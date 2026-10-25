# Scalar guard refinement

The owner's [roadmap continuation](session-memory.md#2026-10-25--continue-non-deferred-roadmap-delivery)
authorizes [#234](https://github.com/berkeleynerd/silver/issues/234) after division
#229. This record selects the scope for #237; implementation and native discovery
are pending. It does not amend current membership or claim supported capability.
The [source assessment and addendum](evidence/scalar-guard-refinement/assessment-20261025.md)
identify the actual interfaces, proof obligations and design traps at division
commit `d85251a4fc`. The selected rules below incorporate the addendum.

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
model. The assessment contains the proposed source; no execution is claimed.

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

## Packages and next check

The existing package order remains scope/discovery [#237](https://github.com/berkeleynerd/silver/issues/237),
native [#238](https://github.com/berkeleynerd/silver/issues/238), universal/source
assurance [#239](https://github.com/berkeleynerd/silver/issues/239), then complete
validation/review/delivery [#240](https://github.com/berkeleynerd/silver/issues/240).
The assessment maps native and Lean ownership; the lead must settle shared flow
interfaces before delegating edits and remains the sole proof-workspace runner.

After division delivery, run one managed discovery batch covering the guarded
counter, reversed/false/minimum/maximum guards, guarded short-circuit division,
stale-fact replacement, branch joins, captured mutable bounds and shadowing.
Include impossible static-constant arms, minimum negation, crossing-zero
inequality and newly empty loop assignments. Retain exact inputs and complete
reports. #237 remains incomplete until that evidence and the representation
choice resolve the design obligations.

| Round | Selected settings | Resolved obligations and remaining evidence |
| --- | --- | --- |
| Read-only scope assessment | GPT-6 Astra, Extra High; runtime setting not independently exposed | Located the flow/metadata boundary, selected bounded refinement and loop rules, preserved static values, and justified the finite driver. Native discovery, frame probe and implementation remain. Elapsed time, tokens and cost unavailable. |

No additional owner decision is currently required. Oracle amendments remain
reserved; #119/#201/#202/#212, paused packets/R93 and #88–#94 stay deferred.
