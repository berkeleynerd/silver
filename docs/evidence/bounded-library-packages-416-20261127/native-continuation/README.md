# Remaining native package contracts — 2026-11-27

Linux x86-64, issue #416 / draft PR #424. Selected proof setting GPT-6 Astra
Max; actual runtime model/effort is not independently exposed. These are
canonical whole-helper `scripts/dev.py prove --subprogram` checks, retaining
the complete flow/proof contract, unchanged input domain, level 2,
cvc5/z3/altergo and the unchanged 30-second timeout. Each run reserves two
workers within the shared eight-CPU host. The summary and managed ledger retain
actual affinity, source/input hashes, target coverage and precise timings.

The retained Main/Analyze failures on November 27 exposed three composite Main
preconditions and one application body-prefix precondition. The new Signature
and Spec contracts export preservation of `Info.Units` on every return, with
loop invariants retaining the same fact. They accept the same arbitrary metadata
as before, including rejected declarations. The Main diagnostic decomposes the
existing metadata/name/context/flow/catalogue facts into checked Static assertions
and names its existing input expression. All original preconditions and
postconditions remain; no obligation or executable branch is removed.

| Complete helper | Canonical run | Outcome |
| --- | --- | --- |
| `Package_Signature_At`, body declaration 8395 | `20261127T184159-a0acf00fba2f` | 79/79 (14 flow, 65 proof), selected entity `all`; 1,020.794 seconds. |
| `Package_Spec_At`, body declaration 8581 | `20261127T185933-2055189d72e9` | 45/45 (9 flow, 36 proof), selected entity `all`; 362.113 seconds. |
| `Package_Main_At`, body declaration 9492 | `20261127T190610-5f1996739339` | Failed: 5 flow and 45/47 proof rows passed, selected entity `all`; 1,471.699 seconds. |
| Complete Package_Bindings unit, strengthened `Valid_Metadata` | `20261127T193818-29ae74a7539e` | 151/151 (28 flow, 123 proof), all 15 selected entities `all`; 42.949 seconds. |
| `Package_Main_At`, body declaration 9492, verified metadata projections | `20261127T193939-4dba03f7ee42` | 52/52 (5 flow, 47 proof), selected entity `all`; 810.944 seconds. |
| `Analyze_Application`, body declaration 9590, preserved unit spans | `20261127T195352-f016f03f782d` | 30/30 (5 flow, 25 proof), selected entity `all`; 124.790 seconds. |

The source for this checkpoint is Output_Profile SHA-256
`f91894e7a0f7088abd621313e731b71424fd031783faa5d8b9a2f3a180f699da`.
Each run subdirectory retains checked source snapshots, full selected SPARK
and SARIF reports, output summary, raw command log and managed ledger. Source
bytes were compared to each recorded managed input hash before retention.
The separate [namespace packet](../namespace-regressions/README.md) retains the
#426/#427 implementation fixes, actual frontend controls and direct caller checks.

The containing-unit existing-helper gate and four public wrappers remain pending at this
checkpoint. Complete native, Lean, original-source correspondence and final
regression/sample checkpoints remain required; these focused results do not
establish feature completion.

## Main failure and next focused check

The complete Main selection passed its metadata, context, flow, catalogue,
body and `Application_Tail` assertions/preconditions. Two Static assertions
remain unresolved at 9503 and 9505: `Valid_Name` for the package name, and
`Info.Units (Main_Body).First <= Text'Last + 1`. CVC5 returned unknown and
Z3/Alt-Ergo timed out; no counterexample was produced. The preceding
`Valid_Metadata (Text, Info)` assertion passed. The public declaration of
that predicate exports no postcondition, although its body directly implies
both failed facts.

The [failed run](20261127T190610-5f1996739339/summary.json) retains every
selected SPARK row, the failed rows, SARIF, full log, managed ledger, Why3
session/shapes and matching source snapshots, including the Package_Bindings
specification and body. Its [managed diagnostic](20261127T190610-5f1996739339/diagnostic.json)
records the next hypothesis before another attempt.

The lead authorized a minimal `Valid_Metadata` true-result postcondition
exporting the two existing projections, with its full input domain and body
unchanged. `Valid_Name` must precede the Main bound with `and then`: it
establishes a one-based, nonempty, bounded text before the addition
`Text'Last + 1` is evaluated. The next native gate is the complete
Package_Bindings unit after lead integration and source-witness alignment,
then the complete Main helper. No native retry was started at this failure
checkpoint.

The next whole-unit check, `20261127T193818-29ae74a7539e`, passed all 151
checks against Package_Bindings specification SHA-256
`dbcb91fe15d79508705cd56f93917d37ce5c9898a0205cfea5c158d2512e9d26`.
Both the new postcondition at specification line 166 and the guarded
addition's overflow check at line 169 passed. `Valid_Metadata` retains its
full unconstrained `Text`/`Metadata` domain, and all 15 selected unit entities
have independent `all` coverage. The body and Output_Profile hashes remain
unchanged. This verifies the strengthened callee and its package-local callers;
the consuming Main check is a separate required gate.

That complete Main gate passed in `20261127T193939-4dba03f7ee42`: all 52
checks, including both previously unresolved assertions at 9503 and 9505,
are proved. The report independently selects `Package_Main_At` with `all`
coverage, the final-policy solver set and unchanged 30-second timeout.
Output_Profile still has SHA-256 `f91894e7a0f7088abd621313e731b71424fd031783faa5d8b9a2f3a180f699da`;
no Main body, precondition, input domain or obligation was changed for this
successful retry.

The complete Analyze_Application selection also passed all 30 checks in
`20261127T195352-f016f03f782d`, including its previously unresolved
Package_Body_At precondition (now at 9616). The verified Signature/Spec
preservation contracts retain the original unit spans across declaration
reading; Analyze's full declared domain and body are unchanged. Its own
selected report has `all` coverage under the same final-policy settings.

## Existing helper reconciliation

The [separate inventory](../../bounded-library-packages-416-20261122/native-package-contracts/changed-output-profile-helpers.json)
contains 11 changed existing declarations and 30 further changed bodies. Its
own coverage record explicitly leaves their focused contracts/callers pending.
The shared managed history was reconciled through the present Spec success;
no complete Output_Profile or compiler proof after the #416 changes is present.
The latest prior complete compiler success, `20261121T191055-5cced625eb47`, used
Output_Profile SHA `5785341f0fb90656f8db5b34cc23687fa30e3d5863a59761450167868fd56624`,
exactly the `1fac6fa133` baseline. Its readers lack the new qualifier parameters,
expanded parser records and validity predicates. That success therefore does
not establish the expanded current helper domains.

Ten changed declarations still have no current-domain whole-helper success:
`Lookup_Subtype_Model`, `Lookup_Subtype`, `Lookup_Boolean_Model`,
`Lookup_Boolean`, `Indexed_At`, `Value_At`, `Expression_Step`, `Expression_Tail`,
`Expression_At`, and `Read_String_In_Flow`. `Call_After` is the eleventh and now
passes the complete 19-check selection.

The inventory records 34 distinct direct callers of those changed declarations.
`Call_After` is freshly checked. Retained successes for `Static_Boolean_Primary`
(24 checks), `Visible_State` (12) and `Package_Callee` (11) remain applicable as
focused helper evidence: their complete tokenized headers/bodies match, all
inherited declarations and helpers preceding Package_Word match, every external
contract file named in the selected report has the same recorded hash, and none
of the four internally changed helper headers occurs in those reports. Selected
entities have `all` coverage under the canonical focused policy. No rerun is
required merely because their enclosing file has unrelated changes. Fresh
complete final-source assurance/provenance remains mandatory.

After the metadata projection repair, the whole Package_Bindings specification
hash differs from that historical comparison. An additional review in the JSON
confirms every byte outside the `Valid_Metadata` declaration is unchanged.
The retained Visible_State report uses only `Valid_Name`; Package_Callee uses
`Lookup_Routine` and `Same_Name`; Static_Boolean_Primary uses no Package_Bindings
contract. Those declarations and the complete body remain identical, so the
three helper successes still apply. The new whole Package_Bindings unit check
also passes; no duplicate helper run is needed for this unrelated strengthened
predicate.

The remaining 30 caller selections are `Array_Declaration_At`,
`Array_Declaration_Model`, `Array_Type_At`, `Assignment_At`, `Basic_Body`,
`Boolean_Atom_After`, `Boolean_Declaration_At`, `Boolean_Target`, `Callee_At`,
`Character_At`, `Character_Declaration_At`, `Comparison_At`, `Expression_At`,
`Expression_Step`, `Expression_Tail`, `Function_Type_At`, `Lookup_Boolean`,
`Lookup_Subtype`, `New_Name_Allowed`, `Output_At`, `Primary_Model`,
`Procedure_Callee_At`, `Read_Primary_Into`, `Read_Relation_Into`,
`Read_String_In_Flow`, `Relation_Model`, `Scalar_Type_At`,
`String_Declaration_At`, `Subtype_Declaration_At`, and `Value_At`.
After overlap, **33 unique contract/caller selections remain uncovered**.

Another 17 inventory bodies lie outside that union. `Argument_At` now passes
its complete 21-check selection. The remaining 16 are listed individually in
[existing-helper-reconciliation.json](existing-helper-reconciliation.json),
with current locations and applicability status. They remain part of the
required final audit; the four changed validity predicates directly contribute
to the expanded contracts and must be included when selecting their affected
callee checks. This inventory does not prescribe 16 duplicate standalone runs.
The old `Bare_Target` attempt failed during global-contract generation at an
unrelated package expression before its selected obligations, so it supplies
no complete-helper success.

The JSON retains precise locations, source comparisons, selected coverage,
external dependency hashes and run identities. This is an uncovered-work
assessment, not a successful proof or permission to enter the complete native
checkpoint. Coordinate a canonical focused selection that covers the remaining
contracts/callers and applicable changed callees, then perform the mandatory
complete final native audit.
