module

public import Silver.ImageModelMatcherDeath

@[expose] public section
namespace Silver.ImageModel.JSON

/-- The pinned Why AST producer emits integral JSON numbers; its arbitrary-
precision mathematical numbers are quoted strings. This syntax permits signed
integer tokens without introducing leading-zero spellings not admitted by JSON.
The separate node-ID domain is nonnegative and bounded by Original_Node_Id. -/
inductive IntegerToken : List Nat → Prop
  | zero : IntegerToken [48]
  | positive (first : Nat) (rest : List Nat) (nonzero : 49 ≤ first ∧ first ≤ 57)
      (digits : ScannerNative.decimalWord rest) : IntegerToken (first :: rest)
  | negativeZero : IntegerToken [45, 48]
  | negative (first : Nat) (rest : List Nat) (nonzero : 49 ≤ first ∧ first ≤ 57)
      (digits : ScannerNative.decimalWord rest) : IntegerToken (45 :: first :: rest)

theorem IntegerToken.nonempty {bytes : List Nat} (token : IntegerToken bytes) : bytes ≠ [] := by
  cases token <;> simp

theorem IntegerToken.no_delimiters {bytes : List Nat} (token : IntegerToken bytes) :
    ∀ byte ∈ bytes, ScannerNative.isDelimiter byte = false := by
  cases token with
  | zero | negativeZero => decide +kernel
  | positive first rest nonzero digits =>
      intro byte member
      rcases List.mem_cons.mp member with equal | member
      · apply ScannerNative.digit_not_delimiter
        omega
      · exact ScannerNative.digit_not_delimiter byte (digits byte member)
  | negative first rest nonzero digits =>
      intro byte member
      rcases List.mem_cons.mp member with equal | member
      · subst byte; decide +kernel
      rcases List.mem_cons.mp member with equal | member
      · apply ScannerNative.digit_not_delimiter
        omega
      · exact ScannerNative.digit_not_delimiter byte (digits byte member)

mutual
  /-- Whitespace and decoded string spelling are explicit in this ASCII grammar. Its
constructors describe syntax only and contain no scanner-state equations,
matching assumptions, or expected template identity. Numeric syntax is exactly
the integral subset emitted by the pinned Why producer. ASCII must be derived
from selected-theory liveness before this relation is used for such a theory. -/
  inductive AsciiSpelling : Value → List Nat → Prop
    | null : AsciiSpelling .null [110, 117, 108, 108]
    | true : AsciiSpelling (.boolean true) [116, 114, 117, 101]
    | false : AsciiSpelling (.boolean false) [102, 97, 108, 115, 101]
    | number (bytes : List Nat) (valid : IntegerToken bytes) : AsciiSpelling (.number bytes) bytes
    | string (characters bytes : List Nat) (content : StringContent characters bytes) :
        AsciiSpelling (.string characters) ([34] ++ bytes ++ [34])
    | array (values : List Value) (bytes : List Nat) (entries : AsciiElements values bytes) :
        AsciiSpelling (.array values) ([91] ++ bytes ++ [93])
    | object (values : List (List Nat × Value)) (bytes : List Nat) (members : AsciiMembers values bytes) :
        AsciiSpelling (.object values) ([123] ++ bytes ++ [125])

  inductive AsciiElements : List Value → List Nat → Prop
    | empty (spaces : List Nat) (whitespace : ScannerNative.Whitespace spaces) : AsciiElements [] spaces
    | single (value : Value) (leading bytes trailing : List Nat)
        (before : ScannerNative.Whitespace leading) (item : AsciiSpelling value bytes)
        (after : ScannerNative.Whitespace trailing) : AsciiElements [value] (leading ++ bytes ++ trailing)
    | more (value : Value) (values : List Value) (leading bytes spaces rest : List Nat)
        (nonempty : values ≠ []) (before : ScannerNative.Whitespace leading)
        (item : AsciiSpelling value bytes) (between : ScannerNative.Whitespace spaces)
        (tail : AsciiElements values rest) :
        AsciiElements (value :: values) (leading ++ bytes ++ spaces ++ [44] ++ rest)

  inductive AsciiMembers : List (List Nat × Value) → List Nat → Prop
    | empty (spaces : List Nat) (whitespace : ScannerNative.Whitespace spaces) : AsciiMembers [] spaces
    | single (name : List Nat) (value : Value) (leading key left right bytes trailing : List Nat)
        (before : ScannerNative.Whitespace leading) (nameBytes : StringContent name key)
        (beforeColon : ScannerNative.Whitespace left) (afterColon : ScannerNative.Whitespace right)
        (item : AsciiSpelling value bytes) (after : ScannerNative.Whitespace trailing) :
        AsciiMembers [(name, value)] (leading ++ [34] ++ key ++ [34] ++ left ++ [58] ++ right ++ bytes ++ trailing)
    | more (name : List Nat) (value : Value) (values : List (List Nat × Value))
        (leading key left right bytes spaces rest : List Nat) (nonempty : values ≠ [])
        (before : ScannerNative.Whitespace leading) (nameBytes : StringContent name key)
        (beforeColon : ScannerNative.Whitespace left) (afterColon : ScannerNative.Whitespace right)
        (item : AsciiSpelling value bytes) (between : ScannerNative.Whitespace spaces)
        (tail : AsciiMembers values rest) :
        AsciiMembers ((name, value) :: values)
          (leading ++ [34] ++ key ++ [34] ++ left ++ [58] ++ right ++ bytes ++ spaces ++ [44] ++ rest)
end

theorem AsciiSpelling.nonempty {value : Value} {bytes : List Nat} (spelling : AsciiSpelling value bytes) : bytes ≠ [] := by
  cases spelling with
  | null | true | false => simp
  | number bytes valid => exact valid.nonempty
  | string | array | object => simp

/-- Theory fields are the exact ordered fields of W_Theory_Declaration in both
the pinned producer and consumer: tag, ID, domain, declarations, name, kind,
includes and comment. The declaration/include fields are typed node lists. -/
structure Theory where
  id : List Nat
  domain : Value
  declarations : Option (List Value)
  name : List Nat
  kind : Value
  includes : Option (List Value)
  comment : Value

def nodeListValue : Option (List Value) → Value
  | none => .null
  | some values => .array values

def Theory.fields (theory : Theory) : List Value :=
  [.string (ascii "W_THEORY_DECLARATION"), .number theory.id, theory.domain,
   nodeListValue theory.declarations, .string theory.name, theory.kind, nodeListValue theory.includes, theory.comment]

def Theory.value (theory : Theory) : Value := .array theory.fields

def Document (theories : List Theory) : Value :=
  .object [(ascii "theory_declarations", .array (theories.map Theory.value))]

/-- This relation describes the serialized producer/consumer AST boundary.
Its syntax includes exactly one root member and a list of typed theories. The
scanner's own name/schema checks must still be derived from these spellings. -/
def DocumentAsciiSpelling (theories : List Theory) (input : List Nat) : Prop :=
  ∃ leading bytes trailing, ScannerNative.Whitespace leading ∧
    AsciiSpelling (Document theories) bytes ∧ ScannerNative.Whitespace trailing ∧
    input = leading ++ bytes ++ trailing

end Silver.ImageModel.JSON
