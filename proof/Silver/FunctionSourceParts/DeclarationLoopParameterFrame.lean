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

theorem declaration_loop_parameter_frame :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.loops.get ⟨2, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  change BooleanDeclarationNative.SourceChecks.ordinaryFunction "parameter_frame" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "Result : Parser_State := Frame; Index : Parameter_Cursor := Frame.First_Parameter; begin if Frame.Position = 0 then return Invalid_State; end if; while Index <= Frame.Functions.Parameter_Count loop pragma Loop_Invariant (Index in Frame.First_Parameter .. Frame.Functions.Parameter_Count + 1); pragma Loop_Invariant (Result.Functions = Frame.Functions); pragma Loop_Invariant (Result.Position = Frame.Position); pragma Loop_Invariant (Result.Scalar_Names.Count >= Frame.Scalar_Names.Count); pragma Loop_Invariant (Result.Boolean_Names.Count >= Frame.Boolean_Names.Count); pragma Loop_Invariant (Valid_State (Text, Result)); pragma Loop_Invariant (Static => Parameter_Frame_Model (Frame, Frame.First_Parameter) = Parameter_Frame_Model (Result, Index)); pragma Loop_Variant (Increases => Index); Result := Append_Parameter (Result, Frame.Functions.Parameters (Index)); if Result.Position = 0 then return Invalid_State; end if; Index := Index + 1; end loop; return Result; end Parameter_Frame;")
  rw [FunctionRemainingExpectedTokens.parameterFrameLoop]
  kernel_exact (Eq.refl (some ["result", ":", "parser_state", ":=", "frame", ";", "index", ":", "parameter_cursor", ":=", "frame", ".", "first_parameter", ";", "begin", "if", "frame", ".", "position", "=", "0", "then", "return", "invalid_state", ";", "end", "if", ";", "while", "index", "<=", "frame", ".", "functions", ".", "parameter_count", "loop", "pragma", "loop_invariant", "(", "index", "in", "frame", ".", "first_parameter", "..", "frame", ".", "functions", ".", "parameter_count", "+", "1", ")", ";", "pragma", "loop_invariant", "(", "result", ".", "functions", "=", "frame", ".", "functions", ")", ";", "pragma", "loop_invariant", "(", "result", ".", "position", "=", "frame", ".", "position", ")", ";", "pragma", "loop_invariant", "(", "result", ".", "scalar_names", ".", "count", ">=", "frame", ".", "scalar_names", ".", "count", ")", ";", "pragma", "loop_invariant", "(", "result", ".", "boolean_names", ".", "count", ">=", "frame", ".", "boolean_names", ".", "count", ")", ";", "pragma", "loop_invariant", "(", "valid_state", "(", "text", ",", "result", ")", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "parameter_frame_model", "(", "frame", ",", "frame", ".", "first_parameter", ")", "=", "parameter_frame_model", "(", "result", ",", "index", ")", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "index", ")", ";", "result", ":=", "append_parameter", "(", "result", ",", "frame", ".", "functions", ".", "parameters", "(", "index", ")", ")", ";", "if", "result", ".", "position", "=", "0", "then", "return", "invalid_state", ";", "end", "if", ";", "index", ":=", "index", "+", "1", ";", "end", "loop", ";", "return", "result", ";", "end", "parameter_frame", ";"]))

end Silver.FunctionSourceCandidate.Parts
