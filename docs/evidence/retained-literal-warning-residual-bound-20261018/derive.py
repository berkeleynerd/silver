#!/usr/bin/env python3
"""Source-closed original-gigi warning count; no complete-pipeline claim."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
FROZEN = HERE.parent / 'retained-literal-warning-map-20261018' / 'derive.py'
R_BREAKDOWN = dict(main_function=1, empty_elaboration_function=1,
                   imported_procedures=2, silver_io_namespace=1,
                   standard_declarations_and_layout=0,
                   size_helper_initial_gimplifications=0,
                   other_selected_routes=0)
R_BOUND = sum(R_BREAKDOWN.values())


def frozen_module():
    manifest = json.loads((HERE / 'source-manifest.json').read_bytes())
    row = next(r for r in manifest['historical_silver_inputs']
               if r['path'].endswith('retained-literal-warning-map-20261018/derive.py'))
    data = FROZEN.read_bytes()
    if len(data) != row['bytes'] or hashlib.sha256(data).hexdigest() != row['sha256']:
        raise ValueError('frozen warning-map transfer identity differs')
    spec = importlib.util.spec_from_file_location('frozen_warning_map', FROZEN)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def evaluate(C, N):
    result = frozen_module().evaluate(C, N, R_BOUND)
    result.update(
        original_gigi_source_count_closed=True,
        original_gigi_residual_put_call_ceiling=R_BOUND,
        residual_breakdown=dict(R_BREAKDOWN),
        source_argument='docs/research/retained-literal-warning-residual-bound.md',
        independent_review='pending',
        complete_imported_frontier_capacity_closed=False,
        whole_literal_pipeline_capacity_established=False,
    )
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('C', type=int)
    parser.add_argument('N', type=int)
    args = parser.parse_args()
    print(json.dumps(evaluate(args.C, args.N), indent=2, sort_keys=True))
