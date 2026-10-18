# Retained inlining conditional-demand packet

2026-10-18, Linux x86_64, research #119; scope correction for #133. See the
[source argument and representative contract](../../research/retained-why-inline-operations.md).

```sh
python3 -B docs/evidence/retained-why-inline-operations-20261018/check.py
```

This is an offline source/capture replay. It starts no native target, compiler,
prover, debugger, server or solver, and performs no new capture.

- `inventory.py` checks the frozen graph's delayed-value, type, pattern and
  ground-data restrictions. It covers captured roots, not selectable old
  declarations in the shared `Hsdecl` table.
- `representatives.py` states the uninstantiated coverage/invariant contract,
  validates numeric hypotheses only, and models returned-old selection with
  arbitrarily many saved keys and their subsequent downstream traversal.
- `compose.py` exports conditional arithmetic, selection-independent topology
  requests, and pure `counter_transfer`, `ephemeron_transfer`, `weak_transfer`
  interfaces. It verifies retained dependencies and complete source members.
- `inventory.json` and `result.json` freeze the outputs. All representation-
  dependent ceilings, including 1,145 fresh identifiers and 669 type requests,
  are under `conditional_arithmetic`. The actual representative envelope is
  null and `local_structural_and_registration_transfer_established` is false.
- `inputs.json` pins dependencies, source revisions and every archived byte.
  `sources.tar.gz` retains complete relevant files and both licenses.
- `check.py` replays arithmetic, models selection of older 37/128-key maps,
  checks envelope propagation, rejects caller coverage flags and preserves
  the established=false result. It also retains the counter/backing boundary,
  small ephemeron-clearing and malformed captured-input checks.
- `round.json` preserves the historical original round, whose local-capacity
  claim was rejected in review. `round-repair.json` records this correction.

The no-argument calculation uses captured `(E,V,T,A)=(8,6,3,80)` only as a
**hypothesis** about selectable representatives. Its conditional 36-map-key,
21,483-stored-occurrence and 1,145-identifier numbers are not established
ceilings for the native invocation. Supplying larger numeric hypotheses
changes downstream conditional arithmetic; it cannot establish coverage.

An actual representative projection or source/process invariant, opened-body
and eligibility correspondence, initial shared state, comparator costs and
runtime allocation composition remain required. No complete local,
transformation, process or whole-pipeline capacity verdict is asserted.
