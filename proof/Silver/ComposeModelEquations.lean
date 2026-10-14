module

public import Silver.ComposeModelRecursion
public import Silver.ComposeRecognitionEquations

@[expose] public section

/-! The concrete model satisfies the rendered helper equations. The range
contracts are supplied separately, without assuming any definition equations. -/

namespace Silver.Compose.Expressions
open Named
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000
set_option backward.dsimp.instances true

private theorem model_argument_definition (text : Source) (state : ParserState) :
    modelCalls.function .argument text state = argumentBody.eval modelCalls (Context.locals {text,state}) := by
  dsimp +instances only [modelCalls, Names.modelCalls, argumentBody, Expr.eval, Context.locals,
    Locals.set, Calls.get, Field.get, spelling, isWord]
  dsimp +instances only [argumentAt, argumentParts, argumentFirst, argumentAfter,
    argumentDefaultPosition, tokenAfter, ShellToken.symbol, ShellToken.word]
  simp [or_assoc]

theorem model_definitions (ranges : RangeContracts modelCalls) :
    DefinitionEquations modelCalls modelCalls where
  ranges := ranges.toHelperRanges
  names := Names.model_interpreted
  callAfter := by
    intros
    simp +instances [modelCalls, Names.modelCalls, Context.locals, Expr.eval, Calls.get, Locals.set,
      callAfterBody, callAfter]
  stepRange := ranges.step
  skip := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, skipBody, spelling, isWord, skipAt]
  name := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, nameBody, spelling, isWord, nameAfter]
  fixed := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, fixedBody, spelling, isWord, fixedAfter] <;> rfl

  take := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, fixedBody, spelling, isWord, fixedAfter] <;> rfl

  lookupFrom := by
    intro text valid names first after index namesValid nameValid positive bounded
    rw [show modelCalls.function .lookupFrom text names first after index = lookupFrom text names first after index from rfl,
      lookupFrom_equation text names first after index positive]
    simp +instances [lookupFromBody, Expr.eval, Context.locals, modelCalls, modelPrimitives, Calls.get, Field.get, decide_eq_true_eq]

  lookup := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, lookupBody, spelling, isWord, Bool.or_eq_true, lookupName]
  literal := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, literalBody, spelling, isWord, Bool.and_eq_true, and_assoc, literalAt]
  workTail := model_workTail_equation
  workBudget := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, workBudgetBody, spelling, isWord, withinWorkBudget]
  value := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, valueBody, spelling, isWord, valueAt]
  newName := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Field.get, newNameBody, spelling, isWord, newNameAllowed]
  addBinding := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Field.get, addBindingBody, spelling, isWord, addBinding]
  declaration := by
    intro text valid state arguments stateValid
    let first := declarationFirst text state
    let after := declarationAfter text state
    let constant := declarationConstantAfter text state
    let value := expressionAt text (declarationValuePosition text state) state.names
    let following := fixedAfter text value.after ";" false
    change
      (if !newNameAllowed text state first after arguments ||
          decide (following = 0 ∨ state.names.length = maxBindings) ||
          !fits value maxSourceLength then invalidState
        else addBinding state first after value.value (decide (constant = 0)) following) = _
    have body : declarationBody.eval modelCalls (Context.locals {text,state,arguments}) =
        (if ((!newNameAllowed text state first after arguments || decide (following = 0)) ||
            decide (state.names.length = maxBindings)) || !fits value maxSourceLength
          then invalidState
          else addBinding state first after value.value (decide (constant = 0)) following) := by
      dsimp +instances only [declarationBody, Expr.eval, Context.locals, Locals.set,
        modelCalls, Calls.get, Field.get, spelling, isWord, ShellToken.symbol, ShellToken.word]
      dsimp +instances only [first, after, constant, value, following, declarationFirst, declarationAfter,
        declarationConstantAfter, declarationColonAfter, declarationValuePosition,
        ExpressionResult.value]
      simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, Bool.or_eq_true,
        Bool.not_eq_true', decide_eq_true_eq, ne_eq, ite_not]
    rw [body]
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]
  argument := fun text _ state _ => model_argument_definition text state
  declarations := by
    intro text valid state arguments stateValid
    rw [show modelCalls.function .declarations text state arguments = declarationsAt text state arguments from rfl,
      declarationsAt_equation text state arguments stateValid.2.1.1]
    dsimp +instances only [declarationsBody, Expr.eval, Context.locals, modelCalls, Calls.get, Field.get, spelling, isWord]
    simp only [decide_eq_true_eq, ite_not]

  expressionStep := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, expressionStepBody, spelling, isWord, Bool.and_eq_true, Bool.or_eq_true, or_assoc, expressionStep, ShellToken.symbol]
  fits := by
    intro text valid result capacity resultValid bounded
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Field.get, fitsBody, spelling, isWord, fits]
    by_cases zero : result.after = 0 <;> simp [zero]
  comparison := by
    intro text valid state stateValid
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, comparisonBody, spelling, isWord, Bool.and_eq_true, Bool.or_eq_true, and_assoc, or_assoc, comparisonAt, ShellToken.symbol]
    generalize fits (expressionAt text state.position state.names) state.capacity = a
    generalize fits (expressionAt text (fixedAfter text (expressionAt text state.position state.names).after "=" false) state.names) state.capacity = b
    generalize (expressionAt text state.position state.names).namedSeen = c
    generalize (expressionAt text (fixedAfter text (expressionAt text state.position state.names).after "=" false) state.names).namedSeen = d
    cases a <;> cases b <;> cases c <;> cases d <;> rfl
  tail := model_tail_equation ranges
  expression := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, expressionBody, spelling, isWord, expressionAt]
  target := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, targetBody, spelling, isWord, Bool.and_eq_true, Bool.or_eq_true, or_assoc, targetAt]
  dynamic := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, dynamicBody, spelling, isWord, Bool.or_eq_true, or_assoc, dynamicAt]
  assignmentValue := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, assignmentBody, spelling, isWord, Bool.or_eq_true, or_assoc, assignmentAt]
  output := by
    intro text valid state stateValid
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, Locals.set, Field.get, outputBody, spelling, isWord, outputAt]
    cases fits (expressionAt text state.position state.names) state.capacity <;> rfl
  capacity := model_capacity_equation
  step := by
    intro text valid form token state tokenValid stateValid
    cases token <;> dsimp +instances only [modelCalls, Names.modelCalls, stepBody, Expr.eval, Context.locals, Calls.get, Field.get, step, spelling, isWord, BEq.beq] <;> simp only [decide_eq_true_eq, reduceCtorEq, ↓reduceIte]

  suffix := by
    intro text valid form index state stateValid positive bounded
    rw [show modelCalls.function .suffix text form index state = suffixAtIndex text form index state from rfl,
      suffixAtIndex_equation text form index state positive]
    simp +instances [suffixBody, suffixEquation, Expr.eval, Context.locals, modelCalls, modelPrimitives, Calls.get, Field.get, tokenAtIndex] <;> rfl

  readDeclarations := by
    intros
    rfl
  formMember := by
    intro text form
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, formBody, spelling, isWord, formAccepts, suffixAtIndex, Nat.lt_iff_add_one_le]
    by_cases first : 1 ≤ text.length <;> by_cases last : text.length ≤ maxSourceLength <;> simp [first, last]
  member := by
    intros
    simp +instances [modelCalls, modelPrimitives, Context.locals, Expr.eval, memberBody, spelling, isWord, accepts, selectedForm, List.isSome_find?]
  arguments := by
    intro text
    change hasArguments text = firstFlagList allForms (formAccepts text) Form.hasArguments
    exact (firstFlag_find allForms (formAccepts text) Form.hasArguments (by decide)).symm

  assignment := by
    intro text
    change hasAssignment text = firstFlagList allForms (formAccepts text) Form.hasAssignment
    exact (firstFlag_find allForms (formAccepts text) Form.hasAssignment (by decide)).symm

end Silver.Compose.Expressions
