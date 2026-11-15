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

theorem calls_callAssignmentBody_spec :
    functionHeader "call_assignment_body" ";" Output.SourceShape.outputImplementation = some callAssignmentBodySpec := by
  change functionHeader "call_assignment_body" ";" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata) return Body_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan) and then Functions.Valid_Metadata (Text, Catalog), Post => (Runtime => Valid_Body (Text, Context, Call_Assignment_Body'Result) and then (Call_Assignment_Body'Result.Position = 0 or else Call_Assignment_Body'Result.Position > Scan.Position), Static => Call_Assignment_Body'Result = Call_Assignment_Model (Text, Context, Scan, Catalog))")
  rw [FunctionRemainingExpectedTokens.callAssignmentBodySpec]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ";", "catalog", ":", "functions", ".", "metadata", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "catalog", ")", ",", "post", "=>", "(", "runtime", "=>", "valid_body", "(", "text", ",", "context", ",", "call_assignment_body", "'", "result", ")", "and", "then", "(", "call_assignment_body", "'", "result", ".", "position", "=", "0", "or", "else", "call_assignment_body", "'", "result", ".", "position", ">", "scan", ".", "position", ")", ",", "static", "=>", "call_assignment_body", "'", "result", "=", "call_assignment_model", "(", "text", ",", "context", ",", "scan", ",", "catalog", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
