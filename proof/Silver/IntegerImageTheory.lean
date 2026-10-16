module

public import Silver.IntegerImageRefinement
public import Silver.ImageTheorySpecSource
public import Init.Data.String.Basic
public meta import Silver.CertificateWitness
import all Init.Data.Nat.ToString
import all Init.Data.Char.Basic

@[expose] public section

/-! Typed decimal-threshold expressions, their native theorem rendering, and
exact correspondence with the SPARK constant consumed by the planned adapter.
The target WhyML assertion is proved here; the token `axiom` in that external
representation does not introduce a Lean axiom. Its use at the native boundary
still requires the typed primitive-identity and insertion correspondence. -/
set_option maxRecDepth 10000

namespace Silver.Integer.Image.Theory

inductive Digits where
  | literal (value : Nat)
  | within (limit digits : Nat) (otherwise : Digits)
  deriving DecidableEq

def Digits.eval (value : Int) : Digits → Nat
  | .literal digits => digits
  | .within limit digits otherwise =>
    if -(limit : Int) < value ∧ value < (limit : Int) then digits
    else otherwise.eval value

/-- Only this finite theorem's numeric fields need printing. Literal text avoids
expanding the standard numeral printer's value-sized recursion in the kernel. -/
def numeralTable : List (Nat × String) :=
  [(1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5"), (6, "6"),
   (7, "7"), (8, "8"), (9, "9"), (10, "10"), (100, "100"),
   (1000, "1000"), (10000, "10000"), (100000, "100000"),
   (1000000, "1000000"), (10000000, "10000000"),
   (100000000, "100000000"), (1000000000, "1000000000")]

def numeral (value : Nat) : String :=
  ((numeralTable.find? (fun entry => entry.1 == value)).map Prod.snd).getD ""

theorem numeralTable_exact :
    numeralTable.all (fun entry =>
      decide (Nat.ofDigitChars 10 entry.2.toList 0 = entry.1) &&
        entry.2.toList.all Char.isDigit) = true := by
  decide +kernel

def Digits.render : Digits → List Char
  | .literal digits => (numeral digits).toList
  | .within limit digits otherwise =>
    "(if -".toList ++ (numeral limit).toList ++ " < v /\\ v < ".toList ++
      (numeral limit).toList ++ " then ".toList ++ (numeral digits).toList ++
      " else ".toList ++ otherwise.render ++ [')']

def ofTable (table : List (Nat × Nat)) (fallback : Nat) : Digits :=
  match table with
  | [] => .literal fallback
  | (limit, digits) :: rest => .within limit digits (ofTable rest fallback)

theorem eval_ofTable (value : Int) (table : List (Nat × Nat)) (fallback : Nat) :
    (ofTable table fallback).eval value = selectSigned value table fallback := by
  induction table with
  | nil => rfl
  | cons item rest ih =>
    rcases item with ⟨limit, digits⟩
    simp only [ofTable, Digits.eval, selectSigned, ih]

def digits : Digits := ofTable digitTable 10

def Digits.numerals : Digits → List Nat
  | .literal value => [value]
  | .within limit count otherwise => limit :: count :: otherwise.numerals

theorem numeral_coverage :
    digits.numerals.all (fun value => (numeralTable.find? (fun entry => entry.1 == value)).isSome) = true := by
  decide +kernel

/-- The interpretation fixes both the bound guard and the native size argument.
In particular it makes no claim about arbitrary sizes, including size zero. -/
def assertion (value : Int) : Prop :=
  -2147483648 ≤ value ∧ value ≤ 2147483647 →
    (Refinement.toString (bytes value) 12).length = 1 + (digits.eval value : Int)

theorem assertion_valid (value : Int) : assertion value := by
  intro bounded
  have inRange : InRange value := bounded
  rw [Refinement.integer_length_refinement value inRange]
  simp only [nativeLength, digits, eval_ofTable]

def lines : List (List Char) :=
  ["module Integer_Image_Length".toList, "use int.Int".toList,
   "type image".toList, "type text".toList,
   "function scalar_image (v : int) : image".toList,
   "function string_image (x : image) (size : int) : text".toList,
   "function length (x : text) : int".toList, "axiom checked_length:".toList,
   "  forall v : int. -2147483648 <= v /\\ v <= 2147483647 ->".toList,
   "    length (string_image (scalar_image v) 12) = 1 + ".toList ++ digits.render,
   "end".toList]

def joinWith (separator : List Char) : List (List Char) → List Char
  | [] => []
  | [line] => line
  | line :: rest => line ++ separator ++ joinWith separator rest

def text : String := String.ofList (joinWith ['\n'] lines ++ ['\n'])

/-- The concrete theorem lines need no escaping inside Ada string delimiters. -/
theorem lines_quotable :
    lines.all (fun line => line.all (fun c => c != '"' && c != '\n')) = true := by
  decide +kernel

def quoteAda (value : List Char) : List Char := ['"'] ++ value ++ ['"']

def sourceChars : List Char :=
  "package Silver_Image_Theory with SPARK_Mode => On is\n".toList ++
  "   --  Native proof representation of the checked Lean Image length theorem.\n".toList ++
  "   --  The typed producer adapter must establish the clone symbol identities.\n".toList ++
  "   Theory_Text : constant String :=\n     ".toList ++
  joinWith " & Character'Val (10) &\n     ".toList (lines.map quoteAda) ++
  " & Character'Val (10);\nend Silver_Image_Theory;\n".toList

def sourceText : String := String.ofList sourceChars

/-- Exact byte reconstruction via character lists avoids repeatedly decoding a
large UTF-8 literal during kernel reduction. Every witness remains checked. -/
theorem authoritative_source : Source.imageTheorySpec = sourceText := by
  have rendered : sourceChars = ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'T', 'h', 'e', 'o', 'r', 'y', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'N', 'a', 't', 'i', 'v', 'e', ' ', 'p', 'r', 'o', 'o', 'f', ' ', 'r', 'e', 'p', 'r', 'e', 's', 'e', 'n', 't', 'a', 't', 'i', 'o', 'n', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', 'L', 'e', 'a', 'n', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'l', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'o', 'r', 'e', 'm', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'T', 'h', 'e', ' ', 't', 'y', 'p', 'e', 'd', ' ', 'p', 'r', 'o', 'd', 'u', 'c', 'e', 'r', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'm', 'u', 's', 't', ' ', 'e', 's', 't', 'a', 'b', 'l', 'i', 's', 'h', ' ', 't', 'h', 'e', ' ', 'c', 'l', 'o', 'n', 'e', ' ', 's', 'y', 'm', 'b', 'o', 'l', ' ', 'i', 'd', 'e', 'n', 't', 'i', 't', 'i', 'e', 's', '.', '\n', ' ', ' ', ' ', 'T', 'h', 'e', 'o', 'r', 'y', '_', 'T', 'e', 'x', 't', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', ':', '=', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'm', 'o', 'd', 'u', 'l', 'e', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'u', 's', 'e', ' ', 'i', 'n', 't', '.', 'I', 'n', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 't', 'y', 'p', 'e', ' ', 'i', 'm', 'a', 'g', 'e', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 't', 'y', 'p', 'e', ' ', 't', 'e', 'x', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 's', 'c', 'a', 'l', 'a', 'r', '_', 'i', 'm', 'a', 'g', 'e', ' ', '(', 'v', ' ', ':', ' ', 'i', 'n', 't', ')', ' ', ':', ' ', 'i', 'm', 'a', 'g', 'e', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 's', 't', 'r', 'i', 'n', 'g', '_', 'i', 'm', 'a', 'g', 'e', ' ', '(', 'x', ' ', ':', ' ', 'i', 'm', 'a', 'g', 'e', ')', ' ', '(', 's', 'i', 'z', 'e', ' ', ':', ' ', 'i', 'n', 't', ')', ' ', ':', ' ', 't', 'e', 'x', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'l', 'e', 'n', 'g', 't', 'h', ' ', '(', 'x', ' ', ':', ' ', 't', 'e', 'x', 't', ')', ' ', ':', ' ', 'i', 'n', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'a', 'x', 'i', 'o', 'm', ' ', 'c', 'h', 'e', 'c', 'k', 'e', 'd', '_', 'l', 'e', 'n', 'g', 't', 'h', ':', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', ' ', ' ', 'f', 'o', 'r', 'a', 'l', 'l', ' ', 'v', ' ', ':', ' ', 'i', 'n', 't', '.', ' ', '-', '2', '1', '4', '7', '4', '8', '3', '6', '4', '8', ' ', '<', '=', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', '=', ' ', '2', '1', '4', '7', '4', '8', '3', '6', '4', '7', ' ', '-', '>', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', ' ', ' ', ' ', ' ', 'l', 'e', 'n', 'g', 't', 'h', ' ', '(', 's', 't', 'r', 'i', 'n', 'g', '_', 'i', 'm', 'a', 'g', 'e', ' ', '(', 's', 'c', 'a', 'l', 'a', 'r', '_', 'i', 'm', 'a', 'g', 'e', ' ', 'v', ')', ' ', '1', '2', ')', ' ', '=', ' ', '1', ' ', '+', ' ', '(', 'i', 'f', ' ', '-', '1', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '2', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9', ' ', 'e', 'l', 's', 'e', ' ', '1', '0', ')', ')', ')', ')', ')', ')', ')', ')', ')', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'e', 'n', 'd', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'T', 'h', 'e', 'o', 'r', 'y', ';', '\n'] := by decide +kernel
  rw [sourceText, rendered]
  kernel_exact (Eq.refl (String.ofList ['p', 'a', 'c', 'k', 'a', 'g', 'e', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'T', 'h', 'e', 'o', 'r', 'y', ' ', 'w', 'i', 't', 'h', ' ', 'S', 'P', 'A', 'R', 'K', '_', 'M', 'o', 'd', 'e', ' ', '=', '>', ' ', 'O', 'n', ' ', 'i', 's', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'N', 'a', 't', 'i', 'v', 'e', ' ', 'p', 'r', 'o', 'o', 'f', ' ', 'r', 'e', 'p', 'r', 'e', 's', 'e', 'n', 't', 'a', 't', 'i', 'o', 'n', ' ', 'o', 'f', ' ', 't', 'h', 'e', ' ', 'c', 'h', 'e', 'c', 'k', 'e', 'd', ' ', 'L', 'e', 'a', 'n', ' ', 'I', 'm', 'a', 'g', 'e', ' ', 'l', 'e', 'n', 'g', 't', 'h', ' ', 't', 'h', 'e', 'o', 'r', 'e', 'm', '.', '\n', ' ', ' ', ' ', '-', '-', ' ', ' ', 'T', 'h', 'e', ' ', 't', 'y', 'p', 'e', 'd', ' ', 'p', 'r', 'o', 'd', 'u', 'c', 'e', 'r', ' ', 'a', 'd', 'a', 'p', 't', 'e', 'r', ' ', 'm', 'u', 's', 't', ' ', 'e', 's', 't', 'a', 'b', 'l', 'i', 's', 'h', ' ', 't', 'h', 'e', ' ', 'c', 'l', 'o', 'n', 'e', ' ', 's', 'y', 'm', 'b', 'o', 'l', ' ', 'i', 'd', 'e', 'n', 't', 'i', 't', 'i', 'e', 's', '.', '\n', ' ', ' ', ' ', 'T', 'h', 'e', 'o', 'r', 'y', '_', 'T', 'e', 'x', 't', ' ', ':', ' ', 'c', 'o', 'n', 's', 't', 'a', 'n', 't', ' ', 'S', 't', 'r', 'i', 'n', 'g', ' ', ':', '=', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'm', 'o', 'd', 'u', 'l', 'e', ' ', 'I', 'n', 't', 'e', 'g', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'L', 'e', 'n', 'g', 't', 'h', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'u', 's', 'e', ' ', 'i', 'n', 't', '.', 'I', 'n', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 't', 'y', 'p', 'e', ' ', 'i', 'm', 'a', 'g', 'e', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 't', 'y', 'p', 'e', ' ', 't', 'e', 'x', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 's', 'c', 'a', 'l', 'a', 'r', '_', 'i', 'm', 'a', 'g', 'e', ' ', '(', 'v', ' ', ':', ' ', 'i', 'n', 't', ')', ' ', ':', ' ', 'i', 'm', 'a', 'g', 'e', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 's', 't', 'r', 'i', 'n', 'g', '_', 'i', 'm', 'a', 'g', 'e', ' ', '(', 'x', ' ', ':', ' ', 'i', 'm', 'a', 'g', 'e', ')', ' ', '(', 's', 'i', 'z', 'e', ' ', ':', ' ', 'i', 'n', 't', ')', ' ', ':', ' ', 't', 'e', 'x', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' ', 'l', 'e', 'n', 'g', 't', 'h', ' ', '(', 'x', ' ', ':', ' ', 't', 'e', 'x', 't', ')', ' ', ':', ' ', 'i', 'n', 't', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'a', 'x', 'i', 'o', 'm', ' ', 'c', 'h', 'e', 'c', 'k', 'e', 'd', '_', 'l', 'e', 'n', 'g', 't', 'h', ':', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', ' ', ' ', 'f', 'o', 'r', 'a', 'l', 'l', ' ', 'v', ' ', ':', ' ', 'i', 'n', 't', '.', ' ', '-', '2', '1', '4', '7', '4', '8', '3', '6', '4', '8', ' ', '<', '=', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', '=', ' ', '2', '1', '4', '7', '4', '8', '3', '6', '4', '7', ' ', '-', '>', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', ' ', ' ', ' ', ' ', 'l', 'e', 'n', 'g', 't', 'h', ' ', '(', 's', 't', 'r', 'i', 'n', 'g', '_', 'i', 'm', 'a', 'g', 'e', ' ', '(', 's', 'c', 'a', 'l', 'a', 'r', '_', 'i', 'm', 'a', 'g', 'e', ' ', 'v', ')', ' ', '1', '2', ')', ' ', '=', ' ', '1', ' ', '+', ' ', '(', 'i', 'f', ' ', '-', '1', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', ' ', 't', 'h', 'e', 'n', ' ', '1', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '2', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '3', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '4', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '5', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '6', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '7', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '8', ' ', 'e', 'l', 's', 'e', ' ', '(', 'i', 'f', ' ', '-', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', ' ', '<', ' ', 'v', ' ', '/', '\\', ' ', 'v', ' ', '<', ' ', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', ' ', 't', 'h', 'e', 'n', ' ', '9', ' ', 'e', 'l', 's', 'e', ' ', '1', '0', ')', ')', ')', ')', ')', ')', ')', ')', ')', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ' ', '&', '\n', ' ', ' ', ' ', ' ', ' ', '"', 'e', 'n', 'd', '"', ' ', '&', ' ', 'C', 'h', 'a', 'r', 'a', 'c', 't', 'e', 'r', '\'', 'V', 'a', 'l', ' ', '(', '1', '0', ')', ';', '\n', 'e', 'n', 'd', ' ', 'S', 'i', 'l', 'v', 'e', 'r', '_', 'I', 'm', 'a', 'g', 'e', '_', 'T', 'h', 'e', 'o', 'r', 'y', ';', '\n']))

end Silver.Integer.Image.Theory
