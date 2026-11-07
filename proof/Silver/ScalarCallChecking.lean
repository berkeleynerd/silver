module

public import Silver.ScalarCallSyntax
public import Silver.PredicateChecking

@[expose] public section

namespace Silver.ScalarFunctions

/-- Check an actual in the caller's incoming flow. A formal range never
narrows the expression being checked to make its evaluation safe. -/
def Actual.check (shape : Bindings.Shape) (analysis : Integer.Analysis)
    (flow : Predicate.Flow) (booleans : Boolean.Analysis)
    (formal : ScalarType) (actual : Actual) : Bool :=
  match formal, actual with
  | .integer target, .integer expression =>
      match expression.infer flow.scalars with
      | some bounds => !bounds.isEmpty && bounds.included target
      | none => false
  | .boolean, .boolean condition => condition.checkBounds shape analysis flow booleans
  | _, _ => false

/-- Every actual uses precisely the same flow, including after a Boolean
actual. Only short circuiting within that actual has ordinary refinement. -/
def checkActuals (shape : Bindings.Shape) (analysis : Integer.Analysis)
    (flow : Predicate.Flow) (booleans : Boolean.Analysis) :
    List ScalarType → List Actual → Bool
  | [], [] => true
  | formal :: formals, actual :: actuals =>
      actual.check shape analysis flow booleans formal &&
        checkActuals shape analysis flow booleans formals actuals
  | _, _ => false

def Call.check (signatures : Signatures) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow)
    (booleans : Boolean.Analysis) (call : Call) : Option ScalarType :=
  (lookup signatures call.callee).bind fun signature =>
    if checkActuals shape analysis flow booleans signature.formals call.actuals
    then some signature.result else none

theorem Call.check_success {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {result : ScalarType}
    (checked : call.check signatures shape analysis flow booleans = some result) :
    ∃ signature, lookup signatures call.callee = some signature ∧
      checkActuals shape analysis flow booleans signature.formals call.actuals = true ∧
      signature.result = result := by
  simp only [Call.check, Option.bind_eq_some_iff] at checked
  obtain ⟨signature, found, checked⟩ := checked
  split at checked
  · exact ⟨signature, found, by assumption, Option.some.inj checked⟩
  · contradiction

/-- An accepted call refers strictly inside the already checked prefix. -/
theorem Call.check_callee_bound {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {result : ScalarType}
    (checked : call.check signatures shape analysis flow booleans = some result) :
    0 < call.callee ∧ call.callee ≤ signatures.length := by
  obtain ⟨signature, found, _, _⟩ := call.check_success checked
  have positive := lookup_nonzero found
  simp only [lookup, positive, ↓reduceIte] at found
  have within := (List.getElem?_eq_some_iff.mp found).1
  omega

def Target.check (analysis : Integer.Analysis) (booleans : Boolean.Analysis)
    (result : ScalarType) (target : Target) : Bool :=
  match target, result with
  | .integer identity declared, .integer bounds =>
      analysis.mutable identity &&
        match analysis.declared identity with
        | some targetBounds => decide (declared = targetBounds) &&
            (!bounds.isEmpty && bounds.included targetBounds)
        | none => false
  | .boolean identity, .boolean => booleans.canWrite identity
  | _, _ => false

def Assignment.check (signatures : Signatures) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow)
    (booleans : Boolean.Analysis) (assignment : Assignment) : Bool :=
  match assignment.call.check signatures shape analysis flow booleans with
  | some result => assignment.target.check analysis booleans result
  | none => false

theorem Assignment.check_success {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {assignment : Assignment}
    (checked : assignment.check signatures shape analysis flow booleans = true) :
    ∃ result, assignment.call.check signatures shape analysis flow booleans = some result ∧
      assignment.target.check analysis booleans result = true := by
  cases found : assignment.call.check signatures shape analysis flow booleans with
  | none => simp [Assignment.check, found] at checked
  | some result => exact ⟨result, rfl, by simpa only [Assignment.check, found] using checked⟩

def Target.after (result : ScalarType) (flow : Predicate.Flow) : Target → Predicate.Flow
  | .integer identity _ =>
      match result with
      | .integer bounds => {flow with scalars := Integer.put flow.scalars identity (some bounds)}
      | .boolean => flow
  | .boolean _ => flow

@[simp] theorem Target.after_path (target : Target) (result : ScalarType) (flow : Predicate.Flow) :
    (target.after result flow).path = flow.path := by
  cases target <;> cases result <;> rfl

/-- The declared callee result interval is the complete exported fact. Boolean
results carry no facts about the arguments or the function body. -/
def Assignment.after (signatures : Signatures) (flow : Predicate.Flow)
    (assignment : Assignment) : Predicate.Flow :=
  match lookup signatures assignment.call.callee with
  | some signature => assignment.target.after signature.result flow
  | none => flow

theorem Assignment.after_checked {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {assignment : Assignment} {result : ScalarType}
    (checked : assignment.call.check signatures shape analysis flow booleans = some result) :
    assignment.after signatures flow = assignment.target.after result flow := by
  obtain ⟨signature, found, _, rfl⟩ := assignment.call.check_success checked
  simp only [Assignment.after, found]

@[simp] theorem Assignment.after_path (signatures : Signatures) (flow : Predicate.Flow)
    (assignment : Assignment) : (assignment.after signatures flow).path = flow.path := by
  unfold after
  split
  · exact Target.after_path ..
  · rfl

@[simp] theorem Assignment.boolean_after (signatures : Signatures) (flow : Predicate.Flow)
    (identity : Nat) (call : Call) :
    (Assignment.mk (.boolean identity) call).after signatures flow = flow := by
  unfold after
  split <;> rfl

theorem Target.integer_check {identity : Nat} {target result : Integer.Interval}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    (checked : (Target.integer identity target).check analysis booleans (.integer result) = true) :
    analysis.mutable identity = true ∧ analysis.declared identity = some target ∧
      result.isEmpty = false ∧ result.included target = true := by
  simp only [Target.check, Bool.and_eq_true] at checked
  cases found : analysis.declared identity with
  | none => simp [found] at checked
  | some bounds =>
      have compatible : target = bounds ∧ result.isEmpty = false ∧ result.included bounds = true := by
        simpa only [found, Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true'] using checked.2
      obtain ⟨rfl, nonempty, included⟩ := compatible
      exact ⟨checked.1, rfl, nonempty, included⟩

theorem Assignment.after_ranges {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {assignment : Assignment}
    (checked : assignment.check signatures shape analysis flow booleans = true)
    (refined : flow.scalars.Refines analysis.declared) (bounded : flow.scalars.Bounded)
    (declared : analysis.declared.Bounded) :
    (assignment.after signatures flow).scalars.Refines analysis.declared ∧
      (assignment.after signatures flow).scalars.Bounded := by
  obtain ⟨result, callChecked, targetChecked⟩ := assignment.check_success checked
  rw [assignment.after_checked callChecked]
  cases targetEq : assignment.target with
  | boolean identity => exact ⟨refined, bounded⟩
  | integer identity target =>
      rw [targetEq] at targetChecked
      cases result with
      | boolean => simp [Target.check] at targetChecked
      | integer result =>
          obtain ⟨_, present, nonempty, included⟩ := Target.integer_check targetChecked
          have ordered : result.lower ≤ result.upper := by
            simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
            omega
          have resultBounded : result.Bounded :=
            ⟨Integer.Interval.bounded_contains (declared _ _ present)
                (Integer.Interval.included_sound included ⟨Int.le_refl _, ordered⟩),
              Integer.Interval.bounded_contains (declared _ _ present)
                (Integer.Interval.included_sound included ⟨ordered, Int.le_refl _⟩)⟩
          refine ⟨?_, Integer.Ranges.put_bounded bounded resultBounded⟩
          intro other interval found
          by_cases same : other = identity
          · subst other
            rw [present] at found
            cases found
            exact ⟨result, by simp [Target.after, Integer.put],
              fun _ within => Integer.Interval.included_sound included within⟩
          · obtain ⟨old, known, subset⟩ := refined other interval found
            exact ⟨old, by simpa only [Target.after, Integer.put, same, ↓reduceIte] using known, subset⟩

theorem Assignment.after_unchanged {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {assignment : Assignment} {identity : Nat}
    (checked : assignment.check signatures shape analysis flow booleans = true)
    (readonly : analysis.mutable identity = false) :
    (assignment.after signatures flow).scalars identity = flow.scalars identity := by
  obtain ⟨result, callChecked, targetChecked⟩ := assignment.check_success checked
  rw [assignment.after_checked callChecked]
  cases targetEq : assignment.target with
  | boolean index => rfl
  | integer index bounds =>
      rw [targetEq] at targetChecked
      cases result with
      | boolean => rfl
      | integer result =>
          have writable := (Target.integer_check targetChecked).1
          have other : identity ≠ index := by
            intro same
            rw [← same, readonly] at writable
            contradiction
          simp only [Target.after, Integer.put, other, ↓reduceIte]

end Silver.ScalarFunctions
