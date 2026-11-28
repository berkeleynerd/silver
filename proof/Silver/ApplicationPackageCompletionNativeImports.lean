module

public import Silver.ApplicationPackageCompletionImports
public import Silver.ApplicationPackageCompletionSimulation

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Library
open Compose Compose.Expressions ApplicationNative ApplicationPackageBodies ApplicationPackageFrames ApplicationPackageDeclarations

/-- The complete original typed Completion body, with arbitrary inactive and
caller locals, projects to the total reader after all real imported callee
meanings and native domains have been established. -/
theorem completion_native (library : Library) (reader : BooleanElaboration.Native.Reader)
    (locals : ApplicationNative.Locals) (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "globals"))
    (typed : (locals .metadata "info").Typed) :
    (Native.body.eval (Native.modelFunctions (library.calls reader))
      (Native.modelProcedures (library.calls reader)) ((locals .source "text").length + 2) locals).map Native.observed =
      some (readCompletion reader (LeafLibraries.model (library.calls reader))
        (locals .source "text") (locals .state "globals") (locals .metadata "info")) :=
  (Native.body_simulation (library.calls reader) ((locals .source "text").length + 2) locals).trans
    (library.completion_read reader valid _ framed _ typed)

theorem completion_native_total (library : Library) (reader : BooleanElaboration.Native.Reader)
    (locals : ApplicationNative.Locals) (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "globals"))
    (typed : (locals .metadata "info").Typed) :
    ∃ returned, Native.body.eval (Native.modelFunctions (library.calls reader))
        (Native.modelProcedures (library.calls reader)) ((locals .source "text").length + 2) locals = some returned ∧
      Native.observed returned = readCompletion reader (LeafLibraries.model (library.calls reader))
        (locals .source "text") (locals .state "globals") (locals .metadata "info") :=
  Option.map_eq_some_iff.mp (library.completion_native reader locals valid framed typed)

end Silver.ApplicationPackageCompletion.Library
