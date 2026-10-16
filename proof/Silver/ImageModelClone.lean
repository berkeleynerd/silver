module

public import Silver.ImageModelJsonSyntax
public import Silver.ImageModelInsertion
public import Init.Core
public import Init.Data.String.Basic
public meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

/-! The exact typed-JSON clone and include added to `Standard_String__Img`.
The declarations use the shared JSON syntax. Their encoded fragments retain
the leading commas consumed by the byte-splice implementation. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.Clone
open JSON

/-- The clone uses this finite set of numeric fields. Literal digit bytes avoid
expanding the standard printer's value-sized recursion for the inserted IDs. -/
def numeralTable : List (Nat × List Nat) := [
   (0, [48]),
   (1, [49]),
   (2, [50]),
   (2147483648, [50, 49, 52, 55, 52, 56, 51, 54, 52, 56]),
   (2147483649, [50, 49, 52, 55, 52, 56, 51, 54, 52, 57]),
   (2147483650, [50, 49, 52, 55, 52, 56, 51, 54, 53, 48]),
   (2147483651, [50, 49, 52, 55, 52, 56, 51, 54, 53, 49]),
   (2147483652, [50, 49, 52, 55, 52, 56, 51, 54, 53, 50]),
   (2147483653, [50, 49, 52, 55, 52, 56, 51, 54, 53, 51]),
   (2147483654, [50, 49, 52, 55, 52, 56, 51, 54, 53, 52]),
   (2147483655, [50, 49, 52, 55, 52, 56, 51, 54, 53, 53]),
   (2147483656, [50, 49, 52, 55, 52, 56, 51, 54, 53, 54]),
   (2147483657, [50, 49, 52, 55, 52, 56, 51, 54, 53, 55]),
   (2147483658, [50, 49, 52, 55, 52, 56, 51, 54, 53, 56]),
   (2147483659, [50, 49, 52, 55, 52, 56, 51, 54, 53, 57]),
   (2147483660, [50, 49, 52, 55, 52, 56, 51, 54, 54, 48]),
   (2147483661, [50, 49, 52, 55, 52, 56, 51, 54, 54, 49]),
   (2147483662, [50, 49, 52, 55, 52, 56, 51, 54, 54, 50]),
   (2147483663, [50, 49, 52, 55, 52, 56, 51, 54, 54, 51]),
   (2147483664, [50, 49, 52, 55, 52, 56, 51, 54, 54, 52]),
   (2147483665, [50, 49, 52, 55, 52, 56, 51, 54, 54, 53]),
   (2147483666, [50, 49, 52, 55, 52, 56, 51, 54, 54, 54]),
   (2147483667, [50, 49, 52, 55, 52, 56, 51, 54, 54, 55]),
   (2147483668, [50, 49, 52, 55, 52, 56, 51, 54, 54, 56]),
   (2147483669, [50, 49, 52, 55, 52, 56, 51, 54, 54, 57]),
   (2147483670, [50, 49, 52, 55, 52, 56, 51, 54, 55, 48])]

/-- Every entry is a nonempty canonical decimal token denoting its key. -/
theorem numeralTable_exact :
    numeralTable.all (fun entry =>
      !entry.2.isEmpty &&
      entry.2.all (fun digit => decide (48 ≤ digit ∧ digit ≤ 57)) &&
      decide (entry.2 = [48] ∨ entry.2.head? ≠ some 48) &&
      decide (entry.2.foldl (fun total digit => 10 * total + (digit - 48)) 0 = entry.1)) = true := by
  decide +kernel

/-- Domains, substitution kinds, clone/include kinds, and every inserted ID
have table entries. The fallback below is not used by the checked fragments. -/
theorem numeral_coverage :
    ([0, 1, 2] ++ (List.range insertedNodeCount).map (insertedIdFirst + ·)).all
      (fun value => (numeralTable.find? (fun (entry : Nat × List Nat) => entry.1 == value)).isSome) = true := by
  decide +kernel

def number (value : Nat) : Value :=
  .number (match numeralTable.find? (fun entry => entry.1 == value) with
    | some (_, digits) => digits
    | none => ascii (toString value))

def text (value : String) : Value := .string (ascii value)

def moduleNode (id : Nat) (file name : String) : Value :=
  .array [text "W_MODULE", number id, number 1, text file, text name]

def nameNode (id : Nat) (symbol : String) (owner : Value := .null) : Value :=
  .array [text "W_NAME", number id, number 1, text symbol, text "", owner, .boolean false]

def substitution (id kind : Nat) (source target : Value) : Value :=
  .array [text "W_CLONE_SUBSTITUTION", number id, number 1, number kind, source, target]

def imageSubstitution : Value :=
  substitution (insertedIdFirst + 6) 0
    (nameNode (insertedIdFirst + 4) "image")
    (nameNode (insertedIdFirst + 5) "__image"
      (moduleNode insertedIdFirst "_gnatprove_standard" "Main"))

def textSubstitution : Value :=
  substitution (insertedIdFirst + 9) 0
    (nameNode (insertedIdFirst + 7) "text")
    (nameNode (insertedIdFirst + 8) "string__"
      (moduleNode (insertedIdFirst + 1) "" "Standard__string"))

def scalarImageSubstitution : Value :=
  substitution (insertedIdFirst + 12) 1
    (nameNode (insertedIdFirst + 10) "scalar_image")
    (nameNode (insertedIdFirst + 11) "attr__ATTRIBUTE_IMAGE"
      (moduleNode (insertedIdFirst + 2) "" "Standard__integer"))

def stringImageSubstitution : Value :=
  substitution (insertedIdFirst + 15) 1
    (nameNode (insertedIdFirst + 13) "string_image")
    (nameNode (insertedIdFirst + 14) "to_string")

def lengthSubstitution : Value :=
  substitution (insertedIdFirst + 18) 1
    (nameNode (insertedIdFirst + 16) "length")
    (nameNode (insertedIdFirst + 17) "length"
      (moduleNode (insertedIdFirst + 3) "" "Standard__string"))

def substitutions : List Value :=
  [imageSubstitution, textSubstitution, scalarImageSubstitution,
    stringImageSubstitution, lengthSubstitution]

def declaration : Value :=
  .array [text "W_CLONE_DECLARATION", number (insertedIdFirst + 20), number 1,
    moduleNode (insertedIdFirst + 19) "silver_image" "Integer_Image_Length",
    text "Silver_Image", number 2, .array substitutions, number 1]

def includeDeclaration : Value :=
  .array [text "W_INCLUDE_DECLARATION", number (insertedIdFirst + 22), number 1,
    moduleNode (insertedIdFirst + 21) "" "Standard__integer", number 1, number 2]

def declarationsFragment : List Nat := [44] ++ declaration.encode

def includesFragment : List Nat := [44] ++ includeDeclaration.encode

/-- Array selectors use zero-based JSON field indices and fail on a wrong
shape. They do not identify `null` with an absent field. -/
def select (value : Value) : List Nat → Option Value
  | [] => some value
  | index :: rest =>
      match value with
      | .array values => (values[index]?).bind (fun item => select item rest)
      | _ => none

def stringAt (value : Value) (path : List Nat) : Option (List Nat) :=
  match select value path with
  | some (.string characters) => some characters
  | _ => none

def numberAt (value : Value) (path : List Nat) : Option (List Nat) :=
  match select value path with
  | some (.number digits) => some digits
  | _ => none

def arrayLengthAt (value : Value) (path : List Nat) : Option Nat :=
  match select value path with
  | some (.array values) => some values.length
  | _ => none

def encodedAt (value : Value) (path : List Nat) : Option (List Nat) :=
  (select value path).map Value.encode

theorem declaration_selectors :
    arrayLengthAt declaration [] = some 8 ∧
    stringAt declaration [0] = some (ascii "W_CLONE_DECLARATION") ∧
    numberAt declaration [1] = some (ascii "2147483668") ∧
    numberAt declaration [2] = some (ascii "1") ∧
    arrayLengthAt declaration [3] = some 5 ∧
    stringAt declaration [3, 0] = some (ascii "W_MODULE") ∧
    numberAt declaration [3, 1] = some (ascii "2147483667") ∧
    numberAt declaration [3, 2] = some (ascii "1") ∧
    stringAt declaration [3, 3] = some (ascii "silver_image") ∧
    stringAt declaration [3, 4] = some (ascii "Integer_Image_Length") ∧
    stringAt declaration [4] = some (ascii "Silver_Image") ∧
    numberAt declaration [5] = some (ascii "2") ∧
    arrayLengthAt declaration [6] = some 5 ∧
    numberAt declaration [7] = some (ascii "1") := by decide +kernel

theorem include_selectors :
    arrayLengthAt includeDeclaration [] = some 6 ∧
    stringAt includeDeclaration [0] = some (ascii "W_INCLUDE_DECLARATION") ∧
    numberAt includeDeclaration [1] = some (ascii "2147483670") ∧
    numberAt includeDeclaration [2] = some (ascii "1") ∧
    arrayLengthAt includeDeclaration [3] = some 5 ∧
    stringAt includeDeclaration [3, 0] = some (ascii "W_MODULE") ∧
    numberAt includeDeclaration [3, 1] = some (ascii "2147483669") ∧
    numberAt includeDeclaration [3, 2] = some (ascii "1") ∧
    stringAt includeDeclaration [3, 3] = some (ascii "") ∧
    stringAt includeDeclaration [3, 4] = some (ascii "Standard__integer") ∧
    numberAt includeDeclaration [4] = some (ascii "1") ∧
    numberAt includeDeclaration [5] = some (ascii "2") := by decide +kernel

/-- The two type substitutions precede the three function substitutions.
The unqualified `to_string` belongs to the Image theory receiving the clone. -/
theorem substitution_selectors :
    substitutions.map (fun item =>
      (numberAt item [3], stringAt item [4, 3], stringAt item [5, 3],
        stringAt item [5, 5, 3], stringAt item [5, 5, 4])) =
      [(some (ascii "0"), some (ascii "image"), some (ascii "__image"),
          some (ascii "_gnatprove_standard"), some (ascii "Main")),
       (some (ascii "0"), some (ascii "text"), some (ascii "string__"),
          some (ascii ""), some (ascii "Standard__string")),
       (some (ascii "1"), some (ascii "scalar_image"), some (ascii "attr__ATTRIBUTE_IMAGE"),
          some (ascii ""), some (ascii "Standard__integer")),
       (some (ascii "1"), some (ascii "string_image"), some (ascii "to_string"), none, none),
       (some (ascii "1"), some (ascii "length"), some (ascii "length"),
          some (ascii ""), some (ascii "Standard__string"))] := by
  rfl

theorem substitution_shapes :
    substitutions.map (fun item =>
      (arrayLengthAt item [], stringAt item [0], numberAt item [2],
        arrayLengthAt item [4], stringAt item [4, 0], numberAt item [4, 2],
        stringAt item [4, 4], encodedAt item [4, 5], encodedAt item [4, 6],
        arrayLengthAt item [5], stringAt item [5, 0], numberAt item [5, 2],
        stringAt item [5, 4], encodedAt item [5, 6])) =
      List.replicate 5
        (some 6, some (ascii "W_CLONE_SUBSTITUTION"), some (ascii "1"),
          some 7, some (ascii "W_NAME"), some (ascii "1"),
          some (ascii ""), some (ascii "null"), some (ascii "false"),
          some 7, some (ascii "W_NAME"), some (ascii "1"),
          some (ascii ""), some (ascii "false")) ∧
    encodedAt stringImageSubstitution [5, 5] = some (ascii "null") := by
  constructor <;>
    simp only [substitutions, imageSubstitution, textSubstitution,
      scalarImageSubstitution, stringImageSubstitution, lengthSubstitution,
      substitution, moduleNode, nameNode, number, text,
      arrayLengthAt, stringAt, numberAt, encodedAt, select,
      List.map_cons, List.map_nil, List.getElem?_cons_zero, List.getElem?_cons_succ,
      Option.bind_some, Option.map_some, Value.encode] <;>
    rfl

/-- Explicit character witnesses let the kernel check source spelling without
repeatedly decoding the long UTF-8 string literals. -/
def declarationsFragmentChars : List Char := [
    ',', '[', '"', 'W', '_', 'C', 'L', 'O', 'N', 'E', '_', 'D', 'E', 'C', 'L', 'A', 'R', 'A', 'T', 'I', 'O', 'N', '"', ',',
    '2', '1', '4', '7', '4', '8', '3', '6', '6', '8', ',', '1', ',', '[', '"', 'W', '_', 'M', 'O', 'D', 'U', 'L', 'E', '"',
    ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '7', ',', '1', ',', '"', 's', 'i', 'l', 'v', 'e', 'r', '_', 'i', 'm',
    'a', 'g', 'e', '"', ',', '"', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g',
    't', 'h', '"', ']', ',', '"', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '"', ',', '2', ',', '[', '[',
    '"', 'W', '_', 'C', 'L', 'O', 'N', 'E', '_', 'S', 'U', 'B', 'S', 'T', 'I', 'T', 'U', 'T', 'I', 'O', 'N', '"', ',', '2',
    '1', '4', '7', '4', '8', '3', '6', '5', '4', ',', '1', ',', '0', ',', '[', '"', 'W', '_', 'N', 'A', 'M', 'E', '"', ',',
    '2', '1', '4', '7', '4', '8', '3', '6', '5', '2', ',', '1', ',', '"', 'i', 'm', 'a', 'g', 'e', '"', ',', '"', '"', ',',
    'n', 'u', 'l', 'l', ',', 'f', 'a', 'l', 's', 'e', ']', ',', '[', '"', 'W', '_', 'N', 'A', 'M', 'E', '"', ',', '2', '1',
    '4', '7', '4', '8', '3', '6', '5', '3', ',', '1', ',', '"', '_', '_', 'i', 'm', 'a', 'g', 'e', '"', ',', '"', '"', ',',
    '[', '"', 'W', '_', 'M', 'O', 'D', 'U', 'L', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '4', '8', ',', '1',
    ',', '"', '_', 'g', 'n', 'a', 't', 'p', 'r', 'o', 'v', 'e', '_', 's', 't', 'a', 'n', 'd', 'a', 'r', 'd', '"', ',', '"',
    'M', 'a', 'i', 'n', '"', ']', ',', 'f', 'a', 'l', 's', 'e', ']', ']', ',', '[', '"', 'W', '_', 'C', 'L', 'O', 'N', 'E',
    '_', 'S', 'U', 'B', 'S', 'T', 'I', 'T', 'U', 'T', 'I', 'O', 'N', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '5',
    '7', ',', '1', ',', '0', ',', '[', '"', 'W', '_', 'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6',
    '5', '5', ',', '1', ',', '"', 't', 'e', 'x', 't', '"', ',', '"', '"', ',', 'n', 'u', 'l', 'l', ',', 'f', 'a', 'l', 's',
    'e', ']', ',', '[', '"', 'W', '_', 'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '5', '6', ',',
    '1', ',', '"', 's', 't', 'r', 'i', 'n', 'g', '_', '_', '"', ',', '"', '"', ',', '[', '"', 'W', '_', 'M', 'O', 'D', 'U',
    'L', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '4', '9', ',', '1', ',', '"', '"', ',', '"', 'S', 't', 'a',
    'n', 'd', 'a', 'r', 'd', '_', '_', 's', 't', 'r', 'i', 'n', 'g', '"', ']', ',', 'f', 'a', 'l', 's', 'e', ']', ']', ',',
    '[', '"', 'W', '_', 'C', 'L', 'O', 'N', 'E', '_', 'S', 'U', 'B', 'S', 'T', 'I', 'T', 'U', 'T', 'I', 'O', 'N', '"', ',',
    '2', '1', '4', '7', '4', '8', '3', '6', '6', '0', ',', '1', ',', '1', ',', '[', '"', 'W', '_', 'N', 'A', 'M', 'E', '"',
    ',', '2', '1', '4', '7', '4', '8', '3', '6', '5', '8', ',', '1', ',', '"', 's', 'c', 'a', 'l', 'a', 'r', '_', 'i', 'm',
    'a', 'g', 'e', '"', ',', '"', '"', ',', 'n', 'u', 'l', 'l', ',', 'f', 'a', 'l', 's', 'e', ']', ',', '[', '"', 'W', '_',
    'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '5', '9', ',', '1', ',', '"', 'a', 't', 't', 'r',
    '_', '_', 'A', 'T', 'T', 'R', 'I', 'B', 'U', 'T', 'E', '_', 'I', 'M', 'A', 'G', 'E', '"', ',', '"', '"', ',', '[', '"',
    'W', '_', 'M', 'O', 'D', 'U', 'L', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '5', '0', ',', '1', ',', '"',
    '"', ',', '"', 'S', 't', 'a', 'n', 'd', 'a', 'r', 'd', '_', '_', 'i', 'n', 't', 'e', 'g', 'e', 'r', '"', ']', ',', 'f',
    'a', 'l', 's', 'e', ']', ']', ',', '[', '"', 'W', '_', 'C', 'L', 'O', 'N', 'E', '_', 'S', 'U', 'B', 'S', 'T', 'I', 'T',
    'U', 'T', 'I', 'O', 'N', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '3', ',', '1', ',', '1', ',', '[', '"',
    'W', '_', 'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '1', ',', '1', ',', '"', 's', 't',
    'r', 'i', 'n', 'g', '_', 'i', 'm', 'a', 'g', 'e', '"', ',', '"', '"', ',', 'n', 'u', 'l', 'l', ',', 'f', 'a', 'l', 's',
    'e', ']', ',', '[', '"', 'W', '_', 'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '2', ',',
    '1', ',', '"', 't', 'o', '_', 's', 't', 'r', 'i', 'n', 'g', '"', ',', '"', '"', ',', 'n', 'u', 'l', 'l', ',', 'f', 'a',
    'l', 's', 'e', ']', ']', ',', '[', '"', 'W', '_', 'C', 'L', 'O', 'N', 'E', '_', 'S', 'U', 'B', 'S', 'T', 'I', 'T', 'U',
    'T', 'I', 'O', 'N', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '6', ',', '1', ',', '1', ',', '[', '"', 'W',
    '_', 'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '4', ',', '1', ',', '"', 'l', 'e', 'n',
    'g', 't', 'h', '"', ',', '"', '"', ',', 'n', 'u', 'l', 'l', ',', 'f', 'a', 'l', 's', 'e', ']', ',', '[', '"', 'W', '_',
    'N', 'A', 'M', 'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '5', ',', '1', ',', '"', 'l', 'e', 'n', 'g',
    't', 'h', '"', ',', '"', '"', ',', '[', '"', 'W', '_', 'M', 'O', 'D', 'U', 'L', 'E', '"', ',', '2', '1', '4', '7', '4',
    '8', '3', '6', '5', '1', ',', '1', ',', '"', '"', ',', '"', 'S', 't', 'a', 'n', 'd', 'a', 'r', 'd', '_', '_', 's', 't',
    'r', 'i', 'n', 'g', '"', ']', ',', 'f', 'a', 'l', 's', 'e', ']', ']', ']', ',', '1', ']']

def declarationsFragmentBytes : List Nat := declarationsFragmentChars.map Char.toNat

def includesFragmentChars : List Char := [
    ',', '[', '"', 'W', '_', 'I', 'N', 'C', 'L', 'U', 'D', 'E', '_', 'D', 'E', 'C', 'L', 'A', 'R', 'A', 'T', 'I', 'O', 'N',
    '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '7', '0', ',', '1', ',', '[', '"', 'W', '_', 'M', 'O', 'D', 'U', 'L',
    'E', '"', ',', '2', '1', '4', '7', '4', '8', '3', '6', '6', '9', ',', '1', ',', '"', '"', ',', '"', 'S', 't', 'a', 'n',
    'd', 'a', 'r', 'd', '_', '_', 'i', 'n', 't', 'e', 'g', 'e', 'r', '"', ']', ',', '1', ',', '2', ']']

def includesFragmentBytes : List Nat := includesFragmentChars.map Char.toNat

theorem declarationsFragment_bytes : declarationsFragment = declarationsFragmentBytes := by
  simp only [declarationsFragment, declaration, substitutions,
    imageSubstitution, textSubstitution, scalarImageSubstitution,
    stringImageSubstitution, lengthSubstitution, substitution, moduleNode,
    nameNode, number, text, Value.encode, List.map_cons, List.map_nil] <;>
    decide +kernel

theorem includesFragment_bytes : includesFragment = includesFragmentBytes := by
  simp only [includesFragment, includeDeclaration, moduleNode, number, text,
    Value.encode, List.map_cons, List.map_nil] <;>
    decide +kernel

theorem declarationsFragment_spelling :
    ",[\"W_CLONE_DECLARATION\",2147483668,1,[\"W_MODULE\",2147483667,1,\"silver_image\",\"Integer_Image_Length\"],\"Silver_Image\",2,[[\"W_CLONE_SUBSTITUTION\",2147483654,1,0,[\"W_NAME\",2147483652,1,\"image\",\"\",null,false],[\"W_NAME\",2147483653,1,\"__image\",\"\",[\"W_MODULE\",2147483648,1,\"_gnatprove_standard\",\"Main\"],false]],[\"W_CLONE_SUBSTITUTION\",2147483657,1,0,[\"W_NAME\",2147483655,1,\"text\",\"\",null,false],[\"W_NAME\",2147483656,1,\"string__\",\"\",[\"W_MODULE\",2147483649,1,\"\",\"Standard__string\"],false]],[\"W_CLONE_SUBSTITUTION\",2147483660,1,1,[\"W_NAME\",2147483658,1,\"scalar_image\",\"\",null,false],[\"W_NAME\",2147483659,1,\"attr__ATTRIBUTE_IMAGE\",\"\",[\"W_MODULE\",2147483650,1,\"\",\"Standard__integer\"],false]],[\"W_CLONE_SUBSTITUTION\",2147483663,1,1,[\"W_NAME\",2147483661,1,\"string_image\",\"\",null,false],[\"W_NAME\",2147483662,1,\"to_string\",\"\",null,false]],[\"W_CLONE_SUBSTITUTION\",2147483666,1,1,[\"W_NAME\",2147483664,1,\"length\",\"\",null,false],[\"W_NAME\",2147483665,1,\"length\",\"\",[\"W_MODULE\",2147483651,1,\"\",\"Standard__string\"],false]]],1]" = String.ofList declarationsFragmentChars := by
  kernel_exact (Eq.refl (String.ofList declarationsFragmentChars))

theorem includesFragment_spelling :
    ",[\"W_INCLUDE_DECLARATION\",2147483670,1,[\"W_MODULE\",2147483669,1,\"\",\"Standard__integer\"],1,2]" = String.ofList includesFragmentChars := by
  kernel_exact (Eq.refl (String.ofList includesFragmentChars))

theorem declarationsFragment_eq : declarationsFragment = ascii
    ",[\"W_CLONE_DECLARATION\",2147483668,1,[\"W_MODULE\",2147483667,1,\"silver_image\",\"Integer_Image_Length\"],\"Silver_Image\",2,[[\"W_CLONE_SUBSTITUTION\",2147483654,1,0,[\"W_NAME\",2147483652,1,\"image\",\"\",null,false],[\"W_NAME\",2147483653,1,\"__image\",\"\",[\"W_MODULE\",2147483648,1,\"_gnatprove_standard\",\"Main\"],false]],[\"W_CLONE_SUBSTITUTION\",2147483657,1,0,[\"W_NAME\",2147483655,1,\"text\",\"\",null,false],[\"W_NAME\",2147483656,1,\"string__\",\"\",[\"W_MODULE\",2147483649,1,\"\",\"Standard__string\"],false]],[\"W_CLONE_SUBSTITUTION\",2147483660,1,1,[\"W_NAME\",2147483658,1,\"scalar_image\",\"\",null,false],[\"W_NAME\",2147483659,1,\"attr__ATTRIBUTE_IMAGE\",\"\",[\"W_MODULE\",2147483650,1,\"\",\"Standard__integer\"],false]],[\"W_CLONE_SUBSTITUTION\",2147483663,1,1,[\"W_NAME\",2147483661,1,\"string_image\",\"\",null,false],[\"W_NAME\",2147483662,1,\"to_string\",\"\",null,false]],[\"W_CLONE_SUBSTITUTION\",2147483666,1,1,[\"W_NAME\",2147483664,1,\"length\",\"\",null,false],[\"W_NAME\",2147483665,1,\"length\",\"\",[\"W_MODULE\",2147483651,1,\"\",\"Standard__string\"],false]]],1]" := by
  rw [declarationsFragment_bytes, declarationsFragment_spelling]
  simp only [declarationsFragmentBytes, ascii, String.toList_ofList]

theorem includesFragment_eq : includesFragment = ascii
    ",[\"W_INCLUDE_DECLARATION\",2147483670,1,[\"W_MODULE\",2147483669,1,\"\",\"Standard__integer\"],1,2]" := by
  rw [includesFragment_bytes, includesFragment_spelling]
  simp only [includesFragmentBytes, ascii, String.toList_ofList]

theorem fragment_lengths : declarationsFragment.length = 1002 ∧
    includesFragment.length = 92 := by
  rw [declarationsFragment_bytes, includesFragment_bytes]
  decide +kernel

/-- Only a W-tagged array with a nonempty decimal ID token contributes an ID.
The traversal below still visits every nested array and object value. -/
def nodeId : Value → Option Nat
  | .array (.string tag :: .number digits :: _) =>
      if nodeTag tag && !digits.isEmpty && digits.all (fun digit => decide (48 ≤ digit ∧ digit ≤ 57)) then
        some (digits.foldl (fun total digit => 10 * total + (digit - 48)) 0)
      else none
  | _ => none

def nodeIds : Value → List Nat
  | .array values => (nodeId (.array values)).toList ++ values.flatMap nodeIds
  | .object members => members.flatMap (fun member => nodeIds member.2)
  | _ => []
decreasing_by
  all_goals first | decreasing_tactic | skip
  have small := List.sizeOf_lt_of_mem ‹_ ∈ members›
  rcases member with ⟨name, value⟩
  simp only [Prod.mk.sizeOf_spec] at small
  simp only [Value.object.sizeOf_spec]
  omega

theorem declaration_nodeIds : nodeIds declaration =
    [2147483668, 2147483667, 2147483654, 2147483652, 2147483653, 2147483648,
     2147483657, 2147483655, 2147483656, 2147483649,
     2147483660, 2147483658, 2147483659, 2147483650,
     2147483663, 2147483661, 2147483662,
     2147483666, 2147483664, 2147483665, 2147483651] := by
  simp only [declaration, substitutions, imageSubstitution, textSubstitution,
    scalarImageSubstitution, stringImageSubstitution, lengthSubstitution,
    substitution, moduleNode, nameNode, number, text,
    nodeIds, List.flatMap_cons, List.flatMap_nil] <;>
    decide +kernel

theorem include_nodeIds : nodeIds includeDeclaration = [2147483670, 2147483669] := by
  simp only [includeDeclaration, moduleNode, number, text,
    nodeIds, List.flatMap_cons, List.flatMap_nil] <;>
    decide +kernel

def insertedIds : List Nat := nodeIds declaration ++ nodeIds includeDeclaration

theorem inserted_ids_unique : insertedIds.Nodup := by
  rw [insertedIds, declaration_nodeIds, include_nodeIds]
  decide +kernel

theorem inserted_ids_count : insertedIds.length = insertedNodeCount := by
  rw [insertedIds, declaration_nodeIds, include_nodeIds]
  decide +kernel

theorem inserted_ids_bounded : insertedIds.all (fun id =>
    decide (insertedIdFirst ≤ id ∧ id < insertedIdFirst + insertedNodeCount)) = true := by
  rw [insertedIds, declaration_nodeIds, include_nodeIds]
  decide +kernel

theorem inserted_ids_covered : ∀ index : Fin insertedNodeCount,
    insertedIdFirst + index.val ∈ insertedIds := by
  rw [insertedIds, declaration_nodeIds, include_nodeIds]
  decide +kernel

theorem inserted_ids_membership (id : Nat) :
    id ∈ insertedIds ↔ insertedIdFirst ≤ id ∧ id < insertedIdFirst + insertedNodeCount := by
  constructor
  · intro member
    have bounded := List.all_eq_true.mp inserted_ids_bounded id member
    exact of_decide_eq_true bounded
  · intro ⟨lower, upper⟩
    have within : id - insertedIdFirst < insertedNodeCount := by omega
    have covered := inserted_ids_covered ⟨id - insertedIdFirst, within⟩
    have restored : insertedIdFirst + (id - insertedIdFirst) = id := by omega
    simpa only [restored] using covered

theorem inserted_ids_fresh {original id : Nat}
    (bounded : original ≤ originalIdMaximum) (member : id ∈ insertedIds) :
    original < id ∧ id ≤ consumerIdMaximum := by
  obtain ⟨lower, upper⟩ := (inserted_ids_membership id).mp member
  have within : id - insertedIdFirst < insertedNodeCount := by omega
  have fresh := inserted_id_fresh bounded within
  have restored : insertedIdFirst + (id - insertedIdFirst) = id := by omega
  simpa only [restored] using fresh

end Silver.ImageModel.Clone
