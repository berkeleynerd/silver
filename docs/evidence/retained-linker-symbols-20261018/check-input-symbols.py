"""Reconcile the selected ELF input symbol-constructor transfer."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sources = {}
for prefix in ('', 'input-symbol-'):
    manifest = json.loads((root/f'{prefix}sources.json').read_text())
    assert manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
    archive_path = root/f'{prefix}sources.tar.gz'
    assert hashlib.sha256(archive_path.read_bytes()).hexdigest() == manifest['archive_sha256']
    with tarfile.open(archive_path) as archive:
        assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
        for row in manifest['files']:
            raw = archive.extractfile(row['path']).read()
            assert len(raw) == row['bytes']
            assert hashlib.sha256(raw).hexdigest() == row['sha256']
            sources[row['path']] = raw.decode()

anchors = {
    'bfd/elflink.c': [
        'for (isym = isymbuf, isymend = PTR_ADD (isymbuf, extsymcount);',
        'h = elf_link_hash_lookup (elf_hash_table (info), name, true, false, false);',
        'memcpy (shortname, name, shortlen);',
        'memcpy (shortname + shortlen, p + 1, len - shortlen);',
        'name += sizeof ".gnu.warning." - 1;',
        'old_count = htab->root.table.count;',
        'htab->root.table.count = old_count;',
        'objalloc_free_block ((struct objalloc *) htab->root.table.memory,',
        'false, bed->collect, NULL)))',
        'table->dynsymcount = 1;',
        '++elf_hash_table (info)->dynsymcount;',
    ],
    'bfd/linker.c': [
        'if (hashp != NULL && *hashp != NULL)',
        'h = *hashp;',
        'if (info->wrap_hash != NULL)',
        '(NULL, &info->hash->table, h->root.string)))',
        '*sub = *h;', 'bfd_hash_replace (&info->hash->table,',
        'if (collect && name[0] == \'_\')',
    ],
    'bfd/elfxx-target.h': ['#define elf_backend_collect false'],
    'bfd/elf64-x86-64.c': ['const char **namep ATTRIBUTE_UNUSED,',
                          'elf_x86_64_add_symbol_hook'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)
assert '#define elf_backend_collect' not in sources['bfd/elf64-x86-64.c']
link = sources['bfd/elflink.c'].split('\n')
for line in (1531, 2117, 5688, 5693, 6096, 6111):
    assert 'bfd_elf_link_record_dynamic_symbol' in link[line-1]
weak_alias_loop = '\n'.join(link[6009:6120])
assert 'dynindx =' not in weak_alias_loop.replace('dynindx ==', '')

inputs = root.parent/'retained-link-inputs-20261018'
# These counts are the already reviewed add-symbol pass bounds, not archive
# candidate scans or their much larger inner common-symbol work counts.
inventory = json.loads((inputs/'inventory.json').read_text())
fixed_record = json.loads((root/'fixed-version-inputs.json').read_text())
assert hashlib.sha256((inputs/'inventory.json').read_bytes()).hexdigest() == fixed_record['inventory_sha256']
fixed = inventory['summary']['weighted_fixed_sums']
loader = next(f['elf'] for f in inventory['files'] if f['path'] == '/lib64/ld-linux-x86-64.so.2')
r = fixed['symbol_records'] + 8*loader['symbol_records']
q = fixed['sections'] + 8*loader['sections']
assert (r, q) == (49081, 36433)
bound = 3*r+2*q
assert bound == 220109
assert bound < 805306341
result = dict(scope='Selected ELF add-object-symbols and warning constructor contribution',
              source_files_verified=len(sources),
              fixed_symbol_record_passes=r, fixed_section_record_passes=q,
              fixed_global_entry_constructor_contribution_upper=bound,
              fixed_input_dynamic_registration_increments_upper=8*r,
              input_registration_bound='8*R; includes registrations lost to as-needed rollback',
              general_bound='3*R+2*Q; Q bounds .gnu.warning sections across input passes',
              generated_input_contribution='3*R_generated+2*Q_generated',
              script_and_synthetic_and_output_version_contributions_included=False,
              rollback_snapshots_and_name_copy_requests_included=False,
              whole_dynamic_symbol_registration_lifetime_included=False,
              whole_link_capacity_established=False, native_execution=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result))
