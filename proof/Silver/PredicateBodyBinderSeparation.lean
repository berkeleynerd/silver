module

public import Silver.PredicateBodyReadings
public import Silver.PredicateLoopProperties

@[expose] public section

/-! Every scoped identity comes from the active native scalar prefix. The
source-derived bound separates all nested loop binders from array storage;
the generic statement model itself has no native-identity assumption. -/
namespace Silver.Predicate
open Compose

mutual
  theorem statement_bindersApart {text context scan item result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : StatementAt text context scan item result) : item.lower.bindersApart array = true := by
    cases parsed with
    | basic _ _ _ reading _ => cases reading.payload <;> simp only [SourceStatement.lower, Statement.bindersApart]
    | choice _ _ reading _ =>
        have branches := choice_bindersApart low apart reading
        simpa only [SourceStatement.lower, Statement.bindersApart, Bool.and_eq_true] using branches
    | loop _ _ _ reading _ => exact loop_bindersApart low apart reading
    | arrayLoop _ _ _ reading _ => exact arrayLoop_bindersApart low apart reading
  termination_by (bodyRemaining text scan, 2)

  theorem loop_bindersApart {text context scan lower upper body result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : LoopAt text context scan lower upper body result) :
      (SourceStatement.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        lower upper body).lower.bindersApart array = true := by
    cases parsed with
    | loop _ allowed _ _ _ bodyRead _ _ _ =>
        have space := loopNameAllowed_space low allowed
        have innerLow : (loopInner context (loopHeader text context scan)).scalarNames.length ≤ ArrayBindings.scalarLimit := by
          simpa only [loopInner, List.length_append, List.length_singleton] using space
        have bodyApart := body_bindersApart innerLow apart bodyRead
        simpa only [SourceStatement.lower, Statement.bindersApart, apart _ space, not_false_eq_true, decide_true,
          Bool.true_and] using bodyApart
  termination_by (bodyRemaining text scan, 1)

  theorem arrayLoop_bindersApart {text context scan body result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : ArrayLoopAt text context scan body result) :
      (SourceStatement.arrayLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).descriptor body).lower.bindersApart array = true := by
    cases parsed with
    | loop _ allowed _ _ bodyRead _ _ _ =>
        have space := loopNameAllowed_space low allowed
        have innerLow : (loopInner context (loopHeader text context scan)).scalarNames.length ≤ ArrayBindings.scalarLimit := by
          simpa only [loopInner, List.length_append, List.length_singleton] using space
        have bodyApart := body_bindersApart innerLow apart bodyRead
        simpa only [SourceStatement.lower, Statement.bindersApart, apart _ space, not_false_eq_true, decide_true,
          Bool.true_and] using bodyApart
  termination_by (bodyRemaining text scan, 1)

  theorem choice_bindersApart {text context scan condition yes tail result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : ChoiceAt text context scan condition yes tail result) :
      statementsBindersApart array (lowerStatements yes) = true ∧
        statementsBindersApart array tail.lower = true := by
    cases parsed with
    | choice _ _ yesRead _ noRead _ _ _ =>
        exact ⟨body_bindersApart low apart yesRead, alternative_bindersApart low apart noRead⟩
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_bindersApart {text context scan tail result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : AlternativeAt text context scan tail result) :
      statementsBindersApart array tail.lower = true := by
    cases parsed with
    | absent => simp only [SourceAlternative.lower, statementsBindersApart]
    | otherwise _ _ _ _ bodyRead _ =>
        simpa only [SourceAlternative.lower] using body_bindersApart low apart bodyRead
    | elsif _ _ _ _ yesRead _ noRead _ _ _ =>
        simp only [SourceAlternative.lower, statementsBindersApart, Statement.bindersApart,
          body_bindersApart low apart yesRead, alternative_bindersApart low apart noRead, Bool.and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_bindersApart {text context stop scan items result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : BodyTailAt text context stop scan items result) :
      statementsBindersApart array (lowerStatements items) = true := by
    cases parsed with
    | done => simp only [lowerStatements, statementsBindersApart]
    | next _ _ itemRead _ restRead _ =>
        simpa only [lowerStatements, statementsBindersApart, Bool.and_eq_true] using
          And.intro (statement_bindersApart low apart itemRead) (bodyTail_bindersApart low apart restRead)
  termination_by (bodyRemaining text scan, 3)

  theorem body_bindersApart {text context scan stop items result}
      {array : Integer.ArrayDescriptor}
      (low : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
      (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
      (parsed : BodyAt text context scan stop items result) :
      statementsBindersApart array (lowerStatements items) = true := by
    cases parsed with
    | cons itemRead _ restRead _ =>
        simpa only [lowerStatements, statementsBindersApart, Bool.and_eq_true] using
          And.intro (statement_bindersApart low apart itemRead) (bodyTail_bindersApart low apart restRead)
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
