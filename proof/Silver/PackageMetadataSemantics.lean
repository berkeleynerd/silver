module

public import Silver.PackageBindings
public import Silver.PackageDefinitions

@[expose] public section

/-! Native metadata validation supplies the full declared state product used by
package semantics. State identity is its original declaration-order index; masks
select that same order and never substitute coincidental visible frame indices. -/
namespace Silver.PackageBindings

@[simp] theorem StateDeclaration.semantic_cell (item : StateDeclaration) (identity : Nat) :
    (item.semantic identity).cell = item.cell identity := by
  cases kind : item.kind <;> simp only [StateDeclaration.semantic, StateDeclaration.cell, kind]

@[simp] theorem StateDeclaration.cell_identity (item : StateDeclaration) (identity : Nat) :
    Packages.cellIndex (item.cell identity) = identity := by
  cases kind : item.kind <;> simp only [StateDeclaration.cell, kind, Packages.cellIndex]

theorem Metadata.stateAt_mem (info : Metadata) (identity : Nat)
    (positive : 0 < identity) (bounded : identity ≤ info.states.length) : info.stateAt identity ∈ info.states := by
  have index : identity - 1 < info.states.length := by omega
  simp only [Metadata.stateAt, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem index, Option.getD_some]
  exact List.getElem_mem index

theorem Metadata.stateAt_typed {info : Metadata} (typed : info.Typed) (identity : Nat)
    (positive : 0 < identity) (bounded : identity ≤ info.states.length) : (info.stateAt identity).Typed := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, states, _, _⟩
  exact states _ (info.stateAt_mem identity positive bounded)

theorem validMetadata_state {text : Text} {info : Metadata} (valid : validMetadata text info = true)
    (identity : Nat) (positive : 0 < identity) (bounded : identity ≤ info.states.length) :
    stateValid text info identity = true := by
  simp only [validMetadata, Bool.and_eq_true] at valid
  have selected := (List.all_eq_true.mp valid.1.1.2) (identity - 1) (by simp; omega)
  simpa only [Nat.sub_add_cancel positive] using selected

theorem stateValid_semantic {text : Text} {info : Metadata} {identity : Nat}
    (positive : 0 < identity) (typed : (info.stateAt identity).Typed)
    (valid : stateValid text info identity = true) : ((info.stateAt identity).semantic identity).Valid := by
  have declared := typed.2.2.1
  simp only [stateValid, Bool.and_eq_true, decide_eq_true_eq] at valid
  have nonempty : (info.stateAt identity).declaredBounds.lower ≤ (info.stateAt identity).declaredBounds.upper := by
    have checked := valid.1.1.2
    simp only [Integer.Interval.isEmpty, Bool.not_eq_true', decide_eq_false_iff_not] at checked
    omega
  have initial := valid.2
  cases kind : (info.stateAt identity).kind with
  | integer =>
      simp only [StateDeclaration.semantic, kind, Packages.StateDeclaration.Valid, Packages.cellIndex,
        Packages.CellDomain, ScalarFunctions.ScalarType.Valid, ScalarFunctions.ScalarType.Contains]
      refine ⟨by omega, trivial, ⟨declared, nonempty⟩, ?_⟩
      simp only [Integer.Interval.Contains]
      exact ⟨initial.2.1, by omega⟩
  | boolean =>
      simp [StateDeclaration.semantic, kind, Packages.StateDeclaration.Valid, Packages.cellIndex,
        Packages.CellDomain, ScalarFunctions.ScalarType.Valid, ScalarFunctions.ScalarType.Contains,
        Nat.ne_of_gt positive]

theorem Metadata.stateSchema_valid {text : Text} {info : Metadata}
    (typed : info.Typed) (valid : validMetadata text info = true) : info.stateSchema.Valid := by
  constructor
  · simp only [Metadata.stateSchema, List.map_map, Function.comp_def, StateDeclaration.semantic_cell]
    change List.Pairwise (fun a b : Packages.Cell => a ≠ b) _
    rw [List.pairwise_map]
    apply List.Pairwise.imp _ List.nodup_range
    intro a b different same
    apply different
    have indices := congrArg Packages.cellIndex same
    simpa only [StateDeclaration.cell_identity, Nat.add_right_cancel_iff] using indices
  · intro declaration member
    obtain ⟨index, present, rfl⟩ := List.mem_map.mp member
    have bounded : index + 1 ≤ info.states.length := Nat.succ_le_of_lt (List.mem_range.mp present)
    exact stateValid_semantic (by omega) (info.stateAt_typed typed (index + 1) (by omega) bounded)
      (validMetadata_state valid (index + 1) (by omega) bounded)

theorem stateUnion_get (left right : StateSet) (identity : Nat)
    (positive : 0 < identity) (bounded : identity ≤ maxStates) :
    StateSet.get (stateUnion left right) identity =
      (StateSet.get left identity || StateSet.get right identity) := by
  have index : identity - 1 < maxStates := by omega
  simp [StateSet.get, stateUnion, List.getD_eq_getElem?_getD, index]

theorem within_iff (effect : StateSet) (count : Nat) :
    within effect count = true ↔
      ∀ identity, 0 < identity → identity ≤ maxStates → count < identity → StateSet.get effect identity = false := by
  simp only [within, List.all_eq_true, List.mem_range]
  constructor
  · intro all identity positive bounded above
    have checked := all (identity - 1) (by omega)
    simpa [Nat.sub_add_cancel positive, above] using checked
  · intro checked index bounded
    split
    · rename_i above
      simp [checked (index + 1) (by omega) (by omega) above]
    · rfl

theorem Metadata.mem_effectCells (info : Metadata) (set : StateSet) (cell : Packages.Cell) :
    cell ∈ info.effectCells set ↔
      ∃ index, index < info.states.length ∧ StateSet.get set (index + 1) = true ∧
        cell = (info.stateAt (index + 1)).cell (index + 1) := by
  simp only [Metadata.effectCells, List.mem_map, List.mem_filter, List.mem_range]
  constructor
  · rintro ⟨index, ⟨bounded, selected⟩, equal⟩
    exact ⟨index, bounded, selected, equal.symm⟩
  · rintro ⟨index, bounded, selected, equal⟩
    exact ⟨index, ⟨bounded, selected⟩, equal.symm⟩

theorem Metadata.effectCells_index {info : Metadata} {set : StateSet} {identity : Nat}
    (positive : 0 < identity) (bounded : identity ≤ info.states.length) :
    (info.stateAt identity).cell identity ∈ info.effectCells set ↔ StateSet.get set identity = true := by
  rw [info.mem_effectCells]
  constructor
  · rintro ⟨index, _, selected, same⟩
    have indices := congrArg Packages.cellIndex same
    simp only [StateDeclaration.cell_identity] at indices
    simpa only [← indices] using selected
  · intro selected
    exact ⟨identity - 1, by omega, by simpa [Nat.sub_add_cancel positive], by simp [Nat.sub_add_cancel positive]⟩

theorem Routine.effects_covered (info : Metadata) (routine : Routine) :
    (routine.effects info).CoveredBy info.stateSchema := by
  intro cell captured
  rcases captured with present | present
  all_goals
    obtain ⟨index, bounded, _, rfl⟩ := (info.mem_effectCells _ _).mp present
    apply List.mem_map.mpr
    refine ⟨(info.stateAt (index + 1)).semantic (index + 1), ?_, by simp⟩
    exact List.mem_map.mpr ⟨index, by simpa using bounded, rfl⟩

def Metadata.captureSchema (info : Metadata) (routine : Routine) : Packages.StateSchema :=
  ((List.range info.states.length).filter fun index =>
    StateSet.get routine.mayRead (index + 1) || StateSet.get routine.mayWrite (index + 1)).map fun index =>
      (info.stateAt (index + 1)).semantic (index + 1)

theorem Metadata.captureSchema_eq (info : Metadata) (routine : Routine) :
    info.captureSchema routine = (routine.effects info).captureSchema info.stateSchema := by
  simp only [Metadata.captureSchema, Packages.Effects.captureSchema, Metadata.stateSchema, List.filter_map]
  congr 1
  apply List.filter_congr
  intro index member
  have bounded : index + 1 ≤ info.states.length := Nat.succ_le_of_lt (List.mem_range.mp member)
  apply Bool.eq_iff_iff.mpr
  simp only [Function.comp_apply, Bool.or_eq_true, Packages.Effects.captures_iff, Packages.Effects.Captures,
    StateDeclaration.semantic_cell, Routine.effects,
    info.effectCells_index (by omega) bounded]

end Silver.PackageBindings
