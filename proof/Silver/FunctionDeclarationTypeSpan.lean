module

public import Silver.FunctionDeclarationRecursion

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions

private theorem scalarTypeAt_span (text : Source) (state : ParserState) (position : Nat) :
    (scalarTypeAt text state position).after = 0 ∨
      FunctionBindings.NameSpan text (skipAt text position) (scalarTypeAt text state position).after := by
  rcases scalarTypeAt_after text state position with failed | reading
  · exact .inl failed
  · by_cases empty : (QualifiedNames.read text position).after = 0
    · exact .inl (reading.trans empty)
    · apply Or.inr
      rw [reading]
      have validFirst : ¬ (QualifiedNames.skip text position = 0 ∨
          QualifiedNames.nameAfter text (QualifiedNames.skip text position) ≤ QualifiedNames.skip text position) := by
        intro rejected
        exact empty (by simp [QualifiedNames.read, rejected])
      have firstBound := QualifiedNames.nameAfter_bounds text (QualifiedNames.skip text position)
      have success := QualifiedNames.read_success text (QualifiedNames.skip text position)
        (by omega) (by rwa [QualifiedNames.read_skipped])
      rw [QualifiedNames.read_skipped] at success
      exact ⟨show 0 < QualifiedNames.skip text position by omega, success.2.2.1, success.2.2.2⟩

theorem functionTypeAt_span (text : Source) (state : ParserState) (position : Nat)
    (positionBound : ValidCursor text position) :
    (functionTypeAt text state position).after = 0 ∨
      FunctionBindings.NameSpan text (skipAt text position) (functionTypeAt text state position).after := by
  dsimp only [functionTypeAt]
  split
  · rename_i accepted
    exact .inr ((scalarTypeAt_span text state position).resolve_left accepted)
  · split
    · exact .inl rfl
    · rename_i allowed
      have nonzero : fixedAfter text (skipAt text position) "boolean" true ≠ 0 :=
        fun zero => allowed (.inl zero)
      have firstNonzero : skipAt text position ≠ 0 := by
        intro zero
        apply nonzero
        simp [zero, fixedAfter]
      exact .inr ⟨by omega,
        model_fixed_advances text _ "boolean" true (model_skip_valid text position positionBound) (by decide) nonzero,
        fixedAfter_result_bound text _ "boolean" true (by decide)⟩

theorem formalTypeAt_span (text : Source) (state : ParserState) (position : Nat)
    (positionBound : ValidCursor text position) :
    (formalTypeAt text state position).after = 0 ∨
      FunctionBindings.NameSpan text (skipAt text position) (formalTypeAt text state position).after := by
  dsimp only [formalTypeAt]
  split
  · exact functionTypeAt_span text state position positionBound
  · rename_i nominal
    have name : 0 < skipAt text position ∧
        skipAt text position < nameAfter text (skipAt text position) := by
      dsimp only [arrayTypeAt] at nominal
      split at nominal
      · exact False.elim (nominal rfl)
      · rename_i accepted
        simp only [not_or] at accepted
        omega
    exact .inr ⟨name.1, name.2, function_nameAfter_bound text _⟩

end Silver.Compose
