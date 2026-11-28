module

public import Silver.ApplicationPackageRoutineSourceChecking
public import Silver.PackageSummaryLibrarySafety

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationPackageDeclarations

/-- The footer records effects and source locations without changing the
routine's original callable interface or formal domains. -/
theorem CompletionFrames.result_signature {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (pending : info.completed < info.routines.length) (present : result.globals.position ≠ 0) :
    (result.info.routineAt result.info.completed).signature result.info =
      (frames.signature.info.routineAt (info.completed + 1)).signature frames.signature.info := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  have within : info.completed + 1 ≤ frames.signature.info.routines.length := by
    rw [tables.lengths.2]
    omega
  have selected := (read.stored_item (by omega) within).2.2
  rw [selected, read.stored]
  rfl

end Silver.ApplicationPackageBodies

namespace Silver.ApplicationPackageRoutineSources
open Compose Packages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageBodies.Recursive

def RoutineCode.summaryEntry {reader calls text globals info result readers}
    {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (source : RoutineCode frames readers) (specRows : List ApplicationPackageInitializers.SpecificationItem) :
    SummaryRoutineEntry :=
  ⟨source.entry specRows, (result.info.routineAt result.info.completed).effects result.info⟩

theorem RoutineCode.summary_original {reader calls text readers specRows} {row : RoutineRead}
    {frames : CompletionFrames (declarationReaders reader calls) text row.before.globals row.before.info row.result}
    (source : RoutineCode frames readers)
    (pending : row.before.info.completed < row.before.info.routines.length)
    (present : row.result.globals.position ≠ 0) :
    (source.summaryEntry specRows).summary = row.effectEntry := by
  have signature := frames.result_signature pending present
  change Packages.RoutineEffects.mk _ _ = Packages.RoutineEffects.mk _ _
  exact congrArg (fun signature => Packages.RoutineEffects.mk signature
    ((row.result.info.routineAt row.result.info.completed).effects row.result.info)) signature.symm

/-- Every semantic entry is selected by an original accepted routine frame
and source-only code. No Form, checker, discharge or safety fact is stored in
this source relation. The list includes every original completion ordinal. -/
inductive RoutineEntriesAt (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (readers : Readers) (specRows : List ApplicationPackageInitializers.SpecificationItem) :
    List RoutineRead → List SummaryRoutineEntry → Prop
  | nil : RoutineEntriesAt reader calls text readers specRows [] []
  | cons {row : RoutineRead} {rows : List RoutineRead} {entries : List SummaryRoutineEntry}
      (frames : CompletionFrames (declarationReaders reader calls) text row.before.globals row.before.info row.result)
      (code : RoutineCode frames readers)
      (pending : row.before.info.completed < row.before.info.routines.length)
      (present : row.result.globals.position ≠ 0)
      (rest : RoutineEntriesAt reader calls text readers specRows rows entries) :
      RoutineEntriesAt reader calls text readers specRows (row :: rows) (code.summaryEntry specRows :: entries)

theorem RoutineEntriesAt.summaries {reader calls text readers specRows rows entries}
    (source : RoutineEntriesAt reader calls text readers specRows rows entries) :
    entries.map SummaryRoutineEntry.summary = rows.map RoutineRead.effectEntry := by
  induction source with
  | nil => rfl
  | cons frames code pending present rest ih =>
    simp only [List.map_cons, code.summary_original pending present, ih]

theorem RoutineEntriesAt.length {reader calls text readers specRows rows entries}
    (source : RoutineEntriesAt reader calls text readers specRows rows entries) : entries.length = rows.length := by
  have lengths := congrArg List.length source.summaries
  simpa only [List.length_map] using lengths

/-- Original history gives the native callable prefix at each source ordinal;
the constructed semantic prefix has precisely that same summary table. -/
theorem RoutineEntriesAt.prefix_effects {reader calls text readers specRows before rows result entries}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (source : RoutineEntriesAt reader calls text readers specRows rows entries)
    (initial : RoutineLibrary) (prior : initial.effects = ApplicationPackageCalls.completedEnvironment before.info)
    {offset : Nat} {row : RoutineRead} (found : rows[offset]? = some row) :
    (buildSummaryLibraryFrom initial (entries.take offset)).effects =
      ApplicationPackageCalls.completedEnvironment row.before.info := by
  rw [buildSummaryLibraryFrom_effects, prior, List.map_take, source.summaries, ← List.map_take]
  exact ((history.environments).2 offset row found).symm

theorem RoutineEntriesAt.final_effects {reader calls text readers specRows before rows result entries}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (source : RoutineEntriesAt reader calls text readers specRows rows entries)
    (initial : RoutineLibrary) (prior : initial.effects = ApplicationPackageCalls.completedEnvironment before.info) :
    (buildSummaryLibraryFrom initial entries).effects = ApplicationPackageCalls.completedEnvironment result.info := by
  rw [buildSummaryLibraryFrom_effects, prior, source.summaries]
  exact history.environments.1.symm

end Silver.ApplicationPackageRoutineSources
