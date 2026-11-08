module

public import Silver.FunctionBindingsSourceChecks

@[expose] public section

/-! Complete expression/helper correspondence for the native metadata package.
The imperative lookup uses its source-checked static postcondition, whose
GNATprove discharge remains a required native obligation. No accepted source
derives meaning from certificate generation. -/
namespace Silver.FunctionBindings.SourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  primitives : Native.Primitives calls
  definitions : Native.Equations calls

structure ImplementationCorrect (calls : Native.Calls) : Prop where
  lookup : ∀ text, Native.ValidText text → ∀ functions, ValidMetadata text functions →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.lookup text functions first after = FunctionBindings.lookup text functions first after
  validMetadata : ∀ text, Native.ValidText text → ∀ functions, Native.MetadataType functions →
    calls.validMetadata text functions = decide (ValidMetadata text functions)
  appendFormal : ∀ functions, Native.MetadataType functions → ∀ item, Native.FormalType item →
    functions.parameters.length < maxFormals →
    calls.appendFormal functions item = FunctionBindings.appendFormal functions item
  append : ∀ functions, Native.MetadataType functions → ∀ item, Native.SignatureType item →
    functions.items.length < maxFunctions →
    calls.append functions item = FunctionBindings.append functions item

theorem interpreted_complete (calls : Native.Calls) (source : InterpretedSource calls) :
    ImplementationCorrect calls where
  lookup := Native.interpreted_lookup calls source.primitives source.definitions
  validMetadata := Native.interpreted_validMetadata calls source.primitives source.definitions
  appendFormal := Native.interpreted_appendFormal calls source.definitions
  append := Native.interpreted_append calls source.definitions

theorem model_interpreted : InterpretedSource Native.modelCalls :=
  ⟨Native.model_primitives, Native.model_equations⟩

theorem actual_source_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ImplementationCorrect calls :=
  ⟨SourceChecks.checked_source, interpreted_complete⟩

end Silver.FunctionBindings.SourceBridge
