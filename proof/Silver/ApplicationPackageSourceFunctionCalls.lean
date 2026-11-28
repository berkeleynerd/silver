module

public import Silver.ApplicationPackageCompletedSource
public import Silver.ApplicationPackageFunctionCallFrame
public import Silver.ApplicationPackageCallsFunctionChecking

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open PackageBindings

/-- Only routines already available to a source call are covered. -/
def CompletedFunctionWrites (info : Metadata) : Prop :=
  ∀ identity, 0 < identity → identity ≤ info.completed →
    (info.routineAt identity).kind = .function → (info.routineAt identity).mayWrite = emptyStateSet

theorem completed_function_writes {text : Text} {info : Metadata}
    (complete : completeMetadata text info = true) : CompletedFunctionWrites info := by
  simp only [completeMetadata, Bool.and_eq_true, decide_eq_true_eq] at complete
  intro identity positive available function
  have declared := validMetadata_routine complete.1 positive (complete.2.2 ▸ available)
  simp only [routineValid, Bool.and_eq_true] at declared
  have pure := declared.1.2
  simp only [function, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq] at pure
  exact pure.2

/-- A literal retained table prefix inherits the final validator's function
write restriction. The validator is used only at its original full bundle. -/
theorem CompletedFunctionWrites.of_prefix {earlier later : Metadata} (known : CompletedFunctionWrites later)
    (count : earlier.completed ≤ later.completed)
    (rows : ∀ index, index < earlier.completed → later.routines[index]? = earlier.routines[index]?) :
    CompletedFunctionWrites earlier := by
  intro identity positive available function
  have same : later.routineAt identity = earlier.routineAt identity := by
    simpa only [Metadata.routineAt, List.getD_eq_getElem?_getD] using
      congrArg (fun value : Option Routine => value.getD {}) (rows (identity - 1) (by omega))
  rw [← same]
  exact known identity positive (Nat.le_trans available count) (same ▸ function)

end Silver.ApplicationPackageDeclarations

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationPackageDeclarations
open ApplicationAdmission (BodyResult ParsedPackage)

theorem RoutineHistory.completed_prefixes {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {before : UnitState} {rows : List RoutineRead} {result : BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result) :
    ∀ row ∈ rows, row.before.info.completed ≤ result.info.completed ∧
      ∀ index, index < row.before.info.completed → result.info.routines[index]? = row.before.info.routines[index]? := by
  induction history with
  | finished => simp
  | @added row later result phase pending read advanced rest ih =>
    have full : RoutineHistory (bodyReaders reader calls) text row.before (row :: later) result :=
      .added phase pending read advanced rest
    have covered := full.coverage
    intro seen member
    rcases List.mem_cons.mp member with rfl | following
    · exact ⟨by have count := covered.count; omega, covered.previous⟩
    · exact ih seen following

theorem original_function_writes {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result) :
    CompletedFunctionWrites parsed.body.info ∧
      ∀ row ∈ parsed.history.rows, CompletedFunctionWrites row.before.info := by
  have finalWrites := completed_function_writes parsed.complete
  refine ⟨finalWrites, ?_⟩
  intro row member
  obtain ⟨count, rows⟩ := parsed.history.completions.completed_prefixes row member
  exact finalWrites.of_prefix count rows

theorem CompletionFrames.body_function_writes {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (known : CompletedFunctionWrites info) : CompletedFunctionWrites frames.signature.info := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  have kept := congrArg Metadata.completed (readSignature_exec text globals info true).retains_fields
  have count : frames.signature.info.completed = info.completed := by
    simpa only [SignatureStates.unchangedFields, signed] using kept
  apply known.of_prefix (Nat.le_of_eq count)
  intro index earlier
  exact (tables.otherRoutines index (by omega)).symm

end Silver.ApplicationPackageBodies

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages PackageBindings ApplicationPackageDeclarations
open ApplicationPackageBodies

/-- Both premises below are derived from original declaration and completion
history. The call uses its own completed prefix; no full-text validity predicate
is imposed on the shorter source supplied while parsing the package body. -/
theorem declared_function_call_frame {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : Metadata} {position : Nat}
    (accepted : (packageCallAt modelCalls text context input info position .function).value.after ≠ 0)
    (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info) :
    let called := packageCallAt modelCalls text context input info position .function
    called.result.scan = {input.scan with position := called.value.after} ∧
      called.result.allowProcedureCalls = input.allowProcedureCalls ∧
      called.result.writes = stateUnion input.writes emptyStateSet := by
  obtain ⟨callee, _, _, _, selected, present, _, _, _, _, _, _, _⟩ := accepted_call accepted
  obtain ⟨positive, completed, kind, _⟩ := callee_completed selected.symm present rfl
  have inside : callee - 1 < info.routines.length := by
    have available := (callee_trace selected.symm present).1
    omega
  have member : info.routineAt callee ∈ info.routines := by
    simp only [Metadata.routineAt, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem inside, Option.getD_some]
    exact List.getElem_mem inside
  apply function_call_frame accepted
  · rw [← selected]
    intro slot slotPresent
    obtain ⟨offset, inRange, same⟩ := List.mem_map.mp slotPresent
    apply declared.function_inputs member kind
    exact List.mem_map.mpr ⟨offset, inRange, congrArg info.parameterAt same⟩
  · rw [← selected]
    exact writes callee positive completed kind

theorem original_body_function_call_frame {reader completion calls sources result}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    {row : RoutineRead} (member : row ∈ parsed.history.rows)
    (frames : CompletionFrames (declarationReaders reader completion) (sources.prefix .packageBody)
      row.before.globals row.before.info row.result)
    {context : ParseContext} {input : ApplicationScan} {position : Nat}
    (accepted : (packageCallAt modelCalls (sources.prefix .packageBody) context input frames.signature.info position .function).value.after ≠ 0) :
    let called := packageCallAt modelCalls (sources.prefix .packageBody) context input frames.signature.info position .function
    called.result.scan = {input.scan with position := called.value.after} ∧
      called.result.allowProcedureCalls = input.allowProcedureCalls ∧
      called.result.writes = stateUnion input.writes emptyStateSet := by
  obtain ⟨offset, found⟩ := List.mem_iff_getElem?.mp member
  have modes := ((original_formal_modes parsed).2.2 offset row found).1
  have writes := (original_function_writes parsed).2 row member
  exact declared_function_call_frame accepted (frames.body_formal_modes modes) (frames.body_function_writes writes)

theorem original_main_function_call_frame {reader completion calls sources result}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    {context : ParseContext} {input : ApplicationScan} {position : Nat}
    (accepted : (packageCallAt modelCalls (sources.prefix .mainBody) context input parsed.body.info position .function).value.after ≠ 0) :
    let called := packageCallAt modelCalls (sources.prefix .mainBody) context input parsed.body.info position .function
    called.result.scan = {input.scan with position := called.value.after} ∧
      called.result.allowProcedureCalls = input.allowProcedureCalls ∧
      called.result.writes = stateUnion input.writes emptyStateSet :=
  declared_function_call_frame accepted (original_formal_modes parsed).2.1 (original_function_writes parsed).1

end Silver.ApplicationPackageCalls
