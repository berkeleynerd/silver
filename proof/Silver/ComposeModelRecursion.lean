module

public import Silver.ComposeModelCalls

@[expose] public section

/-! On the original machine domains, the total model's defensive recursion
checks follow from cursor progress. Its concrete equations therefore inhabit
the same body equations used by the source interpretation. -/

namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
set_option backward.dsimp.instances true

theorem model_workTail_equation (text : Source) (_valid : ValidText text)
    (position remaining : Nat) (bound : ValidCursor text position)
    (_remainingBound : remaining ≤ maxConcatenations) :
    modelCalls.function .workTail text position remaining =
      workTailBody.eval modelCalls (Context.locals {text,position,remaining}) := by
  change workTail text position remaining = _
  dsimp +instances only [workTailBody, Expr.eval, Context.locals, Locals.set,
    modelCalls, modelPrimitives, Calls.get, Field.get]
  simp +instances only [reduceCtorEq, String.reduceEq, List.mem_cons, List.not_mem_nil, or_false,
    ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  rw [workTail]
  by_cases firstZero : skipAt text position = 0
  · simp [firstZero]
  · by_cases finished : skipAt text position > text.length
    · simp [firstZero, finished]
    · have firstAdvance := skipAt_advances text position bound firstZero
      have plainDecrease : text.length - skipAt text position <
          text.length + 1 - position := by omega
      by_cases isQuote : Cursor.byteAt text (skipAt text position) = 34
      · by_cases absent : (literalAt text (skipAt text position)).after = 0
        · simp [firstZero, finished, isQuote, absent]
        · have quotedAdvance := literalAt_advances text (skipAt text position) absent
          have quotedDecrease : text.length + 1 - (literalAt text (skipAt text position)).after <
              text.length + 1 - position := by omega
          simp [firstZero, finished, isQuote, absent, quotedDecrease]
      · by_cases nameZero : nameAfter text (skipAt text position) = 0
        · by_cases numberZero : (ScalarLiteral.read text (skipAt text position)).after = 0
          · by_cases isComparison : Cursor.byteAt text (skipAt text position) = 47 ∧
                skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61
            · have pairDecrease : text.length + 1 - (skipAt text position + 2) < text.length + 1 - position := by omega
              simp [firstZero, finished, nameZero, numberZero, isComparison]
              omega
            · simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc, isComparison, ↓reduceIte]
              by_cases isOperator : Cursor.byteAt text (skipAt text position) = 38 ∨
                  Cursor.byteAt text (skipAt text position) = 43 ∨
                  Cursor.byteAt text (skipAt text position) = 45 ∨
                  Cursor.byteAt text (skipAt text position) = 42 ∨ Cursor.byteAt text (skipAt text position) = 47
              · by_cases empty : remaining = 0
                · simp [firstZero, finished, isQuote, nameZero, numberZero, isOperator, empty]
                · simp [firstZero, finished, isQuote, nameZero, numberZero, isOperator, empty, plainDecrease]
              · simp [firstZero, finished, isQuote, nameZero, numberZero, isOperator, plainDecrease]
          · have numberBounds := ScalarLiteral.integer_bounds
              (ScalarLiteral.read_sound (model_skip_valid text position bound) numberZero)
            have numberDecrease :
                text.length + 1 - (ScalarLiteral.read text (skipAt text position)).after <
                  text.length + 1 - position := by omega
            simp [firstZero, finished, isQuote, nameZero, numberZero, numberDecrease]
        · have nameAdvance := model_name_advances text (skipAt text position) nameZero
          have nameDecrease : text.length + 1 - nameAfter text (skipAt text position) <
                text.length + 1 - position := by omega
          simp only [firstZero, finished, isQuote, ne_eq, nameZero, not_false_eq_true,
            nameDecrease, ↓reduceIte, ↓reduceDIte]
          split
          · by_cases empty : remaining = 0 <;> simp [empty]
          · rfl

theorem model_tail_equation (ranges : RangeContracts modelCalls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment)
    (scan : ExpressionState) (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (namesValid : ValidNames text names)
    (scalarNamesValid : ScalarExpression.ValidEnvironment text scalarNames)
    (scanValid : ValidScan text scan) :
    modelCalls.function .tail text names scan scalarNames integerHidden =
      tailBody.eval modelCalls (Context.locals {text,scalarNames,integerHidden,names,scan}) := by
  have nextRange := ranges.expressionStep text valid names scan scalarNames integerHidden namesValid scalarNamesValid scanValid
  change ValidScan text (expressionStep text names scan scalarNames integerHidden) ∧
    ((expressionStep text names scan scalarNames integerHidden).position = 0 ∨
      (expressionStep text names scan scalarNames integerHidden).complete = true ∨
      scan.position < (expressionStep text names scan scalarNames integerHidden).position) at nextRange
  change expressionTail text names scan scalarNames integerHidden = _
  dsimp +instances only [tailBody, Expr.eval, Context.locals, Locals.set,
    modelCalls, Calls.get, Field.get]
  simp +instances only [reduceCtorEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  rw [expressionTail]
  by_cases zero : scan.position = 0
  · simp [zero]
  · by_cases complete : scan.complete = true
    · simp [zero, complete, ExpressionState.result]
    · by_cases nextZero : (expressionStep text names scan scalarNames integerHidden).position = 0
      · simp [zero, complete, nextZero]
      · by_cases nextComplete : (expressionStep text names scan scalarNames integerHidden).complete = true
        · simp [zero, complete, nextZero, nextComplete, ExpressionState.result]
        · have advances : scan.position < (expressionStep text names scan scalarNames integerHidden).position := by
            rcases nextRange.2 with bad | done | progress
            · exact False.elim (nextZero bad)
            · exact False.elim (nextComplete done)
            · exact progress
          have bounded := nextRange.1.1
          have smaller : text.length + 1 - (expressionStep text names scan scalarNames integerHidden).position <
              text.length + 1 - scan.position := by
            unfold ValidCursor at bounded
            omega
          simp [zero, complete, nextZero, nextComplete, smaller]

theorem model_capacity_equation (text : Source) (_valid : ValidText text)
    (state : ParserState) (stateValid : ValidState text state) :
    modelCalls.function .capacity text state =
      capacityBody.eval modelCalls (Context.locals {text,state}) := by
  by_cases zero : state.position = 0
  · dsimp +instances only [capacityBody, Expr.eval, Context.locals, modelCalls, modelPrimitives,
      Field.get, capacityAt, skipAt]
    simp +instances [zero]
  · have positive : Cursor.triviaPosition text state.position ≠ 0 := by
      have lower := (Cursor.triviaPosition_bounds text state.position (by omega) stateValid.1).1
      omega
    dsimp +instances only [capacityBody, Expr.eval, Context.locals, modelCalls, modelPrimitives,
      Field.get, capacityAt, skipAt]
    simp +instances [zero, positive]

end Silver.Compose.Expressions
