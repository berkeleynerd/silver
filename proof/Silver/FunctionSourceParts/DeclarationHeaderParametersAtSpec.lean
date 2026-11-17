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

theorem declaration_header_parameters_at_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨6, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "parameters_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => (Runtime => Valid_State (Text, Parameters_At'Result) and then (Parameters_At'Result.Position = 0 or else (Parameters_At'Result.Position > State.Position and then Parameters_At'Result.Functions.Count = State.Functions.Count and then Parameters_At'Result.Functions.Parameter_Count > State.Functions.Parameter_Count and then Parameters_At'Result.First_Parameter = State.First_Parameter and then Parameters_At'Result.Pure = State.Pure)), Static => Parameters_At'Result = Parameters_Model (Text, State, Arguments))")
  rw [FunctionParameterLocalHeaderTokens.parametersAt]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "parameters_at", "'", "result", ")", "and", "then", "(", "parameters_at", "'", "result", ".", "position", "=", "0", "or", "else", "(", "parameters_at", "'", "result", ".", "position", ">", "state", ".", "position", "and", "then", "parameters_at", "'", "result", ".", "functions", ".", "count", "=", "state", ".", "functions", ".", "count", "and", "then", "parameters_at", "'", "result", ".", "functions", ".", "parameter_count", ">", "state", ".", "functions", ".", "parameter_count", "and", "then", "parameters_at", "'", "result", ".", "first_parameter", "=", "state", ".", "first_parameter", "and", "then", "parameters_at", "'", "result", ".", "pure", "=", "state", ".", "pure", ")", ")", ",", "static", "=>", "parameters_at", "'", "result", "=", "parameters_model", "(", "text", ",", "state", ",", "arguments", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
