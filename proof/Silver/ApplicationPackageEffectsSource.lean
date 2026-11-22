module

public import Silver.ApplicationPackageEffectsInterpretation
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Complete native source requirements for package-state visibility and effects.
The interpretation equations admit arbitrary locals and imported calls; source
contracts are retained separately, without silently strengthening their domains.
The authoritative source checkpoint must instantiate Checked on its own tokens. -/
namespace Silver.ApplicationPackageEffects.Native.Source
open SourceBridge ApplicationNative

def visibleHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Info : Packages.Metadata; Index : Packages.State_Index) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context), Post => (if Visible_State'Result then Index <= Info.State_Count and then Packages.Valid_Name (Text, Info.States (Index).Name))"

def targetHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Info : Packages.Metadata; Position : Literal_Position) return Packages.State_Id with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1, Post => State_Target'Result <= Info.State_Count"

def readsHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Info : Packages.Metadata; First, After : Literal_Position) return Packages.State_Set with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then First <= Text'Last + 1 and then After <= Text'Last + 1, Post => Packages.Within (State_Reads'Result, Info.State_Count)"

structure Checked (tokens : List String) : Prop where
  visibleHeader : functionHeader "visible_state" "is" tokens = some visibleHeader
  visibleBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "visible_state" tokens = some (Native.visibleBody.render functionNames)
  targetHeader : functionHeader "state_target" "is" tokens = some targetHeader
  targetBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "state_target" tokens = some (Native.targetBody.render functionNames)
  readsHeader : functionHeader "state_reads" "is" tokens = some readsHeader
  readsBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "state_reads" tokens = some (Native.readsBody.render functionNames)

theorem Checked.meaning {tokens : List String} (checked : Checked tokens)
    (calls : ApplicationPackageEffects.Calls) (locals : Locals) :
    Checked tokens ∧
    Native.visibleBody.eval (callsOf calls) locals =
      visibleState calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "index") ∧
    Native.targetBody.eval (callsOf calls) locals =
      stateTarget calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "position") ∧
    Native.readsBody.eval (callsOf calls) locals =
      stateReads calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "first") (locals .number "after") :=
  ⟨checked, visible_denotation calls locals, target_denotation calls locals,
    reads_denotation calls locals⟩

end Silver.ApplicationPackageEffects.Native.Source
