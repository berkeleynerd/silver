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

private theorem boolean_bindings_checked : BooleanBindings.SourceChecks.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem xor_scanner_checked : XorSourceBridge.Checked SourceShape.bodyTokens := by
  constructor
  · exact CharacterSourceCandidate.xor_body
  all_goals decide +kernel

private theorem counted_bound_checked : CountedBoundNative.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem native_flow_checked : FlowSourceBridge.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem native_readers_checked : FlowReaders.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

/-- Assemble the independently checked private source proofs. -/
theorem checked : Checked where
  booleanBindings := boolean_bindings_checked
  xorScanner := xor_scanner_checked
  counted_bound := counted_bound_checked
  flow := native_flow_checked
  readers := native_readers_checked

end Silver.Predicate.SourceChecks.FlowSourceCandidate
