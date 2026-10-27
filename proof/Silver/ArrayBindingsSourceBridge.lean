module

public import Silver.ArrayBindingsSourceChecks

@[expose] public section

/-! Native array helper correspondence, on the actual native metadata and
value-table domains. Ordered source allocation is a separate invariant. -/
namespace Silver.ArrayBindings.SourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  primitives : Native.Primitives calls
  definitions : Native.Equations calls

theorem interpreted_lookup (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (names : Metadata) (metadata : ValidMetadata text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names first after :=
  Native.interpreted_lookup calls source.primitives source.definitions text valid names metadata first after firstBound afterBound

theorem interpreted_contains (calls : Native.Calls) (source : InterpretedSource calls)
    (item : Binding) (indices : Integer.Interval) (itemType : Native.BindingType item) (indexType : indices.Bounded) :
    calls.contains item indices = contains item indices :=
  Native.interpreted_contains calls source.primitives source.definitions item indices itemType indexType

theorem interpreted_elementSlot (calls : Native.Calls) (source : InterpretedSource calls)
    (item : Binding) (index : Int) (valid : ValidBinding item) (inside : item.bounds.Contains index) :
    calls.elementSlot item index = elementSlot item index :=
  Native.interpreted_elementSlot calls source.definitions item index valid inside

theorem interpreted_readBounds (calls : Native.Calls) (source : InterpretedSource calls)
    (names : Metadata) (values : Initials) (elaborating : Bool) (target : Nat) (indices : Integer.Interval)
    (metadataCap : names.length ≤ maxBindings) (valuesValid : ValidInitials values)
    (positive : 0 < target) (targetBound : target ≤ names.length)
    (itemValid : ValidBinding (binding names target)) (inside : contains (binding names target) indices = true) :
    calls.readBounds names values elaborating target indices = readBounds names values elaborating target indices :=
  Native.interpreted_readBounds calls source.primitives source.definitions names values elaborating target indices
    metadataCap valuesValid positive targetBound itemValid inside

theorem model_interpreted : InterpretedSource Native.modelCalls :=
  ⟨Native.model_primitives, Native.model_equations⟩

theorem actual_source_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ names values elaborating target indices,
      names.length ≤ maxBindings → ValidInitials values → 0 < target → target ≤ names.length →
      ValidBinding (binding names target) → contains (binding names target) indices = true →
      calls.readBounds names values elaborating target indices = readBounds names values elaborating target indices :=
  ⟨SourceChecks.checked_source, interpreted_readBounds⟩

end Silver.ArrayBindings.SourceBridge
