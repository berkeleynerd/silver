module

public import Silver.ImageModelDecodedNative

@[expose] public section
namespace Silver.ImageModel.JSON

/-- JSON values retain numeric token spelling. This avoids assuming any
rounding or canonicalization by an external numeric library. The selected
producer schemas use integer tokens; their concrete spellings are checked. -/
inductive Value
  | null | boolean (value : Bool) | number (lexeme : List Nat) | string (characters : List Nat)
  | array (values : List Value) | object (members : List (List Nat × Value))
  deriving Inhabited

def ascii (text : String) : List Nat := text.toList.map Char.toNat

def stringBytes (characters : List Nat) : List Nat :=
  [34] ++ characters.flatMap DecodedNative.normalizedCode ++ [34]

def separated (parts : List (List Nat)) : List Nat := (parts.intersperse [44]).flatten

/-- Canonical JSON serialization on the ASCII domain used by selected theory
schemas. Other values are still representable; encoding claims explicitly
require ASCII strings and valid number tokens. -/
def Value.encode : Value → List Nat
  | .null => [110, 117, 108, 108]
  | .boolean true => [116, 114, 117, 101]
  | .boolean false => [102, 97, 108, 115, 101]
  | .number lexeme => lexeme
  | .string characters => stringBytes characters
  | .array values => [91] ++ separated (values.map Value.encode) ++ [93]
  | .object members => [123] ++ separated (members.map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode)) ++ [125]
decreasing_by
  all_goals first | decreasing_tactic | skip
  have small := List.sizeOf_lt_of_mem ‹_ ∈ members›
  rcases member with ⟨name, value⟩
  simp only [Prod.mk.sizeOf_spec] at small
  simp only [Value.object.sizeOf_spec]
  omega

def nodeTag (characters : List Nat) : Bool := characters.take 2 == [87, 95]

/-- Native normalization erases only the second field of a W-tagged array.
Every other field, string value, array entry, and object member is retained. -/
def Value.eraseNodeIds : Value → Value
  | .array (.string tag :: .number digits :: rest) =>
      if nodeTag tag then .array (.string tag :: .number [48] :: rest.map Value.eraseNodeIds)
      else .array (.string tag :: .number digits :: rest.map Value.eraseNodeIds)
  | .array values => .array (values.map Value.eraseNodeIds)
  | .object members => .object (members.map (fun member => (member.1, member.2.eraseNodeIds)))
  | value => value
decreasing_by
  all_goals first | decreasing_tactic | skip
  have small := List.sizeOf_lt_of_mem ‹_ ∈ members›
  rcases member with ⟨name, value⟩
  simp only [Prod.mk.sizeOf_spec] at small
  simp only [Value.object.sizeOf_spec]
  omega

end Silver.ImageModel.JSON
