module

public import Silver.PredicateFunctionCallEquations
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.FunctionCallNative.SourceChecks
open Silver.SourceBridge

def expectedTokens (text : String) : List String := (Source.lexLine text).getD []

def actualModelSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Actual_Model'Result = 0 or else Actual_Model'Result in Position + 1 .. Text'Last + 1"

def actualModelImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position"

def actualAfterSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => (Runtime => Actual_After'Result = 0 or else Actual_After'Result in Position + 1 .. Text'Last + 1, Static => Actual_After'Result = Actual_Model (Text, Context, Position, Facts, Parameter))"

def actualAfterImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position"

def actualsModelSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index) return Literal_Position with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog) and then First <= Last and then Last <= Catalog.Parameter_Count, Post => Actuals_Model'Result = 0 or else Actuals_Model'Result in Position + 1 .. Text'Last + 1, Subprogram_Variant => (Decreases => Last - First)"

def actualsModelImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index) return Literal_Position"

def actualsAfterSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog) and then First <= Last and then Last <= Catalog.Parameter_Count, Post => (Runtime => Actuals_After'Result = 0 or else Actuals_After'Result in Position + 1 .. Text'Last + 1, Static => Actuals_After'Result = Actuals_Model (Text, Context, Position, Facts, Catalog, First, Last))"

def actualsAfterImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index) return Literal_Position"

def calleeAtSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Catalog : Functions.Metadata) return Functions.Function_Count with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Functions.Valid_Metadata (Text, Catalog), Post => Callee_At'Result <= Catalog.Count"

def calleeAtImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Catalog : Functions.Metadata) return Functions.Function_Count"

def callModelSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog), Post => Call_Model'Result.After = 0 or else Call_Model'Result.After in Position + 1 .. Text'Last + 1"

def callModelImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result"

def readCallSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog), Post => (Runtime => Read_Call'Result.After = 0 or else Read_Call'Result.After in Position + 1 .. Text'Last + 1, Static => Read_Call'Result = Call_Model (Text, Context, Position, Facts, Catalog))"

def readCallImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result"

def callAssignmentResultSpec : List String := expectedTokens
  "(Context : Body_Context; Scan : Body_Scan; Scalar : Scalar_Expressions.Binding_Count; Flag : Boolean_Count; Value : Call_Result) return Body_Scan with Global => null, Pre => Scalar <= Context.Scalar_Names.Count and then Scalar <= Scan.Count and then Flag <= Context.Boolean_Names.Count"

def callAssignmentResultImpl : List String := expectedTokens
  "(Context : Body_Context; Scan : Body_Scan; Scalar : Scalar_Expressions.Binding_Count; Flag : Boolean_Count; Value : Call_Result) return Body_Scan"

def callAssignmentModelSpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata) return Body_Scan with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan) and then Functions.Valid_Metadata (Text, Catalog)"

def callAssignmentModelImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata) return Body_Scan"

def callAssignmentBodySpec : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata) return Body_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan) and then Functions.Valid_Metadata (Text, Catalog), Post => (Runtime => Valid_Body (Text, Context, Call_Assignment_Body'Result) and then (Call_Assignment_Body'Result.Position = 0 or else Call_Assignment_Body'Result.Position > Scan.Position), Static => Call_Assignment_Body'Result = Call_Assignment_Model (Text, Context, Scan, Catalog))"

def callAssignmentBodyImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata) return Body_Scan"

structure Checked (tokens : List String) : Prop where
  trees : CheckedTrees
  included_impl : functionHeader "included" "is" tokens =
    some (expectedTokens "(Value, Bounds : Scalars.Interval) return Boolean")
  included_body : Source.expressionBody "included" tokens = some includedBody.render
  actualModel_spec : functionHeader "actual_model" ";" tokens = some actualModelSpec
  actualModel_impl : functionHeader "actual_model" "is" tokens = some actualModelImpl
  actualAfter_spec : functionHeader "actual_after" ";" tokens = some actualAfterSpec
  actualAfter_impl : functionHeader "actual_after" "is" tokens = some actualAfterImpl
  actualsModel_spec : functionHeader "actuals_model" ";" tokens = some actualsModelSpec
  actualsModel_impl : functionHeader "actuals_model" "is" tokens = some actualsModelImpl
  actualsAfter_spec : functionHeader "actuals_after" ";" tokens = some actualsAfterSpec
  actualsAfter_impl : functionHeader "actuals_after" "is" tokens = some actualsAfterImpl
  calleeAt_spec : functionHeader "callee_at" ";" tokens = some calleeAtSpec
  calleeAt_impl : functionHeader "callee_at" "is" tokens = some calleeAtImpl
  callModel_spec : functionHeader "call_model" ";" tokens = some callModelSpec
  callModel_impl : functionHeader "call_model" "is" tokens = some callModelImpl
  readCall_spec : functionHeader "read_call" ";" tokens = some readCallSpec
  readCall_impl : functionHeader "read_call" "is" tokens = some readCallImpl
  callAssignmentResult_spec : functionHeader "call_assignment_result" ";" tokens = some callAssignmentResultSpec
  callAssignmentResult_impl : functionHeader "call_assignment_result" "is" tokens = some callAssignmentResultImpl
  callAssignmentModel_spec : functionHeader "call_assignment_model" ";" tokens = some callAssignmentModelSpec
  callAssignmentModel_impl : functionHeader "call_assignment_model" "is" tokens = some callAssignmentModelImpl
  callAssignmentBody_spec : functionHeader "call_assignment_body" ";" tokens = some callAssignmentBodySpec
  callAssignmentBody_impl : functionHeader "call_assignment_body" "is" tokens = some callAssignmentBodyImpl
  actual_model_body : Source.expressionBody "actual_model" tokens = some actualBody.render
  actuals_model_body : Source.expressionBody "actuals_model" tokens = some actualsBody.render
  callee_at_body : Source.expressionBody "callee_at" tokens = some calleeBody.render
  call_model_body : Source.expressionBody "call_model" tokens = some callBody.render
  call_assignment_result_body : Source.expressionBody "call_assignment_result" tokens = some assignmentResultBody.render
  call_assignment_model_body : Source.expressionBody "call_assignment_model" tokens = some (assignmentBody false).render
  call_assignment_body_body : Source.expressionBody "call_assignment_body" tokens = some (assignmentBody true).render

end Silver.Predicate.FunctionCallNative.SourceChecks
