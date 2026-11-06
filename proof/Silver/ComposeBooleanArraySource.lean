module

public import Silver.ComposeArrayExpressions
public import Silver.ComposeBooleanInitializerNative

@[expose] public section

/-! The Boolean aggregate loop refines its checked recursive model through
its native Static postcondition. Model recursion uses the separately derived
Boolean initializer meaning on the exact state/cursor/mask domain. -/
namespace Silver.Compose.BooleanArraySource
open Silver.SourceBridge

def modelSpec : List String := expectedTokens
  "(Text : String; Source_State, Result_State : Parser_State; Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count; Mask_First, Mask_After : Literal_Position) return Parser_State with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Source_State) and then Valid_State (Text, Result_State) and then Position <= Text'Last + 1 and then Parsed <= Length and then Valid_Name_State (Text, Mask_First, Mask_After) and then Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used and then Result_State.Array_Names.Used = Source_State.Array_Names.Used + Parsed, Post => Valid_State (Text, Boolean_Array_Values_Model'Result) and then (if Boolean_Array_Values_Model'Result.Position /= 0 then Boolean_Array_Values_Model'Result.Position >= Position and then Boolean_Array_Values_Model'Result = (Result_State with delta Position => Boolean_Array_Values_Model'Result.Position, Array_Names => (Result_State.Array_Names with delta Used => Source_State.Array_Names.Used + Length, Values => Boolean_Array_Values_Model'Result.Array_Names.Values)) and then (for all Slot in 1 .. Result_State.Array_Names.Used => Boolean_Array_Values_Model'Result.Array_Names.Values (Slot) = Result_State.Array_Names.Values (Slot))), Subprogram_Variant => (Decreases => Length - Parsed)"

def modelImpl : List String := expectedTokens
  "(Text : String; Source_State, Result_State : Parser_State; Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count; Mask_First, Mask_After : Literal_Position) return Parser_State"

def executableSpec : List String := expectedTokens
  "(Text : String; Source_State, Result_State : Parser_State; Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count; Mask_First, Mask_After : Literal_Position) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Source_State) and then Valid_State (Text, Result_State) and then Position <= Text'Last + 1 and then Parsed <= Length and then Valid_Name_State (Text, Mask_First, Mask_After) and then Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used and then Result_State.Array_Names.Used = Source_State.Array_Names.Used + Parsed, Post => (Runtime => Valid_State (Text, Boolean_Array_Values_At'Result) and then (if Boolean_Array_Values_At'Result.Position /= 0 then Boolean_Array_Values_At'Result.Position >= Position and then Boolean_Array_Values_At'Result = (Result_State with delta Position => Boolean_Array_Values_At'Result.Position, Array_Names => (Result_State.Array_Names with delta Used => Source_State.Array_Names.Used + Length, Values => Boolean_Array_Values_At'Result.Array_Names.Values)) and then (for all Slot in 1 .. Result_State.Array_Names.Used => Boolean_Array_Values_At'Result.Array_Names.Values (Slot) = Result_State.Array_Names.Values (Slot))), Static => Boolean_Array_Values_At'Result = Boolean_Array_Values_Model (Text, Source_State, Result_State, Position, Length, Parsed, Mask_First, Mask_After) and then Same_Parser_State (Boolean_Array_Values_At'Result, Boolean_Array_Values_Model (Text, Source_State, Result_State, Position, Length, Parsed, Mask_First, Mask_After)))"

def executableImpl : List String := expectedTokens
  "(Text : String; Source_State, Result_State : Parser_State; Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count; Mask_First, Mask_After : Literal_Position) return Parser_State"

structure Checked (tokens : List String) : Prop where
  initializer : BooleanInitializerNative.SourceChecks.Checked tokens
  body : expressionDeclaration "boolean_array_values_model" tokens =
    some (Expressions.booleanArrayValuesModelBody.render, [])
  modelSpec : functionHeader "boolean_array_values_model" ";" tokens = some modelSpec
  modelImpl : functionHeader "boolean_array_values_model" "is" tokens = some modelImpl
  executableSpec : functionHeader "boolean_array_values_at" ";" tokens = some executableSpec
  executableImpl : functionHeader "boolean_array_values_at" "is" tokens = some executableImpl

end Silver.Compose.BooleanArraySource
