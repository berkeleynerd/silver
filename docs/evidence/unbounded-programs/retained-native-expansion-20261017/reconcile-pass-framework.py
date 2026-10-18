#!/usr/bin/env python3
"""Check the retained RTL pass-framework inventory and local arithmetic offline."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'pass-framework-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
sites = {}
for path in ('gcc/cgraphunit.cc', 'gcc/symtab.cc'):
    sites[path] = [i for i, line in enumerate(sources[path].split('\n'), 1)
                   if 'bitmap_obstack_initialize (NULL);' in line]
assert sites == {'gcc/cgraphunit.cc': [316, 582, 607, 700, 1191, 1844, 2238, 2396],
                 'gcc/symtab.cc': [1454]}
anchors = {
    'gcc/function.cc': ['static vec<function *> cfun_stack;',
                        'cfun_stack.safe_push (cfun);', 'if (cfun != new_cfun || force)'],
    'gcc/passes.cc': ['if (execute_one_pass (pass) && pass->sub)',
                      'statistics_fini_pass ();', 'ggc_collect ();'],
    'gcc/dumpfile.cc': ['if (dfi->pstate == 0)\n    return NULL;'],
    'gcc/statistics.cc': ['curr_statistics_hash (false)', 'if (!alloc)\n    return nullptr;'],
    'gcc/plugin.h': ['if (flag_plugin_added)', 'return PLUGEVT_NO_CALLBACK;'],
    'gcc/opts-diagnostic.cc': [': m_cfgs (false)', 'if (gcc_keys.m_cfgs)'],
    'gcc/tree-ssanames.cc': ['vec_safe_splice (FREE_SSANAMES (cfun), FREE_SSANAMES_QUEUE (cfun));'],
    'gcc/bitmap.cc': ['static int bitmap_default_obstack_depth;',
                      'if (bitmap_default_obstack_depth++)',
                      'if (--bitmap_default_obstack_depth)'],
    'gcc/timevar.cc': ['context = XNEW (struct timevar_stack_def);',
                       'if (m_stack && time_report_details)'],
    'gcc/cfgrtl.cc': ['new_bb->succs = bb->succs;', 'bb->succs = NULL;'],
}
for path, strings in anchors.items():
    for string in strings:
        assert string in sources[path], (path, string)
depth = sum(map(len, sites.values()))
assert depth == 9 and depth < (1 << 31)
result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'additional_GGC_object_constructors': 0,
    'normal_RTL_saved_function_stack_logical_depth': 2,
    'cold_saved_function_stack_capacity': 4,
    'cold_saved_function_stack_raw_bytes': 8 + 4 * 8,
    'ordinary_timevar_context_bytes': 2 * 8,
    'default_bitmap_initialization_sites': sites,
    'default_bitmap_initialization_depth_upper': depth,
    'bitmap_retained_object_or_chunk_number_field': False,
    'generic_rtl_split_block_not_selected': True,
    'premises': ['fixed installed pass tree', 'one nonnested emitted function',
                 'no new functions or thunks', 'no GGC plugin',
                 'no pass dumps or forced gates', 'no CFG diagnostics sink',
                 'no profile reporting or detailed timing',
                 'no SSA releases after incoming GIMPLE TODO flush',
                 'no LTO, strub, callgraph-info or optimized x86 feature passes'],
    'required_remaining_inputs': ['pass-specific/global constructor coverage',
                                  'shared GGC page/finalizer composition',
                                  'non-DF pool retained counts',
                                  'metadata/Main translation/unit emission'],
    'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'source_files': len(sources), 'bitmap_depth_upper': depth,
                  'new_GGC_object_constructors': 0,
                  'whole_native_capacity_established': False}))
