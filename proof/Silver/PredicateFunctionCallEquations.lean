module

public import Silver.PredicateFunctionCallNative

@[expose] public section

namespace Silver.Predicate.FunctionCallNative
open Compose FunctionBindings

set_option backward.dsimp.instances true
set_option maxRecDepth 4096
set_option maxHeartbeats 1000000

def callScope : Scope := [("text", 5), ("context", 6), ("position", 0), ("facts", 7), ("catalog", 8)]

abbrev CheckedTrees : Prop :=
  includedBody.wellFormed = true ∧ includedBody.scoped [("value", 10), ("bounds", 10)] = true ∧
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

theorem included_model (left right : Integer.Interval) :
    includedBody.eval modelImports modelCalls {intervalValue := left, intervalBounds := right} =
      left.included right := by
  apply Bool.eq_iff_iff.mpr
  dsimp +instances only [includedBody, Expr.eval, modelImports, Integer.Interval.included, Integer.Interval.isEmpty]
  simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, decide_eq_false_iff_not]
  omega

theorem actual_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (parameter : Formal) :
    actualBody.eval modelImports modelCalls {text, context, position, facts, parameter} =
      actualAfter text context.model position facts parameter := by
  dsimp +instances only [actualBody, Expr.eval, modelImports, actualAfter]
  simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, or_assoc]

theorem actuals_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) (first last : Nat) (ordered : first ≤ last) :
    actualsBody.eval modelImports modelCalls {text, context, position, facts, catalog, first, last} =
      actualsAfter text context.model position facts catalog first last := by
  rw [actualsAfter]
  dsimp +instances only [actualsBody, Expr.eval, modelImports, modelCalls, tokenAfter, ShellToken.symbol]
  by_cases zero : actualAfter text context.model position facts (parameter catalog first) = 0
  · simp_all +instances
  · by_cases final : first = last
    · simp_all +instances
    · have advancing : first < last := by omega
      by_cases comma : fixedAfter text
          (actualAfter text context.model position facts (parameter catalog first)) "," false = 0
      · simp_all +instances [actualsAfter_zero]
      · simp_all +instances

theorem callee_model (text : Source) (context : Native.Context) (position : Nat)
    (catalog : Metadata) :
    calleeBody.eval modelImports modelCalls {text, context, position, catalog} =
      calleeAt text context.model position catalog := by
  dsimp +instances only [calleeBody, Expr.eval, modelImports, calleeAt, Native.Context.model]
  simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]

theorem call_model (text : Source) (context : Native.Context) (position : Nat)
    (facts : ActiveFlow) (catalog : Metadata) :
    callBody.eval modelImports modelCalls {text, context, position, facts, catalog} =
      Predicate.readCall text context.model position facts catalog := by
  dsimp +instances only [callBody, Expr.eval, modelImports, modelCalls, Predicate.readCall,
    tokenAfter, ShellToken.symbol]
  simp only [decide_eq_true_eq]

theorem assignmentResult_model (context : Native.Context) (scan : BodyScan)
    (scalar flag : Nat) (called : CallResult) :
    assignmentResultBody.eval modelImports modelCalls {context, scan, scalar, flag, called} =
      callAssignmentResult context.model scan scalar flag called := by
  dsimp +instances only [assignmentResultBody, Expr.eval, modelImports, callAssignmentResult,
    Native.Context.model]
  simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, and_assoc, or_assoc]

theorem assignment_model (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : Metadata) (native : Bool) :
    (assignmentBody native).eval modelImports modelCalls {text, context, scan, catalog} =
      callAssignmentBody text context.model scan catalog := by
  cases native <;> rfl

end Silver.Predicate.FunctionCallNative
