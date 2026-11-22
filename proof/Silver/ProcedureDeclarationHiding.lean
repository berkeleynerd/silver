module

public import Silver.ProcedureDeclarationPreservation
public import Silver.FunctionDeclarationHiding

@[expose] public section

namespace Silver.Compose

/-- Both completed callable tables contribute their actual names to the native
operation-hiding inventory. Local formals stay in the declaration's own frame. -/
theorem procedureBodyAt_hiding_or_rejected {text : Source} {outer frame : ParserState}
    {first after : Nat} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text outer.subtypeNames
      (declarationHidingNames outer))
    (sameItems : frame.procedures.items = outer.procedures.items) :
    (procedureBodyAt text outer frame first after arguments).position = 0 ∨
      IntegerSubtypes.HidingCorrect text
        (procedureBodyAt text outer frame first after arguments).subtypeNames
        (declarationHidingNames (procedureBodyAt text outer frame first after arguments)) := by
  by_cases zero : (procedureBodyAt text outer frame first after arguments).position = 0
  · exact .inl zero
  · right
    rw [procedureBodyAt_installed zero]
    intro operation
    simpa [declarationHidingNames, procedureBodyInstalled, procedureSourceEntry, ProcedureBindings.append,
      sameItems, List.any_append, Bool.or_assoc] using
      IntegerSubtypes.hiding_add_other correct first after operation

theorem procedureDeclarationAt_hiding_or_rejected {text : Source} {state : ParserState} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (declarationHidingNames state)) :
    (procedureDeclarationAt text state arguments).position = 0 ∨
      IntegerSubtypes.HidingCorrect text (procedureDeclarationAt text state arguments).subtypeNames
        (declarationHidingNames (procedureDeclarationAt text state arguments)) := by
  dsimp only [procedureDeclarationAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · rename_i headerGood
      have unchanged := (procedureParametersModel_items text _ arguments).resolve_left headerGood
      split
      · exact .inl rfl
      · exact procedureBodyAt_hiding_or_rejected correct unchanged

theorem procedureDeclarationAt_hiding {text : Source} {state : ParserState} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (declarationHidingNames state))
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    IntegerSubtypes.HidingCorrect text (procedureDeclarationAt text state arguments).subtypeNames
      (declarationHidingNames (procedureDeclarationAt text state arguments)) :=
  (procedureDeclarationAt_hiding_or_rejected correct).resolve_left accepted

end Silver.Compose
