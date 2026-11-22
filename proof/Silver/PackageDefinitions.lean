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

end Silver.Packages
