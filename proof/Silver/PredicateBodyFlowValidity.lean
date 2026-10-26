module

public import Silver.PredicateBodyFlow
public import Silver.PredicateBodyProperties
public import Silver.PredicateConditionFlowValidity
public import Silver.ScalarExpressionNativeRecursion

@[expose] public section

namespace Silver.Predicate
open Compose

namespace ScalarMetadata

theorem FlowReady.replace {names declarations flow}
    (base : BaseReady names declarations) (ready : FlowReady names declarations flow)
    (index : Nat) (bounds : Integer.Interval) (positive : 0 < index)
    (bounded : index ≤ names.length) (mutable : (ScalarExpression.binding names index).mutable = true)
    (typed : bounds.Bounded) (nonempty : bounds.isEmpty = false)
    (included : ∀ value, bounds.Contains value → (ScalarExpression.binding names index).declaredBounds.Contains value) :
    FlowReady names declarations (flow.replace index bounds) := by
  have active : index ≤ flow.count := by rw [ready.compatible.count]; exact bounded
  have model := ActiveFlow.replace_model flow index bounds positive active
  refine ⟨?_, ?_, ?_, ?_⟩
  · apply overlayCompatible_of_preserved ready.compatible
      ((ActiveFlow.replace_count ..).trans ready.compatible.count)
    intro other otherPositive otherBound immutable declared
    have different : other ≠ index := by
      intro same
      subst other
      rw [mutable] at immutable
      contradiction
    rw [model]
    exact ite_eq_right different
  · rw [model]
    exact Integer.Ranges.put_bounded ready.bounded typed
  · intro other target found
    rw [model]
    by_cases same : other = index
    · subst other
      have bindingFound : (analysis names declarations).declared index =
          some (ScalarExpression.binding names index).bounds := by
        simp only [analysis, ScalarExpression.ranges, positive, bounded, and_self, ↓reduceIte]
      rw [bindingFound] at found
      cases found
      refine ⟨bounds, by simp only [Integer.put, ↓reduceIte], ?_⟩
      rw [ScalarExpression.bodyReady_binding base.body positive bounded mutable]
      exact included
    · obtain ⟨incoming, present, subset⟩ := ready.contained other target found
      exact ⟨incoming, by simpa only [Integer.put, same, ↓reduceIte] using present, subset⟩
  · intro other value isMutable found
    rw [model] at found
    change Integer.put flow.model.scalars index (some bounds) other = some value at found
    by_cases same : other = index
    · subst other
      simp only [Integer.put, ↓reduceIte, Option.some.injEq] at found
      subst value
      exact nonempty
    · apply ready.mutableNonempty other value isMutable
      simpa only [Integer.put, same, ↓reduceIte] using found

end ScalarMetadata

def BodyScan.FlowReady (context : ParseContext) (scan : BodyScan) : Prop :=
  ScalarMetadata.FlowReady context.scalarNames context.declarationCount scan.facts

theorem invalidBody_flowReady {context scan} (ready : BodyScan.FlowReady context scan) :
    (invalidBody scan).FlowReady context := ready.withPath _

theorem bodyToken_flowReady {context scan} (ready : BodyScan.FlowReady context scan)
    (text : Source) (token : ShellToken) : (bodyToken text scan token).FlowReady context := ready

theorem bodyTokens_flowReady {context scan} (ready : BodyScan.FlowReady context scan)
    (text : Source) (tokens : List ShellToken) : (bodyTokens text scan tokens).FlowReady context := by
  simpa only [BodyScan.FlowReady, bodyTokens_facts] using ready

private theorem scalarRead_bounds_bounded (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) : (ScalarExpression.read text position names).bounds.Bounded := by
  by_cases zero : (ScalarExpression.read text position names).after = 0
  · rw [show ScalarExpression.read text position names = ScalarExpression.invalid from ScalarExpression.Native.summarize_zero zero]
    exact Integer.Interval.empty_bounded
  · obtain ⟨expression, inferred, _, _⟩ := ScalarExpression.read_has_expression zero
    exact Integer.Expr.infer_bounded inferred

private theorem true_of_not_neg {value : Bool} (known : ¬(!value) = true) : value = true := by
  cases value <;> simp_all

theorem scalarAssignment_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : scan.FlowReady context) : (scalarAssignmentBody text context scan).FlowReady context := by
  unfold scalarAssignmentBody
  dsimp only
  split
  · exact invalidBody_flowReady ready
  · rename_i good
    have nonzero : scalarTarget text context scan.position ≠ 0 := fun bad => good (Or.inl bad)
    have targetBound : scalarTarget text context scan.position ≤ context.scalarNames.length :=
      ScalarExpression.lookup_bound ..
    have mutable : (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).mutable = true :=
      true_of_not_neg (fun bad => good (Or.inr (Or.inl bad)))
    have nonempty : (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.isEmpty = false :=
      Bool.eq_false_iff.mpr (fun bad => good (Or.inr (Or.inr (Or.inr (Or.inl bad)))))
    have low : ¬ (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.lower <
        (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds.lower :=
      fun bad => good (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl bad)))))
    have high : ¬ (ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts)).bounds.upper >
        (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds.upper :=
      fun bad => good (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr bad)))))
    apply ScalarMetadata.FlowReady.replace base ready _ _ (Nat.pos_of_ne_zero nonzero) targetBound mutable
      (scalarRead_bounds_bounded ..) nonempty
    intro value within
    rcases within with ⟨lo, hi⟩
    constructor <;> omega

theorem basicRaw_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : scan.FlowReady context) : (basicRaw text context scan).FlowReady context := by
  unfold basicRaw
  cases basicKind text context scan with
  | null => exact ready
  | output =>
      try dsimp only
      split
      · exact invalidBody_flowReady ready
      · exact ready
  | put =>
      try dsimp only
      split
      · exact invalidBody_flowReady ready
      · exact ready
  | reject => exact ready.withPath _
  | scalarAssignment => exact scalarAssignment_flowReady text context scan base ready
  | assignment =>
      try dsimp only
      split
      · exact invalidBody_flowReady ready
      · exact ready

theorem basic_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : scan.FlowReady context) : (basicBody text context scan).FlowReady context := by
  unfold basicBody
  split
  · exact invalidBody_flowReady ready
  · try dsimp only
    split
    · exact invalidBody_flowReady ready
    · exact bodyToken_flowReady (basicRaw_flowReady text context scan base ready) text _

theorem branchStart_flowReady (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : scan.FlowReady context) :
    (branchStart text context scan keyword).1.FlowReady context ∧
      ScalarMetadata.FlowReady context.scalarNames context.declarationCount (branchStart text context scan keyword).2 :=
  condition_flowReady text context (bodyToken text scan (.word keyword)).position scan.facts base ready

end Silver.Predicate
