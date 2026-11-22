module

public import Silver.PackageLowering

@[expose] public section

/-! Package routines bind their explicit incoming tuple before local and out
initialization, execute the original resolved scalar body, and collect explicit
results from the completed frame. The effect/locality fold visits every
definition in completion order, including definitions never called by Main. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Actual)

def initializerReads (initializers : List LocalInitializer) : List Cell :=
  initializers.flatMap fun item => globalCells item.layout (actualReads item.value)

theorem initializeLocals_agreement {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (initializers : List LocalInitializer)
    (scalar : ∀ item ∈ initializers, ScalarFunctions.scalarActual item.value = true)
    (covered : ∀ cell ∈ initializerReads initializers, cell ∈ cells) :
    SharedAgreement cells (initializeLocals first initializers) (initializeLocals second initializers) := by
  induction initializers generalizing first second with
  | nil => exact same
  | cons item rest ih =>
      have value := same.actual_evaluate item.layout item.value (scalar item (by simp))
        (fun cell member => covered cell (List.mem_flatMap.mpr ⟨item, by simp, member⟩))
      simp only [initializeLocals, value]
      apply ih (same.write (.local item.target) _)
      · intro next member
        exact scalar next (by simp [member])
      · intro cell member
        apply covered
        simp only [initializerReads, List.flatMap_cons, List.mem_append]
        exact Or.inr member

structure RoutineDefinition where
  signature : RoutineSignature
  inputs : List InputBinding
  initializers : List LocalInitializer
  layout : FrameLayout
  body : List Predicate.Statement
  results : List Actual

def RoutineDefinition.initialEffects (definition : RoutineDefinition) : Effects :=
  ⟨initializerReads definition.initializers, []⟩

def RoutineDefinition.resultEffects (definition : RoutineDefinition) : Effects :=
  directEffects definition.layout (actualsReads definition.results) []

def RoutineDefinition.inferEffects (earlier : EffectEnvironment) (definition : RoutineDefinition) : Option Effects :=
  if definition.initializers.all (fun item => ScalarFunctions.scalarActual item.value) &&
      definition.results.all ScalarFunctions.scalarActual then
    (inferBodyEffects earlier definition.layout definition.body).map fun body =>
      definition.initialEffects.merge (body.merge definition.resultEffects)
  else none

structure RoutineDefinition.Inferred (earlier : EffectEnvironment)
    (definition : RoutineDefinition) (effects : Effects) : Prop where
  initializers : ∀ item ∈ definition.initializers, ScalarFunctions.scalarActual item.value = true
  results : ∀ actual ∈ definition.results, ScalarFunctions.scalarActual actual = true
  body : ∃ bodyEffects, inferStatementsEffects earlier definition.layout definition.body = some bodyEffects ∧
    ScalarProcedures.scalarStatements definition.body = true ∧
    effects = definition.initialEffects.merge (bodyEffects.merge definition.resultEffects)

theorem RoutineDefinition.inferEffects_sound {earlier : EffectEnvironment} {definition : RoutineDefinition}
    {effects : Effects} (inferred : definition.inferEffects earlier = some effects) :
    definition.Inferred earlier effects := by
  unfold inferEffects at inferred
  split at inferred
  · rename_i selected
    have selections := Bool.and_eq_true_iff.mp selected
    obtain ⟨body, bodyFound, rfl⟩ := Option.map_eq_some_iff.mp inferred
    have scalar := inferBodyEffects_scalar bodyFound
    have bodyExact : inferStatementsEffects earlier definition.layout definition.body = some body := by
      simpa [inferBodyEffects, scalar] using bodyFound
    exact ⟨List.all_eq_true.mp selections.1, List.all_eq_true.mp selections.2, body, bodyExact, scalar, rfl⟩
  · contradiction

def RoutineDefinition.executeFrame (earlier : SharedEnvironment) (definition : RoutineDefinition)
    (globals : Frame) (inputs : List Value) : SharedState :=
  executeSharedStatements earlier definition.layout
    (invocationFrame globals definition.inputs inputs definition.initializers) definition.body

def RoutineDefinition.execute (earlier : SharedEnvironment) (definition : RoutineDefinition)
    (globals : Frame) (inputs : List Value) : Frame × List Value :=
  let final := definition.executeFrame earlier globals inputs
  (final.globals, final.actuals definition.layout definition.results)

theorem RoutineDefinition.execute_changes {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.RespectsEffects earlier) {definition : RoutineDefinition} {effects : Effects}
    (inferred : definition.inferEffects earlier = some effects) (globals : Frame) (inputs : List Value) :
    ChangesOnly effects.writes globals (definition.execute environment globals inputs).1 := by
  have facts := definition.inferEffects_sound inferred
  obtain ⟨body, bodyFound, _, rfl⟩ := facts.body
  have result := executeSharedStatements_changes previous definition.layout
    (invocationFrame globals definition.inputs inputs definition.initializers) definition.body bodyFound
  simpa [execute, executeFrame, Effects.merge, initialEffects, resultEffects, directEffects, globalCells,
    invocationFrame_globals] using result

theorem RoutineDefinition.execute_local {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.LocalOn earlier) {definition : RoutineDefinition} {effects : Effects}
    (inferred : definition.inferEffects earlier = some effects) {first second : Frame}
    (same : EqualOn effects.cells first second) (inputs : List Value) :
    (definition.execute environment second inputs).2 = (definition.execute environment first inputs).2 ∧
      EqualOn effects.cells (definition.execute environment first inputs).1
        (definition.execute environment second inputs).1 := by
  have facts := definition.inferEffects_sound inferred
  obtain ⟨body, bodyFound, scalar, effectEq⟩ := facts.body
  have self : effects.CapturedIn effects.cells := fun cell member => (Effects.mem_cells _ _).mpr member
  have total : (definition.initialEffects.merge (body.merge definition.resultEffects)).CapturedIn effects.cells := by
    rw [← effectEq]
    exact self
  have initialized : SharedAgreement effects.cells
      (invocationFrame first definition.inputs inputs definition.initializers)
      (invocationFrame second definition.inputs inputs definition.initializers) := by
    let locals := bindInputs ⟨Integer.emptyStore, Boolean.emptyStore⟩ definition.inputs inputs
    have initial : SharedAgreement effects.cells (⟨first, locals⟩ : SharedState) ⟨second, locals⟩ := ⟨same, rfl⟩
    apply initializeLocals_agreement initial definition.initializers facts.initializers
    intro cell member
    exact total.left cell (Or.inl member)
  have final := executeSharedStatements_agreement previous definition.layout initialized
    definition.body scalar bodyFound total.right.left
  have values := final.actuals_evaluate definition.layout definition.results facts.results
    (fun cell member => total.right.right cell (Or.inl member))
  exact ⟨values, final.globals⟩

def SharedEnvironment.append (earlier : SharedEnvironment) (definition : RoutineDefinition) : SharedEnvironment :=
  let identity := earlier.signatures.length + 1
  { signatures := earlier.signatures ++ [definition.signature]
    functions := fun called globals inputs =>
      if called = identity then
        match definition.signature with
        | .function _ => ((definition.execute earlier globals inputs).2).headD (.integer 0)
        | .procedure _ => .integer 0
      else earlier.functions called globals inputs
    procedures := fun called globals inputs =>
      if called = identity then
        match definition.signature with
        | .function _ => (globals, [])
        | .procedure _ => definition.execute earlier globals inputs
      else earlier.procedures called globals inputs }

theorem lookupRoutine_append {α : Type} {earlier : List α} {item result : α} {identity : Nat}
    (found : lookupRoutine (earlier ++ [item]) identity = some result) :
    (identity ≤ earlier.length ∧ lookupRoutine earlier identity = some result) ∨
      (identity = earlier.length + 1 ∧ result = item) := by
  have bounds := lookupRoutine_before found
  by_cases old : identity ≤ earlier.length
  · refine Or.inl ⟨old, ?_⟩
    simp only [lookupRoutine, show identity ≠ 0 by omega, ↓reduceIte] at found ⊢
    rw [List.getElem?_append_left (by omega)] at found
    exact found
  · have current : identity = earlier.length + 1 := by
      simp only [List.length_append, List.length_singleton] at bounds
      omega
    subst identity
    have equal : item = result := by simpa [lookupRoutine] using found
    exact Or.inr ⟨rfl, equal.symm⟩

theorem SharedEnvironment.append_respectsEffects {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.RespectsEffects earlier) {definition : RoutineDefinition} {effects : Effects}
    (inferred : definition.inferEffects earlier = some effects) :
    (environment.append definition).RespectsEffects (earlier ++ [⟨definition.signature, effects⟩]) := by
  refine ⟨by simp [append, previous.1], ?_⟩
  intro identity routine found globals inputs
  rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, rfl⟩
  · have apart : identity ≠ environment.signatures.length + 1 := by rw [previous.1, List.length_map]; omega
    simpa [append, apart] using previous.2 identity routine known globals inputs
  · have same : identity = environment.signatures.length + 1 := by simpa [previous.1] using current
    cases kind : definition.signature with
    | function => simpa [append, same, kind] using changesOnly_refl effects.writes globals
    | procedure => simpa [append, same, kind] using definition.execute_changes previous inferred globals inputs

theorem SharedEnvironment.append_localOn {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.LocalOn earlier) {definition : RoutineDefinition} {effects : Effects}
    (inferred : definition.inferEffects earlier = some effects) :
    (environment.append definition).LocalOn (earlier ++ [⟨definition.signature, effects⟩]) := by
  refine ⟨environment.append_respectsEffects previous.footprints inferred, ?_, ?_⟩
  · intro identity routine found first second inputs same
    rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, rfl⟩
    · have apart : identity ≠ environment.signatures.length + 1 := by
        rw [previous.footprints.1, List.length_map]; omega
      simpa [append, apart] using previous.functions identity routine known first second inputs same
    · have current : identity = environment.signatures.length + 1 := by
        simpa [previous.footprints.1] using current
      cases kind : definition.signature with
      | function =>
          simp only [append, current, ↓reduceIte, kind]
          exact congrArg (fun values => values.headD (.integer 0))
            (definition.execute_local previous inferred same inputs).1
      | procedure => simp [append, current, kind]
  · intro identity routine found first second inputs same
    rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, rfl⟩
    · have apart : identity ≠ environment.signatures.length + 1 := by
        rw [previous.footprints.1, List.length_map]; omega
      simpa [append, apart] using previous.procedures identity routine known first second inputs same
    · have current : identity = environment.signatures.length + 1 := by
        simpa [previous.footprints.1] using current
      cases kind : definition.signature with
      | function => simpa [append, current, kind] using And.intro (rfl : ([] : List Value) = []) same
      | procedure => simpa [append, current, kind] using definition.execute_local previous inferred same inputs

structure RoutineLibrary where
  environment : SharedEnvironment
  effects : EffectEnvironment

def RoutineLibrary.empty : RoutineLibrary := ⟨.empty, []⟩

def RoutineLibrary.extend (library : RoutineLibrary) (definition : RoutineDefinition) : Option RoutineLibrary :=
  (definition.inferEffects library.effects).map fun effects =>
    ⟨library.environment.append definition, library.effects ++ [⟨definition.signature, effects⟩]⟩

def buildLibraryFrom : RoutineLibrary → List RoutineDefinition → Option RoutineLibrary
  | library, [] => some library
  | library, definition :: rest => (library.extend definition).bind fun next => buildLibraryFrom next rest

def buildLibrary (definitions : List RoutineDefinition) : Option RoutineLibrary :=
  buildLibraryFrom .empty definitions

theorem buildLibraryFrom_localOn {initial final : RoutineLibrary} {definitions : List RoutineDefinition}
    (valid : initial.environment.LocalOn initial.effects)
    (built : buildLibraryFrom initial definitions = some final) : final.environment.LocalOn final.effects := by
  induction definitions generalizing initial with
  | nil => cases Option.some.inj built; exact valid
  | cons definition rest ih =>
      simp only [buildLibraryFrom, RoutineLibrary.extend, Option.bind_eq_some_iff, Option.map_eq_some_iff] at built
      obtain ⟨next, ⟨effects, inferred, rfl⟩, remaining⟩ := built
      exact ih (initial.environment.append_localOn valid inferred) remaining

theorem buildLibrary_localOn {definitions : List RoutineDefinition} {library : RoutineLibrary}
    (built : buildLibrary definitions = some library) : library.environment.LocalOn library.effects :=
  buildLibraryFrom_localOn SharedEnvironment.empty_localOn built

def schemaBindings (schema : StateSchema) : List InputBinding :=
  schema.map fun declaration => ⟨declaration.cell, declaration.domain⟩

def schemaValues (schema : StateSchema) (frame : Frame) : List Value :=
  schema.map fun declaration => readCell frame declaration.cell

def loadSchema (base : Frame) (schema : StateSchema) (values : List Value) : Frame :=
  bindInputs base (schemaBindings schema) values

def schemaPlan (schema : StateSchema) : List Transfer :=
  schema.map fun declaration => ⟨declaration.cell, declaration.cell⟩

theorem schemaPlan_valid {schema : StateSchema} (valid : schema.Valid) : TransferPlanValid (schemaPlan schema) := by
  refine ⟨?_, ?_⟩
  · simpa [schemaPlan, List.map_map, Function.comp_def] using valid.1
  · intro transfer member
    obtain ⟨declaration, _, rfl⟩ := List.mem_map.mp member
    change SameKind declaration.cell declaration.cell
    cases declaration.cell <;> trivial

theorem loadSchema_values (base original : Frame) (schema : StateSchema) :
    loadSchema base schema (schemaValues schema original) = copyCells original base (schemaPlan schema) := by
  induction schema generalizing base with
  | nil => rfl
  | cons declaration rest ih =>
      simp only [loadSchema, schemaBindings, schemaValues, schemaPlan, List.map_cons, bindInputs, copyCells]
      exact ih _

theorem loadSchema_equal {schema : StateSchema} (valid : schema.Valid) (base original : Frame) :
    EqualOn (schema.map StateDeclaration.cell) original (loadSchema base schema (schemaValues schema original)) := by
  intro cell member
  obtain ⟨declaration, declMem, rfl⟩ := List.mem_map.mp member
  rw [loadSchema_values]
  exact copyCells_value original base (schemaPlan_valid valid) (List.mem_map.mpr ⟨declaration, declMem, rfl⟩)

theorem bindInputs_changes (bindings : List InputBinding) (values : List Value) (base : Frame) :
    ChangesOnly (bindings.map InputBinding.target) base (bindInputs base bindings values) := by
  induction bindings generalizing values base with
  | nil => exact changesOnly_refl _ _
  | cons binding rest ih =>
      cases values with
      | nil => exact changesOnly_refl _ _
      | cons value values => exact changesOnly_sequence (changesOnly_write base binding.target value) (ih values _)

theorem loadSchema_changes (base : Frame) (schema : StateSchema) (values : List Value) :
    ChangesOnly (schema.map StateDeclaration.cell) base (loadSchema base schema values) := by
  simpa [loadSchema, schemaBindings, List.map_map, Function.comp_def] using
    bindInputs_changes (schemaBindings schema) values base

theorem schemaValues_fit {schema : StateSchema} {frame : Frame} (fits : schema.Fits frame) :
    ScalarFunctions.ArgumentsFit (schema.map StateDeclaration.domain) (schemaValues schema frame) := by
  induction schema with
  | nil => trivial
  | cons declaration rest ih =>
      exact ⟨fits declaration (by simp), ih (fun other member => fits other (by simp [member]))⟩

theorem loadSchema_preservesFits {schema captured : StateSchema} {base original : Frame}
    (valid : captured.Valid) (baseFits : schema.Fits base) (originalFits : schema.Fits original) :
    schema.Fits (loadSchema base captured (schemaValues captured original)) := by
  intro declaration member
  by_cases selected : declaration.cell ∈ captured.map StateDeclaration.cell
  · rw [loadSchema_equal valid base original declaration.cell selected]
    exact originalFits declaration member
  · rw [loadSchema_changes base captured (schemaValues captured original) declaration.cell selected]
    exact baseFits declaration member

theorem StateSchema.filter_valid {schema : StateSchema} (valid : schema.Valid)
    (selected : StateDeclaration → Bool) : StateSchema.Valid (schema.filter selected) := by
  refine ⟨?_, ?_⟩
  · exact List.pairwise_map.mpr (List.Pairwise.filter selected (List.pairwise_map.mp valid.1))
  · intro declaration member
    exact valid.2 declaration (List.mem_filter.mp member).1

def Effects.writeSchema (effects : Effects) (schema : StateSchema) : StateSchema :=
  schema.filter fun declaration => effects.writes.contains declaration.cell

def Effects.CoveredBy (effects : Effects) (schema : StateSchema) : Prop :=
  ∀ cell, effects.Captures cell → cell ∈ schema.map StateDeclaration.cell

theorem Effects.captureSchema_cells {effects : Effects} {schema : StateSchema}
    (covered : effects.CoveredBy schema) (cell : Cell) :
    cell ∈ (effects.captureSchema schema).map StateDeclaration.cell ↔ effects.Captures cell := by
  constructor
  · intro member
    obtain ⟨declaration, declMem, rfl⟩ := List.mem_map.mp member
    exact ((effects.mem_captureSchema schema declaration).mp declMem).2
  · intro member
    obtain ⟨declaration, inside, same⟩ := List.mem_map.mp (covered cell member)
    apply List.mem_map.mpr
    refine ⟨declaration, ?_, same⟩
    exact (effects.mem_captureSchema schema declaration).mpr ⟨inside, same.symm ▸ member⟩

theorem Effects.writeSchema_cells {effects : Effects} {schema : StateSchema}
    (covered : effects.CoveredBy schema) (cell : Cell) :
    cell ∈ (effects.writeSchema schema).map StateDeclaration.cell ↔ cell ∈ effects.writes := by
  constructor
  · intro member
    obtain ⟨declaration, declMem, rfl⟩ := List.mem_map.mp member
    exact List.contains_iff_mem.mp (List.mem_filter.mp declMem).2
  · intro member
    obtain ⟨declaration, inside, same⟩ := List.mem_map.mp (covered cell (Or.inr member))
    apply List.mem_map.mpr
    refine ⟨declaration, List.mem_filter.mpr ⟨inside, ?_⟩, same⟩
    exact List.contains_iff_mem.mpr (same.symm ▸ member)

structure CapturedResult where
  writes : List Value
  outputs : List Value

/-- The closed evaluator receives only the explicit input tuple and the
declaration-order R∪W tuple. Its other globals come from canonical elaboration;
read locality proves those unobserved choices irrelevant. No author source is
rewritten or compiled from this semantic representation. -/
def RoutineDefinition.executeClosed (earlier : SharedEnvironment) (definition : RoutineDefinition)
    (schema : StateSchema) (effects : Effects) (inputs captures : List Value) : CapturedResult :=
  let globals := loadSchema (initialState schema) (effects.captureSchema schema) captures
  let result := definition.execute earlier globals inputs
  ⟨schemaValues (effects.writeSchema schema) result.1, result.2⟩

def RoutineDefinition.invokeClosed (earlier : SharedEnvironment) (definition : RoutineDefinition)
    (schema : StateSchema) (effects : Effects) (globals : Frame) (inputs : List Value) : Frame × List Value :=
  let result := definition.executeClosed earlier schema effects inputs
    (schemaValues (effects.captureSchema schema) globals)
  (loadSchema globals (effects.writeSchema schema) result.writes, result.outputs)

theorem capturedEntry_fits {schema : StateSchema} (valid : schema.Valid) (effects : Effects)
    {globals : Frame} (fitting : schema.Fits globals) :
    schema.Fits (loadSchema (initialState schema) (effects.captureSchema schema)
      (schemaValues (effects.captureSchema schema) globals)) :=
  loadSchema_preservesFits (StateSchema.filter_valid valid _) (initialState_fits valid) fitting

theorem RoutineDefinition.invokeClosed_correct {definitions : List RoutineDefinition} {library : RoutineLibrary}
    (built : buildLibrary definitions = some library) {definition : RoutineDefinition} {effects : Effects}
    (inferred : definition.inferEffects library.effects = some effects) {schema : StateSchema}
    (valid : schema.Valid) (covered : effects.CoveredBy schema) (globals : Frame) (inputs : List Value) :
    definition.invokeClosed library.environment schema effects globals inputs =
      definition.execute library.environment globals inputs := by
  have previous := buildLibrary_localOn built
  let captures := effects.captureSchema schema
  let writes := effects.writeSchema schema
  let restored := loadSchema (initialState schema) captures (schemaValues captures globals)
  let closed := definition.execute library.environment restored inputs
  let original := definition.execute library.environment globals inputs
  have captureValid : captures.Valid := StateSchema.filter_valid valid _
  have writeValid : writes.Valid := StateSchema.filter_valid valid _
  have restoredEqual : EqualOn effects.cells globals restored := by
    apply (loadSchema_equal captureValid (initialState schema) globals).mono
    intro cell member
    exact (effects.captureSchema_cells covered cell).mpr ((Effects.mem_cells _ _).mp member)
  have locality := definition.execute_local previous inferred restoredEqual inputs
  have changed := definition.execute_changes previous.footprints inferred globals inputs
  have returned := loadSchema_equal writeValid globals closed.1
  have copyChanged := loadSchema_changes globals writes (schemaValues writes closed.1)
  have state : loadSchema globals writes (schemaValues writes closed.1) = original.1 := by
    apply frame_ext
    intro cell
    by_cases written : cell ∈ effects.writes
    · exact (returned cell ((effects.writeSchema_cells covered cell).mpr written)).trans
        (locality.2 cell ((Effects.mem_cells _ _).mpr (Or.inr written)))
    · have absent : cell ∉ writes.map StateDeclaration.cell :=
        fun member => written ((effects.writeSchema_cells covered cell).mp member)
      exact (copyChanged cell absent).trans (changed cell written).symm
  exact Prod.ext state locality.1

end Silver.Packages
