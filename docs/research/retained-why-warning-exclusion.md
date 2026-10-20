# Warning-attempt exclusion for the five retained library domains

2026-10-20 UTC, Linux x86_64; owner-resumed #119 / #153 research, base
`59bf44c59c9bda53b8c4ea5be52c10266f2b93e9`.

**Every scheduled automatic attempt in the five named fixed-library domains
has `warning=false`, under the accepted source/configuration and registered
metadata relation.** Consequently the independent one-second warning timeout
cannot be selected there. Setting `--warn-timeout=0` is unnecessary for this
specific exclusion. This result does not establish the other configuration,
timing, source/prefix, grammar or full-output q obligations of the prospective
solver-response adapter, or adopt that design.

The [certificate and focused checker](../evidence/retained-why-warning-exclusion-20261020/README.md)
join accepted typed attribute coverage, direct raw membership/byte checks,
source classification and the accepted fresh logical-graph correspondence.
They do not rerun a predecessor checker, logical opening, binder/alpha analysis,
graph comparison, native process, solver or proof.

| Domain | Attribute-capture PID | Accepted fresh PID | Forest APn visits | Registered-goal upper bound | Distinct `GP_Check` attributes | Warning-attempt upper bound |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 3085 | 17310 | 65 | 64 | 18 | 0 |
| Put | 3323 | 17514 | 54 | 53 | 14 | 0 |
| First_Or_Default | 3470 | 17631 | 33 | 32 | 9 | 0 |
| Is_Message | 3568 | 17704 | 4 | 3 | 1 | 0 |
| Input_Is_Valid | 97103 | 17869 | 5 | 1 | 1 | 0 |

Attribute counts are distinct label objects in each whole covered forest;
they are neither registered-check counts nor goal counts. The 161 forest
visits and the 153 registered-goal envelope remain different domains. The
whole forest is a sufficient overapproximation: registration may discard
raw tasks without weakening the exclusion.

## Attribute origin and registration

All source references below identify members of the unchanged retained Why3
archive, revision `9390baf120ef260547dfa14f08e11c890b203d9c`.
[Source witnesses](../evidence/retained-why-warning-exclusion-20261020/source-witnesses.json)
retain complete-member identities and 22 exact slices. Native application uses
the existing [relevant-behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
to Linux `gnatwhy3`, SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
this packet adds no historical build-identity or full binary-refinement claim.

1. `gnat_main.ml:48–73` obtains the raw session task for a leaf goal, obtains
   `Task.task_goal_fmla`, and passes that formula to `Gnat_expl.search_labels`.
   It either drops the goal, aborts for missing traceability, or stores the
   resulting `vc_info` through `Gnat_checks.add_to_check`. No alternative check
   kind is manufactured on the missing-label path.
2. `gnat_expl.ml:485–573` starts label search with a fresh copy whose check kind
   is `None`. `search_attrs` reads only term attribute sets on its selected
   formula traversal. Its `Term.t_fold` can safely open binders. The accepted
   [atom-coverage contract](../evidence/retained-why-fixed-session-atoms-20261020/README.md)
   covers every stored term and deferred-substitution term in every imported
   formula, including all raw goal formulas. Opening adds fresh variables with
   empty term attributes; substitution and reconstruction retain or union
   existing term attributes (`term.ml:626–659,663–675,739–781,799–831,1282–1294`).
   Induction on that accepted opening/substitution relation therefore places
   every visited attribute in the captured union. Stopping at a typed term or
   `stop_split` can only reduce the read domain. This is why a census of the
   captured union suffices here; a string search without this coverage/origin
   argument would not suffice.
3. `read_label` recognizes `GP_Check`, and `parse_check_string` obtains the
   kind only through `check_kind_from_string` (`gnat_expl.ml:194–269,424–471`).
   The checker derives the parser mapping and true/false kind partition from
   that source, checks every captured label token, and checks its raw attribute
   record, string bytes and stored term-set memberships. The only observed
   tokens are `VC_RANGE_CHECK`, `VC_INDEX_CHECK`, `VC_OVERFLOW_CHECK`,
   `VC_LOOP_INVARIANT`, `VC_POSTCONDITION`, `VC_PRECONDITION` and
   `VC_LENGTH_CHECK`. Each maps to the false arm of `is_warning_kind`.
4. The mutable extraction accumulator may overwrite an earlier parsed kind
   with another parsed kind, or refine `VC_Loop_Invariant` to
   `VC_Loop_Invariant_Init`/`VC_Loop_Invariant_Preserv` when reading `expl:`
   attributes (`gnat_expl.ml:495–531`). Both refinements also classify false.
   Thus traversal order, multiple labels and loop refinement cannot introduce
   a warning kind. `extract_check` and `mk_check` merely store the resulting
   kind. The registered `check` and `vc_info.check` fields are immutable
   (`:152–168,188–193,534–573`). The transient mutable accumulator is not the
   stored check.

The five true cases at `gnat_expl.ml:75–147` are exactly
`VC_Inconsistent_Pre`, `VC_Inconsistent_Post`, `VC_Inconsistent_Assume`,
`VC_Unreachable_Branch` and `VC_Dead_Code`. None is a parser result for a
captured `GP_Check` attribute or a loop refinement.

## Continuation closure and fresh-process attachment

`add_to_check` binds each goal to that immutable `vc_info`; `get_check_of_goal`
retrieves its check (`gnat_checks.ml:201–235`). The accepted
[dispatch envelope](retained-producer-driver-envelope.md) and
[interrupted preparation argument](retained-why-path-writer-capacity.md)
fix the selected fresh, automatic, serial Per_Check, CE-off, non-replay route.
Registered goals remain initial split children. No successor split, clone, CE,
editor, reload or merge route adds a new registered goal. Driver preparation
may rebuild its own task but does not register a new GNAT check or replace
this raw task/check relation. The source's Per_Check last-split decision has
no catch that turns an exception into a false result and a new split.

Consequently every later successful `get_check_of_goal` returns one of the
nonwarning checks established at registration. A failure can abort a query or
attempt under the existing exception contract; it does not create a warning
constructor. `has_been_tried_by`, `register_result`, `schedule_goal` and the
automatic `run_goal` all classify that same check
(`gnat_checks.ml:469–482,598–661,1022–1084`). `run_goal` passes
`warning=false` to `Gnat_config.limit`. The registered metadata maps themselves
were not newly observed: their source ownership and correct lookup/payload
relation are imported premises of the accepted envelope and
[continued table/native contract](retained-why-save-table-contract-join.md).
This exclusion adds no assumption that allocation or I/O succeeds.

The old attribute-capture PIDs above are not identified with the fresh PIDs.
The accepted [Round 28 repaired join](retained-why-save-state-join.md), its
[independent review](../reviews/review-save-state-continuation-20261020.md),
and [Round 29 review](../reviews/review-save-capacity-round29-20261020.md)
supply a pointer-bijection correspondence for the immutable logical declaration
graphs. Ordinary block fields, term attribute sets and string bytes are
preserved; the narrowly recognized Zarith operations-pointer relocation changes
no attribute bytes. The new checker binds each old raw member and occurrence
certificate to that saved comparison, checks that all imported formula roots
and task pointers are covered, and joins its fresh raw identity/PID to the
accepted status projection. A read-only attribute predicate therefore transfers
within those matched logical graphs. Mutable backing, process identity and
unrelated domains are not transferred. The four registration cuts and the
Input_Is_Valid first-inline cut retain their different phases.

The logical-preservation and metadata premises apply throughout the selected
post-cut continuation. Keep **one global `e<=2` escaping signal-save budget per
process**, at most two save-entering callbacks and at most three reached saves.
This packet neither renews those allowances at an attempt nor uses the normal
459-call envelope as the interrupted call count. Warning exclusion holds even
when a permitted interrupted query causes a repeated attempt on the same
nonwarning check.

## Consequence and limits

`gnat_config.ml:24–27,567–575` retains the warning timeout default of one second,
independent of ordinary timeout selection. The selected fixed domains cannot
reach that warning arm. This removes only that caveat when a separately
justified configuration/timing argument needs to exclude warning-derived
positive limits. Actual queued limits, adaptation, server CPU fallback,
solver-emitted timeout answers and result/report interpretation retain their
own obligations. Warning-kind attempts are also distinct from diagnostic
warnings emitted by the solver answer analyser; those diagnostics are not
excluded here.

The result concerns continuations of the five named retained logical domains
under the stated source/configuration/metadata relation. It is not a proof that
every future execution of those inputs has the same graph, or that arbitrary
current/future grammar admits no warning kinds. Full #119/#153 capacity remains
open. Production #88–#94 stays unstarted; PR #121 stays draft/unmerged. No
Oracle, tool/pin, admission, production implementation or prospective adapter
packet changes.

The task selected GPT-6.1 Sol / Extra High; live runtime model/effort confirmation
and token/cost measurements are unavailable. The packet records the actual
Linux host and focused offline verification time. Independent acceptance and
integration are lead-owned.
