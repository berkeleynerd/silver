module

public import Silver.ImageModelDocumentEntries

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- The closing list/root and trailing whitespace preserve all selected theory
observations and consume exactly their original source bytes. -/
theorem document_footer (tables : Native.Tables) (state : Core.State) (document : JSON.DocumentSpan)
    (good : state.failed = false) (mode : state.mode = .between)
    (depth : state.depth = 2) (pending : state.nodeIdPending = false)
    (phase : state.phase = .firstTheory ∨ state.phase = .theorySeparator)
    (room : state.bytes + document.footer.length ≤ 9223372036854775807) :
    let final := document.footer.foldl (consume (Core.modelHelpers tables)) state
    final.failed = false ∧ final.mode = .between ∧ final.depth = 0 ∧ final.phase = .afterRoot ∧
      final.nodeIdPending = false ∧ final.matcher = state.matcher ∧ final.seen = state.seen ∧
      final.declarations = state.declarations ∧ final.includes = state.includes ∧
      final.bytes = state.bytes + document.footer.length := by
  let listEnd := {counted state with depth := 1, phase := TheoryNative.Phase.rootEnd, previousArrayStart := false}
  let beforeRoot := {listEnd with bytes := listEnd.bytes + document.afterList.length}
  let rootEnd := {counted beforeRoot with depth := 0, phase := TheoryNative.Phase.afterRoot, previousArrayStart := false}
  let final := {rootEnd with bytes := rootEnd.bytes + document.trailing.length}
  have bound : state.bytes + (1 + document.afterList.length + 1 + document.trailing.length) ≤ 9223372036854775807 := by
    simpa only [JSON.DocumentSpan.footer, List.length_append, List.length_cons, List.length_nil, Nat.add_zero] using room
  have run : document.footer.foldl (consume (Core.modelHelpers tables)) state = final := by
    simp only [JSON.DocumentSpan.footer, List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [consume_between _ state 93 good (by omega) mode,
      structural_root_list_close _ (counted state) pending depth phase]
    rw [consume_whitespace_run _ listEnd document.afterList good
      (by change state.bytes + 1 + document.afterList.length ≤ _; omega) mode document.afterListSpace]
    rw [consume_between _ beforeRoot 125 good
      (by change state.bytes + 1 + document.afterList.length ≠ _; omega) mode,
      structural_root_close _ (counted beforeRoot) pending rfl rfl]
    exact consume_whitespace_run _ rootEnd document.trailing good
      (by change state.bytes + 1 + document.afterList.length + 1 + document.trailing.length ≤ _; omega) mode document.trailingSpace
  rw [run]
  refine ⟨good, mode, rfl, rfl, pending, rfl, rfl, rfl, rfl, ?_⟩
  change state.bytes + 1 + document.afterList.length + 1 + document.trailing.length = _
  simp only [JSON.DocumentSpan.footer, List.length_append, List.length_cons, List.length_nil]
  omega

end Silver.ImageModel.ScannerNative
