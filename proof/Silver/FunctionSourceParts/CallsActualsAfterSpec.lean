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

theorem calls_actualsAfter_spec :
    functionHeader "actuals_after" ";" Output.SourceShape.outputImplementation = some actualsAfterSpec := by
  change functionHeader "actuals_after" ";" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog) and then First <= Last and then Last <= Catalog.Parameter_Count, Post => (Runtime => Actuals_After'Result = 0 or else Actuals_After'Result in Position + 1 .. Text'Last + 1, Static => Actuals_After'Result = Actuals_Model (Text, Context, Position, Facts, Catalog, First, Last))")
  rw [FunctionRemainingExpectedTokens.actualsAfterSpec]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "catalog", ":", "functions", ".", "metadata", ";", "first", ",", "last", ":", "functions", ".", "formal_index", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "catalog", ")", "and", "then", "first", "<=", "last", "and", "then", "last", "<=", "catalog", ".", "parameter_count", ",", "post", "=>", "(", "runtime", "=>", "actuals_after", "'", "result", "=", "0", "or", "else", "actuals_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "actuals_after", "'", "result", "=", "actuals_model", "(", "text", ",", "context", ",", "position", ",", "facts", ",", "catalog", ",", "first", ",", "last", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
