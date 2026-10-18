#!/usr/bin/env python3
"""Reconcile retained link inputs and local bounds; never invoke a linker."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile

BUNDLE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--installed', action='store_true',
                        help='also re-read the retained installation and compare all ELF/archive data')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    sources = json.loads((BUNDLE / 'sources.json').read_text())
    with tarfile.open(BUNDLE / 'sources.tar.gz') as tar:
        for row in sources:
            data = tar.extractfile(row['archive_path']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']

    capture = json.loads((BUNDLE / 'capture/result.json').read_text())
    assert len(capture['commands']) == 11
    assert all(row['returncode'] == 0 for row in capture['commands'])
    assert hashlib.sha256((BUNDLE / 'source-build.stdout').read_bytes()).hexdigest() == capture['source_build_log_sha256']
    assert len(capture['environment']) == 7
    query = json.loads((BUNDLE / 'link-script/result.json').read_text())
    assert query['returncode'] == 0
    assert query['outputs_before_metadata'] == ['stderr', 'stdout']
    raw = (BUNDLE / 'link-script/stdout').read_text()
    script = raw.split('==================================================\n')[1]
    installed_script = (BUNDLE / 'link-script/installed-elf_x86_64.xdc').read_text()
    assert script == installed_script + '\n\n'
    tokens = re.sub(r'/\*.*?\*/', '', script, flags=re.S)
    assert not re.search(r'\b(INPUT|GROUP|INCLUDE|STARTUP)\b', tokens)

    inventory = json.loads((BUNDLE / 'inventory.json').read_text())
    command = inventory['collect2_argv']
    assert command[command.index('-rpath') + 1].startswith('$ORIGIN/')
    assert len(inventory['search_directories']) == 14
    for resolution in inventory['library_resolution']:
        probes = resolution['ordered_probes']
        assert all(not p['exists'] for p in probes[:-1])
        assert probes[-1]['exists'] and probes[-1]['path'] == resolution['selected']

    fixed = [row for row in inventory['files'] if row['role'] != 'generated-input']
    assert len(fixed) == 15
    elves = []
    archives = []
    dsos = {}
    for row in fixed:
        count = row['link_argv_occurrences']
        if row['kind'] == 'elf':
            elves.append((row['elf'], count))
            if row['elf']['elf_type'] == 3:
                assert len(row['elf']['soname']) == 1
                dsos[row['elf']['soname'][0]] = row['elf']
        elif row['kind'] == 'archive':
            elves.extend((member, count) for member in row['members'])
            for table in row['archive_metadata']:
                if 'symbols' not in table:
                    continue
                assert table['offset_width'] == 4
                c = table['symbols']
                string_bytes = table['symbol_string_bytes']
                assert set(table['member_header_offsets']) <= {m['header_offset'] for m in row['members']}
                # LP64 carsym is one pointer and one file_ptr.
                storage = 16*c + string_bytes + 1
                assert storage < 2**31 and 4*c < 2**31
                passes = len(row['members']) + 1
                group_scans = 7 if Path(row['path']).name == 'libc_nonshared.a' else 1
                archives.append({'name': Path(row['path']).name,
                                 'argument_occurrences': count,
                                 'members': len(row['members']),
                                 'map_symbols': c, 'raw_offset_bytes': 4*c,
                                 'canonical_map_allocation': storage,
                                 'included_allocation': c,
                                 'symbol_candidate_visits_bound': c*passes*group_scans*count})
    assert set(dsos) == {'libatomic.so.1', 'libc.so.6', 'ld-linux-x86-64.so.2'}
    assert dsos['libatomic.so.1']['dt_needed'] == ['libc.so.6']
    assert dsos['libc.so.6']['dt_needed'] == ['ld-linux-x86-64.so.2']
    assert dsos['ld-linux-x86-64.so.2']['dt_needed'] == []
    for elf, _ in elves:
        assert elf['gnu_lto_sections'] == elf['gnu_offload_lto_sections'] == elf['gnu_object_only_sections'] == 0
    summary = inventory['summary']
    assert sum(count for _, count in elves) == summary['fixed_elf_occurrences']
    for key, total in summary['weighted_fixed_sums'].items():
        assert sum(elf[key]*count for elf, count in elves) == total
    assert max(e['max_input_name_bytes'] for e, _ in elves) == summary['max_fixed_name_bytes']
    assert max(e['max_section_bytes'] for e, _ in elves) == summary['max_fixed_section_bytes']
    assert sum(row['bytes']*row['link_argv_occurrences'] for row in fixed) == summary['fixed_library_file_bytes_weighted']

    # Seven scans of the only group plus two DT_NEEDED hooks can visit the
    # loader nine times; its first occurrence is already in the raw inventory.
    loader = dsos['ld-linux-x86-64.so.2']
    add_symbol_inputs = {key: total + 8*loader[key]
                         for key, total in summary['weighted_fixed_sums'].items()}
    candidate_visits = sum(a['symbol_candidate_visits_bound'] for a in archives)
    # Each common-symbol candidate can independently reread/scan the member's
    # external symbols. Complete symbol counts conservatively bound that scan;
    # this is cumulative work, not one live array or a shared integer counter.
    max_member_symbols = max(member['symbol_records']
                             for row in fixed if row['kind'] == 'archive'
                             for member in row['members'])
    result = {'verified_source_files': len(sources),
              'collect2_argv_positions': len(command),
              'default_script_extra_search_dirs': len(re.findall(r'\bSEARCH_DIR\s*\(', tokens)),
              'archive_maps': archives,
              'archive_symbol_candidate_visits_bound': candidate_visits,
              'maximum_archive_member_symbol_records': max_member_symbols,
              'common_probe_symbol_visits_bound': candidate_visits*max_member_symbols,
              'maximum_archive_map_allocation': max(a['canonical_map_allocation'] for a in archives),
              'fixed_add_symbol_input_bounds_with_loader_revisits': add_symbol_inputs,
              'scope': 'fixed input selection, archive maps, add-symbol input passes and separate common-probe work; not all symbol visits, generated names, string references or final layout',
              'whole_capacity_established': False}
    if args.installed:
        target = args.output / 'installed-inventory.json'
        subprocess.run([sys.executable, str(BUNDLE / 'inventory.py'), '--output', str(target)],
                       check=True, stdout=subprocess.DEVNULL)
        assert json.loads(target.read_text()) == inventory
    (args.output / 'checks.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
