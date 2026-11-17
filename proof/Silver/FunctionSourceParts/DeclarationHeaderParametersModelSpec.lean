module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
public import Silver.FunctionSourceParts.FunctionParameterLocalHeaderTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_header_parameters_model_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨4, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "parameters_model" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Parameters_Model'Result) and then (Parameters_Model'Result.Position = 0 or else (Parameters_Model'Result.Position > State.Position and then Parameters_Model'Result.Functions.Count = State.Functions.Count and then Parameters_Model'Result.Functions.Parameter_Count > State.Functions.Parameter_Count and then Parameters_Model'Result.First_Parameter = State.First_Parameter and then Parameters_Model'Result.Pure = State.Pure)), Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position)")
  rw [FunctionParameterLocalHeaderTokens.parametersModel]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "parameters_model", "'", "result", ")", "and", "then", "(", "parameters_model", "'", "result", ".", "position", "=", "0", "or", "else", "(", "parameters_model", "'", "result", ".", "position", ">", "state", ".", "position", "and", "then", "parameters_model", "'", "result", ".", "functions", ".", "count", "=", "state", ".", "functions", ".", "count", "and", "then", "parameters_model", "'", "result", ".", "functions", ".", "parameter_count", ">", "state", ".", "functions", ".", "parameter_count", "and", "then", "parameters_model", "'", "result", ".", "first_parameter", "=", "state", ".", "first_parameter", "and", "then", "parameters_model", "'", "result", ".", "pure", "=", "state", ".", "pure", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "state", ".", "position", ")"]))

end Silver.FunctionSourceCandidate.Parts
