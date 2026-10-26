module

public import Silver.PredicateOuterEquations
public import Silver.PredicateAdapter
public import Silver.ComposeModelEquations
public import Silver.ComposeModelRanges
public import Silver.PredicateInheritedReady

@[expose] public section
namespace Silver.Predicate.Outer
open Compose
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- The concrete witness for the outer scanner; body calls remain separately
justified by their own equations and interpretation witness. -/
def modelCalls : Calls where
  helpers := Compose.Expressions.modelCalls
  body := BodyNative.modelCalls
  readStatements := Adapter.adapterEval BodyNative.modelCalls
  scanStep := Predicate.scanStep
  suffix := fun text form index scan => scanSuffix text form (form.tokens.drop (index - 1)) scan
  formResult := Predicate.formResult
  member := accepts
  arguments := hasArguments
  assignment := hasAssignment
  output := hasOutput

theorem model_helpers : HelperMeaning modelCalls where
  equations := Compose.SourceBridge.interpreted_equations Compose.Expressions.modelCalls InheritedReady.model_interpreted
  step _ _ _ _ _ _ _ := rfl
  trivia _ _ _ _ _ := rfl

theorem model_body : BodyMeaning modelCalls where
  statements text _ scan _ := Adapter.model_adapter text scan

theorem model_ranges : RangeContracts modelCalls where
  step text tv form token scan _ sv := by
    cases token with
    | helper token => exact OuterReadiness.step_valid text tv form.helper token scan.state sv
    | statements => exact Adapter.readStatements_valid text tv scan sv

theorem model_suffix (text : Source) (form : Form) (index : Nat) (scan : ScanResult)
    (first : 1 ≤ index) :
    modelCalls.suffix text form index scan = suffixBody.eval modelCalls {text,scan,form,nextToken := index} := by
  dsimp +instances only [suffixBody, Expr.eval, Condition.eval, IndexRef.eval, modelCalls,
    Compose.Expressions.modelCalls, Compose.Expressions.modelPrimitives]
  simp only [decide_eq_true_eq]
  by_cases zero : scan.state.position = 0
  · cases form.tokens.drop (index - 1) <;> simp +instances [scanSuffix, zero]
  · simp +instances only [zero, ↓reduceIte]
    by_cases finished : index > form.tokens.length
    · have enough : form.tokens.length ≤ index - 1 := by omega
      simp +instances [finished, List.drop_eq_nil_of_le enough, scanSuffix, zero]
    · have present : index - 1 < form.tokens.length := by omega
      have drop := List.drop_eq_getElem_cons present
      have next : index - 1 + 1 = index := by omega
      simp +instances only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, scanSuffix, next,
        List.getD, List.getElem?_eq_getElem present, Option.getD_some]
      simp +instances [zero]


theorem model_definitions : DefinitionEquations modelCalls where
  ranges := model_ranges
  step text _ form token scan _ _ := by
    cases token with
    | helper token => rfl
    | statements => exact (Adapter.model_adapter text scan).symm
  suffix text _ form index scan _ first _ := model_suffix text form index scan first
  formResult text form := by
    simp +instances [modelCalls, formBody, Expr.eval, Condition.eval, Predicate.formResult,
      Compose.Expressions.modelCalls]
  member text := by
    simp only [modelCalls, MembershipBody.eval, memberBody, accepts, selectedForm,
      List.isSome_find?, Bool.and_true]
    rfl
  arguments _ := rfl
  assignment _ := rfl
  output _ := rfl

end Silver.Predicate.Outer
