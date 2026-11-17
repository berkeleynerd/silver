module

public import Silver.ProcedureBindingsSourceChecks
public import Silver.ProcedureMetadataValidity

@[expose] public section

/-! Complete expression/helper correspondence for the native metadata package.
The imperative lookup uses its source-checked static postcondition, whose
GNATprove discharge remains a required native obligation. No accepted source
derives meaning from certificate generation. -/
namespace Silver.ProcedureBindings.SourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  primitives : Native.Primitives calls
  definitions : Native.Equations calls

structure ImplementationCorrect (calls : Native.Calls) : Prop where
  lookup : ∀ text, Native.ValidText text → ∀ procedures, ValidMetadata text procedures →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.lookup text procedures first after = ProcedureBindings.lookup text procedures first after
  validMetadata : ∀ text, Native.ValidText text → ∀ procedures, Native.MetadataType procedures →
    calls.validMetadata text procedures = decide (ValidMetadata text procedures)
  appendFormal : ∀ procedures, Native.MetadataType procedures → ∀ item, Native.FormalType item →
    procedures.parameters.length < maxFormals →
    calls.appendFormal procedures item = ProcedureBindings.appendFormal procedures item
  append : ∀ procedures, Native.MetadataType procedures → ∀ item, Native.SignatureType item →
    procedures.items.length < maxProcedures →
    calls.append procedures item = ProcedureBindings.append procedures item

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

end Silver.ProcedureBindings.SourceBridge
