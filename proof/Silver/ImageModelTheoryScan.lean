module

public import Silver.ImageModelTheoryFields

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def openedTheory (tables : Native.Tables) (state : Core.State) : Core.State :=
  {(Core.modelHelpers tables).matchByte (beginTheory (counted state)) 91 with previousArrayStart := true}

def closedTheory (tables : Native.Tables) (state : Core.State) : Core.State :=
  {(Core.modelHelpers tables).endTheory (counted (settled state)) with previousArrayStart := false}

theorem open_theory_result (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .between) (pending : state.nodeIdPending = false) (depth : state.depth = 2)
    (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory) :
    consume (Core.modelHelpers tables) state 91 = openedTheory tables state := by
  rw [consume_between _ state 91 good room mode, structural_begin_theory _ (counted state) pending depth phase]
  rfl

theorem opened_theory_invariant (tables : Native.Tables) (state : Core.State) (kind : Native.Theory) :
    MatchInvariant (tables.byte kind) (tables.length kind) [91] ((openedTheory tables state).matcher.cells kind) := by
  have result := Emits.of_fold tables (beginTheory (counted state)) (openedTheory tables state) [91] rfl rfl
  exact result kind [] (initial_match_invariant _ _)

theorem closed_theory_cells (tables : Native.Tables) (state : Core.State) (kind : Native.Theory) :
    (closedTheory tables state).matcher.cells kind = (Core.matcher tables state.matcher 93).cells kind := by
  simp only [closedTheory, Core.modelHelpers, Core.State.setTheory, TheoryNative.model]
  split <;> change (Core.matcher tables (settled state).matcher 93).cells kind = _
  all_goals rw [settled_matcher]

theorem closed_theory_emits (tables : Native.Tables) (state : Core.State) (active : state.matcher.inTheory = true) :
    Emits tables state (closedTheory tables state) [93] := by
  intro kind initial invariant
  rw [closed_theory_cells]
  have result := Emits.of_fold tables state
    ((Core.modelHelpers tables).matchByte state 93) [93] active rfl
  exact result kind initial invariant

theorem close_theory_result (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (boundary : Boundary state) (pending : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3) :
    consume (Core.modelHelpers tables) state 93 = closedTheory tables state := by
  have d := congrArg JsonScope.depth (settled_scope state)
  change (settled state).depth = state.depth at d
  rw [consume_boundary_delimiter _ state 93 good room boundary (by decide +kernel)]
  exact structural_close_theory _ (counted (settled state)) ((settled_pending state).trans pending)
    (by change (settled state).matcher.inTheory = true; rw [settled_matcher]; exact active)
    (by change (settled state).depth = 3; omega)

theorem closed_theory_selected (tables : Native.Tables) (state : Core.State) (kind : Native.Theory)
    (selected : state.theory = some kind) (accepted : (closedTheory tables state).failed = false) :
    ((closedTheory tables state).matcher.cells kind).live = true ∧
      ((closedTheory tables state).matcher.cells kind).position = tables.length kind := by
  have target := congrArg JsonScope.theory (settled_scope state)
  change (settled state).theory = state.theory at target
  have result := TheoryNative.successful_selected tables (Core.matcher tables)
    (counted (settled state)).theoryView kind (target.trans selected) accepted
  rw [closed_theory_cells, ← settled_matcher state]
  exact ⟨result.2.2.1, result.2.2.2⟩

/-- A complete theory spelling derives the actual final scanner state and the
matching invariant for its entire normalized serialization. The exact body
scope is retained for name and insertion-offset interpretation. -/
theorem normal_theory_run (tables : Native.Tables) (state : Core.State)
    (spans : List JSON.FieldSpan) (normalized : List JSON.Value)
    (normal : JSON.NormalFields 0 true false spans normalized)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (depth : state.depth = 2) (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + ([91] ++ JSON.fieldsBytes spans ++ [93]).length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes spans).length ≤ 9223372036854775807) :
    let middle := (JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
    ([91] ++ JSON.fieldsBytes spans ++ [93]).foldl (consume (Core.modelHelpers tables)) state = closedTheory tables middle ∧
      scope middle = fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) spans ∧
      ∀ kind, MatchInvariant (tables.byte kind) (tables.length kind) (JSON.Value.array normalized).encode
        ((closedTheory tables middle).matcher.cells kind) := by
  have openingActive : (openedTheory tables state).matcher.inTheory = true :=
    Native.match_inTheory tables (beginTheory (counted state)).matcher 91 .integer
  have body := normal_fields tables 0 true false spans normalized normal (openedTheory tables state)
    good mode rfl pending openingActive rfl rfl
    (by change state.bytes + 1 + (JSON.fieldsBytes spans).length ≤ _
        simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) depthRoom
  let middle := (JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
  have middleDepth : middle.depth = 3 := (congrArg JsonScope.depth body.context).trans (fieldsScope_depth _ _ spans)
  have middleBytes : middle.bytes = state.bytes + 1 + (JSON.fieldsBytes spans).length := body.bytes
  refine ⟨?_, body.context, ?_⟩
  · simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [open_theory_result tables state good
      (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) mode pending depth phase]
    exact close_theory_result tables middle body.good
      (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
      body.boundary body.nodeId body.active middleDepth
  · intro kind
    have full := (body.emits.trans (closed_theory_emits tables middle body.active)) kind [91]
      (opened_theory_invariant tables state kind)
    simpa only [JSON.Value.encode, List.append_assoc] using full

/-- Successful selected-theory acceptance forces equality with every byte of
the complete selected template. The emitted stream is derived from independent
field/value syntax, not supplied as an assumption about the scanner. -/
theorem normal_theory_exact (tables : Native.Tables) (state : Core.State)
    (spans : List JSON.FieldSpan) (normalized : List JSON.Value) (kind : Native.Theory)
    (normal : JSON.NormalFields 0 true false spans normalized)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (depth : state.depth = 2) (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + ([91] ++ JSON.fieldsBytes spans ++ [93]).length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes spans).length ≤ 9223372036854775807)
    (selected : (fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) spans).theory = some kind)
    (accepted : (([91] ++ JSON.fieldsBytes spans ++ [93]).foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    (JSON.Value.array normalized).encode.length = tables.length kind ∧
      ∀ index, (bound : index < (JSON.Value.array normalized).encode.length) →
        (JSON.Value.array normalized).encode[index] = tables.byte kind (index + 1) := by
  obtain ⟨run, context, invariant⟩ := normal_theory_run tables state spans normalized normal good mode pending depth phase room depthRoom
  rw [run] at accepted
  have target := (congrArg JsonScope.theory context).trans selected
  obtain ⟨live, finished⟩ := closed_theory_selected tables _ kind target accepted
  obtain ⟨position, _, items⟩ := invariant kind live
  exact ⟨position.symm.trans finished, items⟩

end Silver.ImageModel.ScannerNative
