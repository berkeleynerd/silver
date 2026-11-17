module

public import Silver.ProcedureDeclarationHighSource
public import Silver.ReviewedOutputShape
public import Silver.ProcedureDeclarationHighSourceParts.MetadataAppendExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose
open Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureDeclarationHighSourceCandidate.Parts

theorem ordinary_0 :
    let item := HighSourceChecks.ordinary.get ⟨0, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

theorem metadata_append_header :
    procedureHeader "lemma_procedure_metadata_append" "is" Output.SourceShape.outputImplementation =
      some HighSourceChecks.metadataAppendHeader := by
  change procedureHeader "lemma_procedure_metadata_append" "is" Output.SourceShape.outputImplementation =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Environment : Procedures.Metadata; Item : Procedures.Signature) with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Procedures.Valid_Metadata (Text, Environment) and then Environment.Count < Procedures.Max_Procedures and then Item.First > 0 and then Valid_Name_State (Text, Item.First, Item.After) and then Item.Count > 0 and then Item.Formal_First > 0 and then Item.Formal_First <= Environment.Parameter_Count and then Item.Count <= Environment.Parameter_Count - Item.Formal_First + 1, Post => Procedures.Valid_Metadata (Text, Procedures.Append (Environment, Item))")
  rw [MetadataAppendExpectedTokens.metadataAppend]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "environment", ":", "procedures", ".", "metadata", ";", "item", ":", "procedures", ".", "signature", ")", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "procedures", ".", "valid_metadata", "(", "text", ",", "environment", ")", "and", "then", "environment", ".", "count", "<", "procedures", ".", "max_procedures", "and", "then", "item", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "item", ".", "first", ",", "item", ".", "after", ")", "and", "then", "item", ".", "count", ">", "0", "and", "then", "item", ".", "formal_first", ">", "0", "and", "then", "item", ".", "formal_first", "<=", "environment", ".", "parameter_count", "and", "then", "item", ".", "count", "<=", "environment", ".", "parameter_count", "-", "item", ".", "formal_first", "+", "1", ",", "post", "=>", "procedures", ".", "valid_metadata", "(", "text", ",", "procedures", ".", "append", "(", "environment", ",", "item", ")", ")"]))

end Silver.ProcedureDeclarationHighSourceCandidate.Parts
