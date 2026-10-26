# Scalar guard refinement

The owner's [roadmap continuation](session-memory.md#2026-10-25--continue-non-deferred-roadmap-delivery)
authorizes [#234](https://github.com/berkeleynerd/silver/issues/234) after division
#229. This record selects the scope for #237 and records pending #238/#240 delivery
metadata. Native discovery is complete; the selected native implementation is
committed at `171d6b2a62`, independently of these records prepared from
`e7ec53b325`. Universal/source assurance and complete validation/review remain
pending. Delivery remains ordered: division first, then guards. Prepared changes
to the language, catalogue and Rosetta `supported` list describe the selected
increment together; they do not establish completed support or close a package.
The [source assessment and addendum](evidence/scalar-guard-refinement/assessment-20261025.md)
identify the actual interfaces, proof obligations and design traps at division
commit `d85251a4fc`. The selected rules below incorporate the addendum.
The [implementation/proof design](evidence/scalar-guard-refinement/proof-design-20261026.md)
maps the native and semantic flow interfaces. In particular, semantic metadata
must preserve Ada staticness and refinement eligibility independently of current
intervals; a singleton range alone cannot identify a static threshold.
The [native discovery](evidence/scalar-guard-refinement/native-discovery-20261026.md)
retains positive checks, isolated unsafe controls, exact driver execution and
the storage proxy. The [active-flow interface](evidence/scalar-guard-refinement/active-flow-design-20261026.md)
selects caller-owned condition buffers, active-length records, nonrecursive
read overlays and iterative tails. Fixed full-size recursive vectors overflowed
the proxy's unchanged stack; actual parser frame and source-limit validation
remain implementation obligations.

## Selected rules

Keep the existing grammar. Refine a bare, visible mutable Integer object or
loop-index name compared with an Ada-static singleton Integer expression, in
either order, for `=`, `/=`, `<`, `<=`, `>` and `>=`. Both operands must first
pass the incoming expression check. Use resolved binding identities, not the
spelling or equality of inferred intervals. Parenthesized whole conditions keep
their existing behavior; extra parentheses around the scalar name initially
leave the comparison nonrefining. Other admitted comparisons remain checked
without expression inversion or relational facts.

Keep immutable declaration constants' exact values and staticness untouched.
An immutable snapshot copied from a mutable object remains nonstatic and cannot
supply the selected threshold. Separating declarations from appended loop
indexes is essential: both an immutable snapshot and an index may be nonstatic,
but only the latter is a refinement target.

Reuse the existing interval `Refine`, `Complement` and `Swap` semantics. For each
outcome, retain the incoming interval if refinement would be empty; otherwise
use the refinement. This `refineOrKeep` rule is sound because the contradictory
outcome has no execution fitting the incoming range. It avoids direct new
empty-RHS rejections from contradictory guards and preserves existing empty
loop-index intervals. It never changes static evaluation values or waives a
statically illegal subtree.

One interval cannot represent a hole. Thus `X /= 0` narrows `[0,b]` to `[1,b]`
and `[a,0]` to `[a,-1]`, but a range crossing zero retains zero in its hull.
Separate positive and negative arms can justify division for both signs.

## Flow and loops

Separate current scalar read intervals from immutable declared assignment
ranges and from declaration snapshots. Initially, mutable body reads use their
declared ranges. Carry scalar flow alongside existing input/String path facts.

- Infer assignment RHSs in the incoming flow, retain the existing nonempty-RHS
  requirement and require containment in the target's declared range. Replace
  that target's flow interval with the inferred RHS; retain other identities.
- Thread true/false flows through branches, `elsif`, omitted else and `not`.
  Join scalar intervals componentwise. Short-circuit RHSs receive the reached
  flow for every scalar expression and Image, including within String checks.
- Preserve snapshot semantics. String writes leave scalar facts intact. A
  scalar write does not invalidate an established fact about immutable input
  length, but no relationship to a later live Image is retained.
- Infer and capture loop bounds in entry flow, with the index's own name hidden
  as today. Before one body analysis, widen every mutable scalar to its declared
  range; retain outer-index facts and append the new captured index interval.
  Each iteration must satisfy that same body-entry invariant.
- An empty loop restores entry flow. A possibly executing loop widens mutable
  exit ranges, preserves entry immutable/index facts and removes only its new
  index identity. Existing input-path loop transfer remains subject to its
  repeated-iteration proof. No loop-carried scalar invariant or write-set
  analysis is inferred.

Guard facts immediately inside a loop therefore justify a counter update;
mutable facts acquired before or during an earlier iteration cannot justify
later iterations. Changing a bound object does not alter the already captured
index range. Shadowed names remain distinct identities.

There is no blanket admission-monotonicity claim. More precise bound inference
can reveal an empty loop, whose index-dependent assignment RHS is excluded by
the retained rule. Document and test such intentional consequences while
preserving existing supported samples. Scalar impossibility does not prune the
independent input/String context in this increment.

## Driver and assurance

Use the complete finite **100 doors** task. For each door, count its divisibility
visits over passes 1 through 100, guarding the counter increment with
`Visits < 100`, and print whether the count is odd. Loop order may be exchanged
because door toggles are independent; parity equals the final door state. At
most 99 visits precede any increment, so the bound guard suppresses no required
toggle. Derive the exact 100 output lines independently with a pass-major toggle
model. The checked-in [sample](../samples/rosetta_100_doors.adb) preserves the exact
529 source bytes from [native discovery](evidence/scalar-guard-refinement/discovery-20261026/native/doors/src/main.adb).
Its manifest's expected stdout is independently generated by the pass-major toggle
model, with Ada Image's leading space, ` is open` or ` is closed`, and one newline
for each door 1 through 100. The open doors are 1, 4, 9, 16, 25, 36, 49, 64,
81 and 100. Historical native discovery executed those original Ada/SPARK bytes;
these delivery records do not claim a Silver admission, proof, build or execution
run for the prepared sample.

The universal proof must preserve concrete-store containment in current flow
and declared ranges, static values, name identity, assignment replacement,
true/false and short-circuit refinement, branch hulls, captured bounds and the
widened loop-entry invariant. Obligation generation must use exactly the same
intermediate flow as admission at every expression and statement. Extend both
automatic discharge and actual-source correspondence, including typed source
trees, arbitrary-callee equations, concrete witnesses, full source checks and
the current-language endpoints. A source pin or execution safety alone is
insufficient.

No new obligation class, grammar, library, source/operator bound or tool pin is
selected. Native discovery must verify automatic discharge and diagnostics.
Retain a source-derived report-counting argument: new analysis creates no
authored operation sites, but altered static elimination must remain covered by
the existing envelope. Probe recursive frame growth before choosing how scalar
vectors are stored in condition results. This is a feature-local implementation
obligation, not a resumption of #119.

## Prepared delivery records and checks

The specification and catalogue now describe the selected rules without new
grammar: bare-name/static-threshold refinement, immutable declared ranges and
current read ranges, assignment replacement, componentwise branch hulls,
short-circuit scalar/Image reads, bound capture before mutable loop widening,
entry immutable/outer-index restoration, and the intentional empty-loop
assignment exclusion. The README and roadmap link the pending capability.
No general admission-monotonicity claim is made.

Rosetta's existing `scalar-guard-refinement` identifier is narrowed to exactly
this selected flow fragment and prepared in `supported`. The only previous
assessment using it, **Unicode variable names**, increments a bare mutable name
under a static threshold and fits these guard rules; Unicode source itself
remains unsupported. **100 doors** now uses the faithful complete visit-count
approach with only bounded mutables, interval division, finite Integer loops,
Integer Image and this narrow guard identifier. Its old arrays/Boolean-objects/
named-subtypes approach is no longer needed. Broader scalar-expression inversion,
variable relations, holes and loop-carried numeric invariants remain unassessed
and unsupported. Other assessments are not promoted by a broader guard claim.
The generated progression is refreshed for these prepared metadata; no generated
stage position authorizes implementation or establishes validation.

Read-only structural verification passed: exact sample/discovery bytes, all
100 manifest output lines regenerated from pass-major toggles, unique sample and
catalogue identifiers, all manifest capability references, edited JSON parsing,
and a two-task-only assessment delta. Rendering succeeded using only the existing
Rosetta tree with `python3 rosetta/refresh.py --render`; generated task changes
outside the two edited assessments are position/stage changes only. A repeated
render preserved all 80 changed generated outputs byte for byte, and
`git diff --check` passed. Native, Lean,
test, full validation and GitHub updates are deliberately left to the lead's
managed integration checkpoint; these draft checks are not evidence that those
obligations passed. Selected documentation inputs include the capability and
2026-10-26 active-flow/proof designs and native tests at `171d6b2a62`.

## Packages and next check

The native implementation at `171d6b2a62` passed 105 exploratory admission cases
and all twenty prepared 4,096/4,097-byte parser shapes on an 8 MiB stack.
The [retained inputs and results](evidence/scalar-guard-refinement/admission-20261026/validation.json)
match all 129 retained native source files to that commit. These checks exercise
the actual parser; they do not establish application proof or universal resource
sufficiency. The semantic core `fa815fca56` and fixed-cell follow-up `9db41ab578`
passed focused Lean builds and fresh audits, including assignment/loop transfer,
execution, obligation discharge and immutable-cell preservation. Complete native
verification, parser/source correspondence and the final delivery checkpoint
remain pending.

Native verification exposed flow-initialization and discriminant-translation
issues after the executable checks. Explicit initialization and constrained ghost
results cleared those translation failures without changing the toolchain or
removing obligations. The declaration-prefix invariant and source bridge are
being completed against the repaired inputs; earlier successes retain their
exact scope.

The source-reading checkpoint now derives bare-name selection and threshold
staticness from the parsed expressions and proves both scalar-condition outcomes
equal the semantic refinement rule. It also checks active flow counts through
the recursive body parser and retains the body bound proofs. Managed run
`20261026T014427-38afd0166e18` passed those focused targets and a fresh audit of
10,411 declarations. The subsequent combined run
`20261026T015802-cae0e8786438` passed full-flow condition/body source meaning,
parser soundness and uniqueness, native condition sizing and flow-storage
contract projections, with a fresh audit of 16,092 declarations. Complete native
contract/model correspondence, source checks and the whole-project checkpoint
remain pending.

The next focused checkpoint, `20261026T023524-114e39d9c637`, passed the
language-wide semantic endpoint (`Silver.Current`), native condition allocation
extents and full-flow reader contracts, with a fresh audit of 17,798 declarations.
The declaration bridge derives staticness and initial scalar flow from the
actual parsed header, including nonempty declaration intervals; it does not
assume those facts at the language endpoint. Integrated commits `9049fa4766`
and `fd19152ea2` retain these checked inputs. Native scalar helper, body/loop
worker and declaration-adapter correspondence, complete source checks, native
verification and final delivery validation remain outstanding.

The constrained native repair is integrated at `7c403a063e`. Its exploratory
build, 105 admission cases and twenty 4,096/4,097-byte parser shapes passed
again on the repaired source. All 129 compiled repository source files match
that commit. The [retained frame checkpoint](evidence/scalar-guard-refinement/native-frames-20261026/validation.json)
includes managed commands, input comparisons, emitted assembly and stack-usage
records. Predicate forwarding frames contain no full scalar environment;
`Read_Chain_Into` retains both its active scratch result and a runtime
loop-entry snapshot. The loop body still has a larger fixed context frame.
Complete primary/secondary stack accounting remains pending; successful shape
execution is not a universal resource bound. The older exploratory native proof
run retains its captured inputs and is not evidence for this later repair.

The existing package order remains scope/discovery [#237](https://github.com/berkeleynerd/silver/issues/237),
native [#238](https://github.com/berkeleynerd/silver/issues/238), universal/source
assurance [#239](https://github.com/berkeleynerd/silver/issues/239), then complete
validation/review/delivery [#240](https://github.com/berkeleynerd/silver/issues/240).
The assessment maps native and Lean ownership; the lead must settle shared flow
interfaces before delegating edits and remains the sole proof-workspace runner.

The managed discovery batch covered guarded counters, reversed/false/endpoint
guards, short-circuit division, assignment replacement, joins, captured bounds,
shadowing, static illegality and conservative exclusions. Positive Main checks
proved; all six isolated unsafe controls exposed their intended failure; the
100-door driver built and matched the independent output. Retained hashes and
full reports were verified. The remaining checks are focused native/model
validation of the committed interface, actual parser frame measurements and
source/frame accounting, then the complete universal/source and native
validation/review checkpoint. Division's captured validation workspaces remain
unchanged by this separate implementation stream.

| Round | Selected settings | Resolved obligations and remaining evidence |
| --- | --- | --- |
| Read-only scope assessment | GPT-6 Astra, Extra High; runtime setting not independently exposed | Located the flow/metadata boundary, selected bounded refinement and loop rules, preserved static values, and justified the finite driver. Native discovery, frame probe and implementation remain. Elapsed time, tokens and cost unavailable. |
| Implementation/proof design | Selected GPT-6 Astra, Extra High; runtime setting not independently exposed | Mapped immutable metadata, flow overlays, assignment replacement, loop closure and actual-source proof changes. Identified the semantic staticness/refinement-policy metadata requirement. Native discovery and measured storage choice remain; no owner decision is missing. Recorded elapsed 5m 55s; tokens/cost unavailable. |
| Pending documentation/sample records | Selected GPT-6.1 Sol, High; runtime model/effort not independently exposed | Aligned selected semantics with native tests at `171d6b2a62`, preserved discovered sample bytes, independently derived its manifest output, and prepared narrow Rosetta metadata/render. Structural checks only; full support remains pending. Elapsed time and token/cost measurements unavailable. |
| Native discovery and storage selection | Probe preparation selected GPT-6.1 Sol, Extra High; design selected GPT-6 Astra, Extra High; live lead setting not independently exposed | Positive/native-driver checks and isolated unsafe diagnostics resolved the report/site questions. Fixed-vector proxy failures led to active extents and caller-owned condition buffers. Actual parser resource and source-proof closure remain. Managed timings are retained in discovery; active-flow design elapsed 6m 50s; tokens/cost unavailable. |
| Native behavior and semantic integration | Native author selected GPT-6.1 Sol, Extra High; semantic/source authors selected GPT-6 Astra, Extra High; records author selected GPT-6.1 Sol, High; live lead setting not independently exposed | Actual admission and prepared parser boundary cases passed; the core and fixed-cell semantic proofs passed focused fresh audits. Native contract/translation repairs and complete source composition remain. Exact native timings are retained in the linked evidence; whole-team time, tokens and cost unavailable. |
| Source-selection and body-flow foundations | Continuing semantic/source and flow-storage authors selected GPT-6 Astra, Extra High; live lead setting not independently exposed | Derived scanner selection/staticness, full-flow condition/body meaning, parser soundness/uniqueness, native condition sizing and storage projections; the combined focused fresh audit passed. All-input native validity, remaining helper/worker correspondence and complete source checks remain. Combined run elapsed 59.178 seconds; whole-team time, tokens and cost unavailable. |
| Language endpoint and native condition contracts | Continuing semantic/source and scalar-helper authors selected GPT-6 Astra, Extra High; live lead setting not independently exposed | Integrated strict native condition contracts and all-input flow validity, then declaration-derived staticness/initial flow through `Silver.Current`, condition extents and reader contracts. Focused fresh audits passed; helper and body/loop/outer source correspondence remains. | Endpoint checkpoint elapsed 92.819 seconds; whole-team time, tokens and cost unavailable. |

No additional owner decision is currently required. Oracle amendments remain
reserved; #119/#201/#202/#212, paused packets/R93 and #88–#94 stay deferred.

## Shared-reader proof and frame checkpoint

The division delivery merged as `a5305f1b04`; this separate guard branch
incorporates it without changing the guard authorization. Commit `042998ad3a`
(native author `a201d7e6f7`) shares executable `Reading_Names` between the scalar
and String wrappers. Both wrappers now pass that exact returned environment to
the existing readers. This removes duplicated overlay construction while
preserving the Count/all-cell contract and the nonrecursive wrapper placement.
The old separately constructed environments were equal under Ada's bounded
array equality, but that fact alone did not discharge the recursive reader
congruence obligations in the generated proof context.

Focused runs `20261026T032948-7db1c6e04607`,
`20261026T033131-e84a79b990b3` and `20261026T033141-6f0297e34305` proved
all 11 scalar-reader, 12 shared-helper and 10 String-reader checks respectively.
The Body_Tail rank adjustment discharges its prior ghost-call termination checks;
its exact model equality and loop invariant still need repair. These focused
successes do not establish the complete compiler audit.

The [frame account](evidence/scalar-guard-refinement/parser-frame-account-20261026.md)
and [retained native observations](evidence/scalar-guard-refinement/shared-reader-frames-20261026/README.md)
record the corresponding build, 105 admission cases and 20 source-boundary
shapes. All passed; every one of 129 source inputs matches the measured commit.
The recursive frame sums remain unchanged; the shared helper adds transient
nonrecursive frames and no secondary-stack allocation. The account distinguishes
actual frame/lifetime facts, conditional source-budget arithmetic and the
unchanged environmental sufficient-resource premise. It does not claim a
universal fixed-8-MiB certificate or resume deferred capacity work.

Later proof-annotation candidates are still under validation. An attempted
automatic lemma-instantiation annotation was rejected by the pinned frontend;
the replacement keeps the existing join function and strengthens its checked
componentwise postcondition. Complete native discharge, final source correspondence,
full regression/sample validation and independent delivery review remain open.

| Round | Selected settings | Resolved obligations and remaining work |
| --- | --- | --- |
| Shared reader diagnosis and proof repair | GPT-6 Astra, Extra High for bounded diagnosis; live lead setting not independently exposed | Identified the generated array-congruence boundary and proved the shared environment/helper/reader contracts. Body/condition equations remain under validation. |
| Frame retention and scope reconciliation | GPT-6.1 Sol, High for retention/accounting; GPT-6 Astra, Extra High for read-only scope review; runtime settings not independently exposed | Retained exact source/frame/admission/boundary evidence and conditional allocation analysis under the governing sufficient-resource premise. Later source applicability still requires checking. |

Native timings remain in the retained run records. Whole-round token/cost
measurements are unavailable.

## Semantic review and native equation checkpoint — 2026-10-26

The [independent semantic review](reviews/review-scalar-guard-semantics-0655fa76be.md)
at `0655fa76be` found no material gap in guard selection, assignment replacement,
short-circuit flow, joins, captured bounds or repeated-loop closure. Its selected
reviewer was GPT-6 Astra at Extra High; the bounded inspection and report took
3 minutes 3 seconds. It excludes the unfinished native/source integration and
does not establish a new validation result.

The native relation reader's exact model equation passed in managed run
`20261026T041233-b1a6f00330d2`. That run failed its runtime flow-validity
postcondition, which remains a required repair. Joined-flow, refinement-target
and condition-tail helpers have passed focused checks. Body-tail and operator
budget annotations remain under focused development, with unchanged contracts,
runtime behavior and solver settings. Further condition/body checks are active.

The coherent Lean check now builds loop execution equations, body expressions,
body equations/correspondence and inherited declaration readiness. Remaining
adapter/sizing proof diagnostics are being repaired before a fresh combined
audit. The source runner still carries the preceding division parser input;
these focused results do not establish final guard actual-source correspondence.
The resumed proof subthreads use selected GPT-6 Astra at Extra High. Runtime
settings and whole-round token/cost measurements are unavailable. Complete native,
source, regression and independent delivery validation remain outstanding.

Managed run `20261026T042806-91a48244f160` then completed a fresh focused audit
of 61,948 declarations covering the repaired loop equations/sizing, scalar-body
helpers, body equations/correspondence, reader libraries and inherited declaration
readiness. The [result and integrated input hashes](evidence/scalar-guard-refinement/lean-cohort-20261026/integration.json)
retain its exact scope. The build and audit took 11.687 and 12.442 seconds,
reusing successful objects. Adapter and remaining body/helper integration are
still pending; the parser/source qualification above remains unchanged.

The operator-budget and body-tail annotation repairs subsequently passed all
80 and 57 focused native checks in runs `20261026T042717-e1a3158cf544` and
`20261026T042859-6bcf808e8681`. The repairs expose recursive model equations
through ordinary Static ghost calls and explicit transition equalities. They
preserve runtime statements, contracts and solver settings. Only those two
proved bodies are integrated; their [exact identities](evidence/scalar-guard-refinement/native-loop-annotations-20261026.json)
distinguish the checked scratch source from the integrated subset. Condition
validity and the complete native audit remain pending.

The top-level parser equations and all selected helper integrations then passed
in managed run `20261026T044700-92f77d7e4b48`, with a fresh audit of 63,340
declarations. This closes the outstanding adapter, body-count, basic-statement
and loop-helper model proofs. The [integrated hashes](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-equations.json)
and [focused result](evidence/scalar-guard-refinement/lean-cohort-20261026/lean-equations-evidence.json)
retain the scope and 22.432-second build/15.207-second audit. Complete guard
actual-source checks still wait for the stable native annotation snapshot.

This round used selected GPT-6 Astra at Extra High for the proof subthreads and
semantic review, and the previously prepared GPT-6.1 Sol Extra High operator-budget
repair. Explicit frame-count preservation and reuse of the checked target reader
resolved the repeated model-normalization failures. Native condition transport
and final delivery validation remain; whole-round token/cost data are unavailable.

The [independent source-contract review](reviews/review-scalar-guard-source-contracts-4a4435a5ba.md)
at `4a4435a5ba` found one material gap: the token wrapper assumes normalized
`Take_Token` behavior without deriving it from the inherited lexical callee,
and its broad token domain includes a concrete counterexample (`Capacity_Literal`
on `"0"`). The conditional model theorems remain valid; the actual native function
cannot satisfy that interface over its stated domain. The finding is confirmed
and under repair before final source validation. The repair must retain raw
callee semantics and prove every actual caller lies in any narrower normalized
projection domain; native contracts and application membership remain unchanged.


The token-wrapper finding [#243](https://github.com/berkeleynerd/silver/issues/243)
is repaired in the five files identified by the
[checked integration manifest](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-token-wrapper.json).
The raw model retains the lexical callee over its existing full formal domain;
normalization now derives that callee's meaning before projecting fixed-token
calls used by the body, basic and loop parsers. The native contract and language
membership are unchanged. The [independent recheck](reviews/review-scalar-guard-token-wrapper-repair.md)
found no residual issue in that bounded repair.

Managed run `20261026T050814-e5e727ef4f27` passed the focused parser equations
and scalar-body source target with a fresh audit of 63,378 declarations. Its
build took 20.020 seconds and audit 11.573 seconds; all five integrated files
match the captured inputs. The first attempt exposed a record-field layout
syntax error, repaired before this run. Final native-source correspondence
still waits for the stable compiler snapshot and complete audit.

This repair used selected GPT-6 Astra at Extra High for the author and
independent reviewer. Runtime settings are not independently exposed; token
and cost measurements are unavailable. The reviewer reports 3 minutes 7 seconds
including report writing and final hash checks. Native parser proof obligations
remain under development and no capability package is complete.


The final interface assessment also confirmed [#244](https://github.com/berkeleynerd/silver/issues/244):
`Native.ValidContext` omitted nonempty bounds for hypothetical mutable bindings
beyond the declaration prefix, although native `Valid_Context` requires them.
The [assessment](reviews/review-scalar-guard-context-domain-e2b96b884c.md)
retains the precise witness and distinguishes this contract-domain gap from
reachable application behavior. Repair adds the missing property to the formal
context invariant and preserves declaration and immutable loop-index construction.
Native contracts and application membership remain unchanged. Its proof and
final source integration are pending.


The #244 domain repair is now integrated with its
[exact input manifest](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-context-domain.json).
`BaseReady` includes nonempty mutable bounds, and `baseReady_iff_native`
connects it to all native context clauses. Declaration and header constructors
preserve the added property; immutable loop indexes may still have empty ranges.
The [independent domain review](reviews/review-scalar-guard-context-domain-repair.md)
found no material issue. A later helper-name collision was repaired by a rename
and its consumer update, with statements unchanged.

Managed run `20261026T054741-00f8b4d72975` passed the combined focused check
and fresh audit of 21,357 declarations (84.370 seconds build, 16.423 seconds
audit). All six integrated files match its captured inputs. This resolves the
context-only contract-domain obligation; final actual-source integration remains
pending, so #244 stays open through that checkpoint.

The same run checked literal-token candidates after direct inline lexer reduction
proved costly: the preceding worker reached 14,690,800 KiB resident memory and
was interrupted for diagnosis. Explicit candidate token lists preserve the exact
kernel-checked renderer equality and later authoritative-source comparison; the
Body candidate then built in 11 seconds. Existing successful objects were retained.
No application rule, lexer or trusted boundary changed.

This round used selected GPT-6 Astra at Extra High for the proof authors and
independent reviewer; runtime settings and token/cost measurements are unavailable.
The bounded domain review reports 154 seconds of inspection. Native loop-body
and equality-transport helpers have passed focused checks; condition, relation
and branch return proofs still precede the complete native/source checkpoint.

The checked source renderers, literal-token candidates and scalar helper headers
are now integrated with their [input manifest](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-source-renderers.json).
The manifest checks each file against its successful run's captured input and
audited module list. Run `20261026T055212-fb21807077d8` also checked the exact
loop annotation rendering, parser equations and current-language model endpoint,
with a fresh audit of 64,624 declarations. Its [focused result](evidence/scalar-guard-refinement/lean-cohort-20261026/lean-loop-current-evidence.json)
records 295.195 seconds building and 14.624 seconds auditing. These results still
use the preceding division source binding; final guard source correspondence
and the complete native checkpoint remain outstanding.

This integration reused completed proof work. Recovery and source/input inventory
used selected GPT-6.1 Sol at Extra High; source and native equality repairs use
selected GPT-6 Astra at Extra High. The live lead setting is not independently
exposed, and whole-round token/cost measurements are unavailable.

The native loop, primary reader, invalid-body helper and both branch-body
checks have passed. Their [focused evidence](evidence/scalar-guard-refinement/native-transport-20261026/index.json)
records the exact commands, logs and frozen source hashes compared with the
managed inputs. The stronger invalid-body post exposes the preserved count and
interval endpoints without changing executable behavior. Its [exact Lean
contract rendering](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-invalid-body-header.json)
passed run `20261026T061202-8932bfd8f50a`, with a fresh audit of 10,480
declarations. Relation/chain equality and one condition-join equality remain
under focused repair before final native-source integration. These are partial
checks, not the complete compiler or source checkpoint.

The [final source-interface review](reviews/review-scalar-guard-final-source-20261026.md)
found no new semantic/domain gap. It identified a stale public facade still
using the old path-only signatures; the three-line repair uses the checked
active-flow domain. Focused validation also exposed a missing explicit wrapper
import, which was added. The [integrated interfaces](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-final-interface.json)
then passed their fresh audit of 24,877 declarations; the [result](evidence/scalar-guard-refinement/lean-cohort-20261026/lean-final-interface-evidence.json)
retains the exact inputs and timings. This checks the source-requirement
definitions and facade, not their instantiation against final guard source.
The independent review used selected GPT-6 Astra at Extra High and reports
455 seconds including writing; runtime settings and token/cost are unavailable.

The condition reader and flow-equality helper subsequently passed their focused
native checks. The remaining relation diagnostics exposed a model mismatch:
comparison orientation was inferred from target-index equality instead of the
executable reader's first-candidate predicate. The corrected ghost/formal helper
uses that predicate directly, preserving executable behavior and the full helper
domain. The [independent review](reviews/review-scalar-guard-orientation-20261026.md)
found no scoped blocker. Its native helper passed 13 checks; the native evidence
index above retains the exact inputs and log.

The [integrated model repair](evidence/scalar-guard-refinement/lean-cohort-20261026/integration-orientation.json)
passed focused validation through `Silver.Current` in run
`20261026T072713-47e20847e594`, including a fresh audit of 64,530 declarations.
Two unused simplification hints from the first attempt were removed without
changing theorem statements. This remains model/endpoint evidence using the
preceding native source binding; final guard source correspondence, the active
chain/relation native checks and complete delivery validation remain required.
The final parser also requires fresh frame and boundary observations because its
ordinary postcondition and control-flow rewrites differ from the retained frame
snapshot. This round uses selected GPT-6 Astra at Extra High for the model/native
repair and independent review, and GPT-6.1 Sol at Extra High for input inventory.
The passing Lean build/audit took 514.269/9.942 seconds; independent review took
356 seconds. Live lead settings and whole-round token/cost data are unavailable.


The remaining relation join is resolved at `bc9b0815eb`: both target branches
supply checked Static equality bridges, preserving the original joined assertion,
all native contracts and executable behavior. [Retained focused run](evidence/scalar-guard-refinement/native-join-final-20261026/README.md)
`20261026T083814-1b657c3ee2da` passed all 22 selected checks at the unchanged
level-2/30-second settings. The final source pin and certificate were regenerated;
run `20261026T084854-8fd2b4b2d2e8` passed the regeneration-parity method for all
26 certificates (8.424 seconds of tests). This is not a complete source audit.

The [final integration review](reviews/review-scalar-guard-final-integration-20261026.md)
found no scoped blocker, checked the earlier semantic/domain/callee repairs
against final bytes, and identified no additional independent review gap. It
also establishes qualified applicability of the retained `956eff...` frame
observations to the final Static-only delta, under the existing ghost-erasure
premise. Those observations are not relabeled as a fresh final-source build or
a universal stack bound. Complete native proof, final-source Lean, build and
full-suite checks remain required before delivery.

This integration round selected GPT-6 Astra at Extra High for the independent
review (390 seconds including writing) and GPT-6.1 Sol at Extra High for
evidence preparation. Runtime settings and whole-round token/cost measurements
are unavailable. It closed the native join and final semantic-review obligations;
the complete native and preserved preceding-source Lean runs remain active.


Complete source checking exposed three candidate integration errors: two private
header lemmas used the complete-source lexer instead of the required line lexer,
and direct reduction did not unfold the well-founded grouped-contract renderer.
The [bounded repair review](reviews/review-scalar-guard-candidate-integration-repair-20261026.md)
records the rejected shorthand/import hypotheses and the final existing
`render.eq_def`/`renderElse.eq_def` proof. The native source, models, contracts,
source requirements and public endpoint types are unchanged.

At `d039e68dba`, the renderer-only proof and all three affected source-header
goals passed their focused builds and fresh audits. The [retained evidence](evidence/scalar-guard-refinement/candidate-repair-20261026/index.json)
identifies their exact scopes and inputs. The failed complete run's obsolete
certificate worker was interrupted deliberately, preserving completed objects;
final complete source run `20261026T094105-ac4e120bd9f9` now checks the repaired
proof and final parser/catalogue inputs. The native full proof remains active.
This closes the specific reduction/interface errors, not the final delivery gate.
