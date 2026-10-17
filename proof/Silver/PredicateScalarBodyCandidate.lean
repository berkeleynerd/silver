module

public import Silver.PredicateScalarBodySource
public import Silver.PredicateSourceShape

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.ScalarBodyNative.SourceChecks

/-- Exact scalar helper bodies and headers in the reviewed output source. -/
theorem candidate_checked : Checked SourceShape.bodyTokens := by
  constructor
  · rw [target_rendered]
    decide +kernel
  · rw [assignment_rendered]
    decide +kernel
  all_goals decide +kernel

end Silver.Predicate.ScalarBodyNative.SourceChecks
