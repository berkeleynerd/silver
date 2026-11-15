module

public import Silver.BooleanBindingsSourceChecks
public import Silver.PredicateXorSourceBridge
public import Silver.PredicateCountedBoundSource
public import Silver.PredicateFlowReaders
public import Silver.PredicateCharacterSourceCandidate
public import Silver.PredicateFlowExpectedTokens
meta import Silver.CertificateWitness
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
  constructor
  · decide +kernel
  · decide +kernel
  · change functionHeader "read_counted_bound" ";" SourceShape.bodyTokens =
      some (CountedBoundNative.header ++ Silver.SourceBridge.expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After), Post => (Runtime => Read_Counted_Bound'Result.After = 0 or else (Read_Counted_Bound'Result.After in Position + 1 .. Text'Last + 1 and then Read_Counted_Bound'Result.Operands > 0), Static => (if Read_Counted_Bound'Result.After /= 0 then Read_Counted_Bound'Result = Read_Scalar_In_Flow (Text, Context, Position, Facts, Mask_First, Mask_After)))")
    rw [FlowExpectedTokens.countedSpecSuffix]
    kernel_exact (Eq.refl (some (CountedBoundNative.header ++ ["with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", ",", "post", "=>", "(", "runtime", "=>", "read_counted_bound", "'", "result", ".", "after", "=", "0", "or", "else", "(", "read_counted_bound", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "read_counted_bound", "'", "result", ".", "operands", ">", "0", ")", ",", "static", "=>", "(", "if", "read_counted_bound", "'", "result", ".", "after", "/=", "0", "then", "read_counted_bound", "'", "result", "=", "read_scalar_in_flow", "(", "text", ",", "context", ",", "position", ",", "facts", ",", "mask_first", ",", "mask_after", ")", ")", ")"])))
  · decide +kernel

private theorem native_flow_checked : FlowSourceBridge.Checked SourceShape.bodyTokens := by
  constructor
  · decide +kernel
  · unfold FlowSourceBridge.joinedHeader
    rw [FlowExpectedTokens.joinedSuffix]
    kernel_exact (Eq.refl (some (Silver.SourceBridge.expectedTokens "(Left, Right : Scalar_Flow) return Scalar_Flow with Ghost => Static, Global => null, Pre => Left.Count = Right.Count, Post => Joined'Result.Count =" ++   FlowSourceBridge.joinedCount.render ++ Silver.SourceBridge.expectedTokens "and then Joined'Result.Path =" ++ FlowSourceBridge.joinedPath.render ++   Silver.SourceBridge.expectedTokens "and then (for all Index in Joined'Result.Values'Range => Joined'Result.Values (Index) =" ++   FlowSourceBridge.joinedValue.render ++   ["and", "then", "(", "if", "scalars", ".", "is_empty", "(", "left", ".", "values", "(", "index", ")", ")", "then", "(", "if", "scalars", ".", "is_empty", "(", "right", ".", "values", "(", "index", ")", ")", "then", "scalars", ".", "is_empty", "(", "joined", "'", "result", ".", "values", "(", "index", ")", ")", "else", "joined", "'", "result", ".", "values", "(", "index", ")", "=", "right", ".", "values", "(", "index", ")", ")", "elsif", "scalars", ".", "is_empty", "(", "right", ".", "values", "(", "index", ")", ")", "then", "joined", "'", "result", ".", "values", "(", "index", ")", "=", "left", ".", "values", "(", "index", ")", "else", "not", "scalars", ".", "is_empty", "(", "joined", "'", "result", ".", "values", "(", "index", ")", ")", "and", "then", "joined", "'", "result", ".", "values", "(", "index", ")", ".", "lower", "=", "scalars", ".", "value", "'", "min", "(", "left", ".", "values", "(", "index", ")", ".", "lower", ",", "right", ".", "values", "(", "index", ")", ".", "lower", ")", "and", "then", "joined", "'", "result", ".", "values", "(", "index", ")", ".", "upper", "=", "scalars", ".", "value", "'", "max", "(", "left", ".", "values", "(", "index", ")", ".", "upper", ",", "right", ".", "values", "(", "index", ")", ".", "upper", ")", ")", "and", "then", "(", "if", "not", "scalars", ".", "is_empty", "(", "left", ".", "values", "(", "index", ")", ")", "and", "then", "left", ".", "values", "(", "index", ")", "=", "right", ".", "values", "(", "index", ")", "then", "joined", "'", "result", ".", "values", "(", "index", ")", "=", "left", ".", "values", "(", "index", ")", ")"] ++ [")"])))
  · decide +kernel
  · decide +kernel
  · decide +kernel
  · decide +kernel
  · decide +kernel
  · decide +kernel

private theorem reader_integer_type_word :
    Source.declaration "integer_type_word" SourceShape.bodyTokens =
      some (FlowReaders.expectedTokens "constant String := \"integer\"") := by
  decide +kernel

private theorem reader_scalar_spec :
    functionHeader "read_scalar_in_flow" ";" SourceShape.bodyTokens = some FlowReaders.scalarSpec := by
  decide +kernel

private theorem reader_scalar_body :
    functionHeader "read_scalar_in_flow" "is" SourceShape.bodyTokens = some FlowReaders.scalarHeader := by
  decide +kernel

private theorem reader_string_spec :
    functionHeader "read_string_in_flow" ";" SourceShape.bodyTokens = some FlowReaders.stringSpec := by
  decide +kernel

private theorem reader_string_body :
    functionHeader "read_string_in_flow" "is" SourceShape.bodyTokens = some FlowReaders.stringHeader := by
  decide +kernel

private theorem native_readers_checked : FlowReaders.Checked SourceShape.bodyTokens := by
  exact ⟨reader_integer_type_word, reader_scalar_spec, reader_scalar_body,
    reader_string_spec, reader_string_body⟩

/-- Assemble the independently checked private source proofs. -/
theorem checked : Checked where
  booleanBindings := boolean_bindings_checked
  xorScanner := xor_scanner_checked
  counted_bound := counted_bound_checked
  flow := native_flow_checked
  readers := native_readers_checked

end Silver.Predicate.SourceChecks.FlowSourceCandidate
