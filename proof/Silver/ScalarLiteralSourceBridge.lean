module

public import Silver.ScalarLiteralSourceChecks

@[expose] public section

/-! Actual-source integer-literal correspondence. The frontend interprets the
checked expression bodies and ranges; GNATprove establishes the checked native
Read_Integer postcondition. Neither premise assumes grammar correctness. -/
namespace Silver.ScalarLiteral.SourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  definitions : Native.Equations calls

structure ExecutableRefinement (calls : Native.Calls) (runtime : Source → Nat → Result) : Prop where
  result : ∀ text, Native.ValidText text → ∀ position, position ≤ text.length + 1 →
    runtime text position = calls.model text position

theorem interpreted_model (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (positionBound : position ≤ text.length + 1) :
    calls.model text position = read text position :=
  Native.interpreted_model calls source.definitions text valid position positionBound

theorem executable_correspondence (calls : Native.Calls) (source : InterpretedSource calls)
    (runtime : Source → Nat → Result) (refinement : ExecutableRefinement calls runtime)
    (text : Source) (valid : Native.ValidText text) (position : Nat) (positionBound : position ≤ text.length + 1) :
    runtime text position = read text position :=
  Native.executable_refinement calls source.definitions runtime refinement.result text valid position positionBound

theorem executable_grammar (calls : Native.Calls) (source : InterpretedSource calls)
    (runtime : Source → Nat → Result) (refinement : ExecutableRefinement calls runtime)
    (text : Source) (valid : Native.ValidText text) (position value finish : Nat)
    (positionBound : position ≤ text.length + 1) :
    IntegerAt text position value finish ↔ runtime text position = ⟨finish, value⟩ ∧ finish ≠ 0 := by
  rw [executable_correspondence calls source runtime refinement text valid position positionBound]
  exact integer_iff_read positionBound

theorem actual_source_correspondence : CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text, Native.ValidText text → ∀ position,
      position ≤ text.length + 1 → calls.model text position = read text position :=
  ⟨checked_source, interpreted_model⟩

/-- The native body equations and runtime refinement admit a concrete witness. -/
theorem model_interpreted : InterpretedSource Native.modelCalls := ⟨Native.model_equations⟩

theorem model_executable : ExecutableRefinement Native.modelCalls read where
  result _ _ _ _ := rfl

end Silver.ScalarLiteral.SourceBridge
