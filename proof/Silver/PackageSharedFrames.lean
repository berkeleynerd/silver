module

public import Silver.PackageInitialization

@[expose] public section

/-! Shared writes agree with ordinary scalar frame writes under an injective
layout. Package calls invalidate precisely the visible written-global ranges;
hidden global cells retain the full schema invariant even while a local binder
hides their name. These are representation lemmas, not extra source conditions. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType)

def FrameLayout.Injective (layout : FrameLayout) : Prop := Function.Injective layout.place

theorem SharedState.view_write {layout : FrameLayout} (unique : layout.Injective)
    (state : SharedState) (target : Cell) (value : Value) (typed : CellValue target value) :
    (state.write (layout.place target) value).view layout = writeCell (state.view layout) target value := by
  apply frame_ext
  intro observed
  rw [SharedState.view_read]
  by_cases same : observed = target
  · subst observed
    rw [SharedState.read_write_same (FrameLayout.place_value typed), readCell_write_same typed]
  · have apart : layout.place observed ≠ layout.place target := fun equal => same (unique equal)
    rw [SharedState.read_write_other apart, readCell_write_other same]
    exact (state.view_read layout observed).symm

theorem SharedState.view_write_total {layout : FrameLayout} (unique : layout.Injective)
    (state : SharedState) (target : Cell) (value : Value) :
    (state.write (layout.place target) value).view layout = writeCell (state.view layout) target value := by
  cases target with
  | integer identity =>
      cases value with
      | integer value => exact state.view_write unique _ _ trivial
      | boolean | array =>
          cases selected : layout.integers identity <;>
            simp only [FrameLayout.place, selected, SharedState.write, writeCell]
  | boolean identity =>
      cases value with
      | boolean value => exact state.view_write unique _ _ trivial
      | integer | array =>
          cases selected : layout.booleans identity <;>
            simp only [FrameLayout.place, selected, SharedState.write, writeCell]

/-- Retain Main's complete expression context while replacing its scalar view. -/
def withScalarFrame (state : ScalarFunctions.State) (frame : Frame) : ScalarFunctions.State :=
  {state with integers := frame.integers, booleans := frame.booleans}

theorem withScalarFrame_write (state : ScalarFunctions.State) (frame : Frame)
    (target : ScalarFunctions.Target) (value : Value) :
    withScalarFrame state (writeCell frame (ScalarProcedures.targetCell target) value) =
      target.write value (withScalarFrame state frame) := by
  cases target <;> cases value <;> rfl

theorem copySharedOutputs_view {layout : FrameLayout} (unique : layout.Injective)
    (targets : List ScalarFunctions.Target) (values : List Value) (state : SharedState)
    (context : ScalarFunctions.State) :
    withScalarFrame context ((copySharedOutputs layout targets values state).view layout) =
      ScalarProcedures.copyBack targets values (withScalarFrame context (state.view layout)) := by
  induction targets generalizing values state with
  | nil => rfl
  | cons target targets ih =>
      cases values with
      | nil => rfl
      | cons value values =>
          rw [copySharedOutputs, ih, ScalarProcedures.copyBack,
            SharedState.view_write_total unique, withScalarFrame_write]

theorem SharedState.write_schema_fits {schema : StateSchema} {layout : FrameLayout}
    {state : SharedState} {target : Cell} {value : Value}
    (valid : schema.Valid) (fitting : schema.Fits state.globals)
    (written : ∀ declaration ∈ schema, layout.place target = .global declaration.cell →
      declaration.domain.Contains value) :
    schema.Fits (state.write (layout.place target) value).globals := by
  intro declaration present
  by_cases same : layout.place target = .global declaration.cell
  · have contained := written declaration present same
    have kind := contains_cell_value (valid.2 declaration present).2.1 contained
    simpa only [same, SharedState.write, readCell_write_same kind] using contained
  · have changes := state.write_globals layout target value declaration.cell
    have absent : declaration.cell ∉ globalCells layout [target] := by
      intro member
      obtain ⟨cell, singleton, equal⟩ := globalCells_mem.mp member
      have targetEq : cell = target := by simpa only [List.mem_singleton] using singleton
      exact same (targetEq ▸ equal)
    rw [changes absent]
    exact fitting declaration present

def resetGlobalRanges (declared current : Integer.Ranges) (layout : FrameLayout)
    (writes : List Cell) : Integer.Ranges :=
  fun index => match layout.integers index with
    | .global identity => if .integer identity ∈ writes then declared index else current index
    | .local _ => current index

/-- Every visible global range comes from the corresponding declaration in the
original state schema. Local metadata never supplies a hidden global's domain. -/
def FrameLayout.CoversGlobals (layout : FrameLayout) (schema : StateSchema) (declared : Integer.Ranges) : Prop :=
  ∀ index identity bounds, layout.integers index = .global identity → declared index = some bounds →
    ∃ declaration ∈ schema, declaration.cell = .integer identity ∧ declaration.domain = .integer bounds

theorem resetGlobalRanges_fits {layout : FrameLayout} {schema : StateSchema}
    {declared current : Integer.Ranges} {before : SharedState} {after : Frame} {writes : List Cell}
    (covered : layout.CoversGlobals schema declared)
    (fitting : Integer.Fits current (before.view layout).integers)
    (globalsFit : schema.Fits after) (changes : ChangesOnly writes before.globals after) :
    Integer.Fits (resetGlobalRanges declared current layout writes)
      ({before with globals := after}.view layout).integers := by
  intro index bounds found
  cases selected : layout.integers index with
  | global identity =>
      by_cases written : ScalarProcedures.Cell.integer identity ∈ writes
      · have declaredRange : declared index = some bounds := by
          simpa only [resetGlobalRanges, selected, written, ↓reduceIte] using found
        obtain ⟨declaration, present, cell, domain⟩ := covered index identity bounds selected declaredRange
        have within := globalsFit declaration present
        simpa only [domain, cell, readCell, ScalarType.Contains, SharedState.view, SharedState.integer, selected] using within
      · have currentRange : current index = some bounds := by
          simpa only [resetGlobalRanges, selected, written, ↓reduceIte] using found
        have unchanged : after.integers identity = before.globals.integers identity :=
          Value.integer.inj (changes (.integer identity) written)
        simpa only [SharedState.view, SharedState.integer, selected, unchanged] using fitting index bounds currentRange
  | «local» identity =>
      have currentRange : current index = some bounds := by
        simpa only [resetGlobalRanges, selected] using found
      simpa only [SharedState.view, SharedState.integer, selected] using fitting index bounds currentRange

def resetGlobalFlow (declared : Integer.Ranges) (layout : FrameLayout)
    (writes : List Cell) (flow : Predicate.Flow) : Predicate.Flow :=
  {flow with scalars := resetGlobalRanges declared flow.scalars layout writes}

theorem resetGlobalFlow_allows {layout : FrameLayout} {schema : StateSchema}
    {declared : Integer.Ranges} {flow : Predicate.Flow} {before : SharedState} {after : Frame}
    {writes : List Cell} {valid rejected : Bool} {length : Nat}
    (covered : layout.CoversGlobals schema declared)
    (allowed : flow.Allows valid length rejected (before.view layout).integers)
    (globalsFit : schema.Fits after) (changes : ChangesOnly writes before.globals after) :
    (resetGlobalFlow declared layout writes flow).Allows valid length rejected
      ({before with globals := after}.view layout).integers :=
  ⟨allowed.1, resetGlobalRanges_fits covered allowed.2 globalsFit changes⟩

theorem resetGlobalRanges_readonly {declared current : Integer.Ranges} {layout : FrameLayout}
    {writes : List Cell} {index : Nat}
    (unwritten : ∀ identity, layout.integers index = .global identity → ScalarProcedures.Cell.integer identity ∉ writes) :
    resetGlobalRanges declared current layout writes index = current index := by
  cases selected : layout.integers index with
  | global identity => simp only [resetGlobalRanges, selected, unwritten identity selected, ↓reduceIte]
  | «local» identity => simp only [resetGlobalRanges, selected]

/-- These are representation properties of the resolved native frame. Every
visible persistent integer has its declaration domain; hidden state is covered
by the schema invariant. A loop binder is represented by a local address. -/
structure FrameLayout.Context (layout : FrameLayout) (schema : StateSchema)
    (analysis : Integer.Analysis) : Prop where
  unique : layout.Injective
  covered : layout.CoversGlobals schema analysis.declared
  reflected : ∀ declaration ∈ schema, ∀ index identity,
    declaration.cell = .integer identity → layout.integers index = .global identity →
      ∃ bounds, declaration.domain = .integer bounds ∧ analysis.declared index = some bounds
  mutable : ∀ index identity, layout.integers index = .global identity → analysis.mutable index = true

theorem FrameLayout.Context.withIndex {layout : FrameLayout} {schema : StateSchema}
    {analysis : Integer.Analysis} (context : layout.Context schema analysis)
    {index localIdentity : Nat} (localIndex : layout.integers index = .local localIdentity)
    (bounds : Integer.Interval) : layout.Context schema (analysis.withIndex index bounds) where
  unique := context.unique
  covered := by
    intro other identity interval selected found
    have different : other ≠ index := by intro equal; subst other; rw [localIndex] at selected; contradiction
    exact context.covered other identity interval selected
      (by simpa only [Integer.Analysis.withIndex, Integer.put, different, ↓reduceIte] using found)
  reflected := by
    intro declaration present other identity cell selected
    have different : other ≠ index := by intro equal; subst other; rw [localIndex] at selected; contradiction
    obtain ⟨interval, domain, declared⟩ := context.reflected declaration present other identity cell selected
    exact ⟨interval, domain, by simpa only [Integer.Analysis.withIndex, Integer.put, different, ↓reduceIte] using declared⟩
  mutable := by
    intro other identity selected
    have different : other ≠ index := by intro equal; subst other; rw [localIndex] at selected; contradiction
    simpa only [Integer.Analysis.withIndex, Integer.put, different, ↓reduceIte] using
      context.mutable other identity selected

theorem replaceGlobals_declared_fits {layout : FrameLayout} {schema : StateSchema}
    {declared : Integer.Ranges} {before : SharedState} {after : Frame}
    (covered : layout.CoversGlobals schema declared)
    (fitting : Integer.Fits declared (before.view layout).integers)
    (globalsFit : schema.Fits after) :
    Integer.Fits declared ({before with globals := after}.view layout).integers := by
  intro index bounds found
  cases selected : layout.integers index with
  | global identity =>
      obtain ⟨declaration, present, cell, domain⟩ := covered index identity bounds selected found
      have within := globalsFit declaration present
      simpa only [domain, cell, readCell, ScalarType.Contains, SharedState.view,
        SharedState.integer, selected] using within
  | «local» identity =>
      simpa only [SharedState.view, SharedState.integer, selected] using fitting index bounds found

theorem schema_from_visible_changes {layout : FrameLayout} {schema : StateSchema}
    {analysis : Integer.Analysis} {before after : SharedState} {targets : List Cell}
    (context : layout.Context schema analysis) (valid : schema.Valid)
    (fitting : schema.Fits before.globals)
    (declared : Integer.Fits analysis.declared (after.view layout).integers)
    (changes : ChangesOnly (globalCells layout targets) before.globals after.globals) :
    schema.Fits after.globals := by
  intro declaration present
  have kind := (valid.2 declaration present).2.1
  cases cell : declaration.cell with
  | boolean identity =>
      cases domain : declaration.domain <;> simp only [cell, domain, CellDomain] at kind
      all_goals try contradiction
      simp only [readCell, ScalarType.Contains]
  | integer identity =>
      by_cases written : declaration.cell ∈ globalCells layout targets
      · obtain ⟨target, _, selected⟩ := globalCells_mem.mp written
        cases target with
        | boolean target =>
            cases located : layout.booleans target <;>
              simp [FrameLayout.place, located, cell] at selected
        | integer target =>
            have located : layout.integers target = .global identity := by
              cases location : layout.integers target with
              | global chosen =>
                  have same : chosen = identity := by
                    simpa only [FrameLayout.place, location, cell, Place.global.injEq,
                      ScalarProcedures.Cell.integer.injEq] using selected
                  simp only [same]
              | «local» chosen => simp [FrameLayout.place, location] at selected
            obtain ⟨bounds, domain, found⟩ := context.reflected declaration present target identity cell located
            have within := declared target bounds found
            simpa only [cell, domain, ScalarType.Contains, readCell, SharedState.view,
              SharedState.integer, located] using within
      · rw [← cell, changes declaration.cell written]
        exact fitting declaration present

theorem SharedState.write_schema_from_declared {layout : FrameLayout} {schema : StateSchema}
    {analysis : Integer.Analysis} {state : SharedState} {target : Cell} {value : Value}
    (context : layout.Context schema analysis) (valid : schema.Valid)
    (fitting : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared
      ((state.write (layout.place target) value).view layout).integers) :
    schema.Fits (state.write (layout.place target) value).globals :=
  schema_from_visible_changes context valid fitting declared (state.write_globals layout target value)

theorem SharedState.write_local_globals (state : SharedState) (target : Cell) (value : Value) :
    (state.write (.local target) value).globals = state.globals := rfl

theorem SharedState.write_integer_view {layout : FrameLayout} (unique : layout.Injective)
    (state : SharedState) (index : Nat) (value : Int) :
    ((state.write (layout.place (.integer index)) (.integer value)).view layout).integers =
      Integer.put (state.view layout).integers index value := by
  rw [state.view_write unique (.integer index) (.integer value) trivial]
  rfl

theorem SharedState.write_boolean_view {layout : FrameLayout} (unique : layout.Injective)
    (state : SharedState) (index : Nat) (value : Bool) :
    ((state.write (layout.place (.boolean index)) (.boolean value)).view layout).integers =
      (state.view layout).integers := by
  rw [state.view_write unique (.boolean index) (.boolean value) trivial]
  rfl

theorem RoutineDefinition.execute_readonly {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.RespectsEffects earlier) {definition : RoutineDefinition} {effects : Effects}
    (inferred : definition.inferEffects earlier = some effects) (readonly : effects.writes = [])
    (globals : Frame) (inputs : List Value) :
    (definition.execute environment globals inputs).1 = globals := by
  apply frame_ext
  intro cell
  exact definition.execute_changes previous inferred globals inputs cell (by simp [readonly])

end Silver.Packages
