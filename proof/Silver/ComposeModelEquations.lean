module

public import Silver.ComposeModelHelperEquations
public import Silver.ComposeRecognitionEquations

@[expose] public section

/-! Assemble the concrete model helper witnesses with the mathematical fixed-form
recognizer equations. Native actual-source interpretation has separate domains. -/

namespace Silver.Compose.Expressions
open Named
set_option maxRecDepth 10000
set_option maxHeartbeats 4000000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read

private theorem model_definition_stepRange (_ranges : RangeContracts modelCalls) : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    ValidState text (modelCalls.function .step text form token state) := by
  intro text valid form token state _ stateValid
  exact model_step_valid text valid form token state stateValid

private theorem model_definition_step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    modelCalls.function .step text form token state =
      stepBody.eval modelCalls (Context.locals {text,form,token,state}) := by
  intro text valid form token state tokenValid stateValid
  cases token <;> dsimp +instances only [modelCalls, Names.modelCalls, stepBody, Expr.eval, Context.locals, Calls.get, Field.get, step, spelling, isWord, BEq.beq] <;> simp +instances only [decide_eq_true_eq, reduceCtorEq, ↓reduceIte]

private theorem model_definition_suffix : ∀ text, ValidText text → ∀ form nextToken state,
    ValidState text state → 1 ≤ nextToken → nextToken ≤ form.tokens.length + 1 →
    modelCalls.function .suffix text form nextToken state =
      suffixBody.eval modelCalls (Context.locals {text,form,nextToken,state}) := by
  intro text valid form index state stateValid positive bounded
  rw [show modelCalls.function .suffix text form index state = suffixAtIndex text form index state from rfl,
    suffixAtIndex_equation text form index state positive]
  dsimp +instances only [suffixBody, suffixEquation, Expr.eval, Context.locals, modelCalls, modelPrimitives, Calls.get, Field.get, tokenAtIndex] <;> simp +instances <;> rfl

private theorem model_definition_formMember : ∀ text form, modelCalls.function .formMember text form =
    formBody.eval modelCalls (Context.locals {text,form}) := by
  intro text form
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, Calls.get, formBody, spelling, isWord, formAccepts, suffixAtIndex] <;> simp +instances [Nat.lt_iff_add_one_le]

private theorem model_definition_member : ∀ text, modelCalls.function .member text = memberBody.eval modelCalls (Context.locals {text}) := by
  intros
  dsimp +instances only [modelCalls, modelPrimitives, Context.locals, Expr.eval, memberBody, spelling, isWord, accepts, selectedForm] <;> simp +instances [List.isSome_find?]

private theorem model_definition_arguments : ∀ text, modelCalls.function .arguments text = argumentsBody.eval modelCalls (Context.locals {text}) := by
  intro text
  change hasArguments text = firstFlagList allForms (formAccepts text) Form.hasArguments
  exact (firstFlag_find allForms (formAccepts text) Form.hasArguments (by decide)).symm

private theorem model_definition_assignment : ∀ text, modelCalls.function .assignment text = assignmentSelectorBody.eval modelCalls (Context.locals {text}) := by
  intro text
  change hasAssignment text = firstFlagList allForms (formAccepts text) Form.hasAssignment
  exact (firstFlag_find allForms (formAccepts text) Form.hasAssignment (by decide)).symm

theorem model_definitions (ranges : RangeContracts modelCalls) :
    DefinitionEquations modelCalls modelCalls where
  toHelperEquations := model_helpers ranges
  legacy := {
    argument := by intros; rfl
    declarations := by intros; rfl
    target := by intros; rfl
    dynamic := by intros; rfl
    assignmentValue := by intros; rfl
    output := by intros; rfl
    comparison := by intros; rfl
    capacity := by intros; rfl }
  stepRange := model_definition_stepRange ranges
  step := model_definition_step
  suffix := model_definition_suffix
  formMember := model_definition_formMember
  member := model_definition_member
  arguments := model_definition_arguments
  assignment := model_definition_assignment

end Silver.Compose.Expressions
