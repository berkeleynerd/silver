module

public import Silver.ApplicationPackageSourceEnvironment
public import Silver.ApplicationPackageDeclarationsFormalModes

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open PackageBindings

private theorem declaration_mode {before after : Metadata}
    (declared : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration) (index : Nat) :
    (after.parameters.getD index {}).mode = (before.parameters.getD index {}).mode := by
  have modes : after.parameters.map Formal.mode = before.parameters.map Formal.mode := by
    simpa only [List.map_map, Function.comp_def, formalDeclaration] using congrArg (List.map Formal.mode) declared
  have project (rows : List Formal) :
      (rows.getD index {}).mode = (rows.map Formal.mode).getD index (.input) := by
    simp only [List.getD_eq_getElem?_getD, List.getElem?_map]
    cases rows[index]? <;> rfl
  rw [project, project, modes]

/-- Body spans and inferred effects cannot change a declared formal mode or
its original physical table bounds. This uses the actual declaration rows. -/
theorem DeclaredFormalModes.of_declarations {before after : Metadata}
    (known : DeclaredFormalModes before)
    (parameters : after.parameters.map formalDeclaration = before.parameters.map formalDeclaration)
    (routines : after.routines.map routineDeclaration = before.routines.map routineDeclaration) :
    DeclaredFormalModes after := by
  have length : after.parameters.length = before.parameters.length := by
    simpa only [List.length_map] using congrArg List.length parameters
  intro item member
  have original : routineDeclaration item ∈ before.routines.map routineDeclaration := by
    rw [← routines]
    exact List.mem_map.mpr ⟨item, member, rfl⟩
  obtain ⟨prior, declared, fields⟩ := List.mem_map.mp original
  have kind : prior.kind = item.kind := by simpa only [routineDeclaration] using congrArg Routine.kind fields
  have first : prior.formalFirst = item.formalFirst := by simpa only [routineDeclaration] using congrArg Routine.formalFirst fields
  have count : prior.count = item.count := by simpa only [routineDeclaration] using congrArg Routine.count fields
  have modes := known prior declared
  rw [FormalModes, kind, first, count] at modes
  intro offset within
  obtain ⟨positive, bounded, input⟩ := modes offset within
  exact ⟨positive, length ▸ bounded, fun function => (declaration_mode parameters _).trans (input function)⟩

end Silver.ApplicationPackageDeclarations

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationPackageDeclarations
open ApplicationAdmission (BodyResult ParsedPackage)

/-- The same declaration invariant applies inside the original body prefix,
after its completing Signature has installed the body-name spans. -/
theorem CompletionFrames.body_formal_modes {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (known : DeclaredFormalModes info) : DeclaredFormalModes frames.signature.info := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  exact signed ▸ readSignature_formal_modes text globals info true known

theorem RoutineHistory.formal_modes {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {before : UnitState} {rows : List RoutineRead} {result : BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (known : DeclaredFormalModes before.info) :
    DeclaredFormalModes result.info ∧
      ∀ (offset : Nat) (row : RoutineRead), rows[offset]? = some row →
        DeclaredFormalModes row.before.info ∧ DeclaredFormalModes row.result.info := by
  induction history with
  | finished phase allRead footer =>
    dsimp only [unitStep] at footer
    cases footer
    exact ⟨known, by simp⟩
  | @added row later result phase pending read advanced rest ih =>
    have present : row.result.globals.position ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced)
    obtain ⟨frames⟩ := RoutineRead.frames read present
    have tables := (frames.result_tables present).2
    have next := known.of_declarations tables.declared tables.routineDeclarations
    obtain ⟨finalModes, following⟩ := ih next
    refine ⟨finalModes, ?_⟩
    intro offset seen found
    cases offset with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at found
      subst seen
      exact ⟨known, next⟩
    | succ offset =>
      exact following offset seen (by simpa only [List.getElem?_cons_succ] using found)

/-- The accepted original specification establishes physical formal bounds
and input-only function formals for every routine, including unused routines.
Every body entry retains them, and the exact metadata supplied to Main does too. -/
theorem original_formal_modes {reader completion calls sources result}
    (parsed : ParsedPackage reader completion calls sources result) :
    DeclaredFormalModes parsed.specification.info ∧ DeclaredFormalModes parsed.body.info ∧
      ∀ (offset : Nat) (row : RoutineRead), parsed.history.rows[offset]? = some row →
        DeclaredFormalModes row.before.info ∧ DeclaredFormalModes row.result.info := by
  have initial : DeclaredFormalModes ({units := sources.units} : Metadata) := by
    intro item member
    cases member
  have specification : DeclaredFormalModes parsed.specification.info :=
    parsed.specified ▸ readSpecification_formal_modes reader (sources.prefix .packageSpecification) _ initial
  obtain ⟨routines, parameters⟩ := parsed.history.routine_start_tables
  have start : DeclaredFormalModes parsed.history.routinesStart.info :=
    specification.of_declarations (congrArg (List.map formalDeclaration) parameters)
      (congrArg (List.map routineDeclaration) routines)
  exact ⟨specification, parsed.history.completions.formal_modes start⟩

end Silver.ApplicationPackageBodies
