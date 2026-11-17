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

theorem declaration_header_parameter_step_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨2, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "parameter_step" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parameter_Step_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Parameter_Step'Result.State) and then (Parameter_Step'Result.State.Position = 0 or else (Parameter_Step'Result.State.Position > State.Position and then Parameter_Step'Result.State.Functions.Count = State.Functions.Count and then Parameter_Step'Result.State.Functions.Parameter_Count = State.Functions.Parameter_Count + 1 and then Parameter_Step'Result.State.First_Parameter = State.First_Parameter and then Parameter_Step'Result.State.Pure = State.Pure))")
  rw [FunctionParameterLocalHeaderTokens.parameterStep]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parameter_step_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "parameter_step", "'", "result", ".", "state", ")", "and", "then", "(", "parameter_step", "'", "result", ".", "state", ".", "position", "=", "0", "or", "else", "(", "parameter_step", "'", "result", ".", "state", ".", "position", ">", "state", ".", "position", "and", "then", "parameter_step", "'", "result", ".", "state", ".", "functions", ".", "count", "=", "state", ".", "functions", ".", "count", "and", "then", "parameter_step", "'", "result", ".", "state", ".", "functions", ".", "parameter_count", "=", "state", ".", "functions", ".", "parameter_count", "+", "1", "and", "then", "parameter_step", "'", "result", ".", "state", ".", "first_parameter", "=", "state", ".", "first_parameter", "and", "then", "parameter_step", "'", "result", ".", "state", ".", "pure", "=", "state", ".", "pure", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
