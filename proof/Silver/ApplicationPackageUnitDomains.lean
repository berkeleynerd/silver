module

public import Silver.ApplicationPackageUnitObjectTypes
public import Silver.ApplicationPackageCompletionMetadata
public import Silver.ApplicationPackageUnitImports

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Compose.Expressions ApplicationPackageDeclarations ApplicationPackageNames PackageBindings

set_option backward.dsimp.instances true

attribute [local irreducible] objectStep readCompletion tokenAfter packageWord sparkPragmaAfter PackageBindings.sameName

structure UnitDomain (text : Source) (state : UnitState) : Prop where
  frame : ReaderFrame text state.globals
  metadata : state.info.Typed

private theorem body_name_typed {info : Metadata} (typed : info.Typed)
    (first last : Nat) (name : (NameSpan.mk first last).Typed) :
    ({info with bodyNameFirst := first, bodyNameAfter := last} : Metadata).Typed :=
  ⟨typed.1, name, typed.2.2⟩

private theorem append_state_typed {info : Metadata} (typed : info.Typed)
    (item : StateDeclaration) (itemTyped : item.Typed) (space : info.states.length ≠ maxStates) :
    ({info with states := info.states ++ [item]} : Metadata).Typed := by
  rcases typed with ⟨name, bodyName, units, exports, states, routines, completed, parameters,
    exportTypes, stateTypes, routineTypes, parameterTypes⟩
  refine ⟨name, bodyName, units, exports, ?_, routines, completed, parameters, exportTypes, ?_, routineTypes, parameterTypes⟩
  · simp only [List.length_append, List.length_singleton]
    omega
  · intro value member
    rcases List.mem_append.mp member with prior | added
    · exact stateTypes value prior
    · obtain rfl := List.mem_singleton.mp added
      exact itemTyped

/-- Both package-name cursors are produced by the original lexical readers. -/
theorem unit_start_domain (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (valid : ValidText text) (exports : ParserState) (framed : ReaderFrame text exports)
    (info : Metadata) (typed : info.Typed) {state : UnitState}
    (entered : startUnit (bodyReaders reader calls) text exports info = .continued state) :
    UnitDomain text state := by
  have frame := ObjectLibraries.unit_start_framed reader
    (bodyReaders reader calls) framed info entered
  refine ⟨frame, ?_⟩
  dsimp +instances only [startUnit, bodyReaders, unitReaders] at entered
  split at entered
  · contradiction
  · split at entered
    · contradiction
    · cases entered
      apply body_name_typed typed
      have word (position : Nat) (word : String) : ValidCursor text (packageWord text position word) := by
        change packageWord text position word ≤ text.length + 1
        unfold ApplicationPackageNames.packageWord
        dsimp +instances only
        split
        · exact model_name_valid text _
        · exact Nat.zero_le _
      have first := model_skip_valid text _ (word (packageWord text (info.units .packageBody).first "package") "body")
      have last := model_name_valid text (skipAt text (packageWord text (packageWord text (info.units .packageBody).first "package") "body"))
      unfold NameSpan.Typed
      change _ ≤ maxSourceLength + 1 ∧ _ ≤ maxSourceLength + 1
      exact ⟨Nat.le_trans first (Nat.add_le_add_right valid.2 1),
        Nat.le_trans last (Nat.add_le_add_right valid.2 1)⟩

/-- Successful Completion changes only the global cursor. The returned
metadata may include completed routines and preserves every native subtype. -/
theorem completion_reader_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (globals : ParserState) (framed : ReaderFrame text globals) (info : Metadata)
    (present : (readCompletion reader calls text globals info).globals.position ≠ 0) :
    ReaderFrame text (readCompletion reader calls text globals info).globals := by
  obtain ⟨frames⟩ := packageCompletionFuel_frames (readCompletion_eq reader calls text globals info) present
  have fields := completionBody_globals frames.executed present
  rw [fields.1]
  exact framed.at_position (readCompletion_bound reader calls text globals info)

/-- Every continued original Unit step supplies the next helper's actual
reader precondition and native component subtypes. -/
theorem unit_step_domain (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    {state next : UnitState} (domain : UnitDomain text state)
    (continued : unitStep (bodyReaders reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)))
      text state = .continued next) : UnitDomain text next := by
  cases phase : state.phase with
  | objects =>
    dsimp +instances only [unitStep, bodyReaders, unitReaders] at continued
    simp only [phase] at continued
    by_cases declaration : tokenAfter text state.globals.position (.word "function") = 0 ∧
        tokenAfter text state.globals.position (.word "procedure") = 0 ∧
        tokenAfter text state.globals.position (.word "end") = 0
    · rw [ite_eq_left declaration] at continued
      by_cases full : state.info.states.length = maxStates
      · rw [ite_eq_left full] at continued
        contradiction
      · rw [ite_eq_right full] at continued
        let out := objectStep (modelObjectCalls reader) text state.globals state.info false
        change (if out.frame.position ≤ state.globals.position ∨ out.constantObject = true then _ else _) = _ at continued
        by_cases rejected : out.frame.position ≤ state.globals.position ∨ out.constantObject = true
        · rw [ite_eq_left rejected] at continued
          contradiction
        · rw [ite_eq_right rejected] at continued
          have live : out.frame.position ≠ 0 := by omega
          cases continued
          refine ⟨objectStep_reader_frame reader valid state.globals domain.frame state.info false live, ?_⟩
          apply append_state_typed domain.metadata _ _ full
          exact object_state_typed reader valid state.globals domain.frame state.info
            domain.metadata.2.2.2.1 false live
    · rw [ite_eq_right declaration] at continued
      cases continued
      exact ⟨domain.frame, domain.metadata⟩
  | routines =>
    dsimp +instances only [unitStep, bodyReaders, unitReaders] at continued
    simp only [phase] at continued
    by_cases more : state.info.completed < state.info.routines.length
    · rw [ite_eq_left more] at continued
      let out := readCompletion reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
        text state.globals state.info
      change (if out.globals.position ≤ state.globals.position then _ else _) = _ at continued
      by_cases stopped : out.globals.position ≤ state.globals.position
      · rw [ite_eq_left stopped] at continued
        contradiction
      · rw [ite_eq_right stopped] at continued
        have live : out.globals.position ≠ 0 := by omega
        cases continued
        exact ⟨completion_reader_frame reader _ state.globals domain.frame state.info live,
          library.completion_read_typed reader valid state.globals domain.frame state.info domain.metadata⟩
    · rw [ite_eq_right more] at continued
      cases continued
      exact ⟨domain.frame, domain.metadata⟩
  | footer => simp only [unitStep, phase, reduceCtorEq] at continued

end Silver.ApplicationPackageBodies
