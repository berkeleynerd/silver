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

end Silver.ApplicationPackageCalls.Native.Call
