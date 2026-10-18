# Retained inlining operational-demand packet

2026-10-18, Linux x86_64, research #119. See the
[source argument and exact boundary](../../research/retained-why-inline-operations.md).

```sh
python3 -B docs/evidence/retained-why-inline-operations-20261018/check.py
```

This is an offline source/capture replay. It starts no native target, compiler,
prover, debugger, server or solver, and performs no new capture.

- `inventory.py` checks the frozen graph's delayed-value, type, pattern and
  ground-data restrictions, joining the accepted all-exclusion semantic model.
- `compose.py` exports the local numerical demand groups and the callable
  `counter_transfer`, `ephemeron_transfer` and `weak_transfer` initial-state
  interfaces. It verifies retained dependencies and complete source members.
- `inventory.json` and `result.json` freeze the complete outputs.
- `inputs.json` pins dependencies, source revisions and every archived byte.
  New Why3 files were joined to the already accepted complete archive; OCaml
  files come from the accepted prefix source packet. `sources.tar.gz` contains
  complete files and both licenses.
- `check.py` checks replay, arithmetic, backing/counter boundaries, small
  ephemeron clearing choices and a material malformed-input rejection.
- `round.json` records selected settings, timing and verification scope.

The fresh-ID increment is at most 1,145. Stored delayed maps have at most 36
keys with six-node values; one formula's stored occurrence envelope is 21,483.
These bounds cover every unknown metadata exclusion set for this one pair.
Shared initial state/comparands, runtime allocation composition, other entries
and later consumers remain explicit inputs. No complete transformation,
process-wide or whole-pipeline capacity verdict is asserted.
