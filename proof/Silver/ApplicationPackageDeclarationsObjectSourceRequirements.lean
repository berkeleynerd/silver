module

public import Silver.ApplicationPackageDeclarationsObjectNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Complete original Object syntax and the scalar-call default specialization.
The candidate below is a focused witness; authoritative certified token streams
must separately satisfy this same predicate at integration. -/
namespace Silver.ApplicationPackageDeclarations.ObjectSourceChecks
open Silver.SourceBridge

abbrev ordinaryFunction := Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction

def objectHeader : List String := expectedTokens "(Text : String; Frame : Parser_State; Info : Packages.Metadata;\n      Local : Boolean := False) return Package_Object_Result\n     with Global => null,\n       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length\n         and then Valid_State (Text, Frame),\n       Post => Valid_State (Text, Package_Object_At'Result.Frame)\n         and then Package_Object_At'Result.Init_First <= Text'Last + 1\n         and then Package_Object_At'Result.Init_After <= Text'Last + 1\n         and then (Package_Object_At'Result.Frame.Position = 0\n           or else Package_Object_At'Result.Frame.Position > Frame.Position)"

def objectRecord : List String := expectedTokens "record\n      Frame : Parser_State := Invalid_State;\n      Name : Packages.Name_Span := Packages.No_Name;\n      Mark : Package_Type_Result := Invalid_Package_Type;\n      Init_First, Init_After : Literal_Position := 0;\n      Initial_Bounds : Scalars.Interval := Scalars.Empty;\n      Constant_Object, Boolean_Value : Boolean := False;\n   end record"

def constraintRecord : List String := expectedTokens "record\n      After : Literal_Position;\n      Bounds : Scalars.Interval;\n   end record"

def staticRecord : List String := expectedTokens "record\n      After : Literal_Position := 0;\n      Value : Boolean := False;\n   end record"

def scalarRecord : List String :=
  expectedTokens "record" ++
  expectedTokens "After : Literal_Position;" ++
  expectedTokens "Bounds : Silver_Scalars.Interval;" ++
  expectedTokens "Operands : Operand_Count;" ++
  expectedTokens "Static : Boolean;" ++
  expectedTokens "end record"

def scalarHeader : List String :=
  expectedTokens "(Text : String; Position : Literal_Position; Names : Environment;" ++
  expectedTokens "Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;" ++
  expectedTokens "Allow_Sign : Boolean := True;" ++
  expectedTokens "Arrays : Silver_Array_Bindings.Metadata := Silver_Array_Bindings.Empty_Metadata;" ++
  expectedTokens "Initials : Silver_Array_Bindings.Element_Array := Silver_Array_Bindings.Empty_Values;" ++
  expectedTokens "Elaborating : Boolean := False;" ++
  expectedTokens "Array_Reads : Array_Read_Mode := All_Elements)" ++
  expectedTokens "return Expression_Result" ++
  expectedTokens "with Global => null," ++
  expectedTokens "Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length" ++
  expectedTokens "and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)" ++
  expectedTokens "and then Valid_Name_State (Text, Mask_First, Mask_After)" ++
  expectedTokens "and then Silver_Array_Bindings.Valid_Metadata (Text, Arrays)," ++
  expectedTokens "Post => Read_Expression'Result.After = 0" ++
  expectedTokens "or else (Read_Expression'Result.After in Position + 1 .. Text'Last + 1" ++
  expectedTokens "and then Read_Expression'Result.Operands > 0)," ++
  expectedTokens "Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3)"

structure Checked (profile scalarSpec : List String) : Prop where
  wellFormed : ObjectNative.body.wellFormed ObjectNative.functionNames = true
  bodyScopes : ObjectNative.body.scoped ObjectNative.scope = true
  named : ObjectNative.body.namedCorrect ObjectNative.functionParameters = true
  bodySource : ordinaryFunction "package_object_at" profile = some (ObjectNative.body.render ObjectNative.functionNames)
  headerSource : functionHeader "package_object_at" "is" profile = some objectHeader
  objectType : Silver.Lexical.SourceBridge.recordDeclaration "package_object_result" profile = some objectRecord
  invalidObject : Source.declaration "invalid_package_object" profile = some
    (expectedTokens "constant Package_Object_Result := (others => <>)")
  constraintType : Silver.Lexical.SourceBridge.recordDeclaration "scalar_constraint_result" profile = some constraintRecord
  staticType : Silver.Lexical.SourceBridge.recordDeclaration "static_boolean_result" profile = some staticRecord
  scalarType : Silver.Lexical.SourceBridge.recordDeclaration "expression_result" scalarSpec = some scalarRecord
  scalarSpecialization : functionHeader "read_expression" ";" scalarSpec = some scalarHeader

end Silver.ApplicationPackageDeclarations.ObjectSourceChecks
