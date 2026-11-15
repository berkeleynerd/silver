module

public import Silver.PredicateFunctionCallSource
public import Silver.ReviewedOutputShape
public import Silver.FunctionSourceParts.FunctionRemainingExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.FunctionCallNative
open Silver.Predicate.FunctionCallNative.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem calls_actualAfter_spec :
    functionHeader "actual_after" ";" Output.SourceShape.outputImplementation = some actualAfterSpec := by
  change functionHeader "actual_after" ";" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => (Runtime => Actual_After'Result = 0 or else Actual_After'Result in Position + 1 .. Text'Last + 1, Static => Actual_After'Result = Actual_Model (Text, Context, Position, Facts, Parameter))")
  rw [FunctionRemainingExpectedTokens.actualAfterSpec]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "parameter", ":", "functions", ".", "formal", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", ",", "post", "=>", "(", "runtime", "=>", "actual_after", "'", "result", "=", "0", "or", "else", "actual_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "actual_after", "'", "result", "=", "actual_model", "(", "text", ",", "context", ",", "position", ",", "facts", ",", "parameter", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
