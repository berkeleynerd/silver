module

public import Silver.ApplicationPackageCompletionNative
public import Silver.ApplicationPackageUnitNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Complete native procedure contracts and bodies. The selected source bridge
must instantiate these unique extraction checks on the actual reconstruction;
checking a proposal alone is not that final binding. -/
namespace Silver.ApplicationPackageBodies.SourceChecks
open Silver.SourceBridge

def ordinaryProcedures (name : String) : List String → List (List String)
  | [] => []
  | "procedure" :: actual :: tokens =>
      let later := ordinaryProcedures name (actual :: tokens)
      if actual == name then
        match headerEnd 0 tokens with
        | some (header, "is") =>
            match Compose.BooleanDeclarationNative.SourceChecks.throughEnd name (tokens.drop (header.length + 1)) with
            | some body => body :: later
            | none => later
        | _ => later
      else later
  | _ :: tokens => ordinaryProcedures name tokens

def ordinaryProcedure (name : String) (tokens : List String) : Option (List String) :=
  match ordinaryProcedures name tokens with
  | [body] => some body
  | _ => none

def completionHeader : List String := expectedTokens
  "(Text : String; Globals : in out Parser_State; Info : in out Packages.Metadata) with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Globals), Post => Valid_State (Text, Globals) and then (Globals.Position = 0 or else (Globals.Position > Globals.Position'Old and then Info.Completed > Info.Completed'Old))"

def unitHeader : List String := expectedTokens
  "(Text : String; Exports : Parser_State; Info : in out Packages.Metadata; Accepted : out Boolean) with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Exports) and then Info.Units (Units.Package_Body).First <= Text'Last + 1"

def objectHeader : List String := expectedTokens
  "(Text : String; Frame : Parser_State; Info : Packages.Metadata; Local : Boolean := False) return Package_Object_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Frame), Post => Valid_State (Text, Package_Object_At'Result.Frame) and then Package_Object_At'Result.Init_First <= Text'Last + 1 and then Package_Object_At'Result.Init_After <= Text'Last + 1 and then (Package_Object_At'Result.Frame.Position = 0 or else Package_Object_At'Result.Frame.Position > Frame.Position)"

structure Checked (tokens : List String) : Prop where
  completionTree : ApplicationPackageCompletion.Native.CheckedTree
  unitTree : ApplicationPackageUnit.Native.CheckedTree
  completionHeader : procedureHeader "package_completion_at" "is" tokens = some completionHeader
  unitHeader : procedureHeader "package_body_at" "is" tokens = some unitHeader
  completionBody : ordinaryProcedure "package_completion_at" tokens =
    some (ApplicationPackageCompletion.Native.body.render ApplicationPackageCompletion.Native.functionNames)
  unitBody : ordinaryProcedure "package_body_at" tokens =
    some (ApplicationPackageUnit.Native.body.render ApplicationPackageUnit.Native.functionNames)
  objectHeader : functionHeader "package_object_at" "is" tokens = some objectHeader

end Silver.ApplicationPackageBodies.SourceChecks
