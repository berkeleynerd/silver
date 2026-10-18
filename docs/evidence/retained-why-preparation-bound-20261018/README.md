# Conditional preparation / inline transfer

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
See the [source argument](../../research/retained-why-preparation-bound.md).

Replay from the repository root with ordinary Python, assertions enabled:

```sh
python3 -B docs/evidence/retained-why-preparation-bound-20261018/check.py
```

`compose.py` exposes `inline_kernel(term, environment)` and
`inline_context(batches)`. They compute conditional natural-number bounds on
opened occurrence size, selected recursive entries, fresh variable identifiers
inside the term kernel, task-chain length and real declaration-tag increments.
The input dimensions must be independently justified for the actual prepared
task; these functions do not parse or certify native inputs. The synthetic
fixtures are explicitly not the five fixed-library tasks.

`compose()` verifies exact dependencies/source identities, reuses the accepted
driver-envelope callable, preserves the exact ordered transformation lists
and applies the new transfers to `fixtures.json`. `result.json` retains that
complete result. `sources.tar.gz` holds fourteen complete Why3 sources,
including the license, all byte-joined to the accepted prefix source archive
and the already downloaded full Why3 archive during acquisition.

`check.py` compares the complete result, checks 600 independent small-tree
expansions against the occurrence recurrence, exercises binder duplication
and nonrecursive replacement, rejects malformed dimensions and an altered
source archive, and replays the standalone CLI. These checks support the
inspected source argument; they do not mechanically prove it. They use no
installed tools, network, native target, compiler or prover.

The next missing inputs are each driver's term/context dimensions after
`update_task` and its transforms preceding `inline_trivial`, plus hidden
substitution/type representations, non-kernel declaration validators and
shared cache/counter lifetimes. Kernel output size does not bound those
representations. All fixed-input/full-preparation/shared-backing/whole-pipeline
capacity flags remain false. `round.json` records the selected model/effort,
measured work interval and verification scope.
