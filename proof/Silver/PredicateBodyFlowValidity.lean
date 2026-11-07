module

public import Silver.PredicateStringAssignmentFields

public import Silver.PredicateBodyFlow
public import Silver.PredicateBodyProperties
public import Silver.PredicateConditionFlowValidity

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata}
open Compose

namespace ScalarMetadata

theorem FlowReady.replace {names declarations flow}
    (ready : FlowReady names declarations flow)
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
      have bindingFound : flowBounds names index =
          some (ScalarExpression.binding names index).declaredBounds := by
        rw [flowBounds_active names index positive bounded, mutable]
        rfl
      rw [bindingFound] at found
      cases found
      refine ⟨bounds, by simp only [Integer.put, ↓reduceIte], ?_⟩
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

private theorem true_of_not_neg {value : Bool} (known : ¬(!value) = true) : value = true := by
  cases value <;> simp_all

theorem scalarAssignment_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (_base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
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
    have nonempty : (readScalarInFlow text context (scalarAssignmentStart text scan) scan.facts).bounds.isEmpty = false :=
      Bool.eq_false_iff.mpr (fun bad => good (Or.inr (Or.inr (Or.inr (Or.inl bad)))))
    have low : ¬ (readScalarInFlow text context (scalarAssignmentStart text scan) scan.facts).bounds.lower <
        (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds.lower :=
      fun bad => good (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl bad)))))
    have high : ¬ (readScalarInFlow text context (scalarAssignmentStart text scan) scan.facts).bounds.upper >
        (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds.upper :=
      fun bad => good (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr bad)))))
    have positive : (readScalarInFlow text context (scalarAssignmentStart text scan) scan.facts).after ≠ 0 := by
      intro zero
      exact good (Or.inr (Or.inr (Or.inl (by omega))))
    obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound
      (Compose.Expressions.model_fixed_valid text _ ":=" false (Compose.Expressions.model_name_valid text _)) positive
    apply ScalarMetadata.FlowReady.replace ready _ _ (Nat.pos_of_ne_zero nonzero) targetBound mutable
      (Integer.Expr.infer_bounded parsed.inferred) nonempty
    intro value within
    rcases within with ⟨lo, hi⟩
    dsimp only [scalarAssignmentStart, readScalarInFlow] at low high
    constructor <;> omega

theorem readCall_bounds (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata)
    (valid : FunctionBindings.ValidMetadata text catalog) :
    (readCall text context position facts catalog).bounds.Bounded := by
  unfold readCall
  dsimp only
  split
  · exact Integer.Interval.empty_bounded
  · rename_i nonzero
    split
    · exact Integer.Interval.empty_bounded
    · have present := FunctionBindings.signature_mem (Nat.pos_of_ne_zero nonzero)
        (calleeAt_bound text context position catalog)
      exact (valid.2.2.2 _ present).2.2.2.2.2.1

theorem callAssignmentResult_flowReady (context : ParseContext) (scan : BodyScan)
    (scalar flag : Nat) (value : CallResult) (ready : scan.FlowReady context)
    (targetBound : scalar ≤ context.scalarNames.length) (typed : value.bounds.Bounded) :
    (callAssignmentResult context scan scalar flag value).FlowReady context := by
  unfold callAssignmentResult
  split
  · exact invalidBody_flowReady ready
  · split
    · rename_i nonzero
      dsimp only
      split
      · exact invalidBody_flowReady ready
      · rename_i good
        have mutable : (ScalarExpression.binding context.scalarNames scalar).mutable = true :=
          true_of_not_neg (fun bad => good (Or.inr (Or.inl bad)))
        have nonempty : value.bounds.isEmpty = false :=
          Bool.eq_false_iff.mpr (fun bad => good (Or.inr (Or.inr (Or.inl bad))))
        have included : value.bounds.included (ScalarExpression.binding context.scalarNames scalar).declaredBounds = true :=
          true_of_not_neg (fun bad => good (Or.inr (Or.inr (Or.inr bad))))
        exact ScalarMetadata.FlowReady.replace ready scalar value.bounds
          (Nat.pos_of_ne_zero nonzero) targetBound mutable typed nonempty
          (fun _ within => Integer.Interval.included_sound included within)
    · split
      · exact ready
      · exact invalidBody_flowReady ready

theorem callAssignment_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata) (valid : FunctionBindings.ValidMetadata text catalog)
    (ready : scan.FlowReady context) : (callAssignmentBody text context scan catalog).FlowReady context :=
  callAssignmentResult_flowReady context scan _ _ _ ready (ScalarExpression.lookup_bound ..)
    (readCall_bounds text context _ scan.facts catalog valid)

theorem basicRaw_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (valid : FunctionBindings.ValidMetadata text catalog)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (ready : scan.FlowReady context) : (basicRaw (catalog := catalog) text context scan).FlowReady context := by
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
  | scalarAssignment =>
      dsimp only
      split
      · exact callAssignment_flowReady text context scan catalog valid ready
      · exact scalarAssignment_flowReady text context scan base ready
  | arrayAssignment =>
      unfold arrayAssignmentBody
      dsimp only
      split
      · exact invalidBody_flowReady ready
      · exact ready
  | booleanAssignment =>
      dsimp only
      split
      · exact callAssignment_flowReady text context scan catalog valid ready
      · unfold booleanAssignmentBody
        dsimp only
        split
        · exact invalidBody_flowReady ready
        · exact ready
  | booleanArrayAssignment =>
      unfold booleanArrayAssignmentBody
      dsimp only
      split
      · exact invalidBody_flowReady ready
      · exact ready
  | assignment =>
      dsimp only
      split
      · exact invalidBody_flowReady ready
      · rcases stringAssignment_fields text context scan with failed | fields
        · rw [failed]
          exact invalidBody_flowReady ready
        · simpa only [BodyScan.FlowReady, fields.2.2.1] using ready

theorem basic_flowReady (text : Source) (context : ParseContext) (scan : BodyScan)
    (valid : FunctionBindings.ValidMetadata text catalog)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (ready : scan.FlowReady context) : (basicBody (catalog := catalog) text context scan).FlowReady context := by
  unfold basicBody
  split
  · exact invalidBody_flowReady ready
  · try dsimp only
    split
    · exact invalidBody_flowReady ready
    · exact bodyToken_flowReady (basicRaw_flowReady (catalog := catalog) text context scan valid base ready) text _

theorem branchStart_flowReady (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (ready : scan.FlowReady context) :
    (branchStart text context scan keyword).1.FlowReady context ∧
      ScalarMetadata.FlowReady context.scalarNames context.declarationCount (branchStart text context scan keyword).2 := by
  exact condition_flowReady text context (bodyToken text scan (.word keyword)).position scan.facts base ready

end Silver.Predicate
