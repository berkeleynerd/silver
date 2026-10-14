module

public import Silver.ArgumentsSourceBridge
public import Silver.SourceDeclarations
public import Silver.GuardedExpressions
import all Init.Data.Repr

@[expose] public section

/-! Source correspondence for the shared decimal and decoded-literal-length
helpers. Their existing typed trees and recursive interpretations are retained;
composed expression and shell correspondence belongs to ComposeSourceBridge. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Lexical.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Guarded.Expressions.decimalTailBody.wellFormed = true ∧
  Guarded.Expressions.decimalAtBody.wellFormed = true ∧
  Guarded.Expressions.literalLengthBody.wellFormed = true ∧
  Source.expressionBody "decimal_tail" Source.outputLexicalSpecTokens =
    some Guarded.Expressions.decimalTailBody.render ∧
  Source.expressionBody "decimal_at" Source.outputLexicalSpecTokens =
    some Guarded.Expressions.decimalAtBody.render ∧
  Source.expressionBody "literal_length" Source.outputLexicalSpecTokens =
    some Guarded.Expressions.literalLengthBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev NumericDeclarations : Prop :=
  subtypeDeclaration "capacity_value" Source.outputLexicalSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Source_Length") ∧
  recordDeclaration "decimal_result" Source.outputLexicalSpecTokens =
    some (expectedTokens "record After : Literal_Position; Value : Capacity_Value; end record") ∧
  Source.declaration "invalid_decimal" Source.outputLexicalSpecTokens =
    some (expectedTokens "constant Decimal_Result := (After => 0, Value => 0)")

theorem actual_numeric_declarations : NumericDeclarations := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "decimal_tail" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Value : Capacity_Value) return Decimal_Result") ∧
  functionHeader "decimal_at" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Decimal_Result") ∧
  functionHeader "literal_length" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Capacity_Value")

theorem actual_refinement : Refinement := by decide +kernel

/-- These verified source preconditions are exactly the domains used by the
arbitrary-callee recursive interpretation. Machine arithmetic refinement still
uses the fixed frontend and the complete compiler SPARK proof. -/
abbrev DecimalTailContract : Prop :=
  functionHeader "decimal_tail" ";" Source.outputLexicalSpecTokens = some (expectedTokens "(Text : String; Position : Cursor; Value : Capacity_Value) return Decimal_Result with Ghost => Static, Global => null," ++
    expectedTokens "Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post =>" ++
    expectedTokens "Decimal_Tail'Result.After = 0 or else Decimal_Tail'Result.After in Position .. Text'Last + 1, Subprogram_Variant =>" ++
    expectedTokens "(Decreases => (Text'Last + 1) - Position)")

theorem actual_decimal_tail_contract : DecimalTailContract := rfl

abbrev DecimalAtContract : Prop :=
  functionHeader "decimal_at" ";" Source.outputLexicalSpecTokens = some (expectedTokens "(Text : String; Position : Cursor) return Decimal_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and" ++
    expectedTokens "then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post => Decimal_At'Result.After = 0 or" ++
    expectedTokens "else Decimal_At'Result.After in Position + 1 .. Text'Last + 1")

theorem actual_decimal_at_contract : DecimalAtContract := rfl

abbrev LiteralLengthContract : Prop :=
  functionHeader "literal_length" ";" Source.outputLexicalSpecTokens = some (expectedTokens "(Text : String; Position : Cursor) return Capacity_Value with Ghost => Static, Global => null, Pre => Text'First = 1 and" ++
    expectedTokens "then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post => Literal_Length'Result <=" ++
    expectedTokens "(Text'Last + 1) - Position, Subprogram_Variant => (Decreases => (Text'Last + 1) - Position)")

theorem actual_literal_length_contract : LiteralLengthContract := rfl

abbrev HelperContracts : Prop := DecimalTailContract ∧ DecimalAtContract ∧ LiteralLengthContract

theorem actual_helper_contracts : HelperContracts :=
  ⟨actual_decimal_tail_contract, actual_decimal_at_contract, actual_literal_length_contract⟩

structure CheckedSource : Prop where
  inherited : Arguments.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  numeric : NumericDeclarations
  refinement : Refinement
  helperContracts : HelperContracts

theorem checked_source : CheckedSource where
  inherited := Arguments.SourceBridge.checked_source
  expressions := actual_expressions
  numeric := actual_numeric_declarations
  refinement := actual_refinement
  helperContracts := actual_helper_contracts

end Silver.Lexical.SourceBridge
