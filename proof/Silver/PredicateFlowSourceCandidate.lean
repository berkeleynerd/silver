module

public import Silver.BooleanBindingsSourceChecks
public import Silver.PredicateXorSourceBridge
public import Silver.PredicateCountedBoundSource
public import Silver.PredicateFlowReaders
public import Silver.PredicateCharacterSourceCandidate
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.SourceChecks.FlowSourceCandidate
open Silver.SourceBridge Native

/-! Exact Boolean binding, xor, counted-bound and flow source checks.
The final source bridge transports the reviewed shape to authoritative tokens. -/

/-- The source requirements assigned to this independent proof leaf. -/
structure Checked : Prop where
  booleanBindings : BooleanBindings.SourceChecks.Checked SourceShape.bodyTokens
  xorScanner : XorSourceBridge.Checked SourceShape.bodyTokens
  counted_bound : CountedBoundNative.Checked SourceShape.bodyTokens
  flow : FlowSourceBridge.Checked SourceShape.bodyTokens
  readers : FlowReaders.Checked SourceShape.bodyTokens

/-- Each original source decision is checked here once. -/
theorem checked : Checked where
  booleanBindings := by
    constructor <;> decide +kernel
  xorScanner := by
    constructor
    · exact CharacterSourceCandidate.xor_body
    all_goals decide +kernel
  counted_bound := by
    constructor <;> decide +kernel
  flow := by
    constructor <;> decide +kernel
  readers := by
    constructor <;> decide +kernel

end Silver.Predicate.SourceChecks.FlowSourceCandidate
