module

public import Silver.ApplicationPackageFrameLayout

@[expose] public section

/-! Source-order facts needed by the stable frame layout. Declaration decoding
must establish the order and bounds; arbitrary native frames need not satisfy
them. Removing hidden rows preserves order and appending the next original
source declaration preserves it whenever its name starts after prior names. -/
namespace Silver.ApplicationPackageFrameLayout

abbrev OrderedRows (rows : List Row) : Prop :=
  rows.Pairwise (fun left right => left.first < right.first)

theorem RowsValid.of_ordered {bound : Nat} {rows : List Row}
    (ordered : OrderedRows rows) (bounded : ∀ row ∈ rows, row.first ≤ bound) :
    RowsValid bound rows where
  firstBound := by
    intro slot positive active
    have index : slot - 1 < rows.length := by omega
    have entry : rows.getD (slot - 1) {} = rows[slot - 1] := by
      simp only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem index, Option.getD_some]
    rw [entry]
    exact bounded _ (List.getElem_mem index)
  unique := by
    intro left right leftPositive leftActive rightPositive rightActive same
    have l : left - 1 < rows.length := by omega
    have r : right - 1 < rows.length := by omega
    simp only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem l,
      List.getElem?_eq_getElem r, Option.getD_some] at same
    by_cases before : left < right
    · have less := ordered.rel_getElem_of_lt l r (by omega : left - 1 < right - 1)
      omega
    · by_cases after : right < left
      · have less := ordered.rel_getElem_of_lt r l (by omega : right - 1 < left - 1)
        omega
      · omega

theorem orderedRows_empty : OrderedRows [] := .nil

theorem orderedRows_append {rows : List Row} {fresh : Row}
    (ordered : OrderedRows rows) (later : ∀ row ∈ rows, row.first < fresh.first) :
    OrderedRows (rows ++ [fresh]) := by
  rw [OrderedRows, List.pairwise_append]
  exact ⟨ordered, by simp, by simpa using later⟩

theorem orderedRows_sublist {before after : List Row}
    (kept : after.Sublist before) (ordered : OrderedRows before) : OrderedRows after :=
  ordered.sublist kept

/-- Compaction never changes the live bound either. -/
theorem rowsValid_after_compaction {bound : Nat} {before after : List Row}
    (kept : after.Sublist before) (ordered : OrderedRows before)
    (bounded : ∀ row ∈ before, row.first ≤ bound) : RowsValid bound after :=
  RowsValid.of_ordered (orderedRows_sublist kept ordered)
    (fun row present => bounded row (kept.subset present))

end Silver.ApplicationPackageFrameLayout
