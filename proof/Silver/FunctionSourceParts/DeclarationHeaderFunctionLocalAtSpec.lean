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

theorem declaration_header_function_local_at_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨8, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "function_local_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Function_Local_At'Result) and then (Function_Local_At'Result.Position = 0 or else (Function_Local_At'Result.Position > State.Position and then Function_Local_At'Result.Functions = State.Functions and then Function_Local_At'Result.Procedures = State.Procedures and then Function_Local_At'Result.First_Procedure_Parameter = State.First_Procedure_Parameter and then Function_Local_At'Result.First_Parameter = State.First_Parameter and then Function_Local_At'Result.Pure = State.Pure))")
  rw [FunctionParameterLocalHeaderTokens.functionLocalAt]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "function_local_at", "'", "result", ")", "and", "then", "(", "function_local_at", "'", "result", ".", "position", "=", "0", "or", "else", "(", "function_local_at", "'", "result", ".", "position", ">", "state", ".", "position", "and", "then", "function_local_at", "'", "result", ".", "functions", "=", "state", ".", "functions", "and", "then", "function_local_at", "'", "result", ".", "procedures", "=", "state", ".", "procedures", "and", "then", "function_local_at", "'", "result", ".", "first_procedure_parameter", "=", "state", ".", "first_procedure_parameter", "and", "then", "function_local_at", "'", "result", ".", "first_parameter", "=", "state", ".", "first_parameter", "and", "then", "function_local_at", "'", "result", ".", "pure", "=", "state", ".", "pure", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
