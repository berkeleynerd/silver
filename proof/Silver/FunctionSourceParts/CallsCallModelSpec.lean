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

theorem calls_callModel_spec :
    functionHeader "call_model" ";" Output.SourceShape.outputImplementation = some callModelSpec := by
  change functionHeader "call_model" ";" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog), Post => Call_Model'Result.After = 0 or else Call_Model'Result.After in Position + 1 .. Text'Last + 1")
  rw [FunctionRemainingExpectedTokens.callModelSpec]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "catalog", ":", "functions", ".", "metadata", ")", "return", "call_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "catalog", ")", ",", "post", "=>", "call_model", "'", "result", ".", "after", "=", "0", "or", "else", "call_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]))

end Silver.FunctionSourceCandidate.Parts
