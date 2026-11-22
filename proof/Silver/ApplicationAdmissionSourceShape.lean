module

public import Silver.ApplicationAdmissionExpressions
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Exact extraction obligations for the original-application wrapper. The
header retains its full native postcondition and the body is generated only by
the typed expression/control tree. The source bridge instantiates these checks
on the authoritative reconstruction, together with the imported source groups. -/
namespace Silver.ApplicationAdmission.Native.SourceChecks
open Silver.SourceBridge

def analyzeHeader : List String := expectedTokens
  "(Sources : Units.Bundle) return Analysis_Result with Global => null, Post => (if Analyze_Application'Result.Accepted then Units.Valid (Sources) and then Analyze_Application'Result.Package_Info.Units = Sources.Units and then Packages.Complete_Metadata (Sources.Pool (1 .. Sources.Used), Analyze_Application'Result.Package_Info) and then Functions.Valid_Metadata (Sources.Pool (1 .. Sources.Used), Analyze_Application'Result.Main_Functions) and then Procedures.Valid_Metadata (Sources.Pool (1 .. Sources.Used), Analyze_Application'Result.Main_Procedures))"

def analysisRecord : List String := expectedTokens
  "record Accepted : Boolean := False; Package_Info : Silver_Package_Bindings.Metadata := Silver_Package_Bindings.Empty_Metadata; Main_Functions : Silver_Function_Bindings.Metadata := Silver_Function_Bindings.Empty_Metadata; Main_Procedures : Silver_Procedure_Bindings.Metadata := Silver_Procedure_Bindings.Empty_Metadata; Uses_Arguments, Uses_Assignment, Uses_Output : Boolean := False; end record"

def aliases : List (String × List String) := [
  ("analyze_model", analyzeModelBody.render functionNames),
  ("analyze", analyzeAliasBody.render functionNames),
  ("is_application_member", memberBody.render functionNames),
  ("accepts_application", acceptsBody.render functionNames)]

def aliasHeader (name : String) : List String :=
  expectedTokens "(Sources : Units.Bundle) return" ++
    (if name = "analyze_model" ∨ name = "analyze" then ["analysis_result"] else ["boolean"])

structure Checked (specification implementation : List String) : Prop where
  trees : CheckedTrees
  wrapperHeader : functionHeader "analyze_application" "is" implementation = some analyzeHeader
  wrapperBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "analyze_application" implementation = some analyzeBody.render
  aliasHeaders : ∀ entry ∈ aliases,
    functionHeader entry.1 "is" implementation = some (aliasHeader entry.1)
  aliasBodies : ∀ entry ∈ aliases,
    expressionDeclaration entry.1 implementation = some (entry.2, [])
  record : Silver.Lexical.SourceBridge.recordDeclaration "analysis_result" specification = some analysisRecord
  invalid : Source.declaration "invalid_analysis" specification =
    some (expectedTokens "constant Analysis_Result := (others => <>)")

end Silver.ApplicationAdmission.Native.SourceChecks
