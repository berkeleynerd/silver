module

public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureTargetActual
public import Silver.PredicateProcedureCallWholeSourceParts.BodyEquality
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureActualAfter
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureActualsModel
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureActualsAfter
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureUpdateStep
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureUpdatesModel
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureUpdates
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureCalleeAt
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureCallBody
public import Silver.PredicateProcedureCallWholeSourceParts.ActualResult
public import Silver.PredicateProcedureCallWholeSourceParts.InvalidActual

public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureActualsTailModel
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedurePayloadsFreeModel
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedurePayloadsFree
public import Silver.PredicateProcedureCallWholeSourceParts.ProcedureUpdatesTailModel
public import Silver.PredicateAssociationWholeSourceCandidate

@[expose] public section

namespace Silver.PredicateProcedureCallWholeSourceCandidate
open Silver.Predicate.ProcedureCallNative

/-- These checks use the reviewed complete native source. The authoritative
adapter binds that token sequence to the freshly certified Ada source. -/
theorem checked : SourceChecks.Checked Output.SourceShape.outputImplementation where
  trees := checked_trees
  associations := PredicateAssociationWholeSourceCandidate.checked
  bodyEquality := Parts.bodyEquality
  headers := by
    intro item member
    simp only [SourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
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
    · exact Parts.headers_17
    · exact Parts.headers_18
    · exact Parts.headers_19
    · exact Parts.headers_20
    · exact Parts.headers_21
    · exact Parts.headers_22
    · exact Parts.headers_23
    · exact Parts.headers_24
    · exact Parts.headers_25
  expressions := by
    intro item member
    simp only [SourceChecks.expressions, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact Parts.expressions_0
    · exact Parts.expressions_1
    · exact Parts.expressions_2
    · exact Parts.expressions_3
    · exact Parts.expressions_4
    · exact Parts.expressions_5
    · exact Parts.expressions_6
  ordinary := by
    intro item member
    simp only [SourceChecks.ordinary, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl
    · exact Parts.ordinary_0
    · exact Parts.ordinary_1
    · exact Parts.ordinary_2
  loops := by
    intro item member
    rcases List.mem_cons.mp member with rfl | member
    · exact Parts.loops_0
    rcases List.mem_cons.mp member with rfl | member
    · exact Parts.loops_1
    rcases List.mem_cons.mp member with rfl | member
    · exact Parts.loops_2
    · cases member
  actualResult := Parts.actualResult
  invalidActual := Parts.invalidActual

end Silver.PredicateProcedureCallWholeSourceCandidate
