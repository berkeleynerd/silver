module

public import Silver.ApplicationPackageCallsDenotation
public import Silver.ApplicationPackageCalleeCandidate
public import Silver.ApplicationPackageCallsCandidate
public import Silver.ApplicationPackageCallsValidityCandidate
public import Silver.StaticBooleanSourceCandidate
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! The source batch must discharge each extraction on the token stream
certified from the full Output Profile source. The focused candidates establish
the corresponding typed declarations and bodies. -/

namespace Silver.ApplicationPackageCalls.Native.CalleeSource

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  completeHeader := by
    refine Eq.trans ?_ candidate_checked.completeHeader
    decide +kernel
  completeBody := by
    refine Eq.trans ?_ candidate_checked.completeBody
    decide +kernel

end Silver.ApplicationPackageCalls.Native.CalleeSource

namespace Silver.ApplicationPackageCalls.Native.Call.SourceChecks

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  actualRecord := by
    refine Eq.trans ?_ candidate_checked.actualRecord
    decide +kernel
  actualArray := by
    refine Eq.trans ?_ candidate_checked.actualArray
    decide +kernel
  seenArray := by
    refine Eq.trans ?_ candidate_checked.seenArray
    decide +kernel
  callRecord := by
    refine Eq.trans ?_ candidate_checked.callRecord
    decide +kernel
  completeHeader := by
    refine Eq.trans ?_ candidate_checked.completeHeader
    decide +kernel
  completeBody := by
    refine Eq.trans ?_ candidate_checked.completeBody
    decide +kernel

end Silver.ApplicationPackageCalls.Native.Call.SourceChecks

namespace Silver.ApplicationPackageCalls.ValidityNative

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  includedHeader := by
    refine Eq.trans ?_ candidate_checked.includedHeader
    decide +kernel
  includedBody := by
    refine Eq.trans ?_ candidate_checked.includedBody
    decide +kernel
  flowHeader := by
    refine Eq.trans ?_ candidate_checked.flowHeader
    decide +kernel
  flowBody := by
    refine Eq.trans ?_ candidate_checked.flowBody
    decide +kernel
  bodySpecification := by
    refine Eq.trans ?_ candidate_checked.bodySpecification
    decide +kernel
  bodyHeader := by
    refine Eq.trans ?_ candidate_checked.bodyHeader
    decide +kernel
  bodyBody := by
    refine Eq.trans ?_ candidate_checked.bodyBody
    decide +kernel

end Silver.ApplicationPackageCalls.ValidityNative

namespace Silver.BooleanElaboration.Native.SourceChecks

set_option maxRecDepth 100000 in
set_option maxHeartbeats 10000000 in
theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  resultRecord := by
    refine Eq.trans ?_ candidate_checked.resultRecord
    decide +kernel
  invalid := by
    refine Eq.trans ?_ candidate_checked.invalid
    decide +kernel
  primaryHeader := by
    refine Eq.trans ?_ candidate_checked.primaryHeader
    decide +kernel
  factorHeader := by
    refine Eq.trans ?_ candidate_checked.factorHeader
    decide +kernel
  relationHeader := by
    refine Eq.trans ?_ candidate_checked.relationHeader
    decide +kernel
  conditionSpec := by
    refine Eq.trans ?_ candidate_checked.conditionSpec
    decide +kernel
  conditionImpl := by
    refine Eq.trans ?_ candidate_checked.conditionImpl
    decide +kernel
  primaryBody := by
    refine Eq.trans ?_ candidate_checked.primaryBody
    decide +kernel
  factorBody := by
    refine Eq.trans ?_ candidate_checked.factorBody
    decide +kernel
  relationBody := by
    refine Eq.trans ?_ candidate_checked.relationBody
    decide +kernel
  conditionBody := by
    refine Eq.trans ?_ candidate_checked.conditionBody
    decide +kernel

end Silver.BooleanElaboration.Native.SourceChecks
