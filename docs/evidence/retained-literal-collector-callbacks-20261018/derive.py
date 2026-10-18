#!/usr/bin/env python3
"""Selected literal collector callback effects; allocation totals stay open."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def require(condition, message):
    if not condition:
        raise ValueError(message)


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include):
        manifest = json.loads((HERE/'inputs.json').read_bytes())
        roots = dict(gcc=Path(gcc_root), ada=Path(ada_root),
                     plugin=Path(plugin_include), repository=REPO)
        for row in manifest['files']:
            raw = (roots[row['root']]/row['path']).read_bytes()
            require(len(raw) == row['bytes'] and
                    hashlib.sha256(raw).hexdigest() == row['sha256'],
                    'changed collector input: '+row['path'])
        prior = REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
        self.old = json.loads((prior/'native-collector-closure.json').read_bytes())
        self.frontier = json.loads((REPO/'docs/evidence/retained-literal-warning-residual-bound-20261018/interface.json').read_bytes())
        self.cold = json.loads((REPO/'docs/evidence/retained-literal-string-layout-20261018/interface.json').read_bytes())
        self.recognizer = runpy.run_path(str(prior/'derive-literal-output.py'))
        self.inputs_verified = len(manifest['files'])


def evaluate(raw, context):
    require(isinstance(raw, bytes) and
            all(32 <= b <= 126 or b in (9, 10, 13) for b in raw),
            'current source alphabet required')
    counts = context.recognizer['source_counts'](raw)
    require(counts['maximum_literal_length'] <= 2**31-1, 'literal length premise')
    frontier, cold, old = context.frontier, context.cold, context.old
    require(frontier['selected_generated_FUNCTION_DECL_body_frontier_closed'] and
            frontier['other_generated_FUNCTION_DECL_bodies'] == 0 and
            frontier['empty_elaboration']['initial_gimplifications'] == 0 and
            frontier['empty_elaboration']['RTL_expansions'] == 0 and
            frontier['cold_string_size_helpers']['FUNCTION_DECLs_created'] == 2 and
            frontier['cold_string_size_helpers']['initial_gimplifications'] == 2 and
            frontier['cold_string_size_helpers']['ordinary_lowering_executions'] == 0 and
            frontier['cold_string_size_helpers']['RTL_expansions'] == 0,
            'generated-body frontier differs')
    require(cold['size_function_parameter_counts'] == [2, 2] and
            cold['size_function_parameter_precision_bits'] == 32 and
            cold['size_function_return_precision_bits'] == [128, 64],
            'helper scalar profile differs')
    finalizers = old['selected_finalizer_effects']
    marking = old['selected_mark_and_cache_effects']
    cache = marking['value_expression_marker']
    require(finalizers['additional_GGC_events'] == 0 and
            finalizers['ordinary_allocation_requests'] == 0 and
            marking['additional_GGC_events'] == 0 and
            marking['other_ordinary_allocation_requests'] == 0 and
            cache['table_initialized_even_when_empty'] and
            cache['ordinary_hash_slots'] == 13 and
            cache['individual_ordinary_hash_backing_bytes'] == 13*8,
            'inherited callback effect interface differs')
    return dict(
        scope='Selected literal-output Main process under reviewed source/configuration premises',
        source=dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()),
        source_counts=counts,
        selected_literal_collector_callback_effects_closed=True,
        value_expression_insertions_upper=0,
        collector_callback_additional_GGC_events=0,
        finalizer_additional_ordinary_allocation_requests=0,
        value_expression_marker=dict(
            ordinary_hash_backing_requests_per_callback=1,
            each_ordinary_hash_backing_bytes=104,
            hash_insertions=0, recursive_tree_walks=0,
            dynamic_vector_backing_requests=0),
        actual_collector_call_count=None,
        total_GGC_events=None, total_finalizer_registrations=None,
        collector_page_and_finalizer_backing=None,
        complete_collector_lifetime_closed=False,
        whole_literal_pipeline_capacity_established=False,
        aggregate_RAM_admission_gate=False,
        source_argument='docs/research/retained-literal-collector-callbacks.md',
        native_tool_executions=0, production_admission_changed=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path, required=True)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--plugin-include', type=Path, required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    context = Context(args.gcc_root, args.ada_root, args.plugin_include)
    result = evaluate(args.source.read_bytes(), context)
    result['inputs_verified'] = context.inputs_verified
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=str(args.output), inputs=context.inputs_verified,
                         callback_GGC_events=0, complete_capacity=False)))
