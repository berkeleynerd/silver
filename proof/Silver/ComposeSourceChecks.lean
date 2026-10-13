module

public import Silver.LexicalSourceBridge
public import Silver.ComposeExpressions
import all Init.Data.Repr

@[expose] public section

/-! Exact source checks for the lexical, declaration and expression helpers
shared by the current statement scanner. Whole-shell recognition belongs to
the sequence source bridge; no old shell is asserted to be current source. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Expressions.WellScopedTrees ∧
  Source.expressionBody "fixed_after" Source.outputBodyTokens =
    some Expressions.fixedBody.render ∧
  Source.expressionBody "lookup_from" Source.outputBodyTokens =
    some Expressions.lookupFromBody.render ∧
  Source.expressionBody "value_at" Source.outputBodyTokens =
    some Expressions.valueBody.render ∧
  Source.expressionBody "new_name_allowed" Source.outputBodyTokens =
    some Expressions.newNameBody.render ∧
  Source.expressionBody "add_binding" Source.outputBodyTokens =
    some (Expressions.addBindingBody.render.drop 1 |>.dropLast) ∧
  Source.expressionBody "declaration_at" Source.outputBodyTokens =
    some Expressions.declarationBody.render ∧
  Source.expressionBody "argument_at" Source.outputBodyTokens =
    some Expressions.argumentBody.render ∧
  Source.expressionBody "declarations_at" Source.outputBodyTokens =
    some Expressions.declarationsBody.render ∧
  Source.expressionBody "expression_step" Source.outputBodyTokens =
    some Expressions.expressionStepBody.render ∧
  Source.expressionBody "expression_tail" Source.outputBodyTokens =
    some Expressions.tailBody.render ∧
  Source.expressionBody "target_at" Source.outputBodyTokens =
    some Expressions.targetBody.render ∧
  Source.expressionBody "dynamic_at" Source.outputBodyTokens =
    some Expressions.dynamicBody.render ∧
  Source.expressionBody "assignment_at" Source.outputBodyTokens =
    some Expressions.assignmentBody.render ∧
  Source.expressionBody "output_at" Source.outputBodyTokens =
    some Expressions.outputBody.render ∧
  Source.expressionBody "step" Source.outputBodyTokens =
    some Expressions.stepBody.render ∧
  Source.expressionBody "work_tail" Source.outputBodyTokens = some Expressions.workTailBody.render ∧
  Source.expressionBody "fits" Source.outputBodyTokens = some Expressions.fitsBody.render ∧
  Source.expressionBody "comparison_at" Source.outputBodyTokens = some Expressions.comparisonBody.render

private theorem expression_fact_03 :
  Source.expressionBody "fixed_after" Source.outputBodyTokens =
    some Expressions.fixedBody.render := by decide +kernel

private theorem expression_fact_04 :
  Source.expressionBody "lookup_from" Source.outputBodyTokens =
    some Expressions.lookupFromBody.render := by decide +kernel

private theorem expression_fact_05 :
  Source.expressionBody "value_at" Source.outputBodyTokens =
    some Expressions.valueBody.render := by decide +kernel

private theorem expression_fact_06 :
  Source.expressionBody "new_name_allowed" Source.outputBodyTokens =
    some Expressions.newNameBody.render := by decide +kernel

private theorem expression_fact_07 :
  Source.expressionBody "add_binding" Source.outputBodyTokens =
    some (Expressions.addBindingBody.render.drop 1 |>.dropLast) := by decide +kernel

private theorem expression_fact_08 :
  Source.expressionBody "declaration_at" Source.outputBodyTokens =
    some Expressions.declarationBody.render := by decide +kernel

private theorem expression_fact_09 :
  Source.expressionBody "argument_at" Source.outputBodyTokens =
    some Expressions.argumentBody.render := by decide +kernel

private theorem expression_fact_10 :
  Source.expressionBody "declarations_at" Source.outputBodyTokens =
    some Expressions.declarationsBody.render := by decide +kernel

private theorem expression_fact_11 :
  Source.expressionBody "expression_step" Source.outputBodyTokens =
    some Expressions.expressionStepBody.render := by decide +kernel

private theorem expression_fact_12 :
  Source.expressionBody "expression_tail" Source.outputBodyTokens =
    some Expressions.tailBody.render := by decide +kernel

private theorem expression_fact_13 :
  Source.expressionBody "target_at" Source.outputBodyTokens =
    some Expressions.targetBody.render := by decide +kernel

private theorem expression_fact_14 :
  Source.expressionBody "dynamic_at" Source.outputBodyTokens =
    some Expressions.dynamicBody.render := by decide +kernel

private theorem expression_fact_15 :
  Source.expressionBody "assignment_at" Source.outputBodyTokens =
    some Expressions.assignmentBody.render := by decide +kernel

private theorem expression_fact_16 :
  Source.expressionBody "output_at" Source.outputBodyTokens =
    some Expressions.outputBody.render := by decide +kernel

private theorem expression_fact_17 :
  Source.expressionBody "step" Source.outputBodyTokens =
    some Expressions.stepBody.render := by decide +kernel

private theorem expression_fact_23 :
  Source.expressionBody "work_tail" Source.outputBodyTokens = some Expressions.workTailBody.render := by decide +kernel

private theorem expression_fact_24 :
  Source.expressionBody "fits" Source.outputBodyTokens = some Expressions.fitsBody.render := by decide +kernel

private theorem expression_fact_25 :
  Source.expressionBody "comparison_at" Source.outputBodyTokens = some Expressions.comparisonBody.render := by decide +kernel

theorem actual_expressions : ExpressionTranslation := by
  exact ⟨Expressions.checked_precedence,
    Expressions.checked_scopes,
    expression_fact_03,
    expression_fact_04,
    expression_fact_05,
    expression_fact_06,
    expression_fact_07,
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
    expression_fact_25⟩

def allTokens : List ShellToken :=
  [.word "with", .word "silver_io", .word "procedure", .word "main", .word "is",
   .word "pragma", .word "spark_mode", .word "on", .word "begin", .word "put_line", .word "end",
   .symbol "(", .symbol ")", .symbol ";", .symbol ".", .literal,
   .symbol ":", .word "constant", .word "string", .symbol ":=",
   .word "silver_arguments", .word "first_or_default", .word "if", .word "input_is_valid",
   .word "then", .word "else", .word "reject", .symbol "&", .word "and", .symbol "'",
   .word "length", .symbol "<=", .capacity, .symbol "=", .argumentDeclaration,
   .declarations, .assignmentTarget, .targetReference, .dynamicReference,
   .assignmentValue, .outputExpression, .comparisonExpression, .word "null"]

def commaNames (names : List String) : List String := List.flatten ((names.map fun name => [name]).intersperse [","])

def quoted (text : String) : String :=
  String.ofList (['"'] ++ text.toList.flatMap (fun ch => if ch = '"' then ['"', '"'] else [ch]) ++ ['"'])

/-- Statements is a scanner nonterminal; all lexical/helper tokens retain
an exact named representation in the native enumeration. -/
def nativeTokenNames : List String := allTokens.map Expressions.tokenName ++ ["statements"]

def spellingBody : List String := ["case", "token", "is"] ++
  List.flatten (((allTokens.take 34 ++ [ShellToken.word "null"]).map fun token =>
    ["when", Expressions.tokenName token, "=>", quoted (Expressions.spelling token)]).intersperse [","]) ++
  [",", "when"] ++
  List.flatten ((((allTokens.drop 34).take 8).map Expressions.tokenName ++ ["statements"]).map
    (fun name => [name]) |>.intersperse ["|"]) ++ ["=>", quoted "_"]

def helperForms : List Form := [.direct, .argument, .guardedArgument]

abbrev HelperCatalogueTranslation : Prop :=
  typeDeclaration "form_kind" Source.outputSpecTokens =
    some (["("] ++ commaNames (helperForms.map Expressions.formName) ++ [")"]) ∧
  typeDeclaration "token_kind" Source.outputSpecTokens =
    some (["("] ++ commaNames nativeTokenNames ++ [")"]) ∧
  Source.expressionBody "spelling" Source.outputBodyTokens = some spellingBody ∧
  Source.expressionBody "is_word_token" Source.outputBodyTokens = some (expectedTokens
    "Token in With_Keyword .. End_Keyword | Constant_Keyword | String_Name | Arguments_Name | First_Or_Default_Name | If_Keyword | Input_Is_Valid_Name | Then_Keyword | Else_Keyword | Reject_Name | And_Keyword | Length_Name | Null_Keyword") ∧
  Source.expressionBody "is_argument_form" Source.outputSpecTokens =
    some (expectedTokens "Form in Argument_Form | Guarded_Argument_Form")

private theorem catalogue_forms :
  typeDeclaration "form_kind" Source.outputSpecTokens =
    some (["("] ++ commaNames (helperForms.map Expressions.formName) ++ [")"]) := by decide +kernel

private theorem catalogue_fact_01 :
  typeDeclaration "token_kind" Source.outputSpecTokens =
    some (["("] ++ commaNames nativeTokenNames ++ [")"]) := by decide +kernel

private theorem catalogue_fact_03 :
  Source.expressionBody "spelling" Source.outputBodyTokens = some spellingBody := by decide +kernel

private theorem catalogue_fact_05 :
  Source.expressionBody "is_word_token" Source.outputBodyTokens = some (expectedTokens
    "Token in With_Keyword .. End_Keyword | Constant_Keyword | String_Name | Arguments_Name | First_Or_Default_Name | If_Keyword | Input_Is_Valid_Name | Then_Keyword | Else_Keyword | Reject_Name | And_Keyword | Length_Name | Null_Keyword") := by decide +kernel

private theorem catalogue_fact_06 :
  Source.expressionBody "is_argument_form" Source.outputSpecTokens =
    some (expectedTokens "Form in Argument_Form | Guarded_Argument_Form") := by decide +kernel

theorem actual_catalogue : HelperCatalogueTranslation :=
  ⟨catalogue_forms, catalogue_fact_01, catalogue_fact_03, catalogue_fact_05, catalogue_fact_06⟩

theorem finite_mapping :
    (∀ token ∈ allTokens, 1 ≤ (Expressions.spelling token).length ∧ (Expressions.spelling token).length ≤ 16) ∧
    (∀ index : Fin allTokens.length, Expressions.isWord allTokens[index] =
      (decide (index.val ≤ 10) || decide (allTokens[index] ∈
        [.word "constant", .word "string", .word "silver_arguments", .word "first_or_default",
         .word "if", .word "input_is_valid", .word "then", .word "else", .word "reject",
         .word "and", .word "length", .word "null"]))) := by decide +kernel

abbrev Declarations : Prop :=
  Source.declaration "max_expression_operands" Source.outputSpecTokens = some (expectedTokens "constant positive := 16") ∧
  Source.declaration "max_bindings" Source.outputSpecTokens = some (expectedTokens "constant positive := max_source_length / 12") ∧
  maxExpressionOperands = 16 ∧
  maxBindings = maxSourceLength / 12 ∧
  Lexical.SourceBridge.subtypeDeclaration "binding_count" Source.outputBodyTokens = some (expectedTokens "natural range 0 .. max_bindings") ∧
  Lexical.SourceBridge.subtypeDeclaration "binding_index" Source.outputBodyTokens = some (expectedTokens "positive range 1 .. max_bindings") ∧
  Lexical.SourceBridge.subtypeDeclaration "operand_count" Source.outputBodyTokens = some (expectedTokens "natural range 0 .. max_expression_operands") ∧
  Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens = some (expectedTokens "positive range 1 .. 101") ∧
  Lexical.SourceBridge.recordDeclaration "binding_info" Source.outputBodyTokens = some (expectedTokens "record first , after , value_first : literal_position ; static_length : capacity_value ; dynamic , mutable : boolean ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "binding_environment" Source.outputBodyTokens = some (expectedTokens "record count : binding_count ; items : binding_array ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "parser_state" Source.outputBodyTokens = some (expectedTokens "record position : literal_position ; names : binding_environment ; dynamic_first , dynamic_after : literal_position ; target : binding_count ; capacity : capacity_value ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "value_result" Source.outputBodyTokens = some (expectedTokens "record after , value_first : literal_position ; static_length : capacity_value ; dynamic_seen : boolean ; reference : binding_count ; end record") ∧
  Lexical.SourceBridge.recordDeclaration "expression_result" Source.outputBodyTokens = some (expectedTokens "record after : literal_position ; static_length : capacity_value ; dynamic_count : operand_count ; named_seen : boolean ; end record") ∧
  typeDeclaration "binding_array" Source.outputBodyTokens = some (expectedTokens "array (Binding_Index) of Binding_Info") ∧
  Source.declaration "empty_binding" Source.outputBodyTokens = some (expectedTokens "constant binding_info := ( first => 0 , after => 0 , value_first => 0 , static_length => 0 , dynamic => false , mutable => false )") ∧
  Source.declaration "empty_environment" Source.outputBodyTokens = some (expectedTokens "constant binding_environment := ( count => 0 , items => ( others => empty_binding ) )") ∧
  Source.declaration "initial_state" Source.outputBodyTokens = some (expectedTokens "constant parser_state := ( position => 1 , names => empty_environment , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => max_source_length )") ∧
  Source.declaration "invalid_state" Source.outputBodyTokens = some (expectedTokens "constant parser_state := ( position => 0 , names => empty_environment , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => 0 )") ∧
  Source.declaration "invalid_value" Source.outputBodyTokens = some (expectedTokens "constant value_result := ( after => 0 , value_first => 0 , static_length => 0 , dynamic_seen => false , reference => 0 )") ∧
  Source.declaration "invalid_expression" Source.outputBodyTokens = some (expectedTokens "constant expression_result := ( after => 0 , static_length => 0 , dynamic_count => 0 , named_seen => false )") ∧
  Source.expressionBody "valid_names" Source.outputBodyTokens = some (expectedTokens "for all I in 1 .. Names.Count => Names.Items (I).First > 0 and then Valid_Name_State (Text, Names.Items (I).First, Names.Items (I).After) and then Names.Items (I).Value_First <= Text'Last + 1") ∧
  Source.expressionBody "valid_state" Source.outputBodyTokens = some (expectedTokens "State.Position <= Text'Last + 1 and then Valid_Names (Text, State.Names) and then Valid_Name_State (Text, State.Dynamic_First, State.Dynamic_After) and then State.Target <= State.Names.Count") ∧
  maxConcatenations = 30 ∧
  Lexical.SourceBridge.subtypeDeclaration "concatenation_count" Source.outputBodyTokens = some (expectedTokens "natural range 0 .. max_concatenations") ∧
  Source.declaration "max_concatenations" Source.outputSpecTokens = some (expectedTokens "constant positive := 30") ∧
  Lexical.SourceBridge.recordDeclaration "expression_state" Source.outputBodyTokens = some (expectedTokens "record position : literal_position ; static_length : capacity_value ; dynamic_count , operands : operand_count ; depth : literal_position ; named_seen , need_operand , complete : boolean ; end record") ∧
  Source.declaration "invalid_expression_state" Source.outputBodyTokens = some (expectedTokens "constant expression_state := ( position => 0 , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false )") ∧
  Source.expressionBody "valid_expression_state" Source.outputBodyTokens = some (expectedTokens "State.Position <= Text'Last + 1 and then State.Dynamic_Count <= State.Operands and then (State.Position = 0 or else State.Depth < State.Position)")

private theorem declaration_fact_01 :
  Source.declaration "max_expression_operands" Source.outputSpecTokens = some (expectedTokens "constant positive := 16") := by decide +kernel

private theorem declaration_fact_02 :
  Source.declaration "max_bindings" Source.outputSpecTokens = some (expectedTokens "constant positive := max_source_length / 12") := by decide +kernel

private theorem declaration_fact_03 :
  maxExpressionOperands = 16 := by decide +kernel

private theorem declaration_fact_04 :
  maxBindings = maxSourceLength / 12 := by decide +kernel

private theorem declaration_fact_05 :
  Lexical.SourceBridge.subtypeDeclaration "binding_count" Source.outputBodyTokens = some (expectedTokens "natural range 0 .. max_bindings") := by decide +kernel

private theorem declaration_fact_06 :
  Lexical.SourceBridge.subtypeDeclaration "binding_index" Source.outputBodyTokens = some (expectedTokens "positive range 1 .. max_bindings") := by decide +kernel

private theorem declaration_fact_07 :
  Lexical.SourceBridge.subtypeDeclaration "operand_count" Source.outputBodyTokens = some (expectedTokens "natural range 0 .. max_expression_operands") := by decide +kernel

private theorem declaration_fact_08 :
  Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens = some (expectedTokens "positive range 1 .. 101") := by decide +kernel

private theorem declaration_fact_09 :
  Lexical.SourceBridge.recordDeclaration "binding_info" Source.outputBodyTokens = some (expectedTokens "record first , after , value_first : literal_position ; static_length : capacity_value ; dynamic , mutable : boolean ; end record") := by decide +kernel

private theorem declaration_fact_10 :
  Lexical.SourceBridge.recordDeclaration "binding_environment" Source.outputBodyTokens = some (expectedTokens "record count : binding_count ; items : binding_array ; end record") := by decide +kernel

private theorem declaration_fact_11 :
  Lexical.SourceBridge.recordDeclaration "parser_state" Source.outputBodyTokens = some (expectedTokens "record position : literal_position ; names : binding_environment ; dynamic_first , dynamic_after : literal_position ; target : binding_count ; capacity : capacity_value ; end record") := by decide +kernel

private theorem declaration_fact_12 :
  Lexical.SourceBridge.recordDeclaration "value_result" Source.outputBodyTokens = some (expectedTokens "record after , value_first : literal_position ; static_length : capacity_value ; dynamic_seen : boolean ; reference : binding_count ; end record") := by decide +kernel

private theorem declaration_fact_13 :
  Lexical.SourceBridge.recordDeclaration "expression_result" Source.outputBodyTokens = some (expectedTokens "record after : literal_position ; static_length : capacity_value ; dynamic_count : operand_count ; named_seen : boolean ; end record") := by decide +kernel

private theorem declaration_fact_14 :
  typeDeclaration "binding_array" Source.outputBodyTokens = some (expectedTokens "array (Binding_Index) of Binding_Info") := by decide +kernel

private theorem declaration_fact_15 :
  Source.declaration "empty_binding" Source.outputBodyTokens = some (expectedTokens "constant binding_info := ( first => 0 , after => 0 , value_first => 0 , static_length => 0 , dynamic => false , mutable => false )") := by decide +kernel

private theorem declaration_fact_16 :
  Source.declaration "empty_environment" Source.outputBodyTokens = some (expectedTokens "constant binding_environment := ( count => 0 , items => ( others => empty_binding ) )") := by decide +kernel

private theorem declaration_fact_17 :
  Source.declaration "initial_state" Source.outputBodyTokens = some (expectedTokens "constant parser_state := ( position => 1 , names => empty_environment , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => max_source_length )") := by decide +kernel

private theorem declaration_fact_18 :
  Source.declaration "invalid_state" Source.outputBodyTokens = some (expectedTokens "constant parser_state := ( position => 0 , names => empty_environment , dynamic_first => 0 , dynamic_after => 0 , target => 0 , capacity => 0 )") := by decide +kernel

private theorem declaration_fact_19 :
  Source.declaration "invalid_value" Source.outputBodyTokens = some (expectedTokens "constant value_result := ( after => 0 , value_first => 0 , static_length => 0 , dynamic_seen => false , reference => 0 )") := by decide +kernel

private theorem declaration_fact_20 :
  Source.declaration "invalid_expression" Source.outputBodyTokens = some (expectedTokens "constant expression_result := ( after => 0 , static_length => 0 , dynamic_count => 0 , named_seen => false )") := by decide +kernel

private theorem declaration_fact_21 :
  Source.expressionBody "valid_names" Source.outputBodyTokens = some (expectedTokens "for all I in 1 .. Names.Count => Names.Items (I).First > 0 and then Valid_Name_State (Text, Names.Items (I).First, Names.Items (I).After) and then Names.Items (I).Value_First <= Text'Last + 1") := by decide +kernel

private theorem declaration_fact_22 :
  Source.expressionBody "valid_state" Source.outputBodyTokens = some (expectedTokens "State.Position <= Text'Last + 1 and then Valid_Names (Text, State.Names) and then Valid_Name_State (Text, State.Dynamic_First, State.Dynamic_After) and then State.Target <= State.Names.Count") := by decide +kernel

private theorem declaration_fact_23 :
  maxConcatenations = 30 := by decide +kernel

private theorem declaration_fact_24 :
  Lexical.SourceBridge.subtypeDeclaration "concatenation_count" Source.outputBodyTokens = some (expectedTokens "natural range 0 .. max_concatenations") := by decide +kernel

private theorem declaration_fact_25 :
  Source.declaration "max_concatenations" Source.outputSpecTokens = some (expectedTokens "constant positive := 30") := by decide +kernel

private theorem declaration_fact_26 :
  Lexical.SourceBridge.recordDeclaration "expression_state" Source.outputBodyTokens = some (expectedTokens "record position : literal_position ; static_length : capacity_value ; dynamic_count , operands : operand_count ; depth : literal_position ; named_seen , need_operand , complete : boolean ; end record") := by decide +kernel

private theorem declaration_fact_27 :
  Source.declaration "invalid_expression_state" Source.outputBodyTokens = some (expectedTokens "constant expression_state := ( position => 0 , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false )") := by decide +kernel

private theorem declaration_fact_28 :
  Source.expressionBody "valid_expression_state" Source.outputBodyTokens = some (expectedTokens "State.Position <= Text'Last + 1 and then State.Dynamic_Count <= State.Operands and then (State.Position = 0 or else State.Depth < State.Position)") := by decide +kernel

theorem actual_declarations : Declarations := by
  exact ⟨declaration_fact_01,
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
    declaration_fact_28⟩

abbrev Refinement : Prop :=
  functionHeader "skip_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => skip_at ' result <= text ' last + 1 and then ( skip_at ' result = ( if position = 0 then 0 else trivia_end ( text , position ) ) ) )") ∧
  functionHeader "name_after" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( name_after ' result = 0 or else name_after ' result in position + 1 .. text ' last + 1 ) and then ( name_after ' result = ( if position = 0 then 0 else identifier_end ( text , position ) ) ) )") ∧
  functionHeader "take_token" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; token : token_kind ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( take_token ' result = 0 or else take_token ' result in position + 1 .. text ' last + 1 ) and then ( take_token ' result = fixed_after ( text , position , token ) ) )") ∧
  functionHeader "lookup_name" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first <= text ' last + 1 and then after <= text ' last + 1 , post => ( static => lookup_name ' result <= names . count and then ( lookup_name ' result = ( if first = 0 or else after <= first then 0 else lookup_from ( text , names , first , after , 1 ) ) ) )") ∧
  functionHeader "literal_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = ( if position /= 0 and then position <= text ' last and then text ( position ) = character ' val ( 34 ) and then literal_end ( text , position + 1 ) /= 0 then ( after => literal_end ( text , position + 1 ) , value_first => position + 1 , static_length => literal_length ( text , position + 1 ) , dynamic_seen => false , reference => 0 ) else invalid_value ) ) )") ∧
  functionHeader "read_declarations" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , read_declarations ' result ) and then ( read_declarations ' result = declarations_at ( text , state , arguments ) ) )") ∧
  functionHeader "expression_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result = expression_tail ( text , names , ( position => position , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false ) ) ) )") ∧
  functionHeader "capacity_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , capacity_at ' result ) and then capacity_at ' result = ( if state . position = 0 then invalid_state elsif decimal_at ( text , trivia_end ( text , state . position ) ) . after = 0 then invalid_state else ( state with delta position => decimal_at ( text , trivia_end ( text , state . position ) ) . after , capacity => decimal_at ( text , trivia_end ( text , state . position ) ) . value ) ) )") ∧
  functionHeader "step" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; form : form_kind ; token : token_kind ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , step ' result )") ∧
  functionHeader "declaration_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , declaration_at ' result ) and then ( declaration_at ' result . position = 0 or else declaration_at ' result . position > state . position )") ∧
  functionHeader "argument_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , argument_at ' result )") ∧
  functionHeader "value_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) , post => value_at ' result . value_first <= text ' last + 1 and then value_at ' result . reference <= names . count and then ( value_at ' result . after = 0 or else value_at ' result . after in position + 1 .. text ' last + 1 )") ∧
  functionHeader "expression_step" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ) return expression_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then valid_expression_state ( text , state ) , post => valid_expression_state ( text , expression_step ' result ) and then ( expression_step ' result . position = 0 or else expression_step ' result . complete or else expression_step ' result . position > state . position )") ∧
  functionHeader "target_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; same_target : boolean ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , target_at ' result )") ∧
  functionHeader "dynamic_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , dynamic_at ' result )") ∧
  functionHeader "assignment_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , assignment_at ' result )") ∧
  functionHeader "output_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , output_at ' result )") ∧
  functionHeader "declarations_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , declarations_at ' result ) , subprogram_variant => ( decreases => ( text ' last + 1 ) - state . position )") ∧
  functionHeader "lookup_from" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; first , after : cursor ; index : positive ) return binding_count with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first < after and then after <= text ' last + 1 and then index <= names . count + 1 , post => lookup_from ' result <= names . count , subprogram_variant => ( increases => index )") ∧
  functionHeader "expression_tail" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ) return expression_result with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then valid_expression_state ( text , state ) , post => expression_tail ' result . after = 0 or else expression_tail ' result . after in state . position .. text ' last + 1 , subprogram_variant => ( decreases => ( text ' last + 1 ) - state . position )") ∧
  functionHeader "work_tail" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; remaining : concatenation_count ) return boolean with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , subprogram_variant => ( decreases => ( text ' last + 1 ) - position )") ∧
  functionHeader "within_work_budget" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length , post => ( static => within_work_budget ' result = work_tail ( text , 1 , max_concatenations ) )") ∧
  functionHeader "comparison_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , comparison_at ' result )") ∧
  functionHeader "fits" ";" Source.outputBodyTokens = some (expectedTokens "( value : expression_result ; capacity : capacity_value ) return boolean with global => null")

private theorem refinement_fact_05 :
  functionHeader "skip_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => skip_at ' result <= text ' last + 1 and then ( skip_at ' result = ( if position = 0 then 0 else trivia_end ( text , position ) ) ) )") := by decide +kernel

private theorem refinement_fact_06 :
  functionHeader "name_after" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( name_after ' result = 0 or else name_after ' result in position + 1 .. text ' last + 1 ) and then ( name_after ' result = ( if position = 0 then 0 else identifier_end ( text , position ) ) ) )") := by decide +kernel

private theorem refinement_fact_07 :
  functionHeader "take_token" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; token : token_kind ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( take_token ' result = 0 or else take_token ' result in position + 1 .. text ' last + 1 ) and then ( take_token ' result = fixed_after ( text , position , token ) ) )") := by decide +kernel

private theorem refinement_fact_08 :
  functionHeader "lookup_name" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first <= text ' last + 1 and then after <= text ' last + 1 , post => ( static => lookup_name ' result <= names . count and then ( lookup_name ' result = ( if first = 0 or else after <= first then 0 else lookup_from ( text , names , first , after , 1 ) ) ) )") := by decide +kernel

private theorem refinement_fact_09 :
  functionHeader "literal_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = ( if position /= 0 and then position <= text ' last and then text ( position ) = character ' val ( 34 ) and then literal_end ( text , position + 1 ) /= 0 then ( after => literal_end ( text , position + 1 ) , value_first => position + 1 , static_length => literal_length ( text , position + 1 ) , dynamic_seen => false , reference => 0 ) else invalid_value ) ) )") := by decide +kernel

private theorem refinement_fact_10 :
  functionHeader "read_declarations" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , read_declarations ' result ) and then ( read_declarations ' result = declarations_at ( text , state , arguments ) ) )") := by decide +kernel

private theorem refinement_fact_11 :
  functionHeader "expression_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result = expression_tail ( text , names , ( position => position , static_length => 0 , dynamic_count => 0 , operands => 0 , depth => 0 , named_seen => false , need_operand => true , complete => false ) ) ) )") := by decide +kernel

private theorem refinement_fact_12 :
  functionHeader "capacity_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , capacity_at ' result ) and then capacity_at ' result = ( if state . position = 0 then invalid_state elsif decimal_at ( text , trivia_end ( text , state . position ) ) . after = 0 then invalid_state else ( state with delta position => decimal_at ( text , trivia_end ( text , state . position ) ) . after , capacity => decimal_at ( text , trivia_end ( text , state . position ) ) . value ) ) )") := by decide +kernel

private theorem refinement_fact_13 :
  functionHeader "step" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; form : form_kind ; token : token_kind ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , step ' result )") := by decide +kernel

private theorem refinement_fact_14 :
  functionHeader "declaration_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , declaration_at ' result ) and then ( declaration_at ' result . position = 0 or else declaration_at ' result . position > state . position )") := by decide +kernel

private theorem refinement_fact_15 :
  functionHeader "argument_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , argument_at ' result )") := by decide +kernel

private theorem refinement_fact_16 :
  functionHeader "value_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) , post => value_at ' result . value_first <= text ' last + 1 and then value_at ' result . reference <= names . count and then ( value_at ' result . after = 0 or else value_at ' result . after in position + 1 .. text ' last + 1 )") := by decide +kernel

private theorem refinement_fact_17 :
  functionHeader "expression_step" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ) return expression_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then valid_expression_state ( text , state ) , post => valid_expression_state ( text , expression_step ' result ) and then ( expression_step ' result . position = 0 or else expression_step ' result . complete or else expression_step ' result . position > state . position )") := by decide +kernel

private theorem refinement_fact_18 :
  functionHeader "target_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; same_target : boolean ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , target_at ' result )") := by decide +kernel

private theorem refinement_fact_19 :
  functionHeader "dynamic_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , dynamic_at ' result )") := by decide +kernel

private theorem refinement_fact_20 :
  functionHeader "assignment_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , assignment_at ' result )") := by decide +kernel

private theorem refinement_fact_21 :
  functionHeader "output_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , output_at ' result )") := by decide +kernel

private theorem refinement_fact_22 :
  functionHeader "declarations_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ; arguments : boolean ) return parser_state with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , declarations_at ' result ) , subprogram_variant => ( decreases => ( text ' last + 1 ) - state . position )") := by decide +kernel

private theorem refinement_fact_23 :
  functionHeader "lookup_from" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; first , after : cursor ; index : positive ) return binding_count with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first < after and then after <= text ' last + 1 and then index <= names . count + 1 , post => lookup_from ' result <= names . count , subprogram_variant => ( increases => index )") := by decide +kernel

private theorem refinement_fact_24 :
  functionHeader "expression_tail" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; names : binding_environment ; state : expression_state ) return expression_result with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then valid_expression_state ( text , state ) , post => expression_tail ' result . after = 0 or else expression_tail ' result . after in state . position .. text ' last + 1 , subprogram_variant => ( decreases => ( text ' last + 1 ) - state . position )") := by decide +kernel

private theorem refinement_fact_26 :
  functionHeader "work_tail" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; position : literal_position ; remaining : concatenation_count ) return boolean with ghost => static , global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , subprogram_variant => ( decreases => ( text ' last + 1 ) - position )") := by decide +kernel

private theorem refinement_fact_27 :
  functionHeader "within_work_budget" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length , post => ( static => within_work_budget ' result = work_tail ( text , 1 , max_concatenations ) )") := by decide +kernel

private theorem refinement_fact_28 :
  functionHeader "comparison_at" ";" Source.outputBodyTokens = some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => valid_state ( text , comparison_at ' result )") := by decide +kernel

private theorem refinement_fact_29 :
  functionHeader "fits" ";" Source.outputBodyTokens = some (expectedTokens "( value : expression_result ; capacity : capacity_value ) return boolean with global => null") := by decide +kernel

theorem actual_refinement : Refinement := by
  exact ⟨refinement_fact_05,
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
    refinement_fact_29⟩

/-- Functional adapter postconditions contain these exact interpreted trees.
This connects imperative lexical/loop adapters to their equations rather than
merely pinning a matching header string. -/
abbrev AdapterTranslation : Prop :=
  functionHeader "skip_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => skip_at ' result <= text ' last + 1 and then ( skip_at ' result = (" ++
      Expressions.skipBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "name_after" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( name_after ' result = 0 or else name_after ' result in position + 1 .. text ' last + 1 ) and then ( name_after ' result = (" ++
      Expressions.nameBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "lookup_name" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first <= text ' last + 1 and then after <= text ' last + 1 , post => ( static => lookup_name ' result <= names . count and then ( lookup_name ' result = (" ++
      Expressions.lookupBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "literal_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = (" ++
      Expressions.literalBody.render ++ expectedTokens ") ) )") ∧
  functionHeader "expression_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result =" ++
      Expressions.expressionBody.render ++ expectedTokens ") )") ∧
  functionHeader "capacity_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , capacity_at ' result ) and then capacity_at ' result = (" ++
      Expressions.capacityBody.render ++ expectedTokens ") )") ∧
  functionHeader "within_work_budget" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length , post => ( static => within_work_budget ' result =" ++
      Expressions.workBudgetBody.render ++ expectedTokens ")")

private theorem adapter_fact_01 :
  functionHeader "skip_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => skip_at ' result <= text ' last + 1 and then ( skip_at ' result = (" ++
      Expressions.skipBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_02 :
  functionHeader "name_after" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return literal_position with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => ( name_after ' result = 0 or else name_after ' result in position + 1 .. text ' last + 1 ) and then ( name_after ' result = (" ++
      Expressions.nameBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_03 :
  functionHeader "lookup_name" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; names : binding_environment ; first , after : literal_position ) return binding_count with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_names ( text , names ) and then first <= text ' last + 1 and then after <= text ' last + 1 , post => ( static => lookup_name ' result <= names . count and then ( lookup_name ' result = (" ++
      Expressions.lookupBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_04 :
  functionHeader "literal_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ) return value_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 , post => ( static => literal_at ' result . value_first <= text ' last + 1 and then ( literal_at ' result . after = 0 or else literal_at ' result . after in position + 1 .. text ' last + 1 ) and then not literal_at ' result . dynamic_seen and then literal_at ' result . reference = 0 and then ( literal_at ' result = (" ++
      Expressions.literalBody.render ++ expectedTokens ") ) )") := by decide +kernel

private theorem adapter_fact_05 :
  functionHeader "expression_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; position : literal_position ; names : binding_environment ) return expression_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then position <= text ' last + 1 and then valid_names ( text , names ) , post => ( static => ( expression_at ' result . after = 0 or else expression_at ' result . after in position + 1 .. text ' last + 1 ) and then ( expression_at ' result =" ++
      Expressions.expressionBody.render ++ expectedTokens ") )") := by decide +kernel

private theorem adapter_fact_06 :
  functionHeader "capacity_at" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ; state : parser_state ) return parser_state with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , state ) , post => ( static => valid_state ( text , capacity_at ' result ) and then capacity_at ' result = (" ++
      Expressions.capacityBody.render ++ expectedTokens ") )") := by decide +kernel

private theorem adapter_fact_07 :
  functionHeader "within_work_budget" ";" Source.outputBodyTokens =
    some (expectedTokens "( text : string ) return boolean with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length , post => ( static => within_work_budget ' result =" ++
      Expressions.workBudgetBody.render ++ expectedTokens ")") := by decide +kernel

theorem actual_adapters : AdapterTranslation := by
  exact ⟨adapter_fact_01,
    adapter_fact_02,
    adapter_fact_03,
    adapter_fact_04,
    adapter_fact_05,
    adapter_fact_06,
    adapter_fact_07⟩

end Silver.Compose.SourceBridge
