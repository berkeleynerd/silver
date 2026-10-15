module

public import Silver.NamesExpressions
public import Silver.NamesSourceShape
public import Silver.SourceDeclarations
public import Silver.NamesSpecCertificate
public import Silver.NamesBodyCertificate
public import Silver.OutputLexicalSpecCertificate
public import Silver.ProfileSpecCertificate
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Names.SourceBridge
open Silver.SourceBridge Silver.Lexical.SourceBridge

abbrev ReviewedShape : Prop :=
  Source.namesSpecTokens = SourceShape.spec ∧ Source.namesBodyTokens = SourceShape.body

theorem actual_reviewed_shape : ReviewedShape := by decide +kernel

abbrev ExpressionTranslation : Prop :=
  Native.WellFormedTrees ∧ Native.WellScopedTrees ∧
  Source.expressionBody "fixed_after" Source.namesBodyTokens = some Native.fixedBody.render ∧
  Source.expressionBody "context_step" Source.namesBodyTokens = some Native.stepBody.render ∧
  Source.expressionBody "context_tail" Source.namesBodyTokens = some Native.tailBody.render ∧
  Source.expressionBody "context_model" Source.namesBodyTokens = some Native.modelBody.render ∧
  Source.expressionBody "context_after" Source.namesBodyTokens = some Native.contextBody.render ∧
  Source.expressionBody "operation_name" Source.namesBodyTokens = some Native.nameBody.render ∧
  Source.expressionBody "operation_after" Source.namesBodyTokens = some Native.operationBody.render ∧
  Source.expressionBody "association_after" Source.namesBodyTokens = some Native.associationBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Declarations : Prop :=
  typeDeclaration "operation_kind" Source.namesSpecTokens =
    some (expectedTokens "(Output_Call, Partial_Output_Call, Argument_Call, Validity_Call, Reject_Call)") ∧
  typeDeclaration "context_mode" Source.namesBodyTokens =
    some (expectedTokens "(Clause_Start, With_Name, Use_Name, With_Separator, Use_Separator)") ∧
  recordDeclaration "context_result" Source.namesSpecTokens =
    some (expectedTokens "record After : Literal_Position; IO_With, Arguments_With, IO_Use, Arguments_Use : Boolean; end record") ∧
  recordDeclaration "context_state" Source.namesBodyTokens =
    some (expectedTokens "record Context : Context_Result; Mode : Context_Mode; Complete : Boolean; end record") ∧
  Source.declaration "invalid_context" Source.namesSpecTokens =
    some (expectedTokens "constant Context_Result := (After => 0, others => False)") ∧
  Source.declaration "initial_state" Source.namesBodyTokens =
    some (expectedTokens "constant Context_State := (Context => (After => 1, others => False), Mode => Clause_Start, Complete => False)") ∧
  Source.declaration "invalid_state" Source.namesBodyTokens =
    some (expectedTokens "constant Context_State := (Context => Invalid_Context, Mode => Clause_Start, Complete => True)") ∧
  subtypeDeclaration "literal_position" Source.outputLexicalSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Source_Length + 1") ∧
  Source.declaration "max_source_length" Source.specTokens =
    some (expectedTokens "constant Positive := 4_096")

theorem actual_declarations : Declarations := by decide +kernel

theorem spec_header_0 :
    functionHeader "context_model" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ")", "return", "context_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "context_model", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1"] := by decide +kernel

theorem spec_header_1 :
    functionHeader "read_context" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ")", "return", "context_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "(", "runtime", "=>", "read_context", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "static", "=>", "read_context", "'", "result", "=", "context_model", "(", "text", ")", ")"] := by decide +kernel

theorem spec_header_2 :
    functionHeader "context_after" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ";", "arguments", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "context_after", "'", "result", "<=", "text", "'", "last", "+", "1"] := by decide +kernel

theorem spec_header_3 :
    functionHeader "operation_after" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operation", ":", "operation_kind", ";", "hidden", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "operation_after", "'", "result", "=", "0", "or", "else", "operation_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"] := by decide +kernel

theorem spec_header_4 :
    functionHeader "association_after" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "default", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "association_after", "'", "result", "in", "position", "..", "text", "'", "last", "+", "1"] := by decide +kernel

theorem body_header_0 :
    functionHeader "fixed_after" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "word", "'", "first", "=", "1", "and", "then", "word", "'", "length", "in", "1", "..", "16", ",", "post", "=>", "fixed_after", "'", "result", "=", "0", "or", "else", "fixed_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"] := by decide +kernel

theorem body_header_1 :
    functionHeader "fixed_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position"] := by decide +kernel

theorem body_header_2 :
    functionHeader "take" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "word", "'", "first", "=", "1", "and", "then", "word", "'", "length", "in", "1", "..", "16", ",", "post", "=>", "(", "runtime", "=>", "take", "'", "result", "=", "0", "or", "else", "take", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "take", "'", "result", "=", "fixed_after", "(", "text", ",", "position", ",", "word", ",", "is_word", ")", ")"] := by decide +kernel

theorem body_header_3 :
    functionHeader "take" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position"] := by decide +kernel

theorem body_header_4 :
    functionHeader "context_step" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "state", ".", "context", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "context_step", "'", "result", ".", "context", ".", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "(", "context_step", "'", "result", ".", "context", ".", "after", "=", "0", "or", "else", "context_step", "'", "result", ".", "complete", "or", "else", "context_step", "'", "result", ".", "context", ".", "after", ">", "state", ".", "context", ".", "after", ")"] := by decide +kernel

theorem body_header_5 :
    functionHeader "context_step" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_state"] := by decide +kernel

theorem body_header_6 :
    functionHeader "context_tail" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "state", ".", "context", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "context_tail", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "state", ".", "context", ".", "after", ",", "decreases", "=>", "(", "if", "state", ".", "complete", "then", "0", "else", "1", ")", ")"] := by decide +kernel

theorem body_header_7 :
    functionHeader "context_tail" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_result"] := by decide +kernel

theorem body_header_8 :
    functionHeader "context_model" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ")", "return", "context_result"] := by decide +kernel

theorem body_header_9 :
    functionHeader "read_context" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ")", "return", "context_result"] := by decide +kernel

theorem body_header_10 :
    functionHeader "context_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "arguments", ":", "boolean", ")", "return", "literal_position"] := by decide +kernel

theorem body_header_11 :
    functionHeader "operation_name" ";" Source.namesBodyTokens = some ["(", "operation", ":", "operation_kind", ")", "return", "string", "with", "global", "=>", "null", ",", "post", "=>", "operation_name", "'", "result", "'", "first", "=", "1", "and", "then", "operation_name", "'", "result", "'", "length", "in", "1", "..", "16"] := by decide +kernel

theorem body_header_12 :
    functionHeader "operation_name" "is" Source.namesBodyTokens = some ["(", "operation", ":", "operation_kind", ")", "return", "string"] := by decide +kernel

theorem body_header_13 :
    functionHeader "operation_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operation", ":", "operation_kind", ";", "hidden", ":", "boolean", ")", "return", "literal_position"] := by decide +kernel

theorem body_header_14 :
    functionHeader "association_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "default", ":", "boolean", ")", "return", "literal_position"] := by decide +kernel

structure CheckedSource : Prop where
  specification : Source.lex Source.namesSpec = some Source.namesSpecTokens
  implementation : Source.lex Source.namesBody = some Source.namesBodyTokens
  reviewedShape : ReviewedShape
  expressions : ExpressionTranslation
  declarations : Declarations
  spec_header_0 : functionHeader "context_model" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ")", "return", "context_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "context_model", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1"]
  spec_header_1 : functionHeader "read_context" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ")", "return", "context_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "(", "runtime", "=>", "read_context", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "static", "=>", "read_context", "'", "result", "=", "context_model", "(", "text", ")", ")"]
  spec_header_2 : functionHeader "context_after" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ";", "arguments", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "context_after", "'", "result", "<=", "text", "'", "last", "+", "1"]
  spec_header_3 : functionHeader "operation_after" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operation", ":", "operation_kind", ";", "hidden", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "operation_after", "'", "result", "=", "0", "or", "else", "operation_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]
  spec_header_4 : functionHeader "association_after" ";" Source.namesSpecTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "default", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "association_after", "'", "result", "in", "position", "..", "text", "'", "last", "+", "1"]
  body_header_0 : functionHeader "fixed_after" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "word", "'", "first", "=", "1", "and", "then", "word", "'", "length", "in", "1", "..", "16", ",", "post", "=>", "fixed_after", "'", "result", "=", "0", "or", "else", "fixed_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]
  body_header_1 : functionHeader "fixed_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position"]
  body_header_2 : functionHeader "take" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "word", "'", "first", "=", "1", "and", "then", "word", "'", "length", "in", "1", "..", "16", ",", "post", "=>", "(", "runtime", "=>", "take", "'", "result", "=", "0", "or", "else", "take", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "take", "'", "result", "=", "fixed_after", "(", "text", ",", "position", ",", "word", ",", "is_word", ")", ")"]
  body_header_3 : functionHeader "take" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word", ":", "string", ";", "is_word", ":", "boolean", ")", "return", "literal_position"]
  body_header_4 : functionHeader "context_step" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "state", ".", "context", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "context_step", "'", "result", ".", "context", ".", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "(", "context_step", "'", "result", ".", "context", ".", "after", "=", "0", "or", "else", "context_step", "'", "result", ".", "complete", "or", "else", "context_step", "'", "result", ".", "context", ".", "after", ">", "state", ".", "context", ".", "after", ")"]
  body_header_5 : functionHeader "context_step" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_state"]
  body_header_6 : functionHeader "context_tail" ";" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "state", ".", "context", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "context_tail", "'", "result", ".", "after", "<=", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "state", ".", "context", ".", "after", ",", "decreases", "=>", "(", "if", "state", ".", "complete", "then", "0", "else", "1", ")", ")"]
  body_header_7 : functionHeader "context_tail" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "state", ":", "context_state", ")", "return", "context_result"]
  body_header_8 : functionHeader "context_model" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ")", "return", "context_result"]
  body_header_9 : functionHeader "read_context" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ")", "return", "context_result"]
  body_header_10 : functionHeader "context_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "arguments", ":", "boolean", ")", "return", "literal_position"]
  body_header_11 : functionHeader "operation_name" ";" Source.namesBodyTokens = some ["(", "operation", ":", "operation_kind", ")", "return", "string", "with", "global", "=>", "null", ",", "post", "=>", "operation_name", "'", "result", "'", "first", "=", "1", "and", "then", "operation_name", "'", "result", "'", "length", "in", "1", "..", "16"]
  body_header_12 : functionHeader "operation_name" "is" Source.namesBodyTokens = some ["(", "operation", ":", "operation_kind", ")", "return", "string"]
  body_header_13 : functionHeader "operation_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operation", ":", "operation_kind", ";", "hidden", ":", "boolean", ")", "return", "literal_position"]
  body_header_14 : functionHeader "association_after" "is" Source.namesBodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "default", ":", "boolean", ")", "return", "literal_position"]

theorem checked_source : CheckedSource where
  specification := Source.namesSpecTokens_correct
  implementation := Source.namesBodyTokens_correct
  reviewedShape := actual_reviewed_shape
  expressions := actual_expressions
  declarations := actual_declarations
  spec_header_0 := spec_header_0
  spec_header_1 := spec_header_1
  spec_header_2 := spec_header_2
  spec_header_3 := spec_header_3
  spec_header_4 := spec_header_4
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

end Silver.Names.SourceBridge
