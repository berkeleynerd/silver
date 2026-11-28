module

public import Silver.ApplicationPackageCallsInterpretation

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- A read-only rejection loop visits precisely the inclusive native range.
The theorem keeps the early return and restores the hidden loop index. -/
theorem forValues_reject {Parameters : Type}
    (body : Locals → (Locals → ApplicationPackages.ApplicationCall) → ApplicationPackages.ApplicationCall)
    (parameters : Locals → Parameters) (test : Parameters → Nat → Bool)
    (failure : Parameters → ApplicationPackages.ApplicationCall) (name : String)
    (preserved : ∀ locals index, parameters (locals.set .number name index) = parameters locals)
    (equation : ∀ locals next, body locals next =
      if test (parameters locals) (locals .number name) then failure (parameters locals) else next locals)
    (values : List Nat) (locals : Locals) (next : Locals → ApplicationPackages.ApplicationCall)
    (stable : ∀ current index, next (current.set .number name index) = next current) :
    forValues (resultType := .appCall) body name values locals next =
      if values.any (test (parameters locals)) then failure (parameters locals) else next locals := by
  induction values generalizing locals with
  | nil => rfl
  | cons value rest ih =>
      rw [forValues, equation]
      simp only [preserved, Locals.set_get_same, List.any_cons]
      split
      · simp_all
      · rw [ih]
        simp_all only [Bool.false_or]

structure StateAliasParameters where
  item : PackageBindings.Routine
  actual : ApplicationPackages.PackageActual
  failure : ApplicationPackages.ApplicationCall

def stateAliasParameters (locals : Locals) : StateAliasParameters :=
  ⟨locals .routine "item", (locals .packageActuals "actuals").getD (locals .number "i" - 1) {},
    locals .appCall "failure"⟩

def stateAliasTest (parameters : StateAliasParameters) (index : Nat) : Bool :=
  PackageBindings.StateSet.get parameters.item.mayWrite index &&
    PackageBindings.StateSet.get parameters.actual.reads index

def stateAliasBody : C :=
  .choose (.andThen (.index .stateBit (.field .routineMayWrite item) s)
    (.index .stateBit (.field .actualReads (actual i).expression) s)) returnFailure .nothing

theorem state_alias_body (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    stateAliasBody.eval (resultType := .appCall) (imported calls) locals next =
      if stateAliasTest (stateAliasParameters locals) (locals .number "s") then
        (stateAliasParameters locals).failure else next locals := by
  rfl

theorem state_alias_scan (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    stateAliasScan.eval (resultType := .appCall) (imported calls) locals next =
      if (List.range (locals .metadata "info").states.length).any
          (fun index => stateAliasTest (stateAliasParameters locals) (index + 1)) then
        locals .appCall "failure" else next locals := by
  change forValues (resultType := .appCall)
    (fun current continuation => stateAliasBody.eval (resultType := .appCall) (imported calls) current continuation)
    "s" ((List.range ((locals .metadata "info").states.length + 1 - 1)).map (1 + ·)) locals
    (fun updated => next (updated.set .number "s" (locals .number "s"))) = _
  rw [forValues_reject _ stateAliasParameters stateAliasTest (·.failure) "s"
    (by intros; simp [stateAliasParameters, Locals.set]) (state_alias_body calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  simp only [Nat.add_sub_cancel, List.any_map, Function.comp_def, Nat.add_comm,
    Locals.set_unchanged, stateAliasParameters]
  rfl

structure PayloadAliasParameters where
  text : Source
  actuals : List ApplicationPackages.PackageActual
  index : Nat
  failure : ApplicationPackages.ApplicationCall

def payloadAliasParameters (locals : Locals) : PayloadAliasParameters :=
  ⟨locals .source "text", locals .packageActuals "actuals", locals .number "i", locals .appCall "failure"⟩

def payloadAliasTest (calls : ApplicationPackageCalls.Calls) (parameters : PayloadAliasParameters)
    (other : Nat) : Bool :=
  let actual := parameters.actuals.getD (parameters.index - 1) {}
  let candidate := parameters.actuals.getD (other - 1) {}
  decide (parameters.index ≠ other) &&
    !calls.actualNameFree parameters.text candidate.first candidate.after actual.target.first actual.target.after

def payloadAliasBody : C :=
  .choose (.andThen (.ne i j) (.not (call5 .actualNameFree text
    (.field .actualFirst (actual j).expression) (.field .actualAfter (actual j).expression)
    (.field .targetFirst (.field .actualTarget (actual i).expression))
    (.field .targetAfter (.field .actualTarget (actual i).expression))))) returnFailure .nothing

theorem payload_alias_body (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    payloadAliasBody.eval (resultType := .appCall) (imported calls) locals next =
      if payloadAliasTest calls (payloadAliasParameters locals) (locals .number "j") then
        (payloadAliasParameters locals).failure else next locals := by
  rfl

theorem payload_alias_scan (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    payloadAliasScan.eval (resultType := .appCall) (imported calls) locals next =
      if (namedRange (locals .routine "item")).any (payloadAliasTest calls (payloadAliasParameters locals)) then
        locals .appCall "failure" else next locals := by
  change forValues (resultType := .appCall)
    (fun current continuation => payloadAliasBody.eval (resultType := .appCall) (imported calls) current continuation)
    "j" (namedRange (locals .routine "item")) locals
    (fun updated => next (updated.set .number "j" (locals .number "j"))) = _
  rw [forValues_reject _ payloadAliasParameters (payloadAliasTest calls) (·.failure) "j"
    (by intros; simp [payloadAliasParameters, Locals.set]) (payload_alias_body calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  simp only [Locals.set_unchanged, payloadAliasParameters]
  rfl


/-- The complete per-formal alias stage retains its temporary scalar assignment.
No metadata validity or reachable-state premise is inserted into its equation. -/
def aliasLocals (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Option Locals :=
  if (List.range (locals .metadata "info").states.length).any
      (fun index => stateAliasTest (stateAliasParameters locals) (index + 1)) then none
  else
    let index := locals .number "i"
    let actual := (locals .packageActuals "actuals").getD (index - 1) {}
    let parameter := (locals .metadata "info").parameterAt index
    let item := locals .routine "item"
    if parameter.mode ≠ .input then
      if actual.target.after = 0 then none
      else if actual.writtenState ≠ 0 ∧
          (PackageBindings.StateSet.get item.mayRead actual.writtenState = true ∨
           PackageBindings.StateSet.get item.mayWrite actual.writtenState = true) then none
      else if (namedRange item).any (payloadAliasTest calls (payloadAliasParameters locals)) then none
      else
        let updated := locals.set .number "scalar" actual.target.scalar
        let result := replaceScalar (locals .appCall "result") actual.target.scalar parameter.bounds
        some (updated.set .appCall "result"
          {result with result := {result.result with scan := {result.result.scan with assigned := true}}})
    else some locals

theorem alias_body_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    aliasCommands.eval (resultType := .appCall) (imported calls) locals next =
      match aliasLocals calls locals with
      | none => locals .appCall "failure" | some updated => next updated := by
  unfold aliasCommands
  generalize stateEq : stateAliasScan = states
  generalize payloadEq : payloadAliasScan = payloads
  have stateRule (current : Locals) (continuation : Locals → ApplicationPackages.ApplicationCall) :
      states.eval (resultType := .appCall) (imported calls) current continuation =
        if (List.range (current .metadata "info").states.length).any
            (fun index => stateAliasTest (stateAliasParameters current) (index + 1)) then
          current .appCall "failure" else continuation current := by
    rw [← stateEq]
    exact state_alias_scan calls current continuation
  have payloadRule (current : Locals) (continuation : Locals → ApplicationPackages.ApplicationCall) :
      payloads.eval (resultType := .appCall) (imported calls) current continuation =
        if (namedRange (current .routine "item")).any
            (payloadAliasTest calls (payloadAliasParameters current)) then
          current .appCall "failure" else continuation current := by
    rw [← payloadEq]
    exact payload_alias_scan calls current continuation
  dsimp only [Command.list, List.foldr, Command.eval, Place.set, Place.expression,
    Expr.eval, imported, info, i, item, actual, actuals, returnFailure, failure,
    scalar, facts, scan, output, result, Field.get, Field.set, Index.get, Index.set]
  simp only [stateRule, payloadRule]
  dsimp only [aliasLocals, PackageBindings.StateSet.get]
  simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq]
  split
  · rfl
  · split
    · split
      · rfl
      · split
        · rfl
        · split
          · rfl
          · simp only [Locals.set, ↓reduceDIte, ↓reduceIte]
            split
            · simp_all [replaceScalar, Predicate.ActiveFlow.replace]
            · simp_all [replaceScalar, Predicate.ActiveFlow.replace]
    · rfl

theorem aliasLocals_result (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (positive : 0 < (locals .routine "item").count) :
    (aliasLocals calls locals).map (fun updated => updated .appCall "result") =
      aliasStep calls (locals .source "text") (locals .metadata "info")
        (locals .routine "item") (locals .packageActuals "actuals")
        (locals .appCall "result") (locals .number "i") := by
  dsimp only [aliasLocals, aliasStep, stateAliasTest, stateAliasParameters,
    payloadAliasTest, payloadAliasParameters, PackageBindings.StateSet.get]
  rw [namedRange_of_positive _ positive]
  split
  · rfl
  · by_cases input : ((locals .metadata "info").parameterAt (locals .number "i")).mode = .input
    · simp [input]
    · simp only [ne_eq, input, not_false_eq_true, ↓reduceIte]
      split
      · rfl
      · split
        · rfl
        · split
          · simp_all [payloadAliasTest]
          · simp_all [payloadAliasTest, Locals.set]


/-- Inputs needed after the alias pass. Its scalar scratch object and range
index are deliberately excluded; every source argument and call effect remains. -/
structure AliasInputs where
  text : Source
  context : Predicate.ParseContext
  input : ApplicationPackages.ApplicationScan
  info : PackageBindings.Metadata
  position : Nat
  kind : PackageBindings.RoutineKind
  item : PackageBindings.Routine
  actuals : List ApplicationPackages.PackageActual
  callWrites : PackageBindings.StateSet
  cursor : Nat
  failure : ApplicationPackages.ApplicationCall

def aliasInputs (locals : Locals) : AliasInputs :=
  ⟨locals .source "text", locals .parseContext "context", locals .appScan "input",
    locals .metadata "info", locals .number "position", locals .routineKind "kind",
    locals .routine "item", locals .packageActuals "actuals", locals .stateSet "call_writes",
    locals .number "cursor_at", locals .appCall "failure"⟩

theorem aliasInputs_index (locals : Locals) (index : Nat) :
    aliasInputs (locals.set .number "i" index) = aliasInputs locals := by
  simp [aliasInputs, Locals.set]

theorem aliasLocals_inputs {calls : ApplicationPackageCalls.Calls} {locals updated : Locals}
    (accepted : aliasLocals calls locals = some updated) : aliasInputs updated = aliasInputs locals := by
  dsimp only [aliasLocals] at accepted
  split at accepted
  · contradiction
  · split at accepted
    · split at accepted
      · contradiction
      · split at accepted
        · contradiction
        · split at accepted
          · contradiction
          · cases accepted
            simp [aliasInputs, Locals.set]
    · cases accepted
      rfl

def aliasStepInputs (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (result : ApplicationPackages.ApplicationCall) (index : Nat) : Option ApplicationPackages.ApplicationCall :=
  aliasStep calls inputs.text inputs.info inputs.item inputs.actuals result index

theorem alias_values (calls : ApplicationPackageCalls.Calls) (values : List Nat) (locals : Locals)
    (next : AliasInputs → ApplicationPackages.ApplicationCall → ApplicationPackages.ApplicationCall)
    (positive : 0 < (aliasInputs locals).item.count) :
    forValues (resultType := .appCall)
      (fun current continuation => aliasCommands.eval (resultType := .appCall) (imported calls) current continuation)
      "i" values locals (fun updated => next (aliasInputs updated) (updated .appCall "result")) =
      match values.foldlM (aliasStepInputs calls (aliasInputs locals)) (locals .appCall "result") with
      | none => (aliasInputs locals).failure
      | some output => next (aliasInputs locals) output := by
  induction values generalizing locals with
  | nil => rfl
  | cons value rest ih =>
      rw [forValues, alias_body_denotation]
      have indexedPositive : 0 < ((locals.set .number "i" value) .routine "item").count := by
        simpa [Locals.set, aliasInputs] using positive
      have projection := aliasLocals_result calls (locals.set .number "i" value) indexedPositive
      change (aliasLocals calls (locals.set .number "i" value)).map
        (fun updated => updated .appCall "result") =
        aliasStepInputs calls (aliasInputs (locals.set .number "i" value))
          ((locals.set .number "i" value) .appCall "result")
          ((locals.set .number "i" value) .number "i") at projection
      simp only [aliasInputs_index, Locals.set_get_same,
        Locals.set_get_other_type _ .number .appCall _ _ _ (by decide)] at projection
      cases accepted : aliasLocals calls (locals.set .number "i" value) with
      | none =>
          rw [accepted] at projection
          simp only [Option.map_none] at projection
          simp only [List.foldlM_cons, ← projection]
          rfl
      | some updated =>
          rw [accepted] at projection
          simp only [Option.map_some] at projection
          have inputs : aliasInputs updated = aliasInputs locals :=
            (aliasLocals_inputs accepted).trans (aliasInputs_index locals value)
          have positiveUpdated : 0 < (aliasInputs updated).item.count := by rw [inputs]; exact positive
          dsimp only
          rw [ih updated positiveUpdated]
          simp only [inputs, List.foldlM_cons, ← projection]
          rfl


def aliasScan : C := .forRange "i" formalFirst formalLast aliasCommands

theorem alias_scan_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : AliasInputs → ApplicationPackages.ApplicationCall → ApplicationPackages.ApplicationCall)
    (positive : 0 < (aliasInputs locals).item.count) :
    aliasScan.eval (resultType := .appCall) (imported calls) locals
        (fun updated => next (aliasInputs updated) (updated .appCall "result")) =
      match (formalSlots (locals .routine "item")).foldlM
          (aliasStepInputs calls (aliasInputs locals)) (locals .appCall "result") with
      | none => (aliasInputs locals).failure
      | some output => next (aliasInputs locals) output := by
  change forValues (resultType := .appCall)
    (fun current continuation => aliasCommands.eval (resultType := .appCall) (imported calls) current continuation)
    "i" (namedRange (locals .routine "item")) locals
    (fun updated => next (aliasInputs (updated.set .number "i" (locals .number "i")))
      ((updated.set .number "i" (locals .number "i")) .appCall "result")) = _
  simp only [aliasInputs_index, Locals.set_get_other_type _ .number .appCall _ _ _ (by decide)]
  rw [alias_values calls _ locals next positive,
    namedRange_of_positive (locals .routine "item") positive]

end Silver.ApplicationPackageCalls.Native.Call

