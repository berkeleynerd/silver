# Partial Output

Authorized and completed on Linux on 2026-10-15, based on `7b5ffea41d`.
All three [roadmap work packages](../roadmap.md#partial-output) are complete.
Git identifies the implementation commit containing this record separately from
that baseline; publication remains authorized.

## Scope

`Silver_IO.Put (Item)` uses the existing bounded String expression grammar,
visibility/hiding and positional or named `Item` association. Put writes exactly
Item bytes without LF, then calls `fflush(NULL)`, even for empty Item. It shares
Put_Line's detected-failure return and sticky status 1. Invalid-input paths must
reject without calling either output operation. Later statements still execute
following a detected output failure.

A separate small checked byte loop retains Put_Line's existing body.
Complete owned-runtime report coverage includes both output postconditions.
The catalogue records the two operations and a per-operation appended-byte map;
common expression, visibility and completion conditions are shared.
The existing Lean statement/effect model and source correspondence cover Put.
All bounds and accepted axioms are preserved.

## Work and validation

Runtime/admission, report policy and assurance are complete. Focused model,
native behavior and report-mutation tests passed. Complete Lean/source validation,
native compiler proof/build and the complete test suite passed. Independent
source/semantic review found no actionable mismatch. Implementation, proof, test,
sample and catalogue inputs stayed frozen throughout the complete checkpoint;
only documentation changed afterward.

The [new sample](../samples/partial_output.adb) builds a greeting using Put for the prefix and selected input,
then Put_Line for the suffix. The input can use all 4096 bytes because each call
has its own bound; no intermediate concatenation exceeds that limit.

### Report capacity

A retained specimen declares an empty String and executes 571 unqualified
`Put(A);` calls. It uses 4094 bytes, padded to the 4096-byte source boundary.
GNATprove, full GNAT build and execution passed. Main emitted 2280 precisely
classified ghost advisories and a 1,020,722-byte report: 48.67% of the unchanged
2,097,152-byte buffer, leaving 1,076,430 bytes. The selected IO report also fits
the unchanged 262,144-byte runtime limit. No arbitrary call cap or report-policy
relaxation was introduced.

The proof took 27.84 seconds with retained isolated solver-cache entries and
other validation running. Sampled aggregate RSS peaked at 336.1 MiB (shared
pages may be counted repeatedly); the largest sampled process was 128.4 MiB.
This is a specimen measurement, not a cold or universal cost bound. Its full
report set passed the Python audit: 47 proof and 19 flow checks, five units,
17 entities, no limitation notes. The production native report policy accepted all five dense reports, including
the Main report in about 0.285 seconds.

The previous 758-assignment/63-concatenation specimen contains no output call;
its source and Main obligations do not change merely because the runtime adds
an unused procedure. Its [1.5% report margin](larger-expressions.md#dense-composition-and-report-capacity)
remains the narrower recorded margin. The new short-call measurement reassesses
the workload specifically made denser by Put; it does not assert an exhaustive
worst-case report bound or remove the documented producer/capacity premises.

### Focused agreement and behavior

A 115-source corpus compares independently expected verdicts, native admission
and compiled Lean `Current.accepts`. All agree. All 82 admitted sources pass full
GNAT object code generation. Cases include empty/static/dynamic expressions,
64/65 leaves, qualified/use-visible and hidden names, named actuals, invalid-input
paths, mixed calls, dense calls, source boundaries and all current samples.
The corpus digest is
`05ee251fcf6870ea96181bd0cad63103ee798c2dc5f1230d9064061bc740b254`.
This is scoped regression evidence, not corpus-wide GNATprove.

Focused runtime tests exercise exact printable bytes, empty Put flushing,
maximum valid input, invalid-input silence, mixed branches and transient write/
flush failures followed by successful later calls with sticky status 1.
The 75 report/evidence tests passed, including separate mutations removing
each required IO postcondition. The frozen complete suite subsequently passed all 319 tests.

Recovery: `tmp/partial-output-active.json`; its timestamped Linux evidence directory
preserves prior canonical evidence. Existing caches and unrelated scratch remain.
No replacement harness goal was requested; the historical Compose String Results
goal is complete. CLI memory tools are unavailable and have not been updated.


## Review and report discovery

The report extension retains exact entity sets and the same approved safety
classes and dependencies. All owned IO entities need complete coverage, and
Put and Put_Line each need a proved postcondition. Eight exact overwritten-ghost
messages replace the prior four-message list; no generic warning relaxation was
introduced. Nine isolated producer probes cover static/dynamic Put-only and mixed
calls, assignment and validity/query variants. Their prototype Put body exactly
matches the delivered body; its successful-byte slice used Written_Count instead
of Item'Length, equivalent under the count equality. Dense/runtime tests use the
actual tracked specification. Native and Python policies accepted every complete
report set (50 native report checks across the nine probes and dense case).

An isolated native probe initially rejected the raw reports because its copied
test harness read only their first line. Reading whole stdin repaired the probe;
no policy change was necessary. Logs retain that failed harness attempt.
The isolated report-package refinement proof passed 968 checks in 748.56 seconds.
Its source was frozen separately; this is focused feedback, not the full compiler
audit. The final checkpoint retains its own current-input evidence.


## Stable Linux checkpoint

The full suite passed **319/319 tests**, with no skips, in 1475.802 seconds
(1476.179 seconds for its runner). All **347 captured implementation, proof,
tooling, test, sample and catalogue inputs** remained unchanged throughout.
Source review and focused native report audits preceded this run. Its result is
against the final frozen source/proof/test bytes, not an earlier tree followed by
unrecorded edits. The native compiler checkpoint passed **3273 checks** (581 flow, 2692 proof),
covering 21 units and 318 entities. It retained 80 classified tool limitation
notes; these are not unproved required checks. The full audit took 1633.585
seconds with four workers and existing sessions/cache available. This was a
complete forced analysis/audit, not a cold measurement. The build passed and
exported catalogue matches the checked-in JSON byte for byte. All 347 captured
inputs stayed unchanged. Native provenance validates 2418 input hashes and
23 reports against the current tree and tools.

The complete Lean check passed for **252 modules**. Its fresh axiom audit
inventoried **57,302 declarations**, using only `propext`, `Classical.choice`
and `Quot.sound`. This is an axiom inventory count, not an independent kernel
replay count. The final runner took **300.618 seconds**, including a 294.449-second
cached build with required integration/example rebuilds and a 3.519-second fresh
audit. It used four Lake workers, four threads per process and a 16384 MiB
per-process threshold. All 347 captured inputs stayed unchanged. The recorded
Lean input digest is
`8425c22bfb42a3a54af7d72e900d3d7d75b83b83cb9ce3b9712a48064da30557`.

The preparatory Lean source build passed all 227 build jobs in **2857.190
seconds** (47.6 minutes). OutputBodyCertificate took 1837 seconds and
ComposeSourceChecks 1010 seconds; the extended whole runtime source bridge
passed in 106 seconds. All five regenerated exact-byte certificates and the
remaining model/source proofs passed. The runner then correctly declined to
issue scoped success evidence because earlier edits, before the final freeze,
had changed its captured input inventory. This was successful preparatory build
work, not a complete stable-input validation claim. The final frozen check reused
those valid objects and performed the fresh whole-project audit. No memory retry,
source repair or kernel bypass was needed; the 16384 MiB per-process allocation
was sufficient. Independent kernel replay is outside this milestone.

## Retained evidence and handoff

The local evidence root is
`.silver/linux-x86_64/partial-output-20261015T144238Z/`. Its `checkpoint/`
contains native, test and Lean runner results with before/after input hashes,
phase logs, `final-native-reports/`, and copies of final Lean evidence/logs.
`source-review.json` records the reviewed source hashes; `differential/` retains
the agreement/code-generation corpus. Preparatory and prior canonical evidence
are preserved separately. Capacity and raw-report probes are under
`.silver/linux-x86_64/partial-output-reports-20261015T142405Z/`.

Existing caches and unrelated scratch are preserved. The previously untracked
`rosetta.md` and `rosetta/` disappeared through an external action during this
task; this task did not edit, move, delete or stage them. No next capability or
replacement harness goal is authorized by this handoff. CLI memory was not
updated because its tools are unavailable; checked-in session memory is current.
macOS validation, hosted CI and independent kernel replay were outside scope.
