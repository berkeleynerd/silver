module

public import Silver.PackagePhasedLibrarySafety
public import Silver.PackageEffectSummaries

@[expose] public section

/-! Original native summaries remain attached to their declaration-order
identities. Each routine checks its complete original initialization phases,
body and results; effect inference is checked for membership inclusion in the
native summary before the executable environment is extended. -/
namespace Silver.Packages
open EffectSummaries

def effectsIncluded (inferred summary : Effects) : Bool :=
  inferred.reads.all (fun cell => decide (cell ∈ summary.reads)) &&
    inferred.writes.all (fun cell => decide (cell ∈ summary.writes))

theorem effectsIncluded_iff {inferred summary : Effects} :
    effectsIncluded inferred summary = true ↔ Included inferred summary := by
  simp only [effectsIncluded, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq]
  exact ⟨fun covered => ⟨covered.1, covered.2⟩, fun covered => ⟨covered.reads, covered.writes⟩⟩

structure SummaryRoutineEntry where
  routine : PhasedRoutineEntry
  effects : Effects

def SummaryRoutineEntry.summary (entry : SummaryRoutineEntry) : RoutineEffects :=
  ⟨entry.routine.definition.signature, entry.effects⟩

def SummaryRoutineEntry.Form (schema : StateSchema) (entry : SummaryRoutineEntry) : Prop :=
  entry.routine.Form schema

def SummaryRoutineEntry.extend (entry : SummaryRoutineEntry) (library : RoutineLibrary) : RoutineLibrary :=
  ⟨library.environment.append entry.routine.definition, library.effects ++ [entry.summary]⟩

def SummaryRoutineEntry.check (schema : StateSchema) (library : RoutineLibrary)
    (entry : SummaryRoutineEntry) : Option RoutineLibrary :=
  (entry.routine.definition.checkPhased schema library.effects entry.routine.context entry.routine.phases).bind fun _ =>
    (entry.routine.definition.inferEffects library.effects).bind fun inferred =>
      if effectsIncluded inferred entry.effects then some (entry.extend library) else none

theorem SummaryRoutineEntry.check_success {schema : StateSchema} {library next : RoutineLibrary}
    {entry : SummaryRoutineEntry} (checked : entry.check schema library = some next) :
    ∃ initial after inferred,
      entry.routine.definition.checkPhased schema library.effects entry.routine.context entry.routine.phases =
        some (initial, after) ∧
      entry.routine.definition.inferEffects library.effects = some inferred ∧
      Included inferred entry.effects ∧ next = entry.extend library := by
  simp only [check, Option.bind_eq_some_iff] at checked
  obtain ⟨⟨initial, after⟩, body, inferred, effects, result⟩ := checked
  split at result
  · rename_i included
    exact ⟨initial, after, inferred, body, effects, effectsIncluded_iff.mp included, (Option.some.inj result).symm⟩
  · contradiction

theorem SummaryRoutineEntry.checked {schema : StateSchema} {library : RoutineLibrary}
    {entry : SummaryRoutineEntry} {initial : InitializedRanges} {after : Predicate.Flow} {inferred : Effects}
    (body : entry.routine.definition.checkPhased schema library.effects entry.routine.context entry.routine.phases =
      some (initial, after))
    (effects : entry.routine.definition.inferEffects library.effects = some inferred)
    (included : Included inferred entry.effects) : entry.check schema library = some (entry.extend library) := by
  simp only [check, body, effects, Option.bind_some, effectsIncluded_iff.mpr included, ite_true]

def checkSummaryLibraryFrom (schema : StateSchema) : RoutineLibrary → List SummaryRoutineEntry → Option RoutineLibrary
  | library, [] => some library
  | library, entry :: rest => (entry.check schema library).bind fun next => checkSummaryLibraryFrom schema next rest

def checkSummaryLibrary (schema : StateSchema) (entries : List SummaryRoutineEntry) : Option RoutineLibrary :=
  checkSummaryLibraryFrom schema .empty entries

def buildSummaryLibraryFrom : RoutineLibrary → List SummaryRoutineEntry → RoutineLibrary
  | library, [] => library
  | library, entry :: rest => buildSummaryLibraryFrom (entry.extend library) rest

def buildSummaryLibrary (entries : List SummaryRoutineEntry) : RoutineLibrary :=
  buildSummaryLibraryFrom .empty entries

def SummaryRoutinesSafeFrom (schema : StateSchema) : RoutineLibrary → List SummaryRoutineEntry → Prop
  | _, [] => True
  | library, entry :: rest =>
      entry.routine.definition.Safe schema library.environment ∧
        SummaryRoutinesSafeFrom schema (entry.extend library) rest

theorem checkSummaryLibraryFrom_build {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List SummaryRoutineEntry} (checked : checkSummaryLibraryFrom schema initial entries = some final) :
    final = buildSummaryLibraryFrom initial entries := by
  induction entries generalizing initial with
  | nil => exact (Option.some.inj checked).symm
  | cons entry rest ih =>
    simp only [checkSummaryLibraryFrom, Option.bind_eq_some_iff] at checked
    obtain ⟨next, first, remaining⟩ := checked
    obtain ⟨_, _, _, _, _, _, rfl⟩ := entry.check_success first
    exact ih remaining

theorem buildSummaryLibraryFrom_effects (initial : RoutineLibrary) (entries : List SummaryRoutineEntry) :
    (buildSummaryLibraryFrom initial entries).effects = initial.effects ++ entries.map SummaryRoutineEntry.summary := by
  induction entries generalizing initial with
  | nil => simp only [buildSummaryLibraryFrom, List.map_nil, List.append_nil]
  | cons entry rest ih =>
    simp only [buildSummaryLibraryFrom, ih, SummaryRoutineEntry.extend, List.map_cons,
      List.append_assoc, List.singleton_append]

theorem checkSummaryLibraryFrom_sound {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List SummaryRoutineEntry} (valid : schema.Valid)
    (forms : ∀ entry ∈ entries, entry.Form schema)
    (typed : initial.environment.Typed schema) (locality : initial.environment.LocalOn initial.effects)
    (checked : checkSummaryLibraryFrom schema initial entries = some final) :
    final.environment.Typed schema ∧ final.environment.LocalOn final.effects ∧
      SummaryRoutinesSafeFrom schema initial entries := by
  induction entries generalizing initial with
  | nil => cases Option.some.inj checked; exact ⟨typed, locality, trivial⟩
  | cons entry rest ih =>
    simp only [checkSummaryLibraryFrom, Option.bind_eq_some_iff] at checked
    obtain ⟨next, first, remaining⟩ := checked
    obtain ⟨ranges, after, inferred, body, effects, included, rfl⟩ := entry.check_success first
    have form := forms entry List.mem_cons_self
    have safe := entry.routine.definition.phased_execution_sound locality.footprints typed valid
      form.1 form.2 body
    have nextTyped := initial.environment.append_typed typed safe
    have nextLocal := append_local_summary locality effects included
    obtain ⟨finalTyped, finalLocal, restSafe⟩ := ih
      (fun seen member => forms seen (List.mem_cons_of_mem _ member)) nextTyped nextLocal remaining
    exact ⟨finalTyped, finalLocal, safe, restSafe⟩

def summaryLibraryObligationsFrom (schema : StateSchema) : RoutineLibrary → List SummaryRoutineEntry → List Predicate.Obligation
  | _, [] => []
  | library, entry :: rest =>
      entry.routine.definition.phasedObligations schema library.effects entry.routine.context entry.routine.phases ++
        match entry.check schema library with
        | none => [.impossible]
        | some next => summaryLibraryObligationsFrom schema next rest

theorem checkSummaryLibraryFrom_obligations_discharge {schema : StateSchema} {initial final : RoutineLibrary}
    {entries : List SummaryRoutineEntry} (checked : checkSummaryLibraryFrom schema initial entries = some final) :
    Predicate.discharged (summaryLibraryObligationsFrom schema initial entries) = true := by
  induction entries generalizing initial with
  | nil => rfl
  | cons entry rest ih =>
    simp only [checkSummaryLibraryFrom, Option.bind_eq_some_iff] at checked
    obtain ⟨next, first, remaining⟩ := checked
    obtain ⟨_, _, _, body, _, _, _⟩ := entry.check_success first
    simp only [summaryLibraryObligationsFrom, first, Predicate.discharged_append,
      entry.routine.definition.phased_obligations_discharge body, Bool.true_and]
    exact ih remaining

theorem checkSummaryLibrary_sound {schema : StateSchema} {entries : List SummaryRoutineEntry} {library : RoutineLibrary}
    (valid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (checked : checkSummaryLibrary schema entries = some library) :
    library.environment.Typed schema ∧ library.environment.LocalOn library.effects ∧
      SummaryRoutinesSafeFrom schema .empty entries ∧
      Predicate.discharged (summaryLibraryObligationsFrom schema .empty entries) = true ∧
      library.effects = entries.map SummaryRoutineEntry.summary ∧
      library = buildSummaryLibrary entries := by
  have built := checkSummaryLibraryFrom_build checked
  have sound := checkSummaryLibraryFrom_sound valid forms (SharedEnvironment.empty_typed schema)
    SharedEnvironment.empty_localOn checked
  refine ⟨sound.1, sound.2.1, sound.2.2, checkSummaryLibraryFrom_obligations_discharge checked, ?_, built⟩
  rw [built, buildSummaryLibraryFrom_effects]
  rfl

end Silver.Packages
