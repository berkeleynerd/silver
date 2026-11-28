module

public import Silver.ApplicationPackageRoutineHistoryFacts

@[expose] public section

namespace Silver.ApplicationPackageRoutineSources
open Compose Compose.Expressions Predicate Packages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageRoutineResults
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax

theorem state_schema_equal {before after : PackageBindings.Metadata} (same : before.states = after.states) :
    before.stateSchema = after.stateSchema := by
  simp only [PackageBindings.Metadata.stateSchema, PackageBindings.Metadata.stateAt, same]

/-- A derived checker fact at one original native prefix. It is kept separate
from RoutineEntriesAt, whose fields contain source syntax/history only. -/
def EntryCheckedAt (schema : StateSchema) (row : RoutineRead) (entry : SummaryRoutineEntry) : Prop :=
  entry.Form schema ∧ ∃ initialized after,
    entry.routine.definition.checkPhased schema (ApplicationPackageCalls.completedEnvironment row.before.info)
      entry.routine.context entry.routine.phases = some (initialized, after)

inductive EntriesRelated (relation : RoutineRead → SummaryRoutineEntry → Prop) :
    List RoutineRead → List SummaryRoutineEntry → Prop
  | nil : EntriesRelated relation [] []
  | cons {row rows entry entries} (first : relation row entry) (rest : EntriesRelated relation rows entries) :
      EntriesRelated relation (row :: rows) (entry :: entries)

theorem entry_checked_forms {schema rows entries}
    (checked : EntriesRelated (EntryCheckedAt schema) rows entries) :
    ∀ entry ∈ entries, entry.Form schema := by
  induction checked with
  | nil => simp
  | @cons row rows entry entries first rest ih =>
    intro seen member
    rcases List.mem_cons.mp member with rfl | later
    · exact first.1
    · exact ih seen later

/-- Every original completion, including unused routines, constructs its
source-only semantic entry and its complete phased checker. Native interface
and frame facts are propagated through original completion history. Function
write restrictions come from the final metadata's literal completed prefixes. -/
theorem original_entries {reader : BooleanElaboration.Native.Reader}
    {specText : Source} {specStart specEnd : SpecificationState} {specRows : List SpecificationItem}
    (specified : SpecificationInventories reader specText specStart specRows (.ready specEnd))
    (specValid : ValidText specText) (specFrame : ReaderFrame specText specStart.exports)
    (specOrder : ApplicationPackageObjectRows.FrameOrder specStart.exports)
    (specEmpty : specStart.exports.scalarNames = [])
    {calls : CompletionCalls} {text : Source} {before : UnitState} {rows : List RoutineRead}
    {result : ApplicationAdmission.BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (textValid : ValidText text)
    (known : RoutineFrameFacts specText specEnd.exports.scalarNames text before.globals before.info)
    (typing : ∀ (globals : ParserState) (info : PackageBindings.Metadata), ReaderFrame text globals → info.Typed →
      (readCompletion reader calls text globals info).info.Typed)
    {finalText : PackageBindings.Text} (complete : PackageBindings.completeMetadata finalText result.info = true)
    {readers : Readers} (equations : Equations (sourceReaders readers) NativeDomain)
    (tail : calls.applicationTail = (sourceReaders readers).statement.applicationTail)
    (actual : calls.actualAfter = Predicate.actualAfter)
    (flow : calls.initialFlow = fun context => ActiveFlow.initial context.scalarNames (initialFacts context.hasArguments))
    (returned : calls.functionReturnAfter = functionReturnAfter) :
    ∃ entries, RoutineEntriesAt reader calls text readers specRows rows entries ∧
      EntriesRelated (EntryCheckedAt before.info.stateSchema) rows entries := by
  let Ready (row : RoutineRead) : Prop :=
    ∃ frames : CompletionFrames (declarationReaders reader calls) text row.before.globals row.before.info row.result,
      ∃ code : RoutineCode frames readers,
        row.before.info.completed < row.before.info.routines.length ∧ row.result.globals.position ≠ 0 ∧
          EntryCheckedAt before.info.stateSchema row (code.summaryEntry specRows)
  have frameFacts := history_frame_facts history known typing
  have states := history.source_layouts known.initial known.framed.typed.scalarCount
  have finalWrites := completed_function_writes complete
  have ready : ∀ row ∈ rows, Ready row := by
    intro row member
    obtain ⟨read, pending, advanced⟩ := history.readings row member
    have present : row.result.globals.position ≠ 0 := by omega
    obtain ⟨frames⟩ := RoutineRead.frames read present
    have facts := (frameFacts row member).1
    obtain ⟨available, prefixRows⟩ := history.completed_prefixes row member
    have writes := finalWrites.of_prefix available prefixRows
    have notOuter := completion_formals_nonouter frames facts.initial facts.exports
    obtain ⟨code, formed, initialized, after, checked⟩ :=
      original_routine specified specValid specFrame specOrder specEmpty frames textValid facts.framed facts.typed
        facts.tables facts.initial facts.origin facts.separated facts.declarations facts.clear facts.bounds
        facts.declared writes facts.interfaces notOuter pending present equations tail actual flow returned
    have signed : readSignature text row.before.globals row.before.info true = frames.signature := frames.signed
    have same : frames.signature.info.states = before.info.states :=
      (signed ▸ readSignature_states text row.before.globals row.before.info true).trans (states.2 row member).1
    have schema := state_schema_equal same
    refine ⟨frames, code, pending, present, ?_⟩
    change (code.entry specRows).Form before.info.stateSchema ∧
      ∃ initialized after, (code.definition specRows).checkPhased before.info.stateSchema
        (ApplicationPackageCalls.completedEnvironment row.before.info) code.context (code.phases specRows) =
          some (initialized, after)
    rw [← schema]
    exact ⟨formed, initialized, after, checked⟩
  have assemble : ∀ items : List RoutineRead, (∀ row ∈ items, Ready row) →
      ∃ entries, RoutineEntriesAt reader calls text readers specRows items entries ∧
        EntriesRelated (EntryCheckedAt before.info.stateSchema) items entries := by
    intro items
    induction items with
    | nil => intro _; exact ⟨[], .nil, .nil⟩
    | cons row rest ih =>
      intro ready
      obtain ⟨frames, code, pending, present, checked⟩ := ready row List.mem_cons_self
      obtain ⟨entries, originals, checks⟩ := ih (fun seen member => ready seen (List.mem_cons_of_mem _ member))
      exact ⟨code.summaryEntry specRows :: entries,
        .cons frames code pending present originals, .cons checked checks⟩
  exact assemble rows ready

end Silver.ApplicationPackageRoutineSources
