module

public import Silver.PredicateOuterExpressions
import all Init.Data.Repr

@[expose] public section
namespace Silver.Predicate.Outer
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def tokenName : Token → String
  | .helper token => Compose.Expressions.tokenName token
  | .statements => "statements"

def formName (form : Form) : String := Compose.Expressions.formName form.helper

def tokensBody : List String := ["case", "form", "is"] ++
  List.flatten ((allForms.map fun form => ["when", formName form, "=>", "("] ++
    List.flatten ((form.tokens.map (fun token => [tokenName token])).intersperse [","]) ++ [")"]).intersperse [","])

/-! Exact candidates for the two-shell outer scanner, interpreted by
PredicateOuterExpressions and connected to complete source by its bridge. -/

def candidate_tokens : List String :=
  ["case", "form", "is", "when", "direct_form", "=>", "(", "context_clauses", ",", "procedure_keyword", ",", "main_name", ",", "is_keyword", ",", "pragma_keyword", ",", "spark_mode_name", ",", "left_parenthesis", ",", "on_name", ",", "right_parenthesis", ",", "semicolon", ",", "declarations", ",", "begin_keyword", ",", "statements", ",", "end_keyword", ",", "main_name", ",", "semicolon", ")", ",", "when", "argument_form", "=>", "(", "context_clauses", ",", "procedure_keyword", ",", "main_name", ",", "is_keyword", ",", "pragma_keyword", ",", "spark_mode_name", ",", "left_parenthesis", ",", "on_name", ",", "right_parenthesis", ",", "semicolon", ",", "argument_declaration", ",", "declarations", ",", "begin_keyword", ",", "statements", ",", "end_keyword", ",", "main_name", ",", "semicolon", ")"]

theorem rendered_tokens : tokensBody = candidate_tokens := by
  decide +kernel

def candidate_scan_step : List String :=
  ["if", "token", "=", "statements", "then", "read_statements", "(", "text", ",", "scan", ",", "end_keyword", ")", "else", "(", "declare", "next", ":", "constant", "parser_state", ":=", "step", "(", "text", ",", "form", ",", "token", ",", "scan", ".", "state", ")", ";", "begin", "(", "scan", "with", "delta", "state", "=>", "next", ",", "assigned", "=>", "scan", ".", "assigned", "or", "next", ".", "assigned_in_functions", ")", ")"]

theorem rendered_scan_step : scanStepBody.render = candidate_scan_step := by
  simp only [scanStepBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel

def candidate_scan_suffix : List String :=
  ["if", "scan", ".", "state", ".", "position", "=", "0", "then", "invalid_scan", "elsif", "next_token", ">", "tokens", "(", "form", ")", "'", "last", "then", "(", "if", "trivia_end", "(", "text", ",", "scan", ".", "state", ".", "position", ")", "=", "text", "'", "last", "+", "1", "then", "scan", "else", "invalid_scan", ")", "else", "scan_suffix", "(", "text", ",", "form", ",", "next_token", "+", "1", ",", "scan_step", "(", "text", ",", "form", ",", "tokens", "(", "form", ")", "(", "next_token", ")", ",", "scan", ")", ")"]

theorem rendered_scan_suffix : suffixBody.render = candidate_scan_suffix := by
  simp only [suffixBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel

def candidate_form_result : List String :=
  ["if", "source", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "allowed_source", "(", "normalized", "(", "source", ")", ")", "and", "then", "within_work_budget", "(", "normalized", "(", "source", ")", ")", "then", "scan_suffix", "(", "normalized", "(", "source", ")", ",", "form", ",", "1", ",", "initial_scan", ")", "else", "invalid_scan"]

theorem rendered_form_result : formBody.render = candidate_form_result := by
  simp only [formBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel

def candidate_is_member : List String :=
  ["for", "some", "form", "in", "form_kind", "=>", "form_result", "(", "source", ",", "form", ")", ".", "state", ".", "position", "/=", "0"]

theorem rendered_is_member : memberBody.render = candidate_is_member := by
  decide +kernel

def candidate_has_arguments : List String :=
  ["for", "some", "form", "in", "form_kind", "=>", "form_result", "(", "source", ",", "form", ")", ".", "state", ".", "position", "/=", "0", "and", "then", "is_argument_form", "(", "form", ")"]

theorem rendered_has_arguments : argumentsBody.render = candidate_has_arguments := by
  decide +kernel

def candidate_has_assignment : List String :=
  ["for", "some", "form", "in", "form_kind", "=>", "form_result", "(", "source", ",", "form", ")", ".", "state", ".", "position", "/=", "0", "and", "then", "form_result", "(", "source", ",", "form", ")", ".", "assigned"]

theorem rendered_has_assignment : assignmentBody.render = candidate_has_assignment := by
  decide +kernel

def candidate_has_output : List String :=
  ["for", "some", "form", "in", "form_kind", "=>", "form_result", "(", "source", ",", "form", ")", ".", "state", ".", "position", "/=", "0", "and", "then", "form_result", "(", "source", ",", "form", ")", ".", "output"]

theorem rendered_has_output : outputBody.render = candidate_has_output := by
  decide +kernel

end Silver.Predicate.Outer
