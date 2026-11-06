module

public import Silver.PredicateNativeSourceChecks
public import Silver.PredicateBasicSourceCandidate
public import Silver.PredicateBooleanBodySource
public import Silver.BooleanBindingsSourceChecks
public import Silver.PredicateXorSourceBridge
public import Silver.PredicateScalarBodySource
public import Silver.PredicateArrayBodySource
public import Silver.PredicateCountedBoundSource
public import Silver.PredicateBodyWrappers
public import Silver.PredicateBodyCandidates
public import Silver.PredicateLoopCandidate
public import Silver.PredicateAdapterSourceCandidate
public import Silver.PredicateAdapterEnvironment
public import Silver.PredicateOuterCandidates
public import Silver.PredicateSourceShape

@[expose] public section

/-! Complete syntactic source requirements for the predicate/path scanner.
Typed body rendering, native contracts and representation declarations are
checked separately. Semantic interpretation also requires the frontend and
GNATprove premises stated by the source bridge, including verified legality of
executed calls when domain-bounded helpers are mathematically totalized. -/
namespace Silver.Predicate.SourceChecks
open Silver.SourceBridge

/-- Read a complete implementation through its named terminator. -/
def throughEnd (name : String) : List String → Option (List String)
  | [] => none
  | "end" :: actual :: ";" :: rest =>
      if actual == name then some ["end", actual, ";"]
      else (throughEnd name (actual :: ";" :: rest)).map ("end" :: ·)
  | token :: rest => (throughEnd name rest).map (token :: ·)

def ordinaryFunctions (name : String) : List String → List (List String)
  | [] => []
  | "function" :: actual :: tokens =>
      let later := ordinaryFunctions name (actual :: tokens)
      if actual == name then
        match headerEnd 0 tokens with
        | some (header, "is") =>
            match throughEnd name (tokens.drop (header.length + 1)) with
            | some body => body :: later
            | none => later
        | _ => later
      else later
  | _ :: tokens => ordinaryFunctions name tokens

/-- Unique complete function body; forward declarations are excluded. -/
def ordinaryFunction (name : String) (tokens : List String) : Option (List String) :=
  match ordinaryFunctions name tokens with
  | [body] => some body
  | _ => none


def spec_tokens_spec_header : List String :=
  ["(", "form", ":", "form_kind", ")", "return", "token_sequence", "with", "global", "=>", "null", ",", "post", "=>", "tokens", "'", "result", "'", "first", "=", "1", "and", "then", "tokens", "'", "result", "'", "length", "in", "1", "..", "100"]

def spec_is_member_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "ghost", "=>", "static", ",", "global", "=>", "null"]

def spec_has_arguments_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "ghost", "=>", "static", ",", "global", "=>", "null"]

def spec_has_assignment_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "ghost", "=>", "static", ",", "global", "=>", "null"]

def spec_has_output_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "ghost", "=>", "static", ",", "global", "=>", "null"]

def spec_accepts_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "accepts", "'", "result", "=", "is_member", "(", "source", ")", ")"]

def spec_uses_arguments_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "uses_arguments", "'", "result", "=", "has_arguments", "(", "source", ")", ")"]

def spec_uses_assignment_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "uses_assignment", "'", "result", "=", "has_assignment", "(", "source", ")", ")"]

def spec_uses_output_spec_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "uses_output", "'", "result", "=", "has_output", "(", "source", ")", ")"]

def spec_spelling_spec_header : List String :=
  ["(", "token", ":", "token_kind", ")", "return", "string", "with", "global", "=>", "null", ",", "post", "=>", "spelling", "'", "result", "'", "first", "=", "1", "and", "then", "spelling", "'", "result", "'", "length", "in", "1", "..", "16"]

def spec_is_word_token_spec_header : List String :=
  ["(", "token", ":", "token_kind", ")", "return", "boolean", "with", "global", "=>", "null", ",", "post", "=>", "is_word_token", "'", "result", "=", "(", "token_kind", "'", "pos", "(", "token", ")", "in", "0", "..", "10", "or", "else", "token", "in", "constant_keyword", "|", "string_name", "|", "arguments_name", "|", "first_or_default_name", "|", "if_keyword", "|", "input_is_valid_name", "|", "then_keyword", "|", "else_keyword", "|", "elsif_keyword", "|", "reject_name", "|", "and_keyword", "|", "length_name", "|", "or_keyword", "|", "not_keyword", "|", "null_keyword", "|", "integer_name", "|", "for_keyword", "|", "in_keyword", "|", "reverse_keyword", "|", "loop_keyword", "|", "range_keyword", "|", "array_keyword", "|", "of_keyword", "|", "subtype_keyword", "|", "boolean_name", "|", "true_name", "|", "false_name", "|", "xor_keyword", "|", "character_name", ")"]

def spec_is_argument_form_impl_header : List String :=
  ["(", "form", ":", "form_kind", ")", "return", "boolean"]

def body_basic_body_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", ",", "post", "=>", "valid_body", "(", "text", ",", "context", ",", "basic_body", "'", "result", ")", "and", "then", "(", "basic_body", "'", "result", ".", "position", "=", "0", "or", "else", "basic_body", "'", "result", ".", "position", ">", "scan", ".", "position", ")"]

def body_basic_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan"]

def body_statement_body_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", ",", "post", "=>", "valid_body", "(", "text", ",", "context", ",", "statement_body", "'", "result", ")", "and", "then", "(", "statement_body", "'", "result", ".", "position", "=", "0", "or", "else", "statement_body", "'", "result", ".", "position", ">", "scan", ".", "position", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "scan", ".", "position", ",", "decreases", "=>", "2", ")"]

def body_statement_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan"]

def body_loop_body_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", ",", "post", "=>", "valid_body", "(", "text", ",", "context", ",", "loop_body", "'", "result", ")", "and", "then", "(", "loop_body", "'", "result", ".", "position", "=", "0", "or", "else", "loop_body", "'", "result", ".", "position", ">", "scan", ".", "position", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "scan", ".", "position", ",", "decreases", "=>", "1", ")"]

def body_loop_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan"]

def body_conditional_body_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", ",", "post", "=>", "valid_body", "(", "text", ",", "context", ",", "conditional_body", "'", "result", ")", "and", "then", "(", "conditional_body", "'", "result", ".", "position", "=", "0", "or", "else", "conditional_body", "'", "result", ".", "position", ">", "scan", ".", "position", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "scan", ".", "position", ",", "decreases", "=>", "1", ")"]

def body_conditional_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan"]

def body_alternative_body_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", ",", "post", "=>", "valid_body", "(", "text", ",", "context", ",", "alternative_body", "'", "result", ")", "and", "then", "(", "alternative_body", "'", "result", ".", "position", "=", "0", "or", "else", "alternative_body", "'", "result", ".", "position", ">=", "scan", ".", "position", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "scan", ".", "position", ",", "decreases", "=>", "1", ")"]

def body_alternative_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan"]

def body_body_tail_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop) return Body_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => (Runtime => Valid_Body (Text, Context, Body_Tail'Result) and then (Body_Tail'Result.Position = 0 or else Body_Tail'Result.Position >= Scan.Position), Static => Body_Tail'Result =").getD [] ++
  (BodyNative.ScanExpr.tailModel .current .input).render ++ (Source.lexLine ") , Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 4)").getD []

def body_body_tail_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ";", "stop", ":", "body_stop", ")", "return", "body_scan"]

def body_read_body_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop) return Body_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => (Runtime => Valid_Body (Text, Context, Read_Body'Result) and then (Read_Body'Result.Position = 0 or else Read_Body'Result.Position > Scan.Position), Static => Read_Body'Result =").getD [] ++
  BodyNative.readContractBody.render ++ (Source.lexLine ") , Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3)").getD []

def body_read_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ";", "stop", ":", "body_stop", ")", "return", "body_scan"]

def body_context_of_impl_header : List String :=
  ["(", "scan", ":", "scan_result", ")", "return", "body_context"]

def body_body_of_impl_header : List String :=
  ["(", "scan", ":", "scan_result", ")", "return", "body_scan"]

def body_expand_body_impl_header : List String :=
  ["(", "context", ":", "body_context", ";", "scan", ":", "body_scan", ";", "arrays", ":", "array_bindings", ".", "environment", ";", "subtypes", ":", "subtype_environment", ")", "return", "scan_result"]

def body_body_token_spec_header : List String :=
  Adapter.Wrappers.tokenSpec

def body_body_token_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ";", "token", ":", "token_kind", ")", "return", "body_scan"]

def body_at_body_stop_spec_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "stop", ":", "body_stop", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1"]

def body_at_body_stop_impl_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "stop", ":", "body_stop", ")", "return", "boolean"]

def body_read_statements_spec_header : List String :=
  ["(", "text", ":", "string", ";", "scan", ":", "scan_result", ";", "stop", ":", "token_kind", ")", "return", "scan_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "scan", ".", "state", ")", "and", "then", "stop", "in", "else_keyword", "|", "end_keyword", ",", "post", "=>", "valid_state", "(", "text", ",", "read_statements", "'", "result", ".", "state", ")"]

def body_read_statements_impl_header : List String :=
  ["(", "text", ":", "string", ";", "scan", ":", "scan_result", ";", "stop", ":", "token_kind", ")", "return", "scan_result"]

def body_tokens_impl_header : List String :=
  ["(", "form", ":", "form_kind", ")", "return", "token_sequence"]

def body_scan_step_spec_header : List String :=
  ["(", "text", ":", "string", ";", "form", ":", "form_kind", ";", "token", ":", "token_kind", ";", "scan", ":", "scan_result", ")", "return", "scan_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "scan", ".", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "scan_step", "'", "result", ".", "state", ")"]

def body_scan_step_impl_header : List String :=
  ["(", "text", ":", "string", ";", "form", ":", "form_kind", ";", "token", ":", "token_kind", ";", "scan", ":", "scan_result", ")", "return", "scan_result"]

def body_scan_suffix_spec_header : List String :=
  ["(", "text", ":", "string", ";", "form", ":", "form_kind", ";", "next_token", ":", "token_index", ";", "scan", ":", "scan_result", ")", "return", "scan_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "scan", ".", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "scan_suffix", "'", "result", ".", "state", ")", ",", "subprogram_variant", "=>", "(", "increases", "=>", "next_token", ")"]

def body_scan_suffix_impl_header : List String :=
  ["(", "text", ":", "string", ";", "form", ":", "form_kind", ";", "next_token", ":", "token_index", ";", "scan", ":", "scan_result", ")", "return", "scan_result"]

def body_form_result_spec_header : List String :=
  ["(", "source", ":", "string", ";", "form", ":", "form_kind", ")", "return", "scan_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null"]

def body_form_result_impl_header : List String :=
  ["(", "source", ":", "string", ";", "form", ":", "form_kind", ")", "return", "scan_result"]

def body_is_member_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_has_arguments_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_has_assignment_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_has_output_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_read_form_spec_header : List String :=
  ["(", "source", ":", "string", ";", "form", ":", "form_kind", ")", "return", "scan_result", "with", "global", "=>", "null", ",", "post", "=>", "(", "static", "=>", "read_form", "'", "result", "=", "form_result", "(", "source", ",", "form", ")", ")"]

def body_read_form_impl_header : List String :=
  ["(", "source", ":", "string", ";", "form", ":", "form_kind", ")", "return", "scan_result"]

def body_valid_context_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length"]

def body_valid_context_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ")", "return", "boolean"]

def body_valid_body_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length"]

def body_valid_body_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "boolean"]

def body_accepts_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_uses_arguments_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_uses_assignment_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_uses_output_impl_header : List String :=
  ["(", "source", ":", "string", ")", "return", "boolean"]

def body_spelling_impl_header : List String :=
  ["(", "token", ":", "token_kind", ")", "return", "string"]

def body_is_word_token_impl_header : List String :=
  ["(", "token", ":", "token_kind", ")", "return", "boolean"]

def scan_result_declaration : List String :=
  ["record", "state", ":", "parser_state", ";", "assigned", ",", "output", ":", "boolean", ";", "end", "record"]

def body_context_declaration : List String :=
  (Source.lexLine "record Names : Binding_Environment; Scalar_Names : Scalar_Expressions.Environment; Array_Names : Array_Bindings.Metadata; Subtype_Hiding : Subtype_Visibility; Boolean_Names : Boolean_Environment; True_Hidden, False_Hidden, Elaborating : Boolean; Mask_First, Mask_After : Literal_Position; Declaration_Count : Scalar_Expressions.Binding_Count; Dynamic_First, Dynamic_After : Literal_Position; end record").getD []

def body_scan_declaration : List String :=
  (Source.lexLine "(Count : Scalar_Expressions.Binding_Count) is record Facts : Scalar_Flow (Count); Position : Literal_Position; Target : Binding_Count; Capacity : Capacity_Value; Assigned, Output : Boolean; end record").getD []

def body_stop_declaration : List String :=
  ["(", "end_only", ",", "else_only", ",", "arm_boundary", ")"]

def form_kind_declaration : List String :=
  ["(", "direct_form", ",", "argument_form", ")"]

def token_kind_declaration : List String :=
  ["(", "with_keyword", ",", "io_name", ",", "procedure_keyword", ",", "main_name", ",", "is_keyword", ",", "pragma_keyword", ",", "spark_mode_name", ",", "on_name", ",", "begin_keyword", ",", "put_line_name", ",", "end_keyword", ",", "left_parenthesis", ",", "right_parenthesis", ",", "semicolon", ",", "dot", ",", "string_literal", ",", "colon", ",", "constant_keyword", ",", "string_name", ",", "assignment", ",", "arguments_name", ",", "first_or_default_name", ",", "if_keyword", ",", "input_is_valid_name", ",", "then_keyword", ",", "else_keyword", ",", "elsif_keyword", ",", "reject_name", ",", "ampersand", ",", "and_keyword", ",", "or_keyword", ",", "not_keyword", ",", "not_equal", ",", "less", ",", "greater", ",", "greater_equal", ",", "apostrophe", ",", "length_name", ",", "less_equal", ",", "capacity_literal", ",", "equal", ",", "argument_declaration", ",", "declarations", ",", "assignment_target", ",", "target_reference", ",", "dynamic_reference", ",", "assignment_value", ",", "output_expression", ",", "comparison_expression", ",", "null_keyword", ",", "statements", ",", "context_clauses", ",", "integer_name", ",", "for_keyword", ",", "in_keyword", ",", "reverse_keyword", ",", "loop_keyword", ",", "range_delimiter", ",", "range_keyword", ",", "array_keyword", ",", "of_keyword", ",", "comma", ",", "arrow", ",", "subtype_keyword", ",", "boolean_name", ",", "true_name", ",", "false_name", ",", "xor_keyword", ",", "character_name", ")"]

def token_sequence_declaration : List String :=
  ["array", "(", "positive", "range", "<", ">", ")", "of", "token_kind"]

def initial_scan_declaration : List String :=
  ["constant", "scan_result", ":=", "(", "state", "=>", "initial_state", ",", "assigned", "=>", "false", ",", "output", "=>", "false", ")"]

def invalid_scan_declaration : List String :=
  ["constant", "scan_result", ":=", "(", "state", "=>", "invalid_state", ",", "assigned", "=>", "false", ",", "output", "=>", "false", ")"]

def max_source_length_declaration : List String :=
  ["constant", "positive", ":=", "4_096"]

def max_expression_operands_declaration : List String :=
  ["constant", "positive", ":=", "64"]

def max_concatenations_declaration : List String :=
  ["constant", "positive", ":=", "63"]

def max_bindings_declaration : List String :=
  ["constant", "positive", ":=", "max_source_length", "/", "12"]

def token_index_declaration : List String :=
  ["positive", "range", "1", "..", "101"]

def binding_count_declaration : List String :=
  ["natural", "range", "0", "..", "max_bindings"]

def binding_index_declaration : List String :=
  ["positive", "range", "1", "..", "max_bindings"]

def operand_count_declaration : List String :=
  ["natural", "range", "0", "..", "max_expression_operands"]

def concatenation_count_declaration : List String :=
  ["natural", "range", "0", "..", "max_concatenations"]

def valid_context_expression : List String :=
  (Source.lexLine "Valid_Names (Text, Context.Names) and then Scalar_Expressions.Valid_Environment (Text, Context.Scalar_Names) and then Array_Bindings.Valid_Metadata (Text, Context.Array_Names) and then Valid_Booleans (Text, Context.Boolean_Names) and then Valid_Name_State (Text, Context.Mask_First, Context.Mask_After) and then Valid_Declaration_Values (Context.Scalar_Names, Context.Declaration_Count) and then Valid_Mutable_Bounds (Context.Scalar_Names) and then (for all Index in 1 .. Context.Scalar_Names.Count => (if Context.Scalar_Names.Items (Index).Mutable and then not Context.Elaborating then Context.Scalar_Names.Items (Index).Bounds = Context.Scalar_Names.Items (Index).Declared_Bounds)) and then Valid_Name_State (Text, Context.Dynamic_First, Context.Dynamic_After)").getD []

def valid_body_expression : List String :=
  (Source.lexLine "Scan.Position <= Text'Last + 1 and then Scan.Target <= Context.Names.Count and then Valid_Flow (Context, Scan.Facts)").getD []

def body_body_tail_model_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop) return Body_Scan with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => Valid_Body (Text, Context, Body_Tail_Model'Result) and then (Body_Tail_Model'Result.Position = 0 or else Body_Tail_Model'Result.Position >= Scan.Position), Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3)").getD []

def valid_flow_expression : List String :=
  (Source.lexLine "Facts.Count = Context.Scalar_Names.Count and then (for all Index in Facts.Values'Range => (if Context.Scalar_Names.Items (Index).Mutable then not Scalars.Is_Empty (Facts.Values (Index)) and then Included (Facts.Values (Index), Context.Scalar_Names.Items (Index).Declared_Bounds) elsif Index > Context.Declaration_Count then Included (Facts.Values (Index), Context.Scalar_Names.Items (Index).Bounds) else Facts.Values (Index) = Context.Scalar_Names.Items (Index).Bounds))").getD []

def included_expression : List String :=
  (Source.lexLine "Scalars.Is_Empty (Value) or else (not Scalars.Is_Empty (Bounds) and then Value.Lower >= Bounds.Lower and then Value.Upper <= Bounds.Upper)").getD []

def string_target_declaration : List String :=
  (Source.lexLine "record After : Literal_Position; Target : Binding_Count; end record").getD []

def lemma_joined_flow_header : List String :=
  (Source.lexLine "(Context : Body_Context; Left, Right : Scalar_Flow)").getD []

/-- This exact Static helper is the only ghost call attached to the rendered
save/join compound. Its verified precondition covers declaration nonemptiness
and both incoming flows; its postcondition covers the joined flow. -/
def lemma_joined_flow_spec : List String :=
  lemma_joined_flow_header ++ (Source.lexLine "with Ghost => Static, Global => null, Pre => Valid_Declaration_Values (Context.Scalar_Names, Context.Declaration_Count) and then Valid_Flow (Context, Left) and then Valid_Flow (Context, Right), Post => Valid_Flow (Context, Joined (Left, Right))").getD []

structure Checked (specTokens bodyTokens : List String) : Prop where
  spec_shape : specTokens = SourceShape.specTokens
  body_shape : bodyTokens = SourceShape.bodyTokens
  native : NativeSourceChecks.Checked bodyTokens
  booleanBindings : BooleanBindings.SourceChecks.Checked bodyTokens
  xorScanner : XorSourceBridge.Checked bodyTokens
  booleanBodies : BooleanBodyNative.SourceChecks.Checked bodyTokens
  scalarBodies : ScalarBodyNative.SourceChecks.Checked bodyTokens
  array_helpers : ArrayBodyNative.SourceChecks.Checked bodyTokens
  counted_bound : CountedBoundNative.Checked bodyTokens
  bodyWrappers : BodyWrappers.Checked bodyTokens
  adapterWrappers : Adapter.Wrappers.Checked bodyTokens
  lemma_joined_flow_spec : procedureHeader "lemma_joined_flow" ";" bodyTokens = some lemma_joined_flow_spec
  lemma_joined_flow_impl : procedureHeader "lemma_joined_flow" "is" bodyTokens = some lemma_joined_flow_header
  basic_body_body : ordinaryFunction "basic_body" bodyTokens = some (BasicNative.basicRender)
  statement_body_body : Source.expressionBody "statement_body" bodyTokens = some (BodyNative.statementRender)
  loop_body_body : ordinaryFunction "loop_body" bodyTokens = some LoopNative.render
  conditional_body_body : ordinaryFunction "conditional_body" bodyTokens = some (BodyNative.conditionalFunction.render "conditional_body")
  alternative_body_body : ordinaryFunction "alternative_body" bodyTokens = some (BodyNative.alternativeFunction.render "alternative_body")
  body_tail_model_body : Source.expressionBody "body_tail_model" bodyTokens = some BodyNative.tailModelBody.render
  body_tail_model_spec : functionHeader "body_tail_model" ";" bodyTokens = some body_body_tail_model_spec_header
  body_tail_model_impl : functionHeader "body_tail_model" "is" bodyTokens = some body_body_tail_impl_header
  read_body_body : ordinaryFunction "read_body" bodyTokens = some (BodyNative.readFunction.render "read_body")
  context_of_body : Source.expressionBody "context_of" bodyTokens = some ((Adapter.contextExpr.render).drop 1).dropLast
  expand_body_body : Source.expressionBody "expand_body" bodyTokens = some ((Adapter.expandExpr.render).drop 1).dropLast
  at_body_stop_body : Source.expressionBody "at_body_stop" bodyTokens = some ((Adapter.atStopExpr.render).drop 1).dropLast
  read_statements_body : ordinaryFunction "read_statements" bodyTokens = some (Adapter.adapterFunction.render)
  tokens_body : Source.expressionBody "tokens" bodyTokens = some (Outer.tokensBody)
  scan_step_body : Source.expressionBody "scan_step" bodyTokens = some (Outer.scanStepBody.render)
  scan_suffix_body : Source.expressionBody "scan_suffix" bodyTokens = some (Outer.suffixBody.render)
  form_result_body : Source.expressionBody "form_result" bodyTokens = some (Outer.formBody.render)
  is_member_body : Source.expressionBody "is_member" bodyTokens = some (Outer.memberBody.render)
  has_arguments_body : Source.expressionBody "has_arguments" bodyTokens = some (Outer.argumentsBody.render)
  has_assignment_body : Source.expressionBody "has_assignment" bodyTokens = some (Outer.assignmentBody.render)
  has_output_body : Source.expressionBody "has_output" bodyTokens = some (Outer.outputBody.render)
  spec_tokens_spec_header : functionHeader "tokens" ";" specTokens = some spec_tokens_spec_header
  spec_is_member_spec_header : functionHeader "is_member" ";" specTokens = some spec_is_member_spec_header
  spec_has_arguments_spec_header : functionHeader "has_arguments" ";" specTokens = some spec_has_arguments_spec_header
  spec_has_assignment_spec_header : functionHeader "has_assignment" ";" specTokens = some spec_has_assignment_spec_header
  spec_has_output_spec_header : functionHeader "has_output" ";" specTokens = some spec_has_output_spec_header
  spec_accepts_spec_header : functionHeader "accepts" ";" specTokens = some spec_accepts_spec_header
  spec_uses_arguments_spec_header : functionHeader "uses_arguments" ";" specTokens = some spec_uses_arguments_spec_header
  spec_uses_assignment_spec_header : functionHeader "uses_assignment" ";" specTokens = some spec_uses_assignment_spec_header
  spec_uses_output_spec_header : functionHeader "uses_output" ";" specTokens = some spec_uses_output_spec_header
  spec_spelling_spec_header : functionHeader "spelling" ";" specTokens = some spec_spelling_spec_header
  spec_is_word_token_spec_header : functionHeader "is_word_token" ";" specTokens = some spec_is_word_token_spec_header
  spec_is_argument_form_impl_header : functionHeader "is_argument_form" "is" specTokens = some spec_is_argument_form_impl_header
  body_basic_body_spec_header : functionHeader "basic_body" ";" bodyTokens = some body_basic_body_spec_header
  body_basic_body_impl_header : functionHeader "basic_body" "is" bodyTokens = some body_basic_body_impl_header
  body_statement_body_spec_header : functionHeader "statement_body" ";" bodyTokens = some body_statement_body_spec_header
  body_statement_body_impl_header : functionHeader "statement_body" "is" bodyTokens = some body_statement_body_impl_header
  body_loop_body_spec_header : functionHeader "loop_body" ";" bodyTokens = some body_loop_body_spec_header
  body_loop_body_impl_header : functionHeader "loop_body" "is" bodyTokens = some body_loop_body_impl_header
  body_conditional_body_spec_header : functionHeader "conditional_body" ";" bodyTokens = some body_conditional_body_spec_header
  body_conditional_body_impl_header : functionHeader "conditional_body" "is" bodyTokens = some body_conditional_body_impl_header
  body_alternative_body_spec_header : functionHeader "alternative_body" ";" bodyTokens = some body_alternative_body_spec_header
  body_alternative_body_impl_header : functionHeader "alternative_body" "is" bodyTokens = some body_alternative_body_impl_header
  body_body_tail_spec_header : functionHeader "body_tail" ";" bodyTokens = some body_body_tail_spec_header
  body_body_tail_impl_header : functionHeader "body_tail" "is" bodyTokens = some body_body_tail_impl_header
  body_read_body_spec_header : functionHeader "read_body" ";" bodyTokens = some body_read_body_spec_header
  body_read_body_impl_header : functionHeader "read_body" "is" bodyTokens = some body_read_body_impl_header
  body_context_of_impl_header : functionHeader "context_of" "is" bodyTokens = some body_context_of_impl_header
  body_body_of_impl_header : functionHeader "body_of" "is" bodyTokens = some body_body_of_impl_header
  body_expand_body_impl_header : functionHeader "expand_body" "is" bodyTokens = some body_expand_body_impl_header
  body_body_token_spec_header : functionHeader "body_token" ";" bodyTokens = some body_body_token_spec_header
  body_body_token_impl_header : functionHeader "body_token" "is" bodyTokens = some body_body_token_impl_header
  body_at_body_stop_spec_header : functionHeader "at_body_stop" ";" bodyTokens = some body_at_body_stop_spec_header
  body_at_body_stop_impl_header : functionHeader "at_body_stop" "is" bodyTokens = some body_at_body_stop_impl_header
  body_read_statements_spec_header : functionHeader "read_statements" ";" bodyTokens = some body_read_statements_spec_header
  body_read_statements_impl_header : functionHeader "read_statements" "is" bodyTokens = some body_read_statements_impl_header
  body_tokens_impl_header : functionHeader "tokens" "is" bodyTokens = some body_tokens_impl_header
  body_scan_step_spec_header : functionHeader "scan_step" ";" bodyTokens = some body_scan_step_spec_header
  body_scan_step_impl_header : functionHeader "scan_step" "is" bodyTokens = some body_scan_step_impl_header
  body_scan_suffix_spec_header : functionHeader "scan_suffix" ";" bodyTokens = some body_scan_suffix_spec_header
  body_scan_suffix_impl_header : functionHeader "scan_suffix" "is" bodyTokens = some body_scan_suffix_impl_header
  body_form_result_spec_header : functionHeader "form_result" ";" bodyTokens = some body_form_result_spec_header
  body_form_result_impl_header : functionHeader "form_result" "is" bodyTokens = some body_form_result_impl_header
  body_is_member_impl_header : functionHeader "is_member" "is" bodyTokens = some body_is_member_impl_header
  body_has_arguments_impl_header : functionHeader "has_arguments" "is" bodyTokens = some body_has_arguments_impl_header
  body_has_assignment_impl_header : functionHeader "has_assignment" "is" bodyTokens = some body_has_assignment_impl_header
  body_has_output_impl_header : functionHeader "has_output" "is" bodyTokens = some body_has_output_impl_header
  body_read_form_spec_header : functionHeader "read_form" ";" bodyTokens = some body_read_form_spec_header
  body_read_form_impl_header : functionHeader "read_form" "is" bodyTokens = some body_read_form_impl_header
  body_valid_context_spec_header : functionHeader "valid_context" ";" bodyTokens = some body_valid_context_spec_header
  body_valid_context_impl_header : functionHeader "valid_context" "is" bodyTokens = some body_valid_context_impl_header
  body_valid_body_spec_header : functionHeader "valid_body" ";" bodyTokens = some body_valid_body_spec_header
  body_valid_body_impl_header : functionHeader "valid_body" "is" bodyTokens = some body_valid_body_impl_header
  body_accepts_impl_header : functionHeader "accepts" "is" bodyTokens = some body_accepts_impl_header
  body_uses_arguments_impl_header : functionHeader "uses_arguments" "is" bodyTokens = some body_uses_arguments_impl_header
  body_uses_assignment_impl_header : functionHeader "uses_assignment" "is" bodyTokens = some body_uses_assignment_impl_header
  body_uses_output_impl_header : functionHeader "uses_output" "is" bodyTokens = some body_uses_output_impl_header
  body_spelling_impl_header : functionHeader "spelling" "is" bodyTokens = some body_spelling_impl_header
  body_is_word_token_impl_header : functionHeader "is_word_token" "is" bodyTokens = some body_is_word_token_impl_header
  scan_result_declaration : Lexical.SourceBridge.recordDeclaration "scan_result" bodyTokens = some scan_result_declaration
  body_context_declaration : Lexical.SourceBridge.recordDeclaration "body_context" bodyTokens = some body_context_declaration
  body_scan_declaration : Lexical.SourceBridge.discriminatedRecordDeclaration "body_scan" bodyTokens = some body_scan_declaration
  body_stop_declaration : typeDeclaration "body_stop" bodyTokens = some body_stop_declaration
  form_kind_declaration : typeDeclaration "form_kind" specTokens = some form_kind_declaration
  token_kind_declaration : typeDeclaration "token_kind" specTokens = some token_kind_declaration
  token_sequence_declaration : typeDeclaration "token_sequence" specTokens = some token_sequence_declaration
  initial_scan_declaration : Source.declaration "initial_scan" bodyTokens = some initial_scan_declaration
  invalid_scan_declaration : Source.declaration "invalid_scan" bodyTokens = some invalid_scan_declaration
  max_source_length_declaration : Source.declaration "max_source_length" specTokens = some max_source_length_declaration
  max_expression_operands_declaration : Source.declaration "max_expression_operands" specTokens = some max_expression_operands_declaration
  max_concatenations_declaration : Source.declaration "max_concatenations" specTokens = some max_concatenations_declaration
  max_bindings_declaration : Source.declaration "max_bindings" specTokens = some max_bindings_declaration
  token_index_declaration : Lexical.SourceBridge.subtypeDeclaration "token_index" bodyTokens = some token_index_declaration
  binding_count_declaration : Lexical.SourceBridge.subtypeDeclaration "binding_count" bodyTokens = some binding_count_declaration
  binding_index_declaration : Lexical.SourceBridge.subtypeDeclaration "binding_index" bodyTokens = some binding_index_declaration
  operand_count_declaration : Lexical.SourceBridge.subtypeDeclaration "operand_count" bodyTokens = some operand_count_declaration
  concatenation_count_declaration : Lexical.SourceBridge.subtypeDeclaration "concatenation_count" bodyTokens = some concatenation_count_declaration
  valid_flow_body : Source.expressionBody "valid_flow" bodyTokens = some valid_flow_expression
  valid_flow_header : functionHeader "valid_flow" "is" bodyTokens = some ((Source.lexLine "(Context : Body_Context; Facts : Scalar_Flow) return Boolean").getD [])
  included_body : Source.expressionBody "included" bodyTokens = some included_expression
  included_header : functionHeader "included" "is" bodyTokens = some ((Source.lexLine "(Value, Bounds : Scalars.Interval) return Boolean").getD [])
  string_target_declaration : Lexical.SourceBridge.recordDeclaration "string_target_result" bodyTokens = some string_target_declaration
  valid_context_body : Source.expressionBody "valid_context" bodyTokens = some valid_context_expression
  valid_body_body : Source.expressionBody "valid_body" bodyTokens = some valid_body_expression

end Silver.Predicate.SourceChecks
