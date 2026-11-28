module

public import Silver.ProcedureNameIndexedReadings
public import Silver.ProcedureNameImageReadings
public import Silver.ProcedureNameStringCursors

@[expose] public section

set_option maxHeartbeats 800000

namespace Silver.Predicate
open Compose ScalarProcedures Bindings

variable {contextFirst : Nat}

theorem ActualNameFreeTrace.stringValue {text : Source} {names : Compose.BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating integerHidden : Bool}
    {position target limit targetFirst targetAfter : Nat} {value : Operand} {result : ValueResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ValueAt (contextFirst := contextFirst) text names position value result scalarNames integerHidden arrays initials elaborating)
    (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    stringMentions target value = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
  cases source with
  | literal positive _ quote literal =>
      have start := skipAt_advances text position positionBound positive
      have bounds := Output.literalAt_bounds literal
      exact ⟨rfl, trace.quoted (by dsimp only at finishBound; omega) rfl positive quote literal finishBound⟩
  | reference positive identifier _ _ _ _ _ _ =>
      have start := skipAt_advances text position positionBound positive
      have bounds := Named.identifier_bounds identifier
      exact ⟨rfl, (trace.identifier (by dsimp only [stringReferenceValue] at finishBound; omega) rfl positive identifier finishBound).2⟩
  | slice _ _ indexed =>
      obtain ⟨lowerFree, upperFree, afterSlice⟩ := trace.indexedSlice indexed positionBound finishBound targetFound targetBound
      exact ⟨by simp only [stringMentions, lowerFree, upperFree, Bool.false_or], afterSlice⟩
  | image _ _ _ image => exact trace.imageSyntax image positionBound finishBound targetFound targetBound

/-- The String scanner's emitted atom list and punctuation transitions follow
one lexical trace; completed scanner states retain their exact source cursor. -/
theorem ActualNameFreeTrace.stringEmission {text : Source} {names : Compose.BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating integerHidden : Bool}
    {scan : ExpressionState} {emitted : Expression} {target limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter scan.position)
    (source : EmissionAt (contextFirst := contextFirst) text names scan emitted scalarNames integerHidden arrays initials elaborating)
    (positive : scan.position ≠ 0) (unfinished : scan.complete = false)
    (accepted : (expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating).position ≠ 0)
    (positionBound : scan.position ≤ text.length + 1)
    (finishBound : (expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating).position ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    emitted.any (stringMentions target) = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter
        (expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating).position := by
  generalize stepEq : expressionStep (contextFirst := contextFirst) text names scan scalarNames integerHidden arrays initials elaborating = next at accepted finishBound ⊢
  by_cases need : scan.needOperand = true
  · by_cases opened : fixedAfter text scan.position "(" false ≠ 0
    · have empty : emitted = [] := by simpa only [EmissionAt, need, opened, and_false, ↓reduceIte] using source
      subst emitted
      simp only [expressionStep, positive, unfinished, Bool.false_eq_true, need, ↓reduceIte] at stepEq
      rw [ite_eq_left opened] at stepEq
      cases stepEq
      exact ⟨rfl, trace.fixedSymbol (byte := '(') positionBound (by unfold OrdinarySymbol; decide) opened finishBound⟩
    · have noOpen : fixedAfter text scan.position "(" false = 0 := by omega
      have parsed := source
      simp only [EmissionAt, need, noOpen, and_self, ↓reduceIte] at parsed
      obtain ⟨atom, atomSource, rfl⟩ := parsed
      simp only [expressionStep, positive, unfinished, Bool.false_eq_true, need, noOpen, ne_eq, not_true_eq_false, ↓reduceIte] at stepEq
      split at stepEq
      · cases stepEq; exact False.elim (accepted rfl)
      · cases stepEq
        obtain ⟨free, following⟩ := trace.stringValue atomSource positionBound finishBound targetFound targetBound
        exact ⟨by simp only [List.any_cons, List.any_nil, free, Bool.false_or], following⟩
  · have empty : emitted = [] := by simpa only [EmissionAt, need, Bool.false_eq_true, false_and, ↓reduceIte] using source
    subst emitted
    simp only [expressionStep, positive, unfinished, Bool.false_eq_true, need, ↓reduceIte] at stepEq
    split at stepEq
    · rename_i joined
      cases stepEq
      exact ⟨rfl, trace.fixedSymbol (byte := '&') positionBound (by unfold OrdinarySymbol; decide) joined finishBound⟩
    · split at stepEq
      · rename_i closed
        cases stepEq
        exact ⟨rfl, trace.fixedSymbol (byte := ')') positionBound (by unfold OrdinarySymbol; decide) closed.1 finishBound⟩
      · split at stepEq
        · cases stepEq; exact ⟨rfl, trace⟩
        · cases stepEq; exact False.elim (accepted rfl)

private theorem stringTail_positive {text names scalarNames integerHidden arrays initials elaborating scan expression result}
    (source : ExpressionTailAt (contextFirst := contextFirst) text names scan expression result scalarNames integerHidden arrays initials elaborating) :
    result.after ≠ 0 := by
  induction source with
  | done positive _ => exact positive
  | last _ _ positive _ _ => exact positive
  | next _ _ _ _ _ _ _ ih => exact ih

private theorem stringTail_monotone {text names scalarNames integerHidden arrays initials elaborating scan expression result}
    (source : ExpressionTailAt (contextFirst := contextFirst) text names scan expression result scalarNames integerHidden arrays initials elaborating) :
    scan.position ≤ result.after := by
  have forward := Compose.Expressions.model_tail_nondecreasing (scalarNames := scalarNames) (integerHidden := integerHidden)
    (arrays := arrays) (initials := initials) (elaborating := elaborating) (contextFirst := contextFirst) text names scan
  rw [expressionTail_complete source] at forward
  exact forward.resolve_left (stringTail_positive source)

theorem ActualNameFreeTrace.stringTail {text : Source} {names : Compose.BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating integerHidden : Bool}
    {scan : ExpressionState} {expression : Expression} {result : ExpressionResult}
    {target limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter scan.position)
    (source : ExpressionTailAt (contextFirst := contextFirst) text names scan expression result scalarNames integerHidden arrays initials elaborating)
    (positionBound : scan.position ≤ text.length + 1) (finishBound : result.after ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    expression.any (stringMentions target) = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
  induction source with
  | done => exact ⟨rfl, trace⟩
  | last positive unfinished accepted _ emitted =>
      exact trace.stringEmission emitted positive unfinished accepted positionBound finishBound targetFound targetBound
  | next positive unfinished accepted _ _ emitted rest ih =>
      have nextValid := stringEmission_source_bound emitted positionBound
      have nextBound := stringTail_monotone rest
      obtain ⟨firstFree, following⟩ := trace.stringEmission emitted positive unfinished accepted positionBound
        (by omega) targetFound targetBound
      obtain ⟨restFree, afterRest⟩ := ih following nextValid finishBound
      exact ⟨by simp only [List.any_append, firstFree, restFree, Bool.false_or], afterRest⟩

theorem ActualNameFreeTrace.stringSyntax {text : Source} {names : Compose.BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating integerHidden : Bool}
    {position target limit targetFirst targetAfter : Nat} {expression : Expression} {result : ExpressionResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ExpressionAt (contextFirst := contextFirst) text names position expression result scalarNames integerHidden arrays initials elaborating)
    (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    expression.any (stringMentions target) = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after :=
  trace.stringTail source positionBound finishBound targetFound targetBound

end Silver.Predicate
