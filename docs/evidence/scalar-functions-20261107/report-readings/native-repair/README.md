# Native report proof diagnosis and repair

Original native run `20261107T175157-cb8fa517991c` completed with 3,397 of
3,404 checks proved across all 213 analyzed entities. Seven checks remained
unproved. The retained final report, log, source and session/shape files preserve
that failed outcome. The first three diagnosed checks are addressed below; the
remaining four are the three `Mixed_Object` checks and the
`Audit_Rebased_Report` postcondition.

Two timeout obligations were runtime wrapper postconditions. Generated policy
calls used different backing maps for separate empty String literals. The
runtime policy definition used `temp___String_Literal_4542`; the unbounded
runtime definition used `temp___String_Literal_7532`; the bridge supplied another
literal. Commit `7e71e70fce` replaces the four runtime wrapper arguments with
the existing `Atom_Empty : constant String := ""`. This preserves their Ada
values and provides the same logical source argument to the policy calls.

Managed diagnostic `20261107T202502-62369d4ce9cb` checked the two complete,
regenerated runtime wrapper tasks with the original 30-second CVC5/Z3/Alt-Ergo
settings and two reserved workers. Every root in both final Why3 sessions is
proved; all reported precondition, range and postcondition results are true.
The retained JSON task files are the exact GNAT-generated inputs, with source,
tool and artifact hashes in the run record. The diagnostic output uses entity
ID 0 and is not an application-coverage report. This establishes the selected
task discharge; complete native audit of integrated source remains required.

The first generation attempt stopped before proof because its cache directory
was missing. After setup correction, `--limit-lines` still transformed unrelated
entities, so that attempt was deliberately interrupted once both complete target
tasks existed. Direct-task setup then exposed missing configuration, required
entity-ID and missing session-directory settings; those failures occurred before
proof and are retained. The final direct run includes the generated configuration,
explicit output/cache leases and session directory. No failed run is presented
as successful evidence.

The third saved timeout is `Mixed_Dependencies_From` goal `def'vc.149`. Its
saved shape requires the recursive precondition
`LM.Next = L.First + To_Big_Integer (RM.Next - R.First)`. The final policy
postcondition was already proved. The candidate states this cursor equality
immediately after the item observations, before the reference/list proof calls
expand the context. It is an assertion inside a static ghost procedure and
does not change the precondition, policy or executable behavior. Managed native run `20261107T202804-ccbed4b846a7` passed all 39 checks for
that subprogram with the unchanged 30-second three-prover settings and two
reserved workers. The assertion, recursive-call precondition, final policy
postcondition and subprogram variant are all proved. The retained source,
command/input hashes, final report, session and generated task bind that focused
result. No other subprogram is claimed validated by that run.

The earlier Boolean-object native repair record documents the same String
literal congruence issue and the lower processing cost of subprogram selection.
These observations motivated the narrowly selected checks; no higher timeout,
weakened obligation or unproved assumption was introduced.

The original `Mixed_Object` failures were the flow-field name premise, the
termination-witness loop invariant and the universal witness transfer in the
final object policy. A static ghost `Observe_Flow_List` helper mirrors the
existing proof-list helper and isolates the name premise. Focused run
`20261107T205812-82bfb098077c` proved all six selected checks with the unchanged
30-second three-prover settings and two reserved workers. The source snapshot
contains a separate witness-helper candidate; this run validates only the flow
helper and makes no claim about that candidate or its consumers.

The first extracted `Mixed_Termination_Witnesses` attempt, run
`20261107T204427-8badf3daece8`, proved 17 of 18 selected checks. Its pointwise
loop invariant passed, but transferring that invariant to equality of the two
complete universal predicates timed out at the expanded `Valid (Text, R)`
conjunct of `List_Spec`. Its failed source, final report, log and saved shape are
retained. The diagnostic checkpoint records the next hypothesis. This attempt
is not a successful witness proof.

The remaining original `Audit_Rebased_Report` failure expanded
`Report_Policy (Report)` and `Report_Policy (Text)` through successive one-based
String copies. Commit `cec30d5414` adds a static ghost
`Report_Rebase_Policy` procedure stating exactly that those policy results agree
for the existing one-based copy. Its null body is proved, and the executable
rebasing function invokes it as a ghost call before its unchanged return.
No existing policy definition, contract, input domain or executable behavior
changes. Run `20261107T210421-9f1a5434bd71` proved all three bridge checks; run
`20261107T210727-1f9c39d223a6` proved all seven `Audit_Rebased_Report` checks,
including the originally failing postcondition. Both used two workers and the
unchanged 30-second CVC5/Z3/Alt-Ergo settings. Exact source, generated tasks,
commands/input hashes, reports and sessions are retained for each scope.

These focused results do not replace the complete native audit of the final
integrated source or its required source/provenance checks.

The second witness attempt, `20261107T205807-8d917b05658e`, replaced the
pointwise invariant with equality of complete prefix quantifiers. It proved
16 of 19 total checks, including the flow check, and failed both invariant
checks as well as the postcondition. Saved leaves `def'vc.31.0` and
`def'vc.87.0` again require the bounded validity conjunct; `def'vc.68.0`
requires the bounded list policy. The retained diagnostic restores the
already-proved pointwise invariant and next isolates the existing validity and
array-boundary facts before the loop. The second attempt is retained as a
failure, with its exact source, task, report and session.

The third witness attempt, `20261107T212038-17d88744a05d`, isolated zero
functions, invalid list spans and non-array boundary bytes before restoring
the pointwise loop. It proved 30 of 31 total checks: all explicit validity and
byte assertions, runtime checks, and both loop-invariant checks passed. Only
the universal-equality postcondition remained unproved, reported at an expanded
opening-bracket conjunct. This distinguishes successful boundary and pointwise
reasoning from the failed quantified transfer. Its diagnostic next uses
subprogram-local expression-body hiding for the two list predicates, retaining
the exact proved callee contract and all obligations.

Run `20261107T213534-43867e204187` proved all 19 checks for
`Mixed_Termination_Witnesses`. The final helper retains the original pointwise
loop and the exact universal-equality postcondition. Two subprogram-local
`Hide_Info` annotations keep `Raw_List_Spec` and `List_Spec` abstract while this
helper uses `Mixed_List_Congruence`'s exact equality contract. The exploratory
boundary branches are absent from the final helper. Comparing the generated
tasks confirms that both predicate declarations and postcondition axioms
remain; only their expression-body definition imports are omitted from this
helper's proof context. This is proof abstraction and introduces no assumption,
input restriction, policy change, skipped check or larger prover limit.
The [SPARK annotation guide](https://docs.adacore.com/spark2014-docs/html/ug/en/appendix/additional_annotate_pragmas.html)
documents this caller-local placement. All recorded input hashes were verified
when retaining the exact successful source, task, log, report and session.

Scratch run `20261107T214103-5c62118c81c8` proved 20 checks for
`Mixed_Object_Field`, because the initial selector matched the requested name
as a prefix. Its final inventory exposed the scope error. This run is retained
without claiming validation of `Mixed_Object`. The runner now requires one
exact Ada identifier match and records that selected name as its managed scope.

The corrected run `20261107T214346-a2fc78f63458` selected exactly
`Mixed_Object` at source line 4606 and proved all 51 checks, including its
original `Raw_Object_Policy = Object_Policy` postcondition. The final analyzed
inventory contains that one intended subprogram. Its two local expression-body
hiding annotations use the same abstraction as the successful witness helper;
the flow and universal-witness helpers now supply the needed correspondences.
The exact bounded and raw object-policy source blocks remain unchanged. Every
selected Why3 root is proved, the final report has no unproved check, and all
recorded input hashes matched when the successful source/task/report/session
were retained. The run used the original 30-second three-prover settings and
two reserved native workers on Linux x86_64.

All seven failures from the original complete report attempt now have scoped
repair evidence. That original attempt remains a failure, and these selected
checks do not establish complete assurance for final integrated compiler bytes.
The lead must still run the complete native audit and required source/Lean/
provenance checks on those final bytes, retaining applicable successful caches.
