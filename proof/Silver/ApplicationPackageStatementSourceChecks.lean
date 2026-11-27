module

public import Silver.ApplicationPackageBodiesBasicCandidate
public import Silver.ApplicationPackageBodiesStatementCandidate
public import Silver.ApplicationPackageBodiesTailCandidate
public import Silver.ApplicationPackageRoutineFrameCandidate
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Authoritative source binding for the three mutually used application body
readers and their routine-frame constructor. Candidate proofs already check the
complete trees, scope, association and named-call structure. -/
namespace Silver

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace ApplicationPackageBodies.Basic.SourceChecks

theorem actual_checked : Checked Source.outputBodyTokens where
  tree := candidate_checked.tree
  header := by
    refine Eq.trans ?_ candidate_checked.header
    decide +kernel
  body := by
    refine Eq.trans ?_ candidate_checked.body
    decide +kernel

end ApplicationPackageBodies.Basic.SourceChecks

namespace ApplicationPackageBodies.Statement.SourceChecks

theorem actual_checked : Checked Source.outputBodyTokens where
  tree := candidate_checked.tree
  specification := by
    refine Eq.trans ?_ candidate_checked.specification
    decide +kernel
  implementation := by
    refine Eq.trans ?_ candidate_checked.implementation
    decide +kernel
  body := by
    refine Eq.trans ?_ candidate_checked.body
    decide +kernel

end ApplicationPackageBodies.Statement.SourceChecks

namespace ApplicationPackageBodies.Tail.SourceChecks

theorem actual_checked : Checked Source.outputBodyTokens where
  tree := candidate_checked.tree
  header := by
    refine Eq.trans ?_ candidate_checked.header
    decide +kernel
  body := by
    refine Eq.trans ?_ candidate_checked.body
    decide +kernel

end ApplicationPackageBodies.Tail.SourceChecks

namespace ApplicationPackageRoutineFrame.SourceChecks

theorem actual_checked : Checked Source.outputBodyTokens where
  tree := candidate_checked.tree
  header := by
    refine Eq.trans ?_ candidate_checked.header
    decide +kernel
  body := by
    refine Eq.trans ?_ candidate_checked.body
    decide +kernel

end ApplicationPackageRoutineFrame.SourceChecks

namespace ApplicationPackageBodies.OriginalStatements

structure CheckedSource : Prop where
  implementation : Source.lex Source.outputProfileBody = some Source.outputBodyTokens
  basic : Basic.SourceChecks.Checked Source.outputBodyTokens
  statement : Statement.SourceChecks.Checked Source.outputBodyTokens
  tail : Tail.SourceChecks.Checked Source.outputBodyTokens
  frame : ApplicationPackageRoutineFrame.SourceChecks.Checked Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Source.outputBodyTokens_correct, Basic.SourceChecks.actual_checked,
    Statement.SourceChecks.actual_checked, Tail.SourceChecks.actual_checked,
    ApplicationPackageRoutineFrame.SourceChecks.actual_checked⟩

end ApplicationPackageBodies.OriginalStatements
end Silver
