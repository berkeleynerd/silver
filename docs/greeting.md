# Literal-backed greeting concatenation

The owner authorized this capability as an active harness goal on 2026-10-09,
following review-repair commit `54844c5`. Its motivating sample is
[samples/greeting.adb](../samples/greeting.adb):

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := "world";
begin
   Silver_IO.Put_Line ("Hello, " & Name & "!");
end Main;
```

The exact grammar is in
[language.md](../language.md#static-output). The initializer,
prefix and suffix may be any existing-domain literals, including empty values
and escaped quotes. The existing named-constant identifier rules apply. Only
one reference appears in the result; its binding ignores ASCII case. The
source remains ordinary Ada/SPARK, passed unchanged to GNATprove and GNAT.

## Bounds and scope

Ada associates the two predefined String concatenations to the left. The first
result joins prefix and initialized value; the second appends suffix. Each
literal contributes once to the output and occupies a distinct source span,
so the combined decoded length and both intermediate lengths are bounded by
the complete 4096-byte source. Quoting, name spelling, syntax and trivia only
consume more source bytes. This requires a combined consumption proof, not
three independent bounds against the source size. All operands are pure;
the result does not depend on their evaluation order.

The grammar is a fifth complete production. It adds no arbitrary expression
grammar, reassignment, repeated name reference, additional declaration,
literal-only concatenation or command-line concatenation. Existing forms and
the Oracle remain unchanged. The proposed command-line greeting would require
an explicit capacity rule accounting for prefix/suffix bytes and remains a
separate, unauthorized increment.

The IO/Arguments runtime files, imported interfaces, source binding and complete
library-report policy are unchanged. All output forms continue selecting six
files and requiring four library-unit reports. Detected output failure returns
status 1, with partial output permitted; external progress, storage and signal
assumptions remain in [trusted-boundary.md](trusted-boundary.md).

## Native obligation experiment

Eleven isolated Linux ARM64 projects were analyzed and compiled with the same
application proof/build options as the driver, including `-U`, the pinned
prover list, deterministic proof-step limit and no wall-clock proof timeout.
They covered ordinary and all-empty strings, escaped quotes, all printable
bytes, legal unusual names, and 4096-byte sources concentrating capacity in each
literal, distributing it across all three, or using a maximal identifier.

Every genuine Main report has empty `flow` and `proof` lists. Each complete
selected-project audit covered five units and sixteen entities, with thirteen
flow and twenty-five proof checks in the selected libraries. Every executable
printed the exact decoded concatenation followed by LF; closed standard output
produced exactly status 1 and no stderr. Source snapshots remained unchanged.
The static literal-backed expression needs no extension to application report
handling. Tool observations supplement the language-wide argument and explicit
faithful-obligation-generation premise; they do not prove the language by tests.

Experiment sources, projects, reports, logs and hashes are retained in
`.silver/linux-aarch64/greeting-experiment/`, with `results.json` and
`evidence-hashes.json`. The exploratory recognizer proof is separate from the
completed-audit harness and is retained under
`.silver/linux-aarch64/greeting-explore/`.
The retained experiment script regenerates eight of the eleven cases; the
additional `all_printable`, `distributed` and `compact_maximum_name` runs have
retained results and artifacts but were not added to that script.

## Implementation and final validation

The compiler adds one punctuation token and a fixed 34-token production, with
a ghost concatenation suffix grammar and an executable loop verified against
it. Existing literal, identifier and source-alphabet helpers are reused. The
catalogue names `string_concatenation` and `concatenated_output`, and exports the
production as `concatenation_tokens`. The sample manifest records expected bytes
and status alongside the four earlier samples.

Final language-wide Lean integration and native validation passed on Linux
ARM64 with GNAT/GNATprove 16.1.0 and Lean 4.34.1.
The first full Lean invocation reached recursion-depth limits while elaborating
the enlarged reviewed token list and final generated source-reconstruction
block. Its failure logs are retained as `lean-full-initial-failure.log` and
`lean-proof-initial-failure.log`. This was an elaboration resource limit;
the repaired source checks subsequently passed full kernel validation.
The repair gives the enlarged implementation-token declaration a local recursion
allowance and sizes the generator's recursion allowance only for reconstruction
joins larger than 32 KiB. For unchanged source inputs, smaller certificates
remain byte-identical. No source check, proof obligation or independent kernel
check is removed. The 19 focused source-generator and evidence tests passed
after this repair in 19.902 seconds; their log is `lean-generator-tests.log`.

The full compiler audit passed all 1,850 checks (302 flow and 1,548 proof),
covering sixteen units and 157 entities. Its command was
`python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=greeting`.
The run used fresh unit-analysis/session output and the existing native solver
cache. It accounted for 24 limitation notes and fourteen imported entities.
The native build, catalogue comparison and manifest-driven five-sample test
passed. Three focused greeting tests passed in 35.512 seconds.
The complete suite passed all 129 tests in 200.120 seconds while the compiler
audit overlapped part of the run; this is an observed duration, not a benchmark.
This complete Linux run preceded the recursion-depth repair; the 19 affected
generator/evidence tests were rerun after that repair, as recorded above.
All 2,389 compiler inputs, eighteen report hashes and twelve tool identities
matched in a separate completed-evidence recheck. The compiler manifest SHA256
is `7fba4e63f2b293e75e791639f70fd710b4a114996f6ea03b5e3e5cc02a280834`.

Separate source and proof reviews found no blocking discrepancy. Their notes
and exact reviewed input hashes are retained as `INDEPENDENT-REVIEW.md`,
`INDEPENDENT-PROOF-REVIEW.md`, `reviewed-inputs.json` and
`reviewed-proof-inputs.json` in the integrated evidence directory. The proof
review checked the combined consumption bound, actual lookup, source-order
literal decoding and complete fifth-form meaning/uniqueness integration.
Those earlier review snapshots predate the final `language.md`/capability-record wording and
one comment-only edit each in `ConcatExpressions.lean` and
`ArgumentsExpressions.lean`. The separate `FINAL-DOCUMENTATION-REVIEW.md`
records the final committed language document's hash. Final Lean validation
covers the committed proof bytes; the older review hashes retain their actual
scope and are not rewritten to imply a later review.

The completed `python3 scripts/check_lean.py --full` invocation reused unchanged
native objects and finished all 69 Lake jobs. The enlarged output-body
certificate took 1,852 seconds. The fresh axiom audit covered 16,249 declarations
across 58 project modules, with only `propext`, `Classical.choice` and `Quot.sound`.
The independent `leanchecker --fresh Silver.Audit` recheck also passed. The full
invocation took 2,454.413 seconds; isolated diagnostic probes overlapped part of
it, so this is an observed duration rather than an isolated benchmark or a clean
replay. All ten generated certificates match their checked-in counterparts.

Afterward, all 83 Lean inputs, 60 workspace inputs, 116 compiled proof artifacts,
three Lean tools and the proof log matched their recorded hashes. Compiler
inputs, tools and retained reports were also rechecked against the current tree.
`final-input-recheck.json` retains the result. The final Lean evidence SHA256 is
`c9a85a9c04357277d0321e9b0985bf8b6e92f9147fa3947e710127d76c450d36`.
The depth-repair review and parity results are retained alongside the semantic
reviews as `PROOF-DEPTH-REVIEW-SUPPLEMENT.md`, `depth-repair-parity.json` and
`reviewed-depth-repair-inputs.json`. No blocking review issue remains.

The enlarged certificate is a measured development cost. A separate bounded
experiment using raw-byte-list equality instead of character-list conversion
received SIGKILL after 148.807 seconds, before its experimental time cap, without
establishing the equality. Its cause was not established and no changes from
that experiment were adopted. The exact probe and result are retained under
`.silver/linux-aarch64/greeting-proof/`. Keep native cache reuse; any future
representation change must preserve exact source reconstruction and demonstrate
successful kernel checking and an actual performance improvement.
Completed evidence is retained in `.silver/linux-aarch64/greeting-final-evidence/`.
The independent native macOS validation below covers this capability. Hosted CI,
x86-64 and GNAT Pro remain untested.

## External review and native macOS validation

The 2026-10-09 external review covers `a73f85e` against `54844c5`. Its full report
and logs are retained in `tmp/review-a73f85e.md` and
`tmp/review-a73f85e-logs/`. It also reviewed documentation commits `c3ca119`,
`9e12c96` and `da0a76e`; later policy commit `29154a8` was outside that review.
No blocking, high or medium finding survived its verification. The following
Linux-side assessment reads and hashes retained evidence; it is not another
native execution or a rerun of the reviewer's scripts.

On macOS ARM64 the compiler audit passed 1,850 checks (302 flow and 1,548 proof)
over sixteen units and 157 entities. All 129 tests passed. Full Lean validation
passed 69 Lake jobs, audited 16,249 declarations across 58 modules with only
standard foundations, and completed `leanchecker --fresh Silver.Audit`.
This is fresh replay through Lean's kernel, not a separately implemented kernel.
The GNATprove audit used a new report/session directory and the existing solver
cache. Lean used `--full`, not `--clean`; its 2,734.783-second duration overlapped
tests and probes. No cold-proof or clean-replay claim follows from those runs.

The retained macOS proof manifest is under
`.silver/macos-aarch64/compiler/obj/review-a73f85e/gnatprove/`; the Lean record is
`.silver/macos-aarch64/lean-evidence.json`, with its log alongside it. Read-only
rehashing on Linux confirmed both hosts' compiler inputs/reports and Lean
inputs/workspace/artifacts. Their 85 combined tracked compiler/Lean inputs match
`a73f85e`; the 83 Lean inputs, 60 workspace inputs and 116 artifact hashes agree
across hosts. The 116 artifacts are 58 `.olean` files plus 58 `.olean.hash`
files, not 116 separately compiled modules. Native test/probe outcomes remain
attributed to the reviewer and retained logs. These establish the reviewed
implementation's scope, not future source changes.

### Finding disposition

- **C1, CI capacity:** confirmed 60-minute configuration and increased observed
  certificate cost; a hosted timeout is unmeasured. Carry capacity/headroom
  assessment into the already proposed bounded performance pass. No arbitrary
  timeout increase or extra proof run is needed for this documentation update.
- **D1–D4, wording and pointers:** corrected String bounds versus lexical
  capacity, the frontend-premise anchor, the platform evidence pointer and the
  destination for capability timings.
- **E1–E3, evidence scope:** clarified the earlier review snapshots, complete
  versus focused Linux test timing, and eight scripted versus eleven retained
  experiment cases above. No evidence of changed proof semantics was found.
- **CRITIC-01, authorization:** the retained owner message at
  `2026-10-09T11:30:02.681Z` says, "Agreed. Please make this a goal we achieve
  using the harnesses' goal feature and drive to completion." The live harness
  record for thread `01a118d1-b593-7a02-941c-6572dc781fbd` created the scoped
  greeting goal at `11:30:11Z`, before commit `a73f85e` at `12:44:23Z`, and marks
  it complete at `12:44:39Z`. The actual session supplies the authorization;
  another owner confirmation is unnecessary.
- **T1–T4, optional witnesses/regressions:** deferred under the owner's policy.
  The sample-meaning probe specializes existing universal existence, uniqueness
  and execution results; the extra names/argv/reserved-word/whole-language
  tests add regression breadth. They do not close a missing language-wide
  theorem. Preserve the passing external probes rather than requiring another
  full replay now.
- **Dynamic concatenation:** the non-admitted command-line contrast produced
  two Main range checks. Preserve this observation in the next capability's
  obligation investigation; it does not prove the proposed guarded form's
  exact obligation set or discharge. That implementation remains unstarted.

The optional 4096-byte concrete Lean evaluation timed out at the reviewer's
30-minute cap. It supplies no result; the existing universal bound and native
boundary checks remain the applicable evidence. The review establishes no need
for an additional solver, proof assistant or certificate framework.
