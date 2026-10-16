module

public import Silver.ImageModelClone
public import Silver.IntegerImageTheory

@[expose] public section
namespace Silver.ImageModel.CloneMeaning
open JSON

/-- The finite typed substitution interface used by this refinement. The type
roles are checked alongside the three function roles; a function substitution
cannot stand in for a type substitution. -/
inductive Role | imageType | textType | scalarImage | stringImage | length
  deriving DecidableEq

abbrev Row := Option (List Nat) × Option (List Nat) × Option (List Nat) ×
  Option (List Nat) × Option (List Nat)

def row (value : Value) : Row :=
  (Clone.numberAt value [3], Clone.stringAt value [4, 3], Clone.stringAt value [5, 3],
    Clone.stringAt value [5, 5, 3], Clone.stringAt value [5, 5, 4])

def Role.row : Role → Row
  | .imageType => (some (ascii "0"), some (ascii "image"), some (ascii "__image"),
      some (ascii "_gnatprove_standard"), some (ascii "Main"))
  | .textType => (some (ascii "0"), some (ascii "text"), some (ascii "string__"),
      some (ascii ""), some (ascii "Standard__string"))
  | .scalarImage => (some (ascii "1"), some (ascii "scalar_image"), some (ascii "attr__ATTRIBUTE_IMAGE"),
      some (ascii ""), some (ascii "Standard__integer"))
  | .stringImage => (some (ascii "1"), some (ascii "string_image"), some (ascii "to_string"), none, none)
  | .length => (some (ascii "1"), some (ascii "length"), some (ascii "length"),
      some (ascii ""), some (ascii "Standard__string"))

def roles : List Role := [.imageType, .textType, .scalarImage, .stringImage, .length]

def decodeRole (value : Row) : Option Role := roles.find? (fun role => role.row == value)

/-- This is the concrete semantic instance of the two type substitutions and
three functions. Name resolution into this instance is valid only under the
complete selected producer schemas, as required by the final adapter endpoint.
The pinned external frontend supplies predefined Ada operation semantics; this
definition does not assume the additional Image length assertion. -/
structure Signature where
  scalarImage : Int → List Nat
  stringImage : List Nat → Int → Integer.Image.Refinement.StringValue
  length : Integer.Image.Refinement.StringValue → Int

def predefined : Signature where
  scalarImage := Integer.Image.bytes
  stringImage := Integer.Image.Refinement.toString
  length := Integer.Image.Refinement.StringValue.length

/-- The finite typed consumer interpretation for the emitted clone. Complete
clone shape, alias/import scope, and canonical theory identities are checked
separately; this projection checks every substituted type/function identity. -/
def interpret (substitutions : List Value) : Option Signature :=
  if substitutions.map (fun value => decodeRole (row value)) = roles.map some then
    some predefined
  else none

theorem clone_rows : Clone.substitutions.map row = roles.map Role.row := by
  exact Clone.substitution_selectors

theorem decoded_roles : (roles.map Role.row).map decodeRole = roles.map some := by
  decide +kernel

theorem clone_interpretation : interpret Clone.substitutions = some predefined := by
  have decoded : Clone.substitutions.map (fun value => decodeRole (row value)) = roles.map some := by
    simpa only [List.map_map, Function.comp_def] using
      (congrArg (List.map decodeRole) clone_rows).trans decoded_roles
  simp only [interpret, decoded, ↓reduceIte]

/-- The asserted size is exactly the producer's fixed Integer Image size 12.
No equation is claimed for arbitrary truncating size arguments. -/
def assertion (signature : Signature) (value : Int) : Prop :=
  -2147483648 ≤ value ∧ value ≤ 2147483647 →
    signature.length (signature.stringImage (signature.scalarImage value) 12) =
      1 + (Integer.Image.Theory.digits.eval value : Int)

theorem predefined_assertion (value : Int) : assertion predefined value :=
  Integer.Image.Theory.assertion_valid value

/-- Evaluating the actual five substitutions yields a proved assertion. Its
validity is a conclusion, not an interpretation or scanner premise. -/
theorem interpreted_assertion (signature : Signature)
    (decoded : interpret Clone.substitutions = some signature) (value : Int) :
    assertion signature value := by
  rw [clone_interpretation] at decoded
  cases Option.some.inj decoded
  exact predefined_assertion value

end Silver.ImageModel.CloneMeaning
