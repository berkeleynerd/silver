module

public import Silver.ScalarExpressionNativeEquations
public import Silver.ScalarExpressionSourceChecks

@[expose] public section

/-! Actual-source scalar-expression correspondence. The interpreted bodies
leave every call arbitrary; imported helper meanings and exact native
refinements identify the implementation by well-founded uniqueness. -/
namespace Silver.ScalarExpression.SourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  primitives : Native.Primitives calls
  definitions : Native.Equations calls

theorem interpreted_readExpression (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter) :
    calls.readExpression text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign :=
  Native.interpreted_readExpression calls source.primitives source.definitions
    text valid position names maskFirst maskAfter allowSign bound environment mask

theorem interpreted_lookup (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (names : Environment)
    (environment : ValidEnvironment text names) (first after : Nat)
    (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names first after :=
  Native.interpreted_lookup calls source.primitives source.definitions
    text valid names environment first after firstBound afterBound

theorem interpreted_admission (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (result : Result) :
    (∃ expression, At text names position expression result maskFirst maskAfter allowSign) ↔
      calls.readExpression text position names maskFirst maskAfter allowSign = result ∧ result.after ≠ 0 := by
  rw [interpreted_readExpression calls source text valid position names maskFirst maskAfter allowSign bound environment mask]
  exact admission_iff bound

theorem interpreted_safe (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1)
    (environment : ValidEnvironment text names) (mask : ValidMask text maskFirst maskAfter)
    (values : Integer.Store) (fits : Integer.Fits (ranges names) values)
    (success : (calls.readExpression text position names maskFirst maskAfter allowSign).after ≠ 0) :
    ∃ expression : Integer.Expr, expression.Safe values ∧
      (calls.readExpression text position names maskFirst maskAfter allowSign).bounds.Contains
        (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  rw [interpreted_readExpression calls source text valid position names maskFirst maskAfter allowSign bound environment mask] at success ⊢
  exact read_safe success fits

theorem model_interpreted : InterpretedSource Native.modelCalls :=
  ⟨Native.model_primitives, Native.model_equations⟩

theorem actual_source_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, Native.ValidText text → ∀ position names maskFirst maskAfter allowSign,
      position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
      calls.readExpression text position names maskFirst maskAfter allowSign =
        read text position names maskFirst maskAfter allowSign :=
  ⟨SourceChecks.checked_source, interpreted_readExpression⟩

end Silver.ScalarExpression.SourceBridge
