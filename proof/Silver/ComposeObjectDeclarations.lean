module

public import Silver.ComposeCharacterDeclarations

@[expose] public section

namespace Silver.Compose
open Named Bindings

/-- The final two native declaration alternatives both allocate an initialized
byte-store cell, with an explicit Ada object kind in the source metadata. -/
def objectDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let character := characterDeclarationAt text state arguments
  if character.position ≠ 0 then character else stringDeclarationAt text state arguments

inductive DeclarationAt (text : Source) (arguments : Bool) : ParserState → Declaration → ParserState → Prop
  | string {state next declaration} : (characterDeclarationAt text state arguments).position = 0 →
      StringDeclarationAt text arguments state declaration next → DeclarationAt text arguments state declaration next
  | character {state next declaration} : CharacterDeclarationAt text arguments state declaration next →
      DeclarationAt text arguments state declaration next

theorem declaration_complete {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : objectDeclarationAt text state arguments = next := by
  cases parsed with
  | string noCharacter source => simp only [objectDeclarationAt, noCharacter, ne_eq, not_true_eq_false, ↓reduceIte, string_declaration_complete source]
  | character source =>
      unfold objectDeclarationAt
      rw [character_declaration_complete source]
      exact ite_eq_left (character_declaration_positive source)

theorem declaration_positive {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : next.position ≠ 0 := by
  cases parsed with
  | string _ source => exact string_declaration_positive source
  | character source => exact character_declaration_positive source

theorem declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (objectDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, DeclarationAt text arguments state declaration (objectDeclarationAt text state arguments) := by
  by_cases character : (characterDeclarationAt text state arguments).position ≠ 0
  · obtain ⟨declaration, source⟩ := character_declaration_sound text state arguments character
    refine ⟨declaration, ?_⟩
    unfold objectDeclarationAt
    rw [ite_eq_left character]
    exact DeclarationAt.character source
  · have noCharacter : (characterDeclarationAt text state arguments).position = 0 := by omega
    have stringPositive : (stringDeclarationAt text state arguments).position ≠ 0 := by
      simpa only [objectDeclarationAt, character, ↓reduceIte] using accepted
    obtain ⟨declaration, source⟩ := string_declaration_sound text state arguments stringPositive
    exact ⟨declaration, by simpa only [objectDeclarationAt, character, ↓reduceIte] using DeclarationAt.string noCharacter source⟩

theorem declaration_count {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : next.names.length = state.names.length + 1 := by
  cases parsed with
  | string _ source => cases source; simp only [addBinding, List.length_append, List.length_singleton]
  | character source => exact character_declaration_count source

theorem declaration_shape {text arguments state next declaration}
    (normal : NamesNormal state.names) (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : DeclarationAt text arguments state declaration next) :
    ∃ bound, declaration.Valid state.names.shape bound ∧ next.names.shape = declaration.extend state.names.shape bound := by
  cases parsed with
  | string _ source => exact string_declaration_shape normal static source
  | character source => exact ⟨.fixed 1, character_declaration_shape normal static source⟩

theorem declaration_normal {text arguments state next declaration}
    (normal : NamesNormal state.names) (parsed : DeclarationAt text arguments state declaration next) : NamesNormal next.names := by
  cases parsed with
  | string _ source => exact string_declaration_normal normal source
  | character source => exact character_declaration_normal normal source

theorem declaration_scalarNames {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : next.scalarNames = state.scalarNames := by
  cases parsed with
  | string _ source => exact string_declaration_scalarNames source
  | character source => exact character_declaration_scalarNames source

theorem declaration_unique {text arguments state leftState rightState left right}
    (first : DeclarationAt text arguments state left leftState)
    (second : DeclarationAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  cases first with
  | string noCharacter source =>
      cases second with
      | string _ other => exact string_declaration_unique source other
      | character other =>
          have positive := character_declaration_positive other
          rw [← character_declaration_complete other, noCharacter] at positive
          contradiction
  | character source =>
      cases second with
      | character other => exact character_declaration_unique source other
      | string noCharacter _ =>
          have positive := character_declaration_positive source
          rw [← character_declaration_complete source, noCharacter] at positive
          contradiction

end Silver.Compose
