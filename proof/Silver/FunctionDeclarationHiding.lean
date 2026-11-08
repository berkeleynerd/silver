module

public import Silver.FunctionDeclarationPreservation

@[expose] public section

namespace Silver.Compose

/-- Completed function names extend the exact operation-hiding inventory;
pending formal names remain local to the function frame. -/
theorem functionBodyAt_hiding_or_rejected {text : Source} {outer frame : ParserState}
    {first after : Nat} {resultType : FunctionTypeResult} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text outer.subtypeNames
      (outer.functions.items.map (fun item => (item.first, item.after))))
    (sameItems : frame.functions.items = outer.functions.items) :
    (functionBodyAt text outer frame first after resultType arguments).position = 0 ∨
      IntegerSubtypes.HidingCorrect text
        (functionBodyAt text outer frame first after resultType arguments).subtypeNames
        ((functionBodyAt text outer frame first after resultType arguments).functions.items.map
          (fun item => (item.first, item.after))) := by
  dsimp only [functionBodyAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · refine .inr ?_
        simpa only [FunctionBindings.append, List.map_append, List.map_cons,
          List.map_nil, sameItems] using IntegerSubtypes.hiding_add_other correct first after

theorem functionDeclarationAt_hiding_or_rejected {text : Source} {state : ParserState} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (state.functions.items.map (fun item => (item.first, item.after)))) :
    (functionDeclarationAt text state arguments).position = 0 ∨
      IntegerSubtypes.HidingCorrect text (functionDeclarationAt text state arguments).subtypeNames
        ((functionDeclarationAt text state arguments).functions.items.map
          (fun item => (item.first, item.after))) := by
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
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (state.functions.items.map (fun item => (item.first, item.after))))
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    IntegerSubtypes.HidingCorrect text (functionDeclarationAt text state arguments).subtypeNames
      ((functionDeclarationAt text state arguments).functions.items.map (fun item => (item.first, item.after))) :=
  (functionDeclarationAt_hiding_or_rejected correct).resolve_left accepted

end Silver.Compose
