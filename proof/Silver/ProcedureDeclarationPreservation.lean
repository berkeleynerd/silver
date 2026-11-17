module

public import Silver.ProcedureDeclarationModel

@[expose] public section

namespace Silver.Compose

/-- A completed procedure changes its callable table and hiding flags while
retaining the complete outer object frame and earlier function table. -/
structure ProcedureOuterPreserved (before after : ParserState) : Prop where
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
  functions : after.functions = before.functions
  firstParameter : after.firstParameter = before.firstParameter
  firstProcedureParameter : after.firstProcedureParameter = before.firstProcedureParameter

theorem procedureBodyAt_outer_or_rejected (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) :
    (procedureBodyAt text outer frame first after arguments).position = 0 ∨
      ProcedureOuterPreserved outer (procedureBodyAt text outer frame first after arguments) := by
  rw [procedureBodyAt_equation]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · split
        · exact .inl rfl
        · exact .inr ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem procedureDeclarationAt_outer_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    (procedureDeclarationAt text state arguments).position = 0 ∨
      ProcedureOuterPreserved state (procedureDeclarationAt text state arguments) := by
  dsimp only [procedureDeclarationAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · exact procedureBodyAt_outer_or_rejected ..

theorem procedureDeclarationAt_preserves_outer (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    ProcedureOuterPreserved state (procedureDeclarationAt text state arguments) :=
  (procedureDeclarationAt_outer_or_rejected text state arguments).resolve_left accepted

def ProcedureItemsUnchanged (before after : ParserState) : Prop :=
  after.position = 0 ∨ after.procedures.items = before.procedures.items

theorem procedureParameterStep_items (text : Source) (state : ParserState) (arguments : Bool) :
    ProcedureItemsUnchanged state (procedureParameterStep text state arguments).state := by
  dsimp only [procedureParameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize colonEq : fixedAfter text after ":" false = colonEnd
  generalize inEq : fixedAfter text colonEnd "in" true = inEnd
  generalize outEq : fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true = outEnd
  generalize startEq : (if outEnd ≠ 0 then outEnd else inEnd) = start
  generalize valueEq : functionTypeAt text state start = value
  split
  · exact .inl rfl
  · split
    · exact .inr rfl
    · split
      · exact .inr rfl
      · exact .inl rfl

theorem procedureParametersModel_items (text : Source) (state : ParserState) (arguments : Bool) :
    ProcedureItemsUnchanged state (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have unchanged := (procedureParameterStep_items text state arguments).resolve_left nonzero
    split
    · exact .inr unchanged
    · split
      · rcases procedureParametersModel_items text (procedureParameterStep text state arguments).state arguments with rejected | preserved
        · exact .inl rejected
        · exact .inr (preserved.trans unchanged)
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

def ProcedureCountStep (before after : ParserState) : Prop :=
  after.position = 0 ∨ after.procedures.items.length = before.procedures.items.length + 1

theorem procedureBodyAt_count_or_rejected (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) :
    ProcedureCountStep frame (procedureBodyAt text outer frame first after arguments) := by
  rw [procedureBodyAt_equation]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · split
        · exact .inl rfl
        · right
          simp only [procedureBodyInstalled, ProcedureBindings.append, List.length_append, List.length_singleton]

theorem procedureDeclarationAt_count_or_rejected (text : Source) (state : ParserState) (arguments : Bool) :
    ProcedureCountStep state (procedureDeclarationAt text state arguments) := by
  dsimp only [procedureDeclarationAt]
  split
  · exact .inl rfl
  · split
    · exact .inl rfl
    · rename_i headerGood
      have unchanged := (procedureParametersModel_items text _ arguments).resolve_left headerGood
      split
      · exact .inl rfl
      · refine Or.imp_right ?_ (procedureBodyAt_count_or_rejected ..)
        intro count
        exact count.trans (congrArg (fun (items : List ProcedureBindings.Signature) => items.length + 1) unchanged)

theorem procedureDeclarationAt_count (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    (procedureDeclarationAt text state arguments).procedures.items.length = state.procedures.items.length + 1 :=
  (procedureDeclarationAt_count_or_rejected text state arguments).resolve_left accepted

theorem procedureBodyAt_position (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) :
    (procedureBodyAt text outer frame first after arguments).position ≤ text.length + 1 ∧
      ((procedureBodyAt text outer frame first after arguments).position = 0 ∨
        outer.position < (procedureBodyAt text outer frame first after arguments).position) := by
  rw [procedureBodyAt_equation]
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · split
    · exact ⟨Nat.zero_le _, .inl rfl⟩
    · split
      · exact ⟨Nat.zero_le _, .inl rfl⟩
      · split
        · exact ⟨Nat.zero_le _, .inl rfl⟩
        · rename_i allowed
          exact ⟨fixedAfter_result_bound text _ ";" false (by decide), .inr
            (Nat.lt_of_not_ge (fun le => allowed (.inr (.inr (.inr (.inr le))))))⟩

theorem procedureDeclarationAt_position (text : Source) (state : ParserState) (arguments : Bool) :
    (procedureDeclarationAt text state arguments).position ≤ text.length + 1 ∧
      ((procedureDeclarationAt text state arguments).position = 0 ∨
        state.position < (procedureDeclarationAt text state arguments).position) := by
  dsimp only [procedureDeclarationAt]
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · split
    · exact ⟨Nat.zero_le _, .inl rfl⟩
    · split
      · exact ⟨Nat.zero_le _, .inl rfl⟩
      · exact procedureBodyAt_position ..

end Silver.Compose
