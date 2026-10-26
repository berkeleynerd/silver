module

public import Silver.ScalarFlow
public import Silver.ScalarExpressionEnvironment

@[expose] public section

/-! Active native scalar storage and its exact projection to the semantic flow.
Native discriminants are represented by list length, including the empty list.
No interval or identity is manufactured outside the active prefix. -/
namespace Silver.Predicate

structure ActiveFlow where
  path : PathFacts.Context
  values : List Integer.Interval
  deriving DecidableEq, Repr

namespace ActiveFlow

def count (flow : ActiveFlow) : Nat := flow.values.length

def ranges (values : List Integer.Interval) : Integer.Ranges := fun index =>
  if index = 0 then none else values[index - 1]?

def model (flow : ActiveFlow) : Flow := ⟨flow.path, ranges flow.values⟩

def initial (names : ScalarExpression.Environment) (path : PathFacts.Context) : ActiveFlow :=
  ⟨path, names.map (·.bounds)⟩

def invalid (flow : ActiveFlow) : ActiveFlow := {flow with path := PathFacts.Context.empty}

def join (left right : ActiveFlow) : ActiveFlow :=
  ⟨left.path.join right.path, List.zipWith Integer.Interval.join left.values right.values⟩

def replace (flow : ActiveFlow) (index : Nat) (bounds : Integer.Interval) : ActiveFlow :=
  if index = 0 then flow else {flow with values := flow.values.set (index - 1) bounds}

def refine (flow : ActiveFlow) (index : Nat) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) : ActiveFlow :=
  match ranges flow.values index with
  | none => flow
  | some bounds => flow.replace index (bounds.refineOrKeep operator threshold truth)

def append (flow : ActiveFlow) (bounds : Integer.Interval) : ActiveFlow :=
  {flow with values := flow.values ++ [bounds]}

def take (flow : ActiveFlow) (count : Nat) : ActiveFlow :=
  {flow with values := flow.values.take count}

@[simp] theorem initial_count (names : ScalarExpression.Environment) (path : PathFacts.Context) :
    (initial names path).count = names.length := by simp [initial, count]

@[simp] theorem invalid_count (flow : ActiveFlow) : flow.invalid.count = flow.count := rfl
@[simp] theorem invalid_values (flow : ActiveFlow) : flow.invalid.values = flow.values := rfl

@[simp] theorem ranges_zero (values : List Integer.Interval) : ranges values 0 = none := by
  simp [ranges]

theorem ranges_inside (values : List Integer.Interval) (index : Nat)
    (positive : 0 < index) (bounded : index ≤ values.length) :
    ranges values index = some values[index - 1] := by
  simp only [ranges, Nat.ne_of_gt positive, ↓reduceIte,
    List.getElem?_eq_getElem (show index - 1 < values.length by omega)]

theorem ranges_outside (values : List Integer.Interval) (index : Nat)
    (outside : index = 0 ∨ values.length < index) : ranges values index = none := by
  rcases outside with rfl | beyond
  · exact ranges_zero values
  · simp only [ranges, show index ≠ 0 by omega, ↓reduceIte,
      List.getElem?_eq_none (show values.length ≤ index - 1 by omega)]

theorem ranges_map_bounds (names : ScalarExpression.Environment) :
    ranges (names.map (·.bounds)) = ScalarExpression.ranges names := by
  funext index
  by_cases active : 0 < index ∧ index ≤ names.length
  · have within : index - 1 < names.length := by omega
    simp only [ranges, show index ≠ 0 by omega, ↓reduceIte, List.getElem?_map,
      Option.map_some, ScalarExpression.ranges, active, and_self, ↓reduceIte,
      ScalarExpression.binding, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem within, Option.getD_some]
  · have outside : index = 0 ∨ (names.map (·.bounds)).length < index := by
      simp only [List.length_map]; omega
    rw [ranges_outside _ _ outside]
    simp only [ScalarExpression.ranges, active, ↓reduceIte]

@[simp] theorem initial_model (names : ScalarExpression.Environment) (path : PathFacts.Context) :
    (initial names path).model = ⟨path, ScalarExpression.ranges names⟩ := by
  simp only [initial, model, ranges_map_bounds]

private theorem lookup_zipWith (left right : List Integer.Interval) (index : Nat) :
    (List.zipWith Integer.Interval.join left right)[index]? =
      match left[index]?, right[index]? with
      | some a, some b => some (a.join b)
      | _, _ => none := by
  induction left generalizing right index with
  | nil => cases right <;> cases index <;> simp [List.zipWith]
  | cons first rest ih =>
    cases right with
    | nil => cases index <;> simp [List.zipWith]
    | cons other tail =>
      cases index with
      | zero => rfl
      | succ index => simpa only [List.zipWith, List.getElem?_cons_succ] using ih tail index

theorem join_model (left right : ActiveFlow) :
    (left.join right).model = left.model.join right.model := by
  unfold join model Flow.join
  congr 1
  funext index
  by_cases zero : index = 0
  · simp only [ranges, zero, ↓reduceIte, Integer.Ranges.join]
  · simp only [ranges, zero, ↓reduceIte, Integer.Ranges.join, lookup_zipWith]
    rfl

theorem ranges_append (values : List Integer.Interval) (bounds : Integer.Interval) :
    ranges (values ++ [bounds]) = Integer.put (ranges values) (values.length + 1) (some bounds) := by
  funext index
  by_cases fresh : index = values.length + 1
  · subst index
    simp [ranges, Integer.put]
  · by_cases active : 0 < index ∧ index ≤ values.length
    · simp only [ranges, show index ≠ 0 by omega, ↓reduceIte,
        List.getElem?_append_left (show index - 1 < values.length by omega), Integer.put,
        fresh, ↓reduceIte]
    · have before : index = 0 ∨ values.length < index := by omega
      have after : index = 0 ∨ (values ++ [bounds]).length < index := by
        simp only [List.length_append, List.length_singleton]; omega
      simp only [ranges_outside _ _ after, Integer.put, fresh, ↓reduceIte,
        ranges_outside _ _ before]

@[simp] theorem append_count (flow : ActiveFlow) (bounds : Integer.Interval) :
    (flow.append bounds).count = flow.count + 1 := by simp [append, count]

theorem append_model (flow : ActiveFlow) (bounds : Integer.Interval) :
    (flow.append bounds).model =
      ⟨flow.path, Integer.put flow.model.scalars (flow.count + 1) (some bounds)⟩ := by
  simp only [append, model, count, ranges_append]

/-- Exact finite storage interpretation of an arbitrary native flow. The
frontend interprets the Count discriminant and its `1 .. Count` array; all
inactive mathematical cells are discarded by this projection. -/
structure Storage where
  count : Nat
  path : PathFacts.Context
  values : Nat → Integer.Interval

def Storage.active (storage : Storage) : ActiveFlow :=
  ⟨storage.path, List.ofFn fun index : Fin storage.count => storage.values (index.val + 1)⟩

@[simp] theorem Storage.active_count (storage : Storage) : storage.active.count = storage.count := by
  simp [Storage.active, ActiveFlow.count]

/-- Equal active fields give equal projected flow; nothing is assumed about
unused cells of a native array interpretation. -/
theorem Storage.active_ext (left right : Storage) (size : left.count = right.count)
    (path : left.path = right.path)
    (cells : ∀ index, 1 ≤ index → index ≤ left.count → left.values index = right.values index) :
    left.active = right.active := by
  cases left with
  | mk leftCount leftPath leftValues =>
    cases right with
    | mk rightCount rightPath rightValues =>
      dsimp only at size path cells
      subst rightCount
      subst rightPath
      unfold Storage.active
      congr 1
      apply congrArg List.ofFn
      funext index
      exact cells (index.val + 1) (Nat.succ_pos _) (Nat.succ_le_of_lt index.isLt)

end ActiveFlow

namespace ScalarMetadata
open ScalarExpression

def staticness (names : Environment) : Integer.Mutability := fun index =>
  decide (0 < index ∧ index ≤ names.length) && (binding names index).isStatic

def refinable (names : Environment) (declarations : Nat) : Integer.Mutability := fun index =>
  decide (0 < index ∧ index ≤ names.length) &&
    ((binding names index).mutable || decide (declarations < index))

/-- Base body metadata already widens mutable bindings to their declared
intervals. Immutable declarations retain snapshots and indexes retain captured
bounds; their current narrowed reads are stored separately. -/
def analysis (names : Environment) (declarations : Nat) : Integer.Analysis :=
  ⟨ranges names, mutability names, staticness names, refinable names declarations⟩

theorem refinable_declarations (names : Environment) :
    refinable names names.length = mutability names := by
  funext index
  by_cases active : 0 < index ∧ index ≤ names.length
  · simp only [refinable, mutability, active,
      show ¬names.length < index by omega, decide_false, Bool.or_false]
  · simp only [refinable, mutability, active, decide_false, Bool.false_and]

def readingBinding (declarations index : Nat) (binding : Binding) (bounds : Integer.Interval) : Binding :=
  if binding.mutable || decide (declarations < index) then {binding with bounds} else binding

@[simp] theorem readingBinding_static (declarations index : Nat) (binding : Binding)
    (bounds : Integer.Interval) : (readingBinding declarations index binding bounds).isStatic = binding.isStatic := by
  unfold readingBinding; split <;> rfl

@[simp] theorem readingBinding_mutable (declarations index : Nat) (binding : Binding)
    (bounds : Integer.Interval) : (readingBinding declarations index binding bounds).mutable = binding.mutable := by
  unfold readingBinding; split <;> rfl

@[simp] theorem readingBinding_declared (declarations index : Nat) (binding : Binding)
    (bounds : Integer.Interval) :
    (readingBinding declarations index binding bounds).declaredBounds = binding.declaredBounds := by
  unfold readingBinding; split <;> rfl

end ScalarMetadata
end Silver.Predicate
