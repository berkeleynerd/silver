module

public import Silver.ImageModelWideFields
public import Silver.ImageModelWideTheorySpelling
public import Silver.ImageModelTheoryScan

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem wide_segment (tables : Native.Tables) (state : Core.State)
    (index : Nat) (previous pending outgoing : Bool) (span : JSON.FieldSpan) (normalized : JSON.Value)
    (normal : JSON.WideField index previous pending span normalized outgoing)
    (good : state.failed = false) (mode : state.mode = .between)
    (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3) (field : state.field = index)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : state.depth + span.bytes.length ≤ 9223372036854775807) :
    ScopedResult tables state (span.bytes.foldl (consume (Core.modelHelpers tables)) state)
      (spanScope (scope state) state.bytes span) span.bytes normalized.encode outgoing ∧
      ∀ kind, ((span.bytes.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
        JSON.NormalField index previous pending span normalized outgoing := by
  cases normal with
  | mk before value legal after =>
      let ready := {state with bytes := state.bytes + span.leading.length}
      obtain ⟨item, ascii⟩ := wide_field tables ready previous pending outgoing span.value normalized span.body value
        (field ▸ legal) good mode prev nodeId active depth
        (by change state.bytes + span.leading.length + span.body.length ≤ _
            simp only [JSON.FieldSpan.bytes, List.length_append] at room; omega)
        (by change state.depth + span.body.length ≤ _
            simp only [JSON.FieldSpan.bytes, List.length_append] at depthRoom; omega)
      let middle := span.body.foldl (consume (Core.modelHelpers tables)) ready
      have fold : span.bytes.foldl (consume (Core.modelHelpers tables)) state = afterSpaces middle span.trailing := by
        simp only [JSON.FieldSpan.bytes, List.foldl_append]
        rw [consume_whitespace_run _ state span.leading good
          (by simp only [JSON.FieldSpan.bytes, List.length_append] at room; omega) mode before]
        exact boundary_whitespace _ middle span.trailing item.good
          (by rw [item.bytes]; change state.bytes + span.leading.length + span.body.length + span.trailing.length ≤ _
              simp only [JSON.FieldSpan.bytes, List.length_append] at room; omega) item.boundary after
      refine ⟨?_, ?_⟩
      · rw [fold]
        refine ⟨(spaces_good middle span.trailing).trans item.good, ?_, ?_, ?_, spaces_boundary middle span.trailing item.boundary,
          (spaces_previous middle span.trailing).trans item.previous, (spaces_pending middle span.trailing).trans item.nodeId, ?_⟩
        · rw [spaces_matcher]; exact item.active
        · rw [spaces_scope, item.context, fieldScope_valueScope]
          rfl
        · rw [spaces_bytes, item.bytes]
          change state.bytes + span.leading.length + span.body.length + span.trailing.length = _
          simp only [JSON.FieldSpan.bytes, List.length_append]; omega
        · have leading := Emits.of_matcher_eq tables state ready rfl
          have trailing := Emits.of_matcher_eq tables middle (afterSpaces middle span.trailing) (spaces_matcher middle span.trailing)
          simpa only [List.nil_append, List.append_nil] using (leading.trans item.emits).trans trailing
      · intro kind live
        rw [fold, spaces_matcher] at live
        exact .mk before (ascii kind live) legal after

/-- Broad strings remain admitted throughout the body simulation. Liveness is
propagated backwards through each actual suffix before deriving any ASCII
subderivation. -/
theorem wide_fields (tables : Native.Tables) (index : Nat) (previous pending : Bool)
    (spans : List JSON.FieldSpan) (normalized : List JSON.Value)
    (normal : JSON.WideFields index previous pending spans normalized) :
    ∀ (state : Core.State), state.failed = false → state.mode = .between →
      state.previousArrayStart = previous → state.nodeIdPending = pending →
      state.matcher.inTheory = true → state.depth = 3 → state.field = index →
      state.bytes + (JSON.fieldsBytes spans).length ≤ 9223372036854775807 →
      state.depth + (JSON.fieldsBytes spans).length ≤ 9223372036854775807 →
      ScopedResult tables state ((JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) state)
        (fieldsScope (scope state) state.bytes spans) (JSON.fieldsBytes spans)
        (JSON.separated (normalized.map JSON.Value.encode)) false ∧
        ∀ kind, (((JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
          JSON.NormalFields index previous pending spans normalized := by
  induction normal with
  | last previous pending span normalized fieldNormal =>
      intro state good mode prev nodeId active depth field room depthRoom
      obtain ⟨result, ascii⟩ := wide_segment tables state 7 previous pending false span normalized fieldNormal
        good mode prev nodeId active depth field room depthRoom
      refine ⟨?_, fun kind live => .last previous pending span normalized (ascii kind live)⟩
      simpa only [JSON.fieldsBytes, fieldsScope, List.map_cons, List.map_nil, JSON.separated,
        List.intersperse_singleton, List.flatten_cons, List.flatten_nil, List.append_nil] using result
  | more index previous pending outgoing span normalized spans restNormalized bounded fieldNormal tail ih =>
      intro state good mode prev nodeId active depth field room depthRoom
      have input := JSON.fieldsBytes_cons span spans tail.nonempty.1
      rw [input] at room depthRoom ⊢
      obtain ⟨item, firstAscii⟩ := wide_segment tables state index previous pending outgoing span normalized fieldNormal
        good mode prev nodeId active depth field
        (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        (by simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
      let middle := span.bytes.foldl (consume (Core.modelHelpers tables)) state
      have middleDepth : middle.depth = state.depth :=
        (congrArg JsonScope.depth item.context).trans (valueScope_depth _ _ _ _)
      have middleField : middle.field = state.field :=
        (congrArg JsonScope.field item.context).trans (valueScope_field _ _ _ _)
      have nextScope := field_comma_scope tables middle
      have nextBytes : (fieldComma tables middle).bytes = state.bytes + span.bytes.length + 1 :=
        (comma_bytes tables middle).trans (by rw [item.bytes])
      have nextDepth : (fieldComma tables middle).depth = state.depth :=
        (congrArg JsonScope.depth nextScope).trans middleDepth
      have nextField : (fieldComma tables middle).field = index + 1 := by change middle.field + 1 = _; rw [middleField, field]
      obtain ⟨final, tailAscii⟩ := ih (fieldComma tables middle) ((comma_good tables middle).trans item.good)
        (comma_mode tables middle item.boundary) rfl ((comma_pending tables middle).trans item.nodeId)
        ((comma_active tables middle).trans item.active) (nextDepth.trans depth) nextField
        (by rw [nextBytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        (by rw [nextDepth]; simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
      have fold : (span.bytes ++ [44] ++ JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) state =
          (JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) (fieldComma tables middle) := by
        simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
        rw [field_comma_result tables middle item.good
          (by rw [item.bytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          item.boundary item.active (middleDepth.trans depth) (by omega)]
      refine ⟨?_, ?_⟩
      · rw [fold, separated_cons normalized restNormalized tail.nonempty.2]
        refine ⟨final.good, final.active, ?_, ?_, final.boundary, final.previous, final.nodeId,
          (item.emits.trans (field_comma_emits tables middle item.active)).trans final.emits⟩
        · rw [final.context, fieldsScope_cons _ _ span spans tail.nonempty.1,
            nextScope, item.context, middleField, nextBytes]
          rfl
        · rw [final.bytes, nextBytes]
          simp only [List.length_append, List.length_cons, List.length_nil]; omega
      · intro kind live
        rw [fold] at live
        have middleLive := (field_comma_emits tables middle item.active).live_before kind (final.emits.live_before kind live)
        exact .more index previous pending outgoing span normalized spans restNormalized bounded (firstAscii kind middleLive) (tailAscii kind live)

end Silver.ImageModel.ScannerNative
