module

public import Silver.FunctionDeclarationPreservation

@[expose] public section

namespace Silver.Compose

/-- Named array types and completed callables supply the native operation-hiding inventory.
Order within this list has no effect on the exact name-membership predicate. -/
def declarationHidingNames (state : ParserState) : List (Nat × Nat) :=
  state.arrayNames.types.map (fun item => (item.first, item.after)) ++
    state.functions.items.map (fun item => (item.first, item.after)) ++
    state.procedures.items.map (fun item => (item.first, item.after))

/-- A completed function adds its actual name to the same hiding inventory as
completed procedures; pending formal names remain local to the function frame. -/
theorem functionBodyAt_hiding_or_rejected {text : Source} {outer frame : ParserState}
    {first after : Nat} {resultType : FunctionTypeResult} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text outer.subtypeNames (declarationHidingNames outer))
    (sameItems : frame.functions.items = outer.functions.items) :
    (functionBodyAt text outer frame first after resultType arguments).position = 0 ∨
      IntegerSubtypes.HidingCorrect text
        (functionBodyAt text outer frame first after resultType arguments).subtypeNames
        (declarationHidingNames (functionBodyAt text outer frame first after resultType arguments)) := by
  dsimp only [functionBodyAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · right
        intro operation
        simpa [declarationHidingNames, FunctionBindings.append, sameItems, List.any_append,
          Bool.or_assoc, Bool.or_left_comm, Bool.or_comm] using
          IntegerSubtypes.hiding_add_other correct first after operation

theorem functionDeclarationAt_hiding_or_rejected {text : Source} {state : ParserState} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames (declarationHidingNames state)) :
    (functionDeclarationAt text state arguments).position = 0 ∨
      IntegerSubtypes.HidingCorrect text (functionDeclarationAt text state arguments).subtypeNames
        (declarationHidingNames (functionDeclarationAt text state arguments)) := by
  dsimp only [functionDeclarationAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · rename_i headerGood
      have unchanged := (parametersModel_items text _ arguments).resolve_left headerGood
      split
      · exact .inl rfl
      · exact functionBodyAt_hiding_or_rejected correct unchanged

theorem functionDeclarationAt_hiding {text : Source} {state : ParserState} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames (declarationHidingNames state))
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    IntegerSubtypes.HidingCorrect text (functionDeclarationAt text state arguments).subtypeNames
      (declarationHidingNames (functionDeclarationAt text state arguments)) :=
  (functionDeclarationAt_hiding_or_rejected correct).resolve_left accepted

end Silver.Compose
