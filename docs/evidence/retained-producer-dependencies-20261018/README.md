# Installed producer fixed-dependency evidence

Linux x86_64, 2026-10-18, #119. Supports the
[fixed producer record](../../research/retained-producer-fixed.md#selected-imported-dependencies).

Five isolated witnesses exercise Put, Put_Line, First_Or_Default,
Input_Is_Valid and Reject. Their complete post-Standard work is retained,
including witness Main work and overlapping imported closures. The additive
source argument is in the [producer report](../../research/retained-producer-capacity.md#additive-isolated-root-envelope);
the measurements alone do not establish a bound for arbitrary Main programs.
The isolated query/Reject witnesses need not meet Silver's complete shell rule.
They are fixed-dependency probes, not newly admitted Silver samples.

- `inputs-and-logs.tar.gz`: exact six current library sources, five Main sources,
  options/invocations, phase-one ALI prerequisites, raw debugger reader and
  guarded runners, result JSON and raw logs. The original `plan.json` and README
  describe their historical prepared state; `summary.json` records execution.
- `graphs.tar.gz`: all 15 complete retained node/list graphs with DWARF layouts.
- `managed-runs.tar.gz`: events and logs for four-library prerequisite generation,
  five witness phase-one runs and five debugger probes. `summary.json` maps IDs.
- `archive-manifest.json`: sizes and SHA256 hashes of every archive member.
- `source-manifest.json`: candidate source identity for conditional arguments;
  its relationship to the historical installed binary remains unestablished.

The probes use the same raw-memory reader as the retained Standard measurement.
They make no inferior calls and stop before Free/backend; `/usr/bin/false` is
also configured as backend. All five reached the before-Free boundary. The
six copied library inputs hash-match the delivered source and the managed run
input records. The retained ALIs were generated from these current inputs;
an older dynamic-256 fixture's library inputs were not reused.

The checker verifies the graphs and occurrence sums, Standard's unchanged
observed graph, all five deltas, current library bytes, managed input hashes,
and successful native-tool phase outcomes:

```sh
python3 docs/evidence/retained-producer-dependencies-20261018/check.py
```

It reads archives without extracting or executing their contents. It does not
prove the general additivity/phase-independence arguments or source-to-binary
correspondence. Library-body Why translation, producer temporary-container
peaks, full proofs, test-suite runs, macOS and CI are outside this evidence.
