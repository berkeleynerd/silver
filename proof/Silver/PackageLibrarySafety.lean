module

public import Silver.PackageRoutineSafety

@[expose] public section

/-! Completion-order checking visits every routine, including unused routines.
Earlier callees' typing is proved by the prefix induction, never supplied as
an application admission assumption. The same fold retains effect locality
and discharges each routine's complete inferred obligation list. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ArgumentsFit)

theorem singleton_result_contains {domain : ScalarFunctions.ScalarType} {values : List Value}
    (fits : ArgumentsFit [domain] values) : domain.Contains (values.headD (.integer 0)) := by
  cases values with
  | nil => contradiction
  | cons value rest => exact fits.1

theorem SharedEnvironment.append_typed {schema : StateSchema} {environment : SharedEnvironment}
    {definition : RoutineDefinition} (previous : environment.Typed schema)
    (safe : definition.Safe schema environment) : (environment.append definition).Typed schema where
  functions := by
    intro identity signature found globals globalsFit inputs inputsFit
    rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, equal⟩
    · have apart : identity ≠ environment.signatures.length + 1 := by omega
      simpa only [append, apart, ↓reduceIte] using
        previous.functions identity signature known globals globalsFit inputs inputsFit
    · have kind : definition.signature = .function signature := equal.symm
      have fitting : ArgumentsFit definition.signature.inputTypes inputs := by
        simpa only [kind, RoutineSignature.inputTypes] using inputsFit
      have result := (safe globals globalsFit inputs fitting).2.1
      simp only [kind, RoutineSignature.outputTypes] at result
      simpa only [append, current, ↓reduceIte, kind] using singleton_result_contains result
  procedures := by
    intro identity signature found globals globalsFit inputs inputsFit
    rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, equal⟩
    · have apart : identity ≠ environment.signatures.length + 1 := by omega
      simpa only [append, apart, ↓reduceIte] using
        previous.procedures identity signature known globals globalsFit inputs inputsFit
    · have kind : definition.signature = .procedure signature := equal.symm
      have fitting : ArgumentsFit definition.signature.inputTypes inputs := by
        simpa only [kind, RoutineSignature.inputTypes] using inputsFit
      have result := safe globals globalsFit inputs fitting
      simpa only [append, current, ↓reduceIte, kind, RoutineSignature.outputTypes] using
        And.intro result.1 result.2.1

structure RoutineEntry where
  definition : RoutineDefinition
  context : RoutineContext

def RoutineEntry.Form (schema : StateSchema) (entry : RoutineEntry) : Prop :=
  entry.definition.Form schema entry.context

def RoutineEntry.check (schema : StateSchema) (library : RoutineLibrary)
    (entry : RoutineEntry) : Option RoutineLibrary :=
  (entry.definition.check schema library.effects entry.context).bind fun _ =>
    library.extend entry.definition

theorem RoutineEntry.check_success {schema : StateSchema} {library next : RoutineLibrary}
    {entry : RoutineEntry} (checked : entry.check schema library = some next) :
    ∃ initial after, entry.definition.check schema library.effects entry.context = some (initial, after) ∧
      library.extend entry.definition = some next := by
  simp only [check, Option.bind_eq_some_iff] at checked
  obtain ⟨⟨initial, after⟩, body, extended⟩ := checked
  exact ⟨initial, after, body, extended⟩

def checkLibraryFrom (schema : StateSchema) : RoutineLibrary → List RoutineEntry → Option RoutineLibrary
  | library, [] => some library
  | library, entry :: rest => (entry.check schema library).bind fun next => checkLibraryFrom schema next rest

def checkLibrary (schema : StateSchema) (entries : List RoutineEntry) : Option RoutineLibrary :=
  checkLibraryFrom schema .empty entries

def RoutinesSafeFrom (schema : StateSchema) : RoutineLibrary → List RoutineEntry → Prop
  | _, [] => True
  | library, entry :: rest =>
      entry.definition.Safe schema library.environment ∧
        ∃ next, library.extend entry.definition = some next ∧ RoutinesSafeFrom schema next rest

theorem checkLibraryFrom_build {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List RoutineEntry} (checked : checkLibraryFrom schema initial entries = some final) :
    buildLibraryFrom initial (entries.map RoutineEntry.definition) = some final := by
  induction entries generalizing initial with
  | nil => exact checked
  | cons entry rest ih =>
      simp only [checkLibraryFrom, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      obtain ⟨_, _, _, extended⟩ := entry.check_success first
      simp only [List.map_cons, buildLibraryFrom, extended, Option.bind_some]
      exact ih remaining

theorem checkLibraryFrom_sound {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List RoutineEntry} (valid : schema.Valid)
    (forms : ∀ entry ∈ entries, entry.Form schema)
    (typed : initial.environment.Typed schema) (effects : initial.environment.RespectsEffects initial.effects)
    (checked : checkLibraryFrom schema initial entries = some final) :
    final.environment.Typed schema ∧ RoutinesSafeFrom schema initial entries := by
  induction entries generalizing initial with
  | nil => cases Option.some.inj checked; exact ⟨typed, trivial⟩
  | cons entry rest ih =>
      simp only [checkLibraryFrom, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      obtain ⟨ranges, after, body, extended⟩ := entry.check_success first
      have safe := entry.definition.execution_sound effects typed valid (forms entry (by simp)) body
      obtain ⟨writes, inferred, rfl⟩ := Option.map_eq_some_iff.mp extended
      have nextTyped := initial.environment.append_typed typed safe
      have nextEffects := initial.environment.append_respectsEffects effects inferred
      have tail := ih (fun item member => forms item (by simp [member])) nextTyped nextEffects remaining
      exact ⟨tail.1, safe, _, extended, tail.2⟩

def libraryObligationsFrom (schema : StateSchema) : RoutineLibrary → List RoutineEntry → List Predicate.Obligation
  | _, [] => []
  | library, entry :: rest =>
      entry.definition.obligations schema library.effects entry.context ++
        match entry.check schema library with
        | none => [.impossible]
        | some next => libraryObligationsFrom schema next rest

theorem checkLibraryFrom_obligations_discharge {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List RoutineEntry} (checked : checkLibraryFrom schema initial entries = some final) :
    Predicate.discharged (libraryObligationsFrom schema initial entries) = true := by
  induction entries generalizing initial with
  | nil => rfl
  | cons entry rest ih =>
      simp only [checkLibraryFrom, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      obtain ⟨_, _, body, _⟩ := entry.check_success first
      simp only [libraryObligationsFrom, first, Predicate.discharged_append,
        entry.definition.obligations_discharge body, Bool.true_and]
      exact ih remaining

theorem checkLibrary_sound {schema : StateSchema} {entries : List RoutineEntry} {library : RoutineLibrary}
    (valid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (checked : checkLibrary schema entries = some library) :
    library.environment.Typed schema ∧ library.environment.LocalOn library.effects ∧
      RoutinesSafeFrom schema .empty entries ∧
      Predicate.discharged (libraryObligationsFrom schema .empty entries) = true ∧
      buildLibrary (entries.map RoutineEntry.definition) = some library := by
  have built := checkLibraryFrom_build checked
  have sound := checkLibraryFrom_sound valid forms (SharedEnvironment.empty_typed schema)
    SharedEnvironment.empty_respectsEffects checked
  exact ⟨sound.1, buildLibrary_localOn built, sound.2,
    checkLibraryFrom_obligations_discharge checked, built⟩

end Silver.Packages
