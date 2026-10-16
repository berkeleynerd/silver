module

public import Silver.ImageModelWideTheoryScan

@[expose] public section
namespace Silver.ImageModel.JSON

theorem NormalFields.to_elements {index : Nat} {previous pending : Bool}
    {spans : List FieldSpan} {normalized : List Value}
    (normal : NormalFields index previous pending spans normalized) :
    NormalElements previous pending (spans.map FieldSpan.value) (fieldsBytes spans) normalized := by
  induction normal with
  | last previous pending span normalized field =>
      cases field with
      | mk before value legal after =>
          simpa only [fieldsBytes, FieldSpan.bytes, List.map_cons, List.map_nil, List.append_assoc] using
            NormalElements.single previous pending span.value normalized span.leading span.body span.trailing before value after
  | more index previous pending outgoing span normalized spans restNormalized bounded field tail ih =>
      cases field with
      | mk before value legal after =>
          rw [fieldsBytes_cons span spans tail.nonempty.1]
          have nonempty : spans.map FieldSpan.value ≠ [] := by
            intro empty
            exact tail.nonempty.1 (List.map_eq_nil_iff.mp empty)
          simpa only [FieldSpan.bytes, List.map_cons, List.append_assoc] using
            NormalElements.more previous pending outgoing span.value normalized (spans.map FieldSpan.value) restNormalized
              span.leading span.body span.trailing (fieldsBytes spans) nonempty before value after ih

/-- A typed producer theory with its original field spans and broad JSON
spellings. Its proof fields describe syntax and the ordered producer AST fields,
not successful scanning, template matching, or insertion correctness. -/
structure TheorySpan where
  theory : Theory
  spans : List FieldSpan
  normalized : List Value
  spelling : WideFields 0 true false spans normalized
  shape : spans.map FieldSpan.value = theory.fields

def TheorySpan.bytes (span : TheorySpan) : List Nat := [91] ++ fieldsBytes span.spans ++ [93]

theorem TheorySpan.erasure (span : TheorySpan) (normal : NormalFields 0 true false span.spans span.normalized) :
    .array span.normalized = span.theory.value.eraseNodeIds := by
  have value := NormalValue.array false (span.spans.map FieldSpan.value) span.normalized (fieldsBytes span.spans) normal.to_elements
  have erased := value.eraseNodeIds
  rw [span.shape] at erased
  exact erased

theorem TheorySpan.parts (span : TheorySpan) :
    ∃ tag id domain declarations name kind includes comment : FieldSpan,
      span.spans = [tag, id, domain, declarations, name, kind, includes, comment] ∧
      tag.value = .string (ascii "W_THEORY_DECLARATION") ∧ id.value = .number span.theory.id ∧
      domain.value = span.theory.domain ∧ declarations.value = nodeListValue span.theory.declarations ∧
      name.value = .string span.theory.name ∧ kind.value = span.theory.kind ∧
      includes.value = nodeListValue span.theory.includes ∧ comment.value = span.theory.comment := by
  have shape := span.shape
  simp only [Theory.fields, List.map_eq_cons_iff, List.map_eq_nil_iff] at shape
  rcases shape with ⟨a, ra, ha, va, b, rb, hb, vb, c, rc, hc, vc, d, rd, hd, vd,
    e, re, he, ve, f, rf, hf, vf, g, rg, hg, vg, h, rh, hh, vh, ht⟩
  exact ⟨a, b, c, d, e, f, g, h, by rw [ha, hb, hc, hd, he, hf, hg, hh, ht], va, vb, vc, vd, ve, vf, vg, vh⟩

end Silver.ImageModel.JSON

namespace Silver.ImageModel.ScannerNative

theorem valueScope_theory (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) :
    (valueScope context start value length).theory =
      if context.field = 4 then
        match value with
        | .string characters => selectedName characters context.theory
        | _ => context.theory
      else context.theory := by
  cases value <;> by_cases field : context.field = 4 <;> simp [valueScope, field]

theorem fieldsScope_name_eight (context : JsonScope) (start : Nat)
    (tag id domain declarations name kind includes comment : JSON.FieldSpan) (characters : List Nat)
    (field : context.field = 0) (named : name.value = .string characters) :
    (fieldsScope context start [tag, id, domain, declarations, name, kind, includes, comment]).theory =
      selectedName characters context.theory := by
  simp only [fieldsScope, spanScope, valueScope_theory, field, Nat.reduceAdd,
    named, Nat.reduceEqDiff, ↓reduceIte]

theorem theory_span_selected (tables : Native.Tables) (state : Core.State) (span : JSON.TheorySpan) :
    (fieldsScope (scope (openedTheory tables state)) (state.bytes + 1) span.spans).theory =
      selectedName span.theory.name none := by
  obtain ⟨tag, id, domain, declarations, name, kind, includes, comment, shape, _, _, _, _, named, _⟩ := span.parts
  rw [shape, fieldsScope_name_eight _ _ tag id domain declarations name kind includes comment span.theory.name rfl named]
  rfl

/-- The selected-name premise is now the typed producer theory's decoded name;
the native scoped name observation is derived from its eight original fields. -/
theorem accepted_theory_span (tables : Native.Tables) (state : Core.State) (span : JSON.TheorySpan) (kind : Native.Theory)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (depth : state.depth = 2) (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807)
    (selected : selectedName span.theory.name none = some kind)
    (accepted : (span.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    JSON.NormalFields 0 true false span.spans span.normalized ∧
      JSON.Value.array span.normalized = span.theory.value.eraseNodeIds ∧
      span.theory.value.eraseNodeIds.encode.length = tables.length kind ∧
      ∀ index, (bound : index < span.theory.value.eraseNodeIds.encode.length) →
        span.theory.value.eraseNodeIds.encode[index] = tables.byte kind (index + 1) := by
  obtain ⟨normal, length, items⟩ := wide_theory_exact tables state span.spans span.normalized kind span.spelling
    good mode pending depth phase room depthRoom ((theory_span_selected tables state span).trans selected) accepted
  have erased := span.erasure normal
  rw [erased] at length items
  exact ⟨normal, erased, length, items⟩

end Silver.ImageModel.ScannerNative
