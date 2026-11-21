module

public import Silver.ProcedureBindingsNativeEquations
public import Silver.SourceDeclarations
public import Silver.ProcedureBindingsSpecCertificate
public import Silver.ProcedureBindingsBodyCertificate
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureBindings.SourceChecks
open Silver.SourceBridge

/-- The full declaration shape fixes names, types, contracts and the imperative
lookup refinement. Semantic body correspondence is checked separately below. -/
abbrev ReviewedShape : Prop :=
  Source.procedureBindingsSpecTokens = ["with", "silver_profile", ";", "with", "silver_output_lexical", ";", "with", "silver_scalars", ";", "with", "silver_array_bindings", ";", "with", "silver_function_bindings", ";", "package", "silver_procedure_bindings", "with", "spark_mode", "=>", "on", "is", "use", "silver_profile", ";", "use", "type", "silver_function_bindings", ".", "scalar_kind", ";", "use", "silver_output_lexical", ";", "max_procedures", ":", "constant", "positive", ":=", "max_source_length", "/", "32", ";", "max_formals", ":", "constant", "positive", ":=", "max_source_length", "/", "7", ";", "subtype", "procedure_count", "is", "natural", "range", "0", "..", "max_procedures", ";", "subtype", "procedure_index", "is", "positive", "range", "1", "..", "max_procedures", ";", "subtype", "formal_count", "is", "natural", "range", "0", "..", "max_formals", ";", "subtype", "formal_index", "is", "positive", "range", "1", "..", "max_formals", ";", "type", "parameter_mode", "is", "(", "input", ",", "output", ",", "input_output", ")", ";", "type", "formal", "is", "record", "first", ",", "after", ":", "literal_position", ";", "kind", ":", "silver_function_bindings", ".", "scalar_kind", ";", "bounds", ":", "silver_scalars", ".", "interval", ";", "type_id", ":", "silver_array_bindings", ".", "type_count", ":=", "0", ";", "mode", ":", "parameter_mode", ";", "end", "record", ";", "empty_formal", ":", "constant", "formal", ":=", "(", "0", ",", "0", ",", "silver_function_bindings", ".", "integer_kind", ",", "silver_scalars", ".", "empty", ",", "0", ",", "input", ")", ";", "type", "formal_array", "is", "array", "(", "formal_index", ")", "of", "formal", ";", "type", "signature", "is", "record", "first", ",", "after", ":", "literal_position", ";", "formal_first", ":", "formal_count", ";", "count", ":", "formal_count", ";", "end", "record", ";", "empty_signature", ":", "constant", "signature", ":=", "(", "0", ",", "0", ",", "0", ",", "0", ")", ";", "type", "signature_array", "is", "array", "(", "procedure_index", ")", "of", "signature", ";", "type", "metadata", "is", "record", "count", ":", "procedure_count", ";", "items", ":", "signature_array", ";", "parameter_count", ":", "formal_count", ";", "parameters", ":", "formal_array", ";", "end", "record", ";", "empty_metadata", ":", "constant", "metadata", ":=", "(", "0", ",", "(", "others", "=>", "empty_signature", ")", ",", "0", ",", "(", "others", "=>", "empty_formal", ")", ")", ";", "function", "valid_metadata", "(", "text", ":", "string", ";", "procedures", ":", "metadata", ")", "return", "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function", "valid_metadata", "(", "text", ":", "string", ";", "procedures", ":", "metadata", ")", "return", "boolean", "is", "(", "(", "for", "all", "i", "in", "1", "..", "procedures", ".", "parameter_count", "=>", "procedures", ".", "parameters", "(", "i", ")", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "procedures", ".", "parameters", "(", "i", ")", ".", "first", ",", "procedures", ".", "parameters", "(", "i", ")", ".", "after", ")", "and", "then", "not", "silver_scalars", ".", "is_empty", "(", "procedures", ".", "parameters", "(", "i", ")", ".", "bounds", ")", "and", "then", "(", "if", "procedures", ".", "parameters", "(", "i", ")", ".", "type_id", "/=", "0", "then", "procedures", ".", "parameters", "(", "i", ")", ".", "mode", "=", "input", "and", "then", "procedures", ".", "parameters", "(", "i", ")", ".", "kind", "=", "silver_function_bindings", ".", "integer_kind", ")", ")", "and", "then", "(", "for", "all", "i", "in", "1", "..", "procedures", ".", "count", "=>", "procedures", ".", "items", "(", "i", ")", ".", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "procedures", ".", "items", "(", "i", ")", ".", "first", ",", "procedures", ".", "items", "(", "i", ")", ".", "after", ")", "and", "then", "procedures", ".", "items", "(", "i", ")", ".", "count", ">", "0", "and", "then", "procedures", ".", "items", "(", "i", ")", ".", "formal_first", ">", "0", "and", "then", "procedures", ".", "items", "(", "i", ")", ".", "formal_first", "<=", "procedures", ".", "parameter_count", "and", "then", "procedures", ".", "items", "(", "i", ")", ".", "count", "<=", "procedures", ".", "parameter_count", "-", "procedures", ".", "items", "(", "i", ")", ".", "formal_first", "+", "1", ")", ")", ";", "function", "lookup_model", "(", "text", ":", "string", ";", "procedures", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "procedure_count", ")", "return", "procedure_count", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "procedures", ")", "and", "then", "index", "<=", "procedures", ".", "count", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "lookup_model", "'", "result", "<=", "index", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "index", ")", ";", "function", "lookup", "(", "text", ":", "string", ";", "procedures", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "procedure_count", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_metadata", "(", "text", ",", "procedures", ")", "and", "then", "first", "<=", "text", "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "(", "runtime", "=>", "lookup", "'", "result", "<=", "procedures", ".", "count", ",", "static", "=>", "lookup", "'", "result", "=", "lookup_model", "(", "text", ",", "procedures", ",", "first", ",", "after", ",", "procedures", ".", "count", ")", ")", ";", "function", "append_formal", "(", "procedures", ":", "metadata", ";", "item", ":", "formal", ")", "return", "metadata", "is", "(", "procedures", "with", "delta", "parameter_count", "=>", "procedures", ".", "parameter_count", "+", "1", ",", "parameters", "=>", "(", "procedures", ".", "parameters", "with", "delta", "procedures", ".", "parameter_count", "+", "1", "=>", "item", ")", ")", "with", "pre", "=>", "procedures", ".", "parameter_count", "<", "max_formals", ";", "function", "append", "(", "procedures", ":", "metadata", ";", "item", ":", "signature", ")", "return", "metadata", "is", "(", "procedures", "with", "delta", "count", "=>", "procedures", ".", "count", "+", "1", ",", "items", "=>", "(", "procedures", ".", "items", "with", "delta", "procedures", ".", "count", "+", "1", "=>", "item", ")", ")", "with", "pre", "=>", "procedures", ".", "count", "<", "max_procedures", ";", "end", "silver_procedure_bindings", ";"] ∧
  Source.procedureBindingsBodyTokens = ["package", "body", "silver_procedure_bindings", "with", "spark_mode", "=>", "on", "is", "function", "lookup_model", "(", "text", ":", "string", ";", "procedures", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ";", "index", ":", "procedure_count", ")", "return", "procedure_count", "is", "(", "if", "first", "=", "0", "or", "else", "after", "<=", "first", "or", "else", "index", "=", "0", "then", "0", "elsif", "equal_name", "(", "text", ",", "procedures", ".", "items", "(", "index", ")", ".", "first", ",", "procedures", ".", "items", "(", "index", ")", ".", "after", ",", "first", ",", "after", ")", "then", "index", "else", "lookup_model", "(", "text", ",", "procedures", ",", "first", ",", "after", ",", "index", "-", "1", ")", ")", ";", "function", "lookup", "(", "text", ":", "string", ";", "procedures", ":", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "procedure_count", "is", "index", ":", "procedure_count", ":=", "procedures", ".", "count", ";", "begin", "if", "first", "=", "0", "or", "else", "after", "<=", "first", "then", "return", "0", ";", "end", "if", ";", "while", "index", ">", "0", "loop", "pragma", "loop_invariant", "(", "index", "<=", "procedures", ".", "count", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "lookup_model", "(", "text", ",", "procedures", ",", "first", ",", "after", ",", "procedures", ".", "count", ")", "=", "lookup_model", "(", "text", ",", "procedures", ",", "first", ",", "after", ",", "index", ")", ")", ";", "pragma", "loop_variant", "(", "decreases", "=>", "index", ")", ";", "if", "equal_name", "(", "text", ",", "procedures", ".", "items", "(", "index", ")", ".", "first", ",", "procedures", ".", "items", "(", "index", ")", ".", "after", ",", "first", ",", "after", ")", "then", "return", "index", ";", "end", "if", ";", "index", ":=", "index", "-", "1", ";", "end", "loop", ";", "return", "0", ";", "end", "lookup", ";", "end", "silver_procedure_bindings", ";"]

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
  Source.expressionBody "lookup_model" Source.procedureBindingsBodyTokens = some Native.lookupBody.render ∧
  Source.expressionBody "valid_metadata" Source.procedureBindingsSpecTokens = some Native.validMetadataBody.render ∧
  postfixExpressionBody "append_formal" Source.procedureBindingsSpecTokens =
    some (Native.appendFormalBody.render, expectedTokens "with Pre => Procedures.Parameter_Count < Max_Formals") ∧
  postfixExpressionBody "append" Source.procedureBindingsSpecTokens =
    some (Native.appendBody.render, expectedTokens "with Pre => Procedures.Count < Max_Procedures")

theorem actual_expressions : ExpressionTranslation := by
  unfold ExpressionTranslation
  repeat' apply And.intro
  all_goals decide +kernel

abbrev Headers : Prop :=
  functionHeader "lookup_model" ";" Source.procedureBindingsSpecTokens =
    some (expectedTokens "(Text : String; Procedures : Metadata; First, After : Literal_Position; Index : Procedure_Count) return Procedure_Count with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Metadata (Text, Procedures) and then Index <= Procedures.Count and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => Lookup_Model'Result <= Index, Subprogram_Variant => (Decreases => Index)") ∧
  functionHeader "lookup" ";" Source.procedureBindingsSpecTokens =
    some (expectedTokens "(Text : String; Procedures : Metadata; First, After : Literal_Position) return Procedure_Count with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Metadata (Text, Procedures) and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => (Runtime => Lookup'Result <= Procedures.Count, Static => Lookup'Result = Lookup_Model (Text, Procedures, First, After, Procedures.Count))") ∧
  functionHeader "valid_metadata" ";" Source.procedureBindingsSpecTokens =
    some (expectedTokens "(Text : String; Procedures : Metadata) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length") ∧
  functionHeader "valid_metadata" "is" Source.procedureBindingsSpecTokens =
    some (expectedTokens "(Text : String; Procedures : Metadata) return Boolean") ∧
  functionHeader "append_formal" "is" Source.procedureBindingsSpecTokens =
    some (expectedTokens "(Procedures : Metadata; Item : Formal) return Metadata") ∧
  functionHeader "append" "is" Source.procedureBindingsSpecTokens =
    some (expectedTokens "(Procedures : Metadata; Item : Signature) return Metadata") ∧
  functionHeader "lookup_model" "is" Source.procedureBindingsBodyTokens =
    some (expectedTokens "(Text : String; Procedures : Metadata; First, After : Literal_Position; Index : Procedure_Count) return Procedure_Count") ∧
  functionHeader "lookup" "is" Source.procedureBindingsBodyTokens =
    some (expectedTokens "(Text : String; Procedures : Metadata; First, After : Literal_Position) return Procedure_Count")

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
input domain, including each positive formal range. -/
theorem checked_preconditions : CheckedSource ∧
    ∀ text, Native.ValidText text → ∀ procedures, Native.MetadataType procedures →
      Native.validMetadataBody.eval Native.modelCalls ({text,procedures} : Native.Context).locals =
        decide (ValidMetadata text procedures) :=
  ⟨checked_source, Native.validMetadata_meaning Native.modelCalls Native.model_primitives⟩

end Silver.ProcedureBindings.SourceChecks
