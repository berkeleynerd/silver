module

public import Silver.ProcedureNameSource
public import Silver.ReviewedOutputShape
public import Silver.ProcedureNameSourceParts.LoopExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.ProcedureNameNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureNameSourceCandidate.Parts

theorem loop :
    Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
      "actual_name_free" Output.SourceShape.outputImplementation = some SourceChecks.loopBody := by
  change Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "actual_name_free" Output.SourceShape.outputImplementation =
      some (expectedTokens "Position : Literal_Position := First; begin if Position = 0 or else Position > After then return False; end if; while Position < After loop pragma Loop_Invariant (Position in First .. After); pragma Loop_Invariant (Static => Actual_Name_Free_Model (Text, First, After, Target_First, Target_After) = Actual_Name_Free_Model (Text, Position, After, Target_First, Target_After)); pragma Loop_Variant (Increases => Position); declare Next : constant Name_Scan_Step := Actual_Name_Step (Text, Position, After, Target_First, Target_After); begin if Next.Next = 0 or else not Next.Free then return False; end if; Position := Next.Next; end; end loop; return True; end Actual_Name_Free;")
  rw [LoopExpectedTokens.loopBody]
  kernel_exact (Eq.refl (some ["position", ":", "literal_position", ":=", "first", ";", "begin", "if", "position", "=", "0", "or", "else", "position", ">", "after", "then", "return", "false", ";", "end", "if", ";", "while", "position", "<", "after", "loop", "pragma", "loop_invariant", "(", "position", "in", "first", "..", "after", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "actual_name_free_model", "(", "text", ",", "first", ",", "after", ",", "target_first", ",", "target_after", ")", "=", "actual_name_free_model", "(", "text", ",", "position", ",", "after", ",", "target_first", ",", "target_after", ")", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "position", ")", ";", "declare", "next", ":", "constant", "name_scan_step", ":=", "actual_name_step", "(", "text", ",", "position", ",", "after", ",", "target_first", ",", "target_after", ")", ";", "begin", "if", "next", ".", "next", "=", "0", "or", "else", "not", "next", ".", "free", "then", "return", "false", ";", "end", "if", ";", "position", ":=", "next", ".", "next", ";", "end", ";", "end", "loop", ";", "return", "true", ";", "end", "actual_name_free", ";"]))

end Silver.ProcedureNameSourceCandidate.Parts

