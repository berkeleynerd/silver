module

public import Silver.FunctionDeclarationAdmission

@[expose] public section

namespace Silver.Compose

/-- The declaration introduces callable metadata and hiding flags. Every outer
object and initializer binding remains exactly the caller's declaration frame. -/
structure FunctionOuterPreserved (before after : ParserState) : Prop where
  names : after.names = before.names
  scalarNames : after.scalarNames = before.scalarNames
  booleanNames : after.booleanNames = before.booleanNames
  arrayNames : after.arrayNames = before.arrayNames
  dynamicFirst : after.dynamicFirst = before.dynamicFirst
  dynamicAfter : after.dynamicAfter = before.dynamicAfter
  target : after.target = before.target
  capacity : after.capacity = before.capacity
  subtypeItems : after.subtypeNames.items = before.subtypeNames.items
  subtypeTrueHidden : after.subtypeNames.trueHidden = before.subtypeNames.trueHidden
  subtypeFalseHidden : after.subtypeNames.falseHidden = before.subtypeNames.falseHidden
  pure : after.pure = before.pure
  firstParameter : after.firstParameter = before.firstParameter

theorem functionBodyAt_outer_or_rejected (text : Source) (outer frame : ParserState)
    (first after : Nat) (resultType : FunctionTypeResult) (arguments : Bool) :
    (functionBodyAt text outer frame first after resultType arguments).position = 0 ∨
      FunctionOuterPreserved outer (functionBodyAt text outer frame first after resultType arguments) := by
  dsimp only [functionBodyAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · exact .inr ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem functionDeclarationAt_outer_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    (functionDeclarationAt text state arguments).position = 0 ∨
      FunctionOuterPreserved state (functionDeclarationAt text state arguments) := by
  dsimp only [functionDeclarationAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · exact functionBodyAt_outer_or_rejected ..

theorem functionDeclarationAt_preserves_outer (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    FunctionOuterPreserved state (functionDeclarationAt text state arguments) :=
  (functionDeclarationAt_outer_or_rejected text state arguments).resolve_left accepted

end Silver.Compose
