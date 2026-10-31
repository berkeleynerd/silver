module

public import Silver.PredicateAdapter

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.Adapter

/-- Exact isolated native candidate blocks. Final authoritative extraction is integrated separately. -/

def context_ofCandidate : List String :=
  ["(", "names", "=>", "scan", ".", "state", ".", "names", ",", "scalar_names", "=>", "scalar_expressions", ".", "body_environment", "(", "scan", ".", "state", ".", "scalar_names", ")", ",", "array_names", "=>", "scan", ".", "state", ".", "array_names", ".", "names", ",", "subtype_hiding", "=>", "scan", ".", "state", ".", "subtype_names", ".", "hidden_calls", ",", "boolean_names", "=>", "scan", ".", "state", ".", "boolean_names", ",", "true_hidden", "=>", "scan", ".", "state", ".", "subtype_names", ".", "true_hidden", ",", "false_hidden", "=>", "scan", ".", "state", ".", "subtype_names", ".", "false_hidden", ",", "elaborating", "=>", "false", ",", "mask_first", "=>", "0", ",", "mask_after", "=>", "0", ",", "declaration_count", "=>", "scan", ".", "state", ".", "scalar_names", ".", "count", ",", "dynamic_first", "=>", "scan", ".", "state", ".", "dynamic_first", ",", "dynamic_after", "=>", "scan", ".", "state", ".", "dynamic_after", ")"]

theorem context_of_candidate : contextExpr.render = context_ofCandidate := by
  unfold context_ofCandidate
  simp only [contextExpr, Expr.render, Field.name, record, Nat.toString_eq_repr,
    Nat.repr_of_lt (by decide : 0 < 10), (Nat.digitChar_eq_zero).2 rfl,
    String.singleton_eq_ofList]
  decide +kernel


def body_ofCandidate : List String :=
  ["(", "count", "=>", "scan", ".", "state", ".", "scalar_names", ".", "count", ",", "facts", "=>", "initial_flow", "(", "context_of", "(", "scan", ")", ")", ",", "position", "=>", "scan", ".", "state", ".", "position", ",", "target", "=>", "scan", ".", "state", ".", "target", ",", "capacity", "=>", "scan", ".", "state", ".", "capacity", ",", "assigned", "=>", "scan", ".", "assigned", ",", "output", "=>", "scan", ".", "output", ")"]

theorem body_of_candidate : bodyExpr.render = body_ofCandidate := by
  unfold body_ofCandidate
  simp only [bodyExpr, Expr.render, Field.name, record]
  decide +kernel


def expand_bodyCandidate : List String :=
  ["(", "state", "=>", "(", "position", "=>", "scan", ".", "position", ",", "names", "=>", "context", ".", "names", ",", "scalar_names", "=>", "context", ".", "scalar_names", ",", "array_names", "=>", "arrays", ",", "subtype_names", "=>", "subtypes", ",", "boolean_names", "=>", "context", ".", "boolean_names", ",", "dynamic_first", "=>", "context", ".", "dynamic_first", ",", "dynamic_after", "=>", "context", ".", "dynamic_after", ",", "target", "=>", "scan", ".", "target", ",", "capacity", "=>", "scan", ".", "capacity", ")", ",", "assigned", "=>", "scan", ".", "assigned", ",", "output", "=>", "scan", ".", "output", ")"]

theorem expand_body_candidate : expandExpr.render = expand_bodyCandidate := by
  simp only [expandExpr, Expr.render, Field.name, record]
  decide +kernel


def body_tokenCandidate : List String :=
  ["(", "scan", "with", "delta", "position", "=>", "take_token", "(", "text", ",", "scan", ".", "position", ",", "token", ")", ")"]

theorem body_token_candidate : tokenExpr.render = body_tokenCandidate := by
  simp only [tokenExpr, Expr.render]
  decide +kernel


def at_body_stopCandidate : List String :=
  ["(", "case", "stop", "is", "when", "end_only", "=>", "take_token", "(", "text", ",", "position", ",", "end_keyword", ")", "/=", "0", ",", "when", "else_only", "=>", "take_token", "(", "text", ",", "position", ",", "else_keyword", ")", "/=", "0", ",", "when", "arm_boundary", "=>", "take_token", "(", "text", ",", "position", ",", "elsif_keyword", ")", "/=", "0", "or", "else", "take_token", "(", "text", ",", "position", ",", "else_keyword", ")", "/=", "0", "or", "else", "take_token", "(", "text", ",", "position", ",", "end_keyword", ")", "/=", "0", ")"]

theorem at_body_stop_candidate : atStopExpr.render = at_body_stopCandidate := by
  simp only [atStopExpr, Expr.render]
  decide +kernel


def read_statementsCandidate : List String :=
  ["context", ":", "constant", "body_context", ":=", "context_of", "(", "scan", ")", ";", "result", ":", "constant", "body_scan", "(", "scan", ".", "state", ".", "scalar_names", ".", "count", ")", ":=", "read_body", "(", "text", ",", "context", ",", "body_of", "(", "scan", ")", ",", "(", "if", "stop", "=", "else_keyword", "then", "else_only", "else", "end_only", ")", ")", ";", "begin", "return", "(", "if", "result", ".", "position", "=", "0", "or", "else", "not", "paths", ".", "completed", "(", "result", ".", "facts", ".", "path", ")", "then", "invalid_scan", "else", "expand_body", "(", "context", ",", "result", ",", "scan", ".", "state", ".", "array_names", ",", "scan", ".", "state", ".", "subtype_names", ")", ")", ";", "end", "read_statements", ";"]

theorem read_statements_candidate : adapterFunction.render = read_statementsCandidate := by
  unfold read_statementsCandidate
  simp only [adapterFunction, Function.render, Expr.render, Field.name]
  decide +kernel


end Silver.Predicate.Adapter
