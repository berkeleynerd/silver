module

public import Silver.PackagePhasedRoutineSafety
public import Silver.PackageLibrarySafety

@[expose] public section

/-! The completion-order library consumer for original native initialization
phases. It executes the same definitions and effect fold as the ordinary library;
only its analysis stages follow the source-derived local/output boundaries. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ArgumentsFit)

structure PhasedRoutineEntry where
  definition : RoutineDefinition
  context : RoutineContext
  phases : InitializerPhases

def PhasedRoutineEntry.Form (schema : StateSchema) (entry : PhasedRoutineEntry) : Prop :=
  entry.definition.Form schema entry.context ∧ entry.phases.items = entry.definition.initializers

def PhasedRoutineEntry.check (schema : StateSchema) (library : RoutineLibrary)
    (entry : PhasedRoutineEntry) : Option RoutineLibrary :=
  (entry.definition.checkPhased schema library.effects entry.context entry.phases).bind fun _ =>
    library.extend entry.definition

theorem PhasedRoutineEntry.check_success {schema : StateSchema} {library next : RoutineLibrary}
    {entry : PhasedRoutineEntry} (checked : entry.check schema library = some next) :
    ∃ initial after, entry.definition.checkPhased schema library.effects entry.context entry.phases = some (initial, after) ∧
      library.extend entry.definition = some next := by
  simp only [check, Option.bind_eq_some_iff] at checked
  obtain ⟨⟨initial, after⟩, body, extended⟩ := checked
  exact ⟨initial, after, body, extended⟩

def checkPhasedLibraryFrom (schema : StateSchema) : RoutineLibrary → List PhasedRoutineEntry → Option RoutineLibrary
  | library, [] => some library
  | library, entry :: rest => (entry.check schema library).bind fun next => checkPhasedLibraryFrom schema next rest

def checkPhasedLibrary (schema : StateSchema) (entries : List PhasedRoutineEntry) : Option RoutineLibrary :=
  checkPhasedLibraryFrom schema .empty entries

def PhasedRoutinesSafeFrom (schema : StateSchema) : RoutineLibrary → List PhasedRoutineEntry → Prop
  | _, [] => True
  | library, entry :: rest =>
      entry.definition.Safe schema library.environment ∧
        ∃ next, library.extend entry.definition = some next ∧ PhasedRoutinesSafeFrom schema next rest

theorem checkPhasedLibraryFrom_build {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List PhasedRoutineEntry} (checked : checkPhasedLibraryFrom schema initial entries = some final) :
    buildLibraryFrom initial (entries.map PhasedRoutineEntry.definition) = some final := by
  induction entries generalizing initial with
  | nil => exact checked
  | cons entry rest ih =>
      simp only [checkPhasedLibraryFrom, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      obtain ⟨_, _, _, extended⟩ := entry.check_success first
      simp only [List.map_cons, buildLibraryFrom, extended, Option.bind_some]
      exact ih remaining

theorem checkPhasedLibraryFrom_sound {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List PhasedRoutineEntry} (valid : schema.Valid)
    (forms : ∀ entry ∈ entries, entry.Form schema)
    (typed : initial.environment.Typed schema) (effects : initial.environment.RespectsEffects initial.effects)
    (checked : checkPhasedLibraryFrom schema initial entries = some final) :
    final.environment.Typed schema ∧ PhasedRoutinesSafeFrom schema initial entries := by
  induction entries generalizing initial with
  | nil => cases Option.some.inj checked; exact ⟨typed, trivial⟩
  | cons entry rest ih =>
      simp only [checkPhasedLibraryFrom, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      obtain ⟨ranges, after, body, extended⟩ := entry.check_success first
      have safe := entry.definition.phased_execution_sound effects typed valid (forms entry (by simp)).1
        (forms entry (by simp)).2 body
      obtain ⟨writes, inferred, rfl⟩ := Option.map_eq_some_iff.mp extended
      have nextTyped := initial.environment.append_typed typed safe
      have nextEffects := initial.environment.append_respectsEffects effects inferred
      have tail := ih (fun item member => forms item (by simp [member])) nextTyped nextEffects remaining
      exact ⟨tail.1, safe, _, extended, tail.2⟩

def phasedLibraryObligationsFrom (schema : StateSchema) : RoutineLibrary → List PhasedRoutineEntry → List Predicate.Obligation
  | _, [] => []
  | library, entry :: rest =>
      entry.definition.phasedObligations schema library.effects entry.context entry.phases ++
        match entry.check schema library with
        | none => [.impossible]
        | some next => phasedLibraryObligationsFrom schema next rest

theorem checkPhasedLibraryFrom_obligations_discharge {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List PhasedRoutineEntry} (checked : checkPhasedLibraryFrom schema initial entries = some final) :
    Predicate.discharged (phasedLibraryObligationsFrom schema initial entries) = true := by
  induction entries generalizing initial with
  | nil => rfl
  | cons entry rest ih =>
      simp only [checkPhasedLibraryFrom, Option.bind_eq_some_iff] at checked
      obtain ⟨next, first, remaining⟩ := checked
      obtain ⟨_, _, body, _⟩ := entry.check_success first
      simp only [phasedLibraryObligationsFrom, first, Predicate.discharged_append,
        entry.definition.phased_obligations_discharge body, Bool.true_and]
      exact ih remaining

theorem checkPhasedLibrary_sound {schema : StateSchema} {entries : List PhasedRoutineEntry} {library : RoutineLibrary}
    (valid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (checked : checkPhasedLibrary schema entries = some library) :
    library.environment.Typed schema ∧ library.environment.LocalOn library.effects ∧
      PhasedRoutinesSafeFrom schema .empty entries ∧
      Predicate.discharged (phasedLibraryObligationsFrom schema .empty entries) = true ∧
      buildLibrary (entries.map PhasedRoutineEntry.definition) = some library := by
  have built := checkPhasedLibraryFrom_build checked
  have sound := checkPhasedLibraryFrom_sound valid forms (SharedEnvironment.empty_typed schema)
    SharedEnvironment.empty_respectsEffects checked
  exact ⟨sound.1, buildLibrary_localOn built, sound.2,
    checkPhasedLibraryFrom_obligations_discharge checked, built⟩

end Silver.Packages
