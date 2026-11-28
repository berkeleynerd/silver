module

public import Silver.ApplicationPackageRoutineSourceEntries

@[expose] public section

namespace Silver.ApplicationPackageRoutineSources
open Compose Packages ApplicationPackageBodies ApplicationPackageBodies.Recursive
open EffectSummaries
open ApplicationPackageCalls (completedEnvironment)

/-- The effect result derived from each original source routine. This is a
separate theorem conclusion; RoutineEntriesAt remains source syntax/history. -/
def EntryEffectsAt (row : RoutineRead) (entry : SummaryRoutineEntry) : Prop :=
  ∃ inferred, entry.routine.definition.inferEffects (completedEnvironment row.before.info) = some inferred ∧
    Included inferred entry.effects

theorem next_environment {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {row : RoutineRead} {later : List RoutineRead} {result : ApplicationAdmission.BodyResult}
    (phase : row.before.phase = .routines)
    (pending : row.before.info.completed < row.before.info.routines.length)
    (read : (bodyReaders reader calls).completionAt text row.before.globals row.before.info = row.result)
    (advanced : row.before.globals.position < row.result.globals.position)
    (rest : RoutineHistory (bodyReaders reader calls) text row.after later result) :
    completedEnvironment row.result.info = completedEnvironment row.before.info ++ [row.effectEntry] := by
  have all : RoutineHistory (bodyReaders reader calls) text row.before (row :: later) result :=
    .added phase pending read advanced rest
  have joined : completedEnvironment row.result.info ++ later.map RoutineRead.effectEntry =
      (completedEnvironment row.before.info ++ [row.effectEntry]) ++ later.map RoutineRead.effectEntry := by
    calc
      _ = completedEnvironment result.info := rest.environments.1.symm
      _ = completedEnvironment row.before.info ++ (row :: later).map RoutineRead.effectEntry := all.environments.1
      _ = _ := by simp only [List.map_cons, List.append_assoc, List.singleton_append]
  exact List.append_cancel_right joined

/-- Compose the independently derived complete routine checks and source
effect inclusions at the exact prefixes supplied by original completion order.
The executable environment is built by the checked summary-library consumer. -/
theorem checked_source_library_from {reader calls text readers specRows before rows result entries schema}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (sources : RoutineEntriesAt reader calls text readers specRows rows entries)
    (phases : EntriesRelated (EntryCheckedAt schema) rows entries)
    (effects : EntriesRelated EntryEffectsAt rows entries)
    (initial : RoutineLibrary) (prior : initial.effects = completedEnvironment before.info) :
    checkSummaryLibraryFrom schema initial entries = some (buildSummaryLibraryFrom initial entries) := by
  induction history generalizing entries initial with
  | finished =>
    cases sources
    rfl
  | @added row later result phase pending read advanced rest ih =>
    cases sources with
    | cons frames code sourcePending present originals =>
      cases phases with
      | cons first remaining =>
        cases effects with
        | cons footprint footprints =>
          obtain ⟨ranges, after, body⟩ := first.2
          obtain ⟨inferred, inferredAt, included⟩ := footprint
          rw [← prior] at body inferredAt
          have checked := SummaryRoutineEntry.checked body inferredAt included
          have next : ((code.summaryEntry specRows).extend initial).effects = completedEnvironment row.result.info := by
            change initial.effects ++ [(code.summaryEntry specRows).summary] = _
            rw [prior, code.summary_original sourcePending present]
            exact (next_environment phase pending read advanced rest).symm
          simp only [checkSummaryLibraryFrom, checked, Option.bind_some, buildSummaryLibraryFrom]
          exact ih originals remaining footprints _ next

theorem checked_source_library {reader calls text readers specRows before rows result entries schema}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (sources : RoutineEntriesAt reader calls text readers specRows rows entries)
    (phases : EntriesRelated (EntryCheckedAt schema) rows entries)
    (effects : EntriesRelated EntryEffectsAt rows entries)
    (empty : before.info.completed = 0) :
    checkSummaryLibrary schema entries = some (buildSummaryLibrary entries) ∧
      (buildSummaryLibrary entries).effects = completedEnvironment result.info ∧
      (∀ entry ∈ entries, entry.Form schema) := by
  have prior : RoutineLibrary.empty.effects = completedEnvironment before.info := by
    simp only [RoutineLibrary.empty, completedEnvironment, empty, List.take_zero, List.map_nil]
  exact ⟨checked_source_library_from history sources phases effects .empty prior,
    sources.final_effects history .empty prior, entry_checked_forms phases⟩

end Silver.ApplicationPackageRoutineSources
