module

public import Silver.BooleanBindingsNative

@[expose] public section

namespace Silver.BooleanBindings.SourceChecks
open Silver.SourceBridge

def tokens (text : String) : List String := (Source.lexLine text).getD []

def lookupModelImpl : List String := tokens
  "(Text : String; Booleans : Boolean_Environment; First, After : Literal_Position; Index : Boolean_Count) return Boolean_Count"
def lookupModelSpec : List String := lookupModelImpl ++ tokens
  "with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Booleans (Text, Booleans) and then Index <= Booleans.Count and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => Lookup_Boolean_Model'Result <= Index, Subprogram_Variant => (Decreases => Index)"
def lookupImpl : List String := tokens
  "(Text : String; Booleans : Boolean_Environment; First, After : Literal_Position) return Boolean_Count"
def lookupSpec : List String := lookupImpl ++ tokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Booleans (Text, Booleans) and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => (Runtime => Lookup_Boolean'Result <= Booleans.Count, Static => Lookup_Boolean'Result = Lookup_Boolean_Model (Text, Booleans, First, After, Booleans.Count))"
def hidesImpl : List String := tokens
  "(Text : String; Booleans : Boolean_Environment) return Boolean"
def hidesSpec : List String := hidesImpl ++ tokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Booleans (Text, Booleans)"

structure Checked (source : List String) : Prop where
  capacity : Source.declaration "max_boolean_bindings" source = some (tokens "constant Positive := max_source_length / 13")
  bindingRecord : Lexical.SourceBridge.recordDeclaration "boolean_binding" source =
    some (tokens "record First, After : Literal_Position; Mutable : Boolean; end record")
  environmentRecord : Lexical.SourceBridge.recordDeclaration "boolean_environment" source =
    some (tokens "record Count : Boolean_Count; Items : Boolean_Binding_Array; end record")
  valid : Source.expressionBody "valid_booleans" source = some (tokens
    "for all Index in 1 .. Booleans.Count => Booleans.Items (Index).First > 0 and then Valid_Name_State (Text, Booleans.Items (Index).First, Booleans.Items (Index).After)")
  lookupModel : Source.expressionBody "lookup_boolean_model" source = some Native.lookupBody.render
  lookupModelSpec : functionHeader "lookup_boolean_model" ";" source = some lookupModelSpec
  lookupModelImpl : functionHeader "lookup_boolean_model" "is" source = some lookupModelImpl
  lookupSpec : functionHeader "lookup_boolean" ";" source = some lookupSpec
  lookupImpl : functionHeader "lookup_boolean" "is" source = some lookupImpl
  hidesInteger : Source.expressionBody "boolean_hides_integer" source = some Native.hidesIntegerTokens
  hidesSpec : functionHeader "boolean_hides_integer" ";" source = some hidesSpec
  hidesImpl : functionHeader "boolean_hides_integer" "is" source = some hidesImpl

end Silver.BooleanBindings.SourceChecks
