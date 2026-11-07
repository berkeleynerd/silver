module

public import Silver.PredicateBodyExpressions
import all Init.Data.Repr

@[expose] public section
namespace Silver.Predicate.BodyNative
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/-! Reviewed candidate bodies, checked against the typed rendering here. Final
source checks extract these same bodies from the authoritative certificate. -/

def candidate_statement_body : List String :=
  ["if", "scan", ".", "position", "=", "0", "then", "invalid_body", "(", "scan", ")", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "if_keyword", ")", "/=", "0", "then", "conditional_body", "(", "text", ",", "context", ",", "scan", ",", "catalog", ")", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "for_keyword", ")", "/=", "0", "then", "loop_body", "(", "text", ",", "context", ",", "scan", ",", "catalog", ")", "else", "basic_body", "(", "text", ",", "context", ",", "scan", ",", "catalog", ")"]

theorem rendered_statement_body : statementRender = candidate_statement_body := by
  unfold candidate_statement_body
  simp only [statementRender, Test.render, ScanExpr.render]
  decide +kernel

def candidate_conditional_body : List String :=
  ["result", ":", "body_scan", "(", "scan", ".", "count", ")", ":=", "body_token", "(", "text", ",", "context", ",", "scan", ",", "if_keyword", ")", ";", "condition", ":", "condition_result", "(", "scan", ".", "count", ")", ";", "yes", ":", "scalar_flow", "(", "scan", ".", "count", ")", ";", "begin", "read_condition_into", "(", "text", ",", "context", ",", "result", ".", "position", ",", "result", ".", "facts", ",", "condition", ")", ";", "result", ".", "position", ":=", "condition", ".", "after", ";", "result", ".", "facts", ":=", "condition", ".", "when_true", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "then_keyword", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "result", ":=", "read_body", "(", "text", ",", "context", ",", "result", ",", "arm_boundary", ",", "catalog", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "yes", ":=", "result", ".", "facts", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "yes", ")", ")", ";", "result", ".", "facts", ":=", "condition", ".", "when_false", ";", "result", ":=", "alternative_body", "(", "text", ",", "context", ",", "result", ",", "catalog", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "result", ".", "facts", ")", ")", ";", "lemma_joined_flow", "(", "context", ",", "result", ".", "facts", ",", "yes", ")", ";", "join_into", "(", "result", ".", "facts", ",", "yes", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "result", ".", "facts", ")", ")", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "end_keyword", ")", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "if_keyword", ")", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "semicolon", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "return", "result", ";", "end", "conditional_body", ";"]

theorem rendered_conditional_body : conditionalFunction.render "conditional_body" = candidate_conditional_body := by
  unfold candidate_conditional_body
  simp only [Function.render, conditionalFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render, FactsExpr.render, finish]
  decide +kernel

def candidate_alternative_body : List String :=
  ["result", ":", "body_scan", "(", "scan", ".", "count", ")", ":=", "scan", ";", "condition", ":", "condition_result", "(", "scan", ".", "count", ")", ";", "yes", ":", "scalar_flow", "(", "scan", ".", "count", ")", ";", "begin", "if", "scan", ".", "position", "=", "0", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "if", "take_token", "(", "text", ",", "scan", ".", "position", ",", "elsif_keyword", ")", "/=", "0", "then", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "elsif_keyword", ")", ";", "read_condition_into", "(", "text", ",", "context", ",", "result", ".", "position", ",", "result", ".", "facts", ",", "condition", ")", ";", "result", ".", "position", ":=", "condition", ".", "after", ";", "result", ".", "facts", ":=", "condition", ".", "when_true", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "then_keyword", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "result", ":=", "read_body", "(", "text", ",", "context", ",", "result", ",", "arm_boundary", ",", "catalog", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "yes", ":=", "result", ".", "facts", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "yes", ")", ")", ";", "result", ".", "facts", ":=", "condition", ".", "when_false", ";", "result", ":=", "alternative_body", "(", "text", ",", "context", ",", "result", ",", "catalog", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "result", ".", "facts", ")", ")", ";", "lemma_joined_flow", "(", "context", ",", "result", ".", "facts", ",", "yes", ")", ";", "join_into", "(", "result", ".", "facts", ",", "yes", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "result", ".", "facts", ")", ")", ";", "return", "result", ";", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "else_keyword", ")", "/=", "0", "then", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "else_keyword", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "return", "read_body", "(", "text", ",", "context", ",", "result", ",", "end_only", ",", "catalog", ")", ";", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "end_keyword", ")", "/=", "0", "then", "return", "scan", ";", "else", "return", "invalid_body", "(", "scan", ")", ";", "end", "if", ";", "end", "alternative_body", ";"]

theorem rendered_alternative_body : alternativeFunction.render "alternative_body" = candidate_alternative_body := by
  unfold candidate_alternative_body
  simp only [Function.render, alternativeFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render, FactsExpr.render]
  decide +kernel

def candidate_body_tail_model : List String :=
  ["if", "scan", ".", "position", "=", "0", "then", "invalid_body_model", "(", "scan", ")", "elsif", "at_body_stop", "(", "text", ",", "scan", ".", "position", ",", "stop", ")", "then", "scan", "else", "(", "declare", "result", ":", "constant", "body_scan", "(", "scan", ".", "count", ")", ":=", "statement_body", "(", "text", ",", "context", ",", "scan", ",", "catalog", ")", ";", "begin", "(", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "invalid_body_model", "(", "result", ")", "else", "body_tail_model", "(", "text", ",", "context", ",", "result", ",", "stop", ",", "catalog", ")", ")", ")"]

theorem rendered_body_tail_model : tailModelBody.render = candidate_body_tail_model := by
  unfold candidate_body_tail_model
  simp only [tailModelBody, ModelExpr.render, ModelExpr.renderElse, ScanExpr.render, Test.render, StopRef.render]
  decide +kernel

def candidate_read_body : List String :=
  ["result", ":", "constant", "body_scan", "(", "scan", ".", "count", ")", ":=", "statement_body", "(", "text", ",", "context", ",", "scan", ",", "catalog", ")", ";", "begin", "if", "result", ".", "position", "=", "0", "then", "return", "invalid_body", "(", "result", ")", ";", "end", "if", ";", "return", "body_tail", "(", "text", ",", "context", ",", "result", ",", "stop", ",", "catalog", ")", ";", "end", "read_body", ";"]

theorem rendered_read_body : readFunction.render "read_body" = candidate_read_body := by
  unfold candidate_read_body
  simp only [Function.render, readFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render]
  decide +kernel

end Silver.Predicate.BodyNative
