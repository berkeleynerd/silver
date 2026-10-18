"""Reconcile retained ELF symbol/version source identities and arithmetic."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
record = json.loads((root / 'sources.json').read_text())
assert record['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02'
sha = lambda b: hashlib.sha256(b).hexdigest()
assert sha((root / 'sources.tar.gz').read_bytes()) == record['archive_sha256']
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in record['files'])
    for row in record['files']:
        data = archive.extractfile(row['path']).read()
        assert len(data) == row['bytes'] and sha(data) == row['sha256']
        sources[row['path']] = data.decode()

anchors = {
    'bfd/elflink.c': [
        'unsigned long dynsymcount = 0;',
        'elf_section_data (p)->dynindx = dynsymcount;',
        'if (info->optimize)',
        's->size = dynsymcount * sizeof (Elf_External_Versym);',
        's->size = dynsymcount * bed->s->sizeof_sym;',
        'amt = dynsymcount * 2 * sizeof (unsigned long int);',
        'else if ((1 << (maskbitslog2 - 2)) & cinfo.nsyms)',
        'cinfo.maskbits = 1 << maskbitslog2;',
        'maskwords = 1 << (maskbitslog2 - cinfo.shift1);',
        's->size = (4 + bucketcount + cinfo.nsyms) * 4;',
        's->size += cinfo.maskbits / 8;',
        'if (t == NULL && bfd_link_executable (info))',
        'version_index = 1;', 't->vernum = version_index;',
        'if (verdefs == NULL && !info->create_default_symver)',
        'sinfo.vers = elf_tdata (output_bfd)->cverdefs;',
        'sinfo.vers = 1;', 'vn->vn_cnt = caux;',
        'a->vna_other = rinfo->vers + 1;',
        'a->vna_other = h->verinfo.verdef->vd_exp_refno + 1;',
        'iversym.vs_vers |= VERSYM_HIDDEN;',
    ],
    'ld/ldmain.c': ['struct bfd_link_info link_info;'],
    'ld/lexsup.c': ['link_info.optimize = strtoul (optarg, NULL, 0) != 0;'],
    'bfd/elf64-x86-64.c': [
        'const char *version[4] = { NULL, NULL, NULL, NULL };',
        '"GLIBC_ABI_DT_RELR"', '"GLIBC_ABI_GNU2_TLS"',
        '"GLIBC_ABI_DT_X86_64_PLT"', '"GLIBC_2.36"',
    ],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)
link = sources['bfd/elflink.c']
buckets = link.split('static const size_t elf_buckets[] =', 1)[1].split('};', 1)[0]
buckets = [int(x) for x in re.findall(r'\d+', buckets)]
assert buckets == [1, 3, 17, 37, 67, 97, 131, 197, 263, 521, 1031,
                   2053, 4099, 8209, 16411, 32771, 0]
external = sources['include/elf/external.h']
for field, width in [('vd_cnt', 2), ('vd_ndx', 2), ('vn_cnt', 2),
                     ('vna_other', 2), ('vna_name', 4), ('vn_next', 4),
                     ('vs_vers', 2)]:
    assert re.search(r'\b' + field + r'\[' + str(width) + r'\]', external)
common = sources['include/elf/common.h']
assert re.search(r'#define VERSYM_HIDDEN\s+0x8000', common)
assert re.search(r'#define VERSYM_VERSION\s+0x7fff', common)

def mask_exponent(n):
    assert n > 0
    k = n.bit_length()
    m = 5 if k < 3 else k + (3 if n & (1 << (k-2)) else 2)
    return max(m, 6)

# For each bit-length region, the quarter-bit test changes once at 3*2^(k-2).
# Check both endpoints of each resulting interval. The exponent is constant
# within that interval by construction; this is not exhaustive symbol testing.
safe_max = 3 * (1 << 26) - 1
intervals = []
for k in range(1, 33):
    lo, hi = 1 << (k-1), (1 << k)-1
    split = 3 * (1 << (k-2)) if k >= 3 else hi+1
    for a, b in [(lo, min(hi, split-1)), (split, hi)]:
        if a > b:
            continue
        m = mask_exponent(a)
        assert m == mask_exponent(b)
        assert (m <= 30) == (b <= safe_max)
        intervals.append({'first': a, 'last': b, 'exponent': m, 'safe': m <= 30})
assert mask_exponent(safe_max) == 30
assert mask_exponent(safe_max+1) == 31
D = (1 << 32)-1
B = max(buckets)
W = 1 << 24
gnu_bytes = 4*(4+B+safe_max)+8*W
assert gnu_bytes == 939655192
requests = {'dynsym': 24*D, 'versym': 2*D, 'sysv_hashcodes': 8*D,
            'sysv_hash': 4*(2+B+D), 'gnu_hashcodes': 16*D,
            'gnu_bitmask_and_buckets': 8*W+16*B, 'gnu_hash': gnu_bytes}
assert all(0 < n < (1 << 63) for n in requests.values())
version_limit = 32767
U = version_limit-1
assert 16*(2*U) == 1048512 < (1 << 32)
assert 28*version_limit < (1 << 32)
assert U < (1 << 16)

result = {
    'scope': 'Conditional LP64 nonoptimizing ELF dynamic-symbol/hash/version transfer',
    'source_files_verified': len(sources),
    'caller_count_limits': {'dynamic_symbols_including_null': D,
                            'section_symbol_prefix': (1 << 31)-1,
                            'GNU_hashed_symbols_no_signed_shift_overflow': safe_max,
                            'maximum_nonhidden_version_index': version_limit},
    'GNU_hash_shift_intervals_checked': intervals,
    'individual_allocation_upper_bytes': requests,
    'version_need_section_upper_bytes': 16*(2*U),
    'version_definition_section_upper_bytes': 28*version_limit,
    'x86_backend_dependency_additions_upper': 4,
    'whole_link_capacity_established': False,
    'native_execution': False,
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: result[k] for k in ['source_files_verified', 'caller_count_limits',
                                       'whole_link_capacity_established', 'native_execution']}))
