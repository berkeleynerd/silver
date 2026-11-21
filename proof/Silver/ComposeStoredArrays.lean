module

public import Silver.ComposeAdmission

@[expose] public section

/-! Declaration snapshots contain physical cells. Read-only input views enter a
subprogram only after its local declaration region has been checked. These
invariants derive that distinction from the recognizer's transitions. -/
namespace Silver.Compose

attribute [local irreducible] ScalarExpression.ArrayGrammar.read

def ParserState.StoredArrays (state : ParserState) : Prop :=
  ∀ item ∈ state.arrayNames.names, item.viewSlot = 0

theorem initialState_stored : initialState.StoredArrays := by
  simp [ParserState.StoredArrays, initialState]

theorem invalidState_stored : invalidState.StoredArrays := by
  simp [ParserState.StoredArrays, invalidState]

theorem scalarDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (scalarDeclarationAt text state arguments).StoredArrays := by
  unfold scalarDeclarationAt
  generalize partsEq : scalarDeclarationParts text state = parts
  dsimp only
  split
  · exact invalidState_stored
  · exact stored

theorem stringDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (stringDeclarationAt text state arguments).StoredArrays := by
  unfold stringDeclarationAt
  dsimp only
  split
  · exact invalidState_stored
  · exact stored

theorem characterDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (characterDeclarationAt text state arguments).StoredArrays := by
  unfold characterDeclarationAt
  dsimp only
  split
  · exact invalidState_stored
  · exact stored

theorem booleanDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (booleanDeclarationAt text state arguments).StoredArrays := by
  unfold booleanDeclarationAt
  dsimp only
  split
  · exact invalidState_stored
  · split
    · exact invalidState_stored
    · exact stored

theorem subtypeDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (subtypeDeclarationAt text state arguments).StoredArrays := by
  unfold subtypeDeclarationAt
  dsimp only
  split
  · exact invalidState_stored
  · exact stored

theorem arrayTypeDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (arrayTypeDeclarationAt text state arguments).StoredArrays := by
  unfold arrayTypeDeclarationAt
  dsimp only
  split
  · exact invalidState_stored
  · exact stored

theorem arrayDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (arrayDeclarationAt text state arguments).StoredArrays := by
  unfold arrayDeclarationAt
  generalize partsEq : arrayDeclarationParts text state = parts
  dsimp only
  split
  · exact invalidState_stored
  · split
    · exact invalidState_stored
    · split
      · exact invalidState_stored
      · rename_i values
        split
        · exact invalidState_stored
        · have kept := arrayDeclarationValues_preserves values
          intro item member
          rcases List.mem_append.mp member with old | fresh
          · rw [kept.2.2.1] at old
            exact stored item old
          · have same := List.mem_singleton.mp fresh
            subst item
            rfl

theorem functionDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays)
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    (functionDeclarationAt text state arguments).StoredArrays := by
  unfold ParserState.StoredArrays
  rw [(functionDeclarationAt_preserves_outer text state arguments accepted).arrayNames]
  exact stored

theorem procedureDeclarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays)
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    (procedureDeclarationAt text state arguments).StoredArrays := by
  unfold ParserState.StoredArrays
  rw [(procedureDeclarationAt_preserves_outer text state arguments accepted).arrayNames]
  exact stored

theorem declarationAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (declarationAt text state arguments).StoredArrays := by
  unfold declarationAt
  dsimp only
  split
  · exact functionDeclarationAt_stored text state arguments stored ‹_›
  · split
    · exact procedureDeclarationAt_stored text state arguments stored ‹_›
    · split
      · exact arrayTypeDeclarationAt_stored text state arguments stored
      · split
        · exact subtypeDeclarationAt_stored text state arguments stored
        · split
          · exact scalarDeclarationAt_stored text state arguments stored
          · split
            · exact arrayDeclarationAt_stored text state arguments stored
            · split
              · exact booleanDeclarationAt_stored text state arguments stored
              · split
                · exact characterDeclarationAt_stored text state arguments stored
                · exact stringDeclarationAt_stored text state arguments stored

theorem declarationsLoop_stored (text : Source) (arguments : Bool) (fuel : Nat)
    (state : ParserState) (stored : state.StoredArrays) :
    (declarationsLoop text arguments fuel state).StoredArrays := by
  induction fuel generalizing state with
  | zero => exact invalidState_stored
  | succ fuel ih =>
      rw [declarationsLoop]
      split
      · exact invalidState_stored
      · split
        · exact stored
        · split
          · exact invalidState_stored
          · exact ih _ (declarationAt_stored text state arguments stored)

theorem declarationsAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (declarationsAt text state arguments).StoredArrays :=
  declarationsLoop_stored text arguments _ state stored

theorem functionLocalAt_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (functionLocalAt text state arguments).StoredArrays := by
  unfold functionLocalAt
  dsimp only
  split
  · exact scalarDeclarationAt_stored text state arguments stored
  · exact booleanDeclarationAt_stored text state arguments stored

theorem functionLocalsModel_stored (text : Source) (state : ParserState) (arguments : Bool)
    (stored : state.StoredArrays) : (functionLocalsModel text state arguments).StoredArrays := by
  rw [functionLocalsModel]
  split
  · exact invalidState_stored
  · split
    · exact stored
    · dsimp only
      split
      · exact invalidState_stored
      · split
        · exact functionLocalsModel_stored text _ arguments
            (functionLocalAt_stored text state arguments stored)
        · exact invalidState_stored
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

end Silver.Compose
