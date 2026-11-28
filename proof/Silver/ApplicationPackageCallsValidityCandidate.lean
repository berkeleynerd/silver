module

public import Silver.ApplicationPackageCallsValidityNative
import all Init.Data.Repr

@[expose] public section
namespace Silver.ApplicationPackageCalls.ValidityNative
open ApplicationNative
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-! Focused exact-source proposal; the final bridge must bind Checked to the
certified complete source tokens. -/
/- Fragment SHA256: 1ea03603b191939807bc167e7c6d5f453a5044c33541eafb7bc6089063131530 -/
def candidateTokens : List String := [
  "function", "included", "(", "value", ",", "bounds", ":", "scalars", ".", "interval", ")", "return",
  "boolean", "is", "(", "scalars", ".", "is_empty", "(", "value", ")", "or", "else", "(",
  "not", "scalars", ".", "is_empty", "(", "bounds", ")", "and", "then", "value", ".", "lower",
  ">=", "bounds", ".", "lower", "and", "then", "value", ".", "upper", "<=", "bounds", ".",
  "upper", ")", ")", ";", "function", "valid_flow", "(", "context", ":", "body_context", ";", "facts",
  ":", "scalar_flow", ")", "return", "boolean", "is", "(", "facts", ".", "count", "=", "context",
  ".", "scalar_names", ".", "count", "and", "then", "(", "for", "all", "index", "in", "facts",
  ".", "values", "'", "range", "=>", "(", "if", "context", ".", "scalar_names", ".", "items",
  "(", "index", ")", ".", "mutable", "then", "not", "scalars", ".", "is_empty", "(", "facts",
  ".", "values", "(", "index", ")", ")", "and", "then", "included", "(", "facts", ".",
  "values", "(", "index", ")", ",", "context", ".", "scalar_names", ".", "items", "(", "index",
  ")", ".", "declared_bounds", ")", "elsif", "index", ">", "context", ".", "declaration_count", "then", "included",
  "(", "facts", ".", "values", "(", "index", ")", ",", "context", ".", "scalar_names", ".",
  "items", "(", "index", ")", ".", "bounds", ")", "else", "facts", ".", "values", "(",
  "index", ")", "=", "context", ".", "scalar_names", ".", "items", "(", "index", ")", ".",
  "bounds", ")", ")", ")", ";", "function", "valid_body", "(", "text", ":", "string", ";",
  "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return", "boolean", "with", "global",
  "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then",
  "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function", "valid_body", "(", "text",
  ":", "string", ";", "context", ":", "body_context", ";", "scan", ":", "body_scan", ")", "return",
  "boolean", "is", "(", "scan", ".", "position", "<=", "text", "'", "last", "+", "1",
  "and", "then", "scan", ".", "target", "<=", "context", ".", "names", ".", "count", "and",
  "then", "valid_flow", "(", "context", ",", "scan", ".", "facts", ")", ")", ";"
]

theorem candidate_checked : Checked candidateTokens where
  includedHeader := by decide +kernel
  includedBody := by decide +kernel
  flowHeader := by decide +kernel
  flowBody := by decide +kernel
  bodySpecification := by decide +kernel
  bodyHeader := by decide +kernel
  bodyBody := by decide +kernel

end Silver.ApplicationPackageCalls.ValidityNative
