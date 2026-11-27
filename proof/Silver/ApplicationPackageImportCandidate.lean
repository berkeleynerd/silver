module

public import Silver.ApplicationPackageImportNative
public import Silver.ComposeBooleanDeclarationSource
import all Init.Data.Repr
import all Init.Data.Int.Repr

@[expose] public section

namespace Silver.ApplicationPackageImport.Native.Source
open SourceBridge
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/-! Original native fragment. The aggregate source bridge must tie this
proposal to the authoritative full-profile certificate before delivery. -/
def candidateTokens : List String := ["function", "imported_package", "(", "main_source", ":", "string", ")", "return", "string", "is", "begin", "if", "main_source", "'", "length", "=", "0", "or", "else", "main_source", "'", "length", ">", "max_source_length", "then", "return", "\"\"", ";", "end", "if", ";", "declare", "text", ":", "constant", "string", ":=", "normalized", "(", "main_source", ")", ";", "position", ":", "literal_position", ":=", "1", ";", "candidate", ":", "silver_package_bindings", ".", "name_span", ":=", "silver_package_bindings", ".", "no_name", ";", "begin", "loop", "pragma", "loop_invariant", "(", "position", "in", "1", "..", "text", "'", "last", "+", "1", ")", ";", "pragma", "loop_invariant", "(", "candidate", ".", "first", "=", "0", "or", "else", "silver_package_bindings", ".", "valid_name", "(", "text", ",", "candidate", ")", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "position", ")", ";", "declare", "first", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "position", ")", ";", "after", ":", "constant", "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "with_clause", ":", "constant", "boolean", ":=", "first", ">", "0", "and", "then", "after", ">", "first", "and", "then", "name_is", "(", "text", ",", "first", ",", "after", ",", "\"with\"", ")", ";", "use_clause", ":", "constant", "boolean", ":=", "first", ">", "0", "and", "then", "after", ">", "first", "and", "then", "name_is", "(", "text", ",", "first", ",", "after", ",", "\"use\"", ")", ";", "begin", "exit", "when", "not", "with_clause", "and", "then", "not", "use_clause", ";", "position", ":=", "after", ";", "loop", "pragma", "loop_invariant", "(", "position", "in", "after", "..", "text", "'", "last", "+", "1", ")", ";", "pragma", "loop_invariant", "(", "candidate", ".", "first", "=", "0", "or", "else", "silver_package_bindings", ".", "valid_name", "(", "text", ",", "candidate", ")", ")", ";", "pragma", "loop_variant", "(", "increases", "=>", "position", ")", ";", "declare", "name_first", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "position", ")", ";", "name_after", ":", "constant", "literal_position", ":=", "silver_output_profile", ".", "name_after", "(", "text", ",", "name_first", ")", ";", "name", ":", "constant", "silver_package_bindings", ".", "name_span", ":=", "(", "name_first", ",", "name_after", ")", ";", "comma_after", ":", "constant", "literal_position", ":=", "take_token", "(", "text", ",", "name_after", ",", "comma", ")", ";", "semicolon_after", ":", "constant", "literal_position", ":=", "take_token", "(", "text", ",", "name_after", ",", "semicolon", ")", ";", "begin", "if", "not", "silver_package_bindings", ".", "valid_name", "(", "text", ",", "name", ")", "or", "else", "(", "comma_after", "=", "0", "and", "then", "semicolon_after", "=", "0", ")", "then", "return", "\"\"", ";", "end", "if", ";", "if", "with_clause", "and", "then", "not", "name_is", "(", "text", ",", "name_first", ",", "name_after", ",", "\"silver_io\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name_first", ",", "name_after", ",", "\"silver_arguments\"", ")", "then", "if", "candidate", ".", "first", "/=", "0", "and", "then", "not", "silver_package_bindings", ".", "same_name", "(", "text", ",", "candidate", ",", "name", ")", "then", "return", "\"\"", ";", "end", "if", ";", "candidate", ":=", "name", ";", "end", "if", ";", "if", "semicolon_after", "/=", "0", "then", "position", ":=", "semicolon_after", ";", "exit", ";", "end", "if", ";", "position", ":=", "comma_after", ";", "end", ";", "end", "loop", ";", "end", ";", "end", "loop", ";", "if", "candidate", ".", "first", "=", "0", "then", "return", "\"\"", ";", "end", "if", ";", "declare", "result_length", ":", "constant", "natural", ":=", "candidate", ".", "after", "-", "candidate", ".", "first", ";", "result", ":", "constant", "string", "(", "1", "..", "result_length", ")", ":=", "text", "(", "candidate", ".", "first", "..", "candidate", ".", "after", "-", "1", ")", ";", "begin", "return", "result", ";", "end", ";", "end", ";", "end", "imported_package", ";"]

def header : List String := expectedTokens "(Main_Source : String) return String"

structure Checked (tokens : List String) : Prop where
  trees : body.wellFormed functionNames false = true ∧
    body.scoped [(.source, "main_source")] [] = true ∧ body.namedCorrect (fun _ => []) = true
  header : functionHeader "imported_package" "is" tokens = some header
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "imported_package" tokens = some render

theorem candidate_checked : Checked candidateTokens where
  trees := trees_checked
  header := by decide +kernel
  body := by
    apply Eq.trans (b := some (candidateTokens.drop 10))
    · decide +kernel
    · apply congrArg some
      simp only [render, body, Control.Command.list, List.foldr, Control.Command.render,
        Control.Command.renderElse, rejectIf, entry, outerBody, innerBody, outerDeclarations,
        innerDeclarations, resultDeclarations]
      decide +kernel

end Silver.ApplicationPackageImport.Native.Source
