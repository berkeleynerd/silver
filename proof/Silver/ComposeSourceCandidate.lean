module

public import Silver.SourceDeclarations
public import Silver.ComposeArrayDeclarationSource
public import Silver.ComposeContracts
public import Silver.ComposeBooleanDeclarationSource
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

abbrev ExpressionTranslationFor (bodyTokens : List String) : Prop :=
  Expressions.WellFormedTrees ∧
  Expressions.WellScopedTrees ∧
  Source.expressionBody "call_after" bodyTokens =
    some Expressions.callAfterBody.render ∧
  Source.expressionBody "fixed_after" bodyTokens =
    some Expressions.fixedBody.render ∧
  Source.expressionBody "lookup_from" bodyTokens =
    some Expressions.lookupFromBody.render ∧
  Source.expressionBody "image_at" bodyTokens =
    some Expressions.imageBody.render ∧
  Source.expressionBody "value_at" bodyTokens =
    some Expressions.valueBody.render ∧
  Source.expressionBody "new_name_allowed" bodyTokens =
    some Expressions.newNameBody.render ∧
  Source.expressionBody "add_binding" bodyTokens =
    some (Expressions.addBindingBody.render.drop 1 |>.dropLast) ∧
  Source.expressionBody "string_declaration_at" bodyTokens =
    some Expressions.stringDeclarationBody.render ∧
  Source.expressionBody "scalar_constraint_at" bodyTokens =
    some Expressions.scalarConstraintBody.render ∧
  Source.expressionBody "scalar_declaration_at" bodyTokens =
    some Expressions.scalarDeclarationBody.render ∧
  Source.expressionBody "declaration_at" bodyTokens =
    some Expressions.declarationBody.render ∧
  Source.expressionBody "argument_at" bodyTokens =
    some Expressions.argumentBody.render ∧
  Source.expressionBody "declarations_at" bodyTokens =
    some Expressions.declarationsBody.render ∧
  Source.expressionBody "expression_step" bodyTokens =
    some Expressions.expressionStepBody.render ∧
  Source.expressionBody "expression_tail" bodyTokens =
    some Expressions.tailBody.render ∧
  Source.expressionBody "target_at" bodyTokens =
    some Expressions.targetBody.render ∧
  Source.expressionBody "dynamic_at" bodyTokens =
    some Expressions.dynamicBody.render ∧
  Source.expressionBody "assignment_at" bodyTokens =
    some Expressions.assignmentBody.render ∧
  Source.expressionBody "output_at" bodyTokens =
    some Expressions.outputBody.render ∧
  Source.expressionBody "step" bodyTokens =
    some Expressions.stepBody.render ∧
  Source.expressionBody "work_tail" bodyTokens = some Expressions.workTailBody.render ∧
  Source.expressionBody "fits" bodyTokens = some Expressions.fitsBody.render ∧
  Source.expressionBody "comparison_at" bodyTokens = some Expressions.comparisonBody.render ∧
  Source.expressionBody "lookup_subtype_model" bodyTokens =
    some Expressions.subtypeLookupModelBody.render ∧
  Source.expressionBody "scalar_type_at" bodyTokens =
    some Expressions.scalarTypeBody.render ∧
  Source.expressionBody "subtype_declaration_at" bodyTokens =
    some Expressions.subtypeDeclarationBody.render

private theorem expression_call_after :
  Source.expressionBody "call_after" Output.SourceShape.outputImplementation =
    some Expressions.callAfterBody.render := by decide +kernel

private theorem expression_fact_03 :
  Source.expressionBody "fixed_after" Output.SourceShape.outputImplementation =
    some Expressions.fixedBody.render := by decide +kernel

private theorem expression_fact_04 :
  Source.expressionBody "lookup_from" Output.SourceShape.outputImplementation =
    some Expressions.lookupFromBody.render := by decide +kernel

private theorem expression_image :
  Source.expressionBody "image_at" Output.SourceShape.outputImplementation =
    some Expressions.imageBody.render := by decide +kernel

private theorem expression_fact_05 :
  Source.expressionBody "value_at" Output.SourceShape.outputImplementation =
    some Expressions.valueBody.render := by decide +kernel

private theorem expression_fact_06 :
  Source.expressionBody "new_name_allowed" Output.SourceShape.outputImplementation =
    some Expressions.newNameBody.render := by decide +kernel

private theorem expression_fact_07 :
  Source.expressionBody "add_binding" Output.SourceShape.outputImplementation =
    some (Expressions.addBindingBody.render.drop 1 |>.dropLast) := by decide +kernel

private theorem expression_string_declaration :
  Source.expressionBody "string_declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.stringDeclarationBody.render := by decide +kernel

private theorem expression_scalar_constraint :
  Source.expressionBody "scalar_constraint_at" Output.SourceShape.outputImplementation =
    some Expressions.scalarConstraintBody.render := by decide +kernel

private theorem expression_scalar_declaration :
  Source.expressionBody "scalar_declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.scalarDeclarationBody.render := by decide +kernel

private theorem expression_fact_08 :
  Source.expressionBody "declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.declarationBody.render := by decide +kernel

private theorem expression_fact_09 :
  Source.expressionBody "argument_at" Output.SourceShape.outputImplementation =
    some Expressions.argumentBody.render := by decide +kernel

private theorem expression_fact_10 :
  Source.expressionBody "declarations_at" Output.SourceShape.outputImplementation =
    some Expressions.declarationsBody.render := by decide +kernel

private theorem expression_fact_11 :
  Source.expressionBody "expression_step" Output.SourceShape.outputImplementation =
    some Expressions.expressionStepBody.render := by decide +kernel

private theorem expression_fact_12 :
  Source.expressionBody "expression_tail" Output.SourceShape.outputImplementation =
    some Expressions.tailBody.render := by decide +kernel

private theorem expression_fact_13 :
  Source.expressionBody "target_at" Output.SourceShape.outputImplementation =
    some Expressions.targetBody.render := by decide +kernel

private theorem expression_fact_14 :
  Source.expressionBody "dynamic_at" Output.SourceShape.outputImplementation =
    some Expressions.dynamicBody.render := by decide +kernel

private theorem expression_fact_15 :
  Source.expressionBody "assignment_at" Output.SourceShape.outputImplementation =
    some Expressions.assignmentBody.render := by decide +kernel

private theorem expression_fact_16 :
  Source.expressionBody "output_at" Output.SourceShape.outputImplementation =
    some Expressions.outputBody.render := by decide +kernel

private theorem expression_fact_17 :
  Source.expressionBody "step" Output.SourceShape.outputImplementation =
    some Expressions.stepBody.render := by decide +kernel

private theorem expression_fact_23 :
  Source.expressionBody "work_tail" Output.SourceShape.outputImplementation = some Expressions.workTailBody.render := by decide +kernel

private theorem expression_fact_24 :
  Source.expressionBody "fits" Output.SourceShape.outputImplementation = some Expressions.fitsBody.render := by decide +kernel

private theorem expression_fact_25 :
  Source.expressionBody "comparison_at" Output.SourceShape.outputImplementation = some Expressions.comparisonBody.render := by decide +kernel

private theorem expression_subtype_lookup :
  Source.expressionBody "lookup_subtype_model" Output.SourceShape.outputImplementation =
    some Expressions.subtypeLookupModelBody.render := by decide +kernel

private theorem expression_scalar_type :
  Source.expressionBody "scalar_type_at" Output.SourceShape.outputImplementation =
    some Expressions.scalarTypeBody.render := by decide +kernel

private theorem expression_subtype_declaration :
  Source.expressionBody "subtype_declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.subtypeDeclarationBody.render := by decide +kernel

theorem candidate_expressions : ExpressionTranslationFor Output.SourceShape.outputImplementation := by
  exact ⟨Expressions.checked_precedence,
    Expressions.checked_scopes,
    expression_call_after,
    expression_fact_03,
    expression_fact_04,
    expression_image,
    expression_fact_05,
    expression_fact_06,
    expression_fact_07,
    expression_string_declaration,
    expression_scalar_constraint,
    expression_scalar_declaration,
    expression_fact_08,
    expression_fact_09,
    expression_fact_10,
    expression_fact_11,
    expression_fact_12,
    expression_fact_13,
    expression_fact_14,
    expression_fact_15,
    expression_fact_16,
    expression_fact_17,
    expression_fact_23,
    expression_fact_24,
    expression_fact_25,
    expression_subtype_lookup,
    expression_scalar_type,
    expression_subtype_declaration⟩

abbrev allTokens : List ShellToken := Expressions.allTokens

/-- The native membership expression contains one enumeration range followed
by these alternatives. Rendering and classification share this inventory. -/
def wordTokenAlternatives : List ShellToken :=
  [.word "constant", .word "string", .word "silver_arguments", .word "first_or_default",
   .word "if", .word "input_is_valid", .word "then", .word "else", .word "elsif", .word "reject",
   .word "and", .word "length", .word "or", .word "not", .word "null",
   .word "integer", .word "for", .word "in", .word "reverse", .word "loop", .word "range",
   .word "array", .word "of", .word "subtype",
   .word "boolean", .word "true", .word "false", .word "xor", .word "character"]

def wordTokens : List ShellToken := allTokens.take 11 ++ wordTokenAlternatives

def wordTokenBody : List String :=
  ["token", "in", Expressions.tokenName (.word "with"), "..", Expressions.tokenName (.word "end")] ++
    wordTokenAlternatives.flatMap (fun token => ["|", Expressions.tokenName token])

def commaNames (names : List String) : List String := List.flatten ((names.map fun name => [name]).intersperse [","])

def quoted (text : String) : String :=
  String.ofList (['"'] ++ text.toList.flatMap (fun ch => if ch = '"' then ['"', '"'] else [ch]) ++ ['"'])

/-- Statements is a scanner nonterminal; all lexical/helper tokens retain
an exact named representation in the native enumeration. -/
def booleanTokens : List ShellToken := [.word "boolean", .word "true", .word "false", .word "xor", .word "character"]

def earlierTokens : List ShellToken := allTokens.take (allTokens.length - booleanTokens.length)

def nativeTokenNames : List String :=
  ((allTokens.take 50).map Expressions.tokenName) ++ ["statements", "context_clauses"] ++
    (((earlierTokens.drop 51).filter (· != ShellToken.word "subtype")).map Expressions.tokenName) ++
    [Expressions.tokenName (.word "subtype")] ++ booleanTokens.map Expressions.tokenName

def spellingBody : List String := ["case", "token", "is"] ++
  List.flatten (((allTokens.take 41 ++ [ShellToken.word "null"] ++
      ((earlierTokens.drop 51).filter (· != ShellToken.word "subtype")).flatMap
        (fun token => if token == ShellToken.word "of" then [ShellToken.word "subtype"] ++ booleanTokens ++ [token] else [token])).map fun token =>
    ["when", Expressions.tokenName token, "=>", quoted (Expressions.spelling token)]).intersperse [","]) ++
  [",", "when"] ++
  List.flatten ((((allTokens.drop 41).take 8).map Expressions.tokenName ++ ["statements", "context_clauses"]).map
    (fun name => [name]) |>.intersperse ["|"]) ++ ["=>", quoted "_"]

def helperForms : List Form := [.direct, .argument]

abbrev HelperCatalogueTranslationFor (specTokens bodyTokens : List String) : Prop :=
  typeDeclaration "form_kind" specTokens =
    some (["("] ++ commaNames (helperForms.map Expressions.formName) ++ [")"]) ∧
  typeDeclaration "token_kind" specTokens =
    some (["("] ++ commaNames nativeTokenNames ++ [")"]) ∧
  Source.expressionBody "spelling" bodyTokens = some spellingBody ∧
  Source.expressionBody "is_word_token" bodyTokens = some wordTokenBody ∧
  Source.expressionBody "is_argument_form" specTokens =
    some (expectedTokens "Form = Argument_Form")

private theorem catalogue_forms :
  typeDeclaration "form_kind" Output.SourceShape.outputSpecification =
    some (["("] ++ commaNames (helperForms.map Expressions.formName) ++ [")"]) := by decide +kernel

private theorem catalogue_fact_01 :
  typeDeclaration "token_kind" Output.SourceShape.outputSpecification =
    some (["("] ++ commaNames nativeTokenNames ++ [")"]) := by decide +kernel

private theorem catalogue_fact_03 :
  Source.expressionBody "spelling" Output.SourceShape.outputImplementation = some spellingBody := by decide +kernel

private theorem catalogue_fact_05 :
  Source.expressionBody "is_word_token" Output.SourceShape.outputImplementation = some wordTokenBody := by decide +kernel

private theorem catalogue_fact_06 :
  Source.expressionBody "is_argument_form" Output.SourceShape.outputSpecification =
    some (expectedTokens "Form = Argument_Form") := by decide +kernel

theorem candidate_catalogue : HelperCatalogueTranslationFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation :=
  ⟨catalogue_forms, catalogue_fact_01, catalogue_fact_03, catalogue_fact_05, catalogue_fact_06⟩

/-- The checked enumeration order gives the exact meaning of With .. End;
every valid model token has the same word classification as that native set. -/
abbrev TokenMapping : Prop :=
  allTokens = Expressions.allTokens ∧
  allTokens.take 11 =
    [.word "with", .word "silver_io", .word "procedure", .word "main", .word "is",
     .word "pragma", .word "spark_mode", .word "on", .word "begin", .word "put_line", .word "end"] ∧
  (∀ token ∈ allTokens, 1 ≤ (Expressions.spelling token).length ∧ (Expressions.spelling token).length ≤ 16) ∧
  (∀ token ∈ allTokens, Expressions.isWord token = decide (token ∈ wordTokens))

theorem candidate_token_mapping : TokenMapping := by decide +kernel

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
  Lexical.SourceBridge.recordDeclaration "value_result" bodyTokens = some (expectedTokens "record after , value_first : literal_position ; minimum_length , static_length : capacity_value ; dynamic_seen , nonliteral_seen , empty_value : boolean ; reference : binding_count ; operands : natural range 0 . . max_expression_operands ; first_index , last_index : scalars . interval ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "expression_result" bodyTokens = some (expectedTokens "record after : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count : operand_count ; named_seen , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") ∧
  typeDeclaration "binding_array" bodyTokens = some (expectedTokens "array (Binding_Index) of Binding_Info") ∧
  Source.declaration "empty_binding" bodyTokens = some (expectedTokens "constant binding_info : = ( first = > 0 , after = > 0 , value_first = > 0 , static_length = > 0 , dynamic = > false , mutable = > false , is_character = > false , first_index = > 1 , last_index = > 0 )") ∧
  Source.declaration "empty_environment" bodyTokens = some (expectedTokens "constant binding_environment : = ( count = > 0 , items = > ( others = > empty_binding ) )") ∧
  Source.declaration "initial_state" bodyTokens = some (expectedTokens "constant parser_state : = ( position = > 1 , names = > empty_environment , scalar_names = > scalar_expressions . empty_environment , array_names = > array_bindings . empty_environment , subtype_names = > empty_subtypes , boolean_names = > empty_booleans , dynamic_first = > 0 , dynamic_after = > 0 , target = > 0 , capacity = > max_source_length )") ∧
  Source.declaration "invalid_state" bodyTokens = some (expectedTokens "constant parser_state : = ( position = > 0 , names = > empty_environment , scalar_names = > scalar_expressions . empty_environment , array_names = > array_bindings . empty_environment , subtype_names = > empty_subtypes , boolean_names = > empty_booleans , dynamic_first = > 0 , dynamic_after = > 0 , target = > 0 , capacity = > 0 )") ∧
  Source.declaration "invalid_value" bodyTokens = some (expectedTokens "constant value_result : = ( after = > 0 , value_first = > 0 , minimum_length = > 0 , static_length = > 0 , dynamic_seen = > false , nonliteral_seen = > false , empty_value = > false , reference = > 0 , operands = > 0 , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( 0 ) )") ∧
  Source.declaration "invalid_expression" bodyTokens = some (expectedTokens "constant expression_result : = ( after = > 0 , minimum_length = > 0 , static_length = > 0 , dynamic_count = > 0 , named_seen = > false , empty_value = > false , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( 0 ) )") ∧
  Source.expressionBody "valid_names" bodyTokens = some (expectedTokens "for all i in 1 . . names . count = > names . items ( i ) . first > 0 and then valid_name_state ( text , names . items ( i ) . first , names . items ( i ) . after ) and then names . items ( i ) . value_first < = text ' last + 1 and then fixed_bounds_valid ( names . items ( i ) . static_length , names . items ( i ) . dynamic , names . items ( i ) . is_character , names . items ( i ) . first_index , names . items ( i ) . last_index , i )") ∧
  Source.expressionBody "valid_state" bodyTokens = some (expectedTokens "state . position < = text ' last + 1 and then valid_names ( text , state . names ) and then scalar_expressions . valid_environment ( text , state . scalar_names ) and then array_bindings . valid_environment ( text , state . array_names ) and then valid_subtypes ( text , state . subtype_names ) and then valid_booleans ( text , state . boolean_names ) and then valid_mutable_bounds ( state . scalar_names ) and then valid_declaration_values ( state . scalar_names , state . scalar_names . count ) and then valid_name_state ( text , state . dynamic_first , state . dynamic_after ) and then state . target < = state . names . count") ∧
  maxConcatenations = 63 ∧
  Lexical.SourceBridge.subtypeDeclaration "concatenation_count" bodyTokens = some (expectedTokens "natural range 0 .. max_concatenations") ∧
  Source.declaration "max_concatenations" specTokens = some (expectedTokens "constant positive := 63") ∧
  Lexical.SourceBridge.recordDeclaration "expression_state" bodyTokens = some (expectedTokens "record position : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count , operands : operand_count ; depth : literal_position ; named_seen , need_operand , complete , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") ∧
  Source.declaration "invalid_expression_state" bodyTokens = some (expectedTokens "constant expression_state : = ( position = > 0 , minimum_length = > 0 , static_length = > 0 , dynamic_count = > 0 , operands = > 0 , depth = > 0 , named_seen = > false , need_operand = > true , complete = > false , empty_value = > false , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( 0 ) )") ∧
  Source.expressionBody "valid_expression_state" bodyTokens = some (expectedTokens "state . position < = text ' last + 1 and then state . dynamic_count < = state . operands and then ( state . position = 0 or else state . depth < state . position )") ∧
  functionHeader "valid_mutable_bounds" "is" bodyTokens = some (expectedTokens "( scalar_names : scalar_expressions . environment ) return boolean") ∧
  Source.expressionBody "valid_mutable_bounds" bodyTokens = some (expectedTokens "for all index in 1 . . scalar_names . count = > ( if scalar_names . items ( index ) . mutable then not scalars . is_empty ( scalar_names . items ( index ) . bounds ) and then scalar_names . items ( index ) . bounds . lower > = scalar_names . items ( index ) . declared_bounds . lower and then scalar_names . items ( index ) . bounds . upper < = scalar_names . items ( index ) . declared_bounds . upper )") ∧
  functionHeader "valid_declaration_values" "is" bodyTokens = some (expectedTokens "( scalar_names : scalar_expressions . environment ; count : scalar_expressions . binding_count ) return boolean") ∧
  Source.expressionBody "valid_declaration_values" bodyTokens = some (expectedTokens "count < = scalar_names . count and then ( for all index in 1 . . count = > not scalars . is_empty ( scalar_names . items ( index ) . bounds ) )") ∧
  Source.declaration "max_subtype_bindings" bodyTokens =
    some (expectedTokens "constant positive : = max_source_length / 3 2") ∧
  Lexical.SourceBridge.subtypeDeclaration "subtype_count" bodyTokens =
    some (expectedTokens "natural range 0 .. max_subtype_bindings") ∧
  Lexical.SourceBridge.subtypeDeclaration "subtype_index" bodyTokens =
    some (expectedTokens "positive range 1 .. max_subtype_bindings") ∧
  Lexical.SourceBridge.recordDeclaration "subtype_binding" bodyTokens =
    some (expectedTokens "record first , after : literal_position ; bounds : scalars . interval ; end record") ∧
  Source.declaration "empty_subtype_binding" bodyTokens =
    some (expectedTokens "constant subtype_binding : = ( 0 , 0 , scalars . empty )") ∧
  typeDeclaration "subtype_binding_array" bodyTokens =
    some (expectedTokens "array ( subtype_index ) of subtype_binding") ∧
  typeDeclaration "subtype_visibility" bodyTokens =
    some (expectedTokens "array ( names . operation_kind ) of boolean") ∧
  Lexical.SourceBridge.recordDeclaration "subtype_environment" bodyTokens =
    some (expectedTokens "record count : subtype_count ; items : subtype_binding_array ; hidden_calls : subtype_visibility ; true_hidden , false_hidden : boolean ; end record") ∧
  Source.declaration "empty_subtypes" bodyTokens =
    some (expectedTokens "constant subtype_environment : = ( 0 , ( others = > empty_subtype_binding ) , ( others = > false ) , false , false )") ∧
  functionHeader "valid_subtypes" ";" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length") ∧
  functionHeader "valid_subtypes" "is" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean") ∧
  Source.expressionBody "valid_subtypes" bodyTokens =
    some (expectedTokens "for all index in 1 . . subtypes . count = > subtypes . items ( index ) . first > 0 and then valid_name_state ( text , subtypes . items ( index ) . first , subtypes . items ( index ) . after ) and then not scalars . is_empty ( subtypes . items ( index ) . bounds )") ∧
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
  Lexical.SourceBridge.recordDeclaration "value_result" Output.SourceShape.outputImplementation = some (expectedTokens "record after , value_first : literal_position ; minimum_length , static_length : capacity_value ; dynamic_seen , nonliteral_seen , empty_value : boolean ; reference : binding_count ; operands : natural range 0 . . max_expression_operands ; first_index , last_index : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_13 :
  Lexical.SourceBridge.recordDeclaration "expression_result" Output.SourceShape.outputImplementation = some (expectedTokens "record after : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count : operand_count ; named_seen , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_14 :
  typeDeclaration "binding_array" Output.SourceShape.outputImplementation = some (expectedTokens "array (Binding_Index) of Binding_Info") := by decide +kernel

private theorem declaration_fact_15 :
  Source.declaration "empty_binding" Output.SourceShape.outputImplementation = some (expectedTokens "constant binding_info : = ( first = > 0 , after = > 0 , value_first = > 0 , static_length = > 0 , dynamic = > false , mutable = > false , is_character = > false , first_index = > 1 , last_index = > 0 )") := by decide +kernel

private theorem declaration_fact_16 :
  Source.declaration "empty_environment" Output.SourceShape.outputImplementation = some (expectedTokens "constant binding_environment : = ( count = > 0 , items = > ( others = > empty_binding ) )") := by decide +kernel

private theorem declaration_fact_17 :
  Source.declaration "initial_state" Output.SourceShape.outputImplementation = some (expectedTokens "constant parser_state : = ( position = > 1 , names = > empty_environment , scalar_names = > scalar_expressions . empty_environment , array_names = > array_bindings . empty_environment , subtype_names = > empty_subtypes , boolean_names = > empty_booleans , dynamic_first = > 0 , dynamic_after = > 0 , target = > 0 , capacity = > max_source_length )") := by decide +kernel

private theorem declaration_fact_18 :
  Source.declaration "invalid_state" Output.SourceShape.outputImplementation = some (expectedTokens "constant parser_state : = ( position = > 0 , names = > empty_environment , scalar_names = > scalar_expressions . empty_environment , array_names = > array_bindings . empty_environment , subtype_names = > empty_subtypes , boolean_names = > empty_booleans , dynamic_first = > 0 , dynamic_after = > 0 , target = > 0 , capacity = > 0 )") := by decide +kernel

private theorem declaration_fact_19 :
  Source.declaration "invalid_value" Output.SourceShape.outputImplementation = some (expectedTokens "constant value_result : = ( after = > 0 , value_first = > 0 , minimum_length = > 0 , static_length = > 0 , dynamic_seen = > false , nonliteral_seen = > false , empty_value = > false , reference = > 0 , operands = > 0 , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( 0 ) )") := by decide +kernel

private theorem declaration_fact_20 :
  Source.declaration "invalid_expression" Output.SourceShape.outputImplementation = some (expectedTokens "constant expression_result : = ( after = > 0 , minimum_length = > 0 , static_length = > 0 , dynamic_count = > 0 , named_seen = > false , empty_value = > false , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( 0 ) )") := by decide +kernel

private theorem declaration_fact_21 :
  Source.expressionBody "valid_names" Output.SourceShape.outputImplementation = some (expectedTokens "for all i in 1 . . names . count = > names . items ( i ) . first > 0 and then valid_name_state ( text , names . items ( i ) . first , names . items ( i ) . after ) and then names . items ( i ) . value_first < = text ' last + 1 and then fixed_bounds_valid ( names . items ( i ) . static_length , names . items ( i ) . dynamic , names . items ( i ) . is_character , names . items ( i ) . first_index , names . items ( i ) . last_index , i )") := by decide +kernel

private theorem declaration_fact_22 :
  Source.expressionBody "valid_state" Output.SourceShape.outputImplementation = some (expectedTokens "state . position < = text ' last + 1 and then valid_names ( text , state . names ) and then scalar_expressions . valid_environment ( text , state . scalar_names ) and then array_bindings . valid_environment ( text , state . array_names ) and then valid_subtypes ( text , state . subtype_names ) and then valid_booleans ( text , state . boolean_names ) and then valid_mutable_bounds ( state . scalar_names ) and then valid_declaration_values ( state . scalar_names , state . scalar_names . count ) and then valid_name_state ( text , state . dynamic_first , state . dynamic_after ) and then state . target < = state . names . count") := by decide +kernel

private theorem declaration_fact_23 :
  maxConcatenations = 63 := by decide +kernel

private theorem declaration_fact_24 :
  Lexical.SourceBridge.subtypeDeclaration "concatenation_count" Output.SourceShape.outputImplementation = some (expectedTokens "natural range 0 .. max_concatenations") := by decide +kernel

private theorem declaration_fact_25 :
  Source.declaration "max_concatenations" Output.SourceShape.outputSpecification = some (expectedTokens "constant positive := 63") := by decide +kernel

private theorem declaration_fact_26 :
  Lexical.SourceBridge.recordDeclaration "expression_state" Output.SourceShape.outputImplementation = some (expectedTokens "record position : literal_position ; minimum_length , static_length : capacity_value ; dynamic_count , operands : operand_count ; depth : literal_position ; named_seen , need_operand , complete , empty_value : boolean ; first_index , last_index : scalars . interval ; end record") := by decide +kernel

private theorem declaration_fact_27 :
  Source.declaration "invalid_expression_state" Output.SourceShape.outputImplementation = some (expectedTokens "constant expression_state : = ( position = > 0 , minimum_length = > 0 , static_length = > 0 , dynamic_count = > 0 , operands = > 0 , depth = > 0 , named_seen = > false , need_operand = > true , complete = > false , empty_value = > false , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( 0 ) )") := by decide +kernel

private theorem declaration_fact_28 :
  Source.expressionBody "valid_expression_state" Output.SourceShape.outputImplementation = some (expectedTokens "state . position < = text ' last + 1 and then state . dynamic_count < = state . operands and then ( state . position = 0 or else state . depth < state . position )") := by decide +kernel

private theorem declaration_mutable_bounds_header :
  functionHeader "valid_mutable_bounds" "is" Output.SourceShape.outputImplementation = some (expectedTokens "( scalar_names : scalar_expressions . environment ) return boolean") := by decide +kernel

private theorem declaration_mutable_bounds_body :
  Source.expressionBody "valid_mutable_bounds" Output.SourceShape.outputImplementation = some (expectedTokens "for all index in 1 . . scalar_names . count = > ( if scalar_names . items ( index ) . mutable then not scalars . is_empty ( scalar_names . items ( index ) . bounds ) and then scalar_names . items ( index ) . bounds . lower > = scalar_names . items ( index ) . declared_bounds . lower and then scalar_names . items ( index ) . bounds . upper < = scalar_names . items ( index ) . declared_bounds . upper )") := by decide +kernel

private theorem declaration_declaration_values_header :
  functionHeader "valid_declaration_values" "is" Output.SourceShape.outputImplementation = some (expectedTokens "( scalar_names : scalar_expressions . environment ; count : scalar_expressions . binding_count ) return boolean") := by decide +kernel

private theorem declaration_declaration_values_body :
  Source.expressionBody "valid_declaration_values" Output.SourceShape.outputImplementation = some (expectedTokens "count < = scalar_names . count and then ( for all index in 1 . . count = > not scalars . is_empty ( scalar_names . items ( index ) . bounds ) )") := by decide +kernel

private theorem declaration_subtype_fact_01 :
  Source.declaration "max_subtype_bindings" Output.SourceShape.outputImplementation =
    some (expectedTokens "constant positive : = max_source_length / 3 2") := by decide +kernel

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
    some (expectedTokens "constant subtype_binding : = ( 0 , 0 , scalars . empty )") := by decide +kernel

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
    some (expectedTokens "constant subtype_environment : = ( 0 , ( others = > empty_subtype_binding ) , ( others = > false ) , false , false )") := by decide +kernel

private theorem declaration_subtype_fact_10 :
  functionHeader "valid_subtypes" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length") := by decide +kernel

private theorem declaration_subtype_fact_11 :
  functionHeader "valid_subtypes" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ) return boolean") := by decide +kernel

private theorem declaration_subtype_fact_12 :
  Source.expressionBody "valid_subtypes" Output.SourceShape.outputImplementation =
    some (expectedTokens "for all index in 1 . . subtypes . count = > subtypes . items ( index ) . first > 0 and then valid_name_state ( text , subtypes . items ( index ) . first , subtypes . items ( index ) . after ) and then not scalars . is_empty ( subtypes . items ( index ) . bounds )") := by decide +kernel

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

abbrev RefinementFor (bodyTokens : List String) : Prop :=
  functionHeader "scalar_constraint_at" ";" bodyTokens = some
    (expectedTokens "( text : string ; position : literal_position ; scalar_names : scalar_expressions . environment ; base_bounds : scalars . interval : = scalars . full ) return scalar_constraint_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then scalar_expressions . valid_environment ( text , scalar_names ) , post = > scalar_constraint_at ' result . after = 0 or else scalar_constraint_at ' result . after in position . . text ' last + 1") ∧
  functionHeader "image_at" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; integer_hidden : boolean ; arrays : array_bindings . metadata ; initials : array_bindings . element_array ; elaborating : boolean ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post = > image_at ' result . value_first = 0 and then image_at ' result . reference = 0 and then ( image_at ' result . after = 0 or else image_at ' result . after in position + 1 . . text ' last + 1 )") ∧
  functionHeader "string_declaration_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , string_declaration_at ' result ) and then ( string_declaration_at ' result . position = 0 or else string_declaration_at ' result . position > state . position )") ∧
  functionHeader "scalar_declaration_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , scalar_declaration_at ' result ) and then ( scalar_declaration_at ' result . position = 0 or else scalar_declaration_at ' result . position > state . position )") ∧
  functionHeader "call_after" ";" bodyTokens = some (expectedTokens "( text : string ; environment : binding_environment ; position : literal_position ; operation : names . operation_kind ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; subtype_hidden : boolean : = false ; booleans : boolean_environment : = empty_booleans ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , environment ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) and then valid_booleans ( text , booleans ) and then position < = text ' last + 1 , post = > call_after ' result = 0 or else call_after ' result in position + 1 . . text ' last + 1") ∧
  functionHeader "skip_at" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > skip_at ' result < = text ' last + 1 and then ( skip_at ' result = ( if position = 0 then 0 else trivia_end ( text , position ) ) ) )") ∧
  functionHeader "name_after" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > ( name_after ' result = 0 or else name_after ' result in position + 1 . . text ' last + 1 ) and then ( name_after ' result = ( if position = 0 then 0 else identifier_end ( text , position ) ) ) )") ∧
  functionHeader "take_token" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; token : token_kind ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > ( take_token ' result = 0 or else take_token ' result in position + 1 . . text ' last + 1 ) and then ( take_token ' result = fixed_after ( text , position , token ) ) )") ∧
  functionHeader "lookup_name" ";" bodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then first < = text ' last + 1 and then after < = text ' last + 1 , post = > ( static = > lookup_name ' result < = names . count and then ( lookup_name ' result = ( if first = 0 or else after < = first then 0 else lookup_from ( text , names , first , after , 1 ) ) ) )") ∧
  functionHeader "literal_at" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > literal_at ' result . value_first < = text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 . . text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = ( if position / = 0 and then position < = text ' last and then text ( position ) = character ' val ( 3 4 ) and then literal_end ( text , position + 1 ) / = 0 then ( after = > literal_end ( text , position + 1 ) , value_first = > position + 1 , minimum_length = > literal_length ( text , position + 1 ) , static_length = > literal_length ( text , position + 1 ) , dynamic_seen = > false , nonliteral_seen = > false , empty_value = > false , reference = > 0 , operands = > 1 , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( scalars . value ( literal_length ( text , position + 1 ) ) ) ) else invalid_value ) ) )") ∧
  functionHeader "read_declarations" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > ( static = > valid_state ( text , read_declarations ' result ) and then ( read_declarations ' result = declarations_at ( text , state , arguments ) ) )") ∧
  functionHeader "expression_at" ";" bodyTokens = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ":=", "scalar_expressions", ".", "empty_environment", ";", "integer_hidden", ":", "boolean", ":=", "false", ";", "arrays", ":", "array_bindings", ".", "metadata", ":=", "array_bindings", ".", "empty_metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_names", "(", "text", ",", "names", ")", "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "scalar_names", ")", "and", "then", "array_bindings", ".", "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "(", "static", "=>", "(", "expression_at", "'", "result", ".", "after", "=", "0", "or", "else", "expression_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", "and", "then", "(", "expression_at", "'", "result", "=", "expression_tail", "(", "text", ",", "names", ",", "(", "position", "=>", "position", ",", "minimum_length", "=>", "0", ",", "static_length", "=>", "0", ",", "dynamic_count", "=>", "0", ",", "operands", "=>", "0", ",", "depth", "=>", "0", ",", "named_seen", "=>", "false", ",", "need_operand", "=>", "true", ",", "complete", "=>", "false", ",", "empty_value", "=>", "false", ")", ",", "scalar_names", ",", "integer_hidden", ",", "arrays", ",", "initials", ",", "elaborating", ")", ")", ")"] ∧
  functionHeader "capacity_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > ( static = > valid_state ( text , capacity_at ' result ) and then capacity_at ' result = ( if state . position = 0 then invalid_state elsif decimal_at ( text , trivia_end ( text , state . position ) ) . after = 0 then invalid_state else ( state with delta position = > decimal_at ( text , trivia_end ( text , state . position ) ) . after , capacity = > decimal_at ( text , trivia_end ( text , state . position ) ) . value ) ) )") ∧
  functionHeader "step" ";" bodyTokens = some (expectedTokens "( text : string ; form : form_kind ; token : token_kind ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , step ' result )") ∧
  functionHeader "declaration_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , declaration_at ' result ) and then ( declaration_at ' result . position = 0 or else declaration_at ' result . position > state . position )") ∧
  functionHeader "argument_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , argument_at ' result )") ∧
  functionHeader "value_at" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; integer_hidden : boolean : = false ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post = > value_at ' result . value_first < = text ' last + 1 and then value_at ' result . reference < = names . count and then ( value_at ' result . after = 0 or else value_at ' result . after in position + 1 . . text ' last + 1 )") ∧
  functionHeader "expression_step" ";" bodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; integer_hidden : boolean : = false ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return expression_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) and then valid_expression_state ( text , state ) , post = > valid_expression_state ( text , expression_step ' result ) and then ( expression_step ' result . position = 0 or else expression_step ' result . complete or else expression_step ' result . position > state . position )") ∧
  functionHeader "target_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; same_target : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , target_at ' result )") ∧
  functionHeader "dynamic_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , dynamic_at ' result )") ∧
  functionHeader "assignment_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , assignment_at ' result )") ∧
  functionHeader "output_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , output_at ' result )") ∧
  functionHeader "declarations_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , declarations_at ' result ) , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - state . position )") ∧
  functionHeader "lookup_from" ";" bodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; first , after : cursor ; index : positive ) return binding_count with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then first < after and then after < = text ' last + 1 and then index < = names . count + 1 , post = > lookup_from ' result < = names . count , subprogram_variant = > ( increases = > index )") ∧
  functionHeader "expression_tail" ";" bodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; integer_hidden : boolean : = false ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return expression_result with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) and then valid_expression_state ( text , state ) , post = > expression_tail ' result . after = 0 or else expression_tail ' result . after in state . position . . text ' last + 1 , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - state . position )") ∧
  functionHeader "work_tail" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; remaining : concatenation_count ) return boolean with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - position )") ∧
  functionHeader "within_work_budget" ";" bodyTokens = some (expectedTokens "( text : string ) return boolean with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length , post = > ( static = > within_work_budget ' result = work_tail ( text , 1 , max_concatenations ) )") ∧
  functionHeader "comparison_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , comparison_at ' result )") ∧
  functionHeader "fits" ";" bodyTokens = some (expectedTokens "( value : expression_result ; capacity : capacity_value ) return boolean with global = > null") ∧
  functionHeader "lookup_subtype_model" ";" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ; index : subtype_count ) return subtype_count with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_subtypes ( text , subtypes ) and then index < = subtypes . count and then first < = text ' last + 1 and then after < = text ' last + 1 , post = > lookup_subtype_model ' result < = index , subprogram_variant = > ( decreases = > index )") ∧
  functionHeader "lookup_subtype_model" "is" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ; index : subtype_count ) return subtype_count") ∧
  functionHeader "lookup_subtype" ";" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ) return subtype_count with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_subtypes ( text , subtypes ) and then first < = text ' last + 1 and then after < = text ' last + 1 , post = > ( runtime = > lookup_subtype ' result < = subtypes . count , static = > lookup_subtype ' result = lookup_subtype_model ( text , subtypes , first , after , subtypes . count ) )") ∧
  functionHeader "lookup_subtype" "is" bodyTokens =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ) return subtype_count") ∧
  functionHeader "scalar_type_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; position : literal_position ) return scalar_constraint_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) and then position < = text ' last + 1 , post = > scalar_type_at ' result . after = 0 or else ( scalar_type_at ' result . after in position + 1 . . text ' last + 1 and then not scalars . is_empty ( scalar_type_at ' result . bounds ) )") ∧
  functionHeader "scalar_type_at" "is" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; position : literal_position ) return scalar_constraint_result") ∧
  functionHeader "subtype_declaration_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , subtype_declaration_at ' result ) and then ( subtype_declaration_at ' result . position = 0 or else subtype_declaration_at ' result . position > state . position )") ∧
  functionHeader "subtype_declaration_at" "is" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state")

private theorem refinement_call_after :
  functionHeader "call_after" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; environment : binding_environment ; position : literal_position ; operation : names . operation_kind ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; subtype_hidden : boolean : = false ; booleans : boolean_environment : = empty_booleans ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , environment ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) and then valid_booleans ( text , booleans ) and then position < = text ' last + 1 , post = > call_after ' result = 0 or else call_after ' result in position + 1 . . text ' last + 1") := by decide +kernel

private theorem refinement_fact_05 :
  functionHeader "skip_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > skip_at ' result < = text ' last + 1 and then ( skip_at ' result = ( if position = 0 then 0 else trivia_end ( text , position ) ) ) )") := by decide +kernel

private theorem refinement_fact_06 :
  functionHeader "name_after" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > ( name_after ' result = 0 or else name_after ' result in position + 1 . . text ' last + 1 ) and then ( name_after ' result = ( if position = 0 then 0 else identifier_end ( text , position ) ) ) )") := by decide +kernel

private theorem refinement_fact_07 :
  functionHeader "take_token" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ; token : token_kind ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > ( take_token ' result = 0 or else take_token ' result in position + 1 . . text ' last + 1 ) and then ( take_token ' result = fixed_after ( text , position , token ) ) )") := by decide +kernel

private theorem refinement_fact_08 :
  functionHeader "lookup_name" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then first < = text ' last + 1 and then after < = text ' last + 1 , post = > ( static = > lookup_name ' result < = names . count and then ( lookup_name ' result = ( if first = 0 or else after < = first then 0 else lookup_from ( text , names , first , after , 1 ) ) ) )") := by decide +kernel

private theorem refinement_fact_09 :
  functionHeader "literal_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > ( static = > literal_at ' result . value_first < = text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 . . text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = ( if position / = 0 and then position < = text ' last and then text ( position ) = character ' val ( 3 4 ) and then literal_end ( text , position + 1 ) / = 0 then ( after = > literal_end ( text , position + 1 ) , value_first = > position + 1 , minimum_length = > literal_length ( text , position + 1 ) , static_length = > literal_length ( text , position + 1 ) , dynamic_seen = > false , nonliteral_seen = > false , empty_value = > false , reference = > 0 , operands = > 1 , first_index = > scalars . singleton ( 1 ) , last_index = > scalars . singleton ( scalars . value ( literal_length ( text , position + 1 ) ) ) ) else invalid_value ) ) )") := by decide +kernel

private theorem refinement_fact_10 :
  functionHeader "read_declarations" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > ( static = > valid_state ( text , read_declarations ' result ) and then ( read_declarations ' result = declarations_at ( text , state , arguments ) ) )") := by decide +kernel

private theorem refinement_fact_11 :
  functionHeader "expression_at" ";" Output.SourceShape.outputImplementation = some ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ":=", "scalar_expressions", ".", "empty_environment", ";", "integer_hidden", ":", "boolean", ":=", "false", ";", "arrays", ":", "array_bindings", ".", "metadata", ":=", "array_bindings", ".", "empty_metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ")", "return", "expression_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_names", "(", "text", ",", "names", ")", "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "scalar_names", ")", "and", "then", "array_bindings", ".", "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "(", "static", "=>", "(", "expression_at", "'", "result", ".", "after", "=", "0", "or", "else", "expression_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", "and", "then", "(", "expression_at", "'", "result", "=", "expression_tail", "(", "text", ",", "names", ",", "(", "position", "=>", "position", ",", "minimum_length", "=>", "0", ",", "static_length", "=>", "0", ",", "dynamic_count", "=>", "0", ",", "operands", "=>", "0", ",", "depth", "=>", "0", ",", "named_seen", "=>", "false", ",", "need_operand", "=>", "true", ",", "complete", "=>", "false", ",", "empty_value", "=>", "false", ")", ",", "scalar_names", ",", "integer_hidden", ",", "arrays", ",", "initials", ",", "elaborating", ")", ")", ")"] := by decide +kernel

private theorem refinement_fact_12 :
  functionHeader "capacity_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > ( static = > valid_state ( text , capacity_at ' result ) and then capacity_at ' result = ( if state . position = 0 then invalid_state elsif decimal_at ( text , trivia_end ( text , state . position ) ) . after = 0 then invalid_state else ( state with delta position = > decimal_at ( text , trivia_end ( text , state . position ) ) . after , capacity = > decimal_at ( text , trivia_end ( text , state . position ) ) . value ) ) )") := by decide +kernel

private theorem refinement_fact_13 :
  functionHeader "step" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; form : form_kind ; token : token_kind ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , step ' result )") := by decide +kernel

private theorem refinement_fact_14 :
  functionHeader "declaration_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , declaration_at ' result ) and then ( declaration_at ' result . position = 0 or else declaration_at ' result . position > state . position )") := by decide +kernel

private theorem refinement_fact_15 :
  functionHeader "argument_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , argument_at ' result )") := by decide +kernel

private theorem refinement_fact_16 :
  functionHeader "value_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; integer_hidden : boolean : = false ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post = > value_at ' result . value_first < = text ' last + 1 and then value_at ' result . reference < = names . count and then ( value_at ' result . after = 0 or else value_at ' result . after in position + 1 . . text ' last + 1 )") := by decide +kernel

private theorem refinement_fact_17 :
  functionHeader "expression_step" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; integer_hidden : boolean : = false ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return expression_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) and then valid_expression_state ( text , state ) , post = > valid_expression_state ( text , expression_step ' result ) and then ( expression_step ' result . position = 0 or else expression_step ' result . complete or else expression_step ' result . position > state . position )") := by decide +kernel

private theorem refinement_fact_18 :
  functionHeader "target_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ; same_target : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , target_at ' result )") := by decide +kernel

private theorem refinement_fact_19 :
  functionHeader "dynamic_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , dynamic_at ' result )") := by decide +kernel

private theorem refinement_fact_20 :
  functionHeader "assignment_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , assignment_at ' result )") := by decide +kernel

private theorem refinement_fact_21 :
  functionHeader "output_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , output_at ' result )") := by decide +kernel

private theorem refinement_fact_22 :
  functionHeader "declarations_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , declarations_at ' result ) , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - state . position )") := by decide +kernel

private theorem refinement_fact_23 :
  functionHeader "lookup_from" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; names : binding_environment ; first , after : cursor ; index : positive ) return binding_count with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then first < after and then after < = text ' last + 1 and then index < = names . count + 1 , post = > lookup_from ' result < = names . count , subprogram_variant = > ( increases = > index )") := by decide +kernel

private theorem refinement_fact_24 :
  functionHeader "expression_tail" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ; scalar_names : scalar_expressions . environment : = scalar_expressions . empty_environment ; integer_hidden : boolean : = false ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return expression_result with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) and then valid_expression_state ( text , state ) , post = > expression_tail ' result . after = 0 or else expression_tail ' result . after in state . position . . text ' last + 1 , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - state . position )") := by decide +kernel

private theorem refinement_fact_26 :
  functionHeader "work_tail" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ; remaining : concatenation_count ) return boolean with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - position )") := by decide +kernel

private theorem refinement_fact_27 :
  functionHeader "within_work_budget" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ) return boolean with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length , post = > ( static = > within_work_budget ' result = work_tail ( text , 1 , max_concatenations ) )") := by decide +kernel

private theorem refinement_fact_28 :
  functionHeader "comparison_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , comparison_at ' result )") := by decide +kernel

private theorem refinement_fact_29 :
  functionHeader "fits" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( value : expression_result ; capacity : capacity_value ) return boolean with global = > null") := by decide +kernel

private theorem refinement_string_declaration_at :
  functionHeader "string_declaration_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , string_declaration_at ' result ) and then ( string_declaration_at ' result . position = 0 or else string_declaration_at ' result . position > state . position )") := by decide +kernel

private theorem refinement_scalar_declaration_at :
  functionHeader "scalar_declaration_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , scalar_declaration_at ' result ) and then ( scalar_declaration_at ' result . position = 0 or else scalar_declaration_at ' result . position > state . position )") := by decide +kernel

private theorem refinement_scalar_constraint :
  functionHeader "scalar_constraint_at" ";" Output.SourceShape.outputImplementation = some
    (expectedTokens "( text : string ; position : literal_position ; scalar_names : scalar_expressions . environment ; base_bounds : scalars . interval : = scalars . full ) return scalar_constraint_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then scalar_expressions . valid_environment ( text , scalar_names ) , post = > scalar_constraint_at ' result . after = 0 or else scalar_constraint_at ' result . after in position . . text ' last + 1") := by decide +kernel

private theorem refinement_image :
  functionHeader "image_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; integer_hidden : boolean ; arrays : array_bindings . metadata ; initials : array_bindings . element_array ; elaborating : boolean ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post = > image_at ' result . value_first = 0 and then image_at ' result . reference = 0 and then ( image_at ' result . after = 0 or else image_at ' result . after in position + 1 . . text ' last + 1 )") := by decide +kernel

private theorem refinement_subtype_fact_01 :
  functionHeader "lookup_subtype_model" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ; index : subtype_count ) return subtype_count with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_subtypes ( text , subtypes ) and then index < = subtypes . count and then first < = text ' last + 1 and then after < = text ' last + 1 , post = > lookup_subtype_model ' result < = index , subprogram_variant = > ( decreases = > index )") := by decide +kernel

private theorem refinement_subtype_fact_02 :
  functionHeader "lookup_subtype_model" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ; index : subtype_count ) return subtype_count") := by decide +kernel

private theorem refinement_subtype_fact_03 :
  functionHeader "lookup_subtype" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ) return subtype_count with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_subtypes ( text , subtypes ) and then first < = text ' last + 1 and then after < = text ' last + 1 , post = > ( runtime = > lookup_subtype ' result < = subtypes . count , static = > lookup_subtype ' result = lookup_subtype_model ( text , subtypes , first , after , subtypes . count ) )") := by decide +kernel

private theorem refinement_subtype_fact_04 :
  functionHeader "lookup_subtype" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; subtypes : subtype_environment ; first , after : literal_position ) return subtype_count") := by decide +kernel

private theorem refinement_subtype_fact_05 :
  functionHeader "scalar_type_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; state : parser_state ; position : literal_position ) return scalar_constraint_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) and then position < = text ' last + 1 , post = > scalar_type_at ' result . after = 0 or else ( scalar_type_at ' result . after in position + 1 . . text ' last + 1 and then not scalars . is_empty ( scalar_type_at ' result . bounds ) )") := by decide +kernel

private theorem refinement_subtype_fact_06 :
  functionHeader "scalar_type_at" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; state : parser_state ; position : literal_position ) return scalar_constraint_result") := by decide +kernel

private theorem refinement_subtype_fact_07 :
  functionHeader "subtype_declaration_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , subtype_declaration_at ' result ) and then ( subtype_declaration_at ' result . position = 0 or else subtype_declaration_at ' result . position > state . position )") := by decide +kernel

private theorem refinement_subtype_fact_08 :
  functionHeader "subtype_declaration_at" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state") := by decide +kernel

theorem candidate_refinement : RefinementFor Output.SourceShape.outputImplementation := by
  exact ⟨refinement_scalar_constraint, refinement_image, refinement_string_declaration_at, refinement_scalar_declaration_at, refinement_call_after, refinement_fact_05,
    refinement_fact_06,
    refinement_fact_07,
    refinement_fact_08,
    refinement_fact_09,
    refinement_fact_10,
    refinement_fact_11,
    refinement_fact_12,
    refinement_fact_13,
    refinement_fact_14,
    refinement_fact_15,
    refinement_fact_16,
    refinement_fact_17,
    refinement_fact_18,
    refinement_fact_19,
    refinement_fact_20,
    refinement_fact_21,
    refinement_fact_22,
    refinement_fact_23,
    refinement_fact_24,
    refinement_fact_26,
    refinement_fact_27,
    refinement_fact_28,
    refinement_fact_29,
    refinement_subtype_fact_01,
    refinement_subtype_fact_02,
    refinement_subtype_fact_03,
    refinement_subtype_fact_04,
    refinement_subtype_fact_05,
    refinement_subtype_fact_06,
    refinement_subtype_fact_07,
    refinement_subtype_fact_08⟩

/-- Functional adapter postconditions contain these exact interpreted trees.
This connects imperative lexical/loop adapters to their equations rather than
merely pinning a matching header string. -/
abbrev AdapterTranslationFor (bodyTokens : List String) : Prop :=
  functionHeader "skip_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => skip_at ' result <= text ' last + 1 and then ( skip_at ' result = (" ++
      Expressions.skipBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "name_after" ";" bodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( name_after ' result = 0 or else name_after ' result in position + 1 .. text ' last + 1 ) and then ( name_after ' result = (" ++
      Expressions.nameBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "lookup_name" ";" bodyTokens =
    some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first <= text ' last + 1 and then after <= text ' last + 1 , post => ( static => lookup_name ' result <= names . count and then ( lookup_name ' result = (" ++
      Expressions.lookupBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "literal_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = (" ++
      Expressions.literalBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "expression_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment := scalar_expressions . empty_environment ; integer_hidden : boolean := false ; arrays : array_bindings . metadata := array_bindings . empty_metadata ; initials : array_bindings . element_array := array_bindings . empty_values ; elaborating : boolean := false ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result =" ++
      Expressions.expressionBody.render ++ expectedTokens ") )") ∧
  functionHeader "capacity_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , capacity_at ' result ) and then capacity_at ' result = (" ++
      Expressions.capacityBody.render ++ expectedTokens ") )") ∧
  functionHeader "within_work_budget" ";" bodyTokens =
    some (expectedTokens "( text : string ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length , post => ( static => within_work_budget ' result =" ++
      Expressions.workBudgetBody.render ++ expectedTokens ")")

private theorem adapter_fact_01 :
  functionHeader "skip_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => skip_at ' result <= text ' last + 1 and then ( skip_at ' result = (" ++
      Expressions.skipBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_02 :
  functionHeader "name_after" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( name_after ' result = 0 or else name_after ' result in position + 1 .. text ' last + 1 ) and then ( name_after ' result = (" ++
      Expressions.nameBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_03 :
  functionHeader "lookup_name" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first <= text ' last + 1 and then after <= text ' last + 1 , post => ( static => lookup_name ' result <= names . count and then ( lookup_name ' result = (" ++
      Expressions.lookupBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_04 :
  functionHeader "literal_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = (" ++
      Expressions.literalBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_05 :
  functionHeader "expression_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment := scalar_expressions . empty_environment ; integer_hidden : boolean := false ; arrays : array_bindings . metadata := array_bindings . empty_metadata ; initials : array_bindings . element_array := array_bindings . empty_values ; elaborating : boolean := false ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result =" ++
      Expressions.expressionBody.render ++ expectedTokens ") )") := by decide +kernel

private theorem adapter_fact_06 :
  functionHeader "capacity_at" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , capacity_at ' result ) and then capacity_at ' result = (" ++
      Expressions.capacityBody.render ++ expectedTokens ") )") := by decide +kernel

private theorem adapter_fact_07 :
  functionHeader "within_work_budget" ";" Output.SourceShape.outputImplementation =
    some (expectedTokens "( text : string ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length , post => ( static => within_work_budget ' result =" ++
      Expressions.workBudgetBody.render ++ expectedTokens ")") := by decide +kernel

theorem candidate_adapters : AdapterTranslationFor Output.SourceShape.outputImplementation := by
  exact ⟨adapter_fact_01,
    adapter_fact_02,
    adapter_fact_03,
    adapter_fact_04,
    adapter_fact_05,
    adapter_fact_06,
    adapter_fact_07⟩



/-- Array helpers retain their exact native domains, postfix aspects and
executable-to-ghost refinement. The loop is connected through its checked
Static postcondition; no mathematical declaration equality is assumed here. -/
abbrev ArrayHelperTranslationFor (bodyTokens : List String) : Prop :=
  Expressions.ArrayWellFormedTrees ∧
  Expressions.ArrayWellScopedTrees ∧
  Source.declaration "integer_type_word" bodyTokens =
    some (expectedTokens "constant string : = \"integer\"") ∧
  expressionDeclaration "put_array_value" bodyTokens =
    some ((Expressions.arrayPutBody.render.drop 1 |>.dropLast), (expectedTokens "with global => null , pre => state . array_names . used < array_bindings . max_elements")) ∧
  expressionDeclaration "add_array_binding" bodyTokens =
    some ((Expressions.arrayAddBody.render.drop 1 |>.dropLast), (expectedTokens "with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) and then state . array_names . names . count < array_bindings . max_bindings and then first > 0 and then valid_name_state ( text , first , after ) and then array_bindings . valid_binding ( ( first , after , bounds , offset , length , mutable , component_bounds ) ) and then offset + length <= state . array_names . used and then ( if state . array_names . names . count > 0 then offset >= state . array_names . names . items ( state . array_names . names . count ) . offset + state . array_names . names . items ( state . array_names . names . count ) . length ) and then following <= text ' last + 1 , post => valid_state ( text , add_array_binding ' result ) and then add_array_binding ' result . position = following")) ∧
  expressionDeclaration "array_values_model" bodyTokens =
    some (Expressions.arrayValuesModelBody.render, []) ∧
  expressionDeclaration "array_declaration_model" bodyTokens =
    some ((Expressions.arrayDeclarationBody false).render, []) ∧
  ArrayDeclarationNative.SourceChecks.Checked bodyTokens ∧
  functionHeader "put_array_value" "is" bodyTokens =
    some (expectedTokens "( state : parser_state ; value : scalars . value ) return parser_state") ∧
  functionHeader "add_array_binding" "is" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; first , after : literal_position ; bounds : scalars . interval ; offset , length : array_bindings . element_count ; mutable : boolean ; following : literal_position ; component_bounds : scalars . interval ) return parser_state") ∧
  functionHeader "array_values_model" ";" bodyTokens =
    some ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then", "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "valid_state", "(", "text", ",", "array_values_model", "'", "result", ")", "and", "then", "(", "if", "array_values_model", "'", "result", ".", "position", "/=", "0", "then", "array_values_model", "'", "result", ".", "position", ">=", "position", "and", "then", "array_values_model", "'", "result", "=", "(", "result_state", "with", "delta", "position", "=>", "array_values_model", "'", "result", ".", "position", ",", "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>", "array_values_model", "'", "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>", "array_values_model", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "length", "-", "parsed", ")"] ∧
  functionHeader "array_values_model" "is" bodyTokens =
    some (expectedTokens "( text : string ; source_state , result_state : parser_state ; position : literal_position ; length , parsed : array_bindings . element_count ; component_bounds : scalars . interval ) return parser_state") ∧
  functionHeader "array_values_at" ";" bodyTokens =
    some ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then", "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "array_values_at", "'", "result", ")", "and", "then", "(", "if", "array_values_at", "'", "result", ".", "position", "/=", "0", "then", "array_values_at", "'", "result", ".", "position", ">=", "position", "and", "then", "array_values_at", "'", "result", "=", "(", "result_state", "with", "delta", "position", "=>", "array_values_at", "'", "result", ".", "position", ",", "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>", "array_values_at", "'", "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>", "array_values_at", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",", "static", "=>", "array_values_at", "'", "result", "=", "array_values_model", "(", "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",", "component_bounds", ")", "and", "then", "same_parser_state", "(", "array_values_at", "'", "result", ",", "array_values_model", "(", "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",", "component_bounds", ")", ")", ")"] ∧
  functionHeader "array_values_at" "is" bodyTokens =
    some (expectedTokens "( text : string ; source_state , result_state : parser_state ; position : literal_position ; length , parsed : array_bindings . element_count ; component_bounds : scalars . interval ) return parser_state") ∧
  functionHeader "array_declaration_model" ";" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with ghost = > static , global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , array_declaration_model ' result ) and then ( array_declaration_model ' result . position = 0 or else array_declaration_model ' result . position > state . position )") ∧
  functionHeader "array_declaration_model" "is" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state") ∧
  functionHeader "array_declaration_at" ";" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > ( runtime = > valid_state ( text , array_declaration_at ' result ) and then ( array_declaration_at ' result . position = 0 or else array_declaration_at ' result . position > state . position ) , static = > array_declaration_at ' result = array_declaration_model ( text , state , arguments ) )") ∧
  functionHeader "array_declaration_at" "is" bodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state")

theorem candidate_array_helpers : ArrayHelperTranslationFor Output.SourceShape.outputImplementation := by
  refine ⟨Expressions.checked_array_precedence, Expressions.checked_array_scopes, ?_⟩
  repeat' apply And.intro
  all_goals decide +kernel

/-- All source-dependent helper checks, before binding the reviewed shape to
actual output specification and implementation tokens. -/
theorem candidate_checked :
    ExpressionTranslationFor Output.SourceShape.outputImplementation ∧
    HelperCatalogueTranslationFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation ∧
    DeclarationsFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation ∧
    RefinementFor Output.SourceShape.outputImplementation ∧
    AdapterTranslationFor Output.SourceShape.outputImplementation ∧
    ArrayHelperTranslationFor Output.SourceShape.outputImplementation :=
  ⟨candidate_expressions, candidate_catalogue, candidate_declarations,
    candidate_refinement, candidate_adapters, candidate_array_helpers⟩

/-- The complete ordinary declaration body, including scope, precedence and
native contracts, independently matched against the reviewed complete source. -/
theorem candidate_boolean_declaration :
    BooleanDeclarationNative.SourceChecks.Checked Output.SourceShape.outputImplementation := by
  constructor <;> decide +kernel


/-- Complete String helper source trees, native subtypes, defaults and contracts.
The exact source excerpts are reviewed together with their typed body equations. -/
abbrev StringHelperTranslationFor (bodyTokens : List String) : Prop :=
  StringNative.WellFormedTrees ∧
  StringNative.WellScopedTrees ∧
  StringNative.SourceChecks.Checked bodyTokens ∧
  expressionDeclaration "fixed_bounds_valid" bodyTokens = some (StringNative.fixedBoundsBody.render, []) ∧
  expressionDeclaration "character_literal_after" bodyTokens = some (StringNative.characterLiteralBody.render, []) ∧
  expressionDeclaration "concatenated_first" bodyTokens = some (StringNative.concatenatedFirstBody.render, []) ∧
  functionHeader "fixed_bounds_valid" "is" bodyTokens = some (expectedTokens "( length : capacity_value ; dynamic , is_character : boolean ; first_index , last_index : scalars . value ; slot : binding_index ) return boolean") ∧
  functionHeader "character_literal_after" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 , post = > character_literal_after ' result = 0 or else character_literal_after ' result = position + 3") ∧
  functionHeader "character_literal_after" "is" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position") ∧
  functionHeader "indexed_at" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; arrays : array_bindings . metadata ; initials : array_bindings . element_array ; elaborating , character_element : boolean ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post = > indexed_at ' result . value_first < = text ' last + 1 and then indexed_at ' result . reference < = names . count and then ( indexed_at ' result . after = 0 or else ( indexed_at ' result . after in position + 1 . . text ' last + 1 and then indexed_at ' result . operands > 0 and then ( if character_element then indexed_at ' result . minimum_length = 1 and then indexed_at ' result . static_length = 1 and then not indexed_at ' result . dynamic_seen and then indexed_at ' result . first_index = scalars . singleton ( 1 ) and then indexed_at ' result . last_index = scalars . singleton ( 1 ) ) ) )") ∧
  functionHeader "indexed_at" "is" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; arrays : array_bindings . metadata ; initials : array_bindings . element_array ; elaborating , character_element : boolean ) return value_result") ∧
  functionHeader "character_at" ";" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return value_result with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then position < = text ' last + 1 and then valid_names ( text , names ) and then scalar_expressions . valid_environment ( text , scalar_names ) and then array_bindings . valid_metadata ( text , arrays ) , post = > character_at ' result . value_first < = text ' last + 1 and then character_at ' result . reference < = names . count and then ( character_at ' result . after = 0 or else ( character_at ' result . after in position + 1 . . text ' last + 1 and then character_at ' result . minimum_length = 1 and then character_at ' result . static_length = 1 and then not character_at ' result . dynamic_seen and then character_at ' result . first_index = scalars . singleton ( 1 ) and then character_at ' result . last_index = scalars . singleton ( 1 ) ) ) , subprogram_variant = > ( decreases = > ( text ' last + 1 ) - position )") ∧
  functionHeader "character_at" "is" bodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ; scalar_names : scalar_expressions . environment ; arrays : array_bindings . metadata : = array_bindings . empty_metadata ; initials : array_bindings . element_array : = array_bindings . empty_values ; elaborating : boolean : = false ) return value_result") ∧
  functionHeader "concatenated_first" "is" bodyTokens = some (expectedTokens "( left : expression_state ; right : value_result ) return scalars . interval") ∧
  functionHeader "concatenated_last" "is" bodyTokens = some (expectedTokens "( left : expression_state ; right : value_result ) return scalars . interval") ∧
  functionHeader "character_declaration_at" ";" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global = > null , pre = > text ' first = 1 and then text ' length in 1 . . max_source_length and then valid_state ( text , state ) , post = > valid_state ( text , character_declaration_at ' result ) and then ( character_declaration_at ' result . position = 0 or else character_declaration_at ' result . position > state . position )") ∧
  functionHeader "character_declaration_at" "is" bodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state")

theorem candidate_string_helpers : StringHelperTranslationFor Output.SourceShape.outputImplementation := by
  refine ⟨StringNative.checked_precedence, StringNative.checked_scopes, ?_⟩
  repeat' apply And.intro
  all_goals decide +kernel

end Silver.Compose.SourceBridge
