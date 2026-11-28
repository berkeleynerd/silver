module

public import Silver.ApplicationPackageDeclarationsObjectScalarSource
import all Init.Data.Repr
import all Init.Data.Int.Repr

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ObjectSourceChecks
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- Copied fragment SHA256: b6eba92d5e413524bea9058ae80f4f3315d8d975d4014e3b7a4a1e1a7ae26a62 -/
def profileCandidate : List String := [
  "type", "scalar_constraint_result", "is", "record", "after", ":", "literal_position", ";", "bounds", ":", "scalars", ".",
  "interval", ";", "end", "record", ";", "type", "static_boolean_result", "is", "record", "after", ":", "literal_position",
  ":=", "0", ";", "value", ":", "boolean", ":=", "false", ";", "end", "record", ";",
  "type", "package_object_result", "is", "record", "frame", ":", "parser_state", ":=", "invalid_state", ";", "name", ":",
  "packages", ".", "name_span", ":=", "packages", ".", "no_name", ";", "mark", ":", "package_type_result", ":=",
  "invalid_package_type", ";", "init_first", ",", "init_after", ":", "literal_position", ":=", "0", ";", "initial_bounds", ":",
  "scalars", ".", "interval", ":=", "scalars", ".", "empty", ";", "constant_object", ",", "boolean_value", ":",
  "boolean", ":=", "false", ";", "end", "record", ";", "invalid_package_object", ":", "constant", "package_object_result", ":=",
  "(", "others", "=>", "<", ">", ")", ";", "function", "package_object_at", "(", "text", ":",
  "string", ";", "frame", ":", "parser_state", ";", "info", ":", "packages", ".", "metadata", ";",
  "local", ":", "boolean", ":=", "false", ")", "return", "package_object_result", "with", "global", "=>", "null",
  ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'",
  "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "frame",
  ")", ",", "post", "=>", "valid_state", "(", "text", ",", "package_object_at", "'", "result", ".",
  "frame", ")", "and", "then", "package_object_at", "'", "result", ".", "init_first", "<=", "text", "'",
  "last", "+", "1", "and", "then", "package_object_at", "'", "result", ".", "init_after", "<=", "text",
  "'", "last", "+", "1", "and", "then", "(", "package_object_at", "'", "result", ".", "frame",
  ".", "position", "=", "0", "or", "else", "package_object_at", "'", "result", ".", "frame", ".",
  "position", ">", "frame", ".", "position", ")", "is", "first", ":", "constant", "literal_position", ":=",
  "skip_at", "(", "text", ",", "frame", ".", "position", ")", ";", "last", ":", "constant",
  "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "colon_end", ":", "constant",
  "literal_position", ":=", "take_token", "(", "text", ",", "last", ",", "colon", ")", ";", "constant_end",
  ":", "constant", "literal_position", ":=", "take_token", "(", "text", ",", "colon_end", ",", "constant_keyword", ")",
  ";", "result", ":", "package_object_result", ";", "constraint", ":", "scalar_constraint_result", ";", "value", ":", "scalar_expressions",
  ".", "expression_result", ";", "flag", ":", "static_boolean_result", ";", "after", ":", "literal_position", ";", "begin",
  "if", "not", "packages", ".", "valid_name", "(", "text", ",", "(", "first", ",", "last",
  ")", ")", "or", "else", "colon_end", "=", "0", "then", "return", "invalid_package_object", ";", "end",
  "if", ";", "result", ".", "name", ":=", "(", "first", ",", "last", ")", ";",
  "if", "local", "then", "result", ".", "frame", ":=", "hide_outer", "(", "text", ",", "frame",
  ",", "info", ",", "result", ".", "name", ")", ";", "elsif", "package_name_fresh", "(", "text",
  ",", "info", ",", "result", ".", "name", ")", "and", "then", "new_name_allowed", "(", "text",
  ",", "frame", ",", "first", ",", "last", ",", "false", ")", "then", "result", ".",
  "frame", ":=", "(", "frame", "with", "delta", "hiding", "=>", "hide_name", "(", "text", ",",
  "frame", ".", "hiding", ",", "first", ",", "last", ")", ")", ";", "else", "return",
  "invalid_package_object", ";", "end", "if", ";", "if", "result", ".", "frame", ".", "position", "=",
  "0", "then", "return", "invalid_package_object", ";", "end", "if", ";", "result", ".", "constant_object", ":=",
  "constant_end", "/=", "0", ";", "result", ".", "mark", ":=", "package_type_at", "(", "text", ",",
  "result", ".", "frame", ",", "info", ",", "(", "if", "constant_end", "=", "0", "then",
  "colon_end", "else", "constant_end", ")", ")", ";", "if", "result", ".", "mark", ".", "after",
  "=", "0", "then", "return", "invalid_package_object", ";", "end", "if", ";", "constraint", ":=", "(",
  "result", ".", "mark", ".", "after", ",", "result", ".", "mark", ".", "bounds", ")",
  ";", "if", "result", ".", "mark", ".", "kind", "=", "functions", ".", "integer_kind", "then",
  "constraint", ":=", "scalar_constraint_at", "(", "text", ",", "result", ".", "mark", ".", "after", ",",
  "result", ".", "frame", ".", "scalar_names", ",", "result", ".", "mark", ".", "bounds", ")",
  ";", "end", "if", ";", "result", ".", "mark", ".", "bounds", ":=", "constraint", ".",
  "bounds", ";", "result", ".", "init_first", ":=", "skip_at", "(", "text", ",", "take_token", "(",
  "text", ",", "constraint", ".", "after", ",", "assignment", ")", ")", ";", "if", "result",
  ".", "init_first", "=", "0", "then", "return", "invalid_package_object", ";", "end", "if", ";", "if",
  "result", ".", "mark", ".", "kind", "=", "functions", ".", "integer_kind", "then", "value", ":=",
  "scalar_expressions", ".", "read_expression", "(", "text", ",", "result", ".", "init_first", ",", "result", ".",
  "frame", ".", "scalar_names", ",", "first", ",", "last", ",", "elaborating", "=>", "true", ")",
  ";", "if", "value", ".", "after", "=", "0", "or", "else", "scalars", ".", "is_empty",
  "(", "value", ".", "bounds", ")", "or", "else", "not", "included", "(", "value", ".",
  "bounds", ",", "constraint", ".", "bounds", ")", "or", "else", "(", "not", "local", "and",
  "then", "value", ".", "bounds", ".", "lower", "/=", "value", ".", "bounds", ".", "upper",
  ")", "or", "else", "result", ".", "frame", ".", "scalar_names", ".", "count", "=", "scalar_expressions",
  ".", "max_bindings", "then", "return", "invalid_package_object", ";", "end", "if", ";", "result", ".", "init_after",
  ":=", "value", ".", "after", ";", "result", ".", "initial_bounds", ":=", "value", ".", "bounds",
  ";", "result", ".", "frame", ".", "scalar_names", ":=", "scalar_expressions", ".", "append", "(", "result",
  ".", "frame", ".", "scalar_names", ",", "(", "first", ",", "last", ",", "value", ".",
  "bounds", ",", "constant_end", "/=", "0", "and", "then", "value", ".", "static", ",", "constraint",
  ".", "bounds", ",", "constant_end", "=", "0", ",", "0", ",", "0", ")", ")",
  ";", "else", "after", ":=", "boolean_initializer_after", "(", "text", ",", "result", ".", "frame", ",",
  "result", ".", "init_first", ",", "first", ",", "last", ")", ";", "if", "after", "=",
  "0", "or", "else", "result", ".", "frame", ".", "boolean_names", ".", "count", "=", "max_boolean_bindings",
  "then", "return", "invalid_package_object", ";", "end", "if", ";", "if", "not", "local", "then", "flag",
  ":=", "static_boolean_at", "(", "text", ",", "result", ".", "frame", ",", "result", ".", "init_first",
  ")", ";", "if", "flag", ".", "after", "/=", "after", "then", "return", "invalid_package_object", ";",
  "end", "if", ";", "result", ".", "boolean_value", ":=", "flag", ".", "value", ";", "end",
  "if", ";", "result", ".", "init_after", ":=", "after", ";", "result", ".", "initial_bounds", ":=",
  "scalars", ".", "singleton", "(", "if", "result", ".", "boolean_value", "then", "1", "else", "0",
  ")", ";", "result", ".", "frame", ".", "boolean_names", ".", "count", ":=", "result", ".",
  "frame", ".", "boolean_names", ".", "count", "+", "1", ";", "result", ".", "frame", ".",
  "boolean_names", ".", "items", "(", "result", ".", "frame", ".", "boolean_names", ".", "count", ")",
  ":=", "(", "first", ",", "last", ",", "constant_end", "=", "0", ",", "0", ",",
  "0", ",", "not", "local", ",", "result", ".", "boolean_value", ")", ";", "end", "if",
  ";", "result", ".", "frame", ".", "position", ":=", "take_token", "(", "text", ",", "result",
  ".", "init_after", ",", "semicolon", ")", ";", "if", "result", ".", "frame", ".", "position",
  "<=", "frame", ".", "position", "then", "return", "invalid_package_object", ";", "end", "if", ";", "return",
  "result", ";", "end", "package_object_at", ";"
]

theorem candidate_checked : Checked profileCandidate scalarCandidate where
  wellFormed := ObjectNative.body_wellFormed
  bodyScopes := ObjectNative.body_scoped
  named := ObjectNative.body_namedCorrect
  bodySource := by
    simp only [ObjectNative.body, ObjectControl.Body.render, ObjectControl.Command.list,
      List.foldr, ObjectControl.Command.render, ObjectControl.Command.renderElse,
      ObjectNative.check, ObjectNative.reject, ObjectNative.set, ObjectNative.scalarBody,
      ObjectNative.booleanBody, ApplicationNative.Command.render, ApplicationNative.Command.renderElse]
    dsimp only [ObjectNative.constant, ObjectNative.localDeclaration, ApplicationNative.Declaration.render,
      ApplicationNative.Declaration.names, ApplicationNative.Expr.render, ApplicationNative.Updates.render,
      ApplicationNative.Place.expression, ApplicationNative.Field.name, ObjectNative.functionNames,
      ObjectNative.text, ObjectNative.frame, ObjectNative.info, ObjectNative.localObject,
      ObjectNative.first, ObjectNative.last, ObjectNative.colonEnd, ObjectNative.constantEnd,
      ObjectNative.result, ObjectNative.resultFrame, ObjectNative.mark, ObjectNative.constraint,
      ObjectNative.value, ObjectNative.flag, ObjectNative.after, ObjectNative.name,
      ObjectNative.isInteger, ObjectNative.scalars, ObjectNative.app2, ObjectNative.app3,
      ObjectNative.app4, ObjectNative.app5]
    decide +kernel
  headerSource := by decide +kernel
  objectType := by decide +kernel
  invalidObject := by decide +kernel
  constraintType := by decide +kernel
  staticType := by decide +kernel
  scalarType := scalar_record_source
  scalarSpecialization := scalar_header_source

end Silver.ApplicationPackageDeclarations.ObjectSourceChecks
