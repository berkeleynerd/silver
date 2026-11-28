module

public import Silver.ApplicationPackageRoutineFrameNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame.SourceChecks
open Silver.SourceBridge

def header : List String := expectedTokens
  "(Text : String; Globals : Parser_State; Info : Packages.Metadata; Routine : Packages.Routine_Index; Position : Literal_Position) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Globals) and then Position <= Text'Last + 1, Post => Valid_State (Text, Routine_Frame'Result)"

structure Checked (tokens : List String) : Prop where
  tree : Native.CheckedTree
  header : functionHeader "routine_frame" "is" tokens = some header
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "routine_frame" tokens =
    some (Native.body.render Native.functionNames)

end Silver.ApplicationPackageRoutineFrame.SourceChecks
