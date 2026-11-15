module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
public import Silver.FunctionSourceParts.FunctionRemainingExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_loop_parameters_at :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.loops.get ⟨0, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  change BooleanDeclarationNative.SourceChecks.ordinaryFunction "parameters_at" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "Current : Parser_State := State; begin loop pragma Loop_Invariant (Valid_State (Text, Current)); pragma Loop_Invariant (Current.Position >= State.Position); pragma Loop_Invariant (Current.Functions.Count = State.Functions.Count); pragma Loop_Invariant (Current.Functions.Parameter_Count >= State.Functions.Parameter_Count); pragma Loop_Invariant (Current.First_Parameter = State.First_Parameter); pragma Loop_Invariant (Current.Pure = State.Pure); pragma Loop_Invariant (Static => Parameters_Model (Text, State, Arguments) = Parameters_Model (Text, Current, Arguments)); pragma Loop_Variant (Increases => Current.Position); declare Next : constant Parameter_Step_Result := Parameter_Step (Text, Current, Arguments); begin if Next.State.Position = 0 then return Invalid_State; end if; if Next.Closed then return Next.State; end if; Current := Next.State; end; end loop; end Parameters_At;")
  rw [FunctionRemainingExpectedTokens.parametersAtLoop]
  kernel_exact (Eq.refl (some ["current", ":", "parser_state", ":=", "state", ";", "begin", "loop", "pragma", "loop_invariant", "(", "valid_state", "(", "text", ",", "current", ")", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "position", ">=", "state", ".", "position", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "functions", ".", "count", "=", "state", ".", "functions", ".", "count", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "functions", ".", "parameter_count", ">=", "state", ".", "functions", ".", "parameter_count", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "first_parameter", "=", "state", ".", "first_parameter", ")", ";", "pragma", "loop_invariant", "(", "current", ".", "pure", "=", "state", ".", "pure", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "parameters_model", "(", "text", ",", "state", ",", "arguments", ")", "=", "parameters_model", "(", "text", ",", "current", ",", "arguments", ")", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "current", ".", "position", ")", ";", "declare", "next", ":", "constant", "parameter_step_result", ":=", "parameter_step", "(", "text", ",", "current", ",", "arguments", ")", ";", "begin", "if", "next", ".", "state", ".", "position", "=", "0", "then", "return", "invalid_state", ";", "end", "if", ";", "if", "next", ".", "closed", "then", "return", "next", ".", "state", ";", "end", "if", ";", "current", ":=", "next", ".", "state", ";", "end", ";", "end", "loop", ";", "end", "parameters_at", ";"]))

end Silver.FunctionSourceCandidate.Parts
