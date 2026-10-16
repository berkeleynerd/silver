module

public import Silver.ImageModelTheorySpan

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem valueScope_declarations (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) :
    (valueScope context start value length).candidateDeclarations =
      if context.field = 3 then
        match value with
        | .array _ => start + length - 1
        | _ => context.candidateDeclarations
      else context.candidateDeclarations := by
  cases value <;> by_cases field : context.field = 3 <;> simp [valueScope, field]

theorem valueScope_includes (context : JsonScope) (start : Nat) (value : JSON.Value) (length : Nat) :
    (valueScope context start value length).candidateIncludes =
      if context.field = 6 then
        match value with
        | .array _ => start + length - 1
        | _ => context.candidateIncludes
      else context.candidateIncludes := by
  cases value <;> by_cases field : context.field = 6 <;> simp [valueScope, field]

/-- Original closing-byte positions are computed from complete preceding field
spans, including their real whitespace and commas. No normalized byte lengths
are substituted into insertion offsets. -/
theorem fieldsScope_offsets_eight (context : JsonScope) (start : Nat)
    (tag id domain declarations name kind includes comment : JSON.FieldSpan)
    (declarationNodes includeNodes : List JSON.Value) (field : context.field = 0)
    (declArray : declarations.value = .array declarationNodes) (incArray : includes.value = .array includeNodes) :
    (fieldsScope context start [tag, id, domain, declarations, name, kind, includes, comment]).candidateDeclarations =
        start + (JSON.fieldsBytes [tag, id, domain]).length + 1 + declarations.leading.length + declarations.body.length - 1 ∧
      (fieldsScope context start [tag, id, domain, declarations, name, kind, includes, comment]).candidateIncludes =
        start + (JSON.fieldsBytes [tag, id, domain, declarations, name, kind]).length + 1 + includes.leading.length + includes.body.length - 1 := by
  simp only [fieldsScope, spanScope, valueScope_declarations, valueScope_includes, field, Nat.reduceAdd,
    declArray, incArray, Nat.reduceEqDiff, ↓reduceIte]
  simp only [JSON.fieldsBytes, List.length_append, List.length_cons, List.length_nil]
  omega

theorem fieldsBytes_eight_declarations (tag id domain declarations name kind includes comment : JSON.FieldSpan) :
    JSON.fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] =
      (JSON.fieldsBytes [tag, id, domain] ++ [44] ++ declarations.leading) ++ declarations.body ++
        (declarations.trailing ++ [44] ++ JSON.fieldsBytes [name, kind, includes, comment]) := by
  simp only [JSON.fieldsBytes, JSON.FieldSpan.bytes, List.append_assoc]

theorem fieldsBytes_eight_includes (tag id domain declarations name kind includes comment : JSON.FieldSpan) :
    JSON.fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] =
      (JSON.fieldsBytes [tag, id, domain, declarations, name, kind] ++ [44] ++ includes.leading) ++ includes.body ++
        (includes.trailing ++ [44] ++ comment.bytes) := by
  simp only [JSON.fieldsBytes, JSON.FieldSpan.bytes, List.append_assoc]

/-- A single decomposition exposes both array fields in document order, ready
for the two insertion cuts. Every original byte outside their bodies appears
verbatim in the three surrounding segments. -/
theorem fieldsBytes_eight_two_arrays (tag id domain declarations name kind includes comment : JSON.FieldSpan) :
    JSON.fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] =
      (JSON.fieldsBytes [tag, id, domain] ++ [44] ++ declarations.leading) ++ declarations.body ++
      (declarations.trailing ++ [44] ++ JSON.fieldsBytes [name, kind] ++ [44] ++ includes.leading) ++ includes.body ++
      (includes.trailing ++ [44] ++ comment.bytes) := by
  simp only [JSON.fieldsBytes, JSON.FieldSpan.bytes, List.append_assoc]

end Silver.ImageModel.ScannerNative
