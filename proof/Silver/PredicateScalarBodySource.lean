module

public import Silver.PredicateScalarBodyNative
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.ScalarBodyNative.SourceChecks
open Silver.SourceBridge

def expectedTokens (text : String) : List String := (Source.lex text).getD []
def targetImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position) return Scalar_Expressions.Binding_Count"
def targetSpec : List String := targetImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1, Post => Scalar_Target'Result <= Context.Scalar_Names.Count"

def stringTargetImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position) return String_Target_Result"
def stringTargetSpec : List String := stringTargetImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1, Post => Body_String_Target'Result.Target <= Context.Names.Count and then (Body_String_Target'Result.After = 0 or else Body_String_Target'Result.After in Position + 1 .. Text'Last + 1)"

def assignmentImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan"
def assignmentModelSpec : List String := assignmentImpl ++ expectedTokens
  "with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => Valid_Body (Text, Context, Scalar_Assignment_Model'Result) and then (Scalar_Assignment_Model'Result.Position = 0 or else Scalar_Assignment_Model'Result.Position > Scan.Position)"
def assignmentSpec : List String := assignmentImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => (Runtime => Valid_Body (Text, Context, Scalar_Assignment_Body'Result) and then (Scalar_Assignment_Body'Result.Position = 0 or else Scalar_Assignment_Body'Result.Position > Scan.Position), Static => Scalar_Assignment_Body'Result =" ++ assignmentRhs.render ++ [")"]

structure Checked (tokens : List String) : Prop where
  target_body : qualifiedExpressionBody "scalar_target" tokens = some targetBody.render
  target_spec : functionHeader "scalar_target" ";" tokens = some targetSpec
  target_impl : functionHeader "scalar_target" "is" tokens = some targetImpl
  string_target_body : Source.expressionBody "body_string_target" tokens = some stringTargetBody.render
  string_target_spec : functionHeader "body_string_target" ";" tokens = some stringTargetSpec
  string_target_impl : functionHeader "body_string_target" "is" tokens = some stringTargetImpl
  assignment_body : Source.expressionBody "scalar_assignment_model" tokens = some assignmentBody.render
  assignment_model_spec : functionHeader "scalar_assignment_model" ";" tokens = some assignmentModelSpec
  assignment_model_impl : functionHeader "scalar_assignment_model" "is" tokens = some assignmentImpl
  assignment_spec : functionHeader "scalar_assignment_body" ";" tokens = some assignmentSpec
  assignment_impl : functionHeader "scalar_assignment_body" "is" tokens = some assignmentImpl

end Silver.Predicate.ScalarBodyNative.SourceChecks
