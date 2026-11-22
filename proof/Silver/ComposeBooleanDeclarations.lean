module

public import Silver.ComposeAdmission

@[expose] public section

/-! The low declaration projection records the actual Boolean recognizer.
Its semantic condition and original obligation trace are reconstructed later,
after the common declaration reading is available. No proof success is an
admission premise. -/
namespace Silver.Compose

inductive BooleanDeclarationAt (text : Source) (arguments : Bool) : ParserState → ParserState → Prop
  | declaration {state : ParserState} :
      booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true →
      state.position < booleanDeclarationFollowing text state →
      BooleanDeclarationAt text arguments state
        (addBooleanBinding state (booleanDeclarationParts text state) (booleanDeclarationFollowing text state))

theorem boolean_declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    (parsed : BooleanDeclarationAt text arguments state next) :
    booleanDeclarationAt text state arguments = next := by
  cases parsed with
  | declaration ready advance =>
      simp only [booleanDeclarationAt, ready, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        Nat.not_le.mpr advance]

theorem boolean_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (booleanDeclarationAt text state arguments).position ≠ 0) :
    BooleanDeclarationAt text arguments state (booleanDeclarationAt text state arguments) := by
  unfold booleanDeclarationAt at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i ready
    have good : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true := by
      cases value : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) <;> simp_all
    split at accepted
    · contradiction
    · rename_i forward
      simpa only [good, Bool.not_true, Bool.false_eq_true, ↓reduceIte, forward] using
        BooleanDeclarationAt.declaration good (Nat.lt_of_not_ge forward)

theorem boolean_declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    (parsed : BooleanDeclarationAt text arguments state next) : next.position ≠ 0 := by
  cases parsed with
  | declaration _ advance => exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advance)

theorem boolean_declaration_progress {text : Source} {arguments : Bool} {state next : ParserState}
    (parsed : BooleanDeclarationAt text arguments state next) : state.position < next.position := by
  cases parsed with
  | declaration _ advance => exact advance

theorem boolean_declaration_unique {text : Source} {arguments : Bool} {state left right : ParserState}
    (first : BooleanDeclarationAt text arguments state left)
    (second : BooleanDeclarationAt text arguments state right) : left = right :=
  (boolean_declaration_complete first).symm.trans (boolean_declaration_complete second)

theorem boolean_declaration_preserves {text : Source} {arguments : Bool} {state next : ParserState}
    (parsed : BooleanDeclarationAt text arguments state next) :
    next.names = state.names ∧ next.scalarNames = state.scalarNames ∧
      next.arrayNames = state.arrayNames ∧ next.subtypeNames = state.subtypeNames ∧
      next.capacity = state.capacity ∧ next.target = state.target ∧
      next.dynamicFirst = state.dynamicFirst ∧ next.dynamicAfter = state.dynamicAfter := by
  cases parsed
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem boolean_declaration_bindings {text : Source} {arguments : Bool} {state next : ParserState}
    (parsed : BooleanDeclarationAt text arguments state next) :
    next.booleanNames = state.booleanNames ++
      [{first := (booleanDeclarationParts text state).first, after := (booleanDeclarationParts text state).after, mutable := decide ((booleanDeclarationParts text state).constantAfter = 0)}] := by
  cases parsed
  rfl

theorem boolean_declaration_value_positive {text : Source} {arguments : Bool} {state next : ParserState}
    (parsed : BooleanDeclarationAt text arguments state next) :
    (booleanDeclarationValue text state).after ≠ 0 := by
  cases parsed with
  | declaration _ advance =>
      intro zero
      simp only [booleanDeclarationFollowing, zero, fixedAfter, ↓reduceIte] at advance
      omega

end Silver.Compose
