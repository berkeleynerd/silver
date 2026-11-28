module

public import Silver.ApplicationPackageHideModel
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Full header/body and association requirements for package frame transforms.
Checked must be instantiated on the authoritative complete profile tokens. -/
namespace Silver.ApplicationPackageFrames.Native.Source
open SourceBridge ApplicationNative

def importedHeader : List String := expectedTokens
  "(Text : String; Exports : Parser_State; Info : Packages.Metadata; Position : Literal_Position) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Exports) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Info.Name_First, Info.Name_After) and then Info.Units (Units.Main_Body).First <= Text'Last + 1, Post => Valid_State (Text, Imported_Frame'Result)"

def hideHeader : List String := expectedTokens
  "(Text : String; Frame : Parser_State; Info : Packages.Metadata; Name : Packages.Name_Span) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Frame) and then Packages.Valid_Name (Text, Name), Post => Valid_State (Text, Hide_Outer'Result)"

structure Checked (tokens : List String) : Prop where
  trees : importedFrameBody.wellFormed functionNames = true ∧
    importedFrameBody.scoped importedScope = true ∧
    hideOuterBody.wellFormed functionNames = true ∧ hideOuterBody.scoped hideScope = true
  importedHeader : functionHeader "imported_frame" "is" tokens = some importedHeader
  importedBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "imported_frame" tokens = some (importedFrameBody.render functionNames)
  hideHeader : functionHeader "hide_outer" "is" tokens = some hideHeader
  hideBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "hide_outer" tokens = some (hideOuterBody.render functionNames)

theorem Checked.meaning {tokens : List String} (checked : Checked tokens) (locals : Locals) :
    Checked tokens ∧
    importedFrameBody.eval modelCalls locals = importedFrame (locals .source "text")
      (locals .state "exports") (locals .metadata "info") (locals .number "position") ∧
    hideOuterBody.eval modelCalls locals = hideOuter (locals .source "text")
      (locals .state "frame") (locals .metadata "info") (locals .nameSpan "name") := by
  refine ⟨checked, ?_, hideOuter_model locals⟩
  rw [importedFrame_denotation, importedFrame_model]

end Silver.ApplicationPackageFrames.Native.Source
