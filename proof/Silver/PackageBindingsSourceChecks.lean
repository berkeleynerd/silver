module

public import Silver.PackageBindingsExpressions
public import Silver.PackageBindingsSourceShape
public import Silver.ApplicationUnitsSourceChecks
public import Silver.PackageBindingsSpecCertificate
public import Silver.PackageBindingsBodyCertificate
public import Silver.FunctionBindingsSpecCertificate
public import Silver.ProcedureBindingsSpecCertificate
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 20000000

namespace Silver.PackageBindings.SourceBridge
open Silver.SourceBridge Silver.Lexical.SourceBridge

abbrev ReviewedShape : Prop :=
  Source.packageBindingsSpecTokens = SourceShape.spec ∧ Source.packageBindingsBodyTokens = SourceShape.body

theorem actual_reviewed_shape : ReviewedShape := by decide +kernel

def specExpressions : List (String × List String) := [
  ("is_identifier", Native.isIdentifierBody.render),
  ("valid_name", Native.validNameBody.render),
  ("in_unit", Native.inUnitBody.render),
  ("same_name", Native.sameNameBody.render),
  ("union", Native.unionBody.render),
  ("within", Native.withinBody.render),
  ("complete_metadata", Native.completeMetadataBody.render)]

def bodyExpressions : List (String × List String) := [
  ("valid_metadata", Native.validMetadataBody.render),
  ("export_lookup_model", Native.exportLookupBody.render),
  ("state_lookup_model", Native.stateLookupBody.render),
  ("routine_lookup_model", Native.routineLookupBody.render)]

def expressionAspects (name : String) : List String :=
  if name == "is_identifier" then []
  else if name == "union" then ["with", "global", "=>", "null", ",", "post", "=>", "(", "for", "all", "i", "in", "state_index", "=>", "union", "'", "result", "(", "i", ")", "=", "(", "left", "(", "i", ")", "or", "right", "(", "i", ")", ")", ")"]
  else ["with", "global", "=>", "null"]

abbrev Expressions : Prop := Native.CheckedTrees ∧
  (∀ item ∈ specExpressions, expressionDeclaration item.1 Source.packageBindingsSpecTokens =
    some (item.2, expressionAspects item.1)) ∧
  (∀ item ∈ bodyExpressions, expressionDeclaration item.1 Source.packageBindingsBodyTokens = some (item.2, []))

theorem actual_expressions : Expressions := by decide +kernel

def specHeaders : List (String × String × List String) := [
  ("is_identifier", ";", ["(", "name", ":", "string", ")", "return", "boolean", "with", "global", "=>", "null"]),
  ("is_identifier", "is", ["(", "name", ":", "string", ")", "return", "boolean"]),
  ("valid_name", "is", ["(", "text", ":", "string", ";", "name", ":", "name_span", ")", "return", "boolean"]),
  ("in_unit", "is", ["(", "name", ":", "name_span", ";", "unit", ":", "silver_application_units", ".", "span", ")", "return", "boolean"]),
  ("same_name", "is", ["(", "text", ":", "string", ";", "left", ",", "right", ":", "name_span", ")", "return", "boolean"]),
  ("union", "is", ["(", "left", ",", "right", ":", "state_set", ")", "return", "state_set"]),
  ("within", "is", ["(", "effect", ":", "state_set", ";", "count", ":", "state_count_type", ")", "return", "boolean"]),
  ("valid_metadata", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ")", "return", "boolean", "with", "global", "=>", "null"]),
  ("complete_metadata", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ")", "return", "boolean"]),
  ("export_lookup_model", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "limit", ":", "export_count_type", ")", "return", "export_count_type", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "limit", "<=", "info", ".", "export_count", ",", "post", "=>", "export_lookup_model", "'", "result", "<=", "limit", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "limit", ")"]),
  ("lookup_export", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ")", "return", "export_count_type", "with", "global", "=>", "null", ",", "post", "=>", "(", "runtime", "=>", "lookup_export", "'", "result", "<=", "info", ".", "export_count", ",", "static", "=>", "lookup_export", "'", "result", "=", "export_lookup_model", "(", "text", ",", "info", ",", "name", ",", "info", ".", "export_count", ")", ")"]),
  ("state_lookup_model", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "limit", ":", "state_count_type", ")", "return", "state_count_type", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "limit", "<=", "info", ".", "state_count", ",", "post", "=>", "state_lookup_model", "'", "result", "<=", "limit", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "limit", ")"]),
  ("lookup_state", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ")", "return", "state_count_type", "with", "global", "=>", "null", ",", "post", "=>", "(", "runtime", "=>", "lookup_state", "'", "result", "<=", "info", ".", "state_count", ",", "static", "=>", "lookup_state", "'", "result", "=", "state_lookup_model", "(", "text", ",", "info", ",", "name", ",", "info", ".", "state_count", ")", ")"]),
  ("routine_lookup_model", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "limit", ":", "routine_count_type", ")", "return", "routine_count_type", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "limit", "<=", "info", ".", "routine_count", ",", "post", "=>", "routine_lookup_model", "'", "result", "<=", "limit", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "limit", ")"]),
  ("lookup_routine", ";", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "completed_only", ":", "boolean", ":=", "true", ")", "return", "routine_count_type", "with", "global", "=>", "null", ",", "pre", "=>", "info", ".", "completed", "<=", "info", ".", "routine_count", ",", "post", "=>", "(", "runtime", "=>", "lookup_routine", "'", "result", "<=", "(", "if", "completed_only", "then", "info", ".", "completed", "else", "info", ".", "routine_count", ")", ",", "static", "=>", "lookup_routine", "'", "result", "=", "routine_lookup_model", "(", "text", ",", "info", ",", "name", ",", "(", "if", "completed_only", "then", "info", ".", "completed", "else", "info", ".", "routine_count", ")", ")", ")"])]

def bodyHeaders : List (String × String × List String) := [
  ("valid_metadata", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ")", "return", "boolean"]),
  ("export_lookup_model", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "limit", ":", "export_count_type", ")", "return", "export_count_type"]),
  ("lookup_export", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ")", "return", "export_count_type"]),
  ("state_lookup_model", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "limit", ":", "state_count_type", ")", "return", "state_count_type"]),
  ("lookup_state", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ")", "return", "state_count_type"]),
  ("routine_lookup_model", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "limit", ":", "routine_count_type", ")", "return", "routine_count_type"]),
  ("lookup_routine", "is", ["(", "text", ":", "string", ";", "info", ":", "metadata", ";", "name", ":", "name_span", ";", "completed_only", ":", "boolean", ":=", "true", ")", "return", "routine_count_type"])]

def records : List (String × List String) := [
  ("name_span", ["record", "first", ",", "after", ":", "literal_position", ":=", "0", ";", "end", "record"]),
  ("export_declaration", ["record", "name", ":", "name_span", ":=", "no_name", ";", "kind", ":", "export_kind", ":=", "integer_subtype", ";", "bounds", ":", "silver_scalars", ".", "interval", ":=", "silver_scalars", ".", "empty", ";", "type_name", ":", "name_span", ":=", "no_name", ";", "type_identity", ":", "type_id", ":=", "integer_type", ";", "initializer_first", ",", "initializer_after", ":", "literal_position", ":=", "0", ";", "boolean_value", ":", "boolean", ":=", "false", ";", "end", "record"]),
  ("state_declaration", ["record", "name", ":", "name_span", ":=", "no_name", ";", "kind", ":", "silver_function_bindings", ".", "scalar_kind", ":=", "silver_function_bindings", ".", "integer_kind", ";", "type_name", ":", "name_span", ":=", "no_name", ";", "type_identity", ":", "type_id", ":=", "integer_type", ";", "declared_bounds", ":", "silver_scalars", ".", "interval", ":=", "silver_scalars", ".", "empty", ";", "initial_bounds", ":", "silver_scalars", ".", "interval", ":=", "silver_scalars", ".", "empty", ";", "initializer_first", ",", "initializer_after", ":", "literal_position", ":=", "0", ";", "boolean_initial", ":", "boolean", ":=", "false", ";", "end", "record"]),
  ("formal", ["record", "spec_name", ",", "body_name", ":", "name_span", ":=", "no_name", ";", "spec_type_name", ",", "body_type_name", ":", "name_span", ":=", "no_name", ";", "kind", ":", "silver_function_bindings", ".", "scalar_kind", ":=", "silver_function_bindings", ".", "integer_kind", ";", "bounds", ":", "silver_scalars", ".", "interval", ":=", "silver_scalars", ".", "empty", ";", "type_identity", ":", "type_id", ":=", "integer_type", ";", "mode", ":", "silver_procedure_bindings", ".", "parameter_mode", ":=", "silver_procedure_bindings", ".", "input", ";", "end", "record"]),
  ("routine", ["record", "kind", ":", "routine_kind", ":=", "procedure_routine", ";", "spec_name", ",", "body_name", ":", "name_span", ":=", "no_name", ";", "spec_first", ",", "spec_after", ":", "literal_position", ":=", "0", ";", "body_first", ",", "body_after", ":", "literal_position", ":=", "0", ";", "formal_first", ":", "formal_count_type", ":=", "0", ";", "count", ":", "formal_count_type", ":=", "0", ";", "result_kind", ":", "silver_function_bindings", ".", "scalar_kind", ":=", "silver_function_bindings", ".", "integer_kind", ";", "result_bounds", ":", "silver_scalars", ".", "interval", ":=", "silver_scalars", ".", "empty", ";", "result_type_identity", ":", "type_id", ":=", "integer_type", ";", "spec_result_name", ",", "body_result_name", ":", "name_span", ":=", "no_name", ";", "may_read", ",", "may_write", ":", "state_set", ":=", "empty_state_set", ";", "assigned", ":", "boolean", ":=", "false", ";", "end", "record"]),
  ("metadata", ["record", "name_first", ",", "name_after", ":", "literal_position", ":=", "0", ";", "body_name_first", ",", "body_name_after", ":", "literal_position", ":=", "0", ";", "units", ":", "silver_application_units", ".", "span_array", ":=", "(", "others", "=>", "(", "1", ",", "1", ")", ")", ";", "export_count", ":", "export_count_type", ":=", "0", ";", "exports", ":", "export_array", ":=", "(", "others", "=>", "(", "others", "=>", "<", ">", ")", ")", ";", "state_count", ":", "state_count_type", ":=", "0", ";", "states", ":", "state_array", ":=", "(", "others", "=>", "(", "others", "=>", "<", ">", ")", ")", ";", "routine_count", ":", "routine_count_type", ":=", "0", ";", "routines", ":", "routine_array", ":=", "(", "others", "=>", "(", "others", "=>", "<", ">", ")", ")", ";", "completed", ":", "routine_count_type", ":=", "0", ";", "parameter_count", ":", "formal_count_type", ":=", "0", ";", "parameters", ":", "formal_array", ":=", "(", "others", "=>", "(", "others", "=>", "<", ">", ")", ")", ";", "assigned", ":", "boolean", ":=", "false", ";", "end", "record"])]

def types : List (String × List String) := [
  ("export_kind", ["(", "integer_subtype", ",", "integer_constant", ",", "boolean_constant", ")"]),
  ("export_array", ["array", "(", "export_index", ")", "of", "export_declaration"]),
  ("state_array", ["array", "(", "state_index", ")", "of", "state_declaration"]),
  ("state_set", ["array", "(", "state_index", ")", "of", "boolean", "with", "pack"]),
  ("formal_array", ["array", "(", "formal_index", ")", "of", "formal"]),
  ("routine_kind", ["(", "function_routine", ",", "procedure_routine", ")"]),
  ("routine_array", ["array", "(", "routine_index", ")", "of", "routine"])]

def subtypes : List (String × List String) := [
  ("state_count_type", ["natural", "range", "0", "..", "max_states"]),
  ("state_index", ["positive", "range", "1", "..", "max_states"]),
  ("state_id", ["state_count_type"]),
  ("export_count_type", ["natural", "range", "0", "..", "max_exports"]),
  ("export_index", ["positive", "range", "1", "..", "max_exports"]),
  ("routine_count_type", ["natural", "range", "0", "..", "max_routines"]),
  ("routine_index", ["positive", "range", "1", "..", "max_routines"]),
  ("formal_count_type", ["natural", "range", "0", "..", "max_formals"]),
  ("formal_index", ["positive", "range", "1", "..", "max_formals"]),
  ("type_id", ["natural", "range", "0", "..", "max_exports", "+", "1"])]

def constants : List (String × List String) := [
  ("max_source_length", ["constant", "positive", ":=", "silver_profile", ".", "max_source_length"]),
  ("max_states", ["constant", "positive", ":=", "max_source_length", "/", "7"]),
  ("max_exports", ["constant", "positive", ":=", "max_source_length", "/", "12"]),
  ("max_routines", ["constant", "positive", ":=", "max_source_length", "/", "32"]),
  ("max_formals", ["constant", "positive", ":=", "max_source_length", "/", "7"]),
  ("no_name", ["constant", "name_span", ":=", "(", "0", ",", "0", ")"]),
  ("boolean_type", ["constant", "type_id", ":=", "0"]),
  ("integer_type", ["constant", "type_id", ":=", "1"]),
  ("empty_state_set", ["constant", "state_set", ":=", "(", "others", "=>", "false", ")"]),
  ("empty_metadata", ["constant", "metadata", ":=", "(", "others", "=>", "<", ">", ")"])]

def loops : List (String × List String) := [
  ("lookup_export", ["limit", ":", "export_count_type", ":=", "info", ".", "export_count", ";", "begin", "while", "limit", ">", "0", "loop", "pragma", "loop_invariant", "(", "limit", "<=", "info", ".", "export_count", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "export_lookup_model", "(", "text", ",", "info", ",", "name", ",", "info", ".", "export_count", ")", "=", "export_lookup_model", "(", "text", ",", "info", ",", "name", ",", "limit", ")", ")", ";", "pragma", "loop_variant", "(", "decreases", "=>", "limit", ")", ";", "if", "same_name", "(", "text", ",", "info", ".", "exports", "(", "limit", ")", ".", "name", ",", "name", ")", "then", "return", "limit", ";", "end", "if", ";", "limit", ":=", "limit", "-", "1", ";", "end", "loop", ";", "return", "0", ";", "end", "lookup_export", ";"]),
  ("lookup_state", ["limit", ":", "state_count_type", ":=", "info", ".", "state_count", ";", "begin", "while", "limit", ">", "0", "loop", "pragma", "loop_invariant", "(", "limit", "<=", "info", ".", "state_count", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "state_lookup_model", "(", "text", ",", "info", ",", "name", ",", "info", ".", "state_count", ")", "=", "state_lookup_model", "(", "text", ",", "info", ",", "name", ",", "limit", ")", ")", ";", "pragma", "loop_variant", "(", "decreases", "=>", "limit", ")", ";", "if", "same_name", "(", "text", ",", "info", ".", "states", "(", "limit", ")", ".", "name", ",", "name", ")", "then", "return", "limit", ";", "end", "if", ";", "limit", ":=", "limit", "-", "1", ";", "end", "loop", ";", "return", "0", ";", "end", "lookup_state", ";"]),
  ("lookup_routine", ["initial", ":", "constant", "routine_count_type", ":=", "(", "if", "completed_only", "then", "info", ".", "completed", "else", "info", ".", "routine_count", ")", ";", "limit", ":", "routine_count_type", ":=", "initial", ";", "begin", "while", "limit", ">", "0", "loop", "pragma", "loop_invariant", "(", "limit", "<=", "initial", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "routine_lookup_model", "(", "text", ",", "info", ",", "name", ",", "initial", ")", "=", "routine_lookup_model", "(", "text", ",", "info", ",", "name", ",", "limit", ")", ")", ";", "pragma", "loop_variant", "(", "decreases", "=>", "limit", ")", ";", "if", "same_name", "(", "text", ",", "info", ".", "routines", "(", "limit", ")", ".", "spec_name", ",", "name", ")", "then", "return", "limit", ";", "end", "if", ";", "limit", ":=", "limit", "-", "1", ";", "end", "loop", ";", "return", "0", ";", "end", "lookup_routine", ";"])]

abbrev Headers : Prop :=
  (∀ item ∈ specHeaders, functionHeader item.1 item.2.1 Source.packageBindingsSpecTokens = some item.2.2) ∧
  (∀ item ∈ bodyHeaders, functionHeader item.1 item.2.1 Source.packageBindingsBodyTokens = some item.2.2)

abbrev Declarations : Prop :=
  (∀ item ∈ records, recordDeclaration item.1 Source.packageBindingsSpecTokens = some item.2) ∧
  (∀ item ∈ types, typeDeclaration item.1 Source.packageBindingsSpecTokens = some item.2) ∧
  (∀ item ∈ subtypes, subtypeDeclaration item.1 Source.packageBindingsSpecTokens = some item.2) ∧
  (∀ item ∈ constants, Source.declaration item.1 Source.packageBindingsSpecTokens = some item.2) ∧
  typeDeclaration "scalar_kind" Source.functionBindingsSpecTokens = some (["(", "integer_kind", ",", "boolean_kind", ")"]) ∧
  typeDeclaration "parameter_mode" Source.procedureBindingsSpecTokens = some (["(", "input", ",", "output", ",", "input_output", ")"])

abbrev Loops : Prop := ∀ item ∈ loops,
  Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Source.packageBindingsBodyTokens = some item.2

theorem actual_headers : Headers := by decide +kernel
theorem actual_declarations : Declarations := by decide +kernel
theorem actual_loops : Loops := by decide +kernel

structure CheckedSource : Prop where
  specification : Source.lex Source.packageBindingsSpec = some Source.packageBindingsSpecTokens
  implementation : Source.lex Source.packageBindingsBody = some Source.packageBindingsBodyTokens
  reviewedShape : ReviewedShape
  expressions : Expressions
  headers : Headers
  declarations : Declarations
  loops : Loops
  units : ApplicationUnits.SourceBridge.CheckedSource

theorem checked_source : CheckedSource where
  specification := Source.packageBindingsSpecTokens_correct
  implementation := Source.packageBindingsBodyTokens_correct
  reviewedShape := actual_reviewed_shape
  expressions := actual_expressions
  headers := actual_headers
  declarations := actual_declarations
  loops := actual_loops
  units := ApplicationUnits.SourceBridge.checked_source

end Silver.PackageBindings.SourceBridge
