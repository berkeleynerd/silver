module

public import Silver.ApplicationPackageUnitInterpretation
public import Silver.ApplicationPackageBodiesExecution

@[expose] public section

/-! Refinement to the independently specified package-unit state machine.
Returning failure observes the metadata actually written before the return. -/
namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative ApplicationPackageProcedure ApplicationPackageBodies

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def observed (locals : Locals) : ApplicationAdmission.BodyResult :=
  ⟨locals .metadata "info", locals .truth "accepted"⟩

def stateAt (locals : Locals) (phase : BodyPhase) : UnitState :=
  ⟨locals .state "globals", locals .metadata "info", phase⟩

theorem objectStep_simulation (calls : UnitCalls) (locals : Locals) :
    unitStep calls (locals .source "text") (stateAt locals .objects) =
      if objectTest calls locals then
        if (objectStep calls locals).returned then
          .returned ⟨(objectStep calls locals).locals .metadata "info", false⟩
        else .continued (stateAt (objectStep calls locals).locals .objects)
      else .continued (stateAt locals .routines) := by
  by_cases tested : calls.takeToken (locals .source "text") (locals .state "globals").position (.word "function") = 0 ∧
      calls.takeToken (locals .source "text") (locals .state "globals").position (.word "procedure") = 0 ∧
      calls.takeToken (locals .source "text") (locals .state "globals").position (.word "end") = 0
  · by_cases full : (locals .metadata "info").states.length = PackageBindings.maxStates
    · simp [unitStep, stateAt, objectStep, objectTest, tested, full]
    · by_cases rejected :
        (calls.objectAt (locals .source "text") (locals .state "globals") (locals .metadata "info") false).frame.position ≤
            (locals .state "globals").position ∨
        (calls.objectAt (locals .source "text") (locals .state "globals") (locals .metadata "info") false).constantObject = true
      all_goals simp [unitStep, stateAt, objectStep, objectTest, tested, full, rejected,
        grownMetadata, Locals.set]
  · have guard : objectTest calls locals = false := by
      apply Bool.eq_false_iff.mpr
      intro guard
      apply tested
      simpa only [objectTest, Bool.and_eq_true, decide_eq_true_eq, and_assoc] using guard
    simp only [unitStep, stateAt, tested, ↓reduceIte, guard, Bool.false_eq_true]

theorem routineStep_simulation (calls : UnitCalls) (locals : Locals) :
    unitStep calls (locals .source "text") (stateAt locals .routines) =
      if routineTest locals then
        if (routineStep calls locals).returned then
          .returned ⟨(routineStep calls locals).locals .metadata "info", false⟩
        else .continued (stateAt (routineStep calls locals).locals .routines)
      else .continued (stateAt locals .footer) := by
  by_cases tested : (locals .metadata "info").completed < (locals .metadata "info").routines.length
  · by_cases stalled :
      (calls.completionAt (locals .source "text") (locals .state "globals") (locals .metadata "info")).globals.position ≤
        (locals .state "globals").position
    all_goals simp [unitStep, stateAt, routineStep, routineTest, tested, stalled, Locals.set]
  · simp [unitStep, stateAt, routineTest, tested]

theorem footerStep_simulation (calls : UnitCalls) (locals : Locals) :
    unitStep calls (locals .source "text") (stateAt locals .footer) =
      .returned (observed (footerStep calls locals).locals) := by
  dsimp only [unitStep, stateAt, observed, footerStep, Locals.set]
  rfl

theorem objectExecution_simulation {calls : UnitCalls} {text : Source} {locals : Locals} {outcome : Outcome}
    (execution : WhileExecution (objectTest calls) (fun current => some (objectStep calls current)) locals outcome)
    (textAt : locals .source "text" = text) (rejected : locals .truth "accepted" = false)
    {result : ApplicationAdmission.BodyResult}
    (early : outcome.returned = true → result = observed outcome.locals)
    (finish : outcome.returned = false →
      UnitExecution (unitStep calls text) (stateAt outcome.locals .routines) result) :
    UnitExecution (unitStep calls text) (stateAt locals .objects) result := by
  induction execution with
  | @stopped locals tested =>
      apply UnitExecution.continued
      · simpa only [textAt, tested, Bool.false_eq_true, ↓reduceIte] using objectStep_simulation calls locals
      · exact finish rfl
  | @returned locals step tested selected returning =>
      have same : objectStep calls locals = step := Option.some.inj selected
      have raw := objectStep_simulation calls locals
      rw [textAt, tested, same, returning] at raw
      simp only [↓reduceIte] at raw
      have falseResult : step.locals .truth "accepted" = false := by
        rw [← same, objectStep_preserves_accepted, rejected]
      rw [early returning]
      apply UnitExecution.returned
      simpa only [observed, falseResult] using raw
  | @continued locals step outcome tested selected continuing rest induction =>
      have same : objectStep calls locals = step := Option.some.inj selected
      have raw := objectStep_simulation calls locals
      rw [textAt, tested, same, continuing] at raw
      simp only [Bool.false_eq_true, ↓reduceIte] at raw
      apply UnitExecution.continued raw
      apply induction
      · rw [← same, objectStep_preserves_text, textAt]
      · rw [← same, objectStep_preserves_accepted, rejected]
      · exact early
      · exact finish

theorem routineExecution_simulation {calls : UnitCalls} {text : Source} {locals : Locals} {outcome : Outcome}
    (execution : WhileExecution routineTest (fun current => some (routineStep calls current)) locals outcome)
    (textAt : locals .source "text" = text) (rejected : locals .truth "accepted" = false)
    {result : ApplicationAdmission.BodyResult}
    (early : outcome.returned = true → result = observed outcome.locals)
    (finish : outcome.returned = false →
      UnitExecution (unitStep calls text) (stateAt outcome.locals .footer) result) :
    UnitExecution (unitStep calls text) (stateAt locals .routines) result := by
  induction execution with
  | @stopped locals tested =>
      apply UnitExecution.continued
      · simpa only [textAt, tested, Bool.false_eq_true, ↓reduceIte] using routineStep_simulation calls locals
      · exact finish rfl
  | @returned locals step tested selected returning =>
      have same : routineStep calls locals = step := Option.some.inj selected
      have raw := routineStep_simulation calls locals
      rw [textAt, tested, same, returning] at raw
      simp only [↓reduceIte] at raw
      have falseResult : step.locals .truth "accepted" = false := by
        rw [← same, routineStep_preserves_accepted, rejected]
      rw [early returning]
      apply UnitExecution.returned
      simpa only [observed, falseResult] using raw
  | @continued locals step outcome tested selected continuing rest induction =>
      have same : routineStep calls locals = step := Option.some.inj selected
      have raw := routineStep_simulation calls locals
      rw [textAt, tested, same, continuing] at raw
      simp only [Bool.false_eq_true, ↓reduceIte] at raw
      apply UnitExecution.continued raw
      apply induction
      · rw [← same, routineStep_preserves_text, textAt]
      · rw [← same, routineStep_preserves_accepted, rejected]
      · exact early
      · exact finish

def Stable (text : Source) (locals : Locals) : Prop :=
  locals .source "text" = text ∧ locals .truth "accepted" = false

theorem objectExecution_stable {calls : UnitCalls} {text : Source} {locals : Locals} {outcome : Outcome}
    (execution : WhileExecution (objectTest calls) (fun current => some (objectStep calls current)) locals outcome)
    (initial : Stable text locals) : Stable text outcome.locals := by
  apply execution.preserves (Stable text) _ initial
  intro current step valid selected
  have same : objectStep calls current = step := Option.some.inj selected
  rw [← same]
  exact ⟨(objectStep_preserves_text calls current).trans valid.1,
    (objectStep_preserves_accepted calls current).trans valid.2⟩

theorem routineExecution_stable {calls : UnitCalls} {text : Source} {locals : Locals} {outcome : Outcome}
    (execution : WhileExecution routineTest (fun current => some (routineStep calls current)) locals outcome)
    (initial : Stable text locals) : Stable text outcome.locals := by
  apply execution.preserves (Stable text) _ initial
  intro current step valid selected
  have same : routineStep calls current = step := Option.some.inj selected
  rw [← same]
  exact ⟨(routineStep_preserves_text calls current).trans valid.1,
    (routineStep_preserves_accepted calls current).trans valid.2⟩

theorem loops_simulation {calls : UnitCalls} {text : Source} {fuel : Nat} {locals : Locals} {outcome : Outcome}
    (initial : Stable text locals)
    (found : ((objectLoop calls fuel locals).bind fun objects => objects.bind fun completedObjects =>
      (routineLoop calls fuel completedObjects).bind fun routines => routines.bind fun completedRoutines =>
        some (footerStep calls completedRoutines)) = some outcome) :
    UnitExecution (unitStep calls text) (stateAt locals .objects) (observed outcome.locals) := by
  simp only [Option.bind_eq_some_iff] at found
  obtain ⟨objects, objectsFound, rest⟩ := found
  have objectsExecuted := whileLocals_sound objectsFound
  have objectsStable := objectExecution_stable objectsExecuted initial
  apply objectExecution_simulation objectsExecuted initial.1 initial.2
  · intro returning
    simp only [Outcome.bind, returning, ↓reduceIte, Option.some.injEq] at rest
    cases rest
    rfl
  · intro continuing
    simp only [Outcome.bind, continuing, Bool.false_eq_true, ↓reduceIte,
      Option.bind_eq_some_iff] at rest
    obtain ⟨routines, routinesFound, finished⟩ := rest
    have routinesExecuted := whileLocals_sound routinesFound
    have routinesStable := routineExecution_stable routinesExecuted objectsStable
    apply routineExecution_simulation routinesExecuted objectsStable.1 objectsStable.2
    · intro returning
      simp only [returning, ↓reduceIte, Option.some.injEq] at finished
      cases finished
      rfl
    · intro continuing
      simp only [continuing, Bool.false_eq_true, ↓reduceIte, Option.some.injEq] at finished
      cases finished
      apply UnitExecution.returned
      simpa only [routinesStable.1] using footerStep_simulation calls routines.locals

theorem initializedLocals_fields (calls : UnitCalls) (locals : Locals) :
    let first := calls.skipAt (locals .source "text") (calls.packageWord (locals .source "text")
      (calls.packageWord (locals .source "text") ((locals .metadata "info").units .packageBody).first "package") "body")
    let updated := initializedLocals calls locals
    updated .source "text" = locals .source "text" ∧
      updated .metadata "info" = locals .metadata "info" ∧
      updated .state "globals" = locals .state "exports" ∧
      updated .number "first" = first ∧
      updated .number "last" = calls.nameAfter (locals .source "text") first := by
  dsimp only [initializedLocals, declarations, Declaration.eval, Declaration.names, List.foldl,
    Expr.eval, modelFunctions, Field.get, Index.get, Locals.set, skip, word, after, text,
    info, Initialization.value]
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem prefixStep_stable (calls : UnitCalls) (locals : Locals) :
    Stable (locals .source "text") (prefixStep calls locals).locals := by
  dsimp only [prefixStep]
  split <;> simp [Stable, Locals.set]

theorem startUnit_simulation (calls : UnitCalls) (locals : Locals) :
    let started := prefixStep calls (initializedLocals calls locals)
    startUnit calls (locals .source "text") (locals .state "exports") (locals .metadata "info") =
      if started.returned then .returned (observed started.locals)
      else .continued (stateAt started.locals .objects) := by
  have fields := initializedLocals_fields calls locals
  dsimp only at fields
  let updated := initializedLocals calls locals
  change startUnit calls _ _ _ = if (prefixStep calls updated).returned then _ else _
  dsimp only [prefixStep, Locals.set]
  simp only [updated, fields.1, fields.2.1, fields.2.2.1, fields.2.2.2.1, fields.2.2.2.2]
  dsimp only [startUnit]
  split
  · simp_all [observed, Locals.set]
  · split <;> simp_all [observed, stateAt, Locals.set]

def UnitMeaning (calls : UnitCalls) (locals after : Locals) : Prop :=
  match startUnit calls (locals .source "text") (locals .state "exports") (locals .metadata "info") with
  | .returned result => observed after = result
  | .continued state => UnitExecution (unitStep calls (locals .source "text")) state (observed after)

/-- Every computed procedure result is an execution of the original phased
unit model, including partially written failure metadata. The theorem does not
assume source safety, successful callee results, or a special initial store. -/
theorem body_simulation {calls : UnitCalls} {fuel : Nat} {locals after : Locals}
    (found : body.eval (modelFunctions calls) (modelProcedures calls) fuel locals = some after) :
    UnitMeaning calls locals after := by
  rw [body_meaning] at found
  simp only [execute, Option.map_eq_some_iff] at found
  obtain ⟨outcome, computed, rfl⟩ := found
  unfold UnitMeaning
  rw [startUnit_simulation]
  unfold executeCommands at computed
  unfold Outcome.bind at computed
  split at computed
  · rename_i returning
    simp only [returning, ↓reduceIte]
    cases computed
    rfl
  · rename_i continuing
    simp only [continuing]
    apply loops_simulation _ computed
    have stable := prefixStep_stable calls (initializedLocals calls locals)
    exact ⟨stable.1.trans (initializedLocals_fields calls locals).1, stable.2⟩

end Silver.ApplicationPackageUnit.Native
