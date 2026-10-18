# Independent literal producer specialization review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted within its stated producer-core scope; no unresolved material finding.

Reviewed implementation target `78b31c252362b8f798e1dd095002b5523fa86241`, then
the complete correction diff through `5b5fb19bb74a79aadc44c183fbb3ca6bdf6c5ab8`.
The correction changes only the source argument and its manifest identity.
Reviewer selection: GPT-6 Astra, Extra High. Those are the parent-selected
settings; the reviewer has no independent runtime confirmation. The measured
source-review/check window was 17:47:33–17:49:20 UTC (107 seconds), excluding
report authoring. Token and cost measurements are unavailable. Host inspection
reported Linux 7.0.14 x86_64.

Inputs were this packet's `compose.py`, `check.py`, `inputs.json`, `result.json`
and README; the linked specialization, zero-check, selected-call and general
composition arguments; the reused complete literal recognizer and general
producer callable; current `src/silver.adb` and `src/silver_io.ads`; and the
identified SPARK files in the retained source archive at revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.

The source check covered the driver snapshot/emission guard, VC counter update,
literal translator including empty and nonempty paths, parent-type conversion,
generated-type early return, procedure precondition/termination guards, and
statement-list composition. The predecessor's unchanged Main wrapper and other
selected-call exclusions remain reused premises, rather than a fresh exhaustive
review of the whole producer.

One low-severity source-explanation error was found and fixed: the original
paragraph attributed empty literals to the nonempty known-high-bound branch.
The actual empty path at `gnat2why-expr.adb:30552–30576` checks the static lower
bound against the index base type's first value. With lower bound 1, that
assertion succeeds and leaves `Checks` true. The correction records this branch
separately. The claimed zero registrations and implementation were unaffected.

The complete recognizer selects only the stated shell and derives its counters
from those same bytes. Ordinary literals, including empty ones, and unchanged
Put/Put_Line contracts introduce no Main check on the inspected paths. Repeating
these statements adds no new checking construct or global-effect root. The old
4096-byte cap does not occur in those path guards; remaining representation and
frontend bounds still apply. The strict-increase driver guard therefore excludes
Main JSON emission and backend launches under the retained source-behavior
premise. The current driver pin is correctly separate from the historical local
driver identity.

Direct comparison with the general callable confirmed that the specialized
predicate keeps all ten other conjuncts, including construction, occurrences,
String, pool, map and undo bounds. Only the hypothetical per-file JSON-byte
condition is omitted. The five fixed-library inputs and all unfinished pipeline
obligations remain explicit; this is neither whole-pipeline capacity nor a
production admission change.

An independent offline run with output under `/tmp` reproduced all 39 checks and
the retained result exactly. Additional evaluations covered empty Put_Line and
5,001 mixed Put/Put_Line calls, mostly empty, with a null statement. Both selected
the specialized core; the larger case failed the general JSON envelope. These
evaluations check attachment/arithmetic, not the universal source argument.
No compiler, GNATprove, Why3, solver, Lean, native build or suite was executed.
