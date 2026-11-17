module

public import Silver.ProcedureDeclarationOuterLibrary
public import Silver.ProcedureDeclarationHighSource
public import Silver.FunctionDeclarationStateRecords

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

/-- Complete declaration meaning is derived from the checked high-level
trees, the low helper equations and the directly linked native libraries. -/
structure InterpretedSource (calls : Calls) where
  helpers : InterpretedHelpers calls
  links : OuterLinks calls helpers
  equations : HighEquations calls

theorem interpreted_source_declaration {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState)
    (arguments : Bool) (valid : StateInput text state) :
    calls .procedureDeclaration text state arguments = procedureDeclarationAt text state arguments :=
  interpreted_declaration calls source.equations text tv state arguments valid
    (declaration_library_imports source.helpers source.links source.equations text tv state arguments valid)

theorem interpreted_native_declaration {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState)
    (arguments : Bool) (valid : FunctionDeclarationNative.NativeValidState text state) :
    calls .procedureDeclaration text state arguments = procedureDeclarationAt text state arguments :=
  interpreted_source_declaration source text tv state arguments
    (FunctionDeclarationNative.StateInput.ofNative tv valid)

theorem checked_source_declaration (tokens : List String) (checked : HighSourceChecks.Checked tokens) :
    HighSourceChecks.Checked tokens ∧ ∀ calls, InterpretedSource calls →
      ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments, StateInput text state →
        calls .procedureDeclaration text state arguments = procedureDeclarationAt text state arguments :=
  ⟨checked, fun _ source => interpreted_source_declaration source⟩

end Silver.Compose.ProcedureDeclarationNative
