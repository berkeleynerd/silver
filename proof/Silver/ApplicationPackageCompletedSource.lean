module

public import Silver.ApplicationPackageSourceFormalModes
public import Silver.ApplicationPackageReturnReading

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationPackageDeclarations
open ApplicationAdmission (BodyResult ParsedPackage)

/-- Every retained row came from the actual completion call at that row's
incoming cursor, with an active declared routine and strict source progress. -/
theorem RoutineHistory.readings {calls : UnitCalls} {text : Source} {before : UnitState}
    {rows : List RoutineRead} {result : BodyResult} (history : RoutineHistory calls text before rows result) :
    ∀ row ∈ rows, calls.completionAt text row.before.globals row.before.info = row.result ∧
      row.before.info.completed < row.before.info.routines.length ∧
      row.before.globals.position < row.result.globals.position := by
  induction history with
  | finished => simp
  | @added row later result phase pending read advanced rest ih =>
    intro seen member
    rcases List.mem_cons.mp member with rfl | following
    · exact ⟨read, pending, advanced⟩
    · exact ih seen following

private theorem declared_routine_at {before after : Metadata}
    (declared : after.routines.map routineDeclaration = before.routines.map routineDeclaration) (index : Nat) :
    routineDeclaration (after.routineAt index) = routineDeclaration (before.routineAt index) := by
  have project (rows : List Routine) : routineDeclaration (rows.getD (index - 1) {}) =
      (rows.map routineDeclaration).getD (index - 1) (routineDeclaration {}) := by
    simp only [List.getD_eq_getElem?_getD, List.getElem?_map]
    cases rows[index - 1]? <;> rfl
  simp only [Metadata.routineAt, project, declared]

theorem CompletionFrames.selected_declaration {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) :
    routineDeclaration (frames.signature.info.routineAt (info.completed + 1)) =
      routineDeclaration (info.routineAt (info.completed + 1)) := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  exact declared_routine_at tables.routineDeclarations _

/-- The accepted footer writes this routine's complete result at the original
one-based ordinal. Its read/write sets are the actual returned scan's sets. -/
theorem CompletionBodyRead.stored_item {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : Metadata} {index : Nat} {item : Routine} {state : InitializationFrame} {result : CompletionResult}
    (read : CompletionBodyRead calls text globals info index item state result)
    (positive : 0 < index) (inside : index ≤ info.routines.length) :
    result.info.completed = index ∧
      result.info.routines[index - 1]? = some (finishedItem item (footerAfter calls text read.returned) read.returned) ∧
      result.info.routineAt result.info.completed = finishedItem item (footerAfter calls text read.returned) read.returned := by
  have bounded : index - 1 < info.routines.length := by omega
  rw [read.stored]
  exact ⟨rfl, List.getElem?_set_self bounded, by
    simp only [finishedInfo, Metadata.routineAt, List.getD_eq_getElem?_getD,
      List.getElem?_set_self bounded, Option.getD_some]⟩

theorem CompletionFrames.completed_source {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (pending : info.completed < info.routines.length) (present : result.globals.position ≠ 0) :
    ∃ read : CompletionBodyRead (declarationReaders reader calls) text globals frames.signature.info (info.completed + 1)
        (frames.signature.info.routineAt (info.completed + 1)) frames.outputs.body result,
      result.info.routines[info.completed]? = some
        (finishedItem (frames.signature.info.routineAt (info.completed + 1))
          (footerAfter (declarationReaders reader calls) text read.returned) read.returned) ∧
      ((info.routineAt (info.completed + 1)).kind = .function →
        (completionInput (declarationReaders reader calls) (frames.signature.info.routineAt (info.completed + 1))
          frames.outputs.body).allowProcedureCalls = false ∧
        read.returned.writes = emptyStateSet ∧
        (result.info.routineAt result.info.completed).mayWrite = emptyStateSet) := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  have within : info.completed + 1 ≤ frames.signature.info.routines.length := by
    rw [tables.lengths.2]
    omega
  obtain ⟨_, stored, selected⟩ := read.stored_item (by omega) within
  refine ⟨read, by simpa only [Nat.add_one_sub_one] using stored, ?_⟩
  intro function
  have kind : (frames.signature.info.routineAt (info.completed + 1)).kind = .function := by
    have same := congrArg Routine.kind frames.selected_declaration
    change (frames.signature.info.routineAt (info.completed + 1)).kind = (info.routineAt (info.completed + 1)).kind at same
    exact same.trans function
  have empty := (completionReturn_function kind read.readReturn).2.2.2.1
  refine ⟨?_, empty, ?_⟩
  · simp only [completionInput, kind, reduceCtorEq, decide_false]
  · rw [selected]
    exact empty

/-- At every original ordinal, Main's final routine row is exactly that
routine's own accepted footer result. Function call permissions and empty
writes follow from the same completion, even for an unused declaration. -/
theorem original_completed_sources {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result) :
    ∀ (offset : Nat) (row : RoutineRead), parsed.history.rows[offset]? = some row →
      ∃ frames : CompletionFrames (declarationReaders reader completion) (sources.prefix .packageBody)
          row.before.globals row.before.info row.result,
        ∃ read : CompletionBodyRead (declarationReaders reader completion) (sources.prefix .packageBody)
            row.before.globals frames.signature.info (offset + 1) (frames.signature.info.routineAt (offset + 1))
            frames.outputs.body row.result,
          parsed.body.info.routines[offset]? = some
            (finishedItem (frames.signature.info.routineAt (offset + 1))
              (footerAfter (declarationReaders reader completion) (sources.prefix .packageBody) read.returned) read.returned) ∧
          ((row.before.info.routineAt (offset + 1)).kind = .function →
            (completionInput (declarationReaders reader completion) (frames.signature.info.routineAt (offset + 1))
              frames.outputs.body).allowProcedureCalls = false ∧ read.returned.writes = emptyStateSet) := by
  intro offset row found
  obtain ⟨called, pending, advanced⟩ := parsed.history.completions.readings row (List.mem_of_getElem? found)
  have present : row.result.globals.position ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced)
  obtain ⟨frames⟩ := RoutineRead.frames called present
  obtain ⟨ordinal, _, finalRow⟩ := (package_routine_ordinals parsed).2.2.2 offset row found
  subst offset
  obtain ⟨read, stored, restricted⟩ := frames.completed_source pending present
  exact ⟨frames, read, finalRow.trans stored, fun function =>
    ⟨(restricted function).1, (restricted function).2.1⟩⟩

end Silver.ApplicationPackageBodies
