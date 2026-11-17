module

public import Silver.BooleanBindingsSourceChecks
public import Silver.PredicateXorSourceBridge
public import Silver.PredicateCountedBoundSource
public import Silver.PredicateFlowReaders
public import Silver.PredicateCharacterSourceCandidate
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/-! Temporary diagnosis: every original field is retained independently over
the same complete reviewed source. Failed fields remain failed checks. -/

namespace Silver.Predicate.CountedBoundNative.MemoryFieldProbe

theorem body_probe : ordinaryFunction "read_counted_bound" Silver.Predicate.SourceShape.bodyTokens = some render := by
  decide +kernel

theorem header_probe : Silver.SourceBridge.functionHeader "read_counted_bound" "is" Silver.Predicate.SourceShape.bodyTokens = some header := by
  decide +kernel

theorem spec_probe : Silver.SourceBridge.functionHeader "read_counted_bound" ";" Silver.Predicate.SourceShape.bodyTokens = some spec := by
  decide +kernel

theorem noInline_probe : noInline Silver.Predicate.SourceShape.bodyTokens = true := by
  decide +kernel

end Silver.Predicate.CountedBoundNative.MemoryFieldProbe

namespace Silver.Predicate.FlowSourceBridge.MemoryFieldProbe

theorem initial_probe : functionHeader "initial_flow" ";" Silver.Predicate.SourceShape.bodyTokens = some initialHeader := by
  decide +kernel

theorem joined_probe : functionHeader "joined" ";" Silver.Predicate.SourceShape.bodyTokens = some joinedHeader := by
  decide +kernel

theorem joinInto_probe : procedureHeader "join_into" ";" Silver.Predicate.SourceShape.bodyTokens = some joinIntoHeader := by
  decide +kernel

theorem lemmaJoinIdentity_probe : procedureHeader "lemma_join_identity" "is" Silver.Predicate.SourceShape.bodyTokens = some lemmaJoinIdentityHeader := by
  decide +kernel

theorem widened_probe : procedureHeader "widen_into" ";" Silver.Predicate.SourceShape.bodyTokens = some widenedHeader := by
  decide +kernel

theorem reading_probe : functionHeader "reading_names" ";" Silver.Predicate.SourceShape.bodyTokens = some readingHeader := by
  decide +kernel

theorem vector_probe : typeDeclaration "interval_vector" Silver.Predicate.SourceShape.bodyTokens =
    some (expectedTokens "array (Positive range <>) of Scalars.Interval") := by
  decide +kernel

theorem flow_probe : Lexical.SourceBridge.discriminatedRecordDeclaration "scalar_flow" Silver.Predicate.SourceShape.bodyTokens =
    some (expectedTokens "(Count : Scalar_Expressions.Binding_Count) is record Path : Paths.Context; Values : Interval_Vector (1 .. Count); end record") := by
  decide +kernel

end Silver.Predicate.FlowSourceBridge.MemoryFieldProbe

namespace Silver.Predicate.FlowReaders.MemoryFieldProbe

theorem integerTypeWord_probe : Source.declaration "integer_type_word" Silver.Predicate.SourceShape.bodyTokens =
    some (expectedTokens "constant String := \"integer\"") := by
  decide +kernel

theorem scalarSpec_probe : Silver.SourceBridge.functionHeader "read_scalar_in_flow" ";" Silver.Predicate.SourceShape.bodyTokens = some scalarSpec := by
  decide +kernel

theorem scalarBody_probe : Silver.SourceBridge.functionHeader "read_scalar_in_flow" "is" Silver.Predicate.SourceShape.bodyTokens = some scalarHeader := by
  decide +kernel

theorem stringSpec_probe : Silver.SourceBridge.functionHeader "read_string_in_flow" ";" Silver.Predicate.SourceShape.bodyTokens = some stringSpec := by
  decide +kernel

theorem stringBody_probe : Silver.SourceBridge.functionHeader "read_string_in_flow" "is" Silver.Predicate.SourceShape.bodyTokens = some stringHeader := by
  decide +kernel

end Silver.Predicate.FlowReaders.MemoryFieldProbe
