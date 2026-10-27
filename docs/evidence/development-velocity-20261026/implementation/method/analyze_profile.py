#!/usr/bin/env python3
"""Scratch Lean 4.34.1 declaration profiler; does not mutate proof inputs.

RSS input is optional JSONL: {"monotonic_ns": int, "rss_bytes": int},
or the measurement launcher's {"monotonic_ns": int, "processes": [...]}.
RSS is process-wide observed usage, never declaration-exclusive allocation.
"""
import argparse
import bisect
import collections
import json
import re
from pathlib import Path


DECL = re.compile(r"^(?:(?:private|protected|noncomputable|partial)\s+)*(def|theorem|lemma|opaque|abbrev)\s+([^\s:()]+)")


def classify(name):
    short = name.rsplit(".", 1)[-1]
    if match := re.fullmatch(r"(.+Tokens)_line_(\d+)", short):
        return {"category": "line_certificate", "ada_line_index": int(match[2])}
    if match := re.fullmatch(r"(.+Tokens)_block_(\d+)_(\d+)", short):
        start, end = int(match[2]), int(match[3])
        return {"category": "reconstruction_single" if end - start == 1 else "reconstruction_join",
                "ada_line_start": start, "ada_line_end_exclusive": end, "ada_line_count": end - start}
    for suffix, category in [("_certificates", "certificate_list"), ("_source", "authoritative_source_equality"),
                             ("_values", "token_flattening_equality"), ("_correct", "final_lexing_theorem")]:
        if short.endswith("Tokens" + suffix):
            return {"category": category}
    return {"category": "explicit_token_list" if short.endswith("Tokens") else "other"}


def inventory(path):
    data = path.read_bytes()
    lines = data.splitlines(keepends=True)
    namespace, offset, declarations = [], 0, []
    for number, line in enumerate(lines, 1):
        text = line.decode("utf-8")
        if text.startswith("namespace "):
            namespace.append(text.split()[1])
        elif text.startswith("end") and namespace:
            namespace.pop()
        if match := DECL.match(text):
            name = ".".join([*namespace, match[2]])
            declarations.append({"name": name, "kind": match[1], "start_line": number,
                                 "start_byte": offset, **classify(name)})
        offset += len(line)
    for index, entry in enumerate(declarations):
        next_entry = declarations[index + 1] if index + 1 < len(declarations) else None
        entry["end_line"] = next_entry["start_line"] - 1 if next_entry else len(lines)
        entry["end_byte_exclusive"] = next_entry["start_byte"] if next_entry else len(data)
        entry["span_bytes"] = entry["end_byte_exclusive"] - entry["start_byte"]
    return declarations


def load_rss(path, command_substring=None):
    if path is None:
        return []
    samples = []
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if "monotonic_ns" not in row:
            raise ValueError("RSS samples need monotonic_ns; epoch_seconds is a different clock")
        if "rss_bytes" in row:
            samples.append(row)
            continue
        if not command_substring:
            raise ValueError("Process-list RSS input requires --rss-command, e.g. OutputBodyCertificate.lean")
        matches = []
        for process in row["processes"]:
            command = process["cmd"]
            if isinstance(command, list):
                command = " ".join(command)
            executable = command.split()[0] if command.split() else ""
            if Path(executable).name == "lean" and command_substring in command:
                matches.append(process)
        if len(matches) > 1:
            raise ValueError("More than one matching Lean process; use a more specific --rss-command")
        if matches:
            process = matches[0]
            samples.append({"monotonic_ns": row["monotonic_ns"], "rss_bytes": process["rss_kib"] * 1024,
                            "pid": process["pid"]})
    if not samples:
        raise ValueError("RSS input has no matching samples")
    return sorted(samples, key=lambda row: row["monotonic_ns"])


def profile_data(path, declarations, rss_path, rss_command=None):
    data = json.loads(path.read_text())
    declared = {entry["name"] for entry in declarations}
    short_names = {name.rsplit(".", 1)[-1]: name for name in declared}
    rss = load_rss(rss_path, rss_command)
    rss_times = [row["monotonic_ns"] / 1e6 for row in rss]
    owners, per_decl = {}, collections.defaultdict(lambda: collections.defaultdict(float))
    per_phase = collections.defaultdict(float)
    coverage, thread_totals = collections.Counter(), {}

    def known_owner(raw):
        # Pinned Lean encodes private names as _private.<module>.<index>.<user>.
        # The current predicate candidate uses private declarations; the retained
        # public-certificate baseline did not exercise these encoded trace names.
        raw = re.sub(r"^_private\..*?\.\d+\.", "", raw)
        while raw:
            if raw in declared:
                return raw
            if raw in short_names:
                return short_names[raw]
            if "." not in raw:
                break
            raw = raw.rsplit(".", 1)[0]
        return None

    def label_owner(label):
        if label in owners:
            return owners[label]
        names = []
        if label.startswith("Kernel: typechecking declarations ["):
            names = label.split("[", 1)[1].rsplit("]", 1)[0].replace(",", " ").split()
        elif label.startswith(("Elab.definition.header: ", "Elab.definition.value: ")):
            names = [label.split(": ", 1)[1].strip()]
        elif label.startswith("Elab.async: elaborating proof of "):
            names = [label.split("elaborating proof of ", 1)[1].strip()]
        mapped = {known_owner(name) for name in names} - {None}
        # Mutual declarations cannot be separated by this trace; leave unassigned.
        owner = next(iter(mapped)) if len(mapped) == 1 else None
        owners[label] = owner
        return owner

    for thread in data["threads"]:
        stack_table, frames, funcs = thread["stackTable"], thread["frameTable"], thread["funcTable"]
        strings, stacks = thread["stringArray"], {}

        def stack_info(index):
            if index is None:
                return ((), False, False)
            if index not in stacks:
                parent_owners, kernel, elaboration = stack_info(stack_table["prefix"][index])
                label = strings[funcs["name"][frames["func"][stack_table["frame"][index]]]]
                owner = label_owner(label)
                chain = parent_owners + ((owner,) if owner else ())
                stacks[index] = (chain, kernel or label.startswith("Kernel:"),
                                 elaboration or label.startswith(("Elab.definition.", "Elab.async: elaborating proof")))
            return stacks[index]

        samples, total = thread["samples"], 0.0
        for index, weight in enumerate(samples["weight"]):
            if weight < 0:
                coverage["negative_weight_samples"] += 1
                continue
            if weight == 0:
                continue
            total += weight
            chain, kernel, elaboration = stack_info(samples["stack"][index])
            phase = "kernel" if kernel else "elaboration" if elaboration else "other"
            per_phase[phase] += weight
            if not chain:
                coverage["unassigned_ms"] += weight
                continue
            owner = chain[-1]
            coverage["assigned_ms"] += weight
            per_decl[owner]["owned_ms"] += weight
            per_decl[owner][phase + "_ms"] += weight
            end_ms = samples["time"][index]
            start_ms = end_ms - weight
            for ancestor in set(chain):
                per_decl[ancestor]["inclusive_ms"] += weight
            if rss:
                left, right = bisect.bisect_left(rss_times, start_ms), bisect.bisect_right(rss_times, end_ms)
                if right > left:
                    observed = max(row["rss_bytes"] for row in rss[left:right])
                    per_decl[owner]["process_rss_observed_peak_bytes"] = max(per_decl[owner]["process_rss_observed_peak_bytes"], observed)
                    per_decl[owner]["rss_sample_matches"] += right - left
        thread_totals[thread["name"]] = total
    categories = collections.defaultdict(lambda: collections.defaultdict(float))
    for entry in declarations:
        entry.update(per_decl[entry["name"]])
        for field in ["owned_ms", "kernel_ms", "elaboration_ms", "other_ms"]:
            categories[entry["category"]][field] += entry.get(field, 0)
    return {
        "profile": str(path), "thread_weight_ms": thread_totals, "sample_phase_ms": dict(per_phase),
        "coverage": dict(coverage), "categories": dict(categories),
        "ranked_declarations": sorted(declarations, key=lambda entry: entry.get("owned_ms", 0), reverse=True),
        "observed_process_peak_rss_bytes": max((row["rss_bytes"] for row in rss), default=None),
        "rss_sample_count": len(rss), "rss_pids": sorted({row["pid"] for row in rss if "pid" in row}),
        "notes": [
            "Timings are traced elapsed milliseconds, not OS CPU measurements. Threads may overlap.",
            "owned_ms assigns each positive self-time slice once to its nearest named declaration frame.",
            "inclusive_ms includes descendant frames and must not be summed across declarations.",
            "kernel/elaboration/other_ms partition owned_ms, with kernel taking precedence.",
            "Unnamed async work and frontend overhead remain unassigned; unrecorded nested events inherit their enclosing scope.",
            "RSS is shared process usage observed during owned slices, not memory allocated by that declaration.",
            "RSS timestamps must use the same host monotonic clock as Lean; sample times in the profile are absolute monotonic milliseconds.",
            "Declaration spans end before the next declaration; intervening whitespace/comments/options are included.",
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--profile", type=Path)
    parser.add_argument("--rss", type=Path)
    parser.add_argument("--rss-command", help="Lean command substring for process-list RSS input")
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    declarations = inventory(args.source)
    result = profile_data(args.profile, declarations, args.rss, args.rss_command) if args.profile else {"declarations": declarations}
    result["source"] = str(args.source)
    args.out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"output": str(args.out), "declarations": len(declarations), "categories": dict(collections.Counter(entry["category"] for entry in declarations))}))


if __name__ == "__main__":
    main()
