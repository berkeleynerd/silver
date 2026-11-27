module

public import Silver.ApplicationPackageBodiesSourceCandidate
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Complete routine-completion and package-body trees are bound to the
certified original Output_Profile source, including their actual contracts. -/
namespace Silver.ApplicationPackageBodies.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  completionTree := candidate_checked.completionTree
  unitTree := candidate_checked.unitTree
  completionHeader := by
    refine Eq.trans ?_ candidate_checked.completionHeader
    decide +kernel
  unitHeader := by
    refine Eq.trans ?_ candidate_checked.unitHeader
    decide +kernel
  completionBody := by
    refine Eq.trans ?_ candidate_checked.completionBody
    decide +kernel
  unitBody := by
    refine Eq.trans ?_ candidate_checked.unitBody
    decide +kernel
  objectHeader := by
    refine Eq.trans ?_ candidate_checked.objectHeader
    decide +kernel

structure CheckedSource : Prop where
  implementation : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  bodies : Checked Silver.Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputBodyTokens_correct, actual_checked⟩

end Silver.ApplicationPackageBodies.SourceChecks
