#!/usr/bin/env python3
"""Check one-stream trace intervals before interpreting serialized diagnostics."""
import argparse
import json
from pathlib import Path


def peak_overlap(intervals):
    events = sorted([(start, 1) for start, stop in intervals if stop > start] +
                    [(stop, -1) for start, stop in intervals if stop > start])
    active = peak = 0
    for _time, change in events:
        active += change
        peak = max(peak, active)
    assert active == 0
    return peak


def union_duration(intervals):
    total = 0.0
    right = None
    for start, stop in sorted(intervals):
        if right is None or start > right:
            total += stop - start
        elif stop > right:
            total += stop - right
        right = stop if right is None else max(right, stop)
    return total


def verify(raw, ranked=None):
    data = json.loads(raw.read_text())
    assert len(data["threads"]) == 1, "Serialized attribution requires one traced stream"
    thread = data["threads"][0]
    assert thread["isMainThread"]
    stacks, frames, functions = thread["stackTable"], thread["frameTable"], thread["funcTable"]
    strings = thread["stringArray"]
    labels = {index: strings[functions["name"][frames["func"][frame]]]
              for index, frame in enumerate(stacks["frame"])}
    frontend = [index for index, label in labels.items() if label.startswith("runFrontend:")]
    assert len(frontend) == 1
    root = frontend[0]
    assert stacks["prefix"][root] is None
    samples = thread["samples"]
    start = data["meta"]["startTime"]
    stop = max(samples["time"])
    span = stop - start
    tolerance = max(0.001, span * 1e-10)
    assert abs(min(samples["time"]) - start) <= tolerance
    intervals, kernel_spans = [], {}
    for index, weight in enumerate(samples["weight"]):
        assert weight >= 0, "Negative slice weight"
        if not weight:
            continue
        assert index > 0 and samples["weight"][index - 1] == 0
        assert samples["stack"][index - 1] == samples["stack"][index]
        left, right = samples["time"][index - 1], samples["time"][index]
        assert right >= left and abs(right - left - weight) <= tolerance
        intervals.append((left, right))
        cursor = samples["stack"][index]
        chain = []
        while cursor is not None:
            chain.append(cursor)
            if labels[cursor].startswith("Kernel:"):
                old = kernel_spans.get(cursor, (left, right))
                kernel_spans[cursor] = (min(left, old[0]), max(right, old[1]))
            cursor = stacks["prefix"][cursor]
        assert root in chain
    slice_overlap = peak_overlap(intervals)
    kernel_overlap = peak_overlap(list(kernel_spans.values()))
    union = union_duration(intervals)
    total = sum(samples["weight"])
    assert slice_overlap == 1, "Serialized self-time slices overlap"
    assert kernel_overlap == 1, "Serialized Kernel scopes overlap"
    assert abs(union - span) <= tolerance, "Absolute slice intervals do not cover frontend span"
    assert abs(total - span) <= tolerance, "Trace weights do not conserve the frontend span"
    result = {"status": "serialized interval checks passed", "trace_threads": 1,
              "frontend_start_monotonic_ms": start, "frontend_stop_monotonic_ms": stop,
              "frontend_span_ms": span, "positive_slice_union_ms": union,
              "positive_slice_weight_ms": total, "peak_overlapping_positive_slices": slice_overlap,
              "kernel_scopes": len(kernel_spans), "peak_overlapping_kernel_scopes": kernel_overlap,
              "kernel_scope_union_ms": union_duration(list(kernel_spans.values())),
              "tolerance_ms": tolerance,
              "notes": ["Absolute timestamp interval coverage and non-overlap checked independently of owner arithmetic.",
                        "These are serialized diagnostic traced elapsed costs; OS scheduling/GC can remain inside scopes.",
                        "No recovered normal-async per-declaration CPU/service cost is claimed."]}
    if ranked:
        analysis = json.loads(ranked.read_text())
        coverage = analysis["coverage"]
        named = sum(entry.get("owned_ms", 0) for entry in analysis["ranked_declarations"])
        unassigned = coverage.get("unassigned_ms", 0)
        assert abs(named + unassigned - span) <= tolerance
        assert abs(named - coverage.get("assigned_ms", 0)) <= tolerance
        assert abs(sum(analysis["sample_phase_ms"].values()) - span) <= tolerance
        result.update({"named_exclusive_ms": named, "unassigned_ms": unassigned,
                       "named_plus_unassigned_minus_frontend_ms": named + unassigned - span})
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", type=Path)
    parser.add_argument("--ranked", type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    result = verify(args.profile, args.ranked)
    args.out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))
