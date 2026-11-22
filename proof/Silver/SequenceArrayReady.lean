module

public import Silver.SequenceSubtypeReady
public import Silver.ComposeArrayElaboration

@[expose] public section

/-! Source allocation readiness follows the actual header token trace from
its empty state. No source-layout assumption is added at an admission endpoint. -/
namespace Silver.Sequence
open Compose

theorem step_array_types_valid {text form token state next event}
    (parsed : StepAt text form token state next event)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidTypes text next.arrayNames.types := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨values, reading, _⟩ := parsed.payload
    exact declarations_types_valid reading types subtypes
  · rw [step_arrayNames_preserved declaration parsed]
    exact types

theorem tokens_array_types_valid {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidTypes text final.arrayNames.types := by
  induction parsed with
  | done => exact types
  | next first _ ih => exact ih (step_array_types_valid first types subtypes) (step_subtypes_valid first subtypes)

theorem initial_array_types_valid (text : Source) :
    ArrayBindings.ValidTypes text initialState.arrayNames.types :=
  ArrayBindings.valid_empty_types text

theorem step_array_ready {text form token state next event}
    (parsed : StepAt text form token state next event)
    (ready : ArrayBindings.SourceReady text state.arrayNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.SourceReady text next.arrayNames := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨values, reading, _⟩ := parsed.payload
    exact declarations_array_ready reading ready types subtypes
  · rw [step_arrayNames_preserved declaration parsed]
    exact ready

theorem tokens_array_ready {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final)
    (ready : ArrayBindings.SourceReady text state.arrayNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  induction parsed with
  | done => exact ready
  | next first _ ih => exact ih (step_array_ready first ready types subtypes) (step_array_types_valid first types subtypes) (step_subtypes_valid first subtypes)

theorem initial_array_ready (text : Source) : ArrayBindings.SourceReady text initialState.arrayNames := by
  simp [initialState, ArrayBindings.SourceReady, ArrayBindings.ValidEnvironment,
    ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials, ArrayBindings.InitialsFit]

end Silver.Sequence
