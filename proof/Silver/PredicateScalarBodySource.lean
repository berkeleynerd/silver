module

public import Silver.PredicateScalarBodyNative
public import Silver.SourceBridge

@[expose] public section

namespace Silver.Predicate.ScalarBodyNative.SourceChecks
open Silver.SourceBridge

def targetSpec : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ")", "return", "scalar_expressions", ".", "binding_count", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "scalar_target", "'", "result", "<=", "context", ".", "scalar_names", ".", "count"]

def targetImpl : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ")", "return", "scalar_expressions", ".", "binding_count"]

def targetCandidate : List String :=
  ["declare", "first", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "position", ")", ";", "after", ":", "constant", "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "begin", "scalar_expressions", ".", "lookup", "(", "text", ",", "context", ".", "scalar_names", ",", "first", ",", "after", ")"]

def assignmentSpec : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "scan", ")", ",", "post", "=>", "valid_body", "(", "text", ",", "context", ",", "scalar_assignment_body", "'", "result", ")", "and", "then", "(", "scalar_assignment_body", "'", "result", ".", "position", "=", "0", "or", "else", "scalar_assignment_body", "'", "result", ".", "position", ">", "scan", ".", "position", ")"]

def assignmentImpl : List String :=
  ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "body_scan"]

def assignmentCandidate : List String :=
  ["declare", "first", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "scan", ".", "position", ")", ";", "after", ":", "constant", "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "target", ":", "constant", "scalar_expressions", ".", "binding_count", ":=", "scalar_expressions", ".", "lookup", "(", "text", ",", "context", ".", "scalar_names", ",", "first", ",", "after", ")", ";", "value", ":", "constant", "scalar_expressions", ".", "expression_result", ":=", "scalar_expressions", ".", "read_expression", "(", "text", ",", "take_token", "(", "text", ",", "after", ",", "assignment", ")", ",", "context", ".", "scalar_names", ")", ";", "begin", "(", "if", "target", "=", "0", "or", "else", "not", "context", ".", "scalar_names", ".", "items", "(", "target", ")", ".", "mutable", "or", "else", "value", ".", "after", "<=", "scan", ".", "position", "or", "else", "scalars", ".", "is_empty", "(", "value", ".", "bounds", ")", "or", "else", "value", ".", "bounds", ".", "lower", "<", "context", ".", "scalar_names", ".", "items", "(", "target", ")", ".", "declared_bounds", ".", "lower", "or", "else", "value", ".", "bounds", ".", "upper", ">", "context", ".", "scalar_names", ".", "items", "(", "target", ")", ".", "declared_bounds", ".", "upper", "then", "invalid_body", "else", "(", "scan", "with", "delta", "position", "=>", "value", ".", "after", ",", "assigned", "=>", "true", ")", ")"]

theorem target_rendered : ScalarBodyNative.targetBody.render = targetCandidate := by decide +kernel

theorem assignment_rendered : ScalarBodyNative.assignmentBody.render = assignmentCandidate := by decide +kernel

structure Checked (tokens : List String) : Prop where
  target_body : qualifiedExpressionBody "scalar_target" tokens = some ScalarBodyNative.targetBody.render
  assignment_body : Source.expressionBody "scalar_assignment_body" tokens = some ScalarBodyNative.assignmentBody.render
  target_spec : functionHeader "scalar_target" ";" tokens = some targetSpec
  target_impl : functionHeader "scalar_target" "is" tokens = some targetImpl
  assignment_spec : functionHeader "scalar_assignment_body" ";" tokens = some assignmentSpec
  assignment_impl : functionHeader "scalar_assignment_body" "is" tokens = some assignmentImpl

end Silver.Predicate.ScalarBodyNative.SourceChecks
