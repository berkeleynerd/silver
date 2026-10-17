module

public import Silver.ScalarExpressionAdmission
public import Silver.IntegerDeclarations

@[expose] public section

/-! Ordered elaboration environments carry exact singleton values. This is
independent of Ada-staticness: a mutable declaration or an immutable snapshot
of it has an exact initial value without becoming a static expression. -/
namespace Silver.ScalarExpression

def ElaboratedEnvironment (names : Environment) : Prop :=
  ∀ item ∈ names, item.bounds.lower = item.bounds.upper

/-- Historical proof API: "static" here means exact during declaration
elaboration. Ada staticness is the independent `Binding.isStatic` flag. -/
abbrev StaticEnvironment := ElaboratedEnvironment

theorem static_empty : StaticEnvironment [] := by simp [StaticEnvironment, ElaboratedEnvironment]

theorem constants_map {names : Environment} (_static : StaticEnvironment names) :
    constants names = names.map (fun item => item.bounds.lower) := rfl

theorem constants_length {names : Environment} (static : StaticEnvironment names) :
    (constants names).length = names.length := by rw [constants_map static, List.length_map]

theorem static_ranges {names : Environment} (static : StaticEnvironment names) :
    ranges names = Integer.Constants.ranges (constants names) := by
  funext index
  rw [constants_map static]
  by_cases zero : index = 0
  · subst index
    simp [ranges, Integer.Constants.ranges, Integer.Constants.get]
  · by_cases inside : index - 1 < names.length
    · have endpoints := static names[index - 1] (List.getElem_mem inside)
      have bounded : 0 < index ∧ index ≤ names.length := by omega
      simp only [ranges, bounded, ↓reduceIte, binding, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem inside, Option.getD_some, Integer.Constants.ranges,
        Integer.Constants.get, zero, List.getElem?_map, Option.map_some]
      cases eq : names[index - 1].bounds with
      | mk lower upper =>
          simp only [eq] at endpoints
          simp only [Integer.Interval.singleton]
          cases endpoints
          rfl
    · have outside : ¬ (0 < index ∧ index ≤ names.length) := by omega
      simp [ranges, outside, Integer.Constants.ranges, Integer.Constants.get, zero,
        List.getElem?_map, List.getElem?_eq_none (by omega : names.length ≤ index - 1)]

theorem static_append {names : Environment} {item : Binding}
    (static : StaticEnvironment names) (_fixed : item.isStatic = true)
    (singleton : item.bounds.lower = item.bounds.upper) :
    StaticEnvironment (names ++ [item]) := by
  intro other member
  rcases List.mem_append.mp member with before | after
  · exact static other before
  · have same := List.mem_singleton.mp after
    simpa only [same] using singleton

theorem elaborated_append {names : Environment} {item : Binding}
    (exact : ElaboratedEnvironment names)
    (singleton : item.bounds.lower = item.bounds.upper) :
    ElaboratedEnvironment (names ++ [item]) := by
  intro other member
  rcases List.mem_append.mp member with before | after
  · exact exact other before
  · simpa only [List.mem_singleton.mp after] using singleton

theorem constants_append {names : Environment} {item : Binding}
    (_fixed : item.isStatic = true) (_singleton : item.bounds.lower = item.bounds.upper) :
    constants (names ++ [item]) = constants names ++ [item.bounds.lower] := by
  simp [constants]

private theorem checked_singleton {value : Int} {bounds : Integer.Interval}
    (found : Integer.accepted (Integer.checked (.singleton value)) = some bounds) :
    bounds = .singleton value := by
  have nonempty : (Integer.Interval.singleton value).isEmpty = false := by
    simp [Integer.Interval.isEmpty, Integer.Interval.singleton]
  by_cases bounded : (Integer.Interval.singleton value).Bounded
  · simp only [Integer.checked, nonempty, Bool.false_eq_true, ↓reduceIte, bounded,
      Integer.accepted, Option.some.injEq] at found
    exact found.symm
  · simp only [Integer.checked, nonempty, Bool.false_eq_true, ↓reduceIte, bounded,
      Integer.accepted] at found
    contradiction

private theorem infer_singleton {ranges : Integer.Ranges} {expression : Integer.Expr}
    {bounds : Integer.Interval}
    (singletons : ∀ index interval, ranges index = some interval → interval.lower = interval.upper)
    (found : expression.infer ranges = some bounds) : bounds.lower = bounds.upper := by
  induction expression generalizing bounds with
  | literal value =>
      have same := checked_singleton found
      simp [same, Integer.Interval.singleton]
  | name index =>
      simp only [Integer.Expr.infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, present, checked⟩ := found
      have equal := singletons index interval present
      have singleton : interval = .singleton interval.lower := by
        cases interval; simp_all [Integer.Interval.singleton]
      rw [singleton] at checked
      have same := checked_singleton checked
      simp [same, Integer.Interval.singleton]
  | positive value ih | parenthesized value ih => exact ih found
  | negative value ih =>
      simp only [Integer.Expr.infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, inferred, checked⟩ := found
      have equal := ih inferred
      have reduced : Integer.checkedNegate interval = Integer.checked (.singleton (-interval.lower)) := by
        simp [Integer.checkedNegate, Integer.Interval.isEmpty, Integer.Interval.negate,
          Integer.Interval.singleton, ← equal]
      rw [reduced] at checked
      have same := checked_singleton checked
      simp [same, Integer.Interval.singleton]
  | add left right il ir | subtract left right il ir | multiply left right il ir =>
      simp only [Integer.Expr.infer, Option.bind_eq_some_iff] at found
      obtain ⟨a, leftFound, b, rightFound, checked⟩ := found
      have leftEqual := il leftFound
      have rightEqual := ir rightFound
      simp only [Integer.checkedAdd, Integer.checkedSubtract, Integer.checkedMultiply,
        Integer.Interval.isEmpty, ← leftEqual, ← rightEqual, Int.lt_irrefl,
        decide_false, Bool.false_or, Bool.false_eq_true, ↓reduceIte,
        Integer.Interval.add, Integer.Interval.subtract, Integer.Interval.multiply,
        Int.min_self, Int.max_self] at checked
      have same := checked_singleton checked
      simp [same, Integer.Interval.singleton]

theorem static_inference {names : Environment} {expression : Integer.Expr}
    {bounds : Integer.Interval} (static : StaticEnvironment names)
    (found : expression.infer (ranges names) = some bounds) : bounds.lower = bounds.upper := by
  apply infer_singleton (found := found)
  intro index interval present
  rw [static_ranges static] at present
  simp only [Integer.Constants.ranges, Option.map_eq_some_iff] at present
  obtain ⟨value, _, rfl⟩ := present
  rfl

end Silver.ScalarExpression
