module

public import Silver.ApplicationPackageRoutineFrameImports
public import Silver.ApplicationPackageRoutineFrameContract
public import Silver.ApplicationPackageRoutineFrameSource
public import Silver.ApplicationPackageDeclarationsReaderSourceRequirements

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame
open Compose Compose.Expressions ApplicationPackageFrames ApplicationPackageDeclarations

/-- Actual extraction of Routine_Frame and the complete Append interface are
joined with the native storage interpretations. Body_Environment's checked
native contract determines every physical scalar cell and the active count. -/
structure SourceLibrary (profile scalarSpec : List String) where
  library : Library
  routineSource : SourceChecks.Checked profile
  appendSource : ReaderSourceChecks.AppendChecked profile scalarSpec
  scalarSource : ScalarExpression.EnvironmentSourceBridge.Checked scalarSpec

namespace SourceLibrary

theorem complete_contract {profile scalarSpec : List String} (source : SourceLibrary profile scalarSpec)
    (locals : ApplicationNative.Locals) (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "globals"))
    (bounded : ValidCursor (locals .source "text") (locals .number "position")) :
    SourceChecks.Checked profile ∧ ReaderSourceChecks.AppendChecked profile scalarSpec ∧
      ScalarExpression.EnvironmentSourceBridge.Checked scalarSpec ∧
      Native.body.eval (Native.modelFunctions source.library.calls) (Native.modelProcedures source.library.calls) locals =
        routineFrame modelCalls (locals .source "text") (locals .state "globals")
          (locals .metadata "info") (locals .number "routine") (locals .number "position") ∧
      stateValid (locals .source "text")
        (Native.body.eval (Native.modelFunctions source.library.calls) (Native.modelProcedures source.library.calls) locals) = true := by
  have exactResult := source.library.body_imports locals valid framed bounded
  refine ⟨source.routineSource, source.appendSource, source.scalarSource, exactResult, ?_⟩
  rw [exactResult]
  exact routine_frame_valid _ _ _ _ _

theorem reader_frame {profile scalarSpec : List String} (source : SourceLibrary profile scalarSpec)
    (locals : ApplicationNative.Locals) (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "globals"))
    (bounded : ValidCursor (locals .source "text") (locals .number "position"))
    (parameters : ParameterBounds (locals .metadata "info")) :
    ReaderFrame (locals .source "text")
      (Native.body.eval (Native.modelFunctions source.library.calls) (Native.modelProcedures source.library.calls) locals) := by
  rw [source.library.body_imports locals valid framed bounded]
  exact routine_frame_reader _ framed _ parameters _ _ bounded

end SourceLibrary
end Silver.ApplicationPackageRoutineFrame
