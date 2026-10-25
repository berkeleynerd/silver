# Scalar guard refinement: proposed #237 package

Read-only assessment, 2026-10-25, of `d85251a4fcdf50c9dce121c7b2a6f4f1be23da94`
in `tmp/interval-integer-division`. The owner continuation recorded on main at
`3217d34d1d` authorizes #234 after division #229; packages #237–#240 are already
recorded on the milestone. This report supplies a design proposal, not completed
#237 evidence or a claim of implementation. No native/Lean/test runner was used.

Selected reviewer: GPT-6 Astra, Extra High, as assigned by the lead; runtime
settings are not independently exposed. Host observed: Linux 7.0.14 x86_64.
An inspection timestamp was 23:01:51 UTC; start/whole-round elapsed,
tokens and cost are unavailable. Inputs read include AGENTS.md, Oracle,
language/development/roadmap, the top continuation memory, assurance and trusted
boundary, live #234/#237, and the source/proof files below. No Git/GitHub mutation,
proof invocation, recursive delegation or CLI-memory update occurred.

## Recommended capability

Keep the existing grammar. Refine a **direct visible scalar name compared with
an Ada-static singleton Integer expression**, in either operand order, for all
six existing comparisons. Useful targets are mutable objects and scoped loop
indexes, distinguished by resolved identities and the declaration/index boundary.
Preserve immutable declaration constants' exact read intervals; their
singleton precision cannot improve except by detecting an impossible arm, which
is unnecessary here. Use the already proved native `Refine`/`Refine_True`,
`Complement` and `Swap`, and Lean `Integer.Interval.refine_sound` and
`refine_bounded`. No expression inversion, variable-to-variable relation,
disjoint intervals, solver-selected membership or loop-invariant inference.

Both operands must first pass the ordinary incoming expression check, including
independent static legality. The threshold must have `Static = True` and a
nonempty singleton interval. Staticness remains declaration-derived: an exact
constant copied from a mutable object is immutable but not Ada-static. Such a
constant remains readable with its exact snapshot value; it is deliberately
outside the selected threshold cases. Other currently admitted comparisons
remain grammatical and checked, but produce unchanged scalar facts.

For the smallest native implementation, identify a bare name by its resolved
binding ID and complete operand source span; do not infer identity from the
numeric interval. Parentheses around the whole condition work already.
Parenthesized scalar names can either be normalized explicitly with a proved
name-reading helper, or remain nonrefining initially; state the choice in the
language/catalogue. Bare-name refinement is sufficient for the driver. No
arithmetic AST/result-wide metadata expansion is inherently needed.

For `X op K`, intersect the current X interval with the true constraint; false
uses the complemented operator. Reverse operands through `Swap`. Strict
comparisons at Integer minimum/maximum must use the existing endpoint-safe
helpers. `X /= 0` narrows `[0,b]` to `[1,b]` or `[a,0]` to `[a,-1]`, but for
`a < 0 < b` its convex hull still includes zero. Consequently such a guard does
not admit division for a crossing-zero interval. Use separate `X > 0` / `X < 0`
arms when both signs are needed. `X = K` true and `X /= K` false give a singleton;
the opposite outcome removes an endpoint only when representable by one interval.

## Actual state boundary and required transfer

The native `Body_Context` in `src/silver_output_profile.adb:1062` owns immutable
String bindings and `Scalar_Names`. `Body_Scan` and `Condition_Result` carry
only `Silver_Path_Facts.Context`; `Read_Relation` currently returns unchanged
facts for scalar comparisons. `Context_Of` invokes `Body_Environment`, which
widens mutable declaration values to declared ranges. Each scalar binding
already separates `Bounds`, `Declared_Bounds`, `Mutable` and `Static`.
`Scalar_Assignment_Body` checks against declared bounds and discards the result
interval. `Loop_Body` appends an immutable index to a copied context; both bounds
are read before the append, with the new name masked out of its own bounds.

Lean matches this arrangement: `ScalarExpression.Binding`, `ParseContext` /
`Native.Context`, and `Predicate.BodyScan` mirror those records.
`Condition.refine` changes only input/String path facts; `Statement.check`
returns `Option PathFacts.Context` and threads a fixed `Integer.Ranges` argument
through all sequential statements. `Integer.Assignment.check` currently requires
the assignment's declared bounds to equal that fixed target range. Simply
replacing this fixed range by a refined range would wrongly reject valid writes
and cannot prove the desired transition invariant.

Introduce an explicit flow value containing existing input/String path facts
and scalar read intervals, with immutable binding metadata/declared ranges kept
separate. Extend both condition outcomes and statement results. The key invariant
is that the concrete store fits the current flow intervals **and** all immutable
declared ranges; metadata, identities, mutability and staticness do not change.
Keep this feature-local; a new general metadata framework is unnecessary.

Static-value trap: `ScalarExpression.constants` currently reads `bounds.lower`,
and native arithmetic uses the binding's `Bounds`. Never overlay an Ada-static
constant's exact singleton with Empty and then use that environment for static
evaluation: `K = Integer'Last; if K < 0 then ... (K + 1) ...` could otherwise hide
illegal static overflow. The selected rule refines only mutable object identities
and loop-index identities. Keep static evaluation on immutable declaration
metadata, and prove that applying the flow overlay leaves every declaration
constant unchanged. Carry the declaration-prefix/index identity boundary explicitly
if needed; do not conflate nonstatic immutable snapshots with loop indexes merely
because both have `Mutable = False` and `Static = False`. This closes the trap
without redesigning static-value representation.

* **Initialization:** retain today's exact declaration elaboration and immutable
  snapshots. Begin executable mutable reads at declared bounds, preserving the
  current initialization/body distinction.
* **Assignment:** infer RHS in the old flow, require a nonempty interval wholly
  inside the target's immutable declared range, execute it, and replace the
  target flow interval with the inferred RHS interval. Retain other scalar
  intervals and input-length facts. This replaces stale target facts, including
  self-update facts; it does not intersect the new result with the old guard.
  Resetting just the target to its declared range would also be sound and enough
  for counters, but retaining the already computed RHS costs only the standard
  store-update containment proof and gives useful straight-line transfer.
* **Branches:** carry both refinements, thread each arm, then take componentwise
  interval hulls plus the existing input-context join. An omitted else contributes
  the condition's false flow. `elsif` starts from the preceding false flow.
  Do not retain cross-object or cross-input correlations at a join.
* **Short circuit:** check `and then` RHS in left-true flow and `or else` RHS in
  left-false flow. Join the alternative outcomes exactly as today's path checker
  does. `not` swaps outcomes. Both scalar arithmetic and Image/String expressions
  in the RHS must receive that flow, not only subsequent statements.
* **Snapshots and String writes:** immutable scalar/String snapshots never become
  aliases. String writes leave scalar facts intact. Scalar writes preserve facts
  about immutable selected-input length already established by an earlier Image
  comparison, but must never preserve a relation asserting that a later live Image
  equals the old Image. Existing path facts store only the former kind.
* **Unreachable arms:** keep scalar empty intervals as conservative abstract
  results; do not use this increment to add scalar-impossibility pruning of the
  independent String/input context. Componentwise joins may therefore retain
  infeasible contributions. Every arm still resolves names/targets and checks
  static subtrees. Preserve the nonempty scalar-assignment RHS rule even when a
  guard proves the arm impossible. This can reject an assignment that was formerly
  checked under a wider range: document this intentional membership consequence,
  preserve existing samples, and test it explicitly. Do not silently skip the arm
  or weaken the pinned frontend restriction.

## Loop rule: capture first, widen mutable facts

1. Evaluate/infer both bounds in entry flow, before resetting mutable facts and
   before exposing the new index. Capture their intervals and the existing
   empty/definitely-nonempty/uncertain classification once.
2. Analyze the body once after widening **every mutable scalar** to its declared
   range. Retain incoming immutable/outer-index facts. Append a fresh binding ID
   for the index, with the captured `[lower.lower, upper.upper]` interval.
   Each semantic iteration must be shown to enter this same conservative body
   context, with its actual captured index value. Guard facts acquired in one
   iteration cannot justify the next.
3. For a provably empty loop, restore entry flow. For any possibly executing loop,
   widen every mutable scalar at exit as well; retain the entry immutable facts
   and remove only the new index. Use today's path-context empty/definite/uncertain
   exit rule, once its repeated-iteration premise has been re-established.
   Do not export additional body-derived immutable refinements in this increment.

This deliberately avoids modified-variable analysis, fixed points and an
inductive loop-carried numeric invariant. A fact just before a loop need not be
usable for a mutable read inside or after it; a guard immediately inside the
loop is useful. Even a read-only loop may lose mutable precision. Captured bounds
remain precise: if entry flow establishes `Limit <= 9`, an index captured from
`1 .. Limit` remains at most 9 even if the body assigns `Limit := 20`.
Nested loops capture anew on each entry. Hidden outer objects use their original
IDs and are never changed by refining or restoring a same-spelled inner index.

Important proof caveat: current repeated-loop reasoning reuses incoming input
facts because selected input is immutable and rejection is sticky. With scalar
flow attached, this reuse is sound only for the widened body context and retained
immutable facts. A wholesale reuse of the preloop refined mutable context is
unsound. Loop-bound captures are facts about index values, not persistent facts
about subsequently assigned bound objects.

## Finite motivating sample

Use **100 doors**, whose checked-in task asks for all final open/closed states.
Count the visits to each door, then report parity. Visits to different doors are
independent, so exchanging loop order preserves each door's toggle history;
parity of visit count is exactly its final state. The proposed source is:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Visits : Integer range 0 .. 100 := 0;
begin
   for Door in 1 .. 100 loop
      Visits := 0;
      for Pass in 1 .. 100 loop
         if (Door mod Pass) = 0 and then Visits < 100 then
            Visits := (Visits + 1);
         end if;
      end loop;
      if (Visits mod 2) = 1 then
         Silver_IO.Put_Line (Integer'Image (Door) & " is open");
      else
         Silver_IO.Put_Line (Integer'Image (Door) & " is closed");
      end if;
   end loop;
end Main;
```

There are exactly 100 candidate visits per door; before any increment there
have been at most 99 prior visits, so the bound guard suppresses no requested
toggle. The program uses 10,000 finite inner iterations. Expected open doors are
1, 4, 9, 16, 25, 36, 49, 64, 81 and 100; all remaining doors are closed. Generate
the complete expected text independently by a pass-major Boolean toggle model,
including Integer Image's leading spaces. No sample execution is claimed here.
This is a faithful alternative to the assessment's Boolean array implementation;
update only its actual dependency assessment when delivery is validated.

Harshad finite outputs are another feasible scalar/divisor exercise, but its
task explicitly requests a successive-member generator. Do not claim the whole
Rosetta task supported merely from a fixed finite output demo without resolving
that source/API correspondence. A focused non-Rosetta probe can simply test
`D > 0 and then (N mod D) = 0` for `D : Integer range 0 .. 9`.

## Ownership and exact assurance obligations

Suggested future file ownership; no implementation was made by this assessment.
One integration owner must reconcile interface changes before source certificates
are regenerated. Arithmetic helpers can be reused unchanged.

| Work package / owner | Source and proof surface |
| --- | --- |
| #237 lead/design | New capability record, language/catalogue rule draft, driver/probe inputs; producer/report-envelope rationale. Do not close #237 before native discovery. |
| #238 native owner | `src/silver_output_profile.adb` body/condition/scalar/loop state and callers; `silver_scalar_expressions.ads/.adb` only for necessary flow projection/helpers. Keep scalar metadata/declared bounds stable; preserve verified executable/ghost scanner equality and selectors. |
| #239 semantic owner | `IntegerMutable`, `IntegerChecks`; `PredicateChecking`, `PredicateStatements`, `PredicateExecution`, `PredicateComposition`, `PredicateObligations`, `PredicateChecks`; reuse `IntegerComparisons`/`IntegerIntervals` and `IntegerIteration`. |
| #239 parser/source owner | `ScalarExpressionEnvironment` and `ScalarEnvironmentSourceBridge`; `PredicateAdmission`, `PredicateBodyAdmission`, condition/body readings/meaning/soundness; `PredicateNative*`, `PredicateBody*`, `PredicateScalarBody*`, `PredicateLoop*`, `PredicateAdapter*`, their typed expressions/equations/contracts/source checks and `PredicateSourceBridge`. `Compose*` declaration/initializer meaning must continue to agree with the unchanged metadata boundary. |
| #240 delivery owner | Focused integer/path/mutable/loop tests, sample/manifest, capability/assurance/trusted-boundary records, language/catalogue, roadmap, scoped Rosetta assessment/support/render and issue handoff; complete validation and independent review. |

Required universal statements are: flow containment after each true/false
predicate outcome; correct swapped/complemented comparison; assignment RHS safety,
declared-range preservation and exactly-target flow/store update; hull inclusion;
short-circuit safety under the reached flow; restoration and immutable preservation
under shadowing; captured-bound finite execution; widened-loop invariant across
arbitrarily many admitted iterations; and source-wide decidable admission with
every permitted composition, independent of prover success. Preserve initialized
String stores, specified IO/Reject effects and invalid-input rejection behavior.

The obligation traversal must use **the same intermediate flow** as admission at
every scalar node, Image, predicate RHS, assignment, branch, loop bound and body.
Repair `Assignment.obligations_discharge`, `Condition.obligations_exact`, statement
and sequence obligation completeness, `Program.all_obligations_discharge`,
`Program.scalar_execution_invariant`, and current-language endpoints. Proving
concrete execution safety alone does not supply these discharge arguments.
No new native check class is expected: range, overflow, length and nonzero divisor
checks remain, but actual pinned-tool discovery must verify diagnostics, preserved
full report coverage and practical automatic discharge. Existing external solver
completion premises stay explicit; no new bounded completion theorem is implied.

Actual-source correspondence must cover newly read identity/staticness fields,
flow storage, active-array projection, resets/joins, all condition and statement
calls, target declared bounds, loop capture order and scope restoration. Extend
arbitrary-callee equations plus concrete witnesses and native contracts; do not
replace these with assumed equality to the recognizer or with source pins alone.
Audit all changed signatures, whole relevant declarations and imported helpers,
source dependencies and generated certificates. `ScalarsNativeSourceBridge`
already interprets `refine`; a small exported refine-sound corollary may make the
new call site explicit without changing the helper definition.

## Smallest experiments and failure cases

After division delivery, use one managed focused discovery run before broad
implementation: raw original-source SPARK probes for a guarded counter inside a
non-unrolled loop, false/reversed guards, a guarded divisor in a short-circuit
RHS, assignment replacement, branch joins, and a captured mutable loop bound.
Inspect every emitted obligation/report category and map it to the endpoint
schema. Retain exact source/tool/options and successful evidence. Then implement
and verify the narrow transfer, followed by full native proof/build/audit,
complete Lean/source/axiom audit, full regression/sample suite and independent
semantic/source review under the existing workflow.

Discriminating negative/interaction probes:

* `X < 9; X := 9; X := X+1` must not retain X's old upper bound.
* A branch assigning 9 must participate in the subsequent join; omitted else
  cannot inherit true-arm bounds. Unrelated target writes must preserve X facts.
* `X /= 0` with a crossing-zero declared interval still cannot justify division;
  `X > 0` can. Swap, negation, equality/inequality and min/max strict endpoints
  require separate exact checks.
* An outer guard before a repeating loop cannot bound a mutable body read after
  a prior iteration writes it. A guard inside each iteration can.
* A nested loop changes a mutable bound source but not the already captured
  index range. Same-spelled index shadowing cannot narrow the hidden object.
* Impossible scalar guards still reject statically illegal arithmetic and empty
  scalar-assignment RHSs. Live Image lengths use current flow; old snapshots do not.
  Specifically test an impossible branch on a maximum-valued Ada-static constant
  containing `(K + 1)`, minimum-value negation, and a loop index shadowing K.
* Full-range/grouped arithmetic comparisons still parse without being inverted.
  Nonstatic immutable singleton thresholds remain outside the selected refinement.

Report counting needs a source-level delta argument, not just sample totals:
new flow analysis adds no authored operation/check sites, no bound or library,
and leaves source/operator counting intact; show that the prior envelope already
bounds possibly retained guard, range, arithmetic and Image records after altered
elimination. If an assumption changes, repair the feature-local calculation.
Do not automatically expand the report bound or reopen #119.

One concrete implementation risk is recursive frame size: today condition
results are tiny; two full scalar vectors per nested condition may inflate stack
usage materially at the unchanged 4,096-byte limit, even when few bindings are
active. Measure deepest parentheses/chains plus nested loops with scalar flow,
and choose representation accordingly. This is a feature-local regression and
resource-premise check, not a reason to resume deferred capacity architecture.

No owner-reserved decision is presently necessary. Threshold scope, conservative
loop resets, joins, source helper structure and proof organization are ordinary
implementation choices within #234. Keep Oracle, installed pins, source/operator
bounds, #119/#201/#202/#212, #88–#94 and paused packets unchanged. Missing native
discovery/proofs are work remaining, not an owner approval gate or a valid stop.

## Addendum: keep the incoming interval when refinement is empty

2026-10-25, 23:08 UTC. Bounded follow-up, selected GPT-6 Astra Extra High;
runtime settings, elapsed/token/cost measurements unavailable. No runners used.

**Recommend `refineOrKeep` for the initial scope:** compute the existing
`Interval.refine incoming op threshold truth`; return `incoming` if its result
is Empty, otherwise return that result. This supersedes the earlier proposal
to introduce empty scalar facts from contradictory guards and the associated
new empty-RHS assignment rejections. Continue to apply it only to mutable
object identities and scoped loop-index identities against static thresholds.

The rule is sound: when the result is retained, `refine_sound` gives containment;
when the incoming interval is restored, its original containment suffices.
Contradictory outcomes acquire no additional precision, but no concrete execution
is omitted. Boundedness follows by the same case split. Prove additionally that
the result is included in the incoming interval, preserves nonemptiness for
nonempty inputs, and maps an initially empty index interval to Empty. The last
property follows from refinement of Empty for each of the six comparisons.

Useful behavior is unchanged. `Visits : 0 .. 100` under `Visits < 100` becomes
`0 .. 99`; `D : 0 .. 9` under `D > 0` or `D /= 0` becomes `1 .. 9`. Equality to
an included threshold still produces its singleton; false and reversed guards
still use Complement/Swap. Crossing-zero nonzero guards still cannot exclude
the interior zero. An impossible `D /= 0` when D is already `[0,0]` leaves
`[0,0]`, so subsequent division remains rejected. No new use of unreachable
code is necessary for the counter or nonzero-divisor driver.

For example, with X declared `0 .. 9`, `if X = 10 then X := X; end if` keeps
the previously admissible nonempty RHS instead of inventing a new empty-RHS
rejection. Empty-index-dependent assignment RHSs in already empty loops remain
excluded. All arms still receive ordinary name, target, static-subtree and
arithmetic checks; the fallback does not skip checking or turn a known illegal
static expression into a vacuous obligation.

Assignment replacement, componentwise joins, short-circuit propagation and the
proposed loop resets compose unchanged with this transfer. Mutable flow intervals
remain nonempty inductively: declared bounds start nonempty, accepted assignment
RHSs are nonempty, guards preserve nonemptiness, joins preserve it, and loop
resets restore declared ranges. The obligation traversal must use this exact
wrapped transfer wherever the checker does. Lost contradiction precision can
only prevent an admission that would require that precision; it is not a safety
gap or a need for relational facts.

This does **not** establish preservation of every previous admission: useful
narrowing can make a loop's inferred index range empty. For example, a guard
`X < 2` for X in `0 .. 9`, followed by `for I in 2 .. X`, now exposes an empty
loop and can trigger the retained empty-index assignment exclusion. Record this
remaining interaction explicitly; do not claim global admission monotonicity
from the fallback rule alone.

Keep the simultaneous identity/static-value resolution unchanged. Immutable
declaration constants, including nonstatic snapshots, retain their exact values;
do not treat `Mutable = False, Static = False` as identifying a loop index.
Shadowing selects the fresh scoped ID, never its same-spelled declaration.
Static evaluation still reads immutable declaration metadata. The fallback is
not authorization to overlay those values or to broaden refinement eligibility.
Retain min/max strict-comparison, impossible static-constant overflow/negation,
and shadowed-index regressions. This is an ordinary scope refinement within #237;
implementation remains after #229 and native discovery remains outstanding.
