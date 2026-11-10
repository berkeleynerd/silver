module

public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedureParameterStep
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedureParametersModel
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedureParametersAt
public import Silver.ProcedureDeclarationHelperWholeSourceParts.AppendProcedureParameter
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedureInputFrameModel
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedureInputFrame
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedurePrefixStep
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedurePrefixModel
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ProcedurePrefix
public import Silver.ProcedureDeclarationHelperWholeSourceParts.StepResult
public import Silver.ProcedureDeclarationHelperWholeSourceParts.ParameterCursor

@[expose] public section

namespace Silver.ProcedureDeclarationHelperWholeSourceCandidate
open Silver.Compose.ProcedureDeclarationNative

/-- These checks use the reviewed complete native source. The authoritative
adapter binds that token sequence to the freshly certified Ada source. -/
theorem checked : HelperSourceChecks.Checked Output.SourceShape.outputImplementation where
  trees := checked_helper_trees
  headers := by
    intro item member
    simp only [HelperSourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact Parts.headers_0
    · exact Parts.headers_1
    · exact Parts.headers_2
    · exact Parts.headers_3
    · exact Parts.headers_4
    · exact Parts.headers_5
    · exact Parts.headers_6
    · exact Parts.headers_7
    · exact Parts.headers_8
    · exact Parts.headers_9
    · exact Parts.headers_10
    · exact Parts.headers_11
    · exact Parts.headers_12
    · exact Parts.headers_13
    · exact Parts.headers_14
    · exact Parts.headers_15
    · exact Parts.headers_16
  expressions := by
    intro item member
    simp only [HelperSourceChecks.expressions, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl | rfl
    · exact Parts.expressions_0
    · exact Parts.expressions_1
    · exact Parts.expressions_2
    · exact Parts.expressions_3
    · exact Parts.expressions_4
  ordinary := by
    intro item member
    simp only [HelperSourceChecks.ordinary, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl
    · exact Parts.ordinary_0
  loops := by
    intro item member
    rcases List.mem_cons.mp member with rfl | member
    · exact Parts.loops_0
    rcases List.mem_cons.mp member with rfl | member
    · exact Parts.loops_1
    rcases List.mem_cons.mp member with rfl | member
    · exact Parts.loops_2
    cases member
  stepResult := Parts.stepResult
  parameterCursor := Parts.parameterCursor

end Silver.ProcedureDeclarationHelperWholeSourceCandidate
