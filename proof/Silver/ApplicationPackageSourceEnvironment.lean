module

public import Silver.ApplicationPackageRoutineCoverage
public import Silver.ApplicationPackageCallsSemantics

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Packages PackageBindings ApplicationPackageDeclarations
open ApplicationPackageCalls (completedEnvironment)
open ApplicationAdmission (BodyResult ParsedPackage)

private theorem project_getD {α β : Type} (project : α → β) (rows : List α) (index : Nat) (fallback : α) :
    project (rows.getD index fallback) = (rows.map project).getD index (project fallback) := by
  simp only [List.getD_eq_getElem?_getD, List.getElem?_map]
  cases rows[index]? <;> rfl

private theorem parameter_fields {before after : Metadata}
    (declared : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration) (id : Nat) :
    formalDeclaration (after.parameterAt id) = formalDeclaration (before.parameterAt id) := by
  have current := project_getD formalDeclaration after.parameters (id - 1) {}
  have original := project_getD formalDeclaration before.parameters (id - 1) {}
  rw [declared] at current
  exact current.trans original.symm

private theorem signature_stable {before after : Metadata}
    (declared : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration) (item : Routine) :
    item.signature after = item.signature before := by
  have domain (i : Nat) := congrArg Formal.domain (parameter_fields declared i)
  have formal (i : Nat) := congrArg Formal.semantic (parameter_fields declared i)
  have inputs : (item.formals after).map Formal.domain = (item.formals before).map Formal.domain := by
    simp only [Routine.formals, List.map_map]
    exact List.map_congr_left (fun offset _ => domain (item.formalFirst + offset))
  have procedure : (item.formals after).map Formal.semantic = (item.formals before).map Formal.semantic := by
    simp only [Routine.formals, List.map_map]
    exact List.map_congr_left (fun offset _ => formal (item.formalFirst + offset))
  cases kind : item.kind <;> simp only [Routine.signature, kind, inputs, procedure]

def signatureEffects (info : Metadata) (item : Routine) : RoutineEffects := ⟨item.signature info, item.effects info⟩

private theorem entry_stable {before after : Metadata} (tables : CompletedTables before after)
    (states : after.states = before.states) (item : Routine) : signatureEffects after item = signatureEffects before item := by
  have effects : item.effects after = item.effects before := by
    simp only [Routine.effects, Metadata.effectCells, Metadata.stateAt, states]
  simp only [signatureEffects, signature_stable tables.declared item, effects]

private theorem previous_rows {before after : Metadata} (tables : CompletedTables before after) :
    after.routines.take before.completed = before.routines.take before.completed := by
  apply List.ext_getElem?
  intro index
  by_cases earlier : index < before.completed
  · simpa only [List.getElem?_take_of_lt earlier] using tables.otherRoutines index (Nat.ne_of_lt earlier)
  · have none (items : List Routine) : (items.take before.completed)[index]? = none := by
      apply List.getElem?_eq_none
      simp only [List.length_take]
      omega
    rw [none, none]

private theorem previous_environment {before after : Metadata} (tables : CompletedTables before after)
    (states : after.states = before.states) :
    (after.routines.take before.completed).map (signatureEffects after) = completedEnvironment before := by
  rw [previous_rows tables]
  exact List.map_congr_left (fun item _ => entry_stable tables states item)

/-- The signature's body-name and formal-span writes preserve the complete
semantic callable prefix seen in this routine's actual body context. -/
theorem completing_environment (text : Source) (globals : ParserState) (before : Metadata) :
    completedEnvironment (readSignature text globals before true).info = completedEnvironment before := by
  have count := congrArg Metadata.completed (readSignature_exec text globals before true).retains_fields
  change (readSignature text globals before true).info.completed = before.completed at count
  unfold completedEnvironment
  rw [count]
  exact previous_environment (readSignature_tables text globals before) (readSignature_states text globals before true)

def RoutineRead.effectEntry (row : RoutineRead) : RoutineEffects :=
  signatureEffects row.result.info (row.result.info.routineAt row.result.info.completed)

private theorem appended_environment {before after : Metadata} (tables : CompletedTables before after)
    (states : after.states = before.states) (completed : after.completed = before.completed + 1)
    (pending : before.completed < before.routines.length) :
    completedEnvironment after = completedEnvironment before ++ [signatureEffects after (after.routineAt after.completed)] := by
  have bounded : before.completed < after.routines.length := by rwa [tables.lengths.2]
  have observed : after.routineAt after.completed = after.routines[before.completed] := by
    simp only [Metadata.routineAt, completed, Nat.add_one_sub_one, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem bounded, Option.getD_some]
  change (after.routines.take after.completed).map (signatureEffects after) = _
  rw [completed, List.take_succ_eq_append_getElem bounded, List.map_append, previous_environment tables states]
  simp only [List.map_cons, List.map_nil, ← completed, observed]

private theorem read_environment {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {row : RoutineRead}
    (read : (bodyReaders reader calls).completionAt text row.before.globals row.before.info = row.result)
    (pending : row.before.info.completed < row.before.info.routines.length)
    (advanced : row.before.globals.position < row.result.globals.position) :
    completedEnvironment row.result.info = completedEnvironment row.before.info ++ [row.effectEntry] := by
  have present : row.result.globals.position ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced)
  obtain ⟨frames⟩ := RoutineRead.frames read present
  obtain ⟨count, fields⟩ := frames.result_tables present
  have signed : readSignature text row.before.globals row.before.info true = frames.signature := frames.signed
  have same : frames.signature.info.states = row.before.info.states := signed ▸ readSignature_states ..
  have states := (completionBody_globals frames.executed present).2.2.trans same
  exact appended_environment fields states count pending

theorem RoutineHistory.environments {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {before : UnitState} {rows : List RoutineRead} {result : BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result) :
    completedEnvironment result.info = completedEnvironment before.info ++ rows.map RoutineRead.effectEntry ∧
      ∀ offset row, rows[offset]? = some row →
        completedEnvironment row.before.info = completedEnvironment before.info ++ (rows.take offset).map RoutineRead.effectEntry := by
  induction history with
  | finished phase allRead footer =>
    dsimp only [unitStep] at footer
    cases footer
    exact ⟨by simp, by simp⟩
  | @added row later result phase pending read advanced rest ih =>
    have added := read_environment read pending advanced
    obtain ⟨last, atOffset⟩ := ih
    change completedEnvironment result.info = completedEnvironment row.result.info ++ _ at last
    refine ⟨by simpa only [added, List.map_cons, List.append_assoc, List.singleton_append] using last, ?_⟩
    intro offset seen found
    cases offset with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at found
      subst seen
      simp
    | succ offset =>
      have previous := atOffset offset seen (by simpa only [List.getElem?_cons_succ] using found)
      change completedEnvironment seen.before.info = completedEnvironment row.result.info ++ _ at previous
      simpa only [added, List.take_succ_cons, List.map_cons, List.append_assoc, List.singleton_append] using previous

theorem CompletionFrames.body_environment {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) :
    completedEnvironment frames.signature.info = completedEnvironment info := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  exact signed ▸ completing_environment text globals info

/-- The semantic callable environment seen by each original routine is
exactly the prefix of preceding footer results. Main receives all of them. -/
theorem original_environments {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result) :
    completedEnvironment parsed.body.info = parsed.history.rows.map RoutineRead.effectEntry ∧
      ∀ offset row, parsed.history.rows[offset]? = some row →
        completedEnvironment row.before.info = (parsed.history.rows.take offset).map RoutineRead.effectEntry := by
  have initial : completedEnvironment parsed.history.routinesStart.info = [] := by
    simp only [completedEnvironment, original_routine_start parsed, List.take_zero, List.map_nil]
  simpa only [initial, List.nil_append] using parsed.history.completions.environments

end Silver.ApplicationPackageBodies
