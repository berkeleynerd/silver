module

public import Silver.ApplicationPackageMainSourceCandidate
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Bind the complete typed Main reader to the certified original Output_Profile
body. The candidate checks and universal execution equation are independent of
this actual-source extraction; callee interpretations are supplied separately. -/
namespace Silver.ApplicationPackageMain.Native.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  tree := checked_tree
  header := by
    rw [mainHeader_exact]
    decide +kernel
  body := by
    rw [mainBody_exact]
    decide +kernel

structure CheckedSource : Prop where
  implementation : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  main : Checked Silver.Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputBodyTokens_correct, actual_checked⟩

theorem actual_meaning (calls : ApplicationPackageMain.Calls) :
    Meaning Silver.Source.outputBodyTokens calls :=
  checked_meaning actual_checked calls

end Silver.ApplicationPackageMain.Native.SourceChecks
