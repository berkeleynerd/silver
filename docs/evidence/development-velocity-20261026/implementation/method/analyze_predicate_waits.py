#!/usr/bin/env python3
"""Retained-profile temporal diagnosis; deliberately does not infer service costs."""
from pathlib import Path
import hashlib
import json

base = Path(__file__).resolve().parent
raw = base / 'predicate-profile.json'
data = json.loads(raw.read_text())
origin = data['meta']['startTime']
intervals = []
trace_weight = 0.0
for thread in data['threads']:
    stacks, frames, funcs, strings = (thread[k] for k in
                                     ['stackTable', 'frameTable', 'funcTable', 'stringArray'])
    def labels(index):
        if index is None:
            return []
        return labels(stacks['prefix'][index]) + [strings[funcs['name'][frames['func'][stacks['frame'][index]]]]]
    samples = thread['samples']
    for index, weight in enumerate(samples['weight']):
        assert weight >= 0, 'Negative slices require separate diagnosis'
        trace_weight += weight
        if not weight:
            continue
        kernel = [label for label in labels(samples['stack'][index]) if label.startswith('Kernel:')]
        if kernel:
            stop = samples['time'][index]
            intervals.append((stop - weight, stop, kernel[-1], thread['name']))
# Sweep the union; overlap is occupancy of traced wall scopes, not active CPU work.
events = sorted([(start, 1) for start, _, _, _ in intervals] +
                [(stop, -1) for _, stop, _, _ in intervals])
active = peak = 0
union = 0.0
previous = events[0][0]
for when, delta in events:
    if active:
        union += when - previous
    active += delta
    peak = max(peak, active)
    previous = when
assert active == 0
ends = sorted(intervals, key=lambda row: row[1])
gaps = []
previous_end = min(row[0] for row in intervals)
for start, stop, label, thread in ends:
    gaps.append({'previous_completion_offset_seconds': (previous_end - origin) / 1000,
                 'completion_offset_seconds': (stop - origin) / 1000,
                 'gap_seconds': (stop - previous_end) / 1000,
                 'completing_scope': label})
    previous_end = stop
summary = json.loads((base / 'profile-predicate/summary.json').read_text())
pids = summary['rss_pids']
observations = []
for line in (base / 'profile-predicate/rss.jsonl').open():
    row = json.loads(line)
    for process in row['processes']:
        if process['pid'] in pids:
            observations.append((row['elapsed_seconds'], process['user_seconds'] + process['system_seconds']))
inputs = [raw, base / 'analyze_profile.py', base / 'finish_profiles.py',
          base / 'profile-predicate/result.json', base / 'profile-predicate/rss.jsonl',
          base / 'profile-predicate/lean-focused-evidence.json',
          base / 'profile/proof/Silver/PredicateSourceCandidate.lean']
lean = base / 'profile/.tools/linux-x86_64/lean/src/lean/Lean'
inputs += [lean / name for name in ['Util/Profiler.lean', 'Environment.lean', 'AddDecl.lean', 'Elab/Tactic/Decide.lean']]
result = {
    'status': 'per-declaration service attribution inconclusive; module observations retained',
    'input_sha256': {str(path.relative_to(base)): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs},
    'trace_threads': len(data['threads']),
    'frontend_span_seconds': (max(data['threads'][0]['samples']['time']) - origin) / 1000,
    'raw_trace_weight_sum_seconds_not_service_cost': trace_weight / 1000,
    'kernel_positive_slices': len(intervals),
    'kernel_scope_weight_sum_seconds_not_service_cost': sum(e - s for s, e, _, _ in intervals) / 1000,
    'kernel_scope_union_wall_seconds_including_waits': union / 1000,
    'peak_overlapping_kernel_scopes_including_waits': peak,
    'sampled_module_process_cpu_seconds_increase': observations[-1][1] - observations[0][1],
    'sampled_module_cpu_window_elapsed_seconds': observations[-1][0] - observations[0][0],
    'largest_global_completion_gaps_not_service_costs': sorted(gaps, key=lambda row: row['gap_seconds'], reverse=True)[:10],
    'limits': [
        'Trace weights and exporter-synthesized threadCPUDelta are elapsed wall intervals, not measured CPU.',
        'Kernel scopes encompass checked-environment future waits and actual checking without a boundary event.',
        'Completion gaps are global observed wall gaps; they are neither per-declaration service costs nor guaranteed cost bounds.',
        'Scope union identifies outstanding kernel-labelled work/wait, not active kernel CPU utilization.',
        'Process CPU samples are cumulative process totals; missing endpoints and no per-thread counters prevent declaration allocation.',
        'Original ranked.json and invalid-attribution.json must not be used for per-declaration cost rankings.',
    ],
}
out = base / 'profile-predicate/attribution-diagnosis.json'
out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({key: value for key, value in result.items() if key not in ['input_sha256', 'limits', 'largest_global_completion_gaps_not_service_costs']}, indent=2))
print(json.dumps(result['largest_global_completion_gaps_not_service_costs'][:4], indent=2))
