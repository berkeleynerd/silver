module

public import Silver.ApplicationPackageOriginalInitialization
public import Silver.ApplicationPackageSpecificationSeeds

@[expose] public section

/-! Original global initializer values. Each loaded constant or persistent cell
has a raw source expression, evaluated over the complete original elaboration
domain. Constant loading never supplies an unproved snapshot-value premise. -/
namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Packages ApplicationPackageDeclarations ApplicationPackageBodies
open ApplicationPackageObjectRows
open ScalarFunctions (Actual Value)

def globalInitializerFrame (text : Source) (frame : ParserState) (info : PackageBindings.Metadata) : ParserState :=
  initializerBase text frame info (objectName text frame) false

/-- Source syntax and evaluation, before replacing the expression by the value
recorded by the original nonlocal Object reader. Integer intermediate obligations
are retained here; complete range/Boolean obligations stay in ObjectSyntax. -/
inductive OriginalValueAt (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (out : ObjectResult) : Actual → Prop
  | integer {expression : Integer.Expr}
      (kind : out.mark.kind = .integer)
      (source : ScalarExpression.sourceSyntaxAt text (globalInitializerFrame text frame info).scalarNames []
        (objectName text frame).first (objectName text frame).after true out.initFirst ⟨out.initAfter, expression⟩)
      (discharged : Integer.discharged
        (expression.obligations (ScalarExpression.ranges (globalInitializerFrame text frame info).scalarNames)) = true)
      (value : ∀ integers,
        Integer.Fits (ScalarExpression.ranges (globalInitializerFrame text frame info).scalarNames) integers →
        expression.evaluate integers = out.initialBounds.lower) :
      OriginalValueAt text frame info out (.integer expression)
  | boolean {expression : Condition}
      (kind : out.mark.kind = .boolean)
      (source : BooleanElaboration.Native.ExpressionAt text (globalInitializerFrame text frame info)
        .condition out.initFirst expression out.initAfter)
      (value : ∀ integers flags,
        Integer.Fits (ScalarExpression.ranges (globalInitializerFrame text frame info).scalarNames) integers →
        BooleanBindings.KnownFits (globalInitializerFrame text frame info).booleanNames flags →
        ∀ values input inputValid,
          expression.evaluate values input inputValid integers flags = out.booleanValue) :
      OriginalValueAt text frame info out (.boolean expression)

theorem object_original_value {objects : ObjectLibraries}
    (library : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    (text : Source) (textValid : ValidText text) (frame : ParserState)
    (framed : ReaderFrame text frame) (info : PackageBindings.Metadata) {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls library.condition) text frame info false = out)
    (present : out.frame.position ≠ 0) :
    ∃ expression, OriginalValueAt text frame info out expression := by
  cases kind : out.mark.kind with
  | integer =>
    have calls := object_value_calls library.condition text frame framed info false (parsed ▸ present)
    rw [parsed] at calls
    obtain ⟨expression, source, discharged, _, value, _⟩ :=
      calls.scalar_constant_seed kind (object_global_singleton library.condition text frame info parsed present)
    refine ⟨.integer expression, .integer kind source discharged ?_⟩
    intro integers fitting
    exact Value.integer.inj (value integers fitting)
  | boolean =>
    have original := object_global_boolean_exact library checked text textValid frame framed info
      (parsed ▸ present) (parsed ▸ kind)
    rw [parsed] at original
    obtain ⟨expression, source, value⟩ := original
    exact ⟨.boolean expression, .boolean kind source value⟩

def ElaborationStore (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (state : ScalarFunctions.State) : Prop :=
  Integer.Fits (ScalarExpression.ranges (globalInitializerFrame text frame info).scalarNames) state.integers ∧
    BooleanBindings.KnownFits (globalInitializerFrame text frame info).booleanNames state.booleans

theorem OriginalValueAt.evaluate {text frame info out expression}
    (source : OriginalValueAt text frame info out expression)
    (state : ScalarFunctions.State) (fitting : ElaborationStore text frame info state) :
    expression.evaluate state = (objectConstantSeed out).value := by
  cases source with
  | integer kind _ _ value =>
    simpa only [Actual.evaluate, objectConstantSeed, kind, ConstantSeed.value] using
      congrArg Value.integer (value state.integers fitting.1)
  | boolean kind _ value =>
    simpa only [Actual.evaluate, objectConstantSeed, kind, ConstantSeed.value] using
      congrArg Value.boolean (value state.integers state.booleans fitting.1 fitting.2
        state.values state.input state.inputValid)

/-- Even if the raw elaboration store and invocation frame differ, the copied
constant has the original expression's value on every original fitting store. -/
theorem OriginalValueAt.constant_load {text frame info out expression}
    (source : OriginalValueAt text frame info out expression)
    (state : ScalarFunctions.State) (fitting : ElaborationStore text frame info state)
    (loaded : SharedState) :
    (initializeLocals loaded [(objectConstantSeed out).initializer]).read
        (.local (objectConstantSeed out).initializer.target) = expression.evaluate state := by
  have layout (seed : ConstantSeed) : seed.initializer.layout = constantLayout := by
    cases seed <;> rfl
  rw [initializeLocals, initializeLocals, layout, ConstantSeed.evaluate]
  have typed : CellValue (objectConstantSeed out).initializer.target (objectConstantSeed out).value := by
    cases kind : out.mark.kind <;>
      simp only [objectConstantSeed, kind, ConstantSeed.initializer, ConstantSeed.value, CellValue]
  exact (SharedState.read_write_same
    (place := .local (objectConstantSeed out).initializer.target) typed loaded).trans
    (source.evaluate state fitting).symm

theorem SpecificationInventories.object_values {objects : ObjectLibraries}
    (library : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    {text : Source} (textValid : ValidText text) {before : SpecificationState}
    {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories library.condition text before rows exit)
    (framed : ReaderFrame text before.exports) :
    ∀ row ∈ rows, ∀ out inventory, row.inventory = .object out inventory →
      ∃ expression, OriginalValueAt text row.before.exports row.before.info out expression := by
  induction history with
  | returned | ready => simp
  | @next row rows exit step source rest ih =>
    have nextFrame : ReaderFrame text row.after.exports := by
      have retained := specification_step_framed library.condition textValid row.before framed
      rwa [step] at retained
    intro observed member out inventory selected
    rcases List.mem_cons.mp member with same | later
    · subst observed
      rw [selected] at source
      exact object_original_value library checked text textValid row.before.exports framed row.before.info
        source.2.1 (specification_object_present source.2.1 source.1).1
    · exact ih nextFrame observed later out inventory selected

/-- Every source-ordered immutable load is connected to the exact declaration
row and raw expression which produced it. No accepted semantic library is input. -/
theorem SpecificationInventories.constant_values {objects : ObjectLibraries}
    (library : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    {text : Source} (textValid : ValidText text) {before : SpecificationState}
    {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories library.condition text before rows exit)
    (framed : ReaderFrame text before.exports) :
    ∀ seed ∈ specificationSeeds rows,
      ∃ row ∈ rows, ∃ out inventory expression,
        row.inventory = .object out inventory ∧ seed = objectConstantSeed out ∧
        OriginalValueAt text row.before.exports row.before.info out expression := by
  intro seed member
  obtain ⟨row, member, selected⟩ := List.mem_filterMap.mp member
  cases found : row.inventory with
  | routine | subtype => simp [found, SpecificationSyntax.seed] at selected
  | object out inventory =>
    have same : seed = objectConstantSeed out := by
      simpa only [found, SpecificationSyntax.seed, Option.some.injEq] using selected.symm
    obtain ⟨expression, source⟩ := history.object_values library checked textValid framed row member out inventory found
    exact ⟨row, member, out, inventory, expression, found, same, source⟩

/-- A constant load retains its original declaration and raw initializer.
The source relation is constructed from the original history below. -/
structure OriginalConstant (text : Source) where
  row : SpecificationItem
  out : ObjectResult
  inventory : ObjectSyntax
  expression : Actual
  declaration : row.inventory = .object out inventory
  source : OriginalValueAt text row.before.exports row.before.info out expression

def OriginalConstant.seed {text : Source} (item : OriginalConstant text) : ConstantSeed :=
  objectConstantSeed item.out

private theorem original_constant_rows {text : Source} (rows : List SpecificationItem)
    (values : ∀ row ∈ rows, ∀ out inventory, row.inventory = .object out inventory →
      ∃ expression, OriginalValueAt text row.before.exports row.before.info out expression) :
    ∃ readings : List (OriginalConstant text), readings.map OriginalConstant.seed = specificationSeeds rows ∧
      ∀ item ∈ readings, item.row ∈ rows := by
  induction rows with
  | nil => exact ⟨[], rfl, by simp⟩
  | cons row rest ih =>
    obtain ⟨following, ordered, owned⟩ := ih (fun next member => values next (List.mem_cons_of_mem _ member))
    cases selected : row.inventory with
    | routine | subtype =>
      refine ⟨following, ?_, fun item member => List.mem_cons_of_mem _ (owned item member)⟩
      simpa only [specificationSeeds, List.filterMap_cons, selected, SpecificationSyntax.seed] using ordered
    | object out inventory =>
      obtain ⟨expression, source⟩ := values row List.mem_cons_self out inventory selected
      let current : OriginalConstant text := ⟨row, out, inventory, expression, selected, source⟩
      refine ⟨current :: following, ?_, ?_⟩
      · simpa only [List.map_cons, specificationSeeds, List.filterMap_cons, selected,
          SpecificationSyntax.seed, current, OriginalConstant.seed] using
          congrArg (List.cons (objectConstantSeed out)) ordered
      · intro item member
        rcases List.mem_cons.mp member with same | later
        · subst item
          exact List.mem_cons_self
        · exact List.mem_cons_of_mem _ (owned item later)

def loadOriginalConstants {text : Source} (stores : OriginalConstant text → ScalarFunctions.State) :
    SharedState → List (OriginalConstant text) → SharedState
  | state, [] => state
  | state, item :: rest =>
      loadOriginalConstants stores
        (state.write (.local item.seed.initializer.target) (item.expression.evaluate (stores item))) rest

/-- Equality of the entire source-ordered loading prefix for arbitrary backing
and full incoming elaboration stores. No snapshot equality is an assumption. -/
theorem loadOriginalConstants_eq {text : Source} (readings : List (OriginalConstant text))
    (stores : OriginalConstant text → ScalarFunctions.State)
    (fitting : ∀ item ∈ readings,
      ElaborationStore text item.row.before.exports item.row.before.info (stores item))
    (backing : SharedState) :
    loadOriginalConstants stores backing readings =
      initializeLocals backing ((readings.map OriginalConstant.seed).map ConstantSeed.initializer) := by
  induction readings generalizing backing with
  | nil => rfl
  | cons item rest ih =>
    have layout (seed : ConstantSeed) : seed.initializer.layout = constantLayout := by
      cases seed <;> rfl
    simp only [loadOriginalConstants, List.map_cons, initializeLocals]
    rw [item.source.evaluate (stores item) (fitting item List.mem_cons_self), layout, ConstantSeed.evaluate]
    exact ih (fun next member => fitting next (List.mem_cons_of_mem _ member)) _

theorem SpecificationInventories.constant_loading {objects : ObjectLibraries}
    (library : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    {text : Source} (textValid : ValidText text) {before : SpecificationState}
    {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories library.condition text before rows exit)
    (framed : ReaderFrame text before.exports) :
    ∃ readings : List (OriginalConstant text), readings.map OriginalConstant.seed = specificationSeeds rows ∧
      (∀ item ∈ readings, item.row ∈ rows) ∧
      ∀ stores, (∀ item ∈ readings,
        ElaborationStore text item.row.before.exports item.row.before.info (stores item)) → ∀ backing,
        loadOriginalConstants stores backing readings =
          initializeLocals backing ((specificationSeeds rows).map ConstantSeed.initializer) := by
  obtain ⟨readings, ordered, owned⟩ :=
    original_constant_rows rows (history.object_values library checked textValid framed)
  refine ⟨readings, ordered, owned, ?_⟩
  intro stores fitting backing
  rw [← ordered]
  exact loadOriginalConstants_eq readings stores fitting backing

theorem StateObjects.original_values {objects : ObjectLibraries}
    (library : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    {calls : UnitCalls} {text : Source} {before after : UnitState} {rows : List StateObject}
    (textValid : ValidText text) (framed : ReaderFrame text before.globals)
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls library.condition) text row.before.globals row.before.info false) :
    ∀ row ∈ rows, ∃ expression,
      OriginalValueAt text row.before.globals row.before.info row.object expression := by
  induction history with
  | finished => simp
  | @added row following final phase selected capacity parsed advanced writable rest ih =>
    have execution := (original row List.mem_cons_self).symm.trans parsed
    have present : row.object.frame.position ≠ 0 := by omega
    have next :=
      execution ▸ objectStep_reader_frame library.condition textValid row.before.globals framed
        row.before.info false (execution ▸ present)
    intro observed member
    rcases List.mem_cons.mp member with same | later
    · subst observed
      exact object_original_value library checked text textValid row.before.globals framed row.before.info execution present
    · exact ih next (fun other member => original other (List.mem_cons_of_mem _ member)) observed later

theorem BodyHistory.original_values {objects : ObjectLibraries}
    (booleans : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    (library : ApplicationPackageCompletion.Library) {sources : ApplicationUnits.Bundle}
    {specification : SpecificationResult} {result : ApplicationAdmission.BodyResult}
    (history : BodyHistory booleans.condition
      (ApplicationPackageCompletion.LeafLibraries.model (library.calls booleans.condition)) sources specification result)
    (valid : ValidText (sources.prefix .packageBody))
    (framed : ReaderFrame (sources.prefix .packageBody) specification.exports)
    (typed : specification.info.Typed) :
    ∀ row ∈ history.objects, ∃ expression,
      OriginalValueAt (sources.prefix .packageBody) row.before.globals row.before.info row.object expression := by
  have entry := unit_start_domain booleans.condition _ valid _ framed _ typed history.entered
  exact StateObjects.original_values booleans checked valid entry.frame history.declarations (fun _ _ => rfl)

theorem state_initial_value (out : ObjectResult) (identity : Nat) :
    ((stateDeclaration out).semantic identity).initial = (objectConstantSeed out).value := by
  cases kind : out.mark.kind <;>
    simp only [stateDeclaration, PackageBindings.StateDeclaration.semantic, objectConstantSeed, kind, ConstantSeed.value]

/-- The final metadata uses declaration-order state identities. Loading it into
any backing frame gives the original initializer's value, not merely an interval
endpoint chosen without an evaluation proof. -/
theorem BodyHistory.loaded_values {objects : ObjectLibraries}
    (booleans : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    (library : ApplicationPackageCompletion.Library) {sources : ApplicationUnits.Bundle}
    {specification : SpecificationResult} {result : ApplicationAdmission.BodyResult}
    (history : BodyHistory booleans.condition
      (ApplicationPackageCompletion.LeafLibraries.model (library.calls booleans.condition)) sources specification result)
    (valid : ValidText (sources.prefix .packageBody))
    (framed : ReaderFrame (sources.prefix .packageBody) specification.exports)
    (typed : specification.info.Typed) (resultTyped : result.info.Typed)
    (metadata : PackageBindings.validMetadata
      (ApplicationPackageNames.metadataText (sources.pool.take sources.used)) result.info = true)
    (index : Nat) (inside : index < history.objects.length) :
    ∃ row expression, history.objects[index]? = some row ∧
      OriginalValueAt (sources.prefix .packageBody) row.before.globals row.before.info row.object expression ∧
      ∀ state, ElaborationStore (sources.prefix .packageBody) row.before.globals row.before.info state →
        ∀ backing, readCell (initializeFrom backing result.info.stateSchema)
          ((stateDeclaration row.object).cell (index + 1)) = expression.evaluate state := by
  let row := history.objects[index]
  have selected : history.objects[index]? = some row := List.getElem?_eq_getElem inside
  have member : row ∈ history.objects := List.getElem_mem inside
  obtain ⟨expression, source⟩ := BodyHistory.original_values booleans checked library history valid framed typed row member
  have entry : result.info.stateAt (index + 1) = stateDeclaration row.object := by
    simp only [PackageBindings.Metadata.stateAt, history.states, Nat.add_one_sub_one,
      List.getD_eq_getElem?_getD, List.getElem?_map, selected, Option.map_some, Option.getD_some]
  have ordinal : index < result.info.states.length := by
    simpa only [history.states, List.length_map] using inside
  have declaration : (stateDeclaration row.object).semantic (index + 1) ∈ result.info.stateSchema := by
    apply List.mem_map.mpr
    exact ⟨index, List.mem_range.mpr ordinal, congrArg (fun item => item.semantic (index + 1)) entry⟩
  have schemaValid := result.info.stateSchema_valid resultTyped metadata
  refine ⟨row, expression, selected, source, ?_⟩
  intro state fitting backing
  have loaded := initializeFrom_value schemaValid declaration backing
  rw [PackageBindings.StateDeclaration.semantic_cell, state_initial_value] at loaded
  exact loaded.trans (source.evaluate state fitting).symm

end Silver.ApplicationPackageInitializers
