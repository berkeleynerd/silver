#!/usr/bin/env python3
"""Check new configuration attachment/arithmetic; no target/predecessor replay."""
import hashlib
import json
import platform
import subprocess
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
R52 = ROOT / 'docs/evidence/retained-adapter-config-composition-20261020'
TIME = ROOT / 'docs/evidence/retained-response-timing-config-20261020'
R55 = ROOT / 'docs/evidence/retained-parallel-logging-prefix-20261020'
ORDER = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']
COUNTS = {}


def checked(group, value):
    assert value, group
    COUNTS[group] = COUNTS.get(group, 0) + 1


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def identity(raw):
    return {'bytes': len(raw), 'sha256': sha(raw)}


def read(path):
    return json.loads(path.read_text())


def project():
    cuts = read(R55 / 'cut-projection.json')
    roles = read(R55 / 'input-role-projection.json')
    recipe = read(R52 / 'recipe.json')
    timing = read(TIME / 'recipe.json')
    checked('domains', set(cuts) == set(roles) == set(ORDER))
    checked('quiet_base', identity((R52 / 'candidate-base-why3.conf').read_bytes())
            == recipe['base_config'])
    original = (TIME / 'base-why3.conf').read_bytes()
    before = recipe['changed_base_line_before'].encode()
    after = recipe['changed_base_line_after'].encode()
    # Ordinary and CE records share the original command. Only the first,
    # ordinary CVC5 record changes; the accepted recipe preserves the CE one.
    checked('quiet_only_change', original.count(before) == 2 and
            original.replace(before, after, 1) == (R52 / 'candidate-base-why3.conf').read_bytes())
    checked('extra_config', (TIME / 'overlay/why3.conf').read_bytes() == b'[main]\nmagic = 14\n')
    for path, expected in recipe['overlay_files'].items():
        checked('candidate_file', identity((ROOT / path).read_bytes()) == expected)
    for changed in timing['changed_lines']:
        entry = timing['driver_closure'][changed['file']]
        with tarfile.open(ROOT / entry['archive']) as archive:
            raw = archive.extractfile(entry['member']).read()
        checked('original_driver', identity(raw) == entry['identity'])
        lines = raw.splitlines(keepends=True)
        old = bytes.fromhex(changed['original_hex'])
        new = bytes.fromhex(changed['replacement_hex'])
        checked('same_length_directive', lines[changed['line'] - 1] == old
                and len(old) == len(new) == changed['bytes'] == 32)
        lines[changed['line'] - 1] = new
        checked('only_directive_change', b''.join(lines) ==
                (TIME / 'overlay' / changed['file']).read_bytes())

    baseline_major = max(cuts[d]['prospective_end_credits']['major_allocation_words']
                         - cuts[d]['logging_delta']['major_envelope_words'] for d in ORDER)
    checked('j12_baseline_major', baseline_major == 945213)
    names = baseline_major + 1
    timeless = 8 * names + 16384
    credits = {'minor_words': timeless + 4096, 'major_words': timeless,
               'remembered_entries': 20 * names + 16384 + 4096}
    checked('credits', credits == {'minor_words': 7582192, 'major_words': 7578096,
                                  'remembered_entries': 18924760})
    result = {'credits': credits, 'baseline_major_words': baseline_major,
              'candidate_filetags_names_upper': names, 'domains': {}}
    for domain in ORDER:
        cut = cuts[domain]
        serial, parallel = roles[domain]['captures']
        opens = parallel['ordered_opens']
        checked('ordered_input_join', len(opens) == 81 and opens == serial['ordered_opens'])
        checked('mapped_input_join', parallel['mapped_files'] == serial['mapped_files'])
        checked('environment_join', parallel['normalized_environment'] == serial['normalized_environment'])
        checked('j12_argv', parallel['argv'] == cut['captured_argv']
                and parallel['argv'][1:3] == ['-j', '12'])
        checked('normalized_argv_join', parallel['normalized_argv'] == serial['normalized_argv'])
        checked('logging_argv', cut['prospective_argv'] ==
                parallel['argv'][:1] + ['--logging'] + parallel['argv'][1:])
        checked('base_input', opens[0]['path'] == 'why3.conf'
                and opens[0]['identity'] == identity(original))
        for name in ['why3.conf', 'cvc5_gnatprove.drv', 'silver_cvc5_no_steps.gen',
                     'z3_gnatprove.drv', 'alt_ergo_gnatprove_smt2.drv']:
            matches = [o for o in opens if o['path'] == '$PRIVATE/overlay/' + name]
            expected = (recipe['extra_config'] if name == 'why3.conf' else
                        timing['driver_closure'][name]['identity'])
            checked('original_private_role', len(matches) == 1
                    and matches[0]['identity'] == expected)
        installed = [o for o in opens if o['path'].endswith('/smt-libv2.gen')]
        checked('installed_import_identity', len(installed) == 6 and all(
            o['identity'] == timing['driver_closure']['smt-libv2.gen']['identity']
            and o['path'] == o['resolved_path'] for o in installed))
        installed_paths = {o['path'] for o in installed}
        checked('installed_import_role', len(installed_paths) == 1)
        old_path = next(iter(installed_paths))
        candidate_path = parallel['private_root'] + '/overlay/smt-libv2.gen'
        checked('shorter_candidate_path', len(candidate_path.encode()) < len(old_path.encode())
                and not any(o['path'] == '$PRIVATE/overlay/smt-libv2.gen' for o in opens))
        # The original input-role equality attaches the already reviewed import
        # control. We do not mislabel the six original opens as six replacements:
        # only selected private-root imports switch, exactly as the R52 recipe.
        logging = cut['prospective_end_credits']
        startup = cut['startup_collection']
        checked('startup_collection_site', startup['startup_guard_order'] ==
                ['caml_minor_collection', 'caml_gc_dispatch', 'caml_empty_minor_heap',
                 'caml_major_collection_slice'])
        checked('pre_collection_margin', startup['prospective_pre_forced_minor_upper'] <= 3312
                and startup['prospective_pre_forced_minor_upper'] < 2**28)
        checked('promotion_delta', startup['prospective_promoted_upper'] == startup['promoted_words'] + 4)
        history = int(startup['promoted_words'])
        checked('integral_history', history == startup['promoted_words'])
        bounds = {'minor_words': logging['minor_words'] + credits['minor_words'],
                  'current_major_words': logging['major_allocation_words'] + credits['major_words'],
                  'remembered_entries': logging['ref_entries'] + credits['remembered_entries'],
                  'ephemeron_entries': logging['ephe_entries'],
                  'custom_entries': logging['custom_entries'],
                  'extra_minor_resources': logging['extra_minor_resources'],
                  'extra_major_resources': logging['extra_major_resources']}
        bounds['all_major_words'] = bounds['current_major_words'] + history
        bounds['contiguous_remnant_words_lower'] = 2**24 - bounds['all_major_words']
        checked('allocation_margins', bounds['minor_words'] < 2**28 and
                bounds['current_major_words'] < 2**28 and bounds['all_major_words'] < 2**24)
        checked('table_margins', all(bounds[key] < 2**25 for key in
                ['remembered_entries', 'ephemeron_entries', 'custom_entries']))
        checked('resource_margins', bounds['extra_minor_resources'] < 1 and
                bounds['extra_major_resources'] < 1)
        checked('large_remnant', bounds['contiguous_remnant_words_lower'] >= 8250999)
        result['domains'][domain] = {
            'original_pid': cut['captured_pid'], 'original_private_root': parallel['private_root'],
            'candidate_argv': cut['prospective_argv'],
            'candidate_base_identity': recipe['base_config'],
            'candidate_private_import': candidate_path,
            'candidate_private_import_bytes': len(candidate_path.encode()),
            'original_installed_import': old_path,
            'original_ordered_input_roles': len(opens),
            'original_startup_major_words': history, 'bounds': bounds,
            'registered_root_count': len(cut['fixed_root_map']),
            'binding_records': cut['checked_binding_records'],
            'session_counters': cut['session_counters'],
            'logging_delta': cut['logging_delta']}
    checked('root_map', sum(r['registered_root_count'] for r in result['domains'].values()) == 118)
    checked('binder_records', sum(r['binding_records'] for r in result['domains'].values()) == 6747)
    checked('path_lengths', [result['domains'][d]['candidate_private_import_bytes'] for d in ORDER]
            == [51, 95, 49, 95, 51])
    return result


def pins_and_sources():
    pins = read(HERE / 'inputs.json')
    for path, expected in pins['accepted_inputs'].items():
        raw = (ROOT / path).read_bytes()
        checked('accepted_identity', identity(raw) == expected['identity'])
        frozen = subprocess.check_output(['git', 'show', expected['freeze'] + ':' + path], cwd=ROOT)
        checked('accepted_freeze', raw == frozen)
    for path, expected in pins['packet_files'].items():
        checked('packet_identity', identity((ROOT / path).read_bytes()) == expected)
    witnesses = read(HERE / 'source-witnesses.json')
    for path in sorted({w['archive'] for w in witnesses}):
        with tarfile.open(ROOT / path) as archive:
            for w in witnesses:
                if w['archive'] != path:
                    continue
                raw = archive.extractfile(w['member']).read()
                selected = b''.join(raw.splitlines(keepends=True)[w['first_line']-1:w['last_line']])
                checked('source_witness', sha(raw) == w['member_sha256']
                        and selected.decode() == w['text'] and sha(selected) == w['slice_sha256'])


def main():
    start = time.perf_counter()
    pins_and_sources()
    checked('new_projection', project() == read(HERE / 'projection.json'))
    print(json.dumps({'status': 'pass', 'platform': platform.system() + ' ' + platform.machine(),
                      'elapsed_seconds': time.perf_counter() - start,
                      'counted_checks': sum(COUNTS.values()), 'check_groups': COUNTS,
                      'native_target_launches': 0, 'predecessor_checker_replays': 0},
                     indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
