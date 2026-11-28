module

public import Silver.ApplicationPackageFormalStorage
public import Silver.ApplicationPackageObjectStateFields

@[expose] public section

namespace Silver.ApplicationPackageFormalStorage
open Compose ApplicationPackageFrameLayout ApplicationPackageObjectRows
open PackageBindings (Formal)

def references (formals : List Formal) : List Row :=
  formals.map fun formal => reference formal.bodyName

theorem chosen_sublist (outputs : Bool) (info : PackageBindings.Metadata) (indices : List Nat) :
    (chosen outputs info indices).Sublist (indices.map info.parameterAt) := by
  induction indices with
  | nil => exact .refl _
  | cons index rest ih =>
    change ((selected outputs (info.parameterAt index)) ++ chosen outputs info rest).Sublist
      (info.parameterAt index :: rest.map info.parameterAt)
    unfold selected
    split
    · exact ih.cons_cons _
    · exact ih.cons _

theorem chosen_mode {outputs : Bool} {info : PackageBindings.Metadata} {indices : List Nat} {formal : Formal}
    (member : formal ∈ chosen outputs info indices) : decide (formal.mode = .output) = outputs := by
  obtain ⟨index, _, read⟩ := List.mem_flatMap.mp member
  unfold selected at read
  split at read
  · rename_i choice
    simpa only [List.mem_singleton.mp read] using choice
  · contradiction

private theorem map_filterMap_sublist {α β : Type} (items : List Formal)
    (take : Formal → Option α) (project : α → β) (original : Formal → β)
    (same : ∀ formal row, take formal = some row → project row = original formal) :
    ((items.filterMap take).map project).Sublist (items.map original) := by
  induction items with
  | nil => exact .refl _
  | cons formal rest ih =>
    cases read : take formal with
    | none =>
      rw [List.filterMap_cons_none read, List.map_cons]
      exact ih.cons _
    | some row =>
      rw [List.filterMap_cons_some read, List.map_cons, List.map_cons, same formal row read]
      exact ih.cons_cons _

theorem Stored.references {before after : ParserState} {formals : List Formal}
    (installed : Stored before after formals) :
    ∃ integers flags : List Row, integers.Sublist (references formals) ∧ flags.Sublist (references formals) ∧
      integerRows after = integerRows before ++ integers ∧ flagRows after = flagRows before ++ flags := by
  refine ⟨(formals.filterMap scalar).map fun row => ⟨row.first,row.after,row.qualifierFirst,row.qualifierAfter⟩,
    (formals.filterMap flag).map fun row => ⟨row.first,row.after,row.qualifierFirst,row.qualifierAfter⟩,
    ?_, ?_, ?_, ?_⟩
  · apply map_filterMap_sublist formals scalar
      (fun row => (⟨row.first,row.after,row.qualifierFirst,row.qualifierAfter⟩ : Row))
    intro formal row read
    unfold scalar at read
    split at read
    · cases read; rfl
    · contradiction
  · apply map_filterMap_sublist formals flag
      (fun row => (⟨row.first,row.after,row.qualifierFirst,row.qualifierAfter⟩ : Row))
    intro formal row read
    unfold flag at read
    split at read
    · cases read; rfl
    · contradiction
  · simp only [integerRows, installed.integers, List.map_append]
  · simp only [flagRows, installed.flags, List.map_append]

theorem Stored.state_fields {before after : ParserState} {formals : List Formal}
    {states : List PackageBindings.StateDeclaration} (installed : Stored before after formals)
    (prior : ScalarStateFields states before.scalarNames)
    (apart : ∀ formal ∈ formals, ∀ state ∈ states, formal.bodyName.first ≠ state.name.first) :
    ScalarStateFields states after.scalarNames := by
  intro row member state declared same
  rw [installed.integers] at member
  rcases List.mem_append.mp member with kept | added
  · exact prior row kept state declared same
  · obtain ⟨formal, source, value⟩ := List.mem_filterMap.mp added
    unfold scalar at value
    split at value
    · cases value
      exact False.elim (apart formal source state declared same)
    · contradiction

structure HeaderWindow (start stop : Nat) (formals : List Formal) : Prop where
  progress : start ≤ stop
  entries : ∀ formal ∈ formals, start ≤ formal.bodyName.first ∧ formal.bodyName.first < stop
  ordered : formals.Pairwise (fun left right => left.bodyName.first < right.bodyName.first)

theorem HeaderWindow.retain {start stop : Nat} {all kept : List Formal} (window : HeaderWindow start stop all)
    (subset : kept.Sublist all) : HeaderWindow start stop kept :=
  ⟨window.progress, fun formal member => window.entries formal (subset.subset member),
    window.ordered.sublist subset⟩

theorem HeaderWindow.reference_order {start stop : Nat} {formals : List Formal} (window : HeaderWindow start stop formals) :
    OrderedRows (references formals) := by
  change (formals.map _).Pairwise _
  rw [List.pairwise_map]
  exact window.ordered

theorem HeaderWindow.reference_bounds {start stop : Nat} {formals : List Formal} (window : HeaderWindow start stop formals)
    {row : Row} (seen : row ∈ references formals) : start ≤ row.first ∧ row.first < stop := by
  obtain ⟨formal, member, rfl⟩ := List.mem_map.mp seen
  exact window.entries formal member

theorem HeaderWindow.different {start stop : Nat} {formals : List Formal} (window : HeaderWindow start stop formals)
    {first second : Formal} (left : first ∈ formals) (right : second ∈ formals) (separate : first ≠ second) :
    first.bodyName.first ≠ second.bodyName.first := by
  obtain ⟨i, leftBound, l⟩ := List.getElem_of_mem left
  obtain ⟨j, rightBound, r⟩ := List.getElem_of_mem right
  have distinct : i ≠ j := by
    intro equal
    subst j
    exact separate (l.symm.trans r)
  rw [← l, ← r]
  rcases Nat.lt_or_gt_of_ne distinct with prior | later
  · exact Nat.ne_of_lt (window.ordered.rel_getElem_of_lt leftBound rightBound prior)
  · exact Nat.ne_of_gt (window.ordered.rel_getElem_of_lt rightBound leftBound later)

end Silver.ApplicationPackageFormalStorage
