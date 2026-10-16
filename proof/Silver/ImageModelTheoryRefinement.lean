module

public import Silver.ImageModelTheoryCuts

@[expose] public section
namespace Silver.ImageModel.JSON

def Theory.appendNodes (theory : Theory) (declaration includeNode : Value) : Theory :=
  { theory with
    declarations := theory.declarations.map (· ++ [declaration])
    includes := theory.includes.map (· ++ [includeNode]) }

/-- Appending the two nodes at the actual scanner's original-byte candidates
changes precisely the declaration/include lists of the selected theory. -/
theorem TheorySpan.refined_spelling (span : TheorySpan)
    (tables : Native.Tables) (state : Core.State)
    (normal : NormalFields 0 true false span.spans span.normalized)
    (declarations includes : List Value)
    (decls : span.theory.declarations = some declarations)
    (incs : span.theory.includes = some includes)
    (declNonempty : declarations ≠ []) (incNonempty : includes ≠ [])
    (first second : Value) (firstBytes secondBytes : List Nat)
    (firstSyntax : AsciiSpelling first firstBytes)
    (secondSyntax : AsciiSpelling second secondBytes) :
    ∃ a b,
      (ScannerNative.fieldsScope (ScannerNative.scope (ScannerNative.openedTheory tables state))
        (state.bytes + 1) span.spans).candidateDeclarations = state.bytes + a ∧
      (ScannerNative.fieldsScope (ScannerNative.scope (ScannerNative.openedTheory tables state))
        (state.bytes + 1) span.spans).candidateIncludes = state.bytes + b ∧
      a < b ∧ b < span.bytes.length ∧
      AsciiSpelling (span.theory.appendNodes first second).value
        (splice span.bytes ([44] ++ firstBytes) ([44] ++ secondBytes) a b) := by
  obtain ⟨a, b, da, ib, ordered, bounded⟩ := span.candidate_cuts tables state normal declarations includes decls incs
  refine ⟨a, b, da, ib, ordered, bounded, ?_⟩
  obtain ⟨tag, id, domain, declarationField, name, kind, includeField, comment,
    shape, tagValue, idValue, domainValue, declValue, nameValue, kindValue, incValue, commentValue⟩ := span.parts
  have declArray : declarationField.value = .array declarations := by rw [declValue, decls]; rfl
  have incArray : includeField.value = .array includes := by rw [incValue, incs]; rfl
  have fields := normal.original_fields
  rw [shape] at fields
  have offsets := ScannerNative.fieldsScope_offsets_eight
    (ScannerNative.scope (ScannerNative.openedTheory tables state)) (state.bytes + 1)
    tag id domain declarationField name kind includeField comment declarations includes rfl declArray incArray
  rw [shape, offsets.1] at da
  rw [shape, offsets.2] at ib
  have firstCut : a = 1 + (fieldsBytes [tag, id, domain]).length + 1 + declarationField.leading.length + declarationField.body.length - 1 := by omega
  have secondCut : b = 1 + (fieldsBytes [tag, id, domain, declarationField, name, kind]).length + 1 + includeField.leading.length + includeField.body.length - 1 := by omega
  have result := splice_theory_fields tag id domain declarationField name kind includeField comment
    declarations includes fields declArray incArray declNonempty incNonempty first second firstBytes secondBytes firstSyntax secondSyntax
  rw [firstCut, secondCut, TheorySpan.bytes, shape]
  simpa only [Theory.appendNodes, Theory.value, Theory.fields, decls, incs, Option.map_some,
    nodeListValue, tagValue, idValue, domainValue, nameValue, kindValue, commentValue] using result

end Silver.ImageModel.JSON
