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

theorem declaration_ordinary_function_body_at :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.ordinary.get ⟨1, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

theorem declaration_metadata_append_header :
    procedureHeader "lemma_function_metadata_append" "is" Output.SourceShape.outputImplementation =
      some Silver.Compose.FunctionDeclarationNative.SourceChecks.metadataAppendHeader := by
  change procedureHeader "lemma_function_metadata_append" "is" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Environment : Functions.Metadata; Item : Functions.Signature) with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Functions.Valid_Metadata (Text, Environment) and then Environment.Count < Functions.Max_Functions and then Item.First > 0 and then Valid_Name_State (Text, Item.First, Item.After) and then Item.Count > 0 and then Item.Formal_First > 0 and then Item.Formal_First <= Environment.Parameter_Count and then Item.Count <= Environment.Parameter_Count - Item.Formal_First + 1 and then not Scalars.Is_Empty (Item.Result_Bounds), Post => Functions.Valid_Metadata (Text, Functions.Append (Environment, Item))")
  rw [FunctionRemainingExpectedTokens.metadataAppend]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "environment", ":", "functions", ".", "metadata", ";", "item", ":", "functions", ".", "signature", ")", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "environment", ")", "and", "then", "environment", ".", "count", "<", "functions", ".", "max_functions", "and", "then", "item", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "item", ".", "first", ",", "item", ".", "after", ")", "and", "then", "item", ".", "count", ">", "0", "and", "then", "item", ".", "formal_first", ">", "0", "and", "then", "item", ".", "formal_first", "<=", "environment", ".", "parameter_count", "and", "then", "item", ".", "count", "<=", "environment", ".", "parameter_count", "-", "item", ".", "formal_first", "+", "1", "and", "then", "not", "scalars", ".", "is_empty", "(", "item", ".", "result_bounds", ")", ",", "post", "=>", "functions", ".", "valid_metadata", "(", "text", ",", "functions", ".", "append", "(", "environment", ",", "item", ")", ")"]))

end Silver.FunctionSourceCandidate.Parts
