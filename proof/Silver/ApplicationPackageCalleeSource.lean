module

public import Silver.ApplicationPackageCalleeNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Complete source requirements for Package_Callee. The executable domain
includes every native Metadata value: no Valid_Metadata requirement is added.
A Checked witness must be established on the authoritative source tokens. -/
namespace Silver.ApplicationPackageCalls.Native.CalleeSource
open SourceBridge ApplicationNative

def header : List String := expectedTokens
  "(Text : String; Context : Body_Context; Info : Packages.Metadata; Position : Literal_Position; Kind : Packages.Routine_Kind) return Packages.Routine_Count_Type with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1, Post => Package_Callee'Result <= Info.Routine_Count"

structure Checked (tokens : List String) : Prop where
  completeHeader : functionHeader "package_callee" "is" tokens = some header
  completeBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "package_callee" tokens = some (calleeBody.render functionNames)

theorem Checked.meaning {tokens : List String} (checked : Checked tokens)
    (calls : ApplicationPackageCalls.Calls) (initial : Locals) :
    functionHeader "package_callee" "is" tokens = some header ∧
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "package_callee" tokens =
      some (calleeBody.render functionNames) ∧
    calleeBody.eval (imported calls) initial =
      packageCallee calls (initial .source "text") (initial .parseContext "context")
        (initial .metadata "info") (initial .number "position") (initial .routineKind "kind") :=
  ⟨checked.completeHeader, checked.completeBody, callee_denotation calls initial⟩

end Silver.ApplicationPackageCalls.Native.CalleeSource
