# Fresh Per_Check prefix and private driver evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119), Linux
x86_64, 2026-10-18. The
[research argument](../../research/retained-producer-prefix-per-check.md)
states the exact scope and conditional contracts.

`observations.tar.gz` retains the five-case guarded `gc7` capture, corrected
private overlay, runner/probe, successful-open observations, operand streams,
driver-resolution graph, managed run records and the stopped `gc6` ambiguity
attempt. The original progressive prefix packet remains unchanged.

Run the replay without launching Why3 or a solver:

```sh
python3 docs/evidence/retained-producer-prefix-per-check-20261018/check.py
```

The checker verifies retained byte identities, replays prior component checks,
checks the exact configuration changes and corrected import rename, recomputes
guard/allocation/count conditions, and joins every fixed input to the source
task bounds. `result.json` records those results. `identity.json` names exact
dependencies and managed runs; `round.json` records selected model/effort,
validation and available timing evidence.

Native prefix capture is evidence under the documented fixed-context and
relevant-source-behavior premises. Neither it nor this replay mechanically
proves the source partition, executes the solver tail, bounds raw solver output,
or establishes whole-pipeline capacity. Private files are research fixtures.
