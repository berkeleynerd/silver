module

public import Silver.PredicateAssociationWholeSourceParts.FunctionFormalModel
public import Silver.PredicateAssociationWholeSourceParts.FunctionFormalAt
public import Silver.PredicateAssociationWholeSourceParts.ProcedureFormalModel
public import Silver.PredicateAssociationWholeSourceParts.ProcedureFormalAt
public import Silver.PredicateAssociationWholeSourceParts.FunctionAssociation
public import Silver.PredicateAssociationWholeSourceParts.ProcedureAssociation
public import Silver.PredicateAssociationWholeSourceParts.Types
public import Silver.PredicateAssociationWholeSourceParts.MarkFormal

@[expose] public section

namespace Silver.PredicateAssociationWholeSourceCandidate
open Silver.Predicate.AssociationNative

/-- Exact source extraction accompanies the interpreted resolver equations.
The authoritative bridge later transports this reviewed complete token shape. -/
theorem checked : SourceChecks.Checked Output.SourceShape.outputImplementation where
  trees := checked_trees
  markFormalSpec := Parts.mark_formal_spec
  markFormalImpl := Parts.mark_formal_impl
  markFormalBody := Parts.mark_formal_body
  headers := by
    intro item member
    simp only [SourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
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
  expressions := by
    intro item member
    simp only [SourceChecks.expressions, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl
    · exact Parts.expressions_0
    · exact Parts.expressions_1
    · exact Parts.expressions_2
    · exact Parts.expressions_3
  loops := by
    intro item member
    simp only [SourceChecks.loops, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl
    · exact Parts.loops_0
    · exact Parts.loops_1
  formalSet := Parts.formalSet
  noFormals := Parts.noFormals
  association := Parts.association
  invalidAssociation := Parts.invalidAssociation

end Silver.PredicateAssociationWholeSourceCandidate
