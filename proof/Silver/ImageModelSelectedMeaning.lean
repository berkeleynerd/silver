module

public import Silver.ImageModelJsonMeaning
public import Silver.ImageModelTheorySpan
public import Silver.ImageModelTemplateSchema

@[expose] public section
namespace Silver.ImageModel.JSON

theorem eraseElements_length (previous pending : Bool) (values : List Value) :
    (eraseElements previous pending values).length = values.length := by
  induction values generalizing previous pending with
  | nil => rfl
  | cons value rest ih => simp only [eraseElements, List.length_cons, ih]

/-- ID erasure changes numeric ID values but never array cardinality. -/
theorem Value.eraseNodeIds_arraySize (value : Value) :
    value.eraseNodeIds.arraySize = value.arraySize := by
  cases value with
  | array values =>
      rw [← eraseElements_array values]
      exact eraseElements_length true false values
  | null | boolean | number | string | object =>
      simp only [Value.eraseNodeIds, Value.arraySize]

/-- The typed theory's declaration and include positions are preserved under
ID erasure; neither `null` nor a list constructor is silently substituted. -/
theorem Theory.erased_lists (theory : Theory) :
    (theory.value.eraseNodeIds.field 3) = (nodeListValue theory.declarations).eraseNodeIds ∧
    (theory.value.eraseNodeIds.field 6) = (nodeListValue theory.includes).eraseNodeIds := by
  have tag : nodeTag (ascii "W_THEORY_DECLARATION") = true := by decide +kernel
  have erased := Value.eraseNodeIds.eq_1 (ascii "W_THEORY_DECLARATION") theory.id
    [theory.domain, nodeListValue theory.declarations, .string theory.name, theory.kind,
      nodeListValue theory.includes, theory.comment]
  change theory.value.eraseNodeIds = _ at erased
  rw [tag] at erased
  simp only [↓reduceIte] at erased
  rw [erased]
  constructor <;> rfl

theorem nodeListValue_of_positive_size (items : Option (List Value)) (count : Nat)
    (positive : 0 < count) (size : (nodeListValue items).arraySize = count) :
    ∃ values, items = some values ∧ values.length = count ∧ values ≠ [] := by
  cases items with
  | none =>
      change 0 = count at size
      omega
  | some values =>
      change values.length = count at size
      refine ⟨values, rfl, size, ?_⟩
      intro empty
      subst values
      simp only [List.length_nil] at size
      omega

end Silver.ImageModel.JSON

namespace Silver.ImageModel.Templates

def declarationCount : Native.Theory → Nat
  | .integer => 10
  | .string => 15
  | .image => 5

def includeCount : Native.Theory → Nat
  | .integer => 3
  | .string => 8
  | .image => 4

theorem template_list_counts (kind : Native.Theory) :
    ((theoryValue kind).field 3).arraySize = declarationCount kind ∧
    ((theoryValue kind).field 6).arraySize = includeCount kind := by
  have declarations :
      arraySize (field integerTheory 3) = 10 ∧
      arraySize (field stringTheory 3) = 15 ∧
      arraySize (field imageTheory 3) = 5 := by
    simpa only [List.map_cons, List.map_nil, List.cons.injEq, and_true] using schema_shape.2.1
  have includes :
      arraySize (field integerTheory 6) = 3 ∧
      arraySize (field stringTheory 6) = 8 ∧
      arraySize (field imageTheory 6) = 4 := by
    simpa only [List.map_cons, List.map_nil, List.cons.injEq, and_true] using schema_shape.2.2
  cases kind with
  | integer => exact ⟨declarations.1, includes.1⟩
  | string => exact ⟨declarations.2.1, includes.2.1⟩
  | image => exact ⟨declarations.2.2, includes.2.2⟩

theorem list_counts_positive (kind : Native.Theory) :
    0 < declarationCount kind ∧ 0 < includeCount kind := by
  cases kind <;> decide +kernel

/-- Actual selected normalization supplies syntax independently of matching.
Complete canonical byte equality and the explicit external parser boundary then
identify the entire erased semantic tree, including every nested typed field. -/
theorem selected_meaning (span : JSON.TheorySpan) (kind : Native.Theory)
    (normal : JSON.NormalFields 0 true false span.spans span.normalized)
    (matched : span.theory.value.eraseNodeIds.encode = (theoryValue kind).encode)
    (parse : List Nat → Option JSON.Meaning) (sound : JSON.ParserSound parse)
    (parsed : parse (theoryValue kind).encode = some (theoryValue kind).meaning) :
    span.theory.value.eraseNodeIds.meaning = (theoryValue kind).meaning := by
  have valid : JSON.Valid (.array span.normalized) :=
    ⟨_, JSON.AsciiSpelling.array span.normalized _
      (JSON.NormalElements.canonical true false (span.spans.map JSON.FieldSpan.value)
        span.normalized (JSON.fieldsBytes span.spans) normal.to_elements)⟩
  rw [span.erasure normal] at valid
  exact sound.canonical_eq valid parsed matched

/-- The selected schema determines both original node lists. Positivity is
derived from the checked finite schemas, so `none`/`null` and empty arrays are
excluded by a conclusion rather than by a schema-shaped input assumption. -/
theorem selected_original_lists (span : JSON.TheorySpan) (kind : Native.Theory)
    (equal : span.theory.value.eraseNodeIds.meaning = (theoryValue kind).meaning) :
    ∃ declarations includes : List JSON.Value,
      span.theory.declarations = some declarations ∧ span.theory.includes = some includes ∧
      declarations.length = declarationCount kind ∧ includes.length = includeCount kind ∧
      declarations ≠ [] ∧ includes ≠ [] := by
  have declarations := congrArg (fun value : JSON.Meaning => (value.field 3).arraySize) equal
  have includes := congrArg (fun value : JSON.Meaning => (value.field 6).arraySize) equal
  have positions := span.theory.erased_lists
  simp only [← JSON.Value.meaning_field, JSON.Value.meaning_arraySize,
    positions.1, JSON.Value.eraseNodeIds_arraySize] at declarations
  simp only [← JSON.Value.meaning_field, JSON.Value.meaning_arraySize,
    positions.2, JSON.Value.eraseNodeIds_arraySize] at includes
  have counts := template_list_counts kind
  have positive := list_counts_positive kind
  obtain ⟨decls, actualDecls, declCount, declNonempty⟩ := JSON.nodeListValue_of_positive_size
    span.theory.declarations (declarationCount kind) positive.1 (declarations.trans counts.1)
  obtain ⟨incs, actualIncs, incCount, incNonempty⟩ := JSON.nodeListValue_of_positive_size
    span.theory.includes (includeCount kind) positive.2 (includes.trans counts.2)
  exact ⟨decls, incs, actualDecls, actualIncs, declCount, incCount, declNonempty, incNonempty⟩

theorem selected_schema_meaning (span : JSON.TheorySpan) (kind : Native.Theory)
    (normal : JSON.NormalFields 0 true false span.spans span.normalized)
    (matched : span.theory.value.eraseNodeIds.encode = (theoryValue kind).encode)
    (parse : List Nat → Option JSON.Meaning) (sound : JSON.ParserSound parse)
    (parsed : parse (theoryValue kind).encode = some (theoryValue kind).meaning) :
    span.theory.value.eraseNodeIds.meaning = (theoryValue kind).meaning ∧
      ∃ declarations includes : List JSON.Value,
        span.theory.declarations = some declarations ∧ span.theory.includes = some includes ∧
        declarations.length = declarationCount kind ∧ includes.length = includeCount kind ∧
        declarations ≠ [] ∧ includes ≠ [] := by
  have equal := selected_meaning span kind normal matched parse sound parsed
  exact ⟨equal, selected_original_lists span kind equal⟩

end Silver.ImageModel.Templates
