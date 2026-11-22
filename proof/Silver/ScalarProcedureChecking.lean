module

public import Silver.ScalarProcedureSyntax
public import Silver.ScalarCallChecking

@[expose] public section

namespace Silver.ScalarProcedures
open ScalarFunctions (ScalarType Target)

def checkTargets (analysis : Integer.Analysis) (booleans : Boolean.Analysis) :
    List ScalarType → List Target → Bool
  | [], [] => true
  | domain :: domains, target :: targets =>
      target.check analysis booleans domain && checkTargets analysis booleans domains targets
  | _, _ => false

/-- All output intervals are declared formal domains. No body-specific result
or caller's previous value is exported as a procedure postcondition. -/
def afterTargets : List ScalarType → List Target → Predicate.Flow → Predicate.Flow
  | domain :: domains, target :: targets, flow =>
      afterTargets domains targets (target.after domain flow)
  | _, _, flow => flow

@[simp] theorem afterTargets_path (domains : List ScalarType) (targets : List Target)
    (flow : Predicate.Flow) : (afterTargets domains targets flow).path = flow.path := by
  induction domains generalizing targets flow with
  | nil => rfl
  | cons domain domains ih =>
      cases targets <;> simp only [afterTargets, ih, ScalarFunctions.Target.after_path]

theorem target_after_ranges {target : Target} {domain : ScalarType}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {flow : Predicate.Flow}
    (checked : target.check analysis booleans domain = true)
    (refined : flow.scalars.Refines analysis.declared) (bounded : flow.scalars.Bounded)
    (declared : analysis.declared.Bounded) :
    (target.after domain flow).scalars.Refines analysis.declared ∧
      (target.after domain flow).scalars.Bounded := by
  cases target with
  | boolean identity => exact ⟨refined, bounded⟩
  | integer identity target =>
      cases domain with
      | boolean | array _ => simp [Target.check] at checked
      | integer domain =>
          obtain ⟨_, present, nonempty, included⟩ := Target.integer_check checked
          have ordered : domain.lower ≤ domain.upper := by
            simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
            omega
          have domainBounded : domain.Bounded :=
            ⟨Integer.Interval.bounded_contains (declared _ _ present)
                (Integer.Interval.included_sound included ⟨Int.le_refl _, ordered⟩),
              Integer.Interval.bounded_contains (declared _ _ present)
                (Integer.Interval.included_sound included ⟨ordered, Int.le_refl _⟩)⟩
          refine ⟨?_, Integer.Ranges.put_bounded bounded domainBounded⟩
          intro other interval found
          by_cases same : other = identity
          · subst other
            rw [present] at found
            cases found
            exact ⟨domain, by simp [Target.after, Integer.put],
              fun _ within => Integer.Interval.included_sound included within⟩
          · obtain ⟨old, known, subset⟩ := refined other interval found
            exact ⟨old, by simpa only [Target.after, Integer.put, same, ↓reduceIte] using known, subset⟩

theorem afterTargets_ranges {domains : List ScalarType} {targets : List Target}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {flow : Predicate.Flow}
    (checked : checkTargets analysis booleans domains targets = true)
    (refined : flow.scalars.Refines analysis.declared) (bounded : flow.scalars.Bounded)
    (declared : analysis.declared.Bounded) :
    (afterTargets domains targets flow).scalars.Refines analysis.declared ∧
      (afterTargets domains targets flow).scalars.Bounded := by
  induction domains generalizing targets flow with
  | nil => cases targets <;> simp_all [checkTargets, afterTargets]
  | cons domain domains ih =>
      cases targets with
      | nil => simp [checkTargets] at checked
      | cons target targets =>
          have both := Bool.and_eq_true_iff.mp checked
          have first := target_after_ranges both.1 refined bounded declared
          exact ih both.2 first.1 first.2

theorem target_after_unchanged {target : Target} {domain : ScalarType}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {flow : Predicate.Flow} {identity : Nat}
    (checked : target.check analysis booleans domain = true)
    (readonly : analysis.mutable identity = false) :
    (target.after domain flow).scalars identity = flow.scalars identity := by
  cases target with
  | boolean index => rfl
  | integer index bounds =>
      cases domain with
      | boolean | array _ => rfl
      | integer result =>
          have writable := (Target.integer_check checked).1
          have other : identity ≠ index := by
            intro same
            rw [← same, readonly] at writable
            contradiction
          simp only [Target.after, Integer.put, other, ↓reduceIte]

theorem afterTargets_unchanged {domains : List ScalarType} {targets : List Target}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {flow : Predicate.Flow} {identity : Nat}
    (checked : checkTargets analysis booleans domains targets = true)
    (readonly : analysis.mutable identity = false) :
    (afterTargets domains targets flow).scalars identity = flow.scalars identity := by
  induction domains generalizing targets flow with
  | nil => cases targets <;> simp_all [checkTargets, afterTargets]
  | cons domain domains ih =>
      cases targets with
      | nil => simp [checkTargets] at checked
      | cons target targets =>
          have both := Bool.and_eq_true_iff.mp checked
          exact (ih both.2).trans (target_after_unchanged both.1 readonly)

def Call.check (signatures : Signatures) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow)
    (booleans : Boolean.Analysis) (call : Call) : Bool :=
  match call.resolve signatures with
  | none => false
  | some resolved =>
      actualsApart call.actuals &&
        ScalarFunctions.checkActuals shape analysis flow booleans
          (inputTypes resolved.signature.formals) resolved.actuals.inputs &&
        checkTargets analysis booleans (outputTypes resolved.signature.formals) resolved.actuals.outputs

theorem Call.check_success {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis} {call : Call}
    (checked : call.check signatures shape analysis flow booleans = true) :
    ∃ resolved, call.resolve signatures = some resolved ∧
      actualsApart call.actuals = true ∧
      ScalarFunctions.checkActuals shape analysis flow booleans
        (inputTypes resolved.signature.formals) resolved.actuals.inputs = true ∧
      checkTargets analysis booleans (outputTypes resolved.signature.formals) resolved.actuals.outputs = true := by
  cases found : call.resolve signatures with
  | none => simp [Call.check, found] at checked
  | some resolved =>
      have checks : (actualsApart call.actuals = true ∧
          ScalarFunctions.checkActuals shape analysis flow booleans
            (inputTypes resolved.signature.formals) resolved.actuals.inputs = true) ∧
          checkTargets analysis booleans (outputTypes resolved.signature.formals) resolved.actuals.outputs = true := by
        simpa only [Call.check, found, Bool.and_eq_true] using checked
      exact ⟨resolved, rfl, checks.1.1, checks.1.2, checks.2⟩

theorem Call.resolve_success {signatures : Signatures} {call : Call} {resolved : ResolvedCall}
    (found : call.resolve signatures = some resolved) :
    lookup signatures call.callee = some resolved.signature ∧
      bindActuals resolved.signature.formals call.actuals = some resolved.actuals := by
  simp only [Call.resolve, Option.bind_eq_some_iff, Option.map_eq_some_iff] at found
  obtain ⟨signature, known, actuals, bound, same⟩ := found
  cases same
  exact ⟨known, bound⟩

def Call.after (signatures : Signatures) (flow : Predicate.Flow) (call : Call) : Predicate.Flow :=
  match call.resolve signatures with
  | none => flow
  | some resolved => afterTargets (outputTypes resolved.signature.formals) resolved.actuals.outputs flow

@[simp] theorem Call.after_path (signatures : Signatures) (flow : Predicate.Flow) (call : Call) :
    (call.after signatures flow).path = flow.path := by
  unfold after
  split
  · rfl
  · exact afterTargets_path ..

theorem Call.after_ranges {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis} {call : Call}
    (checked : call.check signatures shape analysis flow booleans = true)
    (refined : flow.scalars.Refines analysis.declared) (bounded : flow.scalars.Bounded)
    (declared : analysis.declared.Bounded) :
    (call.after signatures flow).scalars.Refines analysis.declared ∧
      (call.after signatures flow).scalars.Bounded := by
  obtain ⟨resolved, found, _, _, targets⟩ := call.check_success checked
  simpa only [Call.after, found] using afterTargets_ranges targets refined bounded declared

theorem Call.after_unchanged {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis} {call : Call}
    {identity : Nat} (checked : call.check signatures shape analysis flow booleans = true)
    (readonly : analysis.mutable identity = false) :
    (call.after signatures flow).scalars identity = flow.scalars identity := by
  obtain ⟨resolved, found, _, _, targets⟩ := call.check_success checked
  simpa only [Call.after, found] using afterTargets_unchanged targets readonly

end Silver.ScalarProcedures
