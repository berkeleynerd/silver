module

public import Silver.ApplicationPackageFormalLocalScope

@[expose] public section

namespace Silver.ApplicationPackageFormalStorage
open Compose Predicate ApplicationPackageBodies ApplicationPackageFrameLayout ApplicationPackageObjectRows
open PackageBindings (Formal)

theorem HeaderWindow.of_offsets {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {start stop : Nat}
    (progress : start < stop)
    (spans : ∀ i, i < item.count →
      let name := (info.parameterAt (item.formalFirst + i)).bodyName
      0 < name.first ∧ start ≤ name.first ∧ name.first < name.after ∧ name.after < stop)
    (ordered : ∀ i j, i < j → j < item.count →
      (info.parameterAt (item.formalFirst + i)).bodyName.after <
        (info.parameterAt (item.formalFirst + j)).bodyName.first) :
    HeaderWindow start stop ((formalIndices item).map info.parameterAt) := by
  refine ⟨Nat.le_of_lt progress, ?_, ?_⟩
  · intro formal member
    obtain ⟨index, active, rfl⟩ := List.mem_map.mp member
    obtain ⟨i, bounded, rfl⟩ := List.mem_map.mp active
    have span := spans i (List.mem_range.mp bounded)
    exact ⟨span.2.1, Nat.lt_trans span.2.2.1 span.2.2.2⟩
  · simp only [formalIndices, List.pairwise_map]
    apply List.Pairwise.imp_of_mem _ List.pairwise_lt_range
    intro i j withinI withinJ prior
    exact Nat.lt_trans (spans i (List.mem_range.mp withinI)).2.2.1 (ordered i j prior (List.mem_range.mp withinJ))

private theorem valid_distinct {bound : Nat} {rows : List Row}
    (bounded : ∀ row ∈ rows, row.first ≤ bound) (distinct : rows.Pairwise (fun left right => left.first ≠ right.first)) :
    RowsValid bound rows := by
  constructor
  · intro slot positive active
    have inside : slot - 1 < rows.length := by omega
    simp only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside, Option.getD_some]
    exact bounded _ (List.getElem_mem inside)
  · intro left right leftPositive leftActive rightPositive rightActive same
    have l : left - 1 < rows.length := by omega
    have r : right - 1 < rows.length := by omega
    simp only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem l,
      List.getElem?_eq_getElem r, Option.getD_some] at same
    by_cases equal : left = right
    · exact equal
    · rcases Nat.lt_or_gt_of_ne equal with before | after
      · exact False.elim (distinct.rel_getElem_of_lt l r (by omega : left - 1 < right - 1) same)
      · exact False.elim (distinct.rel_getElem_of_lt r l (by omega : right - 1 < left - 1) same.symm)

private theorem output_rows_valid {cursor bound : Nat} {rows added : List Row} {outputs : List Formal}
    (old : BeforeCursor cursor rows) (apart : Apart rows outputs)
    (outputBefore : ∀ formal ∈ outputs, formal.bodyName.first < cursor)
    (outputOrder : OrderedRows (references outputs)) (subset : added.Sublist (references outputs))
    (within : cursor ≤ bound + 1) : RowsValid bound (rows ++ added) := by
  apply valid_distinct
  · intro row member
    rcases List.mem_append.mp member with kept | appended
    · have prior := old.before row kept
      omega
    · obtain ⟨formal, stored, rfl⟩ := List.mem_map.mp (subset.subset appended)
      have prior := outputBefore formal stored
      change formal.bodyName.first ≤ bound
      omega
  · apply List.pairwise_append.mpr
    refine ⟨old.ordered.imp (fun less => Nat.ne_of_lt less), (outputOrder.sublist subset).imp
      (fun less => Nat.ne_of_lt less), ?_⟩
    intro row member new appended
    obtain ⟨formal, stored, rfl⟩ := List.mem_map.mp (subset.subset appended)
    exact apart row member formal stored

/-- The final native binding tables may interleave source phases: output formals
belong to the earlier header and are installed after all locals. Each scalar
kind still has unique original source identities and the state domains required
by the actual widened body analysis. -/
theorem LocalFrame.outputs_context {info : PackageBindings.Metadata} {outputs : List Formal} {before : ParserState}
    (prior : LocalFrame info.states outputs before) (scan : ScanResult) (bound count : Nat)
    (installed : Stored before scan.state outputs) (sourceBound : scan.state.position ≤ bound + 1)
    (capacity : scan.state.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    let context := {contextOf scan with declarationCount := count}
    (layout bound info context).Context info.stateSchema context.analysis := by
  obtain ⟨integers, flags, intRefs, flagRefs, intTable, flagTable⟩ := installed.references
  have pos : before.position ≤ bound + 1 := installed.position ▸ sourceBound
  apply body_frame_context
  · rw [intTable]
    exact output_rows_valid prior.source.order.1 prior.scalarApart prior.outputBefore prior.outputOrder intRefs pos
  · rw [flagTable]
    exact output_rows_valid prior.source.order.2 prior.flagApart prior.outputBefore prior.outputOrder flagRefs pos
  · exact capacity
  · exact installed.state_fields prior.source.scalarFields prior.distinctStates

end Silver.ApplicationPackageFormalStorage
