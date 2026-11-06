module

public import Silver.ComposeStringDeclarations
public import Silver.ComposeCharacterProperties

@[expose] public section

namespace Silver.Compose
open Named Bindings

inductive CharacterDeclarationAt (text : Source) (arguments : Bool) : ParserState → Declaration → ParserState → Prop
  | declaration {state : ParserState} {parts : CharacterDeclarationParts} {value : Character.Expr} :
      characterDeclarationParts text state = parts →
      characterDeclarationRejected text state arguments parts = false → parts.following ≠ 0 →
      CharacterAt text state.names state.scalarNames state.arrayNames.names state.arrayNames.values true
        (fixedAfter text parts.typeAfter ":=" false) value parts.value →
      CharacterDeclarationAt text arguments state
        ⟨state.names.length + 1, decide (parts.constantAfter = 0),
          Expression.freezeImages [Value.character value] (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩
        (addBinding state parts.first parts.after parts.value (decide (parts.constantAfter = 0)) parts.following true)

theorem character_declaration_complete {text arguments state next declaration}
    (parsed : CharacterDeclarationAt text arguments state declaration next) :
    characterDeclarationAt text state arguments = next := by
  cases parsed with
  | declaration parts ready _ _ => simp only [characterDeclarationAt, parts, ready, Bool.false_eq_true, ↓reduceIte]

theorem character_declaration_positive {text arguments state next declaration}
    (parsed : CharacterDeclarationAt text arguments state declaration next) : next.position ≠ 0 := by
  cases parsed with
  | declaration _ _ positive _ => exact positive

theorem character_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (characterDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, CharacterDeclarationAt text arguments state declaration (characterDeclarationAt text state arguments) := by
  generalize partsEq : characterDeclarationParts text state = parts
  have observed : characterDeclarationAt text state arguments =
      if characterDeclarationRejected text state arguments parts then invalidState
      else addBinding state parts.first parts.after parts.value (decide (parts.constantAfter = 0)) parts.following true := by
    simp only [characterDeclarationAt, partsEq]
  have ready : characterDeclarationRejected text state arguments parts = false := by
    cases rejected : characterDeclarationRejected text state arguments parts with
    | false => rfl
    | true => simp [observed, rejected, invalidState] at accepted
  have following : parts.following ≠ 0 := by simpa only [observed, ready, Bool.false_eq_true, ↓reduceIte, addBinding] using accepted
  have finish : parts.following = fixedAfter text parts.value.after ";" false := by
    rw [← partsEq]
    rfl
  have valueEq : parts.value = characterAt text (fixedAfter text parts.typeAfter ":=" false)
      state.names state.scalarNames state.arrayNames.names state.arrayNames.values true := by
    rw [← partsEq]
    rfl
  have valuePositive : parts.value.after ≠ 0 := fixedAfter_nonzero (finish ▸ following)
  rw [valueEq] at valuePositive
  obtain ⟨value, source⟩ := character_sound _ valuePositive
  refine ⟨⟨state.names.length + 1, decide (parts.constantAfter = 0),
    Expression.freezeImages [Value.character value]
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩, ?_⟩
  rw [observed]
  simp only [ready, Bool.false_eq_true, ↓reduceIte]
  exact .declaration partsEq ready following (valueEq.symm ▸ source)

theorem character_declaration_normal {text arguments state next declaration}
    (normal : NamesNormal state.names)
    (parsed : CharacterDeclarationAt text arguments state declaration next) : NamesNormal next.names := by
  cases parsed with
  | declaration _ _ _ source =>
      have metadata := character_metadata source
      apply namesNormal_append (slot := state.names.length + 1) normal
      simp [fixedBoundsValid, metadata.1, metadata.2.2.1,
        metadata.2.2.2.2.1, metadata.2.2.2.2.2, Integer.Interval.singleton]

theorem character_declaration_shape {text arguments state next declaration}
    (normal : NamesNormal state.names) (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : CharacterDeclarationAt text arguments state declaration next) :
    declaration.Valid state.names.shape (.fixed 1) ∧
      next.names.shape = declaration.extend state.names.shape (.fixed 1) := by
  cases parsed with
  | declaration _ _ _ source =>
      have known := characterExpression_inferLength normal source
      have scalars := frozenIntegers_fits (arrays := state.arrayNames.names) (initials := state.arrayNames.values) static
      have safe := characterExpression_frozen_safe normal source scalars
      have summary := Expression.freezeImages_summary known (show (⟨1, 1, 0, false⟩ : LengthSummary).exact = some ⟨1, 0⟩ from by decide) scalars
      have metadata := character_metadata source
      refine ⟨⟨environment_fresh _, Expression.infer_iff.mpr ⟨safe.1, summary⟩,
        safe.2.1, safe.2.2.1, safe.2.2.2.1, by decide⟩, ?_⟩
      simp only [addBinding, environment_append, Declaration.extend, BindingInfo.cell, BindingInfo.bound,
        metadata.1, metadata.2.2.1, Bool.false_eq_true, ↓reduceIte]

theorem character_declaration_scalarNames {text arguments state next declaration}
    (parsed : CharacterDeclarationAt text arguments state declaration next) : next.scalarNames = state.scalarNames := by
  cases parsed
  rfl

theorem character_declaration_count {text arguments state next declaration}
    (parsed : CharacterDeclarationAt text arguments state declaration next) : next.names.length = state.names.length + 1 := by
  cases parsed
  simp only [addBinding, List.length_append, List.length_singleton]

theorem character_declaration_unique {text arguments state leftState rightState left right}
    (first : CharacterDeclarationAt text arguments state left leftState)
    (second : CharacterDeclarationAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  have states := (character_declaration_complete first).symm.trans (character_declaration_complete second)
  refine ⟨?_, states⟩
  cases first with
  | declaration parts _ _ source =>
      cases second with
      | declaration otherParts _ _ otherSource =>
          have same := parts.symm.trans otherParts
          cases same
          obtain ⟨rfl, _⟩ := character_unique source otherSource
          rfl

end Silver.Compose
