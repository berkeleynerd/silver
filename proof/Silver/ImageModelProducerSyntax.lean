module

public import Silver.ImageModelTheorySpan
public import Silver.ImageModelJsonCanonical

@[expose] public section
namespace Silver.ImageModel.JSON

/-- ASCII follows from an independently valid normalized string, without
consulting a successful scanner or live matching candidate. -/
theorem Valid.string_ascii {characters : List Nat} (valid : Valid (.string characters)) :
    ∀ code ∈ characters, code < 127 := by
  obtain ⟨input, spelling⟩ := valid
  cases spelling with
  | string _ _ content => exact content.ascii

theorem AsciiElements.valid_items {values : List Value} {input : List Nat}
    (spelling : AsciiElements values input) : ∀ value ∈ values, Valid value := by
  induction values generalizing input with
  | nil => simp
  | cons value rest ih =>
      cases spelling with
      | single _ _ bytes _ _ item _ =>
          intro target member
          have same : target = value := by simpa using member
          subst target
          exact ⟨bytes, item⟩
      | more _ _ _ bytes _ _ _ _ item _ tail =>
          intro target member
          rcases List.mem_cons.mp member with same | member
          · subst target; exact ⟨bytes, item⟩
          · exact ih tail target member

theorem Valid.array_items {values : List Value} (valid : Valid (.array values)) :
    ∀ value ∈ values, Valid value := by
  obtain ⟨input, spelling⟩ := valid
  cases spelling with
  | array _ _ entries => exact entries.valid_items

mutual
  theorem WideValue.narrow (previous pending outgoing : Bool) (value normalized : Value) (input : List Nat)
      (wide : WideValue previous pending value input normalized outgoing) (valid : Valid normalized) :
      NormalValue previous pending value input normalized outgoing := by
    cases wide with
    | null previous => exact .null previous
    | true previous => exact .true previous
    | false previous => exact .false previous
    | number previous bytes token => exact .number previous input token
    | id previous first rest token decimal bounded => exact .id previous first rest token decimal bounded
    | string previous characters bytes content => exact .string previous characters bytes (content.to_ascii valid.string_ascii)
    | array previous values normalized bytes entries =>
        exact .array previous values normalized bytes
          (WideElements.narrow true false values normalized bytes entries valid.array_items)
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem WideElements.narrow (previous pending : Bool) (values normalized : List Value) (input : List Nat)
      (wide : WideElements previous pending values input normalized)
      (valid : ∀ value ∈ normalized, Valid value) :
      NormalElements previous pending values input normalized := by
    cases wide with
    | empty previous spaces whitespace => exact .empty previous input whitespace
    | single previous pending value normalized leading bytes trailing before item after =>
        exact .single previous pending value normalized leading bytes trailing before
          (WideValue.narrow previous pending false value normalized bytes item (valid normalized (by simp))) after
    | more previous pending outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        exact .more previous pending outgoing value normalized values restNormalized leading bytes spaces rest nonempty before
          (WideValue.narrow previous pending outgoing value normalized bytes item (valid normalized (by simp))) between
          (WideElements.narrow false outgoing values restNormalized rest tail (fun value member => valid value (by simp [member])))
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

theorem WideFields.narrow {index : Nat} {previous pending : Bool} {spans : List FieldSpan} {normalized : List Value}
    (wide : WideFields index previous pending spans normalized) (valid : ∀ value ∈ normalized, Valid value) :
    NormalFields index previous pending spans normalized := by
  induction wide with
  | last previous pending span normalized field =>
      cases field with
      | mk before value legal after =>
          exact .last previous pending span normalized
            (.mk before (value.narrow _ _ _ _ _ _ (valid normalized (by simp))) legal after)
  | more index previous pending outgoing span normalized spans restNormalized bounded field tail ih =>
      cases field with
      | mk before value legal after =>
          exact .more index previous pending outgoing span normalized spans restNormalized bounded
            (.mk before (value.narrow _ _ _ _ _ _ (valid normalized (by simp))) legal after)
            (ih (fun item member => valid item (by simp [member])))

theorem WideValue.outgoing {previous pending outgoing : Bool} {value normalized : Value} {input : List Nat}
    (wide : WideValue previous pending value input normalized outgoing) : outgoing = pendingAfter previous value := by
  cases wide <;> rfl

mutual
  /-- Broad syntactic normalization is ID erasure even before any selected
ASCII or matching fact is established. -/
  theorem WideValue.erasure (previous pending outgoing : Bool) (value normalized : Value) (input : List Nat)
      (wide : WideValue previous pending value input normalized outgoing) : normalized = eraseAt pending value := by
    cases wide with
    | null | true | false | number | id | string => simp [eraseAt, Value.eraseNodeIds]
    | array _ values normalized bytes entries =>
        rw [WideElements.erasure true false values normalized bytes entries]
        exact eraseElements_array values
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem WideElements.erasure (previous pending : Bool) (values normalized : List Value) (input : List Nat)
      (wide : WideElements previous pending values input normalized) : normalized = eraseElements previous pending values := by
    cases wide with
    | empty => rfl
    | single _ _ value normalized leading bytes trailing _ item _ =>
        simp only [eraseElements, WideValue.erasure previous pending false value normalized bytes item]
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest _ _ item _ tail =>
        rw [WideValue.erasure previous pending outgoing value normalized bytes item,
          WideElements.erasure false outgoing values restNormalized rest tail, item.outgoing]
        rfl
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

theorem WideFields.to_elements {index : Nat} {previous pending : Bool}
    {spans : List FieldSpan} {normalized : List Value}
    (wide : WideFields index previous pending spans normalized) :
    WideElements previous pending (spans.map FieldSpan.value) (fieldsBytes spans) normalized := by
  induction wide with
  | last previous pending span normalized field =>
      cases field with
      | mk before value legal after =>
          simpa only [fieldsBytes, FieldSpan.bytes, List.map_cons, List.map_nil, List.append_assoc] using
            WideElements.single previous pending span.value normalized span.leading span.body span.trailing before value after
  | more index previous pending outgoing span normalized spans restNormalized bounded field tail ih =>
      cases field with
      | mk before value legal after =>
          rw [fieldsBytes_cons span spans tail.nonempty.1]
          have nonempty : spans.map FieldSpan.value ≠ [] := by
            intro empty
            exact tail.nonempty.1 (List.map_eq_nil_iff.mp empty)
          simpa only [FieldSpan.bytes, List.map_cons, List.append_assoc] using
            WideElements.more previous pending outgoing span.value normalized (spans.map FieldSpan.value) restNormalized
              span.leading span.body span.trailing (fieldsBytes spans) nonempty before value after ih

theorem TheorySpan.wide_erasure (span : TheorySpan) :
    .array span.normalized = span.theory.value.eraseNodeIds := by
  have erased := WideElements.erasure true false (span.spans.map FieldSpan.value)
    span.normalized (fieldsBytes span.spans) span.spelling.to_elements
  rw [erased, eraseElements_array, span.shape]
  rfl

/-- This forward-domain conversion uses only producer syntax and validity of
its erased AST. In the pinned-producer envelope that validity comes from the
fixed typed template; no native acceptance or liveness premise is used. -/
theorem TheorySpan.normal_of_erased_valid (span : TheorySpan) (valid : Valid span.theory.value.eraseNodeIds) :
    NormalFields 0 true false span.spans span.normalized := by
  rw [← span.wide_erasure] at valid
  exact span.spelling.narrow valid.array_items

end Silver.ImageModel.JSON
