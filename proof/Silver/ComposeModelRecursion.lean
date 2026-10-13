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
  simp only [workTailBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq,
    String.reduceEq, modelCalls, modelPrimitives, Calls.get, Field.get,
    ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  rw [workTail]
  by_cases firstZero : skipAt text position = 0
  · simp [firstZero]
  · by_cases finished : skipAt text position > text.length
    · simp [firstZero, finished]
    · have firstAdvance := skipAt_advances text position bound firstZero
      have plainDecrease : text.length + 1 - (skipAt text position + 1) <
          text.length + 1 - position := by omega
      by_cases isQuote : Cursor.byteAt text (skipAt text position) = 34
      · by_cases absent : (literalAt text (skipAt text position)).after = 0
        · simp [firstZero, finished, isQuote, absent]
        · have quotedAdvance := literalAt_advances text (skipAt text position) absent
          have quotedDecrease : text.length + 1 - (literalAt text (skipAt text position)).after <
              text.length + 1 - position := by omega
          simp [firstZero, finished, isQuote, absent, quotedDecrease]
      · by_cases isJoin : Cursor.byteAt text (skipAt text position) = 38
        · by_cases empty : remaining = 0
          · simp [firstZero, finished, isJoin, empty]
          · simp only [firstZero, finished, isJoin, empty, plainDecrease, ↓reduceIte,
              ↓reduceDIte, ne_eq, not_false_eq_true, decide_true, Bool.true_and]
            simp
        · simp only [firstZero, finished, isQuote, isJoin, plainDecrease, ↓reduceIte, ↓reduceDIte]

theorem model_tail_equation (ranges : RangeContracts modelCalls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment)
    (scan : ExpressionState) (namesValid : ValidNames text names)
    (scanValid : ValidScan text scan) :
    modelCalls.function .tail text names scan =
      tailBody.eval modelCalls (Context.locals {text,names,scan}) := by
  have nextRange := ranges.expressionStep text valid names scan namesValid scanValid
  change ValidScan text (expressionStep text names scan) ∧
    ((expressionStep text names scan).position = 0 ∨
      (expressionStep text names scan).complete = true ∨
      scan.position < (expressionStep text names scan).position) at nextRange
  change expressionTail text names scan = _
  simp only [tailBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq,
    modelCalls, Calls.get, Field.get, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  rw [expressionTail]
  by_cases zero : scan.position = 0
  · simp [zero]
  · by_cases complete : scan.complete = true
    · simp [zero, complete, ExpressionState.result]
    · by_cases nextZero : (expressionStep text names scan).position = 0
      · simp [zero, complete, nextZero]
      · by_cases nextComplete : (expressionStep text names scan).complete = true
        · simp [zero, complete, nextZero, nextComplete, ExpressionState.result]
        · have advances : scan.position < (expressionStep text names scan).position := by
            rcases nextRange.2 with bad | done | progress
            · exact False.elim (nextZero bad)
            · exact False.elim (nextComplete done)
            · exact progress
          have bounded := nextRange.1.1
          have smaller : text.length + 1 - (expressionStep text names scan).position <
              text.length + 1 - scan.position := by
            unfold ValidCursor at bounded
            omega
          simp [zero, complete, nextZero, nextComplete, smaller]

theorem model_capacity_equation (text : Source) (_valid : ValidText text)
    (state : ParserState) (stateValid : ValidState text state) :
    modelCalls.function .capacity text state =
      capacityBody.eval modelCalls (Context.locals {text,state}) := by
  by_cases zero : state.position = 0
  · simp [capacityBody, Expr.eval, Context.locals, modelCalls, modelPrimitives,
      Field.get, capacityAt, skipAt, zero]
  · have positive : Cursor.triviaPosition text state.position ≠ 0 := by
      have lower := (Cursor.triviaPosition_bounds text state.position (by omega) stateValid.1).1
      omega
    simp [capacityBody, Expr.eval, Context.locals, modelCalls, modelPrimitives,
      Field.get, capacityAt, skipAt, zero, positive]
    change _ = (if decide ((Guarded.decimalAt text (Cursor.triviaPosition text state.position)).after = 0)
      then invalidState else {state with
        position := (Guarded.decimalAt text (Cursor.triviaPosition text state.position)).after,
        capacity := (Guarded.decimalAt text (Cursor.triviaPosition text state.position)).value})
    split <;> simp_all

end Silver.Compose.Expressions
