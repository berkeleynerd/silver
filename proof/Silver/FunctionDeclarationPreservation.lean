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


def FunctionItemsUnchanged (before after : ParserState) : Prop :=
  after.position = 0 ∨ after.functions.items = before.functions.items

theorem parameterStep_items (text : Source) (state : ParserState) (arguments : Bool) :
    FunctionItemsUnchanged state (parameterStep text state arguments).state := by
  dsimp only [parameterStep]
  split
  · exact .inl rfl
  · split
    · exact .inr rfl
    · split
      · exact .inr rfl
      · exact .inl rfl

theorem parametersModel_items (text : Source) (state : ParserState) (arguments : Bool) :
    FunctionItemsUnchanged state (parametersModel text state arguments) := by
  rw [parametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have unchanged := (parameterStep_items text state arguments).resolve_left nonzero
    split
    · exact .inr unchanged
    · split
      · rename_i advanced
        rcases parametersModel_items text (parameterStep text state arguments).state arguments with rejected | preserved
        · exact .inl rejected
        · exact .inr (preserved.trans unchanged)
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

def FunctionCountStep (before after : ParserState) : Prop :=
  after.position = 0 ∨ after.functions.items.length = before.functions.items.length + 1

theorem functionBodyAt_count_or_rejected (text : Source) (outer frame : ParserState)
    (first after : Nat) (resultType : FunctionTypeResult) (arguments : Bool) :
    FunctionCountStep frame (functionBodyAt text outer frame first after resultType arguments) := by
  dsimp only [functionBodyAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · right
        simp only [FunctionBindings.append, List.length_append, List.length_singleton]

theorem functionBodyAt_count (text : Source) (outer frame : ParserState)
    (first after : Nat) (resultType : FunctionTypeResult) (arguments : Bool)
    (accepted : (functionBodyAt text outer frame first after resultType arguments).position ≠ 0) :
    (functionBodyAt text outer frame first after resultType arguments).functions.items.length =
      frame.functions.items.length + 1 :=
  (functionBodyAt_count_or_rejected text outer frame first after resultType arguments).resolve_left accepted

theorem functionDeclarationAt_count_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    FunctionCountStep state (functionDeclarationAt text state arguments) := by
  dsimp only [functionDeclarationAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · rename_i headerGood
      have unchanged := (parametersModel_items text _ arguments).resolve_left headerGood
      split
      · exact .inl rfl
      · refine Or.imp_right ?_ (functionBodyAt_count_or_rejected ..)
        intro count
        exact count.trans (congrArg (fun (items : List FunctionBindings.Signature) => items.length + 1) unchanged)

theorem functionDeclarationAt_count (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    (functionDeclarationAt text state arguments).functions.items.length = state.functions.items.length + 1 :=
  (functionDeclarationAt_count_or_rejected text state arguments).resolve_left accepted

theorem functionBodyAt_position (text : Source) (outer frame : ParserState)
    (first after : Nat) (resultType : FunctionTypeResult) (arguments : Bool) :
    (functionBodyAt text outer frame first after resultType arguments).position ≤ text.length + 1 ∧
      ((functionBodyAt text outer frame first after resultType arguments).position = 0 ∨
        outer.position < (functionBodyAt text outer frame first after resultType arguments).position) := by
  dsimp only [functionBodyAt]
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · split
    · exact ⟨Nat.zero_le _, .inl rfl⟩
    · split
      · exact ⟨Nat.zero_le _, .inl rfl⟩
      · rename_i allowed
        refine ⟨fixedAfter_result_bound text _ ";" false (by decide), .inr ?_⟩
        exact Nat.lt_of_not_ge (fun le => allowed (.inr (.inr (.inr (.inr (.inr le))))))

theorem functionDeclarationAt_position (text : Source) (state : ParserState) (arguments : Bool) :
    (functionDeclarationAt text state arguments).position ≤ text.length + 1 ∧
      ((functionDeclarationAt text state arguments).position = 0 ∨
        state.position < (functionDeclarationAt text state arguments).position) := by
  dsimp only [functionDeclarationAt]
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · split
    · exact ⟨Nat.zero_le _, .inl rfl⟩
    · split
      · exact ⟨Nat.zero_le _, .inl rfl⟩
      · exact functionBodyAt_position ..

end Silver.Compose
