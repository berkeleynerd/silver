module

public import Silver.ImageModelDocumentSpan

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem closed_theory_mode (tables : Native.Tables) (state : Core.State) (boundary : Boundary state) :
    (closedTheory tables state).mode = .between := settled_mode state boundary

theorem closed_theory_bytes (tables : Native.Tables) (state : Core.State) :
    (closedTheory tables state).bytes = state.bytes + 1 := by
  change (settled state).bytes + 1 = _
  rw [settled_bytes]

theorem closed_theory_depth (tables : Native.Tables) (state : Core.State) : (closedTheory tables state).depth = 2 := rfl
theorem closed_theory_phase (tables : Native.Tables) (state : Core.State) : (closedTheory tables state).phase = .theorySeparator := rfl
theorem closed_theory_pending (tables : Native.Tables) (state : Core.State) :
    (closedTheory tables state).nodeIdPending = state.nodeIdPending := settled_pending state

theorem closed_theory_name (tables : Native.Tables) (state : Core.State) :
    (closedTheory tables state).theory = state.theory := by
  simp only [closedTheory, Core.modelHelpers, Core.State.setTheory, TheoryNative.model]
  split <;> exact congrArg JsonScope.theory (settled_scope state)

structure AfterTheory (state : Core.State) : Prop where
  mode : state.mode = .between
  depth : state.depth = 2
  phase : state.phase = .theorySeparator
  pending : state.nodeIdPending = false

/-- Every typed broad theory consumes its own complete span and returns to the
top-level list protocol. Its final failure flag is deliberately not assumed
away: selected-schema mismatch and duplicate selection still fail normally. -/
theorem theory_span_run (tables : Native.Tables) (state : Core.State) (span : JSON.TheorySpan)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (depth : state.depth = 2) (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807) :
    let middle := (JSON.fieldsBytes span.spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
    span.bytes.foldl (consume (Core.modelHelpers tables)) state = closedTheory tables middle ∧
      scope middle = fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) span.spans ∧
      AfterTheory (span.bytes.foldl (consume (Core.modelHelpers tables)) state) ∧
      (span.bytes.foldl (consume (Core.modelHelpers tables)) state).bytes = state.bytes + span.bytes.length ∧
      (span.bytes.foldl (consume (Core.modelHelpers tables)) state).theory = selectedName span.theory.name none := by
  have openingActive : (openedTheory tables state).matcher.inTheory = true :=
    Native.match_inTheory tables (beginTheory (counted state)).matcher 91 .integer
  obtain ⟨body, _⟩ := wide_fields tables 0 true false span.spans span.normalized span.spelling (openedTheory tables state)
    good mode rfl pending openingActive rfl rfl
    (by change state.bytes + 1 + (JSON.fieldsBytes span.spans).length ≤ _
        simp only [JSON.TheorySpan.bytes, List.length_append, List.length_cons, List.length_nil] at room; omega) depthRoom
  let middle := (JSON.fieldsBytes span.spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
  have middleDepth : middle.depth = 3 := (congrArg JsonScope.depth body.context).trans (fieldsScope_depth _ _ span.spans)
  have middleBytes : middle.bytes = state.bytes + 1 + (JSON.fieldsBytes span.spans).length := body.bytes
  have run : span.bytes.foldl (consume (Core.modelHelpers tables)) state = closedTheory tables middle := by
    simp only [JSON.TheorySpan.bytes, List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [open_theory_result tables state good
      (by simp only [JSON.TheorySpan.bytes, List.length_append, List.length_cons, List.length_nil] at room; omega) mode pending depth phase]
    exact close_theory_result tables middle body.good
      (by simp only [JSON.TheorySpan.bytes, List.length_append, List.length_cons, List.length_nil] at room; omega)
      body.boundary body.nodeId body.active middleDepth
  refine ⟨run, body.context, ?_, ?_, ?_⟩
  · rw [run]
    exact ⟨closed_theory_mode tables middle body.boundary, rfl, rfl, (closed_theory_pending tables middle).trans body.nodeId⟩
  · rw [run, closed_theory_bytes, middleBytes]
    simp only [JSON.TheorySpan.bytes, List.length_append, List.length_cons, List.length_nil]; omega
  · rw [run, closed_theory_name]
    exact (congrArg JsonScope.theory body.context).trans (theory_span_selected tables state span)

end Silver.ImageModel.ScannerNative
