module

import all Init.Data.Char.Basic
public import Silver.ImageModelCoreState

@[expose] public section
namespace Silver.ImageModel.HexNative

set_option backward.dsimp.instances true

inductive Class
  | decimal | lowercase | uppercase
  deriving DecidableEq

def Class.first : Class → Char
  | .decimal => '0' | .lowercase => 'a' | .uppercase => 'A'

def Class.last : Class → Char
  | .decimal => '9' | .lowercase => 'f' | .uppercase => 'F'

def Class.offset : Class → Nat
  | .decimal => 0 | .lowercase => 10 | .uppercase => 10

def Class.accepts (category : Class) (code : Nat) : Bool :=
  decide (category.first.toNat ≤ code ∧ code ≤ category.last.toNat)

def Class.eval (category : Class) (code : Nat) : Nat := (code - category.first.toNat) + category.offset

def character (value : Char) : String := String.ofList ['\'', value, '\'']

def Class.test (category : Class) : List String :=
  ["item", "in", character category.first, "..", character category.last]

def difference (category : Class) : List String :=
  ["character", "'", "pos", "(", "item", ")", "-", "character", "'", "pos", "(", character category.first, ")"]

def Class.result (category : Class) : List String :=
  match category with
  | .decimal => difference category
  | .lowercase | .uppercase => ["("] ++ difference category ++ [")", "+", "10"]

inductive Expression
  | invalid | choose (category : Class) (otherwise : Expression)
  deriving DecidableEq

def Expression.eval (code : Nat) : Expression → Nat
  | .invalid => 16
  | .choose category otherwise => if category.accepts code then category.eval code else otherwise.eval code

mutual
  def Expression.render : Expression → List String
    | .invalid => ["16"]
    | .choose category otherwise => ["if"] ++ category.test ++ ["then"] ++ category.result ++ otherwise.renderElse
  def Expression.renderElse : Expression → List String
    | .invalid => ["else", "16"]
    | .choose category otherwise => ["elsif"] ++ category.test ++ ["then"] ++ category.result ++ otherwise.renderElse
end

def expression : Expression := .choose .decimal (.choose .lowercase (.choose .uppercase .invalid))

theorem eval_model (code : Nat) : expression.eval code = Core.hexadecimal code := by
  change (if decide (48 ≤ code ∧ code ≤ 57) then code - 48 + 0
    else if decide (97 ≤ code ∧ code ≤ 102) then code - 97 + 10
    else if decide (65 ≤ code ∧ code ≤ 70) then code - 65 + 10 else 16) = _
  unfold Core.hexadecimal
  by_cases decimal : 48 ≤ code ∧ code ≤ 57 <;>
    by_cases lower : 97 ≤ code ∧ code ≤ 102 <;>
      by_cases upper : 65 ≤ code ∧ code ≤ 70 <;> simp [decimal, lower, upper]

theorem value_bounded (code : Nat) : Core.hexadecimal code ≤ 16 := by
  unfold Core.hexadecimal
  split <;> (try split) <;> (try split) <;> omega

/-- The concrete lowercase table from Decoded denotes all sixteen hexadecimal
values; case-insensitive Hex also recognizes the uppercase input spelling. -/
theorem table_decodes : ∀ digit : Fin 16,
    Core.hexadecimal (DecodedNative.hexByte digit.val) = digit.val := by decide +kernel

end Silver.ImageModel.HexNative

namespace Silver.ImageModel.SourceBridge
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem hex_expression : Source.expressionBody "hex" Source.imageModelBodyTokens =
    some HexNative.expression.render := by
  simp only [HexNative.expression, HexNative.Expression.render, HexNative.Expression.renderElse,
    HexNative.Class.test, HexNative.Class.result, HexNative.difference, HexNative.Class.first, HexNative.Class.last]
  decide +kernel

/-- Interpretation of this source expression fixes the hexadecimal primitive;
no lexical scanner or JSON-schema equality is assumed at this boundary. -/
structure InterpretedHex (run : Nat → Nat) : Prop where
  expression : ∀ code, code ≤ 255 → run code = HexNative.expression.eval code

theorem actual_hex (run : Nat → Nat) (source : InterpretedHex run) (code : Nat) (byte : code ≤ 255) :
    run code = Core.hexadecimal code := by
  rw [source.expression code byte, HexNative.eval_model]

end Silver.ImageModel.SourceBridge
