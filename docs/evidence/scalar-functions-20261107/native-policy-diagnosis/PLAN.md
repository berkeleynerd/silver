# Proposed bounded auditor repair for failed native run 094547

Status: recommendation only. No production/test patch or validation execution
was performed by the diagnosing reviewer. The critical policy interpretation
needs independent review before acceptance. Keep integration's active Lean
inputs frozen until its actual exit.

## Exact proposed files

- `scripts/check_evidence.py`: two narrow classifiers described below.
- `tests/test_evidence.py`: meaningful positive and negative regression cases
  for those classifiers and their interaction with existing policy rejection.
  Extending existing test methods is acceptable; any new IDs must be reflected
  in the final inventory. No deadline or assertion relaxation.
- `docs/trusted-boundary.md`: explain the safe compiler-only annotation form
  and the separate pinned-GNAT portability diagnostic. Link the pinned sources.
- Existing capability/evidence records as needed to retain the failed run and
  eventual actual outcomes. No Ada, Lean model, certificate or source-pin edit.

## R2 (medium): source-policy recognition

Keep the forbidden pragma set and fail-closed default. For an Annotate pragma,
allow only the complete token shape:

`pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", TARGET);`

Restrict this correction to `silver_library_reports.adb`, with TARGET exactly
`Raw_List_Spec` or `List_Spec` under Ada identifier case equivalence. Preserve
the quoted string exactly. Use existing `source_tokens`; comments/layout are
already removed while literal contents are retained. Validate the full argument
and closing-semicolon token sequence. Do not approve a prefix, substring,
line-number range, matching file hash, arbitrary fourth argument or any other
Annotate category. No scope parser or new framework is needed for these exact
safe statements. Their semantic safety is information removal from a proof
context, not a trusted assertion supplied by their filename.

Retain all existing Assume/Suppress/Assertion_Policy/Check_Policy/Check/Warnings
and SPARK-Off rejection, plus default rejection of all other Annotate forms.
Do not change application admission: Silver authors still cannot write these
pragmas. Existing compiler `Annotate => ...Logical_Equal` aspects are outside
this narrow pragma correction and remain unchanged.

Tests should cover both actual targets and current caller-local statement
placement, case/layout/comments, then wrong unit, target, annotation category,
string, argument count, missing/extra terminator structure and a forbidden
pragma following an allowed one. Preserve existing literal/comment bypass and
suppression tests. A safe occurrence must not exempt the rest of its file.

## R3 (medium): separate compiler reassociation advisory

Use a dedicated category, counter and diagnostic multiset, not
`PROOF_LIMITATION_NOTES`. This note depends on the existing pinned GNAT/SPARK
association agreement; it is not a proof success or a proof-context limitation.

The exact native text is:

`possible reassociation due to missing parentheses [operator-reassociation]`

Candidate recognition must trigger on the exact rule **or** known message, then
validate the entire shape. Do not let a changed severity/rule bypass validation
through the generic informational-record path. Only compiler audits qualify
(`application_kind is None`); the conservative currently reviewed owner/file
pairs are:

| Report unit | Diagnostic file |
| --- | --- |
| silver_function_bindings | silver_function_bindings.ads |
| silver_library_reports | silver_library_reports.adb |
| silver_output_profile | silver_output_profile.adb |
| silver_output_profile | silver_function_bindings.ads |

The last pair is an actual imported-spec diagnostic; do not demand that every
diagnostic filename equal its enclosing report unit. No location-number or
occurrence-count pin is needed. Retain positive integer line/column checks.

Require native key set exactly:
`rule, severity, how_proved, file, line, col, message, unproved_status,
check_tree, suppressed`.
Values are respectively the exact rule, `warning`, `trivial`, approved source
file, positive integer locations, the exact one-field message object,
`{"status":"unknown"}`, `{}`, and empty suppression string. Unknown or extra
fields, including an entity/justification field, are not accepted by this form.

For each matching SARIF diagnostic require the exact existing producer shape:
ruleId `operator-reassociation`, kind `open`, level `warning`, exact message,
one matching physical source location, and
`suppressions: [{"kind":"external"}]`. This is the pinned producer's
disabled-by-default pedantic diagnostic marker, not permission for source
suppression. Reject recognized reassociation rule/message records that do not
match an accepted native diagnostic. Keep the complete native/SARIF diagnostic
multiset equality, including the repeated imported-spec occurrence. A partial
set, mismatched location, changed kind/level/message, omitted/extra field or
other suppression form must fail.

Wire this category through the existing diagnostic acceptance, native empty
suppression-field allowance, SARIF kind/level/suppression checks and separate
statistics. It contributes zero to proved/flow/termination check totals. All
existing proof, dependency, coverage, source and unknown-diagnostic checks stay.

Tests should use the actual retained JSON/SARIF shapes and current duplicate
location. Exercise all four owner/file pairs and reject an application report,
unreviewed source, invalid location types/values, changed producer fields,
missing/extra diagnostic entries, justifications, altered suppression,
and a mismatched or missing SARIF counterpart. Do not weaken existing rejection
tests to make these cases pass.

## Evidence for the interpretation

- Pinned SPARK 16.1 annotation guide, lines 1175–1217, describes the exact
  caller-local Hide_Info placement as omitting expression-function body facts.
  Current reports retain full coverage and successful body/callee postconditions.
- Pinned SPARK portability guide, lines 87–110, states GNATprove uses GNAT's
  implementation choices and both evaluate these arithmetic expressions in the
  same association. SPARK LRM names-and-expressions, lines 431–443, explicitly
  says GNAT does not exercise Ada's permission to reassociate these operators.
- The actual preflight identifies GNAT/GNATprove16.1.0. The compiler project
  retains `-gnat2022`, `-gnata`, `-gnato`; no arbitrary compiler portability or
  changed user-language arithmetic is proposed.
- `diagnosis-evidence.json` retains exact events, selected matching input/tool
  identities, helper report summaries and all twelve native/SARIF advisories.
  Full original reports are in the retained final-036a packet at integration
  evidence commit d39a2b21c8. Failed run094547 stays failed.

## Smallest validation and integration sequence

1. Implement/test in a separate owned worktree; keep live integration inputs
   frozen. Independently review the exact change. This diagnosing reviewer may
   check implementation consistency but must not solely approve their own new
   policy interpretation.
2. Run affected evidence-policy/provenance regressions, retaining all negative
   controls. Before an expensive checkpoint, use the corrected source/report
   checks on all frozen Ada inputs and original094547 reports with their exact
   captured command as cheap diagnostics. This is not complete provenance and
   does not relabel the prior failed run.
3. The existing runner has no audit-only completion path. Its complete_proof
   requires current input_hashes to equal the original snapshot; recursive
   Python scripts are included. Standalone check_evidence requires an existing
   completed manifest, absent here. Do not restamp proof-inputs, manufacture a
   manifest or add a new runner mode merely to bypass this boundary.
4. Freeze the corrected audit inputs in the preserved native checkout and run
   one ordinary managed warm full checkpoint, retaining canonical native
   sessions/cache and unchanged logical proof options. Coordinate current
   resources. Require actual exit/managed success, complete source/report audit,
   current provenance and mandatory final check_evidence. No cold run, cache
   deletion or repeated unchanged native-helper checks is indicated.
5. After the active Lean run actually exits, integrate the auditor/test/docs
   delta and refresh the ordinary cached complete Lean/fresh module+axiom audit.
   Its captured scripts digest changes; expensive proof objects can remain
   cached because Ada/Lean/generator/build inputs are unchanged.
6. Independently update per-ID regression applicability for the auditor/test
   delta, including shared synthetic/provenance/platform fixture dependencies.
   Retain justified successes; refresh every affected/new/failed method. The
   previously accepted621 outcomes cannot simply be assumed unchanged. Complete
   remaining native/Lean/regression/Rosetta/final review work before support or
   ready claims; implementation merge remains held.

No test, auditor, proof, build, generator, tool installation, signal, cache/lease
change or publication was executed by this diagnosis. Original native-tool
success and the managed audit failure remain separate facts.
