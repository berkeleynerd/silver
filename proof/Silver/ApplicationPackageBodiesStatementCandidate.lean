module

public import Silver.ApplicationPackageBodiesStatementSource
import all Init.Data.Repr

@[expose] public section

/-! Native declaration and body tokens selected from source SHA 95c0f3b33e522adb0bec348520b196a51d8d700ef5bae754056f247fa83c9b09. -/
namespace Silver.ApplicationPackageBodies.Statement.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace StatementTokens

def forwardHeader : List String := [
  "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "input", ":", "application_scan",
  ";", "info", ":", "packages", ".", "metadata", ";", "catalog", ":", "functions", ".", "metadata",
  ";", "procedure_catalog", ":", "procedures", ".", "metadata", ")", "return", "application_scan", "with", "global", "=>",
  "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text",
  "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",",
  "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",", "input", ".",
  "scan", ")", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "catalog", ")",
  "and", "then", "procedures", ".", "valid_metadata", "(", "text", ",", "procedure_catalog", ")", ",", "post",
  "=>", "application_statement", "'", "result", ".", "count", "=", "input", ".", "count", "and", "then",
  "application_statement", "'", "result", ".", "allow_procedure_calls", "=", "input", ".", "allow_procedure_calls", "and", "then", "valid_body",
  "(", "text", ",", "context", ",", "application_statement", "'", "result", ".", "scan", ")", "and",
  "then", "(", "application_statement", "'", "result", ".", "scan", ".", "position", "=", "0", "or",
  "else", "application_statement", "'", "result", ".", "scan", ".", "position", ">", "input", ".", "scan",
  ".", "position", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'",
  "last", "+", "1", ")", "-", "input", ".", "scan", ".", "position", ",", "decreases",
  "=>", "1", ")"
]

def bodyHeader : List String := [
  "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "input", ":", "application_scan",
  ";", "info", ":", "packages", ".", "metadata", ";", "catalog", ":", "functions", ".", "metadata",
  ";", "procedure_catalog", ":", "procedures", ".", "metadata", ")", "return", "application_scan"
]

def localDeclarations : List String := [
  "result", ":", "application_scan", "(", "input", ".", "count", ")", ":=", "input", ";", "condition",
  ":", "condition_result", "(", "input", ".", "count", ")", ";", "yes", ":", "scalar_flow", "(",
  "input", ".", "count", ")", ":=", "input", ".", "scan", ".", "facts", ";", "have_yes",
  ":", "boolean", ":=", "false", ";", "first", ",", "last", ",", "start", ":", "literal_position",
  ";", "low", ",", "high", ":", "scalar_expressions", ".", "expression_result", ";", "bounds", ":", "scalars",
  ".", "interval", ";", "definite", ":", "boolean", ";"
]

def conditional : List String := [
  "begin", "if", "input", ".", "scan", ".", "position", "=", "0", "then", "return", "invalid_application",
  "(", "input", ")", ";", "end", "if", ";", "if", "take_token", "(", "text", ",",
  "input", ".", "scan", ".", "position", ",", "if_keyword", ")", "/=", "0", "then", "result",
  ".", "scan", ".", "position", ":=", "take_token", "(", "text", ",", "result", ".", "scan",
  ".", "position", ",", "if_keyword", ")", ";", "loop", "pragma", "loop_invariant", "(", "valid_body", "(",
  "text", ",", "context", ",", "result", ".", "scan", ")", ")", ";", "pragma", "loop_invariant",
  "(", "valid_flow", "(", "context", ",", "yes", ")", ")", ";", "pragma", "loop_invariant", "(",
  "result", ".", "allow_procedure_calls", "=", "input", ".", "allow_procedure_calls", ")", ";", "pragma", "loop_invariant", "(",
  "result", ".", "scan", ".", "position", ">", "input", ".", "scan", ".", "position", ")",
  ";", "pragma", "loop_variant", "(", "increases", "=>", "result", ".", "scan", ".", "position", ")",
  ";", "start", ":=", "result", ".", "scan", ".", "position", ";", "read_condition_into", "(", "text",
  ",", "context", ",", "start", ",", "result", ".", "scan", ".", "facts", ",", "condition",
  ")", ";", "if", "condition", ".", "after", "=", "0", "then", "return", "invalid_application", "(",
  "input", ")", ";", "end", "if", ";", "result", ".", "reads", ":=", "packages", ".",
  "union", "(", "result", ".", "reads", ",", "state_reads", "(", "text", ",", "context", ",",
  "info", ",", "start", ",", "condition", ".", "after", ")", ")", ";", "result", ".",
  "scan", ".", "position", ":=", "take_token", "(", "text", ",", "condition", ".", "after", ",",
  "then_keyword", ")", ";", "result", ".", "scan", ".", "facts", ":=", "condition", ".", "when_true",
  ";", "if", "result", ".", "scan", ".", "position", "<=", "start", "then", "return", "invalid_application",
  "(", "input", ")", ";", "end", "if", ";", "result", ":=", "application_tail", "(", "text",
  ",", "context", ",", "result", ",", "info", ",", "arm_boundary", ",", "true", ",", "catalog",
  ",", "procedure_catalog", ")", ";", "if", "result", ".", "scan", ".", "position", "=", "0",
  "then", "return", "invalid_application", "(", "input", ")", ";", "end", "if", ";", "if", "have_yes",
  "then", "lemma_joined_flow", "(", "context", ",", "yes", ",", "result", ".", "scan", ".", "facts",
  ")", ";", "join_into", "(", "yes", ",", "result", ".", "scan", ".", "facts", ")",
  ";", "else", "yes", ":=", "result", ".", "scan", ".", "facts", ";", "have_yes", ":=",
  "true", ";", "end", "if", ";", "result", ".", "scan", ".", "facts", ":=", "condition",
  ".", "when_false", ";", "exit", "when", "take_token", "(", "text", ",", "result", ".", "scan",
  ".", "position", ",", "elsif_keyword", ")", "=", "0", ";", "result", ".", "scan", ".",
  "position", ":=", "take_token", "(", "text", ",", "result", ".", "scan", ".", "position", ",",
  "elsif_keyword", ")", ";", "if", "result", ".", "scan", ".", "position", "<=", "start", "then",
  "return", "invalid_application", "(", "input", ")", ";", "end", "if", ";", "end", "loop", ";",
  "if", "take_token", "(", "text", ",", "result", ".", "scan", ".", "position", ",", "else_keyword",
  ")", "/=", "0", "then", "result", ".", "scan", ".", "position", ":=", "take_token", "(",
  "text", ",", "result", ".", "scan", ".", "position", ",", "else_keyword", ")", ";", "result",
  ":=", "application_tail", "(", "text", ",", "context", ",", "result", ",", "info", ",", "end_only",
  ",", "true", ",", "catalog", ",", "procedure_catalog", ")", ";", "end", "if", ";", "if",
  "result", ".", "scan", ".", "position", "=", "0", "then", "return", "invalid_application", "(", "input",
  ")", ";", "end", "if", ";", "lemma_joined_flow", "(", "context", ",", "result", ".", "scan",
  ".", "facts", ",", "yes", ")", ";", "join_into", "(", "result", ".", "scan", ".",
  "facts", ",", "yes", ")", ";", "result", ".", "scan", ":=", "body_token", "(", "text",
  ",", "context", ",", "result", ".", "scan", ",", "end_keyword", ")", ";", "result", ".",
  "scan", ":=", "body_token", "(", "text", ",", "context", ",", "result", ".", "scan", ",",
  "if_keyword", ")", ";", "result", ".", "scan", ":=", "body_token", "(", "text", ",", "context",
  ",", "result", ".", "scan", ",", "semicolon", ")", ";"
]

def loopBinder : List String := [
  "elsif", "take_token", "(", "text", ",", "input", ".", "scan", ".", "position", ",", "for_keyword",
  ")", "/=", "0", "then", "result", ".", "scan", ".", "position", ":=", "take_token", "(",
  "text", ",", "input", ".", "scan", ".", "position", ",", "for_keyword", ")", ";", "first",
  ":=", "skip_at", "(", "text", ",", "result", ".", "scan", ".", "position", ")", ";",
  "last", ":=", "name_after", "(", "text", ",", "first", ")", ";", "if", "first", "=",
  "0", "or", "else", "last", "<=", "first", "or", "else", "(", "forbidden_name", "(", "text",
  ",", "first", ",", "last", ")", "and", "then", "not", "name_is", "(", "text", ",",
  "first", ",", "last", ",", "\"string\"", ")", ")", "or", "else", "(", "context", ".",
  "dynamic_first", "/=", "0", "and", "then", "name_is", "(", "text", ",", "first", ",", "last",
  ",", "\"silver_arguments\"", ")", ")", "or", "else", "packages", ".", "same_name", "(", "text", ",",
  "(", "first", ",", "last", ")", ",", "(", "info", ".", "name_first", ",", "info",
  ".", "name_after", ")", ")", "or", "else", "context", ".", "scalar_names", ".", "count", "=",
  "scalar_expressions", ".", "max_bindings", "then", "return", "invalid_application", "(", "input", ")", ";", "end", "if",
  ";", "if", "take_token", "(", "text", ",", "last", ",", "of_keyword", ")", "/=", "0",
  "then", "if", "context", ".", "pure", "then", "return", "invalid_application", "(", "input", ")", ";",
  "end", "if", ";", "result", ".", "scan", ".", "position", ":=", "take_token", "(", "text",
  ",", "last", ",", "of_keyword", ")", ";", "if", "take_token", "(", "text", ",", "result",
  ".", "scan", ".", "position", ",", "reverse_keyword", ")", "/=", "0", "then", "result", ".",
  "scan", ".", "position", ":=", "take_token", "(", "text", ",", "result", ".", "scan", ".",
  "position", ",", "reverse_keyword", ")", ";", "end", "if", ";", "declare", "array_first", ":", "constant",
  "literal_position", ":=", "skip_at", "(", "text", ",", "result", ".", "scan", ".", "position", ")",
  ";", "array_last", ":", "constant", "literal_position", ":=", "name_after", "(", "text", ",", "array_first", ")",
  ";", "target", ":", "constant", "array_bindings", ".", "binding_count", ":=", "array_target", "(", "text", ",",
  "context", ",", "result", ".", "scan", ".", "position", ")", ";", "begin", "if", "array_first",
  "=", "0", "or", "else", "array_last", "<=", "array_first", "or", "else", "equal_name", "(", "text",
  ",", "first", ",", "last", ",", "array_first", ",", "array_last", ")", "or", "else", "target",
  "=", "0", "or", "else", "context", ".", "array_names", ".", "items", "(", "target", ")",
  ".", "mutable", "or", "else", "context", ".", "array_names", ".", "items", "(", "target", ")",
  ".", "boolean_elements", "then", "return", "invalid_application", "(", "input", ")", ";", "end", "if", ";",
  "result", ".", "scan", ".", "position", ":=", "take_token", "(", "text", ",", "array_last", ",",
  "loop_keyword", ")", ";", "bounds", ":=", "context", ".", "array_names", ".", "items", "(", "target",
  ")", ".", "component_bounds", ";", "definite", ":=", "true", ";", "end", ";", "else", "start",
  ":=", "take_token", "(", "text", ",", "last", ",", "in_keyword", ")", ";", "if", "take_token",
  "(", "text", ",", "start", ",", "reverse_keyword", ")", "/=", "0", "then", "start", ":=",
  "take_token", "(", "text", ",", "start", ",", "reverse_keyword", ")", ";", "end", "if", ";"
]

def loopBounds : List String := [
  "declare", "shape", ":", "constant", "scalar_expressions", ".", "expression_result", ":=", "scalar_expressions", ".", "read_array_attribute", "(",
  "text", ",", "start", ",", "context", ".", "scalar_names", ",", "context", ".", "array_names", ",",
  "first", ",", "last", ",", "range_query", "=>", "true", ")", ";", "begin", "if", "shape",
  ".", "after", "/=", "0", "then", "result", ".", "scan", ".", "position", ":=", "take_token",
  "(", "text", ",", "shape", ".", "after", ",", "loop_keyword", ")", ";", "bounds", ":=",
  "shape", ".", "bounds", ";", "definite", ":=", "true", ";", "else", "low", ":=", "read_counted_bound",
  "(", "text", ",", "context", ",", "start", ",", "input", ".", "scan", ".", "facts",
  ",", "first", ",", "last", ")", ";", "high", ":=", "read_counted_bound", "(", "text", ",",
  "context", ",", "take_token", "(", "text", ",", "low", ".", "after", ",", "range_delimiter", ")",
  ",", "input", ".", "scan", ".", "facts", ",", "first", ",", "last", ")", ";",
  "result", ".", "scan", ".", "position", ":=", "take_token", "(", "text", ",", "high", ".",
  "after", ",", "loop_keyword", ")", ";", "bounds", ":=", "(", "if", "scalars", ".", "is_empty",
  "(", "low", ".", "bounds", ")", "or", "else", "scalars", ".", "is_empty", "(", "high",
  ".", "bounds", ")", "then", "scalars", ".", "empty", "else", "scalars", ".", "normalize", "(",
  "(", "low", ".", "bounds", ".", "lower", ",", "high", ".", "bounds", ".", "upper",
  ")", ")", ")", ";", "definite", ":=", "not", "scalars", ".", "is_empty", "(", "low",
  ".", "bounds", ")", "and", "then", "not", "scalars", ".", "is_empty", "(", "high", ".",
  "bounds", ")", "and", "then", "low", ".", "bounds", ".", "upper", "<=", "high", ".",
  "bounds", ".", "lower", ";", "end", "if", ";", "end", ";", "result", ".", "reads",
  ":=", "packages", ".", "union", "(", "result", ".", "reads", ",", "state_reads", "(", "text",
  ",", "(", "context", "with", "delta", "mask_first", "=>", "first", ",", "mask_after", "=>", "last",
  ")", ",", "info", ",", "start", ",", "result", ".", "scan", ".", "position", ")",
  ")", ";", "end", "if", ";", "if", "result", ".", "scan", ".", "position", "<=",
  "input", ".", "scan", ".", "position", "then", "return", "invalid_application", "(", "input", ")", ";",
  "end", "if", ";", "widen_into", "(", "context", ",", "result", ".", "scan", ".", "facts",
  ")", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context", ",", "result",
  ".", "scan", ".", "facts", ")", ")", ";"
]

def loopEntry : List String := [
  "declare", "inner", ":", "body_context", ":=", "context", ";", "inside", ":", "application_scan", "(", "input",
  ".", "count", "+", "1", ")", ";", "begin", "inner", ".", "scalar_names", ".", "count",
  ":=", "inner", ".", "scalar_names", ".", "count", "+", "1", ";", "inner", ".", "scalar_names",
  ".", "items", "(", "inner", ".", "scalar_names", ".", "count", ")", ":=", "(", "first",
  ",", "last", ",", "bounds", ",", "false", ",", "bounds", ",", "false", ",", "0",
  ",", "0", ")", ";", "inside", ".", "scan", ".", "position", ":=", "result", ".",
  "scan", ".", "position", ";", "inside", ".", "scan", ".", "target", ":=", "result", ".",
  "scan", ".", "target", ";", "inside", ".", "scan", ".", "capacity", ":=", "result", ".",
  "scan", ".", "capacity", ";", "inside", ".", "scan", ".", "assigned", ":=", "result", ".",
  "scan", ".", "assigned", ";", "inside", ".", "scan", ".", "output", ":=", "result", ".",
  "scan", ".", "output", ";", "inside", ".", "allow_procedure_calls", ":=", "result", ".", "allow_procedure_calls", ";",
  "inside", ".", "reads", ":=", "result", ".", "reads", ";", "inside", ".", "writes", ":=",
  "result", ".", "writes", ";", "inside", ".", "scan", ".", "facts", ".", "path", ":=",
  "(", "if", "scalars", ".", "is_empty", "(", "bounds", ")", "then", "paths", ".", "empty_context",
  "else", "result", ".", "scan", ".", "facts", ".", "path", ")", ";", "inside", ".",
  "scan", ".", "facts", ".", "values", ":=", "(", "others", "=>", "scalars", ".", "empty",
  ")", ";", "for", "i", "in", "result", ".", "scan", ".", "facts", ".", "values",
  "'", "range", "loop", "pragma", "loop_invariant", "(", "for", "all", "done", "in", "result", ".",
  "scan", ".", "facts", ".", "values", "'", "first", "..", "i", "-", "1", "=>",
  "inside", ".", "scan", ".", "facts", ".", "values", "(", "done", ")", "=", "result",
  ".", "scan", ".", "facts", ".", "values", "(", "done", ")", ")", ";", "inside",
  ".", "scan", ".", "facts", ".", "values", "(", "i", ")", ":=", "result", ".",
  "scan", ".", "facts", ".", "values", "(", "i", ")", ";", "end", "loop", ";",
  "pragma", "assert", "(", "static", "=>", "(", "for", "all", "i", "in", "result", ".",
  "scan", ".", "facts", ".", "values", "'", "range", "=>", "inside", ".", "scan", ".",
  "facts", ".", "values", "(", "i", ")", "=", "result", ".", "scan", ".", "facts",
  ".", "values", "(", "i", ")", ")", ")", ";", "pragma", "assert", "(", "static",
  "=>", "(", "for", "all", "i", "in", "1", "..", "context", ".", "scalar_names", ".",
  "count", "=>", "inner", ".", "scalar_names", ".", "items", "(", "i", ")", "=", "context",
  ".", "scalar_names", ".", "items", "(", "i", ")", ")", ")", ";", "pragma", "assert",
  "(", "static", "=>", "inner", ".", "declaration_count", "=", "context", ".", "declaration_count", ")", ";",
  "inside", ".", "scan", ".", "facts", ".", "values", "(", "inside", ".", "count", ")",
  ":=", "bounds", ";", "pragma", "assert", "(", "static", "=>", "not", "inner", ".", "scalar_names",
  ".", "items", "(", "inside", ".", "count", ")", ".", "mutable", ")", ";", "pragma",
  "assert", "(", "static", "=>", "inside", ".", "count", ">", "inner", ".", "declaration_count", ")",
  ";", "pragma", "assert", "(", "static", "=>", "included", "(", "inside", ".", "scan", ".",
  "facts", ".", "values", "(", "inside", ".", "count", ")", ",", "inner", ".", "scalar_names",
  ".", "items", "(", "inside", ".", "count", ")", ".", "bounds", ")", ")", ";",
  "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "inner", ",", "inside", ".", "scan",
  ".", "facts", ")", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_context", "(",
  "text", ",", "inner", ")", ")", ";", "pragma", "assert", "(", "static", "=>", "inside",
  ".", "scan", ".", "position", "<=", "text", "'", "last", "+", "1", ")", ";",
  "pragma", "assert", "(", "static", "=>", "inside", ".", "scan", ".", "target", "<=", "inner",
  ".", "names", ".", "count", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_body",
  "(", "text", ",", "inner", ",", "inside", ".", "scan", ")", ")", ";"
]

def loopReturn : List String := [
  "inside", ":=", "application_tail", "(", "text", ",", "inner", ",", "inside", ",", "info", ",",
  "end_only", ",", "true", ",", "catalog", ",", "procedure_catalog", ")", ";", "if", "inside", ".",
  "scan", ".", "position", "=", "0", "then", "return", "invalid_application", "(", "input", ")", ";",
  "end", "if", ";", "result", ".", "scan", ".", "position", ":=", "inside", ".", "scan",
  ".", "position", ";", "result", ".", "scan", ".", "target", ":=", "inside", ".", "scan",
  ".", "target", ";", "result", ".", "scan", ".", "capacity", ":=", "inside", ".", "scan",
  ".", "capacity", ";", "result", ".", "scan", ".", "assigned", ":=", "inside", ".", "scan",
  ".", "assigned", ";", "result", ".", "scan", ".", "output", ":=", "inside", ".", "scan",
  ".", "output", ";", "result", ".", "reads", ":=", "inside", ".", "reads", ";", "result",
  ".", "writes", ":=", "inside", ".", "writes", ";", "if", "scalars", ".", "is_empty", "(",
  "bounds", ")", "then", "result", ".", "scan", ".", "facts", ":=", "input", ".", "scan",
  ".", "facts", ";", "elsif", "definite", "then", "result", ".", "scan", ".", "facts", ".",
  "path", ":=", "inside", ".", "scan", ".", "facts", ".", "path", ";", "else", "result",
  ".", "scan", ".", "facts", ".", "path", ":=", "paths", ".", "join", "(", "input",
  ".", "scan", ".", "facts", ".", "path", ",", "inside", ".", "scan", ".", "facts",
  ".", "path", ")", ";", "end", "if", ";", "end", ";", "result", ".", "scan",
  ":=", "body_token", "(", "text", ",", "context", ",", "result", ".", "scan", ",", "end_keyword",
  ")", ";", "result", ".", "scan", ":=", "body_token", "(", "text", ",", "context", ",",
  "result", ".", "scan", ",", "loop_keyword", ")", ";", "result", ".", "scan", ":=", "body_token",
  "(", "text", ",", "context", ",", "result", ".", "scan", ",", "semicolon", ")", ";",
  "else", "return", "application_basic", "(", "text", ",", "context", ",", "input", ",", "info", ",",
  "catalog", ",", "procedure_catalog", ")", ";", "end", "if", ";", "if", "result", ".", "scan",
  ".", "position", "<=", "input", ".", "scan", ".", "position", "or", "else", "not", "valid_body",
  "(", "text", ",", "context", ",", "result", ".", "scan", ")", "then", "return", "invalid_application",
  "(", "input", ")", ";", "end", "if", ";", "return", "result", ";", "end", "application_statement",
  ";"
]

def body : List String :=
  localDeclarations ++ conditional ++ loopBinder ++ loopBounds ++ loopEntry ++ loopReturn

end StatementTokens

def candidateTokens : List String :=
  ["function", "application_statement"] ++ StatementTokens.forwardHeader ++
    [";", "function", "application_statement"] ++ StatementTokens.bodyHeader ++ ["is"] ++ StatementTokens.body

open Silver.SourceBridge

private theorem specification_source : functionHeader "application_statement" ";" candidateTokens =
    some StatementTokens.forwardHeader := by decide +kernel

private theorem specification_spelling : StatementTokens.forwardHeader = specificationHeader := by decide +kernel

private theorem implementation_source : functionHeader "application_statement" "is" candidateTokens =
    some StatementTokens.bodyHeader := by decide +kernel

private theorem implementation_spelling : StatementTokens.bodyHeader = implementationHeader := by decide +kernel

private theorem body_source : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "application_statement" candidateTokens = some StatementTokens.body := by decide +kernel

private theorem body_render : Native.body.render Native.names = StatementTokens.body := by
  simp only [Native.body, Statements.Body.render, Native.commands, Native.ifCommands,
    Native.armCommands, Native.armRead, Native.armExit, Native.ifEnding,
    Native.forCommands, Native.forBinder, Native.forSelect, Native.forBounds, Native.arrayCommands, Native.countedCommands, Native.innerEntry,
    Native.prepareInner, Native.extendInner, Native.copyCursor, Native.copyFlags, Native.moveCursor, Native.moveFlags, Native.copyEffects,
    Native.prepareValues, Native.copyValues, Native.setIterator, Native.innerReturn, Native.returnScan, Native.returnEffects, Native.returnPath, Native.close, Native.closeToken, Native.invalid,
    Statements.Command.list, List.foldr, Statements.Command.render, Statements.Command.renderElse,
    ApplicationNative.Command.render, ApplicationPackageProcedure.Command.render]
  decide +kernel

theorem candidate_checked : Checked candidateTokens where
  tree := Native.checked_tree
  specification := specification_source.trans (congrArg some specification_spelling)
  implementation := implementation_source.trans (congrArg some implementation_spelling)
  body := body_source.trans (congrArg some body_render.symm)


end Silver.ApplicationPackageBodies.Statement.SourceChecks
