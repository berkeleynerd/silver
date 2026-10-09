# Command-line review follow-up

This record follows the independent review of `e14ba1a` and the owner's approval
on 2026-10-09. The review found no failure of an admitted program under its
documented premises. This change strengthens proof connections and regression
coverage without adding language forms or changing the Oracle. The baseline
capability is recorded in [command-line.md](command-line.md).

## Independently verified review disposition

The external report is retained locally at `tmp/review-e14ba1a.md`, with logs
and experiments in `tmp/review-e14ba1a-logs/`. These scratch files are not project
inputs or committed artifacts. This document retains the actionable conclusions
and their independent checks:

- The guarded grammar and executable behavior were correct. Its Main meaning
  was separately hand-defined in Lean, so token rendering did not mechanically
  fix initialization order, guard polarity and branch order in the interpreter.
  A narrow typed composition closes that particular connection. General Ada
  frontend semantics remains trusted.
- The current source bridge already checked the three-output-form membership
  expression. The older two-form named-member template was obsolete model
  plumbing, not the active correspondence theorem. Remove it while preserving
  the named-suffix machinery used by the current recognizer.
- Newer expression trees had no mechanical precedence predicate comparable to
  the null bridge's existing check. No incorrect current tree was found. Apply
  equivalent checks to these trees rather than constructing a general parser.
- The report checker correctly handled the reviewed mutations. Missing tests
  concern entity locations, known-but-unexpected entities and ownership of the
  required postcondition. All emitted obligations must succeed, but complete
  obligation generation/reporting remains a trusted GNATprove premise; there
  is no fixed historical total or required record for every category.
- Portable output-failure and representative admission/name regressions are
  worthwhile. Many guard-neighbour tests already existed. The review's scratch
  mutation module ran 21 tests: seven new tests and 14 imported baseline tests.
  Its scratch paths and duplicate discovery are unsuitable for direct adoption.
- CI artifact selection omitted three of the six runtime sources. Catalogue
  wording about declarations was ambiguous. Both are small consistency fixes.
- Internal independent review records were retained, contrary to the report's
  stronger suggestion: for example,
  `.silver/linux-aarch64/argument-integration/INDEPENDENT-REVIEW.md`, with its
  `reviewed-inputs.json`, and the named experiment's `semantic-review.json`.
  The missing item was a clear documentation pointer. Those reviews covered
  prepared implementation/proof inputs and did not replace final validation.

The inherited Main report scanner, additional adversarial workspace defenses,
binary attestations and release machinery remain deferred under the existing
policy. No new failure justifies replacing them in this task.

## Native macOS validation of the baseline

The external reviewer ran `e14ba1a` natively on macOS ARM64 using Alire's
GNAT-FSF/GNATprove 16.1.0, GPRbuild package 26.0.1 and Lean 4.34.1. Linux-side
read-only corroboration checked the retained evidence against that commit:

- The compiler report auditor accepted 16 units, 155 entities, 297 flow checks
  and 1,434 proof checks, with complete coverage and no failed obligation.
  All 2,374 recorded inputs and 18 report hashes matched. The full run used
  four workers, fresh analysis/session output and the existing solver cache.
- The native log records 122 tests passing, with no skips.
- The Lean evidence records full verification, a fresh axiom audit of 14,309
  declarations across 50 modules, and `leanchecker --fresh Silver.Audit`.
  Its 75 inputs, 52 workspace inputs, 100 compiled artifacts, Lean tool hashes
  and log hash matched. The inputs, module list and compiled artifact hashes
  also matched the retained Linux baseline.
- The final `exit=1` in the wrapper log followed the Lean success line and
  `time: sysctl kern.clockrate: Operation not permitted`. It came from the
  timing wrapper; the proof script emits its success evidence only after every
  check and final input comparison passes.

The compiler manifest SHA256 is
`9cab72dda9f4bea80c293ce8f9c3ea1da683397d921765723ed0152e6fc79351`.
The Lean evidence SHA256 is
`39fc5e19391d0bc93d3ad1c84c9d7d793a684c9346ca5328e3c68ad14ba656b6`.
Compiler and Lean durations were approximately 308 and 1,359 seconds; these
are observed runs with cached results and concurrent review/probe activity,
not isolated performance benchmarks.

The external report additionally records 98 application compilations, 278
argument cases and over 287,000 membership probes. These are attributed review
results, not fresh Linux reproductions or universal equivalence proofs. The
local reassessment did run the seven new report-mutation tests together with
their 14 imported baseline tests against the Linux checker; all passed.

Copies of the relevant macOS reports, manifest and logs are preserved under
`.silver/linux-aarch64/review-followup/baseline-macos/`; the original macOS
artifacts were not modified by the Linux follow-up. The macOS Python executable
is external to this checkout and was not independently rehashed on Linux.
GNAT Pro, x86-64 hosts and hosted CI remain untested. This native macOS record
validates `e14ba1a`, not the subsequent changes described here.

## Follow-up implementation and validation

`Arguments.Main.composition` now uses typed expression and statement nodes for
the initializer, reference, validity query and output/rejection branches. The
same nodes supply token rendering and execution. `Main.rendered_tokens` checks
the complete rendering against `Arguments.requiredTokens`; the interpreter
evaluates the initializer without a binding, then creates the immutable binding
before evaluating the body. `Arguments.execute` uses this interpreter directly.
`Arguments.SourceBridge.authoritative_main_correct` joins parsing against the
rendered tokens, checked source facts and interpreter refinement to
`Current.execute`. Independent read-only review found no mismatch in this
connection; its note and input hashes are retained at
`.silver/linux-aarch64/review-followup/INDEPENDENT-REVIEW.md` and
`reviewed-inputs.json` beside it. Ada frontend interpretation of these fixed
nodes remains a reviewed premise; this is not a general verified Ada parser.

Output, Named and Arguments expression bridges now require finite precedence
checks. The obsolete named two-form membership template and callback/equation
fields were removed; the shared named suffix remains. Kernel-checked source
examples cover legal `Main` binding, default/empty/rejected input, swapped
branches, a negated guard and a package-name collision. These supplement the
universal proofs rather than defining admission by samples.

Native regressions now cover exact Arguments/Runtime entity locations,
postcondition ownership and known-but-unselected entities; closed standard
output for both named and guarded forms; nearby excluded syntax; and unusual
legal names/defaults through real GNATprove and GNAT compilation. Consistency
checks compare catalogue word tokens with all four productions and compare
all ten embedded-source lists, certificate mappings and Lake dependencies.
The ambiguous catalogue key `additional_declarations` is now
`declarations_outside_composition`. CI retains all six selected runtime files.
These changes add no admitted syntax or runtime behavior.

Linux ARM64 validation uses `.silver/linux-aarch64/review-followup/`:

- `python3 scripts/dev.py prove --full --jobs 4 -- --subdirs=review-followup`
  passed all 1,731 checks: 297 flow and 1,434 proof, covering 16 units and
  155 entities. The audit accounted for 23 limitation notes and 14 imported
  entities. Fresh unit-analysis/session output reused the native solver cache;
  this is a complete audit, not a cold-proof measurement.
- The native compiler build passed. All 126 tests passed in 127.544 seconds,
  including certificate regeneration, actual Lake cache invalidation and the
  symlinked temporary-directory regression. This was a full native suite, not
  the focused subthread run.
- A separate compiler evidence recheck accepted all 2,389 inputs, 18 reports
  and 12 tool identities. The manifest SHA256 is
  `6ae23c5518a6bf6818791aee310770bb6350d706312c6def9a6928906087d7d3`.
  Stable manifest/report copies are in `review-followup/gnatprove/`.
- `python3 scripts/check_lean.py --full` passed the incremental Lake build,
  fresh axiom audit of 14,570 declarations across 51 project modules, and
  independent `leanchecker --fresh Silver.Audit` recheck. Only `propext`,
  `Classical.choice` and `Quot.sound` were used. The existing ten source
  certificates were reused unchanged; this was not a clean replay. The full
  invocation took 431.878 seconds, an observed duration rather than a benchmark.
  All 76 inputs, 53 workspace inputs, 102 compiled artifacts, three tool hashes
  and the proof-log hash matched afterward. The Lean evidence SHA256 is
  `d8e35ae4e220684e2530d6c9ac319a248940e5a17c62a8c6d46db401624c08b6`.

Final evidence copies, compiler/build/test/Lean logs, independent review and
`final-validation.json` are retained in the native directory above. Local
documentation links and anchors resolve, and `git diff --check` passes. The
follow-up is complete for Linux ARM64.

The Oracle, recognizer, runtime and source certificates are unchanged. Native
macOS validation of this follow-up remains independent and pending. The
baseline macOS evidence above, configured CI and untested x86-64/GNAT Pro
platforms retain their distinct scope.
