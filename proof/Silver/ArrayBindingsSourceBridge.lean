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
    (text : Source) (valid : Native.ValidText text) (names : Table) (metadata : ValidTable text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names.items first after :=
  Native.interpreted_lookup calls source.primitives source.definitions text valid names metadata first after firstBound afterBound

theorem interpreted_contains (calls : Native.Calls) (source : InterpretedSource calls)
    (item : Binding) (indices : Integer.Interval) (itemType : Native.BindingType item) (indexType : indices.Bounded) :
    calls.contains item indices = contains item indices :=
  Native.interpreted_contains calls source.primitives source.definitions item indices itemType indexType

theorem interpreted_elementSlot (calls : Native.Calls) (source : InterpretedSource calls)
    (item : Binding) (index : Int) (valid : ValidNativeBinding item) (stored : item.viewSlot = 0) (inside : item.bounds.Contains index) :
    calls.elementSlot item index = elementSlot item index :=
  Native.interpreted_elementSlot calls source.definitions item index valid stored inside

theorem interpreted_readBounds (calls : Native.Calls) (source : InterpretedSource calls)
    (names : Table) (values : Initials) (elaborating : Bool) (target : Nat) (indices : Integer.Interval)
    (metadataCap : names.items.length ≤ maxBindings) (valuesValid : ValidInitials values)
    (positive : 0 < target) (targetBound : target ≤ names.items.length)
    (itemValid : ValidNativeBinding (binding names.items target)) (inside : contains (binding names.items target) indices = true) :
    calls.readBounds names values elaborating target indices = readViewBounds names.items values elaborating target indices :=
  Native.interpreted_readBounds calls source.primitives source.definitions names values elaborating target indices
    metadataCap valuesValid positive targetBound itemValid inside

theorem interpreted_lookupType (calls : Native.Calls) (source : InterpretedSource calls)
    (text : Source) (valid : Native.ValidText text) (types : TypeEnvironment) (metadata : ValidTypes text types)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookupType text types first after = lookupType text types first after :=
  Native.interpreted_lookupType calls source.primitives source.definitions text valid types metadata first after firstBound afterBound

structure PredicatesCorrect (calls : Native.Calls) : Prop where
  validType : ∀ item, Native.ArrayTypeType item → calls.validType item = decide (ValidType item)
  validBinding : ∀ item, Native.BindingType item → calls.validBinding item = decide (ValidNativeBinding item)
  validTypes : ∀ text, Native.ValidText text → ∀ types, Native.TypesType types →
    calls.validTypes text types = decide (ValidTypes text types)
  validMetadata : ∀ text, Native.ValidText text → ∀ names, Native.MetadataType names →
    calls.validMetadata text names = decide (ValidTable text names)
  validEnvironment : ∀ text, Native.ValidText text → ∀ environment, Native.EnvironmentType environment →
    calls.validEnvironment text environment = decide (ValidNativeEnvironment text environment)

theorem interpreted_predicates (calls : Native.Calls) (source : InterpretedSource calls) :
    PredicatesCorrect calls where
  validType := Native.interpreted_validType calls source.primitives source.definitions
  validBinding := Native.interpreted_validBinding calls source.primitives source.definitions
  validTypes := Native.interpreted_validTypes calls source.primitives source.definitions
  validMetadata := Native.interpreted_validMetadata calls source.primitives source.definitions
  validEnvironment := Native.interpreted_validEnvironment calls source.primitives source.definitions

/-- Every helper in the native package, including its recursive ghost models,
corresponds on its complete declared domain. -/
structure ImplementationCorrect (calls : Native.Calls) : Prop where
  predicates : PredicatesCorrect calls
  lookupModel : ∀ text, Native.ValidText text → ∀ names, ValidTable text names →
    ∀ first after index, first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.items.length →
      calls.lookupModel text names first after index = ArrayBindings.lookupFrom text names.items first after index
  lookup : ∀ text, Native.ValidText text → ∀ names, ValidTable text names →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.lookup text names first after = ArrayBindings.lookup text names.items first after
  lookupTypeModel : ∀ text, Native.ValidText text → ∀ types, ValidTypes text types →
    ∀ first after index, first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ types.length →
      calls.lookupTypeModel text types first after index = ArrayBindings.lookupTypeFrom text types first after index
  lookupType : ∀ text, Native.ValidText text → ∀ types, ValidTypes text types →
    ∀ first after, first ≤ text.length + 1 → after ≤ text.length + 1 →
      calls.lookupType text types first after = ArrayBindings.lookupType text types first after
  hullModel : ∀ values, ValidInitials values → ∀ first last,
    0 < first → first ≤ last → last ≤ maxElements →
      calls.hullModel values first last = ArrayBindings.hullModel values first last
  contains : ∀ item indices, Native.BindingType item → indices.Bounded →
    calls.contains item indices = ArrayBindings.contains item indices
  elementSlot : ∀ item index, ValidNativeBinding item → item.viewSlot = 0 → item.bounds.Contains index →
    calls.elementSlot item index = ArrayBindings.elementSlot item index
  readBounds : ∀ names values elaborating target indices,
    names.items.length ≤ maxBindings → ValidInitials values → 0 < target → target ≤ names.items.length →
    ValidNativeBinding (binding names.items target) → ArrayBindings.contains (binding names.items target) indices = true →
      calls.readBounds names values elaborating target indices = readViewBounds names.items values elaborating target indices

theorem interpreted_complete (calls : Native.Calls) (source : InterpretedSource calls) :
    ImplementationCorrect calls where
  predicates := interpreted_predicates calls source
  lookupModel := Native.interpreted_lookupModel calls source.primitives source.definitions
  lookup := interpreted_lookup calls source
  lookupTypeModel := Native.interpreted_lookupTypeModel calls source.primitives source.definitions
  lookupType := interpreted_lookupType calls source
  hullModel := Native.interpreted_hullModel calls source.primitives source.definitions
  contains := interpreted_contains calls source
  elementSlot := interpreted_elementSlot calls source
  readBounds := interpreted_readBounds calls source

theorem model_interpreted : InterpretedSource Native.modelCalls :=
  ⟨Native.model_primitives, Native.model_equations⟩

theorem actual_complete_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ImplementationCorrect calls :=
  ⟨SourceChecks.checked_source, interpreted_complete⟩

theorem actual_predicate_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → PredicatesCorrect calls :=
  ⟨SourceChecks.checked_source, interpreted_predicates⟩

theorem actual_source_correspondence : SourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ names values elaborating target indices,
      names.items.length ≤ maxBindings → ValidInitials values → 0 < target → target ≤ names.items.length →
      ValidNativeBinding (binding names.items target) → contains (binding names.items target) indices = true →
      calls.readBounds names values elaborating target indices = readViewBounds names.items values elaborating target indices :=
  ⟨SourceChecks.checked_source, interpreted_readBounds⟩

end Silver.ArrayBindings.SourceBridge
