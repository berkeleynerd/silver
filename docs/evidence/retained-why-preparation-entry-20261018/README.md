# First actual cvc5 inlining entry

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
See the [source and scope record](../../research/retained-why-preparation-entry.md).

Replay from the repository root, with assertions enabled:

```sh
python3 -B docs/evidence/retained-why-preparation-entry-20261018/check.py
```

The replay launches no native target, debugger, compiler, server or solver.
`compose.py` verifies byte identities and actual input/driver/task-entry joins,
uses `decode.py`, exports the complete ordered `inline_context` input, and
reuses the reviewed conditional callable only through its first excessive
conservative bound. It never evaluates the astronomical remaining recurrence.

- `capture.tar.gz`: successful read-only GDB capture and raw graph, input JSON,
  private overlay, exact launch/harness, static instruction evidence, process
  and file-read observations, arithmetic traces, and both managed records.
- `sources.tar.gz`: sixteen complete Why3 files, including the license, joined
  to the accepted full archive and overlapping prior preparation sources.
- `drivers.tar.gz`: the fourteen selected driver/import files with exact paths
  and bytes; archive members are read in memory and never extracted.
- `inputs.json`: exact identities and dependency joins.
- `dimensions.json`: per-logical-declaration opened roots, arities, stored
  substitution records, partial type inventory and validator-root dimensions.
- `batches.json`: all 512 ordered task nodes in the accepted transfer schema.
- `result.json`: compact measured result and earliest conservative excess.

`check.py` replays the entire result, checks all 157 binder payloads against
semantic free-variable counts, exercises real-trigger omission and rejects
missing graph/substitution edges, malformed headers, altered stored counts and
archive corruption. Decoder checks also cover pattern variable sets, map-key
order and logic arities. These checks do not mechanically prove source/runtime
correspondence or universal preparation capacity.

This packet covers **one Input_Is_Valid task at its first cvc5 entry**.
All-input/all-driver projection, precise inlining capacity, hidden operational
work, cache/counter lifetimes and whole-pipeline capacity remain open. The
successful native capture is retained; no native rerun is required for replay.
