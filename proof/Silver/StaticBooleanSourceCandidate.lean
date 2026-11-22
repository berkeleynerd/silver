module

public import Silver.StaticBooleanSourceChecks
import all Init.Data.Repr

@[expose] public section

/-! Focused token proposal for the four native Boolean helpers. Final source
certification must separately instantiate Checked on the authoritative complete
source tokens. This proposal only checks the typed trees against their intended
source spelling before the expensive complete source checkpoint. -/
namespace Silver.BooleanElaboration.Native.SourceChecks
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- Fragment SHA256: da126193c948d31ae7b99e56bd30f6ee4553390b24adc1189711495c7de58302 -/
def candidateTokens : List String := [
  "type", "static_boolean_result", "is", "record", "after", ":", "literal_position", ":=", "0", ";", "value", ":",
  "boolean", ":=", "false", ";", "end", "record", ";", "invalid_static_boolean", ":", "constant", "static_boolean_result", ":=",
  "(", "others", "=>", "<", ">", ")", ";", "function", "static_boolean_at", "(", "text", ":",
  "string", ";", "frame", ":", "parser_state", ";", "position", ":", "literal_position", ")", "return", "static_boolean_result",
  "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1",
  "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state",
  "(", "text", ",", "frame", ")", "and", "then", "position", "<=", "text", "'", "last",
  "+", "1", ",", "post", "=>", "static_boolean_at", "'", "result", ".", "after", "=", "0",
  "or", "else", "static_boolean_at", "'", "result", ".", "after", "in", "position", "+", "1", "..",
  "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(",
  "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "4",
  ")", ";", "function", "static_boolean_primary", "(", "text", ":", "string", ";", "frame", ":", "parser_state",
  ";", "position", ":", "literal_position", ")", "return", "static_boolean_result", "with", "global", "=>", "null", ",",
  "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length",
  "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "frame", ")",
  "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>",
  "static_boolean_primary", "'", "result", ".", "after", "=", "0", "or", "else", "static_boolean_primary", "'", "result",
  ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1",
  ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1",
  ")", "-", "position", ",", "decreases", "=>", "1", ")", "is", "open", ":", "constant",
  "literal_position", ":=", "take_token", "(", "text", ",", "position", ",", "left_parenthesis", ")", ";", "reference",
  ":", "constant", "scalar_expressions", ".", "name_reference", ":=", "scalar_expressions", ".", "read_reference", "(", "text", ",",
  "position", ")", ";", "found", ":", "constant", "boolean_count", ":=", "lookup_boolean", "(", "text", ",",
  "frame", ".", "boolean_names", ",", "reference", ".", "first", ",", "reference", ".", "after", ",",
  "reference", ".", "qualifier_first", ",", "reference", ".", "qualifier_after", ")", ";", "result", ":", "static_boolean_result",
  ";", "begin", "if", "position", "=", "0", "then", "return", "invalid_static_boolean", ";", "end", "if",
  ";", "if", "open", "/=", "0", "then", "result", ":=", "static_boolean_at", "(", "text", ",",
  "frame", ",", "open", ")", ";", "result", ".", "after", ":=", "take_token", "(", "text",
  ",", "result", ".", "after", ",", "right_parenthesis", ")", ";", "return", "result", ";", "elsif",
  "found", "/=", "0", "and", "then", "frame", ".", "boolean_names", ".", "items", "(", "found",
  ")", ".", "known", "then", "return", "(", "reference", ".", "after", ",", "frame", ".",
  "boolean_names", ".", "items", "(", "found", ")", ".", "value", ")", ";", "elsif", "found",
  "=", "0", "and", "then", "reference", ".", "qualifier_first", "=", "0", "and", "then", "reference",
  ".", "first", "/=", "0", "and", "then", "reference", ".", "after", ">", "reference", ".",
  "first", "and", "then", "boolean_atom_after", "(", "text", ",", "context_of", "(", "(", "frame", ",",
  "false", ",", "false", ")", ")", ",", "position", ")", "/=", "0", "then", "if",
  "name_is", "(", "text", ",", "reference", ".", "first", ",", "reference", ".", "after", ",",
  "\"true\"", ")", "then", "return", "(", "reference", ".", "after", ",", "true", ")", ";",
  "elsif", "name_is", "(", "text", ",", "reference", ".", "first", ",", "reference", ".", "after",
  ",", "\"false\"", ")", "then", "return", "(", "reference", ".", "after", ",", "false", ")",
  ";", "end", "if", ";", "end", "if", ";", "return", "invalid_static_boolean", ";", "end", "static_boolean_primary",
  ";", "function", "static_boolean_factor", "(", "text", ":", "string", ";", "frame", ":", "parser_state", ";",
  "position", ":", "literal_position", ")", "return", "static_boolean_result", "with", "global", "=>", "null", ",", "pre",
  "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in",
  "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "frame", ")", "and",
  "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "static_boolean_factor",
  "'", "result", ".", "after", "=", "0", "or", "else", "static_boolean_factor", "'", "result", ".",
  "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ",",
  "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")",
  "-", "position", ",", "decreases", "=>", "2", ")", "is", "negated", ":", "constant", "literal_position",
  ":=", "take_token", "(", "text", ",", "position", ",", "not_keyword", ")", ";", "result", ":",
  "static_boolean_result", ":=", "static_boolean_primary", "(", "text", ",", "frame", ",", "(", "if", "negated", "=",
  "0", "then", "position", "else", "negated", ")", ")", ";", "begin", "if", "negated", "/=",
  "0", "then", "result", ".", "value", ":=", "not", "result", ".", "value", ";", "end",
  "if", ";", "return", "result", ";", "end", "static_boolean_factor", ";", "function", "static_boolean_relation", "(", "text",
  ":", "string", ";", "frame", ":", "parser_state", ";", "position", ":", "literal_position", ")", "return",
  "static_boolean_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then",
  "valid_state", "(", "text", ",", "frame", ")", "and", "then", "position", "<=", "text", "'",
  "last", "+", "1", ",", "post", "=>", "static_boolean_relation", "'", "result", ".", "after", "=",
  "0", "or", "else", "static_boolean_relation", "'", "result", ".", "after", "in", "position", "+", "1",
  "..", "text", "'", "last", "+", "1", ",", "subprogram_variant", "=>", "(", "decreases", "=>",
  "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>",
  "3", ")", "is", "left", ":", "constant", "scalar_expressions", ".", "expression_result", ":=", "scalar_expressions", ".",
  "read_expression", "(", "text", ",", "position", ",", "frame", ".", "scalar_names", ",", "elaborating", "=>",
  "true", ")", ";", "compare", ":", "constant", "comparison_result", ":=", "scalar_comparison_at", "(", "text", ",",
  "left", ".", "after", ")", ";", "right", ":", "scalar_expressions", ".", "expression_result", ";", "flag_left",
  ",", "flag_right", ":", "static_boolean_result", ";", "boolean_compare", ":", "comparison_result", ";", "begin", "if", "left",
  ".", "after", "/=", "0", "and", "then", "compare", ".", "after", "/=", "0", "then",
  "right", ":=", "scalar_expressions", ".", "read_expression", "(", "text", ",", "compare", ".", "after", ",",
  "frame", ".", "scalar_names", ",", "elaborating", "=>", "true", ")", ";", "if", "right", ".",
  "after", "=", "0", "or", "else", "scalars", ".", "is_empty", "(", "left", ".", "bounds",
  ")", "or", "else", "scalars", ".", "is_empty", "(", "right", ".", "bounds", ")", "or",
  "else", "left", ".", "bounds", ".", "lower", "/=", "left", ".", "bounds", ".", "upper",
  "or", "else", "right", ".", "bounds", ".", "lower", "/=", "right", ".", "bounds", ".",
  "upper", "then", "return", "invalid_static_boolean", ";", "end", "if", ";", "return", "(", "right", ".",
  "after", ",", "(", "case", "compare", ".", "operator", "is", "when", "paths", ".", "equal",
  "=>", "left", ".", "bounds", ".", "lower", "=", "right", ".", "bounds", ".", "lower",
  ",", "when", "paths", ".", "unequal", "=>", "left", ".", "bounds", ".", "lower", "/=",
  "right", ".", "bounds", ".", "lower", ",", "when", "paths", ".", "less", "=>", "left",
  ".", "bounds", ".", "lower", "<", "right", ".", "bounds", ".", "lower", ",", "when",
  "paths", ".", "less_equal", "=>", "left", ".", "bounds", ".", "lower", "<=", "right", ".",
  "bounds", ".", "lower", ",", "when", "paths", ".", "greater", "=>", "left", ".", "bounds",
  ".", "lower", ">", "right", ".", "bounds", ".", "lower", ",", "when", "paths", ".",
  "greater_equal", "=>", "left", ".", "bounds", ".", "lower", ">=", "right", ".", "bounds", ".",
  "lower", ")", ")", ";", "end", "if", ";", "flag_left", ":=", "static_boolean_factor", "(", "text",
  ",", "frame", ",", "position", ")", ";", "if", "flag_left", ".", "after", "=", "0",
  "then", "return", "invalid_static_boolean", ";", "end", "if", ";", "boolean_compare", ":=", "scalar_comparison_at", "(", "text",
  ",", "flag_left", ".", "after", ")", ";", "if", "boolean_compare", ".", "after", "=", "0",
  "then", "return", "flag_left", ";", "end", "if", ";", "if", "boolean_compare", ".", "operator", "not",
  "in", "paths", ".", "equal", "|", "paths", ".", "unequal", "then", "return", "invalid_static_boolean", ";",
  "end", "if", ";", "flag_right", ":=", "static_boolean_factor", "(", "text", ",", "frame", ",", "boolean_compare",
  ".", "after", ")", ";", "if", "flag_right", ".", "after", "=", "0", "then", "return",
  "invalid_static_boolean", ";", "end", "if", ";", "return", "(", "flag_right", ".", "after", ",", "(",
  "flag_left", ".", "value", "=", "flag_right", ".", "value", ")", "=", "(", "boolean_compare", ".",
  "operator", "=", "paths", ".", "equal", ")", ")", ";", "end", "static_boolean_relation", ";", "function",
  "static_boolean_at", "(", "text", ":", "string", ";", "frame", ":", "parser_state", ";", "position", ":",
  "literal_position", ")", "return", "static_boolean_result", "is", "result", ":", "static_boolean_result", ":=", "static_boolean_relation", "(", "text",
  ",", "frame", ",", "position", ")", ";", "operator", ",", "selected", ":", "chain_kind", ";",
  "right", ":", "static_boolean_result", ";", "begin", "if", "result", ".", "after", "=", "0", "then",
  "return", "invalid_static_boolean", ";", "end", "if", ";", "selected", ":=", "chain_token", "(", "text", ",",
  "result", ".", "after", ")", ";", "while", "selected", "/=", "no_chain", "loop", "pragma", "loop_invariant",
  "(", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last",
  "+", "1", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "result", ".", "after",
  ")", ";", "operator", ":=", "chain_token", "(", "text", ",", "result", ".", "after", ")",
  ";", "if", "operator", "=", "no_chain", "then", "return", "result", ";", "end", "if", ";",
  "if", "operator", "/=", "selected", "then", "return", "invalid_static_boolean", ";", "end", "if", ";", "right",
  ":=", "static_boolean_relation", "(", "text", ",", "frame", ",", "chain_after", "(", "text", ",", "result",
  ".", "after", ",", "operator", ")", ")", ";", "if", "right", ".", "after", "<=",
  "result", ".", "after", "then", "return", "invalid_static_boolean", ";", "end", "if", ";", "result", ".",
  "value", ":=", "(", "case", "operator", "is", "when", "eager_and", "|", "short_and", "=>", "result",
  ".", "value", "and", "right", ".", "value", ",", "when", "eager_or", "|", "short_or", "=>",
  "result", ".", "value", "or", "right", ".", "value", ",", "when", "eager_xor", "=>", "result",
  ".", "value", "xor", "right", ".", "value", ",", "when", "no_chain", "=>", "result", ".",
  "value", ")", ";", "result", ".", "after", ":=", "right", ".", "after", ";", "end",
  "loop", ";", "return", "result", ";", "end", "static_boolean_at", ";"
]

theorem candidate_checked : Checked candidateTokens where
  resultRecord := by decide +kernel
  invalid := by decide +kernel
  primaryHeader := by decide +kernel
  factorHeader := by decide +kernel
  relationHeader := by decide +kernel
  conditionSpec := by decide +kernel
  conditionImpl := by decide +kernel
  primaryBody := by
    simp only [Native.primaryBody, Native.Body.render, Native.primaryCommands,
      Native.Command.list, List.foldr, Native.Command.render, Native.Command.renderElse]
    decide +kernel
  factorBody := by
    simp only [Native.factorBody, Native.Body.render, Native.factorCommands,
      Native.Command.list, List.foldr, Native.Command.render, Native.Command.renderElse]
    decide +kernel
  relationBody := by
    simp only [Relation.render, Relation.commands, Relation.Command.list,
      List.foldr, Relation.Command.render, Relation.Command.renderElse]
    decide +kernel
  conditionBody := by
    simp only [Condition.render, Condition.prelude, Condition.commands, Condition.finish,
      Condition.Command.list, List.foldr, Condition.Command.render, Condition.Command.renderElse]
    decide +kernel

end Silver.BooleanElaboration.Native.SourceChecks
