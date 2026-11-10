module

public import Silver.ScalarProcedureExecution

@[expose] public section

namespace Silver.ScalarProcedures
open ScalarFunctions (Target Value State)

def writableTargets : List Actual → List Target
  | [] => []
  | .value _ :: rest => writableTargets rest
  | .target target :: rest => target :: writableTargets rest

@[simp] theorem mem_writableTargets (target : Target) (actuals : List Actual) :
    target ∈ writableTargets actuals ↔ Actual.target target ∈ actuals := by
  induction actuals with
  | nil => simp [writableTargets]
  | cons actual rest ih => cases actual <;> simp [writableTargets, ih]

theorem bindActuals_outputs {formals : List Formal} {actuals : List Actual} {bound : ActualBindings}
    (boundEq : bindActuals formals actuals = some bound) : bound.outputs = writableTargets actuals := by
  induction formals generalizing actuals bound with
  | nil =>
      cases actuals with
      | nil => cases Option.some.inj boundEq; rfl
      | cons => simp [bindActuals] at boundEq
  | cons formal formals ih =>
      cases actuals with
      | nil => simp [bindActuals] at boundEq
      | cons actual actuals =>
          rcases formal with ⟨mode, domain⟩
          cases mode <;> cases actual <;> simp only [bindActuals] at boundEq
          all_goals try contradiction
          all_goals
            obtain ⟨following, boundFollowing, rfl⟩ := Option.map_eq_some_iff.mp boundEq
            simp only [writableTargets, ih boundFollowing]

theorem actualsApart_targets {actuals : List Actual} (apart : actualsApart actuals = true) :
    (writableTargets actuals).Pairwise (fun left right => targetCell left ≠ targetCell right) := by
  induction actuals with
  | nil => exact .nil
  | cons first rest ih =>
      have checks := Bool.and_eq_true_iff.mp apart
      cases first with
      | value value => exact ih checks.2
      | target first =>
          apply List.pairwise_cons.mpr
          refine ⟨?_, ih checks.2⟩
          intro next present
          have check := List.all_eq_true.mp checks.1 (.target next) ((mem_writableTargets next rest).mp present)
          simpa only [Actual.apart, bne_iff_ne] using check

theorem Call.outputs_apart {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {resolved : ResolvedCall}
    (checked : call.check signatures shape analysis flow booleans = true)
    (found : call.resolve signatures = some resolved) :
    resolved.actuals.outputs.Pairwise (fun left right => targetCell left ≠ targetCell right) := by
  obtain ⟨other, otherFound, apart, _, _⟩ := call.check_success checked
  rw [found] at otherFound
  cases Option.some.inj otherFound
  rw [bindActuals_outputs (call.resolve_success found).2]
  exact actualsApart_targets apart

private theorem put_commute {α : Type} (store : Nat → α) {left right : Nat}
    (apart : left ≠ right) (a b : α) :
    Integer.put (Integer.put store left a) right b = Integer.put (Integer.put store right b) left a := by
  funext index
  by_cases first : index = left <;> by_cases second : index = right <;> simp_all [Integer.put]

/-- Distinct typed cells commute even when their numeric indexes coincide in
the independent Integer and Boolean stores. -/
theorem target_write_commute {left right : Target} (apart : targetCell left ≠ targetCell right)
    (a b : Value) (state : State) :
    right.write b (left.write a state) = left.write a (right.write b state) := by
  cases left with
  | integer left bounds =>
      cases right with
      | integer right range =>
          have different : left ≠ right := by intro same; apply apart; cases same; rfl
          cases a <;> cases b <;> simp only [Target.write]
          · exact congrArg (fun store => {state with integers := store}) (put_commute state.integers different _ _)
          all_goals rfl
      | boolean right => cases a <;> cases b <;> rfl
  | boolean left =>
      cases right with
      | integer right range => cases a <;> cases b <;> rfl
      | boolean right =>
          have different : left ≠ right := by intro same; apply apart; cases same; rfl
          cases a <;> cases b <;> simp only [Target.write]
          all_goals try rfl
          exact congrArg (fun store => {state with booleans := store}) (put_commute state.booleans different _ _)

def copyBackPair (state : State) (pair : Target × Value) : State := pair.1.write pair.2 state

theorem copyBack_eq_foldl (targets : List Target) (values : List Value) (state : State) :
    copyBack targets values state = (targets.zip values).foldl copyBackPair state := by
  induction targets generalizing values state with
  | nil => simp [copyBack]
  | cons target targets ih =>
      cases values <;> simp [copyBack, List.zip_cons_cons, copyBackPair, ih]

private theorem zip_targets_apart {targets : List Target}
    (apart : targets.Pairwise (fun left right => targetCell left ≠ targetCell right))
    (values : List Value) :
    (targets.zip values).Pairwise (fun left right => targetCell left.1 ≠ targetCell right.1) := by
  induction targets generalizing values with
  | nil => simp
  | cons target targets ih =>
      cases values with
      | nil => simp
      | cons value values =>
          have both := List.pairwise_cons.mp apart
          apply List.pairwise_cons.mpr
          exact ⟨fun pair present => both.1 pair.1 (List.of_mem_zip present).1, ih both.2 values⟩

/-- Ada may choose any order for copy-back. The checked alias rule proves all
those orders equal to the executable model's formal-order traversal. -/
theorem copyBack_permutation {targets : List Target} {values : List Value}
    (apart : targets.Pairwise (fun left right => targetCell left ≠ targetCell right))
    {order : List (Target × Value)} (permuted : (targets.zip values).Perm order) (state : State) :
    order.foldl copyBackPair state = copyBack targets values state := by
  rw [copyBack_eq_foldl]
  symm
  apply permuted.foldl_eq'
  let commute := fun (left right : Target × Value) => ∀ current,
    copyBackPair (copyBackPair current left) right = copyBackPair (copyBackPair current right) left
  have forward : (targets.zip values).Pairwise commute :=
    (zip_targets_apart apart values).imp (fun distinct current => target_write_commute distinct _ _ current)
  have backward : (targets.zip values).Pairwise (flip commute) :=
    forward.imp (fun same current => (same current).symm)
  intro left present right other current
  exact List.Pairwise.forall_of_forall_of_flip (fun _ _ _ => rfl) forward backward present other current

theorem Call.copyBack_order_independent {signatures : Signatures} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {resolved : ResolvedCall}
    (checked : call.check signatures shape analysis flow booleans = true)
    (found : call.resolve signatures = some resolved)
    (values : List Value) {order : List (Target × Value)}
    (permuted : (resolved.actuals.outputs.zip values).Perm order) (state : State) :
    order.foldl copyBackPair state = copyBack resolved.actuals.outputs values state :=
  copyBack_permutation (call.outputs_apart checked found) permuted state

end Silver.ScalarProcedures
