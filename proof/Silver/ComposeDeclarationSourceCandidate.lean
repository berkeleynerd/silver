module

public import Silver.SourceDeclarations
public import Silver.ComposeArrayDeclarationSource
public import Silver.ComposeContracts
public import Silver.ComposeBooleanDeclarationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Kernel source-shape checks for one independent part of the complete
Compose candidate. The facade transports every part to authoritative tokens. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

abbrev DeclarationsFor (specTokens bodyTokens : List String) : Prop :=
  Lexical.SourceBridge.recordDeclaration "scalar_constraint_result" bodyTokens =
    some (expectedTokens "record after : literal_position ; bounds : scalars . interval ; end record") ∧
  Source.declaration "max_expression_operands" specTokens = some (expectedTokens "constant positive := 64") ∧
  Source.declaration "max_bindings" specTokens = some (expectedTokens "constant positive := max_source_length / 12") ∧
  maxExpressionOperands = 64 ∧
  maxBindings = maxSourceLength / 12 ∧
  Lexical.SourceBridge.subtypeDeclaration "binding_count" bodyTokens = some (expectedTokens "natural range 0 .. max_bindings") ∧
  Lexical.SourceBridge.subtypeDeclaration "binding_index" bodyTokens = some (expectedTokens "positive range 1 .. max_bindings") ∧
  Lexical.SourceBridge.subtypeDeclaration "operand_count" bodyTokens = some (expectedTokens "natural range 0 .. max_expression_operands") ∧
  Lexical.SourceBridge.subtypeDeclaration "token_index" bodyTokens = some (expectedTokens "positive range 1 .. 101") ∧
  Lexical.SourceBridge.recordDeclaration "binding_info" bodyTokens = some (expectedTokens "record first , after , value_first : literal_position ; static_length : capacity_value ; dynamic , mutable , is_character : boolean ; first_index , last_index : scalars . value ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "binding_environment" bodyTokens = some (expectedTokens "record count : binding_count ; items : binding_array ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "parser_state" bodyTokens = some (expectedTokens "record position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; array_names : array_bindings . environment ; subtype_names : subtype_environment ; boolean_names : boolean_environment ; dynamic_first , dynamic_after : literal_position ; target : binding_count ; capacity : capacity_value ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "value_result" bodyTokens = some (expectedTokens "record after , value_first : literal_position ; minimum_length , static_length : capacity_value ; dynamic_seen , nonliteral_seen , empty_value : boolean ; reference : binding_count ; operands : natural range 0 .. max_expression_operands ; first_index , last_index : scalars . interval ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "expression_result" bodyTokens = some (expectedTokens "record after : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count : operand_count ; named_seen , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") ∧
  typeDeclaration "binding_array" bodyTokens = some (expectedTokens "array (Binding_Index) of Binding_Info") ∧
  Source.declaration "empty_binding" bodyTokens = some (expectedTokens "constant binding_info := ( first => 0 , after => 0 , value_first => 0 , static_length => 0 , dynamic => false , mutable => false , is_character => false , first_index => 1 , last_index => 0 )") ∧
  Source.declaration "empty_environment" bodyTokens = some (expectedTokens "constant binding_environment := ( count => 0 , items => ( others => empty_binding ) )") ∧
  Source.declaration "initial_state" bodyTokens = some (expectedTokens "constant parser_state := ( position => 1 , names => empty_environment , scalar_names => scalar_expressions . empty_environment , array_names => array_bindings . empty_environment , subtype_names => empty_subtypes , boolean_names => empty_booleans , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => max_source_length )") ∧
  Source.declaration "invalid_state" bodyTokens = some (expectedTokens "constant parser_state := ( position => 0 , names => empty_environment , scalar_names => scalar_expressions . empty_environment , array_names => array_bindings . empty_environment , subtype_names => empty_subtypes , boolean_names => empty_booleans , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => 0 )") ∧
  Source.declaration "invalid_value" bodyTokens = some (expectedTokens "constant value_result := ( after => 0 , value_first => 0 , minimum_length => 0 , static_length => 0 , dynamic_seen => false , nonliteral_seen => false , empty_value => false , reference => 0 , operands => 0 , first_index => scalars . singleton ( 1 ) , last_index => scalars . singleton ( 0 ) )") ∧
  Source.declaration "invalid_expression" bodyTokens = some (expectedTokens "constant expression_result := ( after => 0 , minimum_length => 0 , static_length => 0 , dynamic_count => 0 , named_seen => false , empty_value => false , first_index => scalars . singleton ( 1 ) , last_index => scalars . singleton ( 0 ) )") ∧
  Source.expressionBody "valid_names" bodyTokens = some (expectedTokens "for all i in 1 .. names . count => names . items ( i ) . first > 0 and then valid_name_state ( text , names . items ( i ) . first , names . items ( i ) . after ) and then names . items ( i ) . value_first <= text ' last + 1 and then fixed_bounds_valid ( names . items ( i ) . static_length , names . items ( i ) . dynamic , names . items ( i ) . is_character , names . items ( i ) . first_index , names . items ( i ) . last_index , i )") ∧
  Source.expressionBody "valid_state" bodyTokens = some (expectedTokens "state . position <= text ' last + 1 and then valid_names ( text , state . names ) and then scalar_expressions . valid_environment ( text , state . scalar_names ) and then array_bindings . valid_environment ( text , state . array_names ) and then valid_subtypes ( text , state . subtype_names ) and then valid_booleans ( text , state . boolean_names ) and then valid_mutable_bounds ( state . scalar_names ) and then valid_declaration_values ( state . scalar_names , state . scalar_names . count ) and then valid_name_state ( text , state . dynamic_first , state . dynamic_after ) and then state . target <= state . names . count") ∧
  maxConcatenations = 63 ∧
  Lexical.SourceBridge.subtypeDeclaration "concatenation_count" bodyTokens = some (expectedTokens "natural range 0 .. max_concatenations") ∧
  Source.declaration "max_concatenations" specTokens = some (expectedTokens "constant positive := 63") ∧
  Lexical.SourceBridge.recordDeclaration "expression_state" bodyTokens = some (expectedTokens "record position : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count , operands : operand_count ; depth : literal_position ; named_seen , need_operand , complete , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") ∧
  Source.declaration "invalid_expression_state" bodyTokens = some (expectedTokens "constant expression_state := ( position => 0 , minimum_length => 0 , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false , empty_value => false , first_index => scalars . singleton ( 1 ) , last_index => scalars . singleton ( 0 ) )") ∧
  Source.expressionBody "valid_expression_state" bodyTokens = some (expectedTokens "state . position <= text ' last + 1 and then state . dynamic_count <= state . operands and then ( state . position = 0 or else state . depth < state . position )") ∧
  functionHeader "valid_mutable_bounds" "is" bodyTokens = some (expectedTokens "( scalar_names : scalar_expressions . environment ) return boolean") ∧
  Source.expressionBody "valid_mutable_bounds" bodyTokens = some (expectedTokens "for all index in 1 .. scalar_names . count => ( if scalar_names . items ( index ) . mutable then not scalars . is_empty ( scalar_names . items ( index ) . bounds ) and then scalar_names . items ( index ) . bounds . lower >= scalar_names . items ( index ) . declared_bounds . lower and then scalar_names . items ( index ) . bounds . upper <= scalar_names . items ( index ) . declared_bounds . upper )") ∧
  functionHeader "valid_declaration_values" "is" bodyTokens = some (expectedTokens "( scalar_names : scalar_expressions . environment ; count : scalar_expressions . binding_count ) return boolean") ∧
  Source.expressionBody "valid_declaration_values" bodyTokens = some (expectedTokens "count <= scalar_names . count and then ( for all index in 1 .. count => not scalars . is_empty ( scalar_names . items ( index ) . bounds ) )") ∧
  Source.declaration "max_subtype_bindings" bodyTokens =
    some (expectedTokens "constant positive := max_source_length / 32") ∧
  Lexical.SourceBridge.subtypeDeclaration "subtype_count" bodyTokens =
    some (expectedTokens "natural range 0 .. max_subtype_bindings") ∧
  Lexical.SourceBridge.subtypeDeclaration "subtype_index" bodyTokens =
    some (expectedTokens "positive range 1 .. max_subtype_bindings") ∧
  Lexical.SourceBridge.recordDeclaration "subtype_binding" bodyTokens =
    some (expectedTokens "record first , after : literal_position ; bounds : scalars . interval ; end record") ∧
  Source.declaration "empty_subtype_binding" bodyTokens =
    some (expectedTokens "constant subtype_binding := ( 0 , 0 , scalars . empty )") ∧
  typeDeclaration "subtype_binding_array" bodyTokens =
    some (expectedTokens "array ( subtype_index ) of subtype_binding") ∧
  typeDeclaration "subtype_visibility" bodyTokens =
    some (expectedTokens "array ( names . operation_kind ) of boolean") ∧
  Lexical.SourceBridge.recordDeclaration "subtype_environment" bodyTokens =
    some (expectedTokens "record count : subtype_count ; items : subtype_binding_array ; hidden_calls : subtype_visibility ; true_hidden , false_hidden : boolean ; end record") ∧
  Source.declaration "empty_subtypes" bodyTokens =
    some (expectedTokens "constant subtype_environment := ( 0 , ( others => empty_subtype_binding ) , ( others => false ) , false , false )") ∧
  functionHeader "valid_subtypes" ";" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length") ∧
  functionHeader "valid_subtypes" "is" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean") ∧
  Source.expressionBody "valid_subtypes" bodyTokens =
    some (expectedTokens "for all index in 1 .. subtypes . count => subtypes . items ( index ) . first > 0 and then valid_name_state ( text , subtypes . items ( index ) . first , subtypes . items ( index ) . after ) and then not scalars . is_empty ( subtypes . items ( index ) . bounds )") ∧
  IntegerSubtypes.maxBindings = maxSourceLength / 32

private theorem declaration_scalar_constraint :
  Lexical.SourceBridge.recordDeclaration "scalar_constraint_result" Output.SourceShape.outputImplementation =
    some (expectedTokens "record after : literal_position ; bounds : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_01 :
  Source.declaration "max_expression_operands" Output.SourceShape.outputSpecification = some (expectedTokens "constant positive := 64") := by decide +kernel

private theorem declaration_fact_02 :
  Source.declaration "max_bindings" Output.SourceShape.outputSpecification = some (expectedTokens "constant positive := max_source_length / 12") := by decide +kernel

private theorem declaration_fact_03 :
  maxExpressionOperands = 64 := by decide +kernel

private theorem declaration_fact_04 :
  maxBindings = maxSourceLength / 12 := by decide +kernel

private theorem declaration_fact_05 :
  Lexical.SourceBridge.subtypeDeclaration "binding_count" Output.SourceShape.outputImplementation = some (expectedTokens "natural range 0 .. max_bindings") := by decide +kernel

private theorem declaration_fact_06 :
  Lexical.SourceBridge.subtypeDeclaration "binding_index" Output.SourceShape.outputImplementation = some (expectedTokens "positive range 1 .. max_bindings") := by decide +kernel

private theorem declaration_fact_07 :
  Lexical.SourceBridge.subtypeDeclaration "operand_count" Output.SourceShape.outputImplementation = some (expectedTokens "natural range 0 .. max_expression_operands") := by decide +kernel

private theorem declaration_fact_08 :
  Lexical.SourceBridge.subtypeDeclaration "token_index" Output.SourceShape.outputImplementation = some (expectedTokens "positive range 1 .. 101") := by decide +kernel

private theorem declaration_fact_09 :
  Lexical.SourceBridge.recordDeclaration "binding_info" Output.SourceShape.outputImplementation = some (expectedTokens "record first , after , value_first : literal_position ; static_length : capacity_value ; dynamic , mutable , is_character : boolean ; first_index , last_index : scalars . value ; end record") := by decide +kernel

private theorem declaration_fact_10 :
  Lexical.SourceBridge.recordDeclaration "binding_environment" Output.SourceShape.outputImplementation = some (expectedTokens "record count : binding_count ; items : binding_array ; end record") := by decide +kernel

private theorem declaration_fact_11 :
  Lexical.SourceBridge.recordDeclaration "parser_state" Output.SourceShape.outputImplementation = some (expectedTokens "record position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; array_names : array_bindings . environment ; subtype_names : subtype_environment ; boolean_names : boolean_environment ; dynamic_first , dynamic_after : literal_position ; target : binding_count ; capacity : capacity_value ; end record") := by decide +kernel

private theorem declaration_fact_12 :
  Lexical.SourceBridge.recordDeclaration "value_result" Output.SourceShape.outputImplementation = some (expectedTokens "record after , value_first : literal_position ; minimum_length , static_length : capacity_value ; dynamic_seen , nonliteral_seen , empty_value : boolean ; reference : binding_count ; operands : natural range 0 .. max_expression_operands ; first_index , last_index : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_13 :
  Lexical.SourceBridge.recordDeclaration "expression_result" Output.SourceShape.outputImplementation = some (expectedTokens "record after : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count : operand_count ; named_seen , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_14 :
  typeDeclaration "binding_array" Output.SourceShape.outputImplementation = some (expectedTokens "array (Binding_Index) of Binding_Info") := by decide +kernel

private theorem declaration_fact_15 :
  Source.declaration "empty_binding" Output.SourceShape.outputImplementation = some (expectedTokens "constant binding_info := ( first => 0 , after => 0 , value_first => 0 , static_length => 0 , dynamic => false , mutable => false , is_character => false , first_index => 1 , last_index => 0 )") := by decide +kernel

private theorem declaration_fact_16 :
  Source.declaration "empty_environment" Output.SourceShape.outputImplementation = some (expectedTokens "constant binding_environment := ( count => 0 , items => ( others => empty_binding ) )") := by decide +kernel

private theorem declaration_fact_17 :
  Source.declaration "initial_state" Output.SourceShape.outputImplementation = some (expectedTokens "constant parser_state := ( position => 1 , names => empty_environment , scalar_names => scalar_expressions . empty_environment , array_names => array_bindings . empty_environment , subtype_names => empty_subtypes , boolean_names => empty_booleans , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => max_source_length )") := by decide +kernel

private theorem declaration_fact_18 :
  Source.declaration "invalid_state" Output.SourceShape.outputImplementation = some (expectedTokens "constant parser_state := ( position => 0 , names => empty_environment , scalar_names => scalar_expressions . empty_environment , array_names => array_bindings . empty_environment , subtype_names => empty_subtypes , boolean_names => empty_booleans , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => 0 )") := by decide +kernel

private theorem declaration_fact_19 :
  Source.declaration "invalid_value" Output.SourceShape.outputImplementation = some (expectedTokens "constant value_result := ( after => 0 , value_first => 0 , minimum_length => 0 , static_length => 0 , dynamic_seen => false , nonliteral_seen => false , empty_value => false , reference => 0 , operands => 0 , first_index => scalars . singleton ( 1 ) , last_index => scalars . singleton ( 0 ) )") := by decide +kernel

private theorem declaration_fact_20 :
  Source.declaration "invalid_expression" Output.SourceShape.outputImplementation = some (expectedTokens "constant expression_result := ( after => 0 , minimum_length => 0 , static_length => 0 , dynamic_count => 0 , named_seen => false , empty_value => false , first_index => scalars . singleton ( 1 ) , last_index => scalars . singleton ( 0 ) )") := by decide +kernel

private theorem declaration_fact_21 :
  Source.expressionBody "valid_names" Output.SourceShape.outputImplementation = some (expectedTokens "for all i in 1 .. names . count => names . items ( i ) . first > 0 and then valid_name_state ( text , names . items ( i ) . first , names . items ( i ) . after ) and then names . items ( i ) . value_first <= text ' last + 1 and then fixed_bounds_valid ( names . items ( i ) . static_length , names . items ( i ) . dynamic , names . items ( i ) . is_character , names . items ( i ) . first_index , names . items ( i ) . last_index , i )") := by decide +kernel

private theorem declaration_fact_22 :
  Source.expressionBody "valid_state" Output.SourceShape.outputImplementation = some (expectedTokens "state . position <= text ' last + 1 and then valid_names ( text , state . names ) and then scalar_expressions . valid_environment ( text , state . scalar_names ) and then array_bindings . valid_environment ( text , state . array_names ) and then valid_subtypes ( text , state . subtype_names ) and then valid_booleans ( text , state . boolean_names ) and then valid_mutable_bounds ( state . scalar_names ) and then valid_declaration_values ( state . scalar_names , state . scalar_names . count ) and then valid_name_state ( text , state . dynamic_first , state . dynamic_after ) and then state . target <= state . names . count") := by decide +kernel

private theorem declaration_fact_23 :
  maxConcatenations = 63 := by decide +kernel

private theorem declaration_fact_24 :
  Lexical.SourceBridge.subtypeDeclaration "concatenation_count" Output.SourceShape.outputImplementation = some (expectedTokens "natural range 0 .. max_concatenations") := by decide +kernel

private theorem declaration_fact_25 :
  Source.declaration "max_concatenations" Output.SourceShape.outputSpecification = some (expectedTokens "constant positive := 63") := by decide +kernel

private theorem declaration_fact_26 :
  Lexical.SourceBridge.recordDeclaration "expression_state" Output.SourceShape.outputImplementation = some (expectedTokens "record position : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count , operands : operand_count ; depth : literal_position ; named_seen , need_operand , complete , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_27 :
  Source.declaration "invalid_expression_state" Output.SourceShape.outputImplementation = some (expectedTokens "constant expression_state := ( position => 0 , minimum_length => 0 , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false , empty_value => false , first_index => scalars . singleton ( 1 ) , last_index => scalars . singleton ( 0 ) )") := by decide +kernel

private theorem declaration_fact_28 :
  Source.expressionBody "valid_expression_state" Output.SourceShape.outputImplementation = some (expectedTokens "state . position <= text ' last + 1 and then state . dynamic_count <= state . operands and then ( state . position = 0 or else state . depth < state . position )") := by decide +kernel

private theorem declaration_mutable_bounds_header :
  functionHeader "valid_mutable_bounds" "is" Output.SourceShape.outputImplementation = some (expectedTokens "( scalar_names : scalar_expressions . environment ) return boolean") := by decide +kernel

private theorem declaration_mutable_bounds_body :
  Source.expressionBody "valid_mutable_bounds" Output.SourceShape.outputImplementation = some (expectedTokens "for all index in 1 .. scalar_names . count => ( if scalar_names . items ( index ) . mutable then not scalars . is_empty ( scalar_names . items ( index ) . bounds ) and then scalar_names . items ( index ) . bounds . lower >= scalar_names . items ( index ) . declared_bounds . lower and then scalar_names . items ( index ) . bounds . upper <= scalar_names . items ( index ) . declared_bounds . upper )") := by decide +kernel

private theorem declaration_declaration_values_header :
  functionHeader "valid_declaration_values" "is" Output.SourceShape.outputImplementation = some (expectedTokens "( scalar_names : scalar_expressions . environment ; count : scalar_expressions . binding_count ) return boolean") := by decide +kernel

private theorem declaration_declaration_values_body :
  Source.expressionBody "valid_declaration_values" Output.SourceShape.outputImplementation = some (expectedTokens "count <= scalar_names . count and then ( for all index in 1 .. count => not scalars . is_empty ( scalar_names . items ( index ) . bounds ) )") := by decide +kernel

private theorem declaration_subtype_fact_01 :
  Source.declaration "max_subtype_bindings" Output.SourceShape.outputImplementation =
    some (expectedTokens "constant positive := max_source_length / 32") := by decide +kernel

private theorem declaration_subtype_fact_02 :
  Lexical.SourceBridge.subtypeDeclaration "subtype_count" Output.SourceShape.outputImplementation =
    some (expectedTokens "natural range 0 .. max_subtype_bindings") := by decide +kernel

private theorem declaration_subtype_fact_03 :
  Lexical.SourceBridge.subtypeDeclaration "subtype_index" Output.SourceShape.outputImplementation =
    some (expectedTokens "positive range 1 .. max_subtype_bindings") := by decide +kernel

private theorem declaration_subtype_fact_04 :
  Lexical.SourceBridge.recordDeclaration "subtype_binding" Output.SourceShape.outputImplementation =
    some (expectedTokens "record first , after : literal_position ; bounds : scalars . interval ; end record") := by decide +kernel

private theorem declaration_subtype_fact_05 :
  Source.declaration "empty_subtype_binding" Output.SourceShape.outputImplementation =
    some (expectedTokens "constant subtype_binding := ( 0 , 0 , scalars . empty )") := by decide +kernel

private theorem declaration_subtype_fact_06 :
  typeDeclaration "subtype_binding_array" Output.SourceShape.outputImplementation =
    some (expectedTokens "array ( subtype_index ) of subtype_binding") := by decide +kernel

private theorem declaration_subtype_fact_07 :
  typeDeclaration "subtype_visibility" Output.SourceShape.outputImplementation =
    some (expectedTokens "array ( names . operation_kind ) of boolean") := by decide +kernel

private theorem declaration_subtype_fact_08 :
  Lexical.SourceBridge.recordDeclaration "subtype_environment" Output.SourceShape.outputImplementation =
    some (expectedTokens "record count : subtype_count ; items : subtype_binding_array ; hidden_calls : subtype_visibility ; true_hidden , false_hidden : boolean ; end record") := by decide +kernel

private theorem declaration_subtype_fact_09 :
  Source.declaration "empty_subtypes" Output.SourceShape.outputImplementation =
    some (expectedTokens "constant subtype_environment := ( 0 , ( others => empty_subtype_binding ) , ( others => false ) , false , false )") := by decide +kernel

private theorem declaration_subtype_fact_10 :
  functionHeader "valid_subtypes" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length") := by decide +kernel

private theorem declaration_subtype_fact_11 :
  functionHeader "valid_subtypes" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean") := by decide +kernel

private theorem declaration_subtype_fact_12 :
  Source.expressionBody "valid_subtypes" Output.SourceShape.outputImplementation =
    some (expectedTokens "for all index in 1 .. subtypes . count => subtypes . items ( index ) . first > 0 and then valid_name_state ( text , subtypes . items ( index ) . first , subtypes . items ( index ) . after ) and then not scalars . is_empty ( subtypes . items ( index ) . bounds )") := by decide +kernel

private theorem declaration_subtype_capacity :
  IntegerSubtypes.maxBindings = maxSourceLength / 32 := by decide +kernel

theorem candidate_declarations : DeclarationsFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation := by
  exact ⟨declaration_scalar_constraint, declaration_fact_01,
    declaration_fact_02,
    declaration_fact_03,
    declaration_fact_04,
    declaration_fact_05,
    declaration_fact_06,
    declaration_fact_07,
    declaration_fact_08,
    declaration_fact_09,
    declaration_fact_10,
    declaration_fact_11,
    declaration_fact_12,
    declaration_fact_13,
    declaration_fact_14,
    declaration_fact_15,
    declaration_fact_16,
    declaration_fact_17,
    declaration_fact_18,
    declaration_fact_19,
    declaration_fact_20,
    declaration_fact_21,
    declaration_fact_22,
    declaration_fact_23,
    declaration_fact_24,
    declaration_fact_25,
    declaration_fact_26,
    declaration_fact_27,
    declaration_fact_28,
    declaration_mutable_bounds_header,
    declaration_mutable_bounds_body,
    declaration_declaration_values_header,
    declaration_declaration_values_body,
    declaration_subtype_fact_01,
    declaration_subtype_fact_02,
    declaration_subtype_fact_03,
    declaration_subtype_fact_04,
    declaration_subtype_fact_05,
    declaration_subtype_fact_06,
    declaration_subtype_fact_07,
    declaration_subtype_fact_08,
    declaration_subtype_fact_09,
    declaration_subtype_fact_10,
    declaration_subtype_fact_11,
    declaration_subtype_fact_12,
    declaration_subtype_capacity⟩
end Silver.Compose.SourceBridge
