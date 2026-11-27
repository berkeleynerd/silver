module

public import Silver.ApplicationPackageAdmissionHistory
public import Silver.ApplicationPackageCompletionResult

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationUnits ApplicationPackageDeclarations ApplicationPackageExportRows
open ApplicationAdmission (BodyResult ParsedPackage)

structure RoutineCoverage (before final : Metadata) (rows : List RoutineRead) : Prop where
  count : final.completed = before.completed + rows.length
  routineDeclarations : final.routines.map routineDeclaration = before.routines.map routineDeclaration
  formalDeclarations : final.parameters.map formalDeclaration = before.parameters.map formalDeclaration
  previous : ∀ index, index < before.completed → final.routines[index]? = before.routines[index]?
  ordinal : ∀ offset row, rows[offset]? = some row →
    row.before.info.completed = before.completed + offset ∧ row.result.info.completed = before.completed + offset + 1 ∧
    final.routines[before.completed + offset]? = row.result.info.routines[before.completed + offset]?

private theorem step_tables {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {row : RoutineRead}
    (read : (bodyReaders reader calls).completionAt text row.before.globals row.before.info = row.result)
    (advanced : row.before.globals.position < row.result.globals.position) :
    row.result.info.completed = row.before.info.completed + 1 ∧ CompletedTables row.before.info row.result.info := by
  have present : row.result.globals.position ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced)
  obtain ⟨frames⟩ := RoutineRead.frames read present
  exact frames.result_tables present

theorem RoutineHistory.coverage {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls} {text : Source}
    {before : UnitState} {rows : List RoutineRead} {result : BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result) :
    RoutineCoverage before.info result.info rows := by
  induction history with
  | finished phase allRead footer =>
    dsimp only [unitStep] at footer
    cases footer
    exact ⟨rfl, rfl, rfl, fun _ _ => rfl, by simp⟩
  | @added row later result phase pending read advanced rest ih =>
    obtain ⟨completed, tables⟩ := step_tables read advanced
    change RoutineCoverage row.result.info result.info later at ih
    refine ⟨?_, ih.routineDeclarations.trans tables.routineDeclarations, ih.formalDeclarations.trans tables.declared, ?_, ?_⟩
    · rw [ih.count, completed, List.length_cons]
      omega
    · intro index earlier
      exact (ih.previous index (by omega)).trans (tables.otherRoutines index (Nat.ne_of_lt earlier))
    · intro offset seen found
      cases offset with
      | zero =>
        simp only [List.getElem?_cons_zero, Option.some.injEq] at found
        subst seen
        exact ⟨rfl, completed, ih.previous row.before.info.completed (by omega)⟩
      | succ offset =>
        obtain ⟨first, last, final⟩ := ih.ordinal offset seen (by simpa only [List.getElem?_cons_succ] using found)
        have same : row.result.info.completed + offset = row.before.info.completed + (offset + 1) := by omega
        exact ⟨first.trans same, last.trans (congrArg (· + 1) same), same ▸ final⟩

private structure RoutineTablesEqual (first second : Metadata) : Prop where
  completed : first.completed = second.completed
  routines : first.routines = second.routines
  formals : first.parameters = second.parameters

private theorem start_table_fields {calls : UnitCalls} {text : Source} {exports : ParserState} {info : Metadata}
    {entry : UnitState} (start : startUnit calls text exports info = .continued entry) :
    RoutineTablesEqual entry.info info := by
  dsimp only [startUnit] at start
  split at start
  · contradiction
  · split at start
    · contradiction
    · cases start; exact ⟨rfl, rfl, rfl⟩

private theorem state_table_fields {calls : UnitCalls} {text : Source} {entry next : UnitState} {objects : List StateObject}
    (decls : StateObjects calls text entry objects next) : RoutineTablesEqual next.info entry.info := by
  induction decls with
  | finished => exact ⟨rfl, rfl, rfl⟩
  | added _ _ _ _ _ _ _ ih => exact ⟨ih.completed, ih.routines, ih.formals⟩

theorem BodyHistory.routine_coverage {reader completion sources specification result}
    (history : BodyHistory reader completion sources specification result) :
    RoutineCoverage specification.info result.info history.rows := by
  have first := start_table_fields history.entered
  have states := state_table_fields history.declarations
  have covered := history.completions.coverage
  have count := states.completed.trans first.completed
  have routines := states.routines.trans first.routines
  have formals := states.formals.trans first.formals
  exact ⟨covered.count.trans (congrArg (· + history.rows.length) count),
    covered.routineDeclarations.trans (congrArg (List.map routineDeclaration) routines),
    covered.formalDeclarations.trans (congrArg (List.map formalDeclaration) formals),
    fun n earlier => (covered.previous n (count ▸ earlier)).trans (congrArg (fun xs : List Routine => xs[n]?) routines),
    fun offset row found => count ▸ covered.ordinal offset row found⟩

private theorem specification_zero (reader : BooleanElaboration.Native.Reader) (sources : Bundle)
    {specification : ApplicationAdmission.SpecificationResult}
    (read : readSpecification reader (sources.prefix .packageSpecification) {units := sources.units} = specification)
    (accepted : specification.exports.position ≠ 0) : specification.info.completed = 0 := by
  subst specification
  exact (specification_rows reader _ _ accepted).1.completed

theorem original_routine_start {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result) : parsed.history.routinesStart.info.completed = 0 := by
  have first := start_table_fields parsed.history.entered
  have states := state_table_fields parsed.history.declarations
  exact states.completed.trans (first.completed.trans (specification_zero reader sources parsed.specified parsed.specificationAccepted))

/-- Every routine of the original specification is completed once, including
unused routines. Its final effects come from that routine's original footer. -/
theorem package_routine_ordinals {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result) :
    parsed.history.rows.length = parsed.specification.info.routines.length ∧
      parsed.body.info.routines.map routineDeclaration = parsed.specification.info.routines.map routineDeclaration ∧
      parsed.body.info.parameters.map formalDeclaration = parsed.specification.info.parameters.map formalDeclaration ∧
      ∀ offset row, parsed.history.rows[offset]? = some row →
        row.before.info.completed = offset ∧ row.result.info.completed = offset + 1 ∧
        parsed.body.info.routines[offset]? = row.result.info.routines[offset]? := by
  have covered := parsed.history.routine_coverage
  have zero := specification_zero reader sources parsed.specified parsed.specificationAccepted
  have finished := parsed.complete
  simp only [completeMetadata, Bool.and_eq_true, decide_eq_true_eq] at finished
  have lengths := congrArg List.length covered.routineDeclarations
  simp only [List.length_map] at lengths
  have count := covered.count
  rw [zero, Nat.zero_add] at count
  refine ⟨count.symm.trans (finished.2.2.trans lengths), covered.routineDeclarations, covered.formalDeclarations, ?_⟩
  intro offset row found
  simpa only [zero, Nat.zero_add] using covered.ordinal offset row found

end Silver.ApplicationPackageBodies
