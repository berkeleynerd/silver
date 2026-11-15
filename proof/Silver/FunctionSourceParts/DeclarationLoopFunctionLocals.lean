module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
public import Silver.FunctionSourceParts.FunctionLocalsExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_loop_function_locals :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.loops.get ⟨1, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  change BooleanDeclarationNative.SourceChecks.ordinaryFunction "function_locals"
    Output.SourceShape.outputImplementation = some (expectedTokens "Current : Parser_State := State; begin while Current.Position /= 0 loop pragma Loop_Invariant (Valid_State (Text, Current)); pragma Loop_Invariant (Current.Position >= State.Position); pragma Loop_Invariant (Current.Functions = State.Functions); pragma Loop_Invariant (Current.Procedures = State.Procedures); pragma Loop_Invariant (Current.First_Procedure_Parameter = State.First_Procedure_Parameter); pragma Loop_Invariant (Current.First_Parameter = State.First_Parameter); pragma Loop_Invariant (Current.Pure = State.Pure); pragma Loop_Invariant (Static => Function_Locals_Model (Text, State, Arguments) = Function_Locals_Model (Text, Current, Arguments)); pragma Loop_Variant (Increases => Current.Position); if Take_Token (Text, Current.Position, Begin_Keyword) /= 0 then return Current; end if; Current := Function_Local_At (Text, Current, Arguments); end loop; return Invalid_State; end Function_Locals;")
  rw [FunctionLocalsExpectedTokens.checked]
  kernel_exact (Eq.refl (some ["current", ":", "parser_state", ":=", "state", ";", "begin", "while", "current", ".", "position", "/=", "0", "loop", "pragma", "loop_invariant", "(", "valid_state", "(", "text", ",", "current", ")", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "position", ">=", "state", ".", "position", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "functions", "=", "state", ".", "functions", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "procedures", "=", "state", ".", "procedures", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "first_procedure_parameter", "=", "state", ".", "first_procedure_parameter", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "first_parameter", "=", "state", ".", "first_parameter", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "pure", "=", "state", ".", "pure", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "function_locals_model", "(", "text", ",", "state", ",", "arguments", ")", "=", "function_locals_model", "(", "text", ",", "current", ",", "arguments", ")", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "current", ".", "position", ")", ";", "if", "take_token", "(", "text", ",", "current", ".", "position", ",", "begin_keyword", ")", "/=", "0", "then", "return", "current", ";", "end", "if", ";", "current", ":=", "function_local_at", "(", "text", ",", "current", ",", "arguments", ")", ";", "end", "loop", ";", "return", "invalid_state", ";", "end", "function_locals", ";"]))

end Silver.FunctionSourceCandidate.Parts
