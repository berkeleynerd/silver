module

public import Silver.ScalarExpressionNativeEquations
public import Silver.ScalarExpressionSourceShape
public import Silver.SourceDeclarations
public import Silver.ScalarExpressionSpecCertificate
public import Silver.ScalarExpressionBodyCertificate
public import Silver.ScalarEnvironmentSourceBridge
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ScalarExpression.SourceChecks
open Silver.SourceBridge Silver.Lexical.SourceBridge

abbrev ReviewedShape : Prop :=
  Source.scalarExpressionSpecTokens = SourceShape.spec ∧
  Source.scalarExpressionBodyTokens = SourceShape.body

theorem actual_reviewed_shape : ReviewedShape := by decide +kernel

abbrev ExpressionTranslation : Prop :=
  Native.WellFormedTrees ∧
  Source.expressionBody "lookup_model" Source.scalarExpressionBodyTokens = some Native.lookupBody.render ∧
  Source.expressionBody "symbol" Source.scalarExpressionBodyTokens = some Native.symbolBody.render ∧
  Source.expressionBody "literal_result" Source.scalarExpressionBodyTokens = some Native.literalBody.render ∧
  Source.expressionBody "unary_result" Source.scalarExpressionBodyTokens = some Native.unaryBody.render ∧
  Source.expressionBody "binary_result" Source.scalarExpressionBodyTokens = some Native.binaryBody.render ∧
  Source.expressionBody "close_result" Source.scalarExpressionBodyTokens = some Native.closeBody.render ∧
  Source.expressionBody "read_atom" Source.scalarExpressionBodyTokens = some Native.atomBody.render ∧
  Source.expressionBody "read_unary" Source.scalarExpressionBodyTokens = some Native.readUnaryBody.render ∧
  Source.expressionBody "read_compound" Source.scalarExpressionBodyTokens = some Native.compoundBody.render ∧
  Source.expressionBody "read_group" Source.scalarExpressionBodyTokens = some Native.groupBody.render ∧
  Source.expressionBody "read_expression" Source.scalarExpressionBodyTokens = some Native.expressionBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Declarations : Prop :=
  Source.declaration "max_bindings" Source.scalarExpressionSpecTokens =
    some (expectedTokens "constant Positive := Max_Source_Length / 12") ∧
  Source.declaration "max_operands" Source.scalarExpressionSpecTokens =
    some (expectedTokens "constant Positive := 64") ∧
  subtypeDeclaration "binding_count" Source.scalarExpressionSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Bindings") ∧
  subtypeDeclaration "binding_index" Source.scalarExpressionSpecTokens =
    some (expectedTokens "Positive range 1 .. Max_Bindings") ∧
  subtypeDeclaration "operand_count" Source.scalarExpressionSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Operands") ∧
  recordDeclaration "binding" Source.scalarExpressionSpecTokens =
    some (expectedTokens "record First, After : Literal_Position; Bounds : Silver_Scalars.Interval; Static : Boolean; Declared_Bounds : Silver_Scalars.Interval; Mutable : Boolean; end record") ∧
  typeDeclaration "binding_array" Source.scalarExpressionSpecTokens =
    some (expectedTokens "array (Binding_Index) of Binding") ∧
  recordDeclaration "environment" Source.scalarExpressionSpecTokens =
    some (expectedTokens "record Count : Binding_Count; Items : Binding_Array; end record") ∧
  recordDeclaration "expression_result" Source.scalarExpressionSpecTokens =
    some (expectedTokens "record After : Literal_Position; Bounds : Silver_Scalars.Interval; Operands : Operand_Count; Static : Boolean; end record") ∧
  Source.declaration "empty_binding" Source.scalarExpressionSpecTokens =
    some (expectedTokens "constant Binding := (0, 0, Silver_Scalars.Empty, False, Silver_Scalars.Empty, False)") ∧
  Source.declaration "empty_environment" Source.scalarExpressionSpecTokens =
    some (expectedTokens "constant Environment := (0, (others => Empty_Binding))") ∧
  Source.declaration "invalid" Source.scalarExpressionSpecTokens =
    some (expectedTokens "constant Expression_Result := (0, Silver_Scalars.Empty, 0, False)") ∧
  Source.expressionBody "valid_environment" Source.scalarExpressionSpecTokens =
    some (expectedTokens "for all Index in 1 .. Names.Count => Names.Items (Index).First > 0 and then Valid_Name_State (Text, Names.Items (Index).First, Names.Items (Index).After)")

theorem actual_declarations : Declarations := by decide +kernel

/-! Headers bind every typed equation to its real argument order, domains,
result representation, default arguments and executable refinement contract. -/
abbrev Headers : Prop :=
  functionHeader "valid_environment" ";" Source.scalarExpressionSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length"] ∧
  functionHeader "valid_environment" "is" Source.scalarExpressionSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean"] ∧
  functionHeader "lookup_model" ";" Source.scalarExpressionSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "binding_count", ")", "return", "binding_count", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "index", "<=", "names", ".", "count", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "lookup_model", "'", "result", "<=", "index", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "index", ")"] ∧
  functionHeader "lookup" ";" Source.scalarExpressionSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ";", "first", ",", "after", ":", "literal_position", ")", "return", "binding_count", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "lookup", "'", "result", "<=", "names", ".", "count", ",", "static", "=>", "lookup", "'", "result", "=", "lookup_model", "(", "text", ",", "names", ",", "first", ",", "after", ",", "names", ".", "count", ")", ")"] ∧
  functionHeader "append" "is" Source.scalarExpressionSpecTokens =
    some ["(", "names", ":", "environment", ";", "item", ":", "binding", ")", "return", "environment"] ∧
  functionHeader "read_expression" ";" Source.scalarExpressionSpecTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ":", "literal_position", ":=", "0", ";", "mask_after", ":", "literal_position", ":=", "0", ";", "allow_sign", ":", "boolean", ":=", "true", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", ",", "post", "=>", "read_expression", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_expression", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "read_expression", "'", "result", ".", "operands", ">", "0", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "3", ")"] ∧
  functionHeader "lookup_model" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "binding_count", ")", "return", "binding_count"] ∧
  functionHeader "lookup" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ";", "first", ",", "after", ":", "literal_position", ")", "return", "binding_count"] ∧
  functionHeader "skip" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "(", "if", "position", "=", "0", "then", "skip", "'", "result", "=", "0", "else", "skip", "'", "result", "in", "position", "..", "text", "'", "last", "+", "1", ")", ",", "static", "=>", "skip", "'", "result", "=", "(", "if", "position", "=", "0", "then", "0", "else", "trivia_end", "(", "text", ",", "position", ")", ")", ")"] ∧
  functionHeader "skip" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position"] ∧
  functionHeader "symbol" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "item", ":", "character", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "symbol", "'", "result", "=", "0", "or", "else", "symbol", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"] ∧
  functionHeader "symbol" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "item", ":", "character", ")", "return", "literal_position"] ∧
  functionHeader "name_after" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "name_after", "'", "result", "=", "0", "or", "else", "name_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "name_after", "'", "result", "=", "(", "if", "position", "=", "0", "then", "0", "else", "identifier_end", "(", "text", ",", "position", ")", ")", ")"] ∧
  functionHeader "name_after" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position"] ∧
  functionHeader "literal_result" ";" Source.scalarExpressionBodyTokens =
    some ["(", "number", ":", "silver_scalar_literals", ".", "literal_result", ";", "negative", ":", "boolean", ")", "return", "expression_result", "with", "post", "=>", "literal_result", "'", "result", ".", "after", "=", "0", "or", "else", "(", "literal_result", "'", "result", ".", "after", "=", "number", ".", "after", "and", "then", "literal_result", "'", "result", ".", "operands", "=", "1", ")"] ∧
  functionHeader "literal_result" "is" Source.scalarExpressionBodyTokens =
    some ["(", "number", ":", "silver_scalar_literals", ".", "literal_result", ";", "negative", ":", "boolean", ")", "return", "expression_result"] ∧
  functionHeader "unary_result" ";" Source.scalarExpressionBodyTokens =
    some ["(", "operand", ":", "expression_result", ";", "negative", ":", "boolean", ")", "return", "expression_result", "with", "post", "=>", "unary_result", "'", "result", ".", "after", "=", "0", "or", "else", "(", "unary_result", "'", "result", ".", "after", "=", "operand", ".", "after", "and", "then", "unary_result", "'", "result", ".", "operands", "=", "operand", ".", "operands", ")"] ∧
  functionHeader "unary_result" "is" Source.scalarExpressionBodyTokens =
    some ["(", "operand", ":", "expression_result", ";", "negative", ":", "boolean", ")", "return", "expression_result"] ∧
  functionHeader "binary_result" ";" Source.scalarExpressionBodyTokens =
    some ["(", "left", ",", "right", ":", "expression_result", ";", "operator", ":", "character", ")", "return", "expression_result", "with", "post", "=>", "binary_result", "'", "result", ".", "after", "=", "0", "or", "else", "(", "binary_result", "'", "result", ".", "after", "=", "right", ".", "after", "and", "then", "binary_result", "'", "result", ".", "operands", ">=", "left", ".", "operands", "and", "then", "binary_result", "'", "result", ".", "operands", ">=", "right", ".", "operands", ")"] ∧
  functionHeader "binary_result" "is" Source.scalarExpressionBodyTokens =
    some ["(", "left", ",", "right", ":", "expression_result", ";", "operator", ":", "character", ")", "return", "expression_result"] ∧
  functionHeader "close_result" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "value", ":", "expression_result", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "value", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "close_result", "'", "result", ".", "after", "=", "0", "or", "else", "(", "close_result", "'", "result", ".", "after", "in", "value", ".", "after", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "close_result", "'", "result", ".", "operands", "=", "value", ".", "operands", ")"] ∧
  functionHeader "close_result" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "value", ":", "expression_result", ")", "return", "expression_result"] ∧
  functionHeader "read_atom" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ",", "mask_after", ":", "literal_position", ";", "allow_sign", ":", "boolean", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", ",", "post", "=>", "read_atom", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_atom", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "read_atom", "'", "result", ".", "operands", ">", "0", ")"] ∧
  functionHeader "read_atom" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ",", "mask_after", ":", "literal_position", ";", "allow_sign", ":", "boolean", ")", "return", "expression_result"] ∧
  functionHeader "read_unary" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "in", "1", "..", "text", "'", "last", "and", "then", "text", "(", "position", ")", "in", "'+'", "|", "'-'", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", ",", "post", "=>", "read_unary", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_unary", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "read_unary", "'", "result", ".", "operands", ">", "0", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "1", ")"] ∧
  functionHeader "read_unary" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return", "expression_result"] ∧
  functionHeader "read_compound" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "left", ":", "expression_result", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", "and", "then", "(", "left", ".", "after", "=", "0", "or", "else", "(", "left", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "left", ".", "operands", ">", "0", ")", ")", ",", "post", "=>", "read_compound", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_compound", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "read_compound", "'", "result", ".", "operands", ">", "0", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "1", ")"] ∧
  functionHeader "read_compound" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "left", ":", "expression_result", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return", "expression_result"] ∧
  functionHeader "read_group" ";" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "in", "1", "..", "text", "'", "last", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", ",", "post", "=>", "read_group", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_group", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "read_group", "'", "result", ".", "operands", ">", "0", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "2", ")"] ∧
  functionHeader "read_group" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return", "expression_result"] ∧
  functionHeader "read_expression" "is" Source.scalarExpressionBodyTokens =
    some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "environment", ";", "mask_first", ":", "literal_position", ":=", "0", ";", "mask_after", ":", "literal_position", ":=", "0", ";", "allow_sign", ":", "boolean", ":=", "true", ")", "return", "expression_result"]

theorem actual_headers : Headers := by
  unfold Headers
  repeat' apply And.intro
  all_goals decide +kernel

structure CheckedSource : Prop where
  shape : ReviewedShape
  expressions : ExpressionTranslation
  declarations : Declarations
  headers : Headers
  environment : EnvironmentSourceBridge.Checked Source.scalarExpressionSpecTokens

theorem checked_source : CheckedSource :=
  ⟨actual_reviewed_shape, actual_expressions, actual_declarations, actual_headers,
    EnvironmentSourceBridge.actual_source_checked⟩

end Silver.ScalarExpression.SourceChecks
