module

public import Silver.SourceDeclarations
public import Silver.ComposeContracts
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Shared declaration and expression checks over the complete reviewed output
shape. This module imports no authoritative source bindings or certificates.
ComposeSourceChecks transports these facts to freshly certified actual tokens;
the reviewed-shape checks alone make no claim about the current Ada source. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

private theorem refinement_fact_09 :
  functionHeader "literal_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = ( if position /= 0 and then position <= text ' last and then text ( position ) = character ' val ( 34 ) and then literal_end ( text , position + 1 ) /= 0 then ( after => literal_end ( text , position + 1 ) , value_first => position + 1 , minimum_length => literal_length ( text , position + 1 ) , static_length => literal_length ( text , position + 1 ) , dynamic_seen => false , nonliteral_seen => false , empty_value => false , reference => 0 ) else invalid_value ) ) )") := by decide +kernel

private theorem refinement_fact_11 :
  functionHeader "expression_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment := scalar_expressions . empty_environment ; integer_hidden : boolean := false ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result = expression_tail ( text , names , ( position => position , minimum_length => 0 , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false , empty_value => false ) , scalar_names , integer_hidden ) ) )") := by decide +kernel

end Silver.Compose.SourceBridge
