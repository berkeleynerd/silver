#!/usr/bin/env python3
"""Independent frozen-ledger and selected-source checks; no native tool run."""
import ctypes
import hashlib
import json
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
GCC = Path('/tmp/silver-backend-compose-20261018/full-source')
ADA = Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada')
STRING = 'e652db280a429564fecd06a2b0988c4e9fa8b3c7'
MAIN = 'd528110ba9cdde4b1e7f961cab440ee88f790f23'
REPAIR = '341f9ff8aff91818fc473163fe95fb8a7b297dd5'
SP = 'docs/evidence/retained-literal-string-layout-storage-20261018/'
MP = 'docs/evidence/retained-literal-original-main-storage-20261018/'


def frozen(commit, path):
    return subprocess.check_output(['git', 'show', commit + ':' + path], cwd=REPO)


def load(commit, path):
    return json.loads(frozen(commit, path))


def source(path, first, last):
    # GCC form-feed bytes do not change LF source line numbering.
    return '\n'.join((GCC / path).read_text().split('\n')[first-1:last])


def rho(n):
    return 1 << (n-1).bit_length()


def main():
    checks = []

    def check(name, predicate):
        assert predicate, name
        checks.append(name)

    # Validate Main's attachments independently, reading repository predecessors
    # from the exact freeze, never from whichever worktree happens to be active.
    manifest = load(MAIN, MP + 'inputs.json')
    for row in manifest['files']:
        if row['root'] == 'repository':
            raw = frozen(MAIN, row['path'])
        else:
            raw = ({'gcc': GCC, 'ada': ADA}[row['root']] / row['path']).read_bytes()
        assert len(raw) == row['bytes']
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    check('46_Main_frozen_source_identities', len(manifest['files']) == 46)

    # Independent grouped projection, without importing the author's row table.
    # Constants are charged at the actual extended-unit ceiling, names separately.
    scalar_sites = 2 + 16 + 4 + 6 + 2 + 5 + 14 + 18 + 12 + 18 + 12 + 4 + 12 + 4
    groups = [(23, 256), (4, 16), (2, 48), (10, 32), (1, 24),
              (3, 48), (17, 40), (5, 48), (scalar_sites, 40), (11, 40)]
    names = ['string', 'positive', 'string___XUB', 'string___UB0',
             'string___XUA', 'P_ARRAY', 'P_BOUNDS', 'LB0', 'UB0', 'BOUNDS', 'ARRAY']
    groups += [(1, len(name)+1) for name in names]
    totals = [sum(n for n, b in groups), sum(n*b for n, b in groups),
              sum(n*rho(b) for n, b in groups)]
    interface = load(STRING, SP + 'interface.json')
    check('independent_String_projection', scalar_sites == 129 and totals == [216, 13149, 17112])
    check('String_interface_matches_projection', totals == [interface[k] for k in
          ('GGC_events', 'GGC_caller_bytes', 'GGC_separately_rounded_bytes')])
    check('repair_leaves_all_capacity_interface_bytes_unchanged',
          frozen(STRING, SP+'interface.json') == frozen(REPAIR, SP+'interface.json')
          and frozen(STRING, SP+'derive.py') == frozen(REPAIR, SP+'derive.py'))

    # LP64 field projection checked against tree-core.h's two 32-bit base words,
    # type pointer, and trailing HOST_WIDE_INT array. No C++ compiler is invoked.
    class Typed(ctypes.Structure):
        _fields_ = [('base', ctypes.c_uint32 * 2), ('type', ctypes.c_void_p)]
    class IntCst(ctypes.Structure):
        _fields_ = [('typed', Typed), ('val', ctypes.c_int64)]
    check('LP64_integer_prefix_and_single_unit', ctypes.sizeof(Typed) == 16 and ctypes.sizeof(IntCst) == 24)
    extended = 128 // 64 + 1
    check('unsigned_128_high_bit_extra_word',
          'return cst.get_precision () / HOST_BITS_PER_WIDE_INT + 1;' in source('gcc/tree.cc', 1581, 1589)
          and ((-32) % (1 << 128)) >> 127 == 1
          and ctypes.sizeof(IntCst) + (extended-1)*8 == 40)
    audit = load(REPAIR, SP+'fold-audit.json')
    check('repair_metadata_distinguishes_value_and_extended_words',
          audit['constant_value_words_ceiling'] == 2
          and audit['constant_extended_words_ceiling'] == 3)

    namespace = {'__name__': 'independent_review_frozen_main'}
    exec(compile(frozen(MAIN, MP+'derive.py'), MAIN+':derive.py', 'exec'), namespace)
    evaluate = namespace['evaluate']
    # A separately summed affine event projection detects omitted/duplicated
    # packet rows and preserves the unresolved I parameter.
    cases = 0
    for lengths in ([0], [1], [999, 1000], [0, 999, 1000, (1 << 31)-1]):
        c = len(lengths)
        for n in (0, 3, 17):
            for d in range(1, min(2, c)+1):
                open_result = evaluate(lengths, n, d)
                assert open_result['conditional_direct_totals'] is None
                for i in (0, 1, 114):
                    result = evaluate(lengths, n, d, i)
                    assert result['conditional_direct_totals']['GGC_events'] == 609*c+24*n+54*d+284+i
                    assert result['derived']['R'] == 164*c+16*d+8
                    assert result['shared_demands']['scalar_finalizer_vector_pushes'] == 1
                    assert 'tree_constant_pool' in result['zero_demands']
                    assert result['identities']['DECL_UID'] == 2*c+n+3*d+5
                    assert result['identities']['type_UID'] == 6*c+5*d+3
                    assert not result['complete_original_gigi_storage_closed']
                    assert not result['whole_toolchain_capacity_established']
                    string_rows = [r for r in result['rows'] if r['family'].startswith('STRING_CST_')]
                    assert sum(r['caller_bytes_each'] for r in string_rows) == sum(lengths)+21*c
                    cases += 1
    check('54_mixed_threshold_and_symbolic_I_cases', cases == 54)
    implicit = source('gcc/ada/gcc-interface/trans.cc', 8333, 8340)
    check('implicit_with_returns_list_before_namespace',
          implicit.index('Is_Implicit_With') < implicit.index('gnu_result = alloc_stmt_list')
          < implicit.index('gnu_result = get_namespace'))
    check('namespace_map_finalizer_is_explicit_shared_demand',
          'hash_map<tree, tree>::create_ggc' in source('gcc/ada/gcc-interface/trans.cc', 6416, 6432)
          and 'need_finalization_p<T> ()' in source('gcc/ggc.h', 188, 201)
          and 'G.finalizers[G.context_depth].safe_push (fin)' in source('gcc/ggc-page.cc', 1331, 1343))
    check('constructor_pool_is_deferred_to_gimplification',
          "the CONSTRUCTOR into the constant pool during gimplification" in
          source('gcc/ada/gcc-interface/utils2.cc', 2160, 2195)
          and 'if (TREE_CODE (op0) == CONSTRUCTOR)' in source('gcc/varasm.cc', 5110, 5140))
    print(json.dumps(dict(status='PASS', string_freeze=STRING, main_freeze=MAIN,
                         string_correction=REPAIR, checks=checks,
                         native_runs=0, network_requests=0,
                         limitation='These checks corroborate frozen arithmetic and selected branches; the source review supplies closure.'), indent=2))


if __name__ == '__main__':
    main()
