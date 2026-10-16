module

public import Silver.ImageModelJsonCanonical
public import Silver.ImageModelJsonSplice
public import Silver.ImageModelTheoryOffsets

@[expose] public section
namespace Silver.ImageModel.JSON

/-- Original trivia and field spelling, without any scanner or matching premise. -/
def FieldSyntax (span : FieldSpan) : Prop :=
  ScannerNative.Whitespace span.leading ∧ AsciiSpelling span.value span.body ∧
    ScannerNative.Whitespace span.trailing

theorem NormalFields.original_fields {index : Nat} {previous pending : Bool}
    {spans : List FieldSpan} {normalized : List Value}
    (normal : NormalFields index previous pending spans normalized) :
    ∀ span ∈ spans, FieldSyntax span := by
  induction normal with
  | last previous pending span normalized field =>
      intro target member
      have same : target = span := by simpa using member
      subst target
      cases field with
      | mk before value _ after => exact ⟨before, value.original_spelling, after⟩
  | more index previous pending outgoing span normalized spans restNormalized bounded field tail ih =>
      intro target member
      rcases List.mem_cons.mp member with same | member
      · subst target
        cases field with
        | mk before value _ after => exact ⟨before, value.original_spelling, after⟩
      · exact ih target member

theorem fields_original_spelling (spans : List FieldSpan)
    (spelling : ∀ span ∈ spans, FieldSyntax span) :
    AsciiElements (spans.map FieldSpan.value) (fieldsBytes spans) := by
  induction spans with
  | nil => exact .empty [] (by intro byte member; simp at member)
  | cons span rest ih =>
      have first := spelling span (by simp)
      have tail := ih (fun item member => spelling item (by simp [member]))
      cases rest with
      | nil =>
          exact .single span.value span.leading span.body span.trailing first.1 first.2.1 first.2.2
      | cons next rest =>
          simpa only [fieldsBytes, FieldSpan.bytes, List.map_cons, List.append_assoc] using
            AsciiElements.more span.value ((next :: rest).map FieldSpan.value)
              span.leading span.body span.trailing (fieldsBytes (next :: rest))
              (by simp) first.1 first.2.1 first.2.2 tail

theorem AsciiSpelling.array_body {values : List Value} {input : List Nat}
    (spelling : AsciiSpelling (.array values) input) :
    ∃ body, input = [91] ++ body ++ [93] ∧ AsciiElements values body := by
  cases spelling with
  | array _ body entries => exact ⟨body, rfl, entries⟩

/-- Eight original fields with two nonempty node arrays. At their original
closing brackets, the two comma-prefixed payloads append exactly the indicated
nodes. All other fields, trivia and existing nodes keep their original bytes. -/
theorem splice_theory_fields
    (tag id domain declarations name kind includes comment : FieldSpan)
    (declarationNodes includeNodes : List Value)
    (spelling : ∀ span ∈ [tag, id, domain, declarations, name, kind, includes, comment], FieldSyntax span)
    (declArray : declarations.value = .array declarationNodes)
    (incArray : includes.value = .array includeNodes)
    (declNonempty : declarationNodes ≠ []) (incNonempty : includeNodes ≠ [])
    (first second : Value) (firstBytes secondBytes : List Nat)
    (firstSyntax : AsciiSpelling first firstBytes) (secondSyntax : AsciiSpelling second secondBytes) :
    let original := [91] ++ fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] ++ [93]
    let a := 1 + (fieldsBytes [tag, id, domain]).length + 1 + declarations.leading.length + declarations.body.length - 1
    let b := 1 + (fieldsBytes [tag, id, domain, declarations, name, kind]).length + 1 + includes.leading.length + includes.body.length - 1
    AsciiSpelling
      (.array [tag.value, id.value, domain.value, .array (declarationNodes ++ [first]),
        name.value, kind.value, .array (includeNodes ++ [second]), comment.value])
      (splice original ([44] ++ firstBytes) ([44] ++ secondBytes) a b) := by
  have ds := (spelling declarations (by simp)).2.1
  have ins := (spelling includes (by simp)).2.1
  rw [declArray] at ds
  rw [incArray] at ins
  obtain ⟨declBody, declBytes, declSyntax⟩ := ds.array_body
  obtain ⟨incBody, incBytes, incSyntax⟩ := ins.array_body
  let preBytes := [91] ++ fieldsBytes [tag, id, domain] ++ [44] ++ declarations.leading
  let betweenBytes := declarations.trailing ++ [44] ++ fieldsBytes [name, kind] ++ [44] ++ includes.leading
  let postBytes := includes.trailing ++ [44] ++ comment.bytes ++ [93]
  obtain ⟨spliced, appendedDecl, appendedInc⟩ := splice_array_nodes preBytes betweenBytes postBytes
    declBody incBody firstBytes secondBytes declarationNodes includeNodes first second
    declSyntax incSyntax declNonempty incNonempty firstSyntax secondSyntax
  let newDecl : FieldSpan :=
    {declarations with
      value := .array (declarationNodes ++ [first])
      body := [91] ++ declBody ++ [44] ++ firstBytes ++ [93]}
  let newInc : FieldSpan :=
    {includes with
      value := .array (includeNodes ++ [second])
      body := [91] ++ incBody ++ [44] ++ secondBytes ++ [93]}
  have declField : FieldSyntax newDecl :=
    ⟨(spelling declarations (by simp)).1, appendedDecl, (spelling declarations (by simp)).2.2⟩
  have incField : FieldSyntax newInc :=
    ⟨(spelling includes (by simp)).1, appendedInc, (spelling includes (by simp)).2.2⟩
  have allFields : ∀ span ∈ [tag, id, domain, newDecl, name, kind, newInc, comment], FieldSyntax span := by
    intro span member
    simp only [List.mem_cons, List.not_mem_nil, or_false] at member
    rcases member with h | h | h | h | h | h | h | h
    all_goals subst span
    · exact spelling tag (by simp)
    · exact spelling id (by simp)
    · exact spelling domain (by simp)
    · exact declField
    · exact spelling name (by simp)
    · exact spelling kind (by simp)
    · exact incField
    · exact spelling comment (by simp)
  have result := AsciiSpelling.array _ _ (fields_original_spelling _ allFields)
  have firstCut :
      1 + (fieldsBytes [tag, id, domain]).length + 1 + declarations.leading.length + declarations.body.length - 1 =
      preBytes.length + 1 + declBody.length := by
    simp only [preBytes, declBytes, List.length_append, List.length_cons, List.length_nil]
    omega
  have secondCut :
      1 + (fieldsBytes [tag, id, domain, declarations, name, kind]).length + 1 + includes.leading.length + includes.body.length - 1 =
      preBytes.length + 1 + declBody.length + 1 + betweenBytes.length + 1 + incBody.length := by
    simp only [preBytes, betweenBytes, fieldsBytes, FieldSpan.bytes, declBytes, incBytes,
      List.length_append, List.length_cons, List.length_nil]
    omega
  have originalBytes :
      [91] ++ fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] ++ [93] =
      preBytes ++ [91] ++ declBody ++ [93] ++ betweenBytes ++ [91] ++ incBody ++ [93] ++ postBytes := by
    simp only [preBytes, betweenBytes, postBytes, fieldsBytes, FieldSpan.bytes, declBytes, incBytes, List.append_assoc]
  have exactSplice : splice
      ([91] ++ fieldsBytes [tag, id, domain, declarations, name, kind, includes, comment] ++ [93])
      ([44] ++ firstBytes) ([44] ++ secondBytes)
      (1 + (fieldsBytes [tag, id, domain]).length + 1 + declarations.leading.length + declarations.body.length - 1)
      (1 + (fieldsBytes [tag, id, domain, declarations, name, kind]).length + 1 + includes.leading.length + includes.body.length - 1) =
      [91] ++ fieldsBytes [tag, id, domain, newDecl, name, kind, newInc, comment] ++ [93] := by
    rw [originalBytes, firstCut, secondCut, spliced]
    simp only [preBytes, betweenBytes, postBytes, newDecl, newInc, fieldsBytes, FieldSpan.bytes, List.append_assoc]
  dsimp only
  rw [exactSplice]
  exact result

end Silver.ImageModel.JSON
