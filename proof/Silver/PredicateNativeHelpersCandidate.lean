module

public import Silver.PredicateNativeScalarHelpers
public import Silver.PredicateNativeWorkers
public import Silver.PredicateSourceShape
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.SourceChecks.NativeHelpersCandidate
open Silver.SourceBridge Native

/-! Exact scalar-helper and native-worker source checks.
The final source bridge transports the reviewed shape to authoritative tokens. -/

/-- The source requirements assigned to this independent proof leaf. -/
structure Checked : Prop where
  scalarHelpers : Native.ScalarHelpers.Checked SourceShape.bodyTokens
  workers : Native.Workers.Checked SourceShape.bodyTokens

/-- Each original source decision is checked here once. -/
theorem checked : Checked where
  scalarHelpers := by
    constructor <;> decide +kernel
  workers := by
    constructor <;> decide +kernel

end Silver.Predicate.SourceChecks.NativeHelpersCandidate
