module

public import Silver.PredicateNativeBodies
public import Silver.SourceDeclarations

@[expose] public section

/-! Exact primitive body, contract and representation requirements. This interface
is independent of the candidate excerpt used while the complete source is being
integrated; final correspondence instantiates Checked with authoritative tokens. -/
namespace Silver.Predicate.NativeSourceChecks
open Native Silver.SourceBridge

def summary_of_impl_header : List String :=
  ["(", "value", ":", "expression_result", ")", "return", "length_intervals", ".", "summary"]

def bound_of_impl_header : List String :=
  ["(", "value", ":", "binding_info", ")", "return", "paths", ".", "bound"]

def binding_summary_impl_header : List String :=
  ["(", "value", ":", "binding_info", ")", "return", "length_intervals", ".", "summary"]

def scalar_comparison_at_spec_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "comparison_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "scalar_comparison_at", "'", "result", ".", "after", "=", "0", "or", "else", "scalar_comparison_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]

def scalar_comparison_at_impl_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "comparison_result"]

def length_at_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "literal", ":", "boolean", ")", "return", "length_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", ",", "post", "=>", "length_at", "'", "result", ".", "after", "=", "0", "or", "else", "length_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]

def length_at_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "literal", ":", "boolean", ")", "return", "length_result"]

def read_primary_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", ",", "post", "=>", "read_primary", "'", "result", ".", "after", "=", "0", "or", "else", "read_primary", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "1", ")"]

def read_primary_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result"]

def read_relation_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", ",", "post", "=>", "read_relation", "'", "result", ".", "after", "=", "0", "or", "else", "read_relation", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "2", ")"]

def read_relation_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result"]

def chain_token_spec_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "token_kind", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1"]

def chain_token_impl_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "token_kind"]

def chain_after_spec_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operator", ":", "token_kind", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "operator", "in", "and_keyword", "|", "or_keyword", ",", "post", "=>", "chain_after", "'", "result", "=", "0", "or", "else", "chain_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]

def chain_after_impl_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operator", ":", "token_kind", ")", "return", "literal_position"]

def condition_tail_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "result", ":", "condition_result", ";", "operator", ":", "token_kind", ";", "chained", ":", "boolean", ")", "return", "condition_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "result", ".", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "operator", "in", "and_keyword", "|", "or_keyword", ",", "post", "=>", "condition_tail", "'", "result", ".", "after", "=", "0", "or", "else", "condition_tail", "'", "result", ".", "after", "in", "result", ".", "after", "..", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "result", ".", "after", ",", "decreases", "=>", "4", ")"]

def condition_tail_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "result", ":", "condition_result", ";", "operator", ":", "token_kind", ";", "chained", ":", "boolean", ")", "return", "condition_result"]

def condition_model_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", ",", "post", "=>", "condition_model", "'", "result", ".", "after", "=", "0", "or", "else", "condition_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "3", ")"]

def condition_model_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result"]

def read_condition_spec_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", ",", "post", "=>", "(", "runtime", "=>", "read_condition", "'", "result", ".", "after", "=", "0", "or", "else", "read_condition", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",", "static", "=>", "read_condition", "'", "result", "=", "condition_model", "(", "text", ",", "context", ",", "position", ",", "facts", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "5", ")"]

def read_condition_impl_header : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "paths", ".", "context", ")", "return", "condition_result"]

def comparison_result_declaration : List String :=
  ["record", "after", ":", "literal_position", ";", "operator", ":", "paths", ".", "comparison", ";", "end", "record"]

def length_result_declaration : List String :=
  ["record", "after", ":", "literal_position", ";", "value", ":", "paths", ".", "bound", ";", "end", "record"]

def condition_result_declaration : List String :=
  ["record", "after", ":", "literal_position", ";", "when_true", ",", "when_false", ":", "paths", ".", "context", ";", "end", "record"]

def invalid_condition_declaration : List String :=
  ["constant", "condition_result", ":=", "(", "0", ",", "paths", ".", "empty_context", ",", "paths", ".", "empty_context", ")"]

structure Checked (tokens : List String) : Prop where
  summary_of_body : qualifiedExpressionBody "summary_of" tokens = some ((summaryBody.render.drop 1).dropLast)
  bound_of_body : qualifiedExpressionBody "bound_of" tokens = some ((boundBody.render.drop 1).dropLast)
  binding_summary_body : qualifiedExpressionBody "binding_summary" tokens = some ((bindingSummaryBody.render.drop 1).dropLast)
  scalar_comparison_at_body : Source.expressionBody "scalar_comparison_at" tokens = some (comparisonBody.render)
  length_at_body : Source.expressionBody "length_at" tokens = some (lengthBody.render)
  read_primary_body : Source.expressionBody "read_primary" tokens = some (primaryBody.render)
  read_relation_body : Source.expressionBody "read_relation" tokens = some (relationBody.render)
  chain_token_body : Source.expressionBody "chain_token" tokens = some (chainTokenBody.render)
  chain_after_body : Source.expressionBody "chain_after" tokens = some (chainAfterBody.render)
  condition_tail_body : Source.expressionBody "condition_tail" tokens = some (tailBody.render)
  condition_model_body : Source.expressionBody "condition_model" tokens = some (modelBody.render)
  read_condition_body : Source.expressionBody "read_condition" tokens = some (conditionBody.render)
  summary_of_impl_header : functionHeader "summary_of" "is" tokens = some summary_of_impl_header
  bound_of_impl_header : functionHeader "bound_of" "is" tokens = some bound_of_impl_header
  binding_summary_impl_header : functionHeader "binding_summary" "is" tokens = some binding_summary_impl_header
  scalar_comparison_at_spec_header : functionHeader "scalar_comparison_at" ";" tokens = some scalar_comparison_at_spec_header
  scalar_comparison_at_impl_header : functionHeader "scalar_comparison_at" "is" tokens = some scalar_comparison_at_impl_header
  length_at_spec_header : functionHeader "length_at" ";" tokens = some length_at_spec_header
  length_at_impl_header : functionHeader "length_at" "is" tokens = some length_at_impl_header
  read_primary_spec_header : functionHeader "read_primary" ";" tokens = some read_primary_spec_header
  read_primary_impl_header : functionHeader "read_primary" "is" tokens = some read_primary_impl_header
  read_relation_spec_header : functionHeader "read_relation" ";" tokens = some read_relation_spec_header
  read_relation_impl_header : functionHeader "read_relation" "is" tokens = some read_relation_impl_header
  chain_token_spec_header : functionHeader "chain_token" ";" tokens = some chain_token_spec_header
  chain_token_impl_header : functionHeader "chain_token" "is" tokens = some chain_token_impl_header
  chain_after_spec_header : functionHeader "chain_after" ";" tokens = some chain_after_spec_header
  chain_after_impl_header : functionHeader "chain_after" "is" tokens = some chain_after_impl_header
  condition_tail_spec_header : functionHeader "condition_tail" ";" tokens = some condition_tail_spec_header
  condition_tail_impl_header : functionHeader "condition_tail" "is" tokens = some condition_tail_impl_header
  condition_model_spec_header : functionHeader "condition_model" ";" tokens = some condition_model_spec_header
  condition_model_impl_header : functionHeader "condition_model" "is" tokens = some condition_model_impl_header
  read_condition_spec_header : functionHeader "read_condition" ";" tokens = some read_condition_spec_header
  read_condition_impl_header : functionHeader "read_condition" "is" tokens = some read_condition_impl_header
  comparison_result_declaration : Lexical.SourceBridge.recordDeclaration "comparison_result" tokens = some comparison_result_declaration
  length_result_declaration : Lexical.SourceBridge.recordDeclaration "length_result" tokens = some length_result_declaration
  condition_result_declaration : Lexical.SourceBridge.recordDeclaration "condition_result" tokens = some condition_result_declaration
  invalid_condition_declaration : Source.declaration "invalid_condition" tokens = some invalid_condition_declaration

end Silver.Predicate.NativeSourceChecks
