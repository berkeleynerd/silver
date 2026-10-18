# Fixed selected-driver dispatch envelope

2026-10-18, Linux x86_64, #119. See the
[source argument](../../research/retained-producer-driver-envelope.md).

Replay from the repository root:

```sh
python3 docs/evidence/retained-producer-driver-envelope-20261018/check.py
```

`compose.py` exposes a callable `compose()` that verifies input and source
identities, joins the source archive to the accepted complete prefix, and then
returns the finite call envelope. Its CLI prints JSON or writes it with
`--output`. `check.py` calls that same verified entry point, replays the accepted
initial-registration checker, compares the full composition to `result.json`,
and checks that the standalone CLI rejects altered accepted driver evidence.
The accepted checker runs only once; the tamper check uses an isolated copy.
No installed tool, scratch directory, solver,
network or native run is required.

Inputs are the accepted exact five native inputs, initial raw-task counts,
Input_Is_Valid's raw-four/registered-one classification and three private-driver
lists. The new source argument covers completed valid/nonvalid attempts,
exception paths, late notifications and absence of replay/manual/CE expansion.
It establishes an upper bound of 153 registered tasks, 459 pairs and 6,120 outer
configured transform applications without assuming solver success.

These are call/domain counts, not reconstructed-task or allocation-event counts.
The original task can be reconstructed separately for each driver, and shared
cache/counter lifetimes remain open. All backend printer, prepared-task,
shared-lifetime and whole-pipeline capacity flags remain false. The ordinary
source/runtime/protocol contracts remain assumptions; the source control-flow
proof is not machine checked by the arithmetic script.

`sources.tar.gz` contains 15 complete selected Why3 source files plus the exact
previously pinned imported `ieee_float.mlw`. `inputs.json` records every member
and dependency identity. The three direct floating declarations support the
limited exact generated-maximum calculation in `result.json`; they are not a
complete inventory of future literal origins. `round.json` records selected
settings, timing, validation and open obligations. No historical packet or
byte-pinned report was modified.
