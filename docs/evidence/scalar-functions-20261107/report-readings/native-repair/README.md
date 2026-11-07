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
