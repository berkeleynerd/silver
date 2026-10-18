#!/usr/bin/env python3
"""Reconcile the selected null collector source argument without native runs.

The census is lexical, not a C++ parser or an automatic reachability proof.
Selected type/member and callback dispositions are reviewed in the report.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--options-header', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
raw = (a.gcc_root / 'manifest.json').read_bytes()
assert sha(raw) == '6f0991bf5e0e98ab27d165696913f4db31a9bd9336afcc48937cdbdb0de12480'
manifest = json.loads(raw)
assert manifest['commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
sources = {}
for row in manifest['files']:
    raw = (a.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
assert len(sources) == 4929
identity = json.loads((root / 'collector-closure-inputs.json').read_text())
for row in identity['prior_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
raw = a.options_header.read_bytes()
assert len(raw) == identity['generated_options']['bytes']
assert sha(raw) == identity['generated_options']['sha256']
options = raw.decode()


def common_ada_x86(path):
    parts = Path(path).parts
    return path.endswith(('.cc', '.h')) and (
        (len(parts) == 2 and parts[0] == 'gcc')
        or path.startswith('gcc/ada/gcc-interface/')
        or path.startswith('gcc/config/i386/'))


typed = {}
tables = {}
markers = []
cache_callbacks = []
raw_calls = []
map_helpers = []
for path, source in sorted(sources.items()):
    for number, line in enumerate(source.split('\n'), 1):
        if re.search(r'\bggc_internal_(?:cleared_)?alloc\s*\(', line):
            raw_calls.append({'path': path, 'line': number, 'text': line.strip()})
        if re.search(r'\bhash_map_(?:safe_get_or_insert|safe_put|maybe_create)\s*<', line):
            map_helpers.append({'path': path, 'line': number, 'text': line.strip()})
        if 'GTY' in line and re.search(r'cache\s*\(\s*"', line):
            cache_callbacks.append({'path': path, 'line': number, 'text': line.strip()})
        if common_ada_x86(path) and re.search(r'\bgt_ggc_mx\s*\(', line):
            markers.append({'path': path, 'line': number, 'text': line.strip()})
    if not common_ada_x86(path):
        continue
    for match in re.finditer(r'\b(ggc_alloc|ggc_cleared_alloc|ggc_vec_alloc|ggc_cleared_vec_alloc)\s*<', source):
        start = at = match.end()
        depth = 1
        while depth:
            depth += (source[at] == '<') - (source[at] == '>')
            at += 1
        typename = ' '.join(source[start:at-1].split())
        typed.setdefault(typename, []).append({
            'path': path, 'line': source[:match.start()].count('\n') + 1,
            'allocator': match[1]})
    for match in re.finditer(r'hash_table\s*<\s*(\w+)\s*>\s*::\s*create_ggc', source):
        tables.setdefault(match[1], []).append({
            'path': path, 'line': source[:match.start()].count('\n') + 1})
assert len(typed) == 149 and sum(map(len, typed.values())) == 223
assert len(tables) == 51 and sum(map(len, tables.values())) == 60
assert len(cache_callbacks) == 1 and cache_callbacks[0]['path'] == 'gcc/tree.cc'
assert all(not common_ada_x86(x['path']) or x['path'] == 'gcc/hash-map.h'
           for x in map_helpers)

# Check descriptor inheritance and explicit remove declarations. This does not
# infer the reachability of a table from its textual constructor occurrence.
descriptor_rows = {}
for descriptor in sorted(tables):
    found = []
    pattern = re.compile(r'\bstruct\s+' + re.escape(descriptor)
                         + r'\s*:\s*([^{};]+)\{(.*?)\n\};', re.S)
    for path, source in sources.items():
        if not common_ada_x86(path):
            continue
        for match in pattern.finditer(source):
            found.append((path, source[:match.start()].count('\n') + 1,
                          ' '.join(match[1].split()), match[2]))
    assert len(found) == 1, (descriptor, found)
    path, line, base, body = found[0]
    assert any(k in base for k in ('ggc_ptr_hash', 'ggc_cache_ptr_hash', 'ggc_cache_remove'))
    override = bool(re.search(r'\bremove\s*\(', body))
    assert override == (descriptor == 'loop_exit_hasher'), descriptor
    descriptor_rows[descriptor] = {
        'path': path, 'line': line, 'base': base,
        'remove': 'unlink/free only' if override else 'inherited no-op'}

# Pinned bodies support the handwritten effect argument; substring anchors
# detect the selected interfaces, not all semantic properties of their code.
anchors = {
    'gcc/ggc.h': ['return !__has_trivial_destructor (T);',
                  'static_cast<T *> (p)->~T ();',
                  'ggc_internal_alloc_no_dtor (s, NULL, 0, 1',
                  'ggc_internal_cleared_alloc_no_dtor (s, NULL, 0, 1'],
    'gcc/ggc-page.cc': ['add_finalizer (result, f, s, n);',
                       'if (in_gc)\n    return;', 'v.unordered_remove (i);',
                       'vv.unordered_remove (i);'],
    'gcc/hash-table.h': ['Descriptor::remove (m_entries[i]);',
                         'if (!ggc_test_and_set_mark (h->m_entries))',
                         'for (size_t i = 0; i < h->m_size; i++)'],
    'gcc/hash-map-traits.h': ['entry.m_value.~Value ();'],
    'gcc/hash-traits.h': ['static void remove (T &) {}'],
    'gcc/cfgloop.cc': ['loop_exit_hasher::remove (loop_exit *exit)', 'ggc_free (exit);'],
    'gcc/cfgloop.h': ['typedef generic_wide_int <fixed_wide_int_storage <WIDE_INT_MAX_INL_PRECISION> >'],
    'gcc/vec.h': ['~vec () = default;',
                  'static_assert (std::is_trivially_destructible <T>::value, "");'],
    'gcc/cgraph.h': ['hash_set <const cgraph_node *> GTY ((skip)) cloned_nodes;'],
    'libcpp/line-map.cc': ['line_maps::~line_maps ()',
                         'htab_create (100, location_adhoc_data_hash, location_adhoc_data_eq, NULL);'],
    'gcc/symbol-summary.h': ['new (ggc_internal_alloc (sizeof (T))) T ()'],
    'gcc/ipa-fnsummary.h': ['ggc_alloc_no_dtor<ipa_fn_summary_t> ()'],
    'gcc/ipa-prop.h': ['ggc_alloc_no_dtor <ipa_node_params_t> ()'],
    'gcc/ipa-prop.cc': ['ggc_alloc_no_dtor<ipa_edge_args_sum_t> ()'],
    'gcc/toplev.cc': ['if (time_report || !quiet_flag  || flag_detailed_statistics)'],
    'gcc/gengtype.cc': ['case TYPE_CALLBACK:', 'gt_cleare_cache (%s);',
                        'size_t i%d;', 'wtd->subfield_marker_routine'],
    'gcc/genopinit.cc': ['struct target_optabs {', 'bool pat_enable[NUM_OPTAB_PATTERNS];'],
}
for path, snippets in anchors.items():
    for snippet in snippets:
        assert snippet in sources[path], (path, snippet)
assert sources['gcc/ggc-page.cc'].count('add_finalizer (') == 2
assert sources['gcc/ggc.h'].count('finalize<T>,') == 4
for name in ('cl_optimization', 'cl_target_option'):
    body = options.split('struct GTY(()) ' + name + '\n', 1)[1].split('\n};', 1)[0]
    assert '~' not in body and '(' not in body

prior = json.loads((root / 'native-null-callback-collector.json').read_text())
known = prior['known_GGC_events_through_null_metadata']
assert known == 40098
result = {
    'scope': identity['scope'], 'gcc_commit': manifest['commit'],
    'complete_source_files_verified': len(sources),
    'generated_options_header_verified': identity['generated_options'],
    'prior_result_files_verified': len(identity['prior_results']),
    'lexical_census_is_not_reachability_proof': True,
    'common_Ada_x86_typed_allocation_types': typed,
    'common_Ada_x86_typed_allocation_sites': sum(map(len, typed.values())),
    'common_Ada_x86_table_creation_sites': tables,
    'table_descriptor_removal_join': descriptor_rows,
    'full_corpus_raw_allocation_mentions': raw_calls,
    'full_corpus_hash_map_creation_helper_mentions': map_helpers,
    'full_corpus_named_GTY_cache_callbacks': cache_callbacks,
    'common_Ada_x86_user_marker_mentions': markers,
    'selected_finalizer_effects': {
        'raw_and_no_dtor_allocation_callbacks': None,
        'selected_typed_record_fields': 'Scalars/pointers/fixed scalar storage/plain vec; trivial destructors',
        'hash_table_map_set': 'No-op or unlink/free entry removal; selected map values scalar/pointer/nowarn bitset',
        'symbol_table': 'Ordinary pointer hash_set member frees existing backing',
        'line_maps': 'Delete ordinary ad-hoc htab with NULL element destructor',
        'IPA_summary_managers': 'Explicit no_dtor; raw summary records have no registered callback',
        'alternate_target_JIT_selftest': 'Excluded by selected target/options/frontend',
        'additional_GGC_events': 0,
        'ordinary_allocation_requests': 0,
    },
    'selected_mark_and_cache_effects': {
        'generated_markers': 'Mark before recursively visiting existing bounded fields/arrays',
        'custom_markers': 'Delegate existing members or scalar no-op; profile_probability fields are scalar',
        'dynamic_plugin_JIT_roots': 'Absent',
        'PCH_contexts': 'Absent; context depth zero',
        'memory_statistics_and_time_reports': 'Disabled; quiet frontend has no g_timer',
        'value_expression_marker': prior['null_value_expression_cache_marker'],
        'additional_GGC_events': 0,
        'other_ordinary_allocation_requests': 0,
    },
    'known_GGC_events_after_selected_collector_join': known,
    'collector_backing_substitution': prior['collector_backing_substitution'],
    'selected_null_collector_allocation_closure': True,
    'closure_depends_on_handwritten_source_argument': True,
    'whole_invocation_event_count_complete': False,
    'whole_process_capacity_established': False,
    'remaining_terms': ['Whole-process setup, ordinary library buffers and teardown',
                        'Other phase/request interfaces and assembler/binder/linker/proof-producer joins'],
    'native_execution': False, 'aggregate_RAM_admission_gate': False,
}
a.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'sources': len(sources), 'types': len(typed),
                  'typed_sites': sum(map(len, typed.values())),
                  'table_descriptors': len(tables), 'known_GGC_events': known,
                  'selected_collector_closed': True, 'whole_process_closed': False}))
