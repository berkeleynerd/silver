module

public import Silver.ImageModelTheorySplice

@[expose] public section
namespace Silver.ImageModel.JSON

/-- The closing brackets of the two original array fields are strictly ordered
and lie inside the theory. This is a syntax fact, independent of acceptance. -/
theorem theory_cuts_bounds
    (tag id domain declarations name kind includes comment : FieldSpan)
    (declarationNodes includeNodes : List Value)
    (declSyntax : AsciiSpelling (.array declarationNodes) declarations.body)
    (incSyntax : AsciiSpelling (.array includeNodes) includes.body) :
    let a := 1 + (fieldsBytes [tag, id, domain]).length + 1 + declarations.leading.length + declarations.body.length - 1
    let b := 1 + (fieldsBytes [tag, id, domain, declarations, name, kind]).length + 1 + includes.leading.length + includes.body.length - 1
    a < b ∧ b < ([91] ++ fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] ++ [93]).length := by
  obtain ⟨declBody, declBytes, _⟩ := declSyntax.array_body
  obtain ⟨incBody, incBytes, _⟩ := incSyntax.array_body
  dsimp only
  simp only [fieldsBytes, FieldSpan.bytes, declBytes, incBytes,
    List.length_append, List.length_cons, List.length_nil]
  omega

/-- Actual scoped candidate offsets split into the original prefix length and
two local cuts. Their order and bounds follow from normal syntax and the typed
node-list fields; no scanner-success or Finish premise is required. -/
theorem TheorySpan.candidate_cuts (span : TheorySpan)
    (tables : Native.Tables) (state : Core.State)
    (normal : NormalFields 0 true false span.spans span.normalized)
    (declarations includes : List Value)
    (decls : span.theory.declarations = some declarations)
    (incs : span.theory.includes = some includes) :
    ∃ a b,
      (ScannerNative.fieldsScope (ScannerNative.scope (ScannerNative.openedTheory tables state))
        (state.bytes + 1) span.spans).candidateDeclarations = state.bytes + a ∧
      (ScannerNative.fieldsScope (ScannerNative.scope (ScannerNative.openedTheory tables state))
        (state.bytes + 1) span.spans).candidateIncludes = state.bytes + b ∧
      a < b ∧ b < span.bytes.length := by
  obtain ⟨tag, id, domain, declarationField, name, kind, includeField, comment,
    shape, _, _, _, declValue, _, _, incValue, _⟩ := span.parts
  have declArray : declarationField.value = .array declarations := by rw [declValue, decls]; rfl
  have incArray : includeField.value = .array includes := by rw [incValue, incs]; rfl
  have fields :=  normal.original_fields
  rw [shape] at fields
  have ds := (fields declarationField (by simp)).2.1
  have ins := (fields includeField (by simp)).2.1
  rw [declArray] at ds
  rw [incArray] at ins
  let a := 1 + (fieldsBytes [tag, id, domain]).length + 1 + declarationField.leading.length + declarationField.body.length - 1
  let b := 1 + (fieldsBytes [tag, id, domain, declarationField, name, kind]).length + 1 + includeField.leading.length + includeField.body.length - 1
  have offsets := ScannerNative.fieldsScope_offsets_eight
    (ScannerNative.scope (ScannerNative.openedTheory tables state)) (state.bytes + 1)
    tag id domain declarationField name kind includeField comment declarations includes rfl declArray incArray
  have bounds := theory_cuts_bounds tag id domain declarationField name kind includeField comment
    declarations includes ds ins
  refine ⟨a, b, ?_, ?_, bounds.1, ?_⟩
  · rw [shape, offsets.1]
    dsimp only [a]
    omega
  · rw [shape, offsets.2]
    dsimp only [b]
    omega
  · simpa only [TheorySpan.bytes, shape] using bounds.2

end Silver.ImageModel.JSON
