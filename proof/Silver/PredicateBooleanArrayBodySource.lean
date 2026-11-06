module

public import Silver.PredicateBooleanArrayBodyNative
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.BooleanArrayBodyNative.SourceChecks
open Silver.SourceBridge

def expectedTokens (text : String) : List String := (Source.lexLine text).getD []
def targetImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position) return Array_Bindings.Binding_Count"
def targetSpec : List String := targetImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1, Post => Array_Target'Result <= Context.Array_Names.Count"

def assignmentImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan"
def assignmentModelSpec : List String := assignmentImpl ++ expectedTokens
  "with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => Valid_Body (Text, Context, Boolean_Array_Assignment_Model'Result) and then (Boolean_Array_Assignment_Model'Result.Position = 0 or else Boolean_Array_Assignment_Model'Result.Position > Scan.Position)"
def assignmentSpec : List String := assignmentImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => (Runtime => Valid_Body (Text, Context, Boolean_Array_Assignment_Body'Result) and then (Boolean_Array_Assignment_Body'Result.Position = 0 or else Boolean_Array_Assignment_Body'Result.Position > Scan.Position), Static => Boolean_Array_Assignment_Body'Result =" ++ (Compose.Expressions.call "boolean_array_assignment_model" [["text"], ["context"], ["scan"]]) ++ [")"]

structure Checked (tokens : List String) : Prop where
  precedence : targetBody.wellFormed = true ∧ assignmentBody.wellFormed = true
  scopes : targetBody.scoped {} = true ∧ assignmentBody.scoped {} = true
  target_body : qualifiedExpressionBody "array_target" tokens = some targetBody.render
  target_spec : functionHeader "array_target" ";" tokens = some targetSpec
  target_impl : functionHeader "array_target" "is" tokens = some targetImpl
  assignment_body : Source.expressionBody "boolean_array_assignment_model" tokens = some assignmentBody.render
  assignment_model_spec : functionHeader "boolean_array_assignment_model" ";" tokens = some assignmentModelSpec
  assignment_model_impl : functionHeader "boolean_array_assignment_model" "is" tokens = some assignmentImpl
  assignment_spec : functionHeader "boolean_array_assignment_body" ";" tokens = some assignmentSpec
  assignment_impl : functionHeader "boolean_array_assignment_body" "is" tokens = some assignmentImpl

end Silver.Predicate.BooleanArrayBodyNative.SourceChecks
