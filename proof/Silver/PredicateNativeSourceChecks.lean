module

public import Silver.PredicateNativeBodies
public import Silver.PredicateNativeWorkers
public import Silver.PredicateFlowReaders
public import Silver.PredicateNativeScalarHelpers
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

def primary_model_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Primary_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Primary_Model'Result) and then (Primary_Model'Result.After = 0 or else Primary_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1)").getD []

def primary_model_impl_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Condition_Result").getD []

def relation_model_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Relation_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Relation_Model'Result) and then (Relation_Model'Result.After = 0 or else Relation_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2)").getD []

def relation_model_impl_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Condition_Result").getD []

def chain_token_spec_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "token_kind", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1"]

def chain_token_impl_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "token_kind"]

def chain_after_spec_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operator", ":", "token_kind", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "operator", "in", "and_keyword", "|", "or_keyword", ",", "post", "=>", "chain_after", "'", "result", "=", "0", "or", "else", "chain_after", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1"]

def chain_after_impl_header : List String :=
  ["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "operator", ":", "token_kind", ")", "return", "literal_position"]

def condition_tail_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Result : Condition_Result; Operator : Token_Kind; Chained : Boolean) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Result.After <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Condition (Context, Result) and then Operator in And_Keyword | Or_Keyword, Post => Condition_Tail'Result.Count = Result.Count and then Valid_Condition (Context, Condition_Tail'Result) and then (Condition_Tail'Result.After = 0 or else Condition_Tail'Result.After in Result.After .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Result.After, Decreases => 4)").getD []

def condition_tail_impl_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Result : Condition_Result; Operator : Token_Kind; Chained : Boolean) return Condition_Result").getD []

def condition_model_spec_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Condition_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Condition_Model'Result) and then (Condition_Model'Result.After = 0 or else Condition_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3)").getD []

def condition_model_impl_header : List String :=
  (Source.lexLine "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Condition_Result").getD []

def comparison_result_declaration : List String :=
  ["record", "after", ":", "literal_position", ";", "operator", ":", "paths", ".", "comparison", ";", "end", "record"]

def length_result_declaration : List String :=
  ["record", "after", ":", "literal_position", ";", "value", ":", "paths", ".", "bound", ";", "end", "record"]

def valid_condition_header : List String :=
  (Source.lexLine "(Context : Body_Context; Result : Condition_Result) return Boolean").getD []

def valid_condition_expression : List String :=
  (Source.lexLine "Valid_Flow (Context, Result.When_True) and then Valid_Flow (Context, Result.When_False)").getD []

/-- Fixed worker proof helpers retain their exact Static-only declarations.
Native verification establishes each Logical_Equal annotation and the lemma
postcondition; these source checks do not replace that obligation. -/

def logical_equality_aspects : List String :=
  ["with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "annotate", "=>", "(", "gnatprove", ",", "logical_equal", ")"]

def same_interval_header : List String :=
  ["(", "left", ",", "right", ":", "scalars", ".", "interval", ")", "return", "boolean"]

def same_interval_expression : List String :=
  ["left", ".", "lower", "=", "right", ".", "lower", "and", "then", "left", ".", "upper", "=", "right", ".", "upper"]

def same_path_header : List String :=
  ["(", "left", ",", "right", ":", "paths", ".", "context", ")", "return", "boolean"]

def same_path_expression : List String :=
  ["left", ".", "lower", "=", "right", ".", "lower", "and", "then", "left", ".", "upper", "=", "right", ".", "upper", "and", "then", "left", ".", "valid_reachable", "=", "right", ".", "valid_reachable", "and", "then", "left", ".", "invalid_reachable", "=", "right", ".", "invalid_reachable", "and", "then", "left", ".", "invalid_rejected", "=", "right", ".", "invalid_rejected"]

def same_values_header : List String :=
  ["(", "left", ",", "right", ":", "interval_vector", ")", "return", "boolean"]

def same_values_expression : List String :=
  ["left", "'", "first", "=", "right", "'", "first", "and", "then", "left", "'", "last", "=", "right", "'", "last", "and", "then", "(", "for", "all", "index", "in", "left", "'", "range", "=>", "same_interval", "(", "left", "(", "index", ")", ",", "right", "(", "index", ")", ")", ")"]

def same_flow_header : List String :=
  ["(", "left", ",", "right", ":", "scalar_flow", ")", "return", "boolean"]

def same_flow_expression : List String :=
  ["left", ".", "count", "=", "right", ".", "count", "and", "then", "same_path", "(", "left", ".", "path", ",", "right", ".", "path", ")", "and", "then", "same_values", "(", "left", ".", "values", ",", "right", ".", "values", ")"]

def same_condition_header : List String :=
  ["(", "left", ",", "right", ":", "condition_result", ")", "return", "boolean"]

def same_condition_expression : List String :=
  ["left", ".", "count", "=", "right", ".", "count", "and", "then", "left", ".", "after", "=", "right", ".", "after", "and", "then", "same_flow", "(", "left", ".", "when_true", ",", "right", ".", "when_true", ")", "and", "then", "same_flow", "(", "left", ".", "when_false", ",", "right", ".", "when_false", ")"]

def lemma_condition_equality_impl : List String :=
  ["(", "left", ",", "right", ":", "condition_result", ")", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "left", "=", "right", ",", "post", "=>", "same_condition", "(", "left", ",", "right", ")"]

def lemma_flow_equality_impl : List String :=
  ["(", "left", ",", "right", ":", "scalar_flow", ")", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "left", "=", "right", ",", "post", "=>", "same_flow", "(", "left", ",", "right", ")"]

structure Checked (tokens : List String) : Prop where
  flow : FlowSourceBridge.Checked tokens
  readers : FlowReaders.Checked tokens
  scalarHelpers : Native.ScalarHelpers.Checked tokens
  workers : Native.Workers.Checked tokens
  same_interval_header : functionHeader "same_interval" "is" tokens = some same_interval_header
  same_interval_body : expressionDeclaration "same_interval" tokens = some (same_interval_expression, logical_equality_aspects)
  same_path_header : functionHeader "same_path" "is" tokens = some same_path_header
  same_path_body : expressionDeclaration "same_path" tokens = some (same_path_expression, logical_equality_aspects)
  same_values_header : functionHeader "same_values" "is" tokens = some same_values_header
  same_values_body : expressionDeclaration "same_values" tokens = some (same_values_expression, logical_equality_aspects)
  same_flow_header : functionHeader "same_flow" "is" tokens = some same_flow_header
  same_flow_body : expressionDeclaration "same_flow" tokens = some (same_flow_expression, logical_equality_aspects)
  same_condition_header : functionHeader "same_condition" "is" tokens = some same_condition_header
  same_condition_body : expressionDeclaration "same_condition" tokens = some (same_condition_expression, logical_equality_aspects)
  lemma_condition_equality_impl : procedureHeader "lemma_condition_equality" "is" tokens = some lemma_condition_equality_impl
  lemma_flow_equality_impl : procedureHeader "lemma_flow_equality" "is" tokens = some lemma_flow_equality_impl
  valid_condition_header : functionHeader "valid_condition" "is" tokens = some valid_condition_header
  valid_condition_body : Source.expressionBody "valid_condition" tokens = some valid_condition_expression
  summary_of_body : qualifiedExpressionBody "summary_of" tokens = some ((summaryBody.render.drop 1).dropLast)
  bound_of_body : qualifiedExpressionBody "bound_of" tokens = some ((boundBody.render.drop 1).dropLast)
  binding_summary_body : qualifiedExpressionBody "binding_summary" tokens = some ((bindingSummaryBody.render.drop 1).dropLast)
  scalar_comparison_at_body : Source.expressionBody "scalar_comparison_at" tokens = some (comparisonBody.render)
  length_at_body : Source.expressionBody "length_at" tokens = some (lengthBody.render)
  primary_model_body : Source.expressionBody "primary_model" tokens = some (primaryBody.render)
  relation_model_body : Source.expressionBody "relation_model" tokens = some (relationBody.render)
  chain_token_body : Source.expressionBody "chain_token" tokens = some (chainTokenBody.render)
  chain_after_body : Source.expressionBody "chain_after" tokens = some (chainAfterBody.render)
  condition_tail_body : Source.expressionBody "condition_tail" tokens = some (tailBody.render)
  condition_model_body : Source.expressionBody "condition_model" tokens = some (modelBody.render)
  summary_of_impl_header : functionHeader "summary_of" "is" tokens = some summary_of_impl_header
  bound_of_impl_header : functionHeader "bound_of" "is" tokens = some bound_of_impl_header
  binding_summary_impl_header : functionHeader "binding_summary" "is" tokens = some binding_summary_impl_header
  scalar_comparison_at_spec_header : functionHeader "scalar_comparison_at" ";" tokens = some scalar_comparison_at_spec_header
  scalar_comparison_at_impl_header : functionHeader "scalar_comparison_at" "is" tokens = some scalar_comparison_at_impl_header
  length_at_spec_header : functionHeader "length_at" ";" tokens = some length_at_spec_header
  length_at_impl_header : functionHeader "length_at" "is" tokens = some length_at_impl_header
  primary_model_spec_header : functionHeader "primary_model" ";" tokens = some primary_model_spec_header
  primary_model_impl_header : functionHeader "primary_model" "is" tokens = some primary_model_impl_header
  relation_model_spec_header : functionHeader "relation_model" ";" tokens = some relation_model_spec_header
  relation_model_impl_header : functionHeader "relation_model" "is" tokens = some relation_model_impl_header
  chain_token_spec_header : functionHeader "chain_token" ";" tokens = some chain_token_spec_header
  chain_token_impl_header : functionHeader "chain_token" "is" tokens = some chain_token_impl_header
  chain_after_spec_header : functionHeader "chain_after" ";" tokens = some chain_after_spec_header
  chain_after_impl_header : functionHeader "chain_after" "is" tokens = some chain_after_impl_header
  condition_tail_spec_header : functionHeader "condition_tail" ";" tokens = some condition_tail_spec_header
  condition_tail_impl_header : functionHeader "condition_tail" "is" tokens = some condition_tail_impl_header
  condition_model_spec_header : functionHeader "condition_model" ";" tokens = some condition_model_spec_header
  condition_model_impl_header : functionHeader "condition_model" "is" tokens = some condition_model_impl_header
  comparison_result_declaration : Lexical.SourceBridge.recordDeclaration "comparison_result" tokens = some comparison_result_declaration
  length_result_declaration : Lexical.SourceBridge.recordDeclaration "length_result" tokens = some length_result_declaration

end Silver.Predicate.NativeSourceChecks
