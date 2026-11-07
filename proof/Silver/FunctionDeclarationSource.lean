module

public import Silver.FunctionDeclarationNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative.SourceChecks
open Silver.SourceBridge

/-- Every declared helper contract is retained, including complete static
loop-to-model postconditions. Native proof discharge remains required. -/
def headers : List (String × String × List String) := [
  ("function_type_at", ";", expectedTokens "(Text : String; State : Parser_State; Position : Literal_Position) return Function_Type_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_State (Text, State), Post => Function_Type_At'Result.After = 0 or else (Function_Type_At'Result.After in Position + 1 .. Text'Last + 1 and then not Scalars.Is_Empty (Function_Type_At'Result.Bounds))"),
  ("function_type_at", "is", expectedTokens "(Text : String; State : Parser_State; Position : Literal_Position) return Function_Type_Result"),
  ("parameter_step", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parameter_Step_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Parameter_Step'Result.State) and then (Parameter_Step'Result.State.Position = 0 or else (Parameter_Step'Result.State.Position > State.Position and then Parameter_Step'Result.State.Functions.Count = State.Functions.Count and then Parameter_Step'Result.State.Functions.Parameter_Count = State.Functions.Parameter_Count + 1 and then Parameter_Step'Result.State.First_Parameter = State.First_Parameter and then Parameter_Step'Result.State.Pure = State.Pure))"),
  ("parameter_step", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parameter_Step_Result"),
  ("parameters_model", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Parameters_Model'Result) and then (Parameters_Model'Result.Position = 0 or else (Parameters_Model'Result.Position > State.Position and then Parameters_Model'Result.Functions.Count = State.Functions.Count and then Parameters_Model'Result.Functions.Parameter_Count > State.Functions.Parameter_Count and then Parameters_Model'Result.First_Parameter = State.First_Parameter and then Parameters_Model'Result.Pure = State.Pure)), Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position)"),
  ("parameters_model", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State"),
  ("parameters_at", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => (Runtime => Valid_State (Text, Parameters_At'Result) and then (Parameters_At'Result.Position = 0 or else (Parameters_At'Result.Position > State.Position and then Parameters_At'Result.Functions.Count = State.Functions.Count and then Parameters_At'Result.Functions.Parameter_Count > State.Functions.Parameter_Count and then Parameters_At'Result.First_Parameter = State.First_Parameter and then Parameters_At'Result.Pure = State.Pure)), Static => Parameters_At'Result = Parameters_Model (Text, State, Arguments))"),
  ("parameters_at", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State"),
  ("function_local_at", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Function_Local_At'Result) and then (Function_Local_At'Result.Position = 0 or else (Function_Local_At'Result.Position > State.Position and then Function_Local_At'Result.Functions = State.Functions and then Function_Local_At'Result.First_Parameter = State.First_Parameter and then Function_Local_At'Result.Pure = State.Pure))"),
  ("function_local_at", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State"),
  ("function_locals_model", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Function_Locals_Model'Result) and then (Function_Locals_Model'Result.Position = 0 or else (Function_Locals_Model'Result.Position >= State.Position and then Function_Locals_Model'Result.Functions = State.Functions and then Function_Locals_Model'Result.First_Parameter = State.First_Parameter and then Function_Locals_Model'Result.Pure = State.Pure)), Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position)"),
  ("function_locals_model", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State"),
  ("function_locals", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => (Runtime => Valid_State (Text, Function_Locals'Result) and then (Function_Locals'Result.Position = 0 or else (Function_Locals'Result.Position >= State.Position and then Function_Locals'Result.Functions = State.Functions and then Function_Locals'Result.First_Parameter = State.First_Parameter and then Function_Locals'Result.Pure = State.Pure)), Static => Function_Locals'Result = Function_Locals_Model (Text, State, Arguments))"),
  ("function_locals", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State"),
  ("append_parameter", "is", expectedTokens "(Frame : Parser_State; Parameter : Functions.Formal) return Parser_State"),
  ("parameter_frame_model", ";", expectedTokens "(Frame : Parser_State; Index : Parameter_Cursor) return Parser_State with Ghost => Static, Global => null, Pre => Index <= Frame.Functions.Parameter_Count + 1, Subprogram_Variant => (Decreases => Functions.Max_Formals + 1 - Index)"),
  ("parameter_frame_model", "is", expectedTokens "(Frame : Parser_State; Index : Parameter_Cursor) return Parser_State"),
  ("parameter_frame", ";", expectedTokens "(Text : String; Frame : Parser_State) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Frame) and then Frame.First_Parameter > 0, Post => (Runtime => Valid_State (Text, Parameter_Frame'Result) and then (Parameter_Frame'Result.Position = 0 or else (Parameter_Frame'Result.Position = Frame.Position and then Parameter_Frame'Result.Functions = Frame.Functions and then Parameter_Frame'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count and then Parameter_Frame'Result.Boolean_Names.Count >= Frame.Boolean_Names.Count)), Static => Parameter_Frame'Result = Parameter_Frame_Model (Frame, Frame.First_Parameter))"),
  ("parameter_frame", "is", expectedTokens "(Text : String; Frame : Parser_State) return Parser_State"),
  ("function_return_after", ";", expectedTokens "(Text : String; Context : Body_Context; Scan : Body_Scan; Result_Type : Function_Type_Result) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => Function_Return_After'Result = 0 or else Function_Return_After'Result in Scan.Position + 1 .. Text'Last + 1"),
  ("function_return_after", "is", expectedTokens "(Text : String; Context : Body_Context; Scan : Body_Scan; Result_Type : Function_Type_Result) return Literal_Position"),
  ("function_body_at", ";", expectedTokens "(Text : String; Outer : Parser_State; Frame : Parser_State; First, After : Literal_Position; Result_Type : Function_Type_Result; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Outer) and then Valid_State (Text, Frame) and then Frame.First_Parameter > 0 and then Frame.First_Parameter <= Frame.Functions.Parameter_Count and then Frame.Functions.Count < Functions.Max_Functions and then Valid_Name_State (Text, First, After) and then First > 0 and then not Scalars.Is_Empty (Result_Type.Bounds), Post => Valid_State (Text, Function_Body_At'Result) and then (Function_Body_At'Result.Position = 0 or else Function_Body_At'Result.Position > Outer.Position)"),
  ("function_body_at", "is", expectedTokens "(Text : String; Outer : Parser_State; Frame : Parser_State; First, After : Literal_Position; Result_Type : Function_Type_Result; Arguments : Boolean) return Parser_State"),
  ("function_declaration_at", ";", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Function_Declaration_At'Result) and then (Function_Declaration_At'Result.Position = 0 or else Function_Declaration_At'Result.Position > State.Position)"),
  ("function_declaration_at", "is", expectedTokens "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State")]

def expressions : List (String × List String × List String) := [
  ("function_type_at", functionTypeBody.render, []),
  ("parameter_step", parameterStepBody.render, []),
  ("parameters_model", parametersModelBody.render, []),
  ("function_local_at", functionLocalBody.render, []),
  ("function_locals_model", functionLocalsModelBody.render, []),
  ("append_parameter", appendParameterBody.render, expectedTokens "with Global => null"),
  ("parameter_frame_model", parameterFrameModelBody.render, [])]

def ordinary : List (String × List String) := [
  ("function_return_after", returnAfterBody.render ++ ["end", "function_return_after", ";"]),
  ("function_body_at", functionBodyBody.render ++ ["end", "function_body_at", ";"]),
  ("function_declaration_at", functionDeclarationBody.render ++ ["end", "function_declaration_at", ";"])]

/-- These source checks retain the actual iterative executable readers. Their
semantic equations use the source-checked static postconditions above. -/
def loops : List (String × List String) := [
  ("parameters_at", expectedTokens "Current : Parser_State := State; begin loop pragma Loop_Invariant (Valid_State (Text, Current)); pragma Loop_Invariant (Current.Position >= State.Position); pragma Loop_Invariant (Current.Functions.Count = State.Functions.Count); pragma Loop_Invariant (Current.Functions.Parameter_Count >= State.Functions.Parameter_Count); pragma Loop_Invariant (Current.First_Parameter = State.First_Parameter); pragma Loop_Invariant (Current.Pure = State.Pure); pragma Loop_Invariant (Static => Parameters_Model (Text, State, Arguments) = Parameters_Model (Text, Current, Arguments)); pragma Loop_Variant (Increases => Current.Position); declare Next : constant Parameter_Step_Result := Parameter_Step (Text, Current, Arguments); begin if Next.State.Position = 0 then return Invalid_State; end if; if Next.Closed then return Next.State; end if; Current := Next.State; end; end loop; end Parameters_At;"),
  ("function_locals", expectedTokens "Current : Parser_State := State; begin while Current.Position /= 0 loop pragma Loop_Invariant (Valid_State (Text, Current)); pragma Loop_Invariant (Current.Position >= State.Position); pragma Loop_Invariant (Current.Functions = State.Functions); pragma Loop_Invariant (Current.First_Parameter = State.First_Parameter); pragma Loop_Invariant (Current.Pure = State.Pure); pragma Loop_Invariant (Static => Function_Locals_Model (Text, State, Arguments) = Function_Locals_Model (Text, Current, Arguments)); pragma Loop_Variant (Increases => Current.Position); if Take_Token (Text, Current.Position, Begin_Keyword) /= 0 then return Current; end if; Current := Function_Local_At (Text, Current, Arguments); end loop; return Invalid_State; end Function_Locals;"),
  ("parameter_frame", expectedTokens "Result : Parser_State := Frame; Index : Parameter_Cursor := Frame.First_Parameter; begin while Index <= Frame.Functions.Parameter_Count loop pragma Loop_Invariant (Index in Frame.First_Parameter .. Frame.Functions.Parameter_Count + 1); pragma Loop_Invariant (Result.Functions = Frame.Functions); pragma Loop_Invariant (Result.Position = Frame.Position); pragma Loop_Invariant (Result.Scalar_Names.Count >= Frame.Scalar_Names.Count); pragma Loop_Invariant (Result.Boolean_Names.Count >= Frame.Boolean_Names.Count); pragma Loop_Invariant (Valid_State (Text, Result)); pragma Loop_Invariant (Static => Parameter_Frame_Model (Frame, Frame.First_Parameter) = Parameter_Frame_Model (Result, Index)); pragma Loop_Variant (Increases => Index); Result := Append_Parameter (Result, Frame.Functions.Parameters (Index)); if Result.Position = 0 then return Invalid_State; end if; Index := Index + 1; end loop; return Result; end Parameter_Frame;")]

structure Checked (tokens : List String) : Prop where
  trees : CheckedTrees
  headers : ∀ item ∈ headers, functionHeader item.1 item.2.1 tokens = some item.2.2
  expressions : ∀ item ∈ expressions, expressionDeclaration item.1 tokens = some (item.2.1, item.2.2)
  ordinary : ∀ item ∈ ordinary, BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 tokens = some item.2
  loops : ∀ item ∈ loops, BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 tokens = some item.2
  typeResult : Silver.Lexical.SourceBridge.recordDeclaration "function_type_result" tokens =
    some (expectedTokens "record After : Literal_Position; Kind : Functions.Scalar_Kind; Bounds : Scalars.Interval; end record")
  stepResult : Silver.Lexical.SourceBridge.recordDeclaration "parameter_step_result" tokens =
    some (expectedTokens "record State : Parser_State; Closed : Boolean; end record")
  parameterCursor : Silver.Lexical.SourceBridge.subtypeDeclaration "parameter_cursor" tokens =
    some (expectedTokens "Positive range 1 .. Functions.Max_Formals + 1")

end Silver.Compose.FunctionDeclarationNative.SourceChecks
