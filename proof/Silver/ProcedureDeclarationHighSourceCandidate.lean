module

public import Silver.ProcedureDeclarationHighSourceParts.BodySpec
public import Silver.ProcedureDeclarationHighSourceParts.BodyImpl
public import Silver.ProcedureDeclarationHighSourceParts.OuterSpec
public import Silver.ProcedureDeclarationHighSourceParts.OuterImpl
public import Silver.ProcedureDeclarationHighSourceParts.Body
public import Silver.ProcedureDeclarationHighSourceParts.Outer

@[expose] public section

namespace Silver.ProcedureDeclarationHighSourceCandidate
open Silver.Compose.ProcedureDeclarationNative

/-- Each independently checked fragment uses the same reviewed native tokens.
The authoritative adapter joins this candidate to the source certificate. -/
theorem checked : HighSourceChecks.Checked Output.SourceShape.outputImplementation where
  trees := HighSourceChecks.checked_trees
  metadataAppend := Parts.metadata_append_header
  headers := by
    intro item member
    simp only [HighSourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl | rfl | rfl
    · exact Parts.header_0
    · exact Parts.header_1
    · exact Parts.header_2
    · exact Parts.header_3
  ordinary := by
    intro item member
    simp only [HighSourceChecks.ordinary, List.mem_cons, List.mem_nil_iff, or_false] at member
    rcases member with rfl | rfl
    · exact Parts.ordinary_0
    · exact Parts.ordinary_1

end Silver.ProcedureDeclarationHighSourceCandidate
