module

public import Silver.ApplicationPackageDeclarationsObjectSourceRequirements

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.ObjectSourceChecks
open Silver.SourceBridge

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- Copied fragment SHA256: 5ce4fc3b3d9784a4ee1fab8651d636c7ec618019b007589d1039e113bb787290 -/
def scalarCandidate : List String := [
  "type", "expression_result", "is", "record", "after", ":", "literal_position", ";", "bounds", ":", "silver_scalars", ".",
  "interval", ";", "operands", ":", "operand_count", ";", "static", ":", "boolean", ";", "end", "record",
  ";", "function", "read_expression", "(", "text", ":", "string", ";", "position", ":", "literal_position", ";",
  "names", ":", "environment", ";", "mask_first", ":", "literal_position", ":=", "0", ";", "mask_after", ":",
  "literal_position", ":=", "0", ";", "allow_sign", ":", "boolean", ":=", "true", ";", "arrays", ":",
  "silver_array_bindings", ".", "metadata", ":=", "silver_array_bindings", ".", "empty_metadata", ";", "initials", ":", "silver_array_bindings", ".",
  "element_array", ":=", "silver_array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ";",
  "array_reads", ":", "array_read_mode", ":=", "all_elements", ")", "return", "expression_result", "with", "global", "=>", "null",
  ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'",
  "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last",
  "+", "1", "and", "then", "valid_environment", "(", "text", ",", "names", ")", "and", "then",
  "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", "and", "then", "silver_array_bindings", ".",
  "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "read_expression", "'", "result",
  ".", "after", "=", "0", "or", "else", "(", "read_expression", "'", "result", ".", "after",
  "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then",
  "read_expression", "'", "result", ".", "operands", ">", "0", ")", ",", "subprogram_variant", "=>", "(",
  "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",",
  "decreases", "=>", "3", ")", ";"
]

theorem scalar_record_source :
    Silver.Lexical.SourceBridge.recordDeclaration "expression_result" scalarCandidate = some scalarRecord := by decide +kernel

theorem scalar_header_source :
    functionHeader "read_expression" ";" scalarCandidate = some scalarHeader := by decide +kernel

end Silver.ApplicationPackageDeclarations.ObjectSourceChecks
