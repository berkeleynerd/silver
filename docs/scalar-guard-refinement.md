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
10,411 declarations. This closes the source-selection gap; complete body meaning,
native typed-source contracts and the whole-project checkpoint remain pending.

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
| Source-selection and body-flow foundations | Continuing semantic/source authors selected GPT-6 Astra, Extra High; live lead setting not independently exposed | Derived scanner selection and staticness from source readings, proved both refinement outcomes and parser flow counts, and passed the focused fresh audit above. Body meaning and native source contracts remain. Managed timings are retained in the ledger; whole-team time, tokens and cost unavailable. |

No additional owner decision is currently required. Oracle amendments remain
reserved; #119/#201/#202/#212, paused packets/R93 and #88–#94 stay deferred.
