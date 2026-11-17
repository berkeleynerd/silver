module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
public import Silver.FunctionSourceParts.FunctionDeclarationHeaderExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_header_function_body_at_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨21, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "function_body_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; Outer : Parser_State; Frame : Parser_State; First, After : Literal_Position; Result_Type : Function_Type_Result; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Outer) and then Valid_State (Text, Frame) and then Outer.Functions.Parameter_Count <= Frame.Functions.Parameter_Count and then Frame.First_Parameter > 0 and then Frame.First_Parameter <= Frame.Functions.Parameter_Count and then Frame.Functions.Count < Functions.Max_Functions and then Valid_Name_State (Text, First, After) and then First > 0 and then not Scalars.Is_Empty (Result_Type.Bounds), Post => Valid_State (Text, Function_Body_At'Result) and then (Function_Body_At'Result.Position = 0 or else Function_Body_At'Result.Position > Outer.Position)")
  rw [FunctionDeclarationHeaderExpectedTokens.functionBodyAt]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "outer", ":", "parser_state", ";", "frame", ":", "parser_state", ";", "first", ",", "after", ":", "literal_position", ";", "result_type", ":", "function_type_result", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "outer", ")", "and", "then", "valid_state", "(", "text", ",", "frame", ")", "and", "then", "outer", ".", "functions", ".", "parameter_count", "<=", "frame", ".", "functions", ".", "parameter_count", "and", "then", "frame", ".", "first_parameter", ">", "0", "and", "then", "frame", ".", "first_parameter", "<=", "frame", ".", "functions", ".", "parameter_count", "and", "then", "frame", ".", "functions", ".", "count", "<", "functions", ".", "max_functions", "and", "then", "valid_name_state", "(", "text", ",", "first", ",", "after", ")", "and", "then", "first", ">", "0", "and", "then", "not", "scalars", ".", "is_empty", "(", "result_type", ".", "bounds", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "function_body_at", "'", "result", ")", "and", "then", "(", "function_body_at", "'", "result", ".", "position", "=", "0", "or", "else", "function_body_at", "'", "result", ".", "position", ">", "outer", ".", "position", ")"]))

end Silver.FunctionSourceCandidate.Parts
