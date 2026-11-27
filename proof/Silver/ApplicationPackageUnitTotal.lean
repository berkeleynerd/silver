module

public import Silver.ApplicationPackageUnitSimulation
public import Silver.ApplicationPackageBodyTotal

@[expose] public section

namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies
open Compose ApplicationPackageDeclarations ApplicationPackageObjectRows

set_option backward.dsimp.instances true

private theorem objectStep_bound (calls : UnitCalls) (locals : Locals) (limit : Nat)
    (before : (locals .state "globals").position ≤ limit)
    (next : (calls.objectAt (locals .source "text") (locals .state "globals")
      (locals .metadata "info") false).frame.position ≤ limit) :
    ((objectStep calls locals).locals .state "globals").position ≤ limit := by
  dsimp only [objectStep]
  split
  · exact before
  · split
    · exact before
    · exact next

private theorem routineStep_bound (calls : UnitCalls) (locals : Locals) (limit : Nat)
    (next : (calls.completionAt (locals .source "text") (locals .state "globals")
      (locals .metadata "info")).globals.position ≤ limit) :
    ((routineStep calls locals).locals .state "globals").position ≤ limit := by
  exact next

private def Bounded (text : Source) (locals : Locals) : Prop :=
  locals .source "text" = text ∧ (locals .state "globals").position ≤ text.length + 1

private theorem objectLoop_total (calls : UnitCalls) (text : Source)
    (objects : ∀ frame info, (calls.objectAt text frame info false).frame.position ≤ text.length + 1)
    (locals : Locals) (valid : Bounded text locals) :
    ∃ result, objectLoop calls (text.length + 2) locals = some result ∧ Bounded text result.locals := by
  have preserve (store : Locals) (valid : Bounded text store) :
      Bounded text (objectStep calls store).locals := by
    refine ⟨(objectStep_preserves_text calls store).trans valid.1, ?_⟩
    apply objectStep_bound calls store _ valid.2
    rw [valid.1]
    exact objects _ _
  obtain ⟨result, computed⟩ := whileLocals_total (test := objectTest calls)
    (body := fun current => some (objectStep calls current)) (Bounded text)
    (fun store => text.length + 1 - (store .state "globals").position)
    (fun store legal _ => ⟨objectStep calls store, rfl, fun continues => by
      have next := preserve store legal
      have progress := objectStep_progress calls store continues
      exact ⟨next, by have bound := legal.2; have after := next.2; omega⟩⟩)
    valid (fuel := text.length + 2) (by omega)
  refine ⟨result, computed, ?_⟩
  exact (whileLocals_sound computed).preserves (Bounded text)
    (fun store outcome legal selected => by cases selected; exact preserve store legal) valid

private theorem routineLoop_total (calls : UnitCalls) (text : Source)
    (completions : ∀ frame info, (calls.completionAt text frame info).globals.position ≤ text.length + 1)
    (locals : Locals) (valid : Bounded text locals) :
    ∃ result, routineLoop calls (text.length + 2) locals = some result := by
  apply whileLocals_total (valid := Bounded text)
    (measure := fun store => text.length + 1 - (store .state "globals").position)
  · intro store legal _
    refine ⟨routineStep calls store, rfl, fun continues => ?_⟩
    have next : Bounded text (routineStep calls store).locals := by
      refine ⟨(routineStep_preserves_text calls store).trans legal.1, ?_⟩
      apply routineStep_bound calls store _
      rw [legal.1]
      exact completions _ _
    have progress := routineStep_progress calls store continues
    exact ⟨next, by have bound := legal.2; have after := next.2; omega⟩
  · exact valid
  · omega

/-- The complete typed Package_Body procedure terminates for every incoming
store when its callees return bounded original cursors. Both loops use their
actual strict-progress rejection guards; failed partial metadata is retained. -/
theorem body_total (calls : UnitCalls) (locals : Locals)
    (pragmaBound : ∀ position, calls.sparkPragmaAfter (locals .source "text") position ≤
      (locals .source "text").length + 1)
    (objects : ∀ frame info, (calls.objectAt (locals .source "text") frame info false).frame.position ≤
      (locals .source "text").length + 1)
    (completions : ∀ frame info, (calls.completionAt (locals .source "text") frame info).globals.position ≤
      (locals .source "text").length + 1) :
    ∃ after, body.eval (modelFunctions calls) (modelProcedures calls)
      ((locals .source "text").length + 2) locals = some after := by
  rw [body_meaning]
  let text := locals .source "text"
  let start := prefixStep calls (initializedLocals calls locals)
  have textAt : start.locals .source "text" = text :=
    (prefixStep_stable calls (initializedLocals calls locals)).1.trans (initializedLocals_fields calls locals).1
  have startBound (continuing : start.returned = false) : Bounded text start.locals := by
    refine ⟨textAt, ?_⟩
    have fields := initializedLocals_fields calls locals
    dsimp only [start, prefixStep] at continuing ⊢
    split at continuing
    · contradiction
    · rename_i named
      rw [ite_eq_right named]
      change calls.sparkPragmaAfter ((initializedLocals calls locals) .source "text") _ ≤ _
      rw [fields.1]
      exact pragmaBound _
  change ∃ after, ((start.bind fun started =>
    (objectLoop calls (text.length + 2) started).bind fun objects => objects.bind fun completedObjects =>
      (routineLoop calls (text.length + 2) completedObjects).bind fun routines => routines.bind fun completedRoutines =>
        some (footerStep calls completedRoutines)).map Outcome.locals) = some after
  by_cases returned : start.returned = true
  · exact ⟨start.locals, by simp only [Outcome.bind, returned, ↓reduceIte, Option.map_some]⟩
  · have continuing := Bool.eq_false_iff.mpr returned
    obtain ⟨objectResult, objectDone, objectBound⟩ := objectLoop_total calls text objects start.locals (startBound continuing)
    simp only [Outcome.bind, returned, Bool.false_eq_true, ↓reduceIte, objectDone, Option.bind_some]
    by_cases objectReturns : objectResult.returned = true
    · exact ⟨objectResult.locals, by simp only [objectReturns, ↓reduceIte, Option.map_some]⟩
    · simp only [objectReturns, Bool.false_eq_true, ↓reduceIte]
      obtain ⟨routineResult, routineDone⟩ := routineLoop_total calls text completions objectResult.locals objectBound
      rw [routineDone]
      simp only [Option.bind_some]
      by_cases routineReturns : routineResult.returned = true
      · exact ⟨routineResult.locals, by simp only [routineReturns, ↓reduceIte, Option.map_some]⟩
      · exact ⟨(footerStep calls routineResult.locals).locals,
          by simp only [routineReturns, Bool.false_eq_true, ↓reduceIte, Option.map_some]⟩

/-- The source-derived model callees establish the required bounds even for
malformed/rejected inputs; no successful-read hypothesis is introduced. -/
theorem body_readers_total (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (locals : Locals) :
    ∃ after, body.eval (modelFunctions (bodyReaders reader calls))
      (modelProcedures (bodyReaders reader calls)) ((locals .source "text").length + 2) locals = some after := by
  apply body_total
  · intro position
    exact fixedAfter_result_bound _ _ ";" false (by decide)
  · intro frame info
    change (ApplicationPackageDeclarations.objectStep (modelObjectCalls reader)
      (locals .source "text") frame info false).frame.position ≤ _
    by_cases missing : (ApplicationPackageDeclarations.objectStep (modelObjectCalls reader)
      (locals .source "text") frame info false).frame.position = 0
    · rw [missing]; exact Nat.zero_le _
    · exact (objectStep_positions reader _ frame info false missing).2.2.2
  · intro frame info
    exact readCompletion_bound reader calls _ frame info

/-- Terminating typed execution and the independently totalized unit model
have the same observable metadata and Accepted flag, including every rejection. -/
theorem body_readers_meaning (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (locals after : Locals) (fuel : Nat)
    (found : body.eval (modelFunctions (bodyReaders reader calls))
      (modelProcedures (bodyReaders reader calls)) fuel locals = some after) :
    observed after = readBody reader calls (locals .source "text")
      (locals .state "exports") (locals .metadata "info") := by
  have actual := body_simulation found
  have modeled := readBody_eq reader calls (locals .source "text")
    (locals .state "exports") (locals .metadata "info")
  unfold UnitMeaning at actual
  unfold packageBodyFuel at modeled
  cases started : startUnit (bodyReaders reader calls) (locals .source "text")
      (locals .state "exports") (locals .metadata "info") with
  | returned result =>
    rw [started] at actual modeled
    exact actual.trans (Option.some.inj modeled)
  | continued state =>
    rw [started] at actual modeled
    exact actual.unique (unitFuel_sound modeled)

end Silver.ApplicationPackageUnit.Native
