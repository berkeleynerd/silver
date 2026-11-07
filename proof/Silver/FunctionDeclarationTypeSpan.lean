module

public import Silver.FunctionDeclarationRecursion

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions

private theorem scalarTypeAt_span (text : Source) (state : ParserState) (position : Nat) :
    (scalarTypeAt text state position).after = 0 ∨
      FunctionBindings.NameSpan text (skipAt text position) (scalarTypeAt text state position).after := by
  dsimp only [scalarTypeAt]
  split
  · exact .inl rfl
  · rename_i allowed
    have span : FunctionBindings.NameSpan text (skipAt text position) (nameAfter text (skipAt text position)) := by
      simp only [not_or] at allowed
      exact ⟨by omega, by omega, function_nameAfter_bound text _⟩
    split
    · exact .inr span
    · split
      · exact .inr span
      · exact .inl rfl

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

end Silver.Compose
