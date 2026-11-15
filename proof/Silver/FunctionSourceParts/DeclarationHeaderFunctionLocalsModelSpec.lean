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

theorem declaration_header_function_locals_model_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨10, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "function_locals_model" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Function_Locals_Model'Result) and then (Function_Locals_Model'Result.Position = 0 or else (Function_Locals_Model'Result.Position >= State.Position and then Function_Locals_Model'Result.Functions = State.Functions and then Function_Locals_Model'Result.Procedures = State.Procedures and then Function_Locals_Model'Result.First_Procedure_Parameter = State.First_Procedure_Parameter and then Function_Locals_Model'Result.First_Parameter = State.First_Parameter and then Function_Locals_Model'Result.Pure = State.Pure)), Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position)")
  rw [FunctionDeclarationHeaderExpectedTokens.functionLocalsModel]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "function_locals_model", "'", "result", ")", "and", "then", "(", "function_locals_model", "'", "result", ".", "position", "=", "0", "or", "else", "(", "function_locals_model", "'", "result", ".", "position", ">=", "state", ".", "position", "and", "then", "function_locals_model", "'", "result", ".", "functions", "=", "state", ".", "functions", "and", "then", "function_locals_model", "'", "result", ".", "procedures", "=", "state", ".", "procedures", "and", "then", "function_locals_model", "'", "result", ".", "first_procedure_parameter", "=", "state", ".", "first_procedure_parameter", "and", "then", "function_locals_model", "'", "result", ".", "first_parameter", "=", "state", ".", "first_parameter", "and", "then", "function_locals_model", "'", "result", ".", "pure", "=", "state", ".", "pure", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "state", ".", "position", ")"]))

end Silver.FunctionSourceCandidate.Parts
