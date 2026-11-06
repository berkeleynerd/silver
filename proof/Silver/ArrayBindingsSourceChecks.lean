module

public import Silver.ArrayBindingsNativeEquations
public import Silver.SourceDeclarations
public import Silver.ArrayBindingsSpecCertificate
public import Silver.ArrayBindingsBodyCertificate
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ArrayBindings.SourceChecks
open Silver.SourceBridge Silver.Lexical.SourceBridge

abbrev ReviewedShape : Prop :=
  Source.arrayBindingsSpecTokens = ["with", "silver_profile", ";", "with", "silver_output_lexical", ";", "with", "silver_scalars", ";", "package", "silver_array_bindings", "with", "spark_mode", "=>", "on", "is", "use", "silver_profile", ";", "use", "silver_output_lexical", ";", "package", "scalars", "renames", "silver_scalars", ";", "use", "type", "scalars", ".", "wide", ";", "use", "type", "scalars", ".", "interval", ";", "max_bindings", ":", "constant", "positive", ":=", "max_source_length", "/", "24", ";", "max_elements", ":", "constant", "positive", ":=", "max_source_length", "/", "2", ";", "subtype", "binding_count", "is", "natural", "range", "0", "..", "max_bindings", ";", "subtype", "binding_index", "is", "positive", "range", "1", "..", "max_bindings", ";", "subtype", "element_count", "is", "natural", "range", "0", "..", "max_elements", ";", "subtype", "element_index", "is", "positive", "range", "1", "..", "max_elements", ";", "type", "element_array", "is", "array", "(", "element_index", ")", "of", "scalars", ".", "value", ";", "type", "binding", "is", "record", "first", ",", "after", ":", "literal_position", ";", "bounds", ":", "scalars", ".", "interval", ";", "offset", ",", "length", ":", "element_count", ";", "mutable", ":", "boolean", ";", "component_bounds", ":", "scalars", ".", "interval", ";", "boolean_elements", ":", "boolean", ":=", "false", ";", "end", "record", ";", "empty_binding", ":", "constant", "binding", ":=", "(", "0", ",", "0", ",", "scalars", ".", "empty", ",", "0", ",", "0", ",", "false", ",", "scalars", ".", "full", ",", "false", ")", ";", "type", "binding_array", "is", "array", "(", "binding_index", ")", "of", "binding", ";", "type", "metadata", "is", "record", "count", ":", "binding_count", ";", "items", ":", "binding_array", ";", "end", "record", ";", "empty_metadata", ":", "constant", "metadata", ":=", "(", "0", ",", "(", "others", "=>", "empty_binding", ")", ")", ";", "empty_values", ":", "constant", "element_array", ":=", "(", "others", "=>", "0", ")", ";", "type", "environment", "is", "record", "names", ":", "metadata", ";", "used", ":", "element_count", ";", "values", ":", "element_array", ";", "end", "record", ";", "empty_environment", ":", "constant", "environment", ":=", "(", "empty_metadata", ",", "0", ",", "empty_values", ")", ";", "function", "valid_binding", "(", "item", ":", "binding", ")", "return", "boolean", "is", "(", "not", "scalars", ".", "is_empty", "(", "item", ".", "bounds", ")", "and", "then", "item", ".", "length", ">", "0", "and", "then", "item", ".", "offset", "<=", "max_elements", "-", "item", ".", "length", "and", "then", "scalars", ".", "wide", "(", "item", ".", "bounds", ".", "upper", ")", "-", "scalars", ".", "wide", "(", "item", ".", "bounds", ".", "lower", ")", "=", "scalars", ".", "wide", "(", "item", ".", "length", ")", "-", "1", "and", "then", "not", "scalars", ".", "is_empty", "(", "item", ".", "component_bounds", ")", ")", ";", "function", "valid_metadata", "(", "text", ":", "string", ";", "names", ":", "metadata", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function", "valid_metadata", "(", "text", ":", "string", ";", "names", ":", "metadata", ")", "return", "boolean", "is", "(", "for", "all", "index", "in", "1", "..", "names", ".", "count", "=>", "names", ".", "items", "(", "index", ")", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "names", ".", "items", "(", "index", ")", ".", "first", ",", "names", ".", "items", "(", "index", ")", ".", "after", ")", "and", "then", "valid_binding", "(", "names", ".", "items", "(", "index", ")", ")", "and", "then", "(", "if", "index", ">", "1", "then", "names", ".", "items", "(", "index", ")", ".", "offset", ">=", "names", ".", "items", "(", "index", "-", "1", ")", ".", "offset", "+", "names", ".", "items", "(", "index", "-", "1", ")", ".", "length", ")", ")", ";", "function", "valid_environment", "(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function", "valid_environment", "(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean", "is", "(", "valid_metadata", "(", "text", ",", "names", ".", "names", ")", "and", "then", "(", "for", "all", "index", "in", "1", "..", "names", ".", "names", ".", "count", "=>", "names", ".", "names", ".", "items", "(", "index", ")", ".", "offset", "+", "names", ".", "names", ".", "items", "(", "index", ")", ".", "length", "<=", "names", ".", "used", ")", ")", ";", "function", "lookup_model", "(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "binding_count", ")", "return", "binding_count", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "names", ")", "and", "then", "index", "<=", "names", ".", "count", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "lookup_model", "'", "result", "<=", "index", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "index", ")", ";", "function", "lookup", "(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "binding_count", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "names", ")", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "lookup", "'", "result", "<=", "names", ".", "count", ",", "static", "=>", "lookup", "'", "result", "=", "lookup_model", "(", "text", ",", "names", ",", "first", ",", "after", ",", "names", ".", "count", ")", ")", ";", "function", "contains", "(", "item", ":", "binding", ";", "index", ":", "scalars", ".", "interval", ")", "return", "boolean", "is", "(", "not", "scalars", ".", "is_empty", "(", "index", ")", "and", "then", "index", ".", "lower", ">=", "item", ".", "bounds", ".", "lower", "and", "then", "index", ".", "upper", "<=", "item", ".", "bounds", ".", "upper", ")", ";", "function", "element_slot", "(", "item", ":", "binding", ";", "index", ":", "scalars", ".", "value", ")", "return", "element_index", "is", "(", "element_index", "(", "(", "scalars", ".", "wide", "(", "item", ".", "offset", ")", "+", "1", ")", "+", "(", "scalars", ".", "wide", "(", "index", ")", "-", "scalars", ".", "wide", "(", "item", ".", "bounds", ".", "lower", ")", ")", ")", ")", "with", "global", "=>", "null", ",", "pre", "=>", "valid_binding", "(", "item", ")", "and", "then", "contains", "(", "item", ",", "scalars", ".", "singleton", "(", "index", ")", ")", ";", "function", "hull_model", "(", "values", ":", "element_array", ";", "first", ",", "last", ":", "element_index", ")", "return", "scalars", ".", "interval", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "first", "<=", "last", ",", "post", "=>", "not", "scalars", ".", "is_empty", "(", "hull_model", "'", "result", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "last", ")", ";", "function", "read_bounds", "(", "names", ":", "metadata", ";", "values", ":", "element_array", ";", "elaborating", ":", "boolean", ";", "target", ":", "binding_index", ";", "index", ":", "scalars", ".", "interval", ")", "return", "scalars", ".", "interval", "with", "global", "=>", "null", ",", "pre", "=>", "target", "<=", "names", ".", "count", "and", "then", "valid_binding", "(", "names", ".", "items", "(", "target", ")", ")", "and", "then", "contains", "(", "names", ".", "items", "(", "target", ")", ",", "index", ")", ",", "post", "=>", "(", "runtime", "=>", "not", "scalars", ".", "is_empty", "(", "read_bounds", "'", "result", ")", ",", "static", "=>", "read_bounds", "'", "result", "=", "(", "if", "elaborating", "then", "hull_model", "(", "values", ",", "element_slot", "(", "names", ".", "items", "(", "target", ")", ",", "index", ".", "lower", ")", ",", "element_slot", "(", "names", ".", "items", "(", "target", ")", ",", "index", ".", "upper", ")", ")", "else", "names", ".", "items", "(", "target", ")", ".", "component_bounds", ")", ")", ";", "end", "silver_array_bindings", ";"] ∧
  Source.arrayBindingsBodyTokens = ["package", "body", "silver_array_bindings", "with", "spark_mode", "=>", "on", "is", "use", "type", "scalars", ".", "wide", ";", "function", "hull_model", "(", "values", ":", "element_array", ";", "first", ",", "last", ":", "element_index", ")", "return", "scalars", ".", "interval", "is", "(", "if", "first", "=", "last", "then", "scalars", ".", "singleton", "(", "values", "(", "first", ")", ")", "else", "scalars", ".", "join", "(", "hull_model", "(", "values", ",", "first", ",", "last", "-", "1", ")", ",", "scalars", ".", "singleton", "(", "values", "(", "last", ")", ")", ")", ")", ";", "function", "lookup_model", "(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "binding_count", ")", "return", "binding_count", "is", "(", "if", "first", "=", "0", "or", "else", "after", "<=", "first", "or", "else", "index", "=", "0", "then", "0", "elsif", "equal_name", "(", "text", ",", "names", ".", "items", "(", "index", ")", ".", "first", ",", "names", ".", "items", "(", "index", ")", ".", "after", ",", "first", ",", "after", ")", "then", "index", "else", "lookup_model", "(", "text", ",", "names", ",", "first", ",", "after", ",", "index", "-", "1", ")", ")", ";", "function", "lookup", "(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "binding_count", "is", "index", ":", "binding_count", ":=", "names", ".", "count", ";", "begin", "if", "first", "=", "0", "or", "else", "after", "<=", "first", "then", "return", "0", ";", "end", "if", ";", "while", "index", ">", "0", "loop", "pragma", "loop_invariant", "(", "index", "<=", "names", ".", "count", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "lookup_model", "(", "text", ",", "names", ",", "first", ",", "after", ",", "names", ".", "count", ")", "=", "lookup_model", "(", "text", ",", "names", ",", "first", ",", "after", ",", "index", ")", ")", ";", "pragma", "loop_variant", "(", "decreases", "=>", "index", ")", ";", "if", "equal_name", "(", "text", ",", "names", ".", "items", "(", "index", ")", ".", "first", ",", "names", ".", "items", "(", "index", ")", ".", "after", ",", "first", ",", "after", ")", "then", "return", "index", ";", "end", "if", ";", "index", ":=", "index", "-", "1", ";", "end", "loop", ";", "return", "0", ";", "end", "lookup", ";", "function", "read_bounds", "(", "names", ":", "metadata", ";", "values", ":", "element_array", ";", "elaborating", ":", "boolean", ";", "target", ":", "binding_index", ";", "index", ":", "scalars", ".", "interval", ")", "return", "scalars", ".", "interval", "is", "item", ":", "constant", "binding", ":=", "names", ".", "items", "(", "target", ")", ";", "begin", "if", "elaborating", "then", "declare", "first_slot", ":", "constant", "element_index", ":=", "element_slot", "(", "item", ",", "index", ".", "lower", ")", ";", "last_slot", ":", "constant", "element_index", ":=", "element_slot", "(", "item", ",", "index", ".", "upper", ")", ";", "hull", ":", "scalars", ".", "interval", ":=", "scalars", ".", "singleton", "(", "values", "(", "first_slot", ")", ")", ";", "begin", "for", "slot", "in", "first_slot", "+", "1", "..", "last_slot", "loop", "pragma", "loop_invariant", "(", "not", "scalars", ".", "is_empty", "(", "hull", ")", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "hull", "=", "hull_model", "(", "values", ",", "first_slot", ",", "slot", "-", "1", ")", ")", ";", "hull", ":=", "scalars", ".", "join", "(", "hull", ",", "scalars", ".", "singleton", "(", "values", "(", "slot", ")", ")", ")", ";", "end", "loop", ";", "return", "hull", ";", "end", ";", "else", "return", "item", ".", "component_bounds", ";", "end", "if", ";", "end", "read_bounds", ";", "end", "silver_array_bindings", ";"]

theorem actual_shape : ReviewedShape := by decide +kernel

def postfixExpressionBodies (name : String) : List String → List (List String × List String)
  | [] => []
  | "function" :: actual :: tokens =>
      let later := postfixExpressionBodies name (actual :: tokens)
      if actual == name then
        match tokens.dropWhile (· != "return") with
        | "return" :: _resultType :: "is" :: "(" :: expression =>
            match Source.balanced 1 expression with
            | some (body, "with" :: tail) =>
                match Source.declarationEnd 0 tail with
                | some contract => (body, "with" :: contract) :: later
                | none => later
            | _ => later
        | _ => later
      else later
  | _ :: tokens => postfixExpressionBodies name tokens

def postfixExpressionBody (name : String) (tokens : List String) : Option (List String × List String) :=
  match postfixExpressionBodies name tokens with
  | [body] => some body
  | _ => none

abbrev ExpressionTranslation : Prop :=
  Native.WellFormedTrees ∧
  Source.expressionBody "lookup_model" Source.arrayBindingsBodyTokens = some Native.lookupBody.render ∧
  qualifiedExpressionBody "hull_model" Source.arrayBindingsBodyTokens = some Native.hullBody.render ∧
  Source.expressionBody "contains" Source.arrayBindingsSpecTokens = some Native.containsBody.render ∧
  Source.expressionBody "valid_binding" Source.arrayBindingsSpecTokens = some Native.validBindingBody.render ∧
  Source.expressionBody "valid_metadata" Source.arrayBindingsSpecTokens = some Native.validMetadataBody.render ∧
  Source.expressionBody "valid_environment" Source.arrayBindingsSpecTokens = some Native.validEnvironmentBody.render ∧
  postfixExpressionBody "element_slot" Source.arrayBindingsSpecTokens =
    some (Native.elementSlotBody.render, expectedTokens "with Global => null, Pre => Valid_Binding (Item) and then Contains (Item, Scalars.Singleton (Index))")

theorem actual_expressions : ExpressionTranslation := by
  unfold ExpressionTranslation
  repeat' apply And.intro
  all_goals decide +kernel

abbrev Headers : Prop :=
  functionHeader "valid_binding" "is" Source.arrayBindingsSpecTokens =
    some ["(", "item", ":", "binding", ")", "return", "boolean"] ∧
  functionHeader "valid_metadata" ";" Source.arrayBindingsSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "metadata", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length"] ∧
  functionHeader "valid_metadata" "is" Source.arrayBindingsSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "metadata", ")", "return", "boolean"] ∧
  functionHeader "valid_environment" ";" Source.arrayBindingsSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length"] ∧
  functionHeader "valid_environment" "is" Source.arrayBindingsSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "environment", ")", "return", "boolean"] ∧
  functionHeader "lookup_model" ";" Source.arrayBindingsSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "binding_count", ")", "return", "binding_count", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "names", ")", "and", "then", "index", "<=", "names", ".", "count", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "lookup_model", "'", "result", "<=", "index", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "index", ")"] ∧
  functionHeader "lookup" ";" Source.arrayBindingsSpecTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "binding_count", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "names", ")", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "lookup", "'", "result", "<=", "names", ".", "count", ",", "static", "=>", "lookup", "'", "result", "=", "lookup_model", "(", "text", ",", "names", ",", "first", ",", "after", ",", "names", ".", "count", ")", ")"] ∧
  functionHeader "contains" "is" Source.arrayBindingsSpecTokens =
    some ["(", "item", ":", "binding", ";", "index", ":", "scalars", ".", "interval", ")", "return", "boolean"] ∧
  functionHeader "element_slot" "is" Source.arrayBindingsSpecTokens =
    some ["(", "item", ":", "binding", ";", "index", ":", "scalars", ".", "value", ")", "return", "element_index"] ∧
  functionHeader "hull_model" ";" Source.arrayBindingsSpecTokens =
    some ["(", "values", ":", "element_array", ";", "first", ",", "last", ":", "element_index", ")", "return", "scalars", ".", "interval", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "first", "<=", "last", ",", "post", "=>", "not", "scalars", ".", "is_empty", "(", "hull_model", "'", "result", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "last", ")"] ∧
  functionHeader "read_bounds" ";" Source.arrayBindingsSpecTokens =
    some ["(", "names", ":", "metadata", ";", "values", ":", "element_array", ";", "elaborating", ":", "boolean", ";", "target", ":", "binding_index", ";", "index", ":", "scalars", ".", "interval", ")", "return", "scalars", ".", "interval", "with", "global", "=>", "null", ",", "pre", "=>", "target", "<=", "names", ".", "count", "and", "then", "valid_binding", "(", "names", ".", "items", "(", "target", ")", ")", "and", "then", "contains", "(", "names", ".", "items", "(", "target", ")", ",", "index", ")", ",", "post", "=>", "(", "runtime", "=>", "not", "scalars", ".", "is_empty", "(", "read_bounds", "'", "result", ")", ",", "static", "=>", "read_bounds", "'", "result", "=", "(", "if", "elaborating", "then", "hull_model", "(", "values", ",", "element_slot", "(", "names", ".", "items", "(", "target", ")", ",", "index", ".", "lower", ")", ",", "element_slot", "(", "names", ".", "items", "(", "target", ")", ",", "index", ".", "upper", ")", ")", "else", "names", ".", "items", "(", "target", ")", ".", "component_bounds", ")", ")"] ∧
  functionHeader "lookup_model" "is" Source.arrayBindingsBodyTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "binding_count", ")", "return", "binding_count"] ∧
  functionHeader "lookup" "is" Source.arrayBindingsBodyTokens =
    some ["(", "text", ":", "string", ";", "names", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "binding_count"] ∧
  functionHeader "hull_model" "is" Source.arrayBindingsBodyTokens =
    some ["(", "values", ":", "element_array", ";", "first", ",", "last", ":", "element_index", ")", "return", "scalars", ".", "interval"] ∧
  functionHeader "read_bounds" "is" Source.arrayBindingsBodyTokens =
    some ["(", "names", ":", "metadata", ";", "values", ":", "element_array", ";", "elaborating", ":", "boolean", ";", "target", ":", "binding_index", ";", "index", ":", "scalars", ".", "interval", ")", "return", "scalars", ".", "interval"]

theorem actual_headers : Headers := by
  unfold Headers
  repeat' apply And.intro
  all_goals decide +kernel

structure CheckedSource : Prop where
  shape : ReviewedShape
  expressions : ExpressionTranslation
  headers : Headers

theorem checked_source : CheckedSource := ⟨actual_shape, actual_expressions, actual_headers⟩

/-- Source-checked native guards are implied by the exact mathematical helper
input domains. This covers the changed allocation/component domain rather than
relying on a header token pin alone. -/
theorem checked_preconditions : CheckedSource ∧
    (∀ text names, ValidMetadata text names →
      Native.validMetadataBody.eval Native.modelCalls ({text,names} : Native.Context).locals = true) ∧
    (∀ text environment, ValidEnvironment text environment →
      Native.validEnvironmentBody.eval Native.modelCalls ({text,environment} : Native.Context).locals = true) :=
  ⟨checked_source, Native.validMetadata_model_precondition, Native.validEnvironment_model_precondition⟩


end Silver.ArrayBindings.SourceChecks
