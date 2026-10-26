# Scalar guard flow: implementation and proof design

2026-10-26. Read-only design for authorized #237 following #229. Planning input:
`tmp/scalar-guard-refinement` at `92fec8a3c4db`; implementation/proof input:
`tmp/interval-integer-division` at `8c5db15a2755`. The owner continuation on main
at `3217d34d1d` authorizes successive non-deferred increments, with guards next.
The selected scope is `docs/scalar-guard-refinement.md` and its 2026-10-25
assessment, **including the refineOrKeep addendum**. No owner decision is missing.
No implementation, tool/proof runner, Git/GitHub mutation, or artifact-directory
access was performed. This scratch file is the only written file.

Selected model: GPT-6 Astra, Extra High, as assigned; runtime model/effort are
not independently exposed. Inspection started at 00:09:16 UTC; design was ready
for recording at 00:12:21 UTC (3m 05s inspection), and the written handoff was
checked at 00:15:11 UTC (5m 55s total). Token/cost measurements are
unavailable. Inputs read: AGENTS, Oracle, relevant development/language rules,
selected capability/assessment, and the native/Lean files identified below.

## Established approach

Use one immutable scalar analysis context and one changing flow value. Do not
make the declaration environment itself the result of statement analysis.

The current native `Body_Context` owns `Scalar_Names`; `Context_Of` widens mutable
declarations using `Body_Environment`. `Body_Scan.Facts` and both
`Condition_Result` outcomes contain only `Silver_Path_Facts.Context`.
`Read_Relation` returns unchanged facts for scalar comparisons. Its arithmetic
reader and every Image-containing String reader receive the same fixed names.
`Scalar_Assignment_Body` already checks `Declared_Bounds` but drops the RHS range.
These are the necessary change points in `src/silver_output_profile.adb`.

The smallest coherent native interface is:

* Keep `Body_Context.Scalar_Names` as the immutable body metadata/base ranges.
  Add `Declaration_Count`, initialized to the scalar count by `Context_Of` and
  unchanged when loops append indexes. A live identity is refinable exactly when
  it is mutable or lies after that declaration prefix. Immutable nonstatic
  snapshots therefore cannot be mistaken for indexes.
* Add an interval-only vector and a flow record containing that vector plus the
  existing path facts. Change `Body_Scan.Facts` and condition outcomes to this
  combined flow, or add scalar fields with precisely the same semantics. Do not
  put complete name environments in condition results.
* Add local helpers for initial flow, read-environment overlay, componentwise
  join, mutable widening, exact-target replacement, and guard refinement.
  `Reading_Names(Context, Flow)` preserves Count, source spans, Static,
  Declared_Bounds and Mutable, replacing only Bounds for mutable/index identities.
  Immutable declaration bindings remain literally unchanged. This lets the
  existing scalar and String readers keep their signatures and arithmetic proofs.
  Helpers can remain private to `silver_output_profile.adb`; expanding
  `silver_scalar_expressions.ads/.adb` is unnecessary unless sharing the projection
  materially simplifies implementation/correspondence.
* Keep `Expand_Body`'s visibility metadata separate from the read overlay.
  `Target_At`, `Call_After` and `Length_At` need binding identity/visibility, not
  scalar value changes. Every `Read_Expression` or `Expression_At` in executable
  body/condition checks must use the overlay, including loop bounds and String
  assignments, comparisons, Put and Put_Line. Declarations continue using their
  existing exact initialization environment.

Validity contracts must connect the flow's active length to `Scalar_Names.Count`,
bound every interval endpoint, keep mutable intervals nonempty and within their
declared subtype, and preserve immutable declaration values. An invalid result
must either retain the caller's active extent or be explicitly excluded from
these stronger postconditions; a universal zero-length invalid constant cannot
silently satisfy a dependent active-length contract.

**Representation checkpoint:** a fixed 341-cell interval vector is the lowest
code-change baseline, but it adds roughly 2,728 endpoint bytes per vector before
record/layout overhead, with two vectors per condition result. This is a sizing
calculation, not measured layout. The existing comment that recursive frames
contain only cursors/flags becomes false. The native discovery/implementation
owner must measure maximum-source nested parentheses/chains/loops before choosing
the final representation. An active-length unconstrained vector/discriminated
flow is the bounded alternative if fixed vectors exceed native stack headroom;
it changes storage and invalid-result plumbing, not the flow proof. Do not change
the 4,096-byte bound or reopen deferred capacity work to avoid this check.

## Guard and transfer details

After both operands succeed under the incoming flow, identify a bare name by
`Skip_At`, `Name_After`, exact equality with the successful operand's `After`,
and `Scalar_Expressions.Lookup`. The current name reader's successful `After`
is exactly its identifier end, before following trivia. Resolve the identity
against metadata, never by comparing numeric ranges. Prove this helper equivalent
to the independently parsed `Integer.Expr.name index`; `.parenthesized (.name _)`
must remain nonrefining. Whole-condition parentheses preserve normal refinement.

For a refinable left name and static nonempty singleton right result, apply the
existing Scalars.Refine. For a right name and left threshold, use Scalars.Swap
first. Both false outcomes use the existing complement through Refine. A direct
left/right candidate is selected only after both ordinary expression checks;
neither threshold inference nor contradiction may skip an illegal static subtree.

`refineOrKeep i op k truth` returns `i` when `Refine i op k truth` is empty and
the refined interval otherwise. Prove outcome containment, boundedness, inclusion
in the incoming interval, preservation of nonemptiness, and preservation of an
initially empty interval (the canonical empty index remains canonical Empty).
The last four properties are needed for representation and transfer invariants,
not only the guard's local safety proof. Use existing endpoint-safe Below/Above;
no new unchecked `threshold +/- 1` arithmetic.

`Scalar_Assignment_Body` checks RHS under the old flow, requires nonempty RHS
and containment in the metadata's declared range, then **replaces** only that
identity's current interval. `Basic_Body` String writes and Reject leave scalar
intervals unchanged. A scalar write leaves existing immutable-input-length facts
unchanged; every later Image is inferred afresh from the new scalar flow.

`Condition_Tail`, `Conditional_Body`, and `Alternative_Body` thread and join the
whole flow. `and then` RHS gets left-true, `or else` RHS gets left-false, `not`
swaps outcomes; alternative outcomes and branch exits use componentwise hulls
plus the existing path join. An omitted else contributes the false incoming flow.
The `Read_Body`/`Body_Tail` recursive equation and executable/ghost equality must
carry that same result into the next statement.

`Loop_Body` must preserve this ordering:

1. Read/capture lower and upper bounds using entry flow and today's own-name mask.
2. Compute captured index bounds and empty/definite classification.
3. Widen every mutable scalar to its declared range; retain all entry immutable
   and outer-index intervals. Append the fresh index metadata **and flow cell**.
4. Analyze the body once. Keep the existing empty-loop path-context treatment.
5. If abstractly empty, restore the whole entry scalar flow. Otherwise discard
   body scalar precision and return the widened entry scalar flow. In either
   case remove the new index; do not export body-derived outer-index refinements.
   Continue using the existing empty/definite/uncertain path exit rule.

Index shadowing uses the fresh append identity. No loop-body write changes a
captured bound, and no first-iteration mutable fact is reused in later iterations.
An unknown loop that happens to execute zero times still returns widened mutable
flow: that deliberate precision loss is sound.

## Semantic model and proof work

There is one additional interface requirement beyond the assessment's flow pair:
`Predicate.Condition.scalarCompare` currently stores only two `Integer.Expr`s,
and `Predicate.Program` has ranges/mutability but no threshold staticness or
refinement-target policy. Exact source correspondence cannot infer the selected
policy from singleton ranges alone.

Introduce a small immutable scalar analysis metadata record alongside the flow:
declared ranges, mutability, refinable identities, and per-name Ada staticness.
Use `Expr.name` to decide the bare-target shape. Derive initial static flags in
declaration order from each `Integer.Declaration.value` and `!mutable`; immutable
snapshots of mutable objects remain false. Derive refinability from mutability
initially, and set it true only for the appended loop index while setting its
staticness/mutability false. This avoids adding trusted annotations to Condition
or changing the source AST. Native metadata projection uses `Declaration_Count`
and existing Binding flags. Prove the projection agrees with declaration
elaboration in the outer-program bridge. The old `BodyReady` equality
(`mutable bounds = declaredBounds`) remains valid for base metadata only; replace
its use as a property of every read environment with flow inclusion/metadata
preservation.

The semantic flow carries `PathFacts.Context` and `Integer.Ranges`. Recommended
theorem invariant: concrete scalar store fits the current ranges; current mutable
ranges lie within immutable declared ranges; immutable declarations retain exact
snapshot intervals; current indexes lie within their captured base ranges. Keep
the input/String state and effect invariants already present.

| Files/functions | Required change and closure |
| --- | --- |
| `IntegerComparisons.lean`, small new scalar-flow model module | Prove refineOrKeep lemmas over existing `Interval.refine_sound/refine_bounded`; define flow update/join/widen and active-domain/containment lemmas. |
| `IntegerMutable.lean`: `Assignment.check`, `check_sound`, `unchanged` | Split declared target lookup from current RHS read ranges; retain equality of `assignment.bounds` to metadata's declared target, not the narrowed read interval. Return or expose RHS interval for exact-target flow replacement. Prove checked execution, declared containment, new-flow containment and other-cell preservation. |
| `PredicateChecking.lean`: `Condition.refine`, `checkBounds`, `refine_sound`, `checkBounds_sound` | Carry complete flow and immutable analysis metadata. Prove true/false flow containment together. Generalize induction over changing ranges as well as path facts. Infer String/Image summaries using the reached scalar component, including inside predicates. |
| `PredicateStatements.lean`: `Statement.check`, `checkStatements`, loop helpers | Return `Option Flow`; sequence consumes the returned flow; assignments replace; choice joins; loop captures before widening. Simple/String checker helpers can continue accepting the two projections. |
| `PredicateExecution.lean`: `ExecutionSound`, statement/sequence/iteration theorems | Output scalar fit must reference the returned flow, and retain declared-range fit. Generalize `iterations_execution_sound` to a fixed widened scalar invariant, not the precise preloop range. |
| `IntegerChecks.lean`, `PredicateObligations.lean`, `PredicateChecks.lean` | Update `Assignment.obligations_discharge`, `Condition.obligations_exact`, statement/sequence obligations and check-fragment theorems to consume exactly the same intermediate flow as admission. No new obligation class is expected. |
| `PredicateComposition.lean` and current-language endpoints | Derive metadata/initial flow from declarations; update `Program.checkBody`, `Valid`, `scalar_execution_invariant`, all-obligation discharge and execution endpoints. Preserve invalid-input rejection, initialized Strings and specified effects. |

For the loop argument, establish an explicit preservation lemma: any accepted
body takes stores fitting widened entry ranges back into those same ranges after
restoring the lexical index. A convenient proof is declared containment for
mutable objects plus preservation of read-only cells for every statement/sequence
(extend `Assignment.unchanged`; nested loops restore their own index). This
preserves entry outer-index facts even when nested guards refine them. Alternatively
prove output-flow inclusion in the widened invariant componentwise; either route
must be actual proved closure, not an assumption passed to the iteration theorem.
Use `IntegerIteration`'s existing captured-value membership and finite iteration
lemmas. `allows_after_effects` still justifies reusing immutable input facts because
Reject is sticky; it supplies no scalar invariant by itself.

## Parser and actual-source correspondence

`PredicateAdmission.lean`/`PredicateBodyAdmission.lean` must mirror the native
flow storage and helpers; `ParseContext` and `Native.Context` retain metadata and
the declaration/index boundary. Update condition/basic/body source readings to
read expressions under the overlay. `PredicateConditionMeaning` must identify
both returned outcomes with semantic refinement, and `PredicateBodyMeaning`
must identify the complete returned flow with `Statement.check`.

Necessary bridge surface: `ScalarExpressionEnvironment.lean` and
`ScalarEnvironmentSourceBridge.lean` for overlay/active-prefix lemmas;
`PredicateNativeState/Expressions/Bodies/Equations/Contracts/SourceChecks` and
their correspondence/bridge modules for condition calls;
`PredicateBasic*`, `PredicateBody*`, `PredicateScalarBody*`, `PredicateLoop*`,
`PredicateAdapter*` for statement, loop and initialization wiring; finally
`PredicateSourceBridge.lean` and source-selected membership/safety endpoints.
Keep declaration `Compose*` meaning consistent with staticness projection.

For each newly interpreted helper, prove an arbitrary-callee typed equation,
the concrete model witness, and the corresponding native contract/representation
projection. In particular check the actual copied/read fields, array extents,
index append/removal, joins, mutable reset, and loop capture order. Existing
`ScalarsNativeSourceBridge` already interprets Refine/Swap/Complement; reuse its
checked definitions. Updating generated source certificates or source-shape pins
alone is not correspondence. All source/proof changes require the existing full
source/axiom audit at the stable checkpoint.

## Discriminating validation and remaining work

Extend `tests/test_mutable_integers.py`, `test_integer_division.py`,
`test_integer_loops.py`, `test_path_refinement.py`, `test_branching.py` and
`test_integer_image.py` where each behavior already lives. Avoid duplicating the
same happy-path sample across suites. Required differentiators:

* All six operators, reversed operands, not, whole-condition parentheses,
  parenthesized scalar nonrefinement, strict Integer endpoints, true/false paths.
* Mutable/nonstatic snapshot/static constant/index identity distinctions;
  immutable maximum-valued constant static overflow in a contradictory arm;
  same-spelled shadowed index; ordinary nonrefining comparisons remain checked.
* Guarded counter/nonzero divisor, endpoint nonzero versus crossing-zero hull,
  both short-circuit directions, and RHS Image/String expressions using reached
  flow. A nonstatic singleton threshold must not refine.
* Target replacement invalidates its old bound; unrelated writes retain facts;
  branch hull and omitted else prevent leakage; scalar/String snapshots stay
  frozen; old input-length facts survive a scalar write while a live Image changes.
* Contradictory guard falls back to the incoming range; impossible zero divisor
  remains rejected; all arms check static subtrees and assignment target legality.
* Preloop mutable refinement is lost inside repeating bodies; per-iteration
  guards work; nested bound writes do not change captured indexes; empty loop
  restores entry flow; possibly executing loop widens exit flow; outer-index
  facts and hidden object identities survive scope restoration.
* Narrowed bound discovery can expose an empty loop and trigger the retained
  empty-index RHS assignment exclusion. Record this intentional consequence;
  refineOrKeep does not imply global admission monotonicity.

Native discovery must retain original-source probes and inspect all generated
obligation/report categories for guarded updates, short circuit and repeated
loops. Extend the prior report-envelope argument by source sites and producer
behavior; unchanged source/operator bounds alone are not the argument. Complete
native compiler Bronze/Silver proof/build/audit, Lean/source correspondence,
regression/sample validation and independent review remain required. The parent
is the sole runner; no validation outcome is claimed here.

The concrete motivating sample remains the assessment's 100 doors visit-count
implementation, with its independent pass-major Boolean-toggle expected output.
Keep Oracle, installed pins, source/operator bounds, #119/#201/#202/#212 and
#88–#94 unchanged. There is no discovered scope blocker: implementation,
native discovery and universal proof closure are the next authorized work.
