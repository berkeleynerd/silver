module

public import Silver.ApplicationPackageDeclarationsSignatureNative
public import Silver.ApplicationPackageDeclarationsSpecificationNative
public import Silver.ApplicationPackageDeclarationsObjectSourceRequirements
public import Silver.ApplicationPackageBodiesSourceShape

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ReaderSourceChecks
open Silver.SourceBridge
open ApplicationPackageBodies.SourceChecks (ordinaryProcedure)

def signatureHeader : List String :=
  expectedTokens "(Text : String; Outer : Parser_State; Info : in out Packages.Metadata;" ++
  expectedTokens "Completing : Boolean; Header : out Parser_State)" ++
  expectedTokens "with Global => null," ++
  expectedTokens "Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length" ++
  expectedTokens "and then Valid_State (Text, Outer)," ++
  expectedTokens "Post => Info.Units = Info.Units'Old and then Valid_State (Text, Header)" ++
  expectedTokens "and then (Header.Position = 0 or else Header.Position > Outer.Position)" ++
  expectedTokens "and then (if Header.Position /= 0 and then not Completing then" ++
  expectedTokens "Info.Routine_Count > 0" ++
  expectedTokens "and then Info.Routines (Info.Routine_Count).Spec_Name.First > 0" ++
  expectedTokens "and then Valid_Name_State (Text," ++
  expectedTokens "Info.Routines (Info.Routine_Count).Spec_Name.First," ++
  expectedTokens "Info.Routines (Info.Routine_Count).Spec_Name.After))"

def specificationHeader : List String := expectedTokens "(Text : String; Info : in out Packages.Metadata; Exports : out Parser_State) with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length, Post => Info.Units = Info.Units'Old and then Valid_State (Text, Exports)"

def appendHeader : List String :=
  expectedTokens "(Frame : in out Parser_State; Name : Packages.Name_Span;" ++
  expectedTokens "Mark : Package_Type_Result; Mode : Procedures.Parameter_Mode)" ++
  expectedTokens "with Global => null," ++
  expectedTokens "Pre => Name.First > 0 and then Name.After > Name.First," ++
  expectedTokens "Post => Frame.Context_First = Frame'Old.Context_First" ++
  expectedTokens "and then Frame.Package_First = Frame'Old.Package_First" ++
  expectedTokens "and then Frame.Package_After = Frame'Old.Package_After" ++
  expectedTokens "and then Frame.Functions = Frame'Old.Functions" ++
  expectedTokens "and then Frame.Procedures = Frame'Old.Procedures" ++
  expectedTokens "and then Frame.First_Parameter = Frame'Old.First_Parameter" ++
  expectedTokens "and then Frame.First_Procedure_Parameter = Frame'Old.First_Procedure_Parameter" ++
  expectedTokens "and then Frame.Names = Frame'Old.Names" ++
  expectedTokens "and then Frame.Array_Names = Frame'Old.Array_Names" ++
  expectedTokens "and then Frame.Subtype_Names = Frame'Old.Subtype_Names" ++
  expectedTokens "and then Frame.Dynamic_First = Frame'Old.Dynamic_First" ++
  expectedTokens "and then Frame.Dynamic_After = Frame'Old.Dynamic_After" ++
  expectedTokens "and then Frame.Target = Frame'Old.Target" ++
  expectedTokens "and then Frame.Pure = Frame'Old.Pure" ++
  expectedTokens "and then Frame.Assigned_In_Functions = Frame'Old.Assigned_In_Functions" ++
  expectedTokens "and then Frame.Hiding = Frame'Old.Hiding" ++
  expectedTokens "and then Frame.Capacity = Frame'Old.Capacity" ++
  expectedTokens "and then (if Mark.Kind = Functions.Integer_Kind" ++
  expectedTokens "and then Frame'Old.Scalar_Names.Count < Scalar_Expressions.Max_Bindings" ++
  expectedTokens "then Frame = (Frame'Old with delta Scalar_Names =>" ++
  expectedTokens "Scalar_Expressions.Append" ++
  expectedTokens "(Frame'Old.Scalar_Names," ++
  expectedTokens "(Name.First, Name.After, Mark.Bounds, False," ++
  expectedTokens "Mark.Bounds, Mode /= Procedures.Input, 0, 0)))" ++
  expectedTokens "elsif Mark.Kind = Functions.Boolean_Kind" ++
  expectedTokens "and then Frame'Old.Boolean_Names.Count < Max_Boolean_Bindings" ++
  expectedTokens "then Frame = (Frame'Old with delta Boolean_Names =>" ++
  expectedTokens "(Count => Frame'Old.Boolean_Names.Count + 1," ++
  expectedTokens "Items => (Frame'Old.Boolean_Names.Items with delta" ++
  expectedTokens "Frame'Old.Boolean_Names.Count + 1 =>" ++
  expectedTokens "(Name.First, Name.After, Mode /= Procedures.Input," ++
  expectedTokens "0, 0, False, False))))" ++
  expectedTokens "else Frame = (Frame'Old with delta Position => 0))"

def formalRecord : List String := expectedTokens "record Spec_Name, Body_Name : Name_Span := No_Name; Spec_Type_Name, Body_Type_Name : Name_Span := No_Name; Kind : Silver_Function_Bindings.Scalar_Kind := Silver_Function_Bindings.Integer_Kind; Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty; Type_Identity : Type_Id := Integer_Type; Mode : Silver_Procedure_Bindings.Parameter_Mode := Silver_Procedure_Bindings.Input; end record"

def routineRecord : List String := expectedTokens "record Kind : Routine_Kind := Procedure_Routine; Spec_Name, Body_Name : Name_Span := No_Name; Spec_First, Spec_After : Literal_Position := 0; Body_First, Body_After : Literal_Position := 0; Formal_First : Formal_Count_Type := 0; Count : Formal_Count_Type := 0; Result_Kind : Silver_Function_Bindings.Scalar_Kind := Silver_Function_Bindings.Integer_Kind; Result_Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty; Result_Type_Identity : Type_Id := Integer_Type; Spec_Result_Name, Body_Result_Name : Name_Span := No_Name; May_Read, May_Write : State_Set := Empty_State_Set; Assigned : Boolean := False; end record"

def exportItemRecord : List String := expectedTokens "record Name : Name_Span := No_Name; Kind : Export_Kind := Integer_Subtype; Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty; Type_Name : Name_Span := No_Name; Type_Identity : Type_Id := Integer_Type; Initializer_First, Initializer_After : Literal_Position := 0; Boolean_Value : Boolean := False; end record"

structure SignatureChecked (profile packages : List String) : Prop where
  tree : SignatureNative.CheckedTree
  bodySource : ordinaryProcedure "package_signature_at" profile =
    some (SignatureNative.body.render SignatureNative.functionNames)
  headerSource : procedureHeader "package_signature_at" "is" profile = some signatureHeader
  routineType : Silver.Lexical.SourceBridge.recordDeclaration "routine" packages = some routineRecord
  formalType : Silver.Lexical.SourceBridge.recordDeclaration "formal" packages = some formalRecord
  appendSource : procedureHeader "append_package_formal" "is" profile = some appendHeader

structure SpecificationChecked (profile packages : List String) : Prop where
  tree : SpecificationNative.CheckedTree
  bodySource : ordinaryProcedure "package_spec_at" profile =
    some (SpecificationNative.body.render SpecificationNative.functionNames)
  headerSource : procedureHeader "package_spec_at" "is" profile = some specificationHeader
  exportType : Silver.Lexical.SourceBridge.recordDeclaration "export_declaration" packages = some exportItemRecord
  objectDefault : functionHeader "package_object_at" "is" profile = some ObjectSourceChecks.objectHeader

/-- The full native Append contract fixes every frame component and the exact
array update. The scalar append expression is the same single-cell update on its
own fixed backing, with a strict count precondition. -/
structure AppendChecked (profile scalarSpec : List String) : Prop where
  headerSource : procedureHeader "append_package_formal" "is" profile = some appendHeader
  scalarHeader : functionHeader "append" "is" scalarSpec = some (expectedTokens
    "(Names : Environment; Item : Binding) return Environment")
  scalarBody : expressionDeclaration "append" scalarSpec = some
    (expectedTokens "(Count => Names.Count + 1, Items => (Names.Items with delta Names.Count + 1 => Item))",
     expectedTokens "with Pre => Names.Count < Max_Bindings")

end Silver.ApplicationPackageDeclarations.ReaderSourceChecks
