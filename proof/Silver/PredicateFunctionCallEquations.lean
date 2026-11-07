module

public import Silver.PredicateFunctionCallNative

@[expose] public section

namespace Silver.Predicate.FunctionCallNative
open Compose FunctionBindings

set_option maxRecDepth 4096
set_option maxHeartbeats 1000000

def callScope : Scope := [("text", 5), ("context", 6), ("position", 0), ("facts", 7), ("catalog", 8)]

abbrev CheckedTrees : Prop :=
  actualBody.wellFormed = true ∧ actualBody.scoped (("parameter", 3) :: callScope) = true ∧
  actualsBody.wellFormed = true ∧ actualsBody.scoped (("first", 0) :: ("last", 0) :: callScope) = true ∧
  calleeBody.wellFormed = true ∧ calleeBody.scoped callScope = true ∧
  callBody.wellFormed = true ∧ callBody.scoped callScope = true ∧
  assignmentResultBody.wellFormed = true ∧
    assignmentResultBody.scoped [("context", 6), ("scan", 9), ("scalar", 0), ("flag", 0), ("value", 2)] = true ∧
  (assignmentBody false).wellFormed = true ∧ (assignmentBody true).wellFormed = true ∧
  (assignmentBody false).scoped [("text", 5), ("context", 6), ("scan", 9), ("catalog", 8)] = true ∧
  (assignmentBody true).scoped [("text", 5), ("context", 6), ("scan", 9), ("catalog", 8)] = true

theorem checked_trees : CheckedTrees := by decide +kernel

/-- Unparenthesized right-associated adding trees and conditional operands are
rejected before their token rendering can support correspondence. -/
theorem subtraction_association_guard :
    (Expr.sub (.number 10) (.sub (.number 3) (.number 2))).wellFormed = false := by decide +kernel

theorem conditional_operand_guard :
    (Expr.add (.ite (.eq (.number 0) (.number 0)) (.number 1) (.number 2)) (.number 3)).wellFormed = false := by decide +kernel

theorem wrong_value_kind_guard :
    (Expr.letValue (.readScalar .position) (.callAfter .called)).scoped callScope = false := by decide +kernel

theorem actual_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (parameter : Formal) :
    actualBody.eval modelImports modelCalls {text, context, position, facts, parameter} =
      actualAfter text context.model position facts parameter := by
  simp only [actualBody, Expr.eval, modelImports, actualAfter,
    Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq]

theorem actuals_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) (first last : Nat) (ordered : first ≤ last) :
    actualsBody.eval modelImports modelCalls {text, context, position, facts, catalog, first, last} =
      actualsAfter text context.model position facts catalog first last := by
  rw [actualsAfter]
  dsimp only [actualsBody, Expr.eval, modelImports, modelCalls, tokenAfter, ShellToken.symbol]
  by_cases zero : actualAfter text context.model position facts (parameter catalog first) = 0
  · simp only [zero, decide_true, ↓reduceIte]
  · by_cases final : first = last
    · simp only [zero, final, decide_true, decide_false, Bool.false_eq_true, ↓reduceIte]
    · have advancing : first < last := by omega
      simp only [zero, final, advancing, decide_false, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte]

theorem callee_model (text : Source) (context : Native.Context) (position : Nat)
    (catalog : Metadata) :
    calleeBody.eval modelImports modelCalls {text, context, position, catalog} =
      calleeAt text context.model position catalog := by
  simp only [calleeBody, Expr.eval, modelImports, calleeAt, Native.Context.model,
    Bool.or_eq_true, decide_eq_true_eq]

theorem call_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) :
    callBody.eval modelImports modelCalls {text, context, position, facts, catalog} =
      Predicate.readCall text context.model position facts catalog := by
  simp only [callBody, Expr.eval, modelImports, modelCalls, Predicate.readCall,
    tokenAfter, ShellToken.symbol, decide_eq_true_eq]

theorem assignmentResult_model (context : Native.Context) (scan : BodyScan)
    (scalar flag : Nat) (called : CallResult) :
    assignmentResultBody.eval modelImports modelCalls {context, scan, scalar, flag, called} =
      callAssignmentResult context.model scan scalar flag called := by
  simp only [assignmentResultBody, Expr.eval, modelImports, callAssignmentResult,
    Native.Context.model, Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq]

theorem assignment_model (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : Metadata) (native : Bool) :
    (assignmentBody native).eval modelImports modelCalls {text, context, scan, catalog} =
      callAssignmentBody text context.model scan catalog := by
  cases native <;> rfl

end Silver.Predicate.FunctionCallNative
