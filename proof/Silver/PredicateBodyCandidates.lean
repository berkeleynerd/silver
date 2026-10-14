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
  ["if", "scan", ".", "position", "=", "0", "then", "invalid_body", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "if_keyword", ")", "/=", "0", "then", "conditional_body", "(", "text", ",", "context", ",", "scan", ")", "else", "basic_body", "(", "text", ",", "context", ",", "scan", ")"]

theorem rendered_statement_body : statementRender = candidate_statement_body := by
  simp only [statementRender, Test.render, ScanExpr.render]
  decide +kernel

def candidate_conditional_body : List String :=
  ["result", ":", "body_scan", ":=", "body_token", "(", "text", ",", "context", ",", "scan", ",", "if_keyword", ")", ";", "condition", ":", "constant", "condition_result", ":=", "read_condition", "(", "text", ",", "context", ",", "result", ".", "position", ",", "result", ".", "facts", ")", ";", "yes", ":", "paths", ".", "context", ";", "begin", "result", ".", "position", ":=", "condition", ".", "after", ";", "result", ".", "facts", ":=", "condition", ".", "when_true", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "then_keyword", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "result", ":=", "read_body", "(", "text", ",", "context", ",", "result", ",", "arm_boundary", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "yes", ":=", "result", ".", "facts", ";", "result", ".", "facts", ":=", "condition", ".", "when_false", ";", "result", ":=", "alternative_body", "(", "text", ",", "context", ",", "result", ")", ";", "result", ".", "facts", ":=", "paths", ".", "join", "(", "yes", ",", "result", ".", "facts", ")", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "end_keyword", ")", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "if_keyword", ")", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "semicolon", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "return", "result", ";", "end", "conditional_body", ";"]

theorem rendered_conditional_body : conditionalFunction.render "conditional_body" = candidate_conditional_body := by
  simp only [Function.render, conditionalFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render, FactsExpr.render, finish]
  decide +kernel

def candidate_alternative_body : List String :=
  ["result", ":", "body_scan", ":=", "scan", ";", "condition", ":", "condition_result", ";", "yes", ":", "paths", ".", "context", ";", "begin", "if", "scan", ".", "position", "=", "0", "then", "return", "invalid_body", ";", "end", "if", ";", "if", "take_token", "(", "text", ",", "scan", ".", "position", ",", "elsif_keyword", ")", "/=", "0", "then", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "elsif_keyword", ")", ";", "condition", ":=", "read_condition", "(", "text", ",", "context", ",", "result", ".", "position", ",", "result", ".", "facts", ")", ";", "result", ".", "position", ":=", "condition", ".", "after", ";", "result", ".", "facts", ":=", "condition", ".", "when_true", ";", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "then_keyword", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "result", ":=", "read_body", "(", "text", ",", "context", ",", "result", ",", "arm_boundary", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "yes", ":=", "result", ".", "facts", ";", "result", ".", "facts", ":=", "condition", ".", "when_false", ";", "result", ":=", "alternative_body", "(", "text", ",", "context", ",", "result", ")", ";", "result", ".", "facts", ":=", "paths", ".", "join", "(", "yes", ",", "result", ".", "facts", ")", ";", "return", "result", ";", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "else_keyword", ")", "/=", "0", "then", "result", ":=", "body_token", "(", "text", ",", "context", ",", "result", ",", "else_keyword", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "return", "read_body", "(", "text", ",", "context", ",", "result", ",", "end_only", ")", ";", "elsif", "take_token", "(", "text", ",", "scan", ".", "position", ",", "end_keyword", ")", "/=", "0", "then", "return", "scan", ";", "else", "return", "invalid_body", ";", "end", "if", ";", "end", "alternative_body", ";"]

theorem rendered_alternative_body : alternativeFunction.render "alternative_body" = candidate_alternative_body := by
  simp only [Function.render, alternativeFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render, FactsExpr.render]
  decide +kernel

def candidate_body_tail : List String :=
  ["result", ":", "body_scan", ":=", "scan", ";", "begin", "if", "result", ".", "position", "=", "0", "then", "return", "invalid_body", ";", "end", "if", ";", "if", "at_body_stop", "(", "text", ",", "result", ".", "position", ",", "stop", ")", "then", "return", "result", ";", "end", "if", ";", "result", ":=", "statement_body", "(", "text", ",", "context", ",", "result", ")", ";", "if", "result", ".", "position", "<=", "scan", ".", "position", "then", "return", "invalid_body", ";", "end", "if", ";", "return", "body_tail", "(", "text", ",", "context", ",", "result", ",", "stop", ")", ";", "end", "body_tail", ";"]

theorem rendered_body_tail : tailFunction.render "body_tail" = candidate_body_tail := by
  simp only [Function.render, tailFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render]
  decide +kernel

def candidate_read_body : List String :=
  ["result", ":", "constant", "body_scan", ":=", "statement_body", "(", "text", ",", "context", ",", "scan", ")", ";", "begin", "if", "result", ".", "position", "=", "0", "then", "return", "invalid_body", ";", "end", "if", ";", "return", "body_tail", "(", "text", ",", "context", ",", "result", ",", "stop", ")", ";", "end", "read_body", ";"]

theorem rendered_read_body : readFunction.render "read_body" = candidate_read_body := by
  simp only [Function.render, readFunction, guard, Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse, ScanExpr.render, Test.render]
  decide +kernel

end Silver.Predicate.BodyNative
