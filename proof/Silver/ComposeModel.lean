module

public import Silver.ComposeSourceBridge
public import Silver.ComposeModelEquations
public import Silver.ComposeModelRanges
public import Silver.ComposeModelLegal

@[expose] public section

/-! A concrete inhabitant of the composed source-interpretation interface.
The helper equations, range contracts and executed lexical-call domains are
proved independently. Actual Ada/frontend interpretation remains the documented
premise of correspondence for arbitrary implementation callees. -/

namespace Silver.Compose.SourceBridge

theorem model_interpreted : InterpretedSource Expressions.modelCalls where
  imageLengths := by
    refine ⟨Integer.Image.Native.modelCalls, Integer.Native.Function.eval,
      Integer.Image.NativeSource.model_interpreted, ?_⟩
    intro bounds bounded
    have minimum := Integer.Image.Native.minimumLength_eq bounds bounded
    have maximum := Integer.Image.Native.maximumLength_eq bounds bounded
    change (LengthSummary.ofImage bounds).minimumLength = Integer.Image.Native.minimumLength bounds ∧
      (LengthSummary.ofImage bounds).staticLength = Integer.Image.Native.maximumLength bounds
    rw [minimum, maximum]
    unfold LengthSummary.ofImage
    split <;> exact ⟨rfl, rfl⟩
  lexical := ⟨Guarded.Expressions.modelCalls, fixedAt, rfl, Lexical.model_interpreted⟩
  definitions := (Expressions.model_definitions Expressions.model_ranges).toHelperEquations
  legal := Expressions.model_legal.toLegalHelpers
  step := by
    intro text valid form token state _ tokenValid stateValid
    exact (Expressions.model_definitions Expressions.model_ranges).step
      text valid form token state tokenValid stateValid
  stepLegal := by
    intro text valid form token state _ tokenValid stateValid
    exact Expressions.model_legal.step text valid form token state tokenValid stateValid

end Silver.Compose.SourceBridge
