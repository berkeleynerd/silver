module

public import Silver.FunctionBindingsNativeEquations
public import Silver.SourceDeclarations
public import Silver.FunctionBindingsSpecCertificate
public import Silver.FunctionBindingsBodyCertificate
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionBindings.SourceChecks
open Silver.SourceBridge

/-- The full declaration shape fixes names, types, contracts and the imperative
lookup refinement. Semantic body correspondence is checked separately below. -/
abbrev ReviewedShape : Prop :=
  Source.functionBindingsSpecTokens = ["with", "silver_profile", ";", "with", "silver_output_lexical", ";", "with", "silver_scalars", ";", "package", "silver_function_bindings", "with", "spark_mode", "=>", "on", "is", "use", "silver_profile", ";", "use", "silver_output_lexical", ";", "max_functions", ":", "constant", "positive", ":=", "max_source_length", "/", "32", ";", "max_formals", ":", "constant", "positive", ":=", "max_source_length", "/", "7", ";", "subtype", "function_count", "is", "natural", "range", "0", "..", "max_functions", ";", "subtype", "function_index", "is", "positive", "range", "1", "..", "max_functions", ";", "subtype", "formal_count", "is", "natural", "range", "0", "..", "max_formals", ";", "subtype", "formal_index", "is", "positive", "range", "1", "..", "max_formals", ";", "type", "scalar_kind", "is", "(", "integer_kind", ",", "boolean_kind", ")", ";", "type", "formal", "is", "record", "first", ",", "after", ":", "literal_position", ";", "kind", ":", "scalar_kind", ";", "bounds", ":", "silver_scalars", ".", "interval", ";", "end", "record", ";", "empty_formal", ":", "constant", "formal", ":=", "(", "0", ",", "0", ",", "integer_kind", ",", "silver_scalars", ".", "empty", ")", ";", "type", "formal_array", "is", "array", "(", "formal_index", ")", "of", "formal", ";", "type", "signature", "is", "record", "first", ",", "after", ":", "literal_position", ";", "formal_first", ":", "formal_count", ";", "count", ":", "formal_count", ";", "result_kind", ":", "scalar_kind", ";", "result_bounds", ":", "silver_scalars", ".", "interval", ";", "end", "record", ";", "empty_signature", ":", "constant", "signature", ":=", "(", "0", ",", "0", ",", "0", ",", "0", ",", "integer_kind", ",", "silver_scalars", ".", "empty", ")", ";", "type", "signature_array", "is", "array", "(", "function_index", ")", "of", "signature", ";", "type", "metadata", "is", "record", "count", ":", "function_count", ";", "items", ":", "signature_array", ";", "parameter_count", ":", "formal_count", ";", "parameters", ":", "formal_array", ";", "end", "record", ";", "empty_metadata", ":", "constant", "metadata", ":=", "(", "0", ",", "(", "others", "=>", "empty_signature", ")", ",", "0", ",", "(", "others", "=>", "empty_formal", ")", ")", ";", "function", "valid_metadata", "(", "text", ":", "string", ";", "functions", ":", "metadata", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function", "valid_metadata", "(", "text", ":", "string", ";", "functions", ":", "metadata", ")", "return", "boolean", "is", "(", "(", "for", "all", "i", "in", "1", "..", "functions", ".", "parameter_count", "=>", "functions", ".", "parameters", "(", "i", ")", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "functions", ".", "parameters", "(", "i", ")", ".", "first", ",", "functions", ".", "parameters", "(", "i", ")", ".", "after", ")", "and", "then", "not", "silver_scalars", ".", "is_empty", "(", "functions", ".", "parameters", "(", "i", ")", ".", "bounds", ")", ")", "and", "then", "(", "for", "all", "i", "in", "1", "..", "functions", ".", "count", "=>", "functions", ".", "items", "(", "i", ")", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "functions", ".", "items", "(", "i", ")", ".", "first", ",", "functions", ".", "items", "(", "i", ")", ".", "after", ")", "and", "then", "functions", ".", "items", "(", "i", ")", ".", "count", ">", "0", "and", "then", "functions", ".", "items", "(", "i", ")", ".", "formal_first", ">", "0", "and", "then", "functions", ".", "items", "(", "i", ")", ".", "formal_first", "<=", "functions", ".", "parameter_count", "and", "then", "functions", ".", "items", "(", "i", ")", ".", "count", "<=", "functions", ".", "parameter_count", "-", "functions", ".", "items", "(", "i", ")", ".", "formal_first", "+", "1", "and", "then", "not", "silver_scalars", ".", "is_empty", "(", "functions", ".", "items", "(", "i", ")", ".", "result_bounds", ")", ")", ")", ";", "function", "lookup_model", "(", "text", ":", "string", ";", "functions", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "function_count", ")", "return", "function_count", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "functions", ")", "and", "then", "index", "<=", "functions", ".", "count", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "lookup_model", "'", "result", "<=", "index", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "index", ")", ";", "function", "lookup", "(", "text", ":", "string", ";", "functions", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "function_count", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "functions", ")", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "lookup", "'", "result", "<=", "functions", ".", "count", ",", "static", "=>", "lookup", "'", "result", "=", "lookup_model", "(", "text", ",", "functions", ",", "first", ",", "after", ",", "functions", ".", "count", ")", ")", ";", "function", "append_formal", "(", "functions", ":", "metadata", ";", "item", ":", "formal", ")", "return", "metadata", "is", "(", "functions", "with", "delta", "parameter_count", "=>", "functions", ".", "parameter_count", "+", "1", ",", "parameters", "=>", "(", "functions", ".", "parameters", "with", "delta", "functions", ".", "parameter_count", "+", "1", "=>", "item", ")", ")", "with", "pre", "=>", "functions", ".", "parameter_count", "<", "max_formals", ";", "function", "append", "(", "functions", ":", "metadata", ";", "item", ":", "signature", ")", "return", "metadata", "is", "(", "functions", "with", "delta", "count", "=>", "functions", ".", "count", "+", "1", ",", "items", "=>", "(", "functions", ".", "items", "with", "delta", "functions", ".", "count", "+", "1", "=>", "item", ")", ")", "with", "pre", "=>", "functions", ".", "count", "<", "max_functions", ";", "end", "silver_function_bindings", ";"] ∧
  Source.functionBindingsBodyTokens = ["package", "body", "silver_function_bindings", "with", "spark_mode", "=>", "on", "is", "function", "lookup_model", "(", "text", ":", "string", ";", "functions", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "function_count", ")", "return", "function_count", "is", "(", "if", "first", "=", "0", "or", "else", "after", "<=", "first", "or", "else", "index", "=", "0", "then", "0", "elsif", "equal_name", "(", "text", ",", "functions", ".", "items", "(", "index", ")", ".", "first", ",", "functions", ".", "items", "(", "index", ")", ".", "after", ",", "first", ",", "after", ")", "then", "index", "else", "lookup_model", "(", "text", ",", "functions", ",", "first", ",", "after", ",", "index", "-", "1", ")", ")", ";", "function", "lookup", "(", "text", ":", "string", ";", "functions", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "function_count", "is", "index", ":", "function_count", ":=", "functions", ".", "count", ";", "begin", "if", "first", "=", "0", "or", "else", "after", "<=", "first", "then", "return", "0", ";", "end", "if", ";", "while", "index", ">", "0", "loop", "pragma", "loop_invariant", "(", "index", "<=", "functions", ".", "count", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "lookup_model", "(", "text", ",", "functions", ",", "first", ",", "after", ",", "functions", ".", "count", ")", "=", "lookup_model", "(", "text", ",", "functions", ",", "first", ",", "after", ",", "index", ")", ")", ";", "pragma", "loop_variant", "(", "decreases", "=>", "index", ")", ";", "if", "equal_name", "(", "text", ",", "functions", ".", "items", "(", "index", ")", ".", "first", ",", "functions", ".", "items", "(", "index", ")", ".", "after", ",", "first", ",", "after", ")", "then", "return", "index", ";", "end", "if", ";", "index", ":=", "index", "-", "1", ";", "end", "loop", ";", "return", "0", ";", "end", "lookup", ";", "end", "silver_function_bindings", ";"]

theorem actual_shape : ReviewedShape := by decide +kernel

def postfixExpressionBodies (name : String) : List String → List (List String × List String)
  | [] => []
  | "function" :: actual :: tokens =>
      let later := postfixExpressionBodies name (actual :: tokens)
      if actual == name then
        match tokens.dropWhile (· != "return") with
        | "return" :: _resultType :: "is" :: "(" :: expression =>
            match Source.balanced 1 expression with
            | some (body, "with" :: trailing) =>
                match Source.declarationEnd 0 trailing with
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
  Source.expressionBody "lookup_model" Source.functionBindingsBodyTokens = some Native.lookupBody.render ∧
  Source.expressionBody "valid_metadata" Source.functionBindingsSpecTokens = some Native.validMetadataBody.render ∧
  postfixExpressionBody "append_formal" Source.functionBindingsSpecTokens =
    some (Native.appendFormalBody.render, expectedTokens "with Pre => Functions.Parameter_Count < Max_Formals") ∧
  postfixExpressionBody "append" Source.functionBindingsSpecTokens =
    some (Native.appendBody.render, expectedTokens "with Pre => Functions.Count < Max_Functions")

theorem actual_expressions : ExpressionTranslation := by
  unfold ExpressionTranslation
  repeat' apply And.intro
  all_goals decide +kernel

abbrev Headers : Prop :=
  functionHeader "lookup_model" ";" Source.functionBindingsSpecTokens =
    some (expectedTokens "(Text : String; Functions : Metadata; First, After : Literal_Position; Index : Function_Count) return Function_Count with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Metadata (Text, Functions) and then Index <= Functions.Count and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => Lookup_Model'Result <= Index, Subprogram_Variant => (Decreases => Index)") ∧
  functionHeader "lookup" ";" Source.functionBindingsSpecTokens =
    some (expectedTokens "(Text : String; Functions : Metadata; First, After : Literal_Position) return Function_Count with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Metadata (Text, Functions) and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => (Runtime => Lookup'Result <= Functions.Count, Static => Lookup'Result = Lookup_Model (Text, Functions, First, After, Functions.Count))") ∧
  functionHeader "valid_metadata" ";" Source.functionBindingsSpecTokens =
    some (expectedTokens "(Text : String; Functions : Metadata) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length") ∧
  functionHeader "valid_metadata" "is" Source.functionBindingsSpecTokens =
    some (expectedTokens "(Text : String; Functions : Metadata) return Boolean") ∧
  functionHeader "append_formal" "is" Source.functionBindingsSpecTokens =
    some (expectedTokens "(Functions : Metadata; Item : Formal) return Metadata") ∧
  functionHeader "append" "is" Source.functionBindingsSpecTokens =
    some (expectedTokens "(Functions : Metadata; Item : Signature) return Metadata") ∧
  functionHeader "lookup_model" "is" Source.functionBindingsBodyTokens =
    some (expectedTokens "(Text : String; Functions : Metadata; First, After : Literal_Position; Index : Function_Count) return Function_Count") ∧
  functionHeader "lookup" "is" Source.functionBindingsBodyTokens =
    some (expectedTokens "(Text : String; Functions : Metadata; First, After : Literal_Position) return Function_Count")

theorem actual_headers : Headers := by
  unfold Headers
  repeat' apply And.intro
  all_goals decide +kernel

structure CheckedSource : Prop where
  shape : ReviewedShape
  expressions : ExpressionTranslation
  headers : Headers

theorem checked_source : CheckedSource := ⟨actual_shape, actual_expressions, actual_headers⟩

/-- The source-checked metadata guard follows from the exact native helper
input domain, including each positive formal range and result subtype. -/
theorem checked_preconditions : CheckedSource ∧
    ∀ text, Native.ValidText text → ∀ functions, Native.MetadataType functions →
      Native.validMetadataBody.eval Native.modelCalls ({text,functions} : Native.Context).locals =
        decide (ValidMetadata text functions) :=
  ⟨checked_source, Native.validMetadata_meaning Native.modelCalls Native.model_primitives⟩

end Silver.FunctionBindings.SourceChecks
