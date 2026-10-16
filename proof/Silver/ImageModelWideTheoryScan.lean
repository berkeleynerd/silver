module

public import Silver.ImageModelWideTheoryFields

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- Successful selected-theory acceptance derives the ASCII grammar from the
broader byte/escape grammar. No ASCII restriction is imposed on other theories
or on the producer document as a whole. -/
theorem wide_theory_normal (tables : Native.Tables) (state : Core.State)
    (spans : List JSON.FieldSpan) (normalized : List JSON.Value) (kind : Native.Theory)
    (normal : JSON.WideFields 0 true false spans normalized)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (depth : state.depth = 2) (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + ([91] ++ JSON.fieldsBytes spans ++ [93]).length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes spans).length ≤ 9223372036854775807)
    (selected : (fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) spans).theory = some kind)
    (accepted : (([91] ++ JSON.fieldsBytes spans ++ [93]).foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    JSON.NormalFields 0 true false spans normalized := by
  have openingActive : (openedTheory tables state).matcher.inTheory = true :=
    Native.match_inTheory tables (beginTheory (counted state)).matcher 91 .integer
  obtain ⟨body, ascii⟩ := wide_fields tables 0 true false spans normalized normal (openedTheory tables state)
    good mode rfl pending openingActive rfl rfl
    (by change state.bytes + 1 + (JSON.fieldsBytes spans).length ≤ _
        simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) depthRoom
  let middle := (JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) (openedTheory tables state)
  have middleDepth : middle.depth = 3 := (congrArg JsonScope.depth body.context).trans (fieldsScope_depth _ _ spans)
  have middleBytes : middle.bytes = state.bytes + 1 + (JSON.fieldsBytes spans).length := body.bytes
  have target : middle.theory = some kind := (congrArg JsonScope.theory body.context).trans selected
  simp only [List.foldl_append, List.foldl_cons, List.foldl_nil] at accepted
  rw [open_theory_result tables state good
    (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) mode pending depth phase] at accepted
  rw [close_theory_result tables middle body.good
    (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
    body.boundary body.nodeId body.active middleDepth] at accepted
  have live := (closed_theory_selected tables middle kind target accepted).1
  exact ascii kind ((closed_theory_emits tables middle body.active).live_before kind live)

/-- Complete source/schema matching starts with broad producer spelling. ASCII
and the exact normalized byte stream are consequences of actual selected
acceptance, including all nested values and escaped string forms. -/
theorem wide_theory_exact (tables : Native.Tables) (state : Core.State)
    (spans : List JSON.FieldSpan) (normalized : List JSON.Value) (kind : Native.Theory)
    (normal : JSON.WideFields 0 true false spans normalized)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (depth : state.depth = 2) (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + ([91] ++ JSON.fieldsBytes spans ++ [93]).length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes spans).length ≤ 9223372036854775807)
    (selected : (fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) spans).theory = some kind)
    (accepted : (([91] ++ JSON.fieldsBytes spans ++ [93]).foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    JSON.NormalFields 0 true false spans normalized ∧
      (JSON.Value.array normalized).encode.length = tables.length kind ∧
      ∀ index, (bound : index < (JSON.Value.array normalized).encode.length) →
        (JSON.Value.array normalized).encode[index] = tables.byte kind (index + 1) := by
  have narrow := wide_theory_normal tables state spans normalized kind normal good mode pending depth phase room depthRoom selected accepted
  exact ⟨narrow, normal_theory_exact tables state spans normalized kind narrow good mode pending depth phase room depthRoom selected accepted⟩

end Silver.ImageModel.ScannerNative
