module

public import Silver.ImageModelJsonCanonical

@[expose] public section
namespace Silver.ImageModel.JSON

/-- Semantic JSON on the integral producer fragment. Number lexemes are
interpreted as mathematical integers, so `-0` and `0` have the same meaning.
Object member order and duplicate keys are retained explicitly. -/
inductive Meaning
  | null | boolean (value : Bool) | number (value : Int) | string (characters : List Nat)
  | array (values : List Meaning) | object (members : List (List Nat × Meaning))
  deriving Inhabited

/-- This projection is used only with independently valid integer syntax.
It does not assert that any particular finite external parser accepts an
arbitrarily large mathematical integer. -/
def integerMeaning : List Nat → Int
  | 45 :: digits => -(Int.ofNat (ScannerNative.decimalFold 0 digits))
  | digits => Int.ofNat (ScannerNative.decimalFold 0 digits)

def Value.meaning : Value → Meaning
  | .null => .null
  | .boolean value => .boolean value
  | .number digits => .number (integerMeaning digits)
  | .string characters => .string characters
  | .array values => .array (values.map Value.meaning)
  | .object members => .object (members.map (fun member => (member.1, member.2.meaning)))
decreasing_by
  all_goals first | decreasing_tactic | skip
  have small := List.sizeOf_lt_of_mem ‹_ ∈ members›
  rcases member with ⟨name, value⟩
  simp only [Prod.mk.sizeOf_spec] at small
  simp only [Value.object.sizeOf_spec]
  omega

theorem integerMeaning_negative_zero : integerMeaning [45, 48] = integerMeaning [48] := by
  decide +kernel

/-- Named external parser boundary: successful parses of independently valid
spellings have their mathematical meaning. It is a parameter, not an axiom,
and makes no universal parsing-success claim. -/
def ParserSound (parse : List Nat → Option Meaning) : Prop :=
  ∀ value input parsed, AsciiSpelling value input →
    parse input = some parsed → parsed = value.meaning

/-- Equal canonical bytes identify semantic values when the selected concrete
template parses with its expected meaning. No injectivity of numeric token
spellings, or successful parsing of all unbounded integer tokens, is assumed. -/
theorem ParserSound.canonical_eq {parse : List Nat → Option Meaning}
    (sound : ParserSound parse) {value template : Value}
    (valid : Valid value) (parsed : parse template.encode = some template.meaning)
    (equal : value.encode = template.encode) : value.meaning = template.meaning := by
  exact (sound value value.encode template.meaning valid.canonical (by rw [equal]; exact parsed)).symm

theorem ParserSound.spelling_eq {parse : List Nat → Option Meaning}
    (sound : ParserSound parse) {value : Value} {input : List Nat} {parsed : Meaning}
    (spelling : AsciiSpelling value input) (success : parse input = some parsed) :
    value.meaning = parsed :=
  (sound value input parsed spelling success).symm

def Value.field (value : Value) (index : Nat) : Value :=
  match value with
  | .array values => values[index]?.getD .null
  | _ => .null

def Meaning.field (value : Meaning) (index : Nat) : Meaning :=
  match value with
  | .array values => values[index]?.getD .null
  | _ => .null

def Value.path (value : Value) (indices : List Nat) : Value := indices.foldl Value.field value
def Meaning.path (value : Meaning) (indices : List Nat) : Meaning := indices.foldl Meaning.field value

def Value.arraySize : Value → Nat
  | .array values => values.length
  | _ => 0

def Meaning.arraySize : Meaning → Nat
  | .array values => values.length
  | _ => 0

def Value.string? : Value → Option (List Nat)
  | .string characters => some characters
  | _ => none

def Meaning.string? : Meaning → Option (List Nat)
  | .string characters => some characters
  | _ => none

def Value.integer? : Value → Option Int
  | .number digits => some (integerMeaning digits)
  | _ => none

def Meaning.integer? : Meaning → Option Int
  | .number value => some value
  | _ => none

theorem Value.meaning_field (value : Value) (index : Nat) :
    (value.field index).meaning = value.meaning.field index := by
  cases value <;> simp only [Value.field, Value.meaning, Meaning.field]
  rename_i values
  rw [List.getElem?_map]
  cases values[index]? with
  | none => simp only [Option.getD_none, Option.map_none, Value.meaning]
  | some value => rfl

theorem Value.meaning_path (value : Value) (indices : List Nat) :
    (value.path indices).meaning = value.meaning.path indices := by
  induction indices generalizing value with
  | nil => rfl
  | cons index indices ih =>
      simpa only [Value.path, Meaning.path, List.foldl_cons, Value.meaning_field] using
        ih (value.field index)

theorem Value.meaning_arraySize (value : Value) : value.meaning.arraySize = value.arraySize := by
  cases value <;> simp only [Value.meaning, Meaning.arraySize, Value.arraySize, List.length_map]

theorem Value.meaning_string (value : Value) : value.meaning.string? = value.string? := by
  cases value <;> simp only [Value.meaning, Meaning.string?, Value.string?]

theorem Value.meaning_integer (value : Value) : value.meaning.integer? = value.integer? := by
  cases value <;> simp only [Value.meaning, Meaning.integer?, Value.integer?]

theorem meaning_array_length {left right : List Value}
    (equal : (Value.array left).meaning = (Value.array right).meaning) : left.length = right.length := by
  have sizes := congrArg Meaning.arraySize equal
  simpa only [Value.meaning_arraySize, Value.arraySize] using sizes

theorem meaning_array_nonempty {left right : List Value}
    (equal : (Value.array left).meaning = (Value.array right).meaning)
    (nonempty : right ≠ []) : left ≠ [] := by
  have lengths := meaning_array_length equal
  intro empty
  subst left
  have rightEmpty : right = [] := by simpa using lengths.symm
  exact nonempty rightEmpty

theorem NormalElements.lengths {previous pending : Bool} {values normalized : List Value}
    {input : List Nat} (normal : NormalElements previous pending values input normalized) :
    values.length = normalized.length := by
  cases normal with
  | empty | single => rfl
  | more _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail =>
      simpa only [List.length_cons] using congrArg (fun size => size + 1) (NormalElements.lengths tail)
termination_by values.length

theorem NormalValue.arraySize {previous pending outgoing : Bool} {value normalized : Value}
    {input : List Nat} (normal : NormalValue previous pending value input normalized outgoing) :
    value.arraySize = normalized.arraySize := by
  cases normal with
  | array _ _ _ _ entries => exact entries.lengths
  | null | true | false | number | id | string => rfl

/-- Semantic equality preserves arbitrary nested array selection, including
typed integer and string readings and the size of a selected array. -/
theorem meaning_selectors {left right : Value} (equal : left.meaning = right.meaning)
    (indices : List Nat) :
    (left.path indices).meaning = (right.path indices).meaning ∧
    (left.path indices).arraySize = (right.path indices).arraySize ∧
    (left.path indices).string? = (right.path indices).string? ∧
    (left.path indices).integer? = (right.path indices).integer? := by
  have selected : (left.path indices).meaning = (right.path indices).meaning := by
    rw [Value.meaning_path, Value.meaning_path, equal]
  refine ⟨selected, ?_, ?_, ?_⟩
  · simpa only [Value.meaning_arraySize] using congrArg Meaning.arraySize selected
  · simpa only [Value.meaning_string] using congrArg Meaning.string? selected
  · simpa only [Value.meaning_integer] using congrArg Meaning.integer? selected

end Silver.ImageModel.JSON
