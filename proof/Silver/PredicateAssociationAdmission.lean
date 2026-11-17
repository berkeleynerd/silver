module

public import Silver.PredicateConditionAdmission
public import Silver.ProcedureBindings
public import Silver.ScalarAssociations

@[expose] public section

/-! Source cursors resolve ordinary Ada associations against only the selected
subprogram's formal slice. Lookup is deterministic even for arbitrary metadata
with duplicate spellings; no uniqueness premise is hidden in helper domains. -/
namespace Silver.Predicate
open Compose

abbrev FormalSet := ScalarAssociations.FormalSet
abbrev noFormals := ScalarAssociations.noFormals
abbrev markFormal := ScalarAssociations.markFormal

structure ActualAssociation where
  formal : Nat := 0
  payloadFirst : Nat := 0
  named : Bool := false
  deriving DecidableEq, Repr

def invalidAssociation : ActualAssociation := {}

def functionFormalModel (text : Source) (catalog : FunctionBindings.Metadata)
    (first last nameFirst nameAfter : Nat) : Nat :=
  if nameFirst = 0 ∨ nameAfter ≤ nameFirst then 0
  else if Named.equalName text (FunctionBindings.parameter catalog first).first
      (FunctionBindings.parameter catalog first).after nameFirst nameAfter then first
  else if first = last then 0
  else if _within : first < last then
    functionFormalModel text catalog (first + 1) last nameFirst nameAfter
  else 0
termination_by last - first

def procedureFormalModel (text : Source) (catalog : ProcedureBindings.Metadata)
    (first last nameFirst nameAfter : Nat) : Nat :=
  if nameFirst = 0 ∨ nameAfter ≤ nameFirst then 0
  else if Named.equalName text (ProcedureBindings.parameter catalog first).first
      (ProcedureBindings.parameter catalog first).after nameFirst nameAfter then first
  else if first = last then 0
  else if _within : first < last then
    procedureFormalModel text catalog (first + 1) last nameFirst nameAfter
  else 0
termination_by last - first

def functionAssociation (text : Source) (position : Nat) (catalog : FunctionBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) : ActualAssociation :=
  let nameFirst := skipAt text position
  let nameEnd := nameAfter text nameFirst
  let payload := fixedAfter text nameEnd "=>" false
  if position = 0 then invalidAssociation
  else if payload ≠ 0 then
    ⟨functionFormalModel text catalog first last nameFirst nameEnd, payload, true⟩
  else if named then invalidAssociation
  else ⟨ordinal, position, false⟩

def procedureAssociation (text : Source) (position : Nat) (catalog : ProcedureBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) : ActualAssociation :=
  let nameFirst := skipAt text position
  let nameEnd := nameAfter text nameFirst
  let payload := fixedAfter text nameEnd "=>" false
  if position = 0 then invalidAssociation
  else if payload ≠ 0 then
    ⟨procedureFormalModel text catalog first last nameFirst nameEnd, payload, true⟩
  else if named then invalidAssociation
  else ⟨ordinal, position, false⟩

theorem functionFormalModel_bounds {text catalog first last nameFirst nameAfter}
    (ordered : first ≤ last)
    (found : functionFormalModel text catalog first last nameFirst nameAfter ≠ 0) :
    first ≤ functionFormalModel text catalog first last nameFirst nameAfter ∧
      functionFormalModel text catalog first last nameFirst nameAfter ≤ last := by
  rw [functionFormalModel] at found ⊢
  split
  · simp_all
  · split
    · exact ⟨Nat.le_refl _, ordered⟩
    · split
      · simp_all
      · split
        · rename_i within
          have nextPositive : functionFormalModel text catalog (first + 1) last nameFirst nameAfter ≠ 0 := by
            simpa only [*, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte] using found
          have rest := functionFormalModel_bounds (by omega) nextPositive
          exact ⟨Nat.le_trans (by omega) rest.1, rest.2⟩
        · simp_all
termination_by last - first

theorem procedureFormalModel_bounds {text catalog first last nameFirst nameAfter}
    (ordered : first ≤ last)
    (found : procedureFormalModel text catalog first last nameFirst nameAfter ≠ 0) :
    first ≤ procedureFormalModel text catalog first last nameFirst nameAfter ∧
      procedureFormalModel text catalog first last nameFirst nameAfter ≤ last := by
  rw [procedureFormalModel] at found ⊢
  split
  · simp_all
  · split
    · exact ⟨Nat.le_refl _, ordered⟩
    · split
      · simp_all
      · split
        · rename_i within
          have nextPositive : procedureFormalModel text catalog (first + 1) last nameFirst nameAfter ≠ 0 := by
            simpa only [*, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte] using found
          have rest := procedureFormalModel_bounds (by omega) nextPositive
          exact ⟨Nat.le_trans (by omega) rest.1, rest.2⟩
        · simp_all
termination_by last - first

theorem functionAssociation_formal {text position catalog first last ordinal named}
    (ordered : first ≤ ordinal ∧ ordinal ≤ last)
    (found : (functionAssociation text position catalog first last ordinal named).formal ≠ 0) :
    first ≤ (functionAssociation text position catalog first last ordinal named).formal ∧
      (functionAssociation text position catalog first last ordinal named).formal ≤ last := by
  dsimp only [functionAssociation] at found ⊢
  by_cases zero : position = 0
  · simp [zero, invalidAssociation] at found
  · by_cases arrow : fixedAfter text (nameAfter text (skipAt text position)) "=>" false ≠ 0
    · rw [ite_eq_right zero, ite_eq_left arrow] at found ⊢
      exact functionFormalModel_bounds (by omega) found
    · by_cases namedTrue : named = true
      · simp only [zero, arrow, namedTrue, ↓reduceIte, invalidAssociation] at found
        contradiction
      · simpa only [zero, arrow, namedTrue, Bool.false_eq_true, ↓reduceIte] using ordered

theorem procedureAssociation_formal {text position catalog first last ordinal named}
    (ordered : first ≤ ordinal ∧ ordinal ≤ last)
    (found : (procedureAssociation text position catalog first last ordinal named).formal ≠ 0) :
    first ≤ (procedureAssociation text position catalog first last ordinal named).formal ∧
      (procedureAssociation text position catalog first last ordinal named).formal ≤ last := by
  dsimp only [procedureAssociation] at found ⊢
  by_cases zero : position = 0
  · simp [zero, invalidAssociation] at found
  · by_cases arrow : fixedAfter text (nameAfter text (skipAt text position)) "=>" false ≠ 0
    · rw [ite_eq_right zero, ite_eq_left arrow] at found ⊢
      exact procedureFormalModel_bounds (by omega) found
    · by_cases namedTrue : named = true
      · simp only [zero, arrow, namedTrue, ↓reduceIte, invalidAssociation] at found
        contradiction
      · simpa only [zero, arrow, namedTrue, Bool.false_eq_true, ↓reduceIte] using ordered

@[simp] theorem functionAssociation_zero (text : Source) (catalog : FunctionBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) :
    functionAssociation text 0 catalog first last ordinal named = invalidAssociation := by
  simp [functionAssociation]

@[simp] theorem procedureAssociation_zero (text : Source) (catalog : ProcedureBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) :
    procedureAssociation text 0 catalog first last ordinal named = invalidAssociation := by
  simp [procedureAssociation]

end Silver.Predicate
