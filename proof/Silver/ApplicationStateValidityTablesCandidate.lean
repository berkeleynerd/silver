module

public import Silver.ApplicationStateValidityTables
import all Init.Data.Repr

@[expose] public section

namespace Silver.ApplicationPackageFrames.ValidityTables.Source
open SourceBridge
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/-! Exact native expression proposals for all six local table predicates.
Full-source binding remains separate from these copied fragments. -/

def profileCandidate : List String := [
  "function", "valid_booleans", "(", "text", ":", "string", ";", "booleans", ":", "boolean_environment", ")", "return",
  "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function",
  "valid_booleans", "(", "text", ":", "string", ";", "booleans", ":", "boolean_environment", ")", "return", "boolean",
  "is", "(", "for", "all", "index", "in", "1", "..", "booleans", ".", "count", "=>",
  "booleans", ".", "items", "(", "index", ")", ".", "first", ">", "0", "and", "then",
  "valid_name_state", "(", "text", ",", "booleans", ".", "items", "(", "index", ")", ".", "first",
  ",", "booleans", ".", "items", "(", "index", ")", ".", "after", ")", "and", "then",
  "valid_name_state", "(", "text", ",", "booleans", ".", "items", "(", "index", ")", ".", "qualifier_first",
  ",", "booleans", ".", "items", "(", "index", ")", ".", "qualifier_after", ")", ")", ";",
  "function", "valid_names", "(", "text", ":", "string", ";", "names", ":", "binding_environment", ")", "return",
  "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function",
  "valid_names", "(", "text", ":", "string", ";", "names", ":", "binding_environment", ")", "return", "boolean",
  "is", "(", "for", "all", "i", "in", "1", "..", "names", ".", "count", "=>",
  "names", ".", "items", "(", "i", ")", ".", "first", ">", "0", "and", "then",
  "valid_name_state", "(", "text", ",", "names", ".", "items", "(", "i", ")", ".", "first",
  ",", "names", ".", "items", "(", "i", ")", ".", "after", ")", "and", "then",
  "names", ".", "items", "(", "i", ")", ".", "value_first", "<=", "text", "'", "last",
  "+", "1", "and", "then", "fixed_bounds_valid", "(", "names", ".", "items", "(", "i", ")",
  ".", "static_length", ",", "names", ".", "items", "(", "i", ")", ".", "dynamic", ",",
  "names", ".", "items", "(", "i", ")", ".", "is_character", ",", "names", ".", "items",
  "(", "i", ")", ".", "first_index", ",", "names", ".", "items", "(", "i", ")",
  ".", "last_index", ",", "i", ")", ")", ";", "function", "valid_subtypes", "(", "text", ":",
  "string", ";", "subtypes", ":", "subtype_environment", ")", "return", "boolean", "with", "global", "=>", "null",
  ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'",
  "length", "in", "1", "..", "max_source_length", ";", "function", "valid_subtypes", "(", "text", ":", "string",
  ";", "subtypes", ":", "subtype_environment", ")", "return", "boolean", "is", "(", "for", "all", "index",
  "in", "1", "..", "subtypes", ".", "count", "=>", "subtypes", ".", "items", "(", "index",
  ")", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "subtypes",
  ".", "items", "(", "index", ")", ".", "first", ",", "subtypes", ".", "items", "(",
  "index", ")", ".", "after", ")", "and", "then", "valid_name_state", "(", "text", ",", "subtypes",
  ".", "items", "(", "index", ")", ".", "qualifier_first", ",", "subtypes", ".", "items", "(",
  "index", ")", ".", "qualifier_after", ")", "and", "then", "not", "scalars", ".", "is_empty", "(",
  "subtypes", ".", "items", "(", "index", ")", ".", "bounds", ")", ")", ";", "function",
  "valid_mutable_bounds", "(", "scalar_names", ":", "scalar_expressions", ".", "environment", ")", "return", "boolean", "is", "(",
  "for", "all", "index", "in", "1", "..", "scalar_names", ".", "count", "=>", "(", "if",
  "scalar_names", ".", "items", "(", "index", ")", ".", "mutable", "then", "not", "scalars", ".",
  "is_empty", "(", "scalar_names", ".", "items", "(", "index", ")", ".", "bounds", ")", "and",
  "then", "scalar_names", ".", "items", "(", "index", ")", ".", "bounds", ".", "lower", ">=",
  "scalar_names", ".", "items", "(", "index", ")", ".", "declared_bounds", ".", "lower", "and", "then",
  "scalar_names", ".", "items", "(", "index", ")", ".", "bounds", ".", "upper", "<=", "scalar_names",
  ".", "items", "(", "index", ")", ".", "declared_bounds", ".", "upper", ")", ")", ";",
  "function", "valid_declaration_values", "(", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "count", ":", "scalar_expressions",
  ".", "binding_count", ")", "return", "boolean", "is", "(", "count", "<=", "scalar_names", ".", "count",
  "and", "then", "(", "for", "all", "index", "in", "1", "..", "count", "=>", "not",
  "scalars", ".", "is_empty", "(", "scalar_names", ".", "items", "(", "index", ")", ".", "bounds",
  ")", ")", ")", ";"
]

def scalarCandidate : List String := [
  "function", "valid_environment", "(", "text", ":", "string", ";", "names", ":", "environment", ")", "return",
  "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function",
  "valid_environment", "(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean",
  "is", "(", "for", "all", "index", "in", "1", "..", "names", ".", "count", "=>",
  "names", ".", "items", "(", "index", ")", ".", "first", ">", "0", "and", "then",
  "valid_name_state", "(", "text", ",", "names", ".", "items", "(", "index", ")", ".", "first",
  ",", "names", ".", "items", "(", "index", ")", ".", "after", ")", "and", "then",
  "valid_name_state", "(", "text", ",", "names", ".", "items", "(", "index", ")", ".", "qualifier_first",
  ",", "names", ".", "items", "(", "index", ")", ".", "qualifier_after", ")", ")", ";"
]

structure Checked (profile scalar : List String) : Prop where
  trees : scalarBody.wellFormed functionNames = true ∧
    scalarBody.scoped [(.source,"text"),(.scalars,"names")] = true ∧
    booleanBody.wellFormed functionNames = true ∧
    booleanBody.scoped [(.source,"text"),(.booleans,"booleans")] = true ∧
    subtypeBody.wellFormed functionNames = true ∧
    subtypeBody.scoped [(.source,"text"),(.subtypes,"subtypes")] = true ∧
    namesBody.wellFormed functionNames = true ∧
    namesBody.scoped [(.source,"text"),(.names,"names")] = true ∧
    mutableBody.wellFormed functionNames = true ∧
    mutableBody.scoped [(.scalars,"scalar_names")] = true ∧
    valuesBody.wellFormed functionNames = true ∧
    valuesBody.scoped [(.scalars,"scalar_names"),(.number,"count")] = true
  scalar : Silver.Source.expressionBody "valid_environment" scalar = some (scalarBody.render functionNames)
  boolean : Silver.Source.expressionBody "valid_booleans" profile = some (booleanBody.render functionNames)
  subtype : Silver.Source.expressionBody "valid_subtypes" profile = some (subtypeBody.render functionNames)
  names : Silver.Source.expressionBody "valid_names" profile = some (namesBody.render functionNames)
  mutable : Silver.Source.expressionBody "valid_mutable_bounds" profile = some (mutableBody.render functionNames)
  values : Silver.Source.expressionBody "valid_declaration_values" profile = some (valuesBody.render functionNames)

theorem candidate_checked : Checked profileCandidate scalarCandidate where
  trees := tables_checked
  scalar := by decide +kernel
  boolean := by decide +kernel
  subtype := by decide +kernel
  names := by decide +kernel
  mutable := by decide +kernel
  values := by decide +kernel

end Silver.ApplicationPackageFrames.ValidityTables.Source
