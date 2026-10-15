module

public import Silver.ScalarLiteralEquations
public import Silver.ScalarLiteralSourceShape
public import Silver.SourceDeclarations
public import Silver.ScalarLiteralSpecCertificate
public import Silver.ScalarLiteralBodyCertificate
public import Silver.ProfileSpecCertificate
public import Silver.ProfileBodyCertificate
public import Silver.ReviewedSourceShape
public import Silver.Precedence
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ScalarLiteral.SourceBridge
open Silver.SourceBridge Silver.Lexical.SourceBridge

abbrev ReviewedShape : Prop :=
  Source.scalarLiteralSpecTokens = SourceShape.spec ∧
  Source.scalarLiteralBodyTokens = SourceShape.body ∧
  Source.specTokens = Silver.SourceShape.specification ∧
  Source.bodyTokens = Silver.SourceShape.implementation

theorem actual_reviewed_shape : ReviewedShape := by decide +kernel

abbrev ExpressionTranslation : Prop :=
  Native.WellFormedTrees ∧
  Source.expressionBody "digit" Source.scalarLiteralBodyTokens = some Native.digitBody.render ∧
  Source.expressionBody "numeral_tail" Source.scalarLiteralBodyTokens = some Native.tailBody.render ∧
  Source.expressionBody "numeral_model" Source.scalarLiteralBodyTokens = some Native.numeralBody.render ∧
  Source.expressionBody "mantissa_model" Source.scalarLiteralBodyTokens = some Native.mantissaBody.render ∧
  Source.expressionBody "scale_model" Source.scalarLiteralBodyTokens = some Native.scaleBody.render ∧
  Source.expressionBody "exponent_start" Source.scalarLiteralBodyTokens = some Native.startBody.render ∧
  Source.expressionBody "exponent_model" Source.scalarLiteralBodyTokens = some Native.exponentBody.render ∧
  Source.expressionBody "model" Source.scalarLiteralBodyTokens = some Native.modelBody.render ∧
  Silver.Expressions.identifierBody.wellFormed = true ∧
  Source.expressionBody "is_identifier_character" Source.bodyTokens =
    some Silver.Expressions.identifierBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev NumericDeclarations : Prop :=
  Source.declaration "max_magnitude" Source.scalarLiteralSpecTokens =
    some (expectedTokens "constant := 2_147_483_648") ∧
  subtypeDeclaration "literal_position" Source.scalarLiteralSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Source_Length + 1") ∧
  subtypeDeclaration "literal_value" Source.scalarLiteralSpecTokens =
    some (expectedTokens "Long_Long_Integer range 0 .. Max_Magnitude") ∧
  subtypeDeclaration "literal_base" Source.scalarLiteralSpecTokens =
    some (expectedTokens "Long_Long_Integer range 2 .. 16") ∧
  recordDeclaration "literal_result" Source.scalarLiteralSpecTokens =
    some (expectedTokens "record After : Literal_Position; Value : Literal_Value; end record") ∧
  recordDeclaration "mantissa_result" Source.scalarLiteralBodyTokens =
    some (expectedTokens "record After : Literal_Position; Value : Literal_Value; Base : Literal_Base; end record") ∧
  recordDeclaration "scale_result" Source.scalarLiteralBodyTokens =
    some (expectedTokens "record Valid : Boolean; Value : Literal_Value; end record") ∧
  Source.declaration "invalid" Source.scalarLiteralSpecTokens =
    some (expectedTokens "constant Literal_Result := (After => 0, Value => 0)") ∧
  Source.declaration "invalid_mantissa" Source.scalarLiteralBodyTokens =
    some (expectedTokens "constant Mantissa_Result := (After => 0, Value => 0, Base => 10)") ∧
  Source.declaration "invalid_scale" Source.scalarLiteralBodyTokens =
    some (expectedTokens "constant Scale_Result := (Valid => False, Value => 0)") ∧
  Source.declaration "max_source_length" Source.specTokens =
    some (expectedTokens "constant Positive := 4_096")

theorem actual_numeric_declarations : NumericDeclarations := by decide +kernel

theorem spec_header_0 :
    functionHeader "model" ";" Source.scalarLiteralSpecTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1"] := by decide +kernel

theorem spec_header_1 :
    functionHeader "read_integer" ";" Source.scalarLiteralSpecTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "read_integer", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_integer", "'", "result", ".", "after", ">", "position", "and", "then", "read_integer", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "read_integer", "'", "result", "=", "model", "(", "text", ",", "position", ")", ")"] := by decide +kernel

theorem body_header_0 :
    functionHeader "digit" "is" Source.scalarLiteralBodyTokens =
      some ["(", "item", ":", "character", ")", "return", "long_long_integer"] := by decide +kernel

theorem body_header_1 :
    functionHeader "numeral_tail" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "base", ":", "literal_base", ";", "position", ":", "literal_position", ";", "value", ":", "literal_value", ";", "need_digit", ":", "boolean", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "numeral_tail", "'", "result", ".", "after", "=", "0", "or", "else", "(", "numeral_tail", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "(", "if", "need_digit", "then", "numeral_tail", "'", "result", ".", "after", ">", "position", "else", "numeral_tail", "'", "result", ".", "after", ">=", "position", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ")"] := by decide +kernel

theorem body_header_2 :
    functionHeader "numeral_tail" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "base", ":", "literal_base", ";", "position", ":", "literal_position", ";", "value", ":", "literal_value", ";", "need_digit", ":", "boolean", ")", "return", "literal_result"] := by decide +kernel

theorem body_header_3 :
    functionHeader "numeral_model" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "numeral_model", "'", "result", ".", "after", "=", "0", "or", "else", "(", "numeral_model", "'", "result", ".", "after", ">", "position", "and", "then", "numeral_model", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")"] := by decide +kernel

theorem body_header_4 :
    functionHeader "numeral_model" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result"] := by decide +kernel

theorem body_header_5 :
    functionHeader "numeral" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "numeral", "'", "result", ".", "after", "=", "0", "or", "else", "(", "numeral", "'", "result", ".", "after", ">", "position", "and", "then", "numeral", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "numeral", "'", "result", "=", "numeral_model", "(", "text", ",", "position", ",", "base", ")", ")"] := by decide +kernel

theorem body_header_6 :
    functionHeader "numeral" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result"] := by decide +kernel

theorem body_header_7 :
    functionHeader "mantissa_model" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "mantissa_model", "'", "result", ".", "after", "=", "0", "or", "else", "(", "mantissa_model", "'", "result", ".", "after", ">", "position", "and", "then", "mantissa_model", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")"] := by decide +kernel

theorem body_header_8 :
    functionHeader "mantissa_model" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result"] := by decide +kernel

theorem body_header_9 :
    functionHeader "read_mantissa" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "read_mantissa", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_mantissa", "'", "result", ".", "after", ">", "position", "and", "then", "read_mantissa", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "read_mantissa", "'", "result", "=", "mantissa_model", "(", "text", ",", "position", ")", ")"] := by decide +kernel

theorem body_header_10 :
    functionHeader "read_mantissa" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result"] := by decide +kernel

theorem body_header_11 :
    functionHeader "scale_model" ";" Source.scalarLiteralBodyTokens =
      some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "exponent", ")"] := by decide +kernel

theorem body_header_12 :
    functionHeader "scale_model" "is" Source.scalarLiteralBodyTokens =
      some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result"] := by decide +kernel

theorem body_header_13 :
    functionHeader "power" ";" Source.scalarLiteralBodyTokens =
      some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "power", "'", "result", "=", "scale_model", "(", "base", ",", "value", ",", "exponent", ")", ")"] := by decide +kernel

theorem body_header_14 :
    functionHeader "power" "is" Source.scalarLiteralBodyTokens =
      some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result"] := by decide +kernel

theorem body_header_15 :
    functionHeader "exponent_start" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "exponent_start", "'", "result", "in", "position", "..", "text", "'", "last", "+", "1"] := by decide +kernel

theorem body_header_16 :
    functionHeader "exponent_start" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position"] := by decide +kernel

theorem body_header_17 :
    functionHeader "exponent_model" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "number", ".", "after", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "exponent_model", "'", "result", ".", "after", "=", "0", "or", "else", "exponent_model", "'", "result", ".", "after", "in", "number", ".", "after", "..", "text", "'", "last", "+", "1"] := by decide +kernel

theorem body_header_18 :
    functionHeader "exponent_model" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result"] := by decide +kernel

theorem body_header_19 :
    functionHeader "read_exponent" ";" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "number", ".", "after", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "read_exponent", "'", "result", ".", "after", "=", "0", "or", "else", "read_exponent", "'", "result", ".", "after", "in", "number", ".", "after", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "read_exponent", "'", "result", "=", "exponent_model", "(", "text", ",", "number", ")", ")"] := by decide +kernel

theorem body_header_20 :
    functionHeader "read_exponent" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result"] := by decide +kernel

theorem body_header_21 :
    functionHeader "model" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result"] := by decide +kernel

theorem body_header_22 :
    functionHeader "read_integer" "is" Source.scalarLiteralBodyTokens =
      some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result"] := by decide +kernel

structure CheckedSource : Prop where
  specification : Source.lex Source.scalarLiteralSpec = some Source.scalarLiteralSpecTokens
  implementation : Source.lex Source.scalarLiteralBody = some Source.scalarLiteralBodyTokens
  reviewedShape : ReviewedShape
  expressions : ExpressionTranslation
  numeric : NumericDeclarations
  spec_header_0 : functionHeader "model" ";" Source.scalarLiteralSpecTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1"]
  spec_header_1 : functionHeader "read_integer" ";" Source.scalarLiteralSpecTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "read_integer", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_integer", "'", "result", ".", "after", ">", "position", "and", "then", "read_integer", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "read_integer", "'", "result", "=", "model", "(", "text", ",", "position", ")", ")"]
  body_header_0 : functionHeader "digit" "is" Source.scalarLiteralBodyTokens = some ["(", "item", ":", "character", ")", "return", "long_long_integer"]
  body_header_1 : functionHeader "numeral_tail" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "base", ":", "literal_base", ";", "position", ":", "literal_position", ";", "value", ":", "literal_value", ";", "need_digit", ":", "boolean", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "numeral_tail", "'", "result", ".", "after", "=", "0", "or", "else", "(", "numeral_tail", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "(", "if", "need_digit", "then", "numeral_tail", "'", "result", ".", "after", ">", "position", "else", "numeral_tail", "'", "result", ".", "after", ">=", "position", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ")"]
  body_header_2 : functionHeader "numeral_tail" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "base", ":", "literal_base", ";", "position", ":", "literal_position", ";", "value", ":", "literal_value", ";", "need_digit", ":", "boolean", ")", "return", "literal_result"]
  body_header_3 : functionHeader "numeral_model" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "numeral_model", "'", "result", ".", "after", "=", "0", "or", "else", "(", "numeral_model", "'", "result", ".", "after", ">", "position", "and", "then", "numeral_model", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")"]
  body_header_4 : functionHeader "numeral_model" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result"]
  body_header_5 : functionHeader "numeral" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "numeral", "'", "result", ".", "after", "=", "0", "or", "else", "(", "numeral", "'", "result", ".", "after", ">", "position", "and", "then", "numeral", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "numeral", "'", "result", "=", "numeral_model", "(", "text", ",", "position", ",", "base", ")", ")"]
  body_header_6 : functionHeader "numeral" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "base", ":", "literal_base", ")", "return", "literal_result"]
  body_header_7 : functionHeader "mantissa_model" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "mantissa_model", "'", "result", ".", "after", "=", "0", "or", "else", "(", "mantissa_model", "'", "result", ".", "after", ">", "position", "and", "then", "mantissa_model", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")"]
  body_header_8 : functionHeader "mantissa_model" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result"]
  body_header_9 : functionHeader "read_mantissa" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "read_mantissa", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_mantissa", "'", "result", ".", "after", ">", "position", "and", "then", "read_mantissa", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "read_mantissa", "'", "result", "=", "mantissa_model", "(", "text", ",", "position", ")", ")"]
  body_header_10 : functionHeader "read_mantissa" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "mantissa_result"]
  body_header_11 : functionHeader "scale_model" ";" Source.scalarLiteralBodyTokens = some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "exponent", ")"]
  body_header_12 : functionHeader "scale_model" "is" Source.scalarLiteralBodyTokens = some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result"]
  body_header_13 : functionHeader "power" ";" Source.scalarLiteralBodyTokens = some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "power", "'", "result", "=", "scale_model", "(", "base", ",", "value", ",", "exponent", ")", ")"]
  body_header_14 : functionHeader "power" "is" Source.scalarLiteralBodyTokens = some ["(", "base", ":", "literal_base", ";", "value", ",", "exponent", ":", "literal_value", ")", "return", "scale_result"]
  body_header_15 : functionHeader "exponent_start" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "exponent_start", "'", "result", "in", "position", "..", "text", "'", "last", "+", "1"]
  body_header_16 : functionHeader "exponent_start" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position"]
  body_header_17 : functionHeader "exponent_model" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "number", ".", "after", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "exponent_model", "'", "result", ".", "after", "=", "0", "or", "else", "exponent_model", "'", "result", ".", "after", "in", "number", ".", "after", "..", "text", "'", "last", "+", "1"]
  body_header_18 : functionHeader "exponent_model" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result"]
  body_header_19 : functionHeader "read_exponent" ";" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "number", ".", "after", "in", "1", "..", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "read_exponent", "'", "result", ".", "after", "=", "0", "or", "else", "read_exponent", "'", "result", ".", "after", "in", "number", ".", "after", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "read_exponent", "'", "result", "=", "exponent_model", "(", "text", ",", "number", ")", ")"]
  body_header_20 : functionHeader "read_exponent" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "number", ":", "mantissa_result", ")", "return", "literal_result"]
  body_header_21 : functionHeader "model" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result"]
  body_header_22 : functionHeader "read_integer" "is" Source.scalarLiteralBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_result"]

theorem checked_source : CheckedSource where
  specification := Source.scalarLiteralSpecTokens_correct
  implementation := Source.scalarLiteralBodyTokens_correct
  reviewedShape := actual_reviewed_shape
  expressions := actual_expressions
  numeric := actual_numeric_declarations
  spec_header_0 := spec_header_0
  spec_header_1 := spec_header_1
  body_header_0 := body_header_0
  body_header_1 := body_header_1
  body_header_2 := body_header_2
  body_header_3 := body_header_3
  body_header_4 := body_header_4
  body_header_5 := body_header_5
  body_header_6 := body_header_6
  body_header_7 := body_header_7
  body_header_8 := body_header_8
  body_header_9 := body_header_9
  body_header_10 := body_header_10
  body_header_11 := body_header_11
  body_header_12 := body_header_12
  body_header_13 := body_header_13
  body_header_14 := body_header_14
  body_header_15 := body_header_15
  body_header_16 := body_header_16
  body_header_17 := body_header_17
  body_header_18 := body_header_18
  body_header_19 := body_header_19
  body_header_20 := body_header_20
  body_header_21 := body_header_21
  body_header_22 := body_header_22

end Silver.ScalarLiteral.SourceBridge
