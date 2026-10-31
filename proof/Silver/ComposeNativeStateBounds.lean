module

public import Silver.ComposeDeclarationBounds
public import Silver.ComposeStateBounds

@[expose] public section

/-! String metadata preservation for arbitrary native parser states. These
lemmas use the checked raw metadata fields, without a declaration-history or
runtime byte-store premise. -/
namespace Silver.Compose.Expressions
open Named Bindings

theorem model_string_declaration_bounds_of_result (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names)
    (indices : (declarationParts text state).value.firstIndex.Bounded ∧
      (declarationParts text state).value.lastIndex.Bounded) :
    NamesBoundsValid (stringDeclarationAt text state arguments).names := by
  unfold stringDeclarationAt
  generalize partsEq : declarationParts text state = parts at indices ⊢
  dsimp only
  split
  · exact namesBoundsValid_empty
  · rename_i accepted
    apply namesBoundsValid_append metadata
    have checked : fixedDeclarationBounds parts.value (state.names.length + 1) = true := by
      cases bounds : fixedDeclarationBounds parts.value (state.names.length + 1)
      · simp [bounds] at accepted
      · rfl
    simp only [fixedDeclarationBounds, Bool.and_eq_true] at checked
    exact ⟨indices.1.1, indices.2.1, checked.2⟩

theorem model_character_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (characterDeclarationAt text state arguments).names := by
  by_cases positive : (characterDeclarationAt text state arguments).position ≠ 0
  · obtain ⟨declaration, source⟩ := character_declaration_sound text state arguments positive
    exact character_declaration_bounds metadata source
  · unfold characterDeclarationAt
    dsimp only
    split
    · exact namesBoundsValid_empty
    · rename_i ready
      have readyFalse : characterDeclarationRejected text state arguments
          (characterDeclarationParts text state) = false := Bool.eq_false_iff.mpr ready
      have following : (characterDeclarationParts text state).following ≠ 0 := by
        intro zero
        simp [characterDeclarationRejected, zero] at readyFalse
      have successful : (characterDeclarationAt text state arguments).position ≠ 0 := by
        simp only [characterDeclarationAt, readyFalse, Bool.false_eq_true, ↓reduceIte, addBinding]
        exact following
      exact False.elim (positive successful)

theorem model_scalar_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (scalarDeclarationAt text state arguments).names := by
  unfold scalarDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_subtype_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (subtypeDeclarationAt text state arguments).names := by
  unfold subtypeDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_boolean_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (booleanDeclarationAt text state arguments).names := by
  unfold booleanDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · split
    · exact namesBoundsValid_empty
    · exact metadata

theorem model_array_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (arrayDeclarationAt text state arguments).names := by
  unfold arrayDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · split
    · exact namesBoundsValid_empty
    · split
      · exact namesBoundsValid_empty
      · split
        · exact namesBoundsValid_empty
        · rename_i good start positive advances
          have accepted : (arrayDeclarationAt text state arguments).position ≠ 0 := by
            simp only [arrayDeclarationAt, good, start, positive, advances, Bool.false_eq_true, ↓reduceIte]
            omega
          obtain ⟨declaration, reading⟩ := array_declaration_sound text state arguments accepted
          have preserved : NamesBoundsValid (arrayDeclarationAt text state arguments).names := by
            rw [(array_declaration_preserves reading).1]
            exact metadata
          simpa only [arrayDeclarationAt, good, start, positive, advances, Bool.false_eq_true, ↓reduceIte] using preserved

theorem model_argument_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (argumentAt text state).names := by
  unfold argumentAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · apply namesBoundsValid_append metadata
    simp [BindingInfo.BoundsValid, fixedBoundsValid, Integer.Interval.singleton,
      Integer.InRange, Integer.minValue, Integer.maxValue]

end Silver.Compose.Expressions
