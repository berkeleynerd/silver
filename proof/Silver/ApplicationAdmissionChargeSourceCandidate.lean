module

public import Silver.ApplicationAdmissionChargeSourceShape
import all Init.Data.Repr

@[expose] public section

/-! Exact Charge_Unit fragment from frozen Output_Profile SHA256
f91894e7a0f7088abd621313e731b71424fd031783faa5d8b9a2f3a180f699da.
Fragment SHA256 (without trailing newline):
ab3b7cec5ffc69fc4ecd685d9d69d13179812fd242250d8d240c2fb76217da89.
The actual whole-source extraction is a separate checkpoint. -/
namespace Silver.ApplicationAdmission.Charge.SourceChecks

set_option maxRecDepth 10000

def candidateTokens : List String := [
  "procedure", "charge_unit", "(", "text", ":", "string", ";", "remaining", ":", "in", "out", "concatenation_count",
  ";", "accepted", ":", "out", "boolean", ")", "with", "global", "=>", "null", ",", "pre",
  "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in",
  "1", "..", "max_source_length", "is", "position", ":", "cursor", ":=", "1", ";", "first", ",",
  "after_name", ",", "after_character", ":", "literal_position", ";", "number", ":", "silver_scalar_literals", ".", "literal_result", ";",
  "quoted", ":", "value_result", ";", "charge", ":", "boolean", ";", "begin", "accepted", ":=", "false",
  ";", "loop", "pragma", "loop_invariant", "(", "position", "<=", "text", "'", "last", "+", "1",
  ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "position", ")", ";", "first", ":=",
  "skip_at", "(", "text", ",", "position", ")", ";", "if", "first", "=", "0", "then",
  "return", ";", "end", "if", ";", "if", "first", ">", "text", "'", "last", "then",
  "accepted", ":=", "true", ";", "return", ";", "end", "if", ";", "after_character", ":=", "character_literal_after",
  "(", "text", ",", "first", ")", ";", "after_name", ":=", "name_after", "(", "text", ",",
  "first", ")", ";", "number", ":=", "silver_scalar_literals", ".", "read_integer", "(", "text", ",", "first",
  ")", ";", "charge", ":=", "false", ";", "if", "after_character", "/=", "0", "then", "position",
  ":=", "after_character", ";", "elsif", "text", "(", "first", ")", "=", "character", "'", "val",
  "(", "34", ")", "then", "quoted", ":=", "literal_at", "(", "text", ",", "first", ")",
  ";", "if", "quoted", ".", "after", "=", "0", "then", "return", ";", "end", "if",
  ";", "position", ":=", "quoted", ".", "after", ";", "elsif", "after_name", "/=", "0", "then",
  "charge", ":=", "name_is", "(", "text", ",", "first", ",", "after_name", ",", "\"mod\"", ")",
  "or", "else", "name_is", "(", "text", ",", "first", ",", "after_name", ",", "\"rem\"", ")",
  ";", "position", ":=", "after_name", ";", "elsif", "number", ".", "after", "/=", "0", "then",
  "position", ":=", "number", ".", "after", ";", "elsif", "text", "(", "first", ")", "=",
  "'/'", "and", "then", "first", "<", "text", "'", "last", "and", "then", "text", "(",
  "first", "+", "1", ")", "=", "'='", "then", "position", ":=", "first", "+", "2",
  ";", "else", "charge", ":=", "text", "(", "first", ")", "in", "'&'", "|", "'+'",
  "|", "'-'", "|", "'*'", "|", "'/'", ";", "position", ":=", "first", "+", "1",
  ";", "end", "if", ";", "if", "charge", "then", "if", "remaining", "=", "0", "then",
  "return", ";", "end", "if", ";", "remaining", ":=", "remaining", "-", "1", ";", "end",
  "if", ";", "end", "loop", ";", "end", "charge_unit", ";"]

theorem candidate_checked : Checked candidateTokens where
  tree := checked_tree
  header := by decide +kernel
  body := by
    simp only [Charge.body, Control.Body.render, iteration, select, decrement,
      Control.Statement.list, List.foldr, Control.Statement.render, Control.Statement.renderElse]
    decide +kernel

end Silver.ApplicationAdmission.Charge.SourceChecks
