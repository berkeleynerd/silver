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

theorem declaration_header_parameter_frame_spec :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨17, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  change functionHeader "parameter_frame" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; Frame : Parser_State) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Frame) and then Frame.First_Parameter > 0, Post => (Runtime => Valid_State (Text, Parameter_Frame'Result) and then (Parameter_Frame'Result.Position = 0 or else (Parameter_Frame'Result.Position = Frame.Position and then Parameter_Frame'Result.Functions = Frame.Functions and then Parameter_Frame'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count and then Parameter_Frame'Result.Boolean_Names.Count >= Frame.Boolean_Names.Count)), Static => Parameter_Frame'Result = Parameter_Frame_Model (Frame, Frame.First_Parameter))")
  rw [FunctionParameterLocalHeaderTokens.parameterFrame]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "frame", ":", "parser_state", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "frame", ")", "and", "then", "frame", ".", "first_parameter", ">", "0", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "parameter_frame", "'", "result", ")", "and", "then", "(", "parameter_frame", "'", "result", ".", "position", "=", "0", "or", "else", "(", "parameter_frame", "'", "result", ".", "position", "=", "frame", ".", "position", "and", "then", "parameter_frame", "'", "result", ".", "functions", "=", "frame", ".", "functions", "and", "then", "parameter_frame", "'", "result", ".", "scalar_names", ".", "count", ">=", "frame", ".", "scalar_names", ".", "count", "and", "then", "parameter_frame", "'", "result", ".", "boolean_names", ".", "count", ">=", "frame", ".", "boolean_names", ".", "count", ")", ")", ",", "static", "=>", "parameter_frame", "'", "result", "=", "parameter_frame_model", "(", "frame", ",", "frame", ".", "first_parameter", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
