# Independent bounded scalar-procedure capacity/classifier review

Reviewed 2026-11-10 for #370, in the integration worktree. Reviewed source,
classifier, auditor, test and capacity bytes are recorded in the [reviewed-input inventory](../evidence/scalar-procedures-20261109/source-integration/capacity-review-inputs.json); the reviewed paths were clean
when checked at integration commit a7044d6f45dd375b6874f6f78d1a3246b6d95d7a.
Parent selected GPT-6 Astra / Max. Live runtime model/effort are not independently
exposed. No source mutation or new native run was performed.

## Result

No material finding in this bounded producer/storage/classifier review.
One minor documentation correction: in the pinned `gnat2why-expr.adb`,
`New_Assignment` skips `Shift_Rvalue` for a bare identifier and performs its
EW_Pterm conversion at lines 12347–12366, not 12368–12386. Its Regular direct
assignment branch is 12405–12413, not 12432–12442. The actual code supports the
stated single-copy-back-conversion argument.

## Checked argument

- Procedure declaration parsing requires at least one explicit-mode formal and
  at least one writable formal. Valid metadata requires Count > 0, and calls
  consume a name, parentheses, an actual and the enclosing semicolon. Thus
  `P(X);` is a conservative five-byte minimum; the combined function/procedure
  entity bound and formal bounds are consistent with the complete source grammar.
- Writable actuals are bare scalar names. Their preceding delimiter and first
  name byte give disjoint two-byte reservations. Explicit-mode single-name
  formals likewise support the seven-byte lower bound. These are source-site
  counts, not runtime iteration counts.
- Inspected retained producer sources match the capacity record's hashes.
  The mutable-formal Compute_Store path reconstructs and checks the scalar once;
  Regular bare-identifier assignment adds no second checked conversion. The
  Range_Check_Applied flag makes the two possible scalar range-check stages
  exclusive. Excluded component/access/tag/relaxed-initialization branches do
  not need additional charges for the admitted domain.
- The CFG makes one output-view vertex per writable actual. The ineffective
  call-output path emits the exact quoted target/callee message. Declaration
  entities flow through Adjust_Name_Case at their source location, supporting
  exact source declaration spelling rather than call-site case. All supported
  identifiers require no JSON escaping.
- Out formals get initially uninitialized and exported final-use vertices.
  Local_OK/Local_NOK are sets; exported final uses enter Used; the local success
  filter excludes explicitly initialized variables, internal entities and
  function Result, but not source out formals. This supports one required
  successful output-initialization witness per out formal, including an unused
  procedure. No such extra witness is required for in-out formals.
- The added advisory has exact native/raw/Python matching, individual 4096-byte
  identifier bounds and a source-known procedure callee. It retains application
  owner, positive location, main.adb, warning/flow/INEFFECTIVE and absence of all
  suppression/justification markers. Required output initialization coverage,
  function termination coverage and proved safety records remain independent.
  Python also requires corresponding unsuppressed warning/open SARIF diagnostics.
- The extra copy-back, initialization and unused-output allowances are separate
  from the inherited envelope. The arithmetic is 48,676,608 bytes, with
  18,432,256 bytes below the 67,108,864-byte retained Main/report-reader domains.
  Runtime/null bounds remain 262,144 bytes. Maximal schema tests separately charge
  source-name payloads; the callee-name allowance deliberately overcounts each
  advisory by a full source length.

## Evidence and limits

Reviewed the shared mutation tests for both auditors, the serialization/envelope
assertions and the original retained producer/repair packets. Retained run
20261110T022030-5b7c76913372 has actual OK output for both auditors' advisory
controls and the multi-output/in-out/unused-full-domain application. The earlier
Python fixture-only repair also has actual OK output. These were inspected, not
rerun in this review.

At review time the parent reported native run 20261110T022439 finished with only
Record_OK:1774 and Mixed_Record_Congruence:4232 postconditions unresolved under
30-second prover limits; the two procedure-output classifier helpers discharged.
Its production-setting retry was still pending. This review does not convert
that evidence into complete native discharge, nor replace the pending integrated
Lean/source correspondence or complete feature validation. It establishes no
solver-time, stack, peak-memory or arbitrary-producer-JSON guarantee. The storage
argument remains conditional on the pinned producer and existing trusted-tool
premises; sample successes are corroboration, not universal proof.

## Lead disposition

The two producer-line citations were corrected on 2026-11-10. No source,
contract or assurance claim changed. Native caller discharge and complete
feature validation remain pending as described above.
