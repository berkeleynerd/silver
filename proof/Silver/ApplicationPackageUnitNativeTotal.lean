module

public import Silver.ApplicationPackageUnitComposition

@[expose] public section

namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies Compose
open Compose.Expressions ApplicationPackageDeclarations

set_option backward.dsimp.instances true

private def ImportDomain (text : Source) (locals : ApplicationNative.Locals) : Prop :=
  locals .source "text" = text ∧ ReaderFrame text (locals .state "globals") ∧
    (locals .metadata "info").Typed

private theorem object_continued (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (locals : ApplicationNative.Locals) (legal : ImportDomain text locals)
    (tested : objectTest (library.unitCalls reader) locals = true)
    (continued : (objectStep (library.unitCalls reader) locals).returned = false) :
    ImportDomain text (objectStep (library.unitCalls reader) locals).locals := by
  have step := objectStep_simulation (library.unitCalls reader) locals
  rw [legal.1, library.unit_step reader valid (stateAt locals .objects) ⟨legal.2.1, legal.2.2⟩,
    tested, continued] at step
  simp only [Bool.false_eq_true, ↓reduceIte] at step
  have domain := unit_step_domain library reader valid (state := stateAt locals .objects) ⟨legal.2.1, legal.2.2⟩ step
  exact ⟨(objectStep_preserves_text (library.unitCalls reader) locals).trans legal.1,
    domain.frame, domain.metadata⟩

private theorem routine_continued (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (locals : ApplicationNative.Locals) (legal : ImportDomain text locals)
    (tested : routineTest locals = true)
    (continued : (routineStep (library.unitCalls reader) locals).returned = false) :
    ImportDomain text (routineStep (library.unitCalls reader) locals).locals := by
  have step := routineStep_simulation (library.unitCalls reader) locals
  rw [legal.1, library.unit_step reader valid (stateAt locals .routines) ⟨legal.2.1, legal.2.2⟩,
    tested, continued] at step
  simp only [Bool.false_eq_true, ↓reduceIte] at step
  have domain := unit_step_domain library reader valid (state := stateAt locals .routines) ⟨legal.2.1, legal.2.2⟩ step
  exact ⟨(routineStep_preserves_text (library.unitCalls reader) locals).trans legal.1,
    domain.frame, domain.metadata⟩

private theorem object_imports_total (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (locals : ApplicationNative.Locals) (legal : ImportDomain text locals) :
    ∃ result, objectLoop (library.unitCalls reader) (text.length + 2) locals = some result ∧
      (result.returned = false → ImportDomain text result.locals) := by
  obtain ⟨result, computed⟩ := whileLocals_total (test := objectTest (library.unitCalls reader))
    (body := fun store => some (objectStep (library.unitCalls reader) store)) (ImportDomain text)
    (fun store => text.length + 1 - (store .state "globals").position)
    (fun store domain tested => ⟨_, rfl, fun continued => by
      have next := object_continued library reader valid store domain tested continued
      have progress := objectStep_progress (library.unitCalls reader) store continued
      refine ⟨next, ?_⟩
      have before := domain.2.1.cursor
      have after := next.2.1.cursor
      change (store .state "globals").position ≤ text.length + 1 at before
      change ((objectStep (library.unitCalls reader) store).locals .state "globals").position ≤ text.length + 1 at after
      omega⟩) legal (fuel := text.length + 2) (by omega)
  refine ⟨result, computed, ?_⟩
  have execution := whileLocals_sound computed
  clear computed
  induction execution with
  | stopped tested => exact fun _ => legal
  | returned tested selected returned => exact fun continuing => by simp [returned] at continuing
  | @continued store next final tested selected continuing rest ih =>
    have same : objectStep (library.unitCalls reader) store = next := Option.some.inj selected
    have nextLegal : ImportDomain text next.locals := same ▸ object_continued library reader valid store legal tested (same ▸ continuing)
    exact ih nextLegal

private theorem routine_imports_total (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (locals : ApplicationNative.Locals) (legal : ImportDomain text locals) :
    ∃ result, routineLoop (library.unitCalls reader) (text.length + 2) locals = some result := by
  apply whileLocals_total (valid := ImportDomain text)
    (measure := fun store => text.length + 1 - (store .state "globals").position)
  · intro store domain tested
    refine ⟨_, rfl, fun continued => ?_⟩
    have next := routine_continued library reader valid store domain tested continued
    have progress := routineStep_progress (library.unitCalls reader) store continued
    refine ⟨next, ?_⟩
    have before := domain.2.1.cursor
    have after := next.2.1.cursor
    change (store .state "globals").position ≤ text.length + 1 at before
    change ((routineStep (library.unitCalls reader) store).locals .state "globals").position ≤ text.length + 1 at after
    omega
  · exact legal
  · omega

/-- Actual typed Unit execution terminates using domains preserved on the
original control path. No callback contract is assumed on unreachable frames. -/
theorem body_imports_total (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (locals : ApplicationNative.Locals)
    (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "exports"))
    (typed : (locals .metadata "info").Typed)
    (cursor : ValidCursor (locals .source "text") ((locals .metadata "info").units .packageBody).first) :
    ∃ after, body.eval (modelFunctions (library.unitCalls reader)) (modelProcedures (library.unitCalls reader))
      ((locals .source "text").length + 2) locals = some after := by
  rw [body_meaning]
  let text := locals .source "text"
  let calls := library.unitCalls reader
  let start := prefixStep calls (initializedLocals calls locals)
  have textAt : start.locals .source "text" = text :=
    (prefixStep_stable calls (initializedLocals calls locals)).1.trans (initializedLocals_fields calls locals).1
  have startDomain (continuing : start.returned = false) : ImportDomain text start.locals := by
    have entered := startUnit_simulation calls locals
    change startUnit calls text (locals .state "exports") (locals .metadata "info") =
      if start.returned then _ else _ at entered
    rw [continuing] at entered
    simp only [Bool.false_eq_true, ↓reduceIte] at entered
    rw [library.unit_start reader valid _ _ cursor] at entered
    have domain := unit_start_domain reader _ valid _ framed _ typed entered
    exact ⟨textAt, domain.frame, domain.metadata⟩
  change ∃ after, ((start.bind fun started =>
    (objectLoop calls (text.length + 2) started).bind fun objects => objects.bind fun completedObjects =>
      (routineLoop calls (text.length + 2) completedObjects).bind fun routines => routines.bind fun completedRoutines =>
        some (footerStep calls completedRoutines)).map Outcome.locals) = some after
  by_cases returning : start.returned = true
  · exact ⟨start.locals, by simp only [Outcome.bind, returning, ↓reduceIte, Option.map_some]⟩
  · have continuing := Bool.eq_false_iff.mpr returning
    obtain ⟨objects, computed, objectsDomain⟩ := object_imports_total library reader valid start.locals (startDomain continuing)
    change objectLoop calls (text.length + 2) start.locals = some objects at computed
    simp only [Outcome.bind, returning, Bool.false_eq_true, ↓reduceIte]
    rw [computed]
    simp only [Option.bind_some]
    by_cases objectReturns : objects.returned = true
    · exact ⟨objects.locals, by simp only [objectReturns, ↓reduceIte, Option.map_some]⟩
    · simp only [objectReturns, Bool.false_eq_true, ↓reduceIte]
      obtain ⟨routines, finished⟩ := routine_imports_total library reader valid objects.locals
        (objectsDomain (Bool.eq_false_iff.mpr objectReturns))
      rw [finished]
      simp only [Option.bind_some]
      by_cases routineReturns : routines.returned = true
      · exact ⟨routines.locals, by simp only [routineReturns, ↓reduceIte, Option.map_some]⟩
      · exact ⟨(footerStep calls routines.locals).locals,
          by simp only [routineReturns, Bool.false_eq_true, ↓reduceIte, Option.map_some]⟩

end Silver.ApplicationPackageUnit.Native
