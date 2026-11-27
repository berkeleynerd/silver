module

public import Silver.ApplicationPackageBodyHistory

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose ApplicationUnits ApplicationPackageNames ApplicationPackageObjectRows ApplicationPackageDeclarations
open ApplicationAdmission (BodyResult)

private theorem semicolon_bound (text : Source) (position : Nat) :
    tokenAfter text position (.symbol ";") ≤ text.length + 1 := by
  change fixedAfter text position ";" false ≤ _
  by_cases missing : fixedAfter text position ";" false = 0
  · rw [missing]
    exact Nat.zero_le _
  · exact (fixed_window (by decide) missing).2

private theorem completion_end {calls : CompletionCalls} (text : Source)
    (semicolon : ∀ position, calls.takeToken text position (.symbol ";") ≤ text.length + 1)
    (globals : ParserState) (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine)
    (state : InitializationFrame) :
    (completionBody calls text globals info index item state).globals.position ≤ text.length + 1 := by
  dsimp only [completionBody]
  split
  · dsimp only [uncheckedCompletionBody]
    split
    · exact Nat.zero_le _
    · split
      · exact Nat.zero_le _
      · dsimp only [completionFooter]
        split
        · exact Nat.zero_le _
        · exact semicolon _
  · exact Nat.zero_le _

theorem readCompletion_bound (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (globals : ParserState) (info : PackageBindings.Metadata) :
    (readCompletion reader calls text globals info).globals.position ≤ text.length + 1 := by
  generalize actual : readCompletion reader calls text globals info = result
  by_cases rejected : result.globals.position = 0
  · rw [rejected]
    exact Nat.zero_le _
  · have read := (readCompletion_eq reader calls text globals info).trans (congrArg some actual)
    obtain ⟨frames⟩ := packageCompletionFuel_frames read rejected
    rw [← frames.executed]
    exact completion_end text (semicolon_bound text) ..

private theorem start_bound {calls : UnitCalls} {text : Source} {exports : ParserState}
    {info : PackageBindings.Metadata} {state : UnitState}
    (pragma : ∀ position, calls.sparkPragmaAfter text position ≤ text.length + 1)
    (entered : startUnit calls text exports info = .continued state) : state.globals.position ≤ text.length + 1 := by
  dsimp only [startUnit] at entered
  split at entered
  · contradiction
  · split at entered
    · contradiction
    · cases entered
      exact pragma _

private theorem next_bound {calls : UnitCalls} {text : Source} {before after : UnitState}
    (objectEnd : ∀ frame info, (calls.objectAt text frame info false).frame.position ≤ text.length + 1)
    (completionEnd : ∀ frame info, (calls.completionAt text frame info).globals.position ≤ text.length + 1)
    (bounded : before.globals.position ≤ text.length + 1) (continued : unitStep calls text before = .continued after) :
    after.globals.position ≤ text.length + 1 := by
  cases phase : before.phase with
  | objects =>
    simp only [unitStep, phase] at continued
    split at continued
    · split at continued
      · contradiction
      · split at continued
        · contradiction
        · cases continued
          exact objectEnd _ _
    · cases continued
      exact bounded
  | routines =>
    simp only [unitStep, phase] at continued
    split at continued
    · split at continued
      · contradiction
      · cases continued
        exact completionEnd _ _
    · cases continued
      exact bounded
  | footer => simp only [unitStep, phase, reduceCtorEq] at continued

private theorem object_end (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (info : PackageBindings.Metadata) :
    (objectStep (modelObjectCalls reader) text frame info false).frame.position ≤ text.length + 1 := by
  by_cases missing : (objectStep (modelObjectCalls reader) text frame info false).frame.position = 0
  · rw [missing]
    exact Nat.zero_le _
  · exact (objectStep_positions reader text frame info false missing).2.2.2

/-- Cursor progress and the two possible phase changes bound every run of the
original unit reader, including its rejected and partially read inputs. -/
theorem packageBody_total (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (exports : ParserState) (info : PackageBindings.Metadata) :
    ∃ result, packageBodyFuel (bodyReaders reader calls) (3 * (text.length + 1) + 3) text exports info = some result := by
  dsimp only [packageBodyFuel]
  split
  · exact ⟨_, rfl⟩
  · rename_i state entered
    have initial := start_bound (fun _ => semicolon_bound text _) entered
    have rank : state.phase.rank ≤ 2 := by cases state.phase <;> decide
    apply unitFuel_total (limit := text.length + 1) (valid := fun s => s.globals.position ≤ text.length + 1)
      (fun _ legal => legal) (fun _ _ legal step =>
        next_bound (object_end reader text) (readCompletion_bound reader calls text) legal step) initial
    dsimp only [unitRemaining]
    omega

def readBody (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (exports : ParserState) (info : PackageBindings.Metadata) : BodyResult :=
  (packageBodyFuel (bodyReaders reader calls) (3 * (text.length + 1) + 3) text exports info).get
    (Option.isSome_iff_exists.mpr (packageBody_total reader calls text exports info))

theorem readBody_eq (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (exports : ParserState) (info : PackageBindings.Metadata) :
    packageBodyFuel (bodyReaders reader calls) (3 * (text.length + 1) + 3) text exports info =
      some (readBody reader calls text exports info) := (Option.some_get _).symm

end Silver.ApplicationPackageBodies
