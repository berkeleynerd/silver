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

@[expose] public section

namespace Silver.PredicateProcedureCallWholeSourceCandidate
open Silver.Predicate.ProcedureCallNative

/-- These checks use the reviewed complete native source. The authoritative
adapter binds that token sequence to the freshly certified Ada source. -/
theorem checked : SourceChecks.Checked Output.SourceShape.outputImplementation where
  trees := checked_trees
  bodyEquality := Parts.bodyEquality
  headers := by
    intro item member
    simp only [SourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
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
  expressions := by
    intro item member
    simp only [SourceChecks.expressions, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl
    · exact Parts.expressions_0
    · exact Parts.expressions_1
    · exact Parts.expressions_2
    · exact Parts.expressions_3
  ordinary := by
    intro item member
    simp only [SourceChecks.ordinary, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl
    · exact Parts.ordinary_0
    · exact Parts.ordinary_1
    · exact Parts.ordinary_2
  loops := by
    intro item member
    simp only [SourceChecks.loops, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl
    · exact Parts.loops_0
    · exact Parts.loops_1
  actualResult := Parts.actualResult
  invalidActual := Parts.invalidActual

end Silver.PredicateProcedureCallWholeSourceCandidate
