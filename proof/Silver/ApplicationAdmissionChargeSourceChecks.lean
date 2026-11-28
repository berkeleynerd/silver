module

public import Silver.ApplicationAdmissionChargeSourceCandidate
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Authoritative extraction, kept separate from the complete focused helper
contract. This must be checked on the frozen full Output_Profile source. -/
namespace Silver.ApplicationAdmission.Charge.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  tree := checked_tree
  header := by
    refine Eq.trans ?_ candidate_checked.header
    decide +kernel
  body := by
    refine Eq.trans ?_ candidate_checked.body
    decide +kernel

end Silver.ApplicationAdmission.Charge.SourceChecks
