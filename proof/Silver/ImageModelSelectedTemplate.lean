module

public import Silver.ImageModelTheorySpan
public import Silver.ImageModelTemplateSelectors

@[expose] public section
namespace Silver.ImageModel.Templates

/-- Complete scanner equality at every one-based native table position is
literal equality with the independently serialized typed schema. No parsing or
structural injectivity premise is used at this byte-correspondence step. -/
theorem encoding_of_match (calls : Calls) (source : InterpretedSource calls)
    (kind : Native.Theory) (value : JSON.Value)
    (length : value.encode.length = calls.tables.length kind)
    (matched : ∀ index, (bound : index < value.encode.length) →
      value.encode[index] = calls.tables.byte kind (index + 1)) :
    value.encode = (theoryValue kind).encode := by
  have size := length.trans (interpreted_theory_length calls source kind)
  apply List.ext_getElem size
  intro index leftBound rightBound
  rw [matched index leftBound, interpreted_theory_byte calls source kind (index + 1)
    (by omega) (by omega), Nat.add_sub_cancel, List.getElem?_eq_getElem rightBound, Option.getD_some]

/-- A selected typed producer theory is matched using its original spelling.
The actual native scanner establishes its selected name, ASCII domain and
node-ID-erased serialization; the interpreted native tables identify the entire
checked schema, including nested declarations and all scoped symbol identities. -/
theorem accepted_selected_schema (calls : Calls) (source : InterpretedSource calls)
    (state : Core.State) (span : JSON.TheorySpan) (kind : Native.Theory)
    (good : state.failed = false) (mode : state.mode = .between)
    (pending : state.nodeIdPending = false) (depth : state.depth = 2)
    (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807)
    (selected : ScannerNative.selectedName span.theory.name none = some kind)
    (accepted : (span.bytes.foldl (ScannerNative.consume (Core.modelHelpers calls.tables)) state).failed = false) :
    JSON.NormalFields 0 true false span.spans span.normalized ∧
      JSON.Value.array span.normalized = span.theory.value.eraseNodeIds ∧
      span.theory.value.eraseNodeIds.encode = (theoryValue kind).encode := by
  obtain ⟨normal, erased, length, matched⟩ := ScannerNative.accepted_theory_span calls.tables state span kind
    good mode pending depth phase room depthRoom selected accepted
  exact ⟨normal, erased, encoding_of_match calls source kind _ length matched⟩

end Silver.ImageModel.Templates
