# Fixed-length string assignment

Authorized and completed on 2026-10-10 on Linux x86-64, starting from `6403b5c`.
The owner requested completion of this single capability with local validation.
Implementation, native validation, full Lean verification and final evidence
corroboration passed. The Oracle is unchanged.

## Scope

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : String := "Hello";
begin
   Message := "World";
   Silver_IO.Put_Line (Message);
end Main;
```

Exactly one literal-initialized variable, one literal assignment and one final
output call are admitted by the production. The two literals must
have equal decoded lengths; this source-decidable condition preserves the
variable's fixed bounds. Both references must match its declaration ignoring
ASCII case. Existing literal, identifier, trivia and complete-source bounds
apply. Empty strings and doubled quotes are included. Other assignments,
expressions and compositions remain excluded.

## Obligation experiment and report decision

The native GNATprove 16.1 experiment used the author's unmodified source and the
same selected runtime libraries. Equal-length ordinary, empty and escaped-quote
cases emitted no Main safety checks. The unequal-length control emitted a failing
`VC_LENGTH_CHECK`. GNATprove reports the ordinary initializer's overwritten value
as `INEFFECTIVE`, so `--warnings=error` initially exited unsuccessfully even
though the length compatibility was statically settled. The initializer is
necessary here because its value fixes the variable's bounds; the dead-value
advisory is not an unproved safety obligation.

Only admitted assignment programs use `--warnings=continue`, retaining the
warning in console output and `.spark` evidence. `--checks-as-errors=on` and
all other application proof options remain. `Complete_Assignment_Proof` checks
one of two exact producer shapes:

- Main alone, full Main coverage, an empty proof list and dependency list, and
  zero or one precisely identified ineffective-initialization advisory.
- Main and `Silver_IO.Put_Line`, full Main coverage, empty flow/proof lists, and
  exactly one `CLAIM_EFFECTS(Main)` dependency on `CLAIM_EFFECTS(Put_Line)`.

The warning-free dependency shape occurs for legal names such as
`Unused_Message`, following GNAT's naming convention. It does not admit a new
library operation or an assumed safety check. The initial integration test
caught this genuine variation and the corrected policy covers it explicitly.
Other diagnostics in the audited reports, unknown dependencies, skipped/assumed/suppressed checks,
nonempty safety-proof lists and incomplete coverage fail. The six earlier
forms and all selected library reports retain their existing strict policies.
Successful GNATprove termination is required independently of report acceptance;
an empty `warn_error` list alone does not establish either success or the absence
of frontend compiler warnings.
The Ada checker has an independent ghost policy and proved acceptance-refinement
contract; the Python evidence helper uses an explicit assignment-only option.
The experiment's complete sources, reports, command options and hashes are in
`assignment-validation/experiment/summary.json` and its sibling case directories.

## External review disposition

The owner supplied an interim external review of implementation commit `44fd8ea`
and authorized the small follow-up on 2026-10-10 after independent assessment.
No blocking implementation defect was established. The accepted changes restore
existing-clone recovery guidance, scope warning claims to audited report
diagnostics and successful tool status, correct two documentation slips, and
strengthen Python advisory tests. Source membership still selects the report
policy: a different production's report matching the assignment schema does not
make its source an assignment program.

The earlier negative fixtures mutated `.spark` after creating SARIF, so later
cross-report mismatch checks could mask a removed advisory condition. New cases
coordinate both reports and exercise the exact rule, filename, positive
coordinates/entity, message pattern and report-schema name bound. Existing
cross-report mismatch tests remain. The unmodified helper rejected every
independent malformed probe; this was a regression-test gap, not a demonstrated
production acceptance defect. No compiler, runtime, language or Lean theorem
change is warranted by these findings.

Local assessment and focused test records are retained under
`.silver/linux-x86_64/review-44fd8ea/`, with implementation validation in its
`follow-up/` directory. The owner also authorized the bounded
[Lean runner follow-up](lean-concurrency.md#runner-follow-up) to avoid expensive
later phases once inputs are already stale. Broader architecture proposals
remain separate. macOS proof work is explicitly outside this follow-up.

## Assurance and source review

`AssignmentAdmission` defines the 33-token grammar and its independent event
relation, with equality of decoded lengths. `AssignmentSemantics` proves name
binding, unique meaning, initialized values, fixed-length preservation and
output of the replacement bytes. A typed Main composition drives rendering and
ordered initialization/assignment/output interpretation. `AssignmentDisjoint`
separates this form from the earlier six, and `Current` incorporates it into
membership, specified output/failure behavior and conditional automatic discharge.

`AssignmentEquations` and `AssignmentExpressions` connect the checked recursive
suffix and shared lexical/literal/name helpers to that grammar. The source bridge
checks actual expression bodies, contracts and the Main renderer; the public
union and report selector are included. Updated source-shape pins were reviewed
with the new source and semantic arguments. Candidate certificates still
reconstruct the exact authoritative Ada bytes and require kernel checking.
No certificate-representation change, runtime-library change or new trusted
external operation is introduced.

The assignment's statically satisfied length check uses the existing trusted
Ada frontend and faithful GNATprove-generation premise. The real reports
corroborate the empty Main safety-obligation model; samples do not prove that
premise universally. Existing bounded-solver-completion premises for guarded
concatenation and separately audited fixed-library completion remain explicit.
Output failure and external progress retain the existing wrapper semantics.
See [assurance.md](assurance.md#fixed-length-string-assignment) and
[trusted-boundary.md](trusted-boundary.md).

Focused independent review of the recognizer, selector, policy and root-authored
source correspondence found no blocking mismatch. The root separately reviewed
the delegated grammar, assignment semantics and Current integration. Review
inputs and findings are retained in `assignment-validation/review-lean.md` and
`review-lean-inputs.json`; tests and complete proof runs are separate evidence.

## Local validation

The Linux x86-64 compiler audit, full test suite with focused final-delta checks,
Lean source build, fresh axiom audit and independent fresh kernel recheck passed.
Independent evidence corroboration found no mismatched inputs or artifacts.

| Check | Observed result |
| --- | --- |
| `python3 scripts/dev.py prove --full` | Passed: 2907 checks, comprising 407 flow and 2500 proof checks; 16 units, 213 entities, 40 classified limitation notes and 14 approved imports. |
| `python3 scripts/dev.py test` through a symlinked `TMPDIR` | Passed all 156 tests, including proof/build/exact execution of all seven samples. |
| Final Python evidence-helper regressions | Passed all 27 tests, including Boolean/float dependency-reference rejection. |
| Final rebuilt native policy and assignment regressions | Passed all 31 tests, including nine assignment native programs, complete report-policy mutations and catalogue consistency. |
| `python3 scripts/check_lean.py --full --memory-mb 12288` | Passed with retained build cache: 75 modules, 21,443 declarations, only `propext`, `Classical.choice` and `Quot.sound`, and a successful independent fresh kernel replay. Final invocation: 1154.392 seconds. |

The retained certificate build passed all 86 Lake jobs using 12 workers,
12 threads per Lean process and a 6144-MiB per-process memory threshold. The
output-body certificate took 8284 seconds. The owner asked about using the
available RAM; the final full invocation uses 12288 MiB per build/audit process.
The earlier certificate kept its original threshold to preserve its running work.
The resource check and transition are recorded in `lean-memory-increase.json`.
This change provides headroom, not an established speedup; serial certificate
reductions and the separate sequential kernel replay remain. The threshold is
not an aggregate host-memory budget.

The original outer wrapper had captured inputs before the final helper and
report-checker corrections. It was intentionally ended after its successful Lake
build; it is not final full-verification evidence. The final invocation captures
the corrected inputs and reuses the completed artifacts before performing its
fresh audit and independent kernel replay. Its duration must not be presented
as the total source-build time or as a cold replay. The separate `leanchecker`
has no memory-threshold option.

`lean-final-result.json`, `lean-final-evidence.json`, `lean-final-proof.log` and
`lean-final-kernel.log` retain the completed full result. The independent
`lean-final-corroboration.json` matched all 100 shared inputs, 77 workspace inputs,
150 compiled artifacts and three tool hashes, independently re-enumerated the
path sets and actual module closure, and checked overlapping native evidence.
The resource observation in `lean-late-resources.jsonl` and its summary began
partway through the retained build; it is not a complete-run memory peak.

The first full compiler invocation proved all safety checks, but the evidence
auditor rejected four `operator-reassociation` diagnostics in initializer-message
index arithmetic. Explicit parentheses preserve the intended grouping and remove
the warnings. The final full audit passed using existing sessions and the native
solver cache, with unchanged inputs throughout. The initial failed audit and its
reports remain in `native-full-*`; the successful result and reports are in
`native-final-*`. This was a complete audit with cache reuse, not a cold proof run.

The full suite took 1109.7 seconds while other validation ran. Its source, binary,
catalogue and sample inputs stayed unchanged. The Python evidence helper and its
tests changed during that interval: independent review found that Python numeric
equality accepted Boolean/float dependency references. Exact integer checks now
reject them, and the final 27-test run covers the repaired helper. The subsequent
Ada change only adds the explicit grouping described above. Focused native
regressions cover the rebuilt compiler. These elapsed times are validation
observations under overlapping workloads, not controlled benchmarks.

Review records distinguish authorship from independent review:
`review-root.json`, `review-lean.md`, `review-lean-inputs.json`,
`assignment-model-native-review.json`, `native-independent-review.json`,
`native-independent-review-final.json`, and `final-test-review.json`.
`final-native-corroboration.json` independently matches the completed native
evidence to the final inputs, tools, reports and focused-test records.
The initial rejection of valid `Unused_Message` reports
was repaired by the exact effects-dependency alternative. The Python integer-type
finding is closed with retained reproduction and final test hashes. No unresolved
correctness finding remains in those review scopes; final validation is separate.

The later read-only [architecture review](architecture-review.md) recommends
retaining the main boundaries, with small evidence-runner and proof-only I/O
changes as possible follow-ups. Those recommendations and the cleanup nits were
not implemented in this capability. The development workflow now uses targeted
iteration and one full checkpoint on stable inputs, repeating only affected
checks after subsequent changes.

Evidence is retained under `.silver/linux-x86_64/assignment-validation/`.
`native-final-result.json` and the copied native provenance bind the audited source,
configuration, tools and reports. `full-tests.json` retains the suite's original
input hashes and explicitly identifies the helper/test delta;
`evidence-tests-final.json` binds the repaired helper and regression log.
Prior canonical compiler and Lean manifests/logs were copied into
`preserved-before-validation/` before validation; existing proof objects, solver
caches and foreign-host artifacts remain in place. No runtime source changed, so
this increment did not require rebinding installed libraries.

GitHub Actions is disabled; all results here are local. macOS records are entirely
optional. GNAT Pro remains untested. The historical reused-state `DOC_END` failure
is not established as repaired by these successful runs. The external premises
above remain explicit; this increment does not prove the frontend or solver
implementations or introduce a new trusted operation.
