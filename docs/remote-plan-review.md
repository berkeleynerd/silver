# Remote Oracle and roadmap proposal review

Reviewed on 2026-10-12 against main `0abdb55bad65f589af1587de5087ec6172174058`.
The proposal is [codex/oracle-roadmap-audit-plan, commit
4ae1ae798b](https://github.com/berkeleynerd/silver/commit/4ae1ae798b667916bdbe9cdac1b7fa0c7d702c46).
Its one commit is dated 2026-10-12 09:43 UTC and descends from `b3f7e002e7`
(2026-10-10). Main has 22 subsequent commits absent from that branch. A Git
commit date does not establish when the branch was created.

The owner requested comparison and recommendations. These are **proposals**;
neither the Oracle nor the roadmap is amended by this record. The branch's
statement about earlier owner direction is not new authorization in this session.

## Recommendation

Select a few clarifications and keep the current seven-item consolidation
sequence. Do not merge or cherry-pick this two-file replacement. It combines
useful composition goals with a different assurance policy and obsolete support
status. Shared declarations, names and copies remain next proposed work.

## Oracle assessment

The branch replaces the valid-program nonrejection guarantee and universal
language/composition proof requirement with successful per-program GNATprove
checks. It removes all four Lean provisions, including Lean model-to-implementation
and source correspondence, and permits revising language rules after verification
failures. It retains the separate same-source and selected-library identity rules.

The argument for this alternative is less proof maintenance and a simpler
per-build verification policy. The argument against it is decisive under the
current goals: a build that fails on unproved checks does not establish that
every admitted program automatically proves, or establish the compiler's
language-wide composition and semantic correspondence arguments. This is an
assurance change, not removal of bookkeeping. Optional independent replay is
already available; the [completed optimizations](../roadmap.md#lean-critical-path)
reduce iteration cost while preserving those arguments.

Keep the current guarantees. This does not overstate their implementation:
[external obligation generation and solver completion](assurance.md#automatic-completion-and-the-external-boundary)
remain documented premises. Lean does not prove that physical GNATprove finishes
every admitted case within 10,000 solver steps.

Recommend one compact addition, rather than the branch's detailed process rules:

> Language restrictions and implementation resource limits must be explicit,
> with their purpose documented. Temporary scope limits must not be presented
> as requirements inherited from Ada/SPARK or as inherent limits of an admitted
> operation.

This makes restriction transparency durable. Its cost is some duplication with
the existing roadmap and [restriction inventory](restrictions-capacity.md).
Keep the detailed semantic-case checklist there. An explicitly supported narrow
fragment can remain sound while broader compositional closure is unfinished.
Resource bounds can be explicit Silver membership rules; they are not thereby
requirements of SPARK's Silver assurance level.

Also recommend replacing only **“must be checked automatically in CI”** in the
Oracle's final bullet with **“must be checked automatically during project
validation”**. Retain the pinned Lean version, documented assumptions and ban on
unfinished proofs/project-specific axioms. This reconciles the text with the
owner's local-validation instruction without removing automated checks. GitHub
Actions remains disabled.

Do not import “every applicable use” without a specified fragment, or a blanket
ban on report shapes/entity sets. Source-derived coverage and admitted-obligation
policies are legitimate checks. The current checker does not require a historical
numeric obligation total. Broaden policies alongside justified admission changes;
do not accept arbitrary successful reports or infer expected coverage from the
records that happen to be present. Faithful complete production remains an
external-tool premise. Existing Oracle requirements already forbid skipped,
suppressed or unproved required obligations and mismatched source/libraries.

Both proposed Oracle edits require the owner's explicit approval under
[the Oracle](../oracle.md). No amendment has been applied.

## Minimal roadmap additions

Add these requirements within existing items, without another audit queue:

| Placement | Proposed requirement |
| --- | --- |
| Shared foundations, items 2–7 | As admission is generalized, carry source-derived library requirements and verification policies consistently into library snapshots, project construction and expected report coverage. Required coverage must remain independent of whichever records happen to appear in a report. |
| Declarations/names and existing APIs, items 2 and 7 | Resolve context-clause order/grouping, qualification, visibility and name binding for the existing packages. Record supported alternatives or justified exclusions. |
| Output and argument calls, items 6 and 7 | Resolve positional and named parameter associations for admitted calls alongside their existing effect and argument contracts. This does not admit additional operations. |
| Guard predicates, item 5 | Resolve integer-literal spellings, including separators and based notation, representable bounds and overflow-safe parsing. Preserve short-circuit evaluation order and the path facts available to each operand. This does not admit general arithmetic. |
| Existing completion criteria | When a formerly rejected composition becomes supported, replace its rejection expectation with admission, exact behavior and genuine-report checks; retain negative tests for justified exclusions and incomplete verification. |

The first requirement strengthens the existing source-to-driver invariant; it
does not prescribe a new admission-record representation. The next three make
specific cases explicit that the broad closure language could otherwise overlook.
The final sentence clarifies test migration already implicit in the workflow.
They are decisions to settle during the relevant capability, not a promise to
implement every Ada syntax variant or a separate prerequisite to binding work.

## Disposition of the branch's audit queue

| Branch items | Current home and disposition |
| --- | --- |
| A01 admission/catalogue; A03 reports | Shared foundations and current length-check/diagnostic/capacity follow-ups. Add the source-derived coverage requirement above. A general parser rewrite and mandatory driver redesign are not justified as separate upfront work. |
| A02 lexical/resource limits | Inventory complete; dense proof/report capacity remains open. Preserve lexical coverage and explicit capacities. |
| A04 Main; A05 SPARK pragma | Inventoried and deliberately retained. No demonstrated need to broaden entry points or pragma placement now. |
| A06 contexts | Add the explicit syntax/binding disposition above. |
| A07 null | Item 4: statement sequences and branch positions. |
| A08 Strings; A09 constants | Items 2–3: bindings, copies and shared values/expressions. |
| A10 calls; A11 output; A12 Reject | Items 4, 6 and 7 already cover sequencing, continued execution and sticky failure. Add parameter-association disposition. |
| A13 First_Or_Default; A14 Input_Is_Valid | Item 7, with predicate rules in item 5. Preserve the immutable-argv and returned-bound contracts. |
| A15 concatenation | Item 3, including dynamic multiplicity, intermediate bounds and the measured solver-limit finding. |
| A16 conditionals; A17 and then; A18 Length | Items 3 and 5. Make short-circuit fact availability explicit with the predicate work. |
| A19 <= | Tighter capacity guards already supported; broader comparisons belong to item 5. |
| A20 integer literals | Add the explicit spelling/parsing disposition to item 5. |
| A21 combined review | Existing completion criteria and capability checkpoints; no new all-or-nothing gate. |

The branch marks mutable variables and assignment as future work, and retains
old single-use/exact-capacity descriptions. Assignment, branching, composed
expressions, tighter guards and copies have since shipped. Its “all queued”
status would also erase the completed restriction audit and performance work.
Preserve those results and their original scope. The current audit covers all
23 catalogue constructs; its four concrete open findings are already assigned
in [the roadmap](../roadmap.md#audit-follow-ups).

## Review and preservation

This is source/document analysis with three focused independent reviews: Oracle
policy, roadmap coverage, and native routing/report policy. No build, proof or
language experiment was needed. New documentation links and whitespace were checked.
The existing unfinished `ComposeAdmission.lean` edit, scratch, tools and proof
caches remain untouched. No goal was started; Compose String Results remains
complete. CLI recall is unavailable and was not updated. Proposed amendments
await a decision; this record itself authorizes no language implementation.
