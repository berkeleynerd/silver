module

public import Silver.ApplicationPackageNamesEquations
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Unique complete source requirements for the six package name helpers.
Instantiation against certified authoritative output-profile tokens is separate
from these typed requirements, so focused helper checks do not rebuild a changing
whole-profile certificate. No shape pin or source/model equality replaces them. -/
namespace Silver.ApplicationPackageNames.SourceChecks
open Silver.SourceBridge Native

abbrev ordinaryFunction := Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction

def wordHeader : List String := expectedTokens
  "(Text : String; Position : Literal_Position; Word : String) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Word'First = 1 and then Word'Length in 1 .. 16, Post => Package_Word'Result = 0 or else Package_Word'Result in Position + 1 .. Text'Last + 1"

def pragmaHeader : List String := expectedTokens
  "(Text : String; Position : Literal_Position) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post => Spark_Pragma_After'Result = 0 or else Spark_Pragma_After'Result in Position + 1 .. Text'Last + 1"

def typeHeader : List String := expectedTokens
  "(Text : String; Frame : Parser_State; Info : Packages.Metadata; Position : Literal_Position) return Package_Type_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Frame) and then Position <= Text'Last + 1, Post => Package_Type_At'Result.After = 0 or else (Package_Type_At'Result.After in Position + 1 .. Text'Last + 1 and then Packages.Valid_Name (Text, Package_Type_At'Result.Name) and then not Scalars.Is_Empty (Package_Type_At'Result.Bounds))"

def typeDeclaration : List String := expectedTokens
  "record Name : Packages.Name_Span := Packages.No_Name; After : Literal_Position := 0; Kind : Functions.Scalar_Kind := Functions.Integer_Kind; Bounds : Scalars.Interval := Scalars.Empty; Identity : Packages.Type_Id := Packages.Integer_Type; end record"

structure Checked (tokens : List String) : Prop where
  expressions : Native.WellFormedTrees
  expressionScopes : Native.WellScopedTrees
  bodies : Native.WellFormedBodies
  bodyScopes : Native.WellScopedBodies
  wordBody : ordinaryFunction "package_word" tokens = some (packageWordBody.render functionNames)
  wordSpec : functionHeader "package_word" "is" tokens = some wordHeader
  pragmaBody : ordinaryFunction "spark_pragma_after" tokens = some (sparkPragmaBody.render functionNames)
  pragmaSpec : functionHeader "spark_pragma_after" "is" tokens = some pragmaHeader
  allowedBody : expressionDeclaration "package_name_allowed" tokens =
    some (nameAllowedBody.render functionNames, expectedTokens "with Global => null")
  allowedSpec : functionHeader "package_name_allowed" "is" tokens = some (expectedTokens
    "(Text : String; Name : Packages.Name_Span) return Boolean")
  freshBody : expressionDeclaration "package_name_fresh" tokens =
    some (nameFreshBody.render functionNames, expectedTokens "with Global => null")
  freshSpec : functionHeader "package_name_fresh" "is" tokens = some (expectedTokens
    "(Text : String; Info : Packages.Metadata; Name : Packages.Name_Span) return Boolean")
  packageType : Silver.Lexical.SourceBridge.recordDeclaration "package_type_result" tokens = some typeDeclaration
  invalidType : Source.declaration "invalid_package_type" tokens =
    some (expectedTokens "constant Package_Type_Result := (others => <>)")
  typeBody : ordinaryFunction "package_type_at" tokens = some (packageTypeBody.render functionNames)
  typeSpec : functionHeader "package_type_at" "is" tokens = some typeHeader
  outerBody : expressionDeclaration "outer_declaration" tokens =
    some (outerDeclarationBody.render functionNames, expectedTokens "with Global => null")
  outerSpec : functionHeader "outer_declaration" "is" tokens = some (expectedTokens
    "(Info : Packages.Metadata; Name : Packages.Name_Span) return Boolean")

end Silver.ApplicationPackageNames.SourceChecks
