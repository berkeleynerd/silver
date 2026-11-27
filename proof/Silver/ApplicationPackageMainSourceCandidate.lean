module

public import Silver.ApplicationPackageMainSourceShape
import all Init.Data.Repr

@[expose] public section

/-! Reviewed Package_Main_At native tokens, including declaration-level Static
assertions and the named Input local. The original body fragment SHA256 is
3f7f7abac31594aadd81ffcd35ac50002b2a6b98b843ab35acbf7ff412dbef18.
The typed tree evaluation is proved separately; these kernel equalities check
its exact native declaration and command spelling. The final source bridge
binds this candidate to the authoritative reconstruction. -/
namespace Silver.ApplicationPackageMain.Native.SourceChecks

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def nativeHeader : List String := ["(", "sources", ":", "units", ".", "bundle", ";", "exports", ":", "parser_state", ";", "info", ":", "packages", ".", "metadata", ")", "return", "analysis_result", "with", "global", "=>", "null", ",", "pre", "=>", "units", ".", "valid", "(", "sources", ")", "and", "then", "valid_state", "(", "sources", ".", "pool", "(", "1", "..", "sources", ".", "used", ")", ",", "exports", ")", "and", "then", "packages", ".", "complete_metadata", "(", "sources", ".", "pool", "(", "1", "..", "sources", ".", "used", ")", ",", "info", ")"]

def nativeBody : List String := [
  "text", ":", "constant", "string", ":=", "sources", ".", "pool", "(", "1", "..", "sources",
  ".", "used", ")", ";", "imported", ":", "constant", "string", ":=", "imported_package", "(", "units",
  ".", "unit_source", "(", "sources", ",", "units", ".", "main_body", ")", ")", ";", "pragma",
  "assert", "(", "static", "=>", "packages", ".", "valid_metadata", "(", "text", ",", "info", ")",
  ")", ";", "pragma", "assert", "(", "static", "=>", "packages", ".", "valid_name", "(", "text",
  ",", "(", "info", ".", "name_first", ",", "info", ".", "name_after", ")", ")", ")",
  ";", "pragma", "assert", "(", "static", "=>", "valid_name_state", "(", "text", ",", "info", ".",
  "name_first", ",", "info", ".", "name_after", ")", ")", ";", "pragma", "assert", "(", "static",
  "=>", "info", ".", "units", "(", "units", ".", "main_body", ")", ".", "first", "<=",
  "text", "'", "last", "+", "1", ")", ";", "context_clauses", ":", "constant", "names", ".",
  "context_result", ":=", "names", ".", "read_context", "(", "text", ",", "sources", ".", "units", "(",
  "units", ".", "main_body", ")", ".", "first", ",", "info", ".", "name_first", ",", "info",
  ".", "name_after", ")", ";", "frame", ":", "parser_state", ";", "start", ",", "following", ":",
  "literal_position", ";", "begin", "if", "not", "same_package_spelling", "(", "text", ",", "info", ",", "imported",
  ")", "or", "else", "context_clauses", ".", "after", "=", "0", "then", "return", "invalid_analysis", ";",
  "end", "if", ";", "start", ":=", "spark_pragma_after", "(", "text", ",", "take_token", "(", "text",
  ",", "take_token", "(", "text", ",", "take_token", "(", "text", ",", "context_clauses", ".", "after",
  ",", "procedure_keyword", ")", ",", "main_name", ")", ",", "is_keyword", ")", ")", ";", "if",
  "start", "=", "0", "then", "return", "invalid_analysis", ";", "end", "if", ";", "frame", ":=",
  "imported_frame", "(", "text", ",", "exports", ",", "info", ",", "start", ")", ";", "if",
  "context_clauses", ".", "arguments_with", "then", "frame", ":=", "argument_at", "(", "text", ",", "frame", ")",
  ";", "end", "if", ";", "if", "frame", ".", "position", "=", "0", "then", "return",
  "invalid_analysis", ";", "end", "if", ";", "frame", ":=", "read_declarations", "(", "text", ",", "frame",
  ",", "context_clauses", ".", "arguments_with", ")", ";", "frame", ".", "position", ":=", "take_token", "(",
  "text", ",", "frame", ".", "position", ",", "begin_keyword", ")", ";", "if", "frame", ".",
  "position", "=", "0", "then", "return", "invalid_analysis", ";", "end", "if", ";", "declare", "context",
  ":", "constant", "body_context", ":=", "context_of", "(", "(", "frame", ",", "frame", ".", "assigned_in_functions",
  ",", "false", ")", ")", ";", "input", ":", "constant", "application_scan", ":=", "application_of", "(",
  "body_of", "(", "(", "frame", ",", "frame", ".", "assigned_in_functions", ",", "false", ")", ")",
  ")", ";", "pragma", "assert", "(", "static", "=>", "valid_state", "(", "text", ",", "frame",
  ")", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_context", "(", "text", ",",
  "context", ")", ")", ";", "pragma", "assert", "(", "static", "=>", "input", ".", "scan",
  ".", "position", "<=", "text", "'", "last", "+", "1", ")", ";", "pragma", "assert",
  "(", "static", "=>", "input", ".", "scan", ".", "target", "<=", "context", ".", "names",
  ".", "count", ")", ";", "pragma", "assert", "(", "static", "=>", "valid_flow", "(", "context",
  ",", "input", ".", "scan", ".", "facts", ")", ")", ";", "pragma", "assert", "(",
  "static", "=>", "valid_body", "(", "text", ",", "context", ",", "input", ".", "scan", ")",
  ")", ";", "pragma", "assert", "(", "static", "=>", "functions", ".", "valid_metadata", "(", "text",
  ",", "frame", ".", "functions", ")", ")", ";", "pragma", "assert", "(", "static", "=>",
  "procedures", ".", "valid_metadata", "(", "text", ",", "frame", ".", "procedures", ")", ")", ";",
  "result", ":", "constant", "application_scan", ":=", "application_tail", "(", "text", ",", "context", ",", "input",
  ",", "info", ",", "end_only", ",", "true", ",", "frame", ".", "functions", ",", "frame",
  ".", "procedures", ")", ";", "begin", "following", ":=", "take_token", "(", "text", ",", "take_token",
  "(", "text", ",", "take_token", "(", "text", ",", "result", ".", "scan", ".", "position",
  ",", "end_keyword", ")", ",", "main_name", ")", ",", "semicolon", ")", ";", "if", "following",
  "=", "0", "or", "else", "skip_at", "(", "text", ",", "following", ")", "/=", "text",
  "'", "last", "+", "1", "or", "else", "not", "paths", ".", "completed", "(", "result",
  ".", "scan", ".", "facts", ".", "path", ")", "then", "return", "invalid_analysis", ";", "end",
  "if", ";", "return", "(", "accepted", "=>", "true", ",", "package_info", "=>", "info", ",",
  "main_functions", "=>", "frame", ".", "functions", ",", "main_procedures", "=>", "frame", ".", "procedures", ",",
  "uses_arguments", "=>", "context_clauses", ".", "arguments_with", ",", "uses_assignment", "=>", "result", ".", "scan", ".",
  "assigned", ",", "uses_output", "=>", "result", ".", "scan", ".", "output", ")", ";", "end",
  ";", "end", "package_main_at", ";"
]

theorem mainHeader_exact : mainHeader = nativeHeader := by decide +kernel

set_option linter.unusedSimpArgs false in
theorem mainBody_exact : mainBody.render = nativeBody := by
  simp only [mainBody, Body.render, argumentCommands, declarationCommands, bodyCommands,
    Command.list, List.foldr, Command.render, Command.renderElse,
    mainDeclarations, bodyDeclarations, Declaration.render, mainAssertions, bodyAssertions,
    List.flatMap_cons, List.flatMap_nil, List.append_nil,
    ApplicationPackageBodies.Statements.Command.render]
  decide +kernel

end Silver.ApplicationPackageMain.Native.SourceChecks
