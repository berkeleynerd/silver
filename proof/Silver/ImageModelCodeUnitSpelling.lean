module

public import Silver.ImageModelTheorySpan

@[expose] public section
namespace Silver.ImageModel.JSON

mutual
  /-- Whitespace and broad byte-oriented string spelling are explicit in this grammar. Its
constructors describe syntax only and contain no scanner-state equations,
matching assumptions, or expected template identity. Numeric syntax is exactly
the integral subset emitted by the pinned Why producer. No ASCII condition is imposed on this whole-document grammar. -/
  inductive CodeUnitSpelling : Value → List Nat → Prop
    | null : CodeUnitSpelling .null [110, 117, 108, 108]
    | true : CodeUnitSpelling (.boolean true) [116, 114, 117, 101]
    | false : CodeUnitSpelling (.boolean false) [102, 97, 108, 115, 101]
    | number (bytes : List Nat) (valid : IntegerToken bytes) : CodeUnitSpelling (.number bytes) bytes
    | string (characters bytes : List Nat) (content : CodeUnitContent characters bytes) :
        CodeUnitSpelling (.string characters) ([34] ++ bytes ++ [34])
    | array (values : List Value) (bytes : List Nat) (entries : CodeUnitElements values bytes) :
        CodeUnitSpelling (.array values) ([91] ++ bytes ++ [93])
    | object (values : List (List Nat × Value)) (bytes : List Nat) (members : CodeUnitMembers values bytes) :
        CodeUnitSpelling (.object values) ([123] ++ bytes ++ [125])

  inductive CodeUnitElements : List Value → List Nat → Prop
    | empty (spaces : List Nat) (whitespace : ScannerNative.Whitespace spaces) : CodeUnitElements [] spaces
    | single (value : Value) (leading bytes trailing : List Nat)
        (before : ScannerNative.Whitespace leading) (item : CodeUnitSpelling value bytes)
        (after : ScannerNative.Whitespace trailing) : CodeUnitElements [value] (leading ++ bytes ++ trailing)
    | more (value : Value) (values : List Value) (leading bytes spaces rest : List Nat)
        (nonempty : values ≠ []) (before : ScannerNative.Whitespace leading)
        (item : CodeUnitSpelling value bytes) (between : ScannerNative.Whitespace spaces)
        (tail : CodeUnitElements values rest) :
        CodeUnitElements (value :: values) (leading ++ bytes ++ spaces ++ [44] ++ rest)

  inductive CodeUnitMembers : List (List Nat × Value) → List Nat → Prop
    | empty (spaces : List Nat) (whitespace : ScannerNative.Whitespace spaces) : CodeUnitMembers [] spaces
    | single (name : List Nat) (value : Value) (leading key left right bytes trailing : List Nat)
        (before : ScannerNative.Whitespace leading) (nameBytes : CodeUnitContent name key)
        (beforeColon : ScannerNative.Whitespace left) (afterColon : ScannerNative.Whitespace right)
        (item : CodeUnitSpelling value bytes) (after : ScannerNative.Whitespace trailing) :
        CodeUnitMembers [(name, value)] (leading ++ [34] ++ key ++ [34] ++ left ++ [58] ++ right ++ bytes ++ trailing)
    | more (name : List Nat) (value : Value) (values : List (List Nat × Value))
        (leading key left right bytes spaces rest : List Nat) (nonempty : values ≠ [])
        (before : ScannerNative.Whitespace leading) (nameBytes : CodeUnitContent name key)
        (beforeColon : ScannerNative.Whitespace left) (afterColon : ScannerNative.Whitespace right)
        (item : CodeUnitSpelling value bytes) (between : ScannerNative.Whitespace spaces)
        (tail : CodeUnitMembers values rest) :
        CodeUnitMembers ((name, value) :: values)
          (leading ++ [34] ++ key ++ [34] ++ left ++ [58] ++ right ++ bytes ++ spaces ++ [44] ++ rest)
end

theorem CharacterEncoding.codeUnit {code : Nat} {input : List Nat} (encoding : CharacterEncoding code input) :
    CodeUnitEncoding code input := by
  cases encoding with
  | plain code printable ascii quote escape => exact .plain code printable (by omega) quote escape
  | short item code meaning => exact .short item code meaning
  | unicode a b c d ha hb hc hd ascii => exact .unicode a b c d ha hb hc hd

theorem StringContent.codeUnit {characters input : List Nat} (content : StringContent characters input) :
    CodeUnitContent characters input := by
  induction content with
  | nil => exact .nil
  | cons code characters spelling rest character tail ih => exact .cons code characters spelling rest character.codeUnit ih

mutual
  theorem WideValue.spelling (previous pending outgoing : Bool) (value normalized : Value) (input : List Nat)
      (normal : WideValue previous pending value input normalized outgoing) : CodeUnitSpelling value input := by
    cases normal with
    | null => exact .null
    | true => exact .true
    | false => exact .false
    | number _ _ valid => exact .number input valid
    | id _ first rest valid _ _ => exact .number (first :: rest) valid
    | string _ characters bytes content => exact .string characters bytes content
    | array _ values normalized bytes entries => exact .array values bytes (WideElements.spelling true false values normalized bytes entries)
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem WideElements.spelling (previous pending : Bool) (values normalized : List Value) (input : List Nat)
      (normal : WideElements previous pending values input normalized) : CodeUnitElements values input := by
    cases normal with
    | empty _ _ whitespace => exact .empty input whitespace
    | single _ _ value normalized leading bytes trailing before item after =>
        simpa only [List.append_assoc] using CodeUnitElements.single value leading bytes trailing before
          (WideValue.spelling previous pending false value normalized bytes item) after
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        simpa only [List.append_assoc] using CodeUnitElements.more value values leading bytes spaces rest nonempty before
          (WideValue.spelling previous pending outgoing value normalized bytes item) between
          (WideElements.spelling false outgoing values restNormalized rest tail)
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

theorem WideFields.original_spelling {index : Nat} {previous pending : Bool}
    {spans : List FieldSpan} {normalized : List Value} (normal : WideFields index previous pending spans normalized) :
    CodeUnitElements (spans.map FieldSpan.value) (fieldsBytes spans) := by
  induction normal with
  | last previous pending span normalized field =>
      cases field with
      | mk before value legal after =>
          simpa only [fieldsBytes, FieldSpan.bytes, List.map_cons, List.map_nil, List.append_assoc] using
            CodeUnitElements.single span.value span.leading span.body span.trailing before
              (WideValue.spelling previous pending false span.value normalized span.body value) after
  | more index previous pending outgoing span normalized spans restNormalized bounded field tail ih =>
      cases field with
      | mk before value legal after =>
          rw [fieldsBytes_cons span spans tail.nonempty.1]
          have nonempty : spans.map FieldSpan.value ≠ [] := by intro empty; exact tail.nonempty.1 (List.map_eq_nil_iff.mp empty)
          simpa only [FieldSpan.bytes, List.map_cons, List.append_assoc] using
            CodeUnitElements.more span.value (spans.map FieldSpan.value) span.leading span.body span.trailing (fieldsBytes spans)
              nonempty before (WideValue.spelling previous pending outgoing span.value normalized span.body value) after ih

theorem TheorySpan.original_spelling (span : TheorySpan) : CodeUnitSpelling span.theory.value span.bytes := by
  have entries := span.spelling.original_spelling
  rw [span.shape] at entries
  exact .array span.theory.fields (fieldsBytes span.spans) entries

mutual
  theorem AsciiSpelling.codeUnit (value : Value) (input : List Nat) (spelling : AsciiSpelling value input) :
      CodeUnitSpelling value input := by
    cases spelling with
    | null => exact .null
    | true => exact .true
    | false => exact .false
    | number _ valid => exact .number input valid
    | string characters bytes content => exact .string characters bytes content.codeUnit
    | array values bytes entries => exact .array values bytes (AsciiElements.codeUnit values bytes entries)
    | object members bytes entries => exact .object members bytes (AsciiMembers.codeUnit members bytes entries)
  termination_by input.length * 3
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem AsciiElements.codeUnit (values : List Value) (input : List Nat) (spelling : AsciiElements values input) :
      CodeUnitElements values input := by
    cases spelling with
    | empty _ whitespace => exact .empty input whitespace
    | single value leading bytes trailing before item after =>
        exact .single value leading bytes trailing before (AsciiSpelling.codeUnit value bytes item) after
    | more value values leading bytes spaces rest nonempty before item between tail =>
        exact .more value values leading bytes spaces rest nonempty before (AsciiSpelling.codeUnit value bytes item) between
          (AsciiElements.codeUnit values rest tail)
  termination_by input.length * 3 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem AsciiMembers.codeUnit (values : List (List Nat × Value)) (input : List Nat) (spelling : AsciiMembers values input) :
      CodeUnitMembers values input := by
    cases spelling with
    | empty _ whitespace => exact .empty input whitespace
    | single name value leading key left right bytes trailing before nameBytes beforeColon afterColon item after =>
        exact .single name value leading key left right bytes trailing before nameBytes.codeUnit beforeColon afterColon
          (AsciiSpelling.codeUnit value bytes item) after
    | more name value values leading key left right bytes spaces rest nonempty before nameBytes beforeColon afterColon item between tail =>
        exact .more name value values leading key left right bytes spaces rest nonempty before nameBytes.codeUnit beforeColon afterColon
          (AsciiSpelling.codeUnit value bytes item) between (AsciiMembers.codeUnit values rest tail)
  termination_by input.length * 3 + 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

end Silver.ImageModel.JSON
