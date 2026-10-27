module

public import Silver.IntegerMutable

@[expose] public section

/-! The projected scalar declaration store need not carry array storage.
An initializer containing indexing is frozen to its exact elaboration value,
with a nonstatic tag. Raw source expressions and all their obligations remain
in the separate declaration trace; this projection does not replace them. -/
namespace Silver.Integer

def Expr.hasArray : Expr → Bool
  | .literal _ | .snapshot _ | .name _ => false
  | .indexed _ _ => true
  | .positive inner | .negative inner | .parenthesized inner => inner.hasArray
  | .add left right | .subtract left right | .multiply left right
  | .divide left right | .modulo left right | .remainder left right =>
      left.hasArray || right.hasArray

def Expr.freezeArrays (values : Store) (expression : Expr) : Expr :=
  if expression.hasArray then .snapshot (expression.evaluate values) else expression

theorem Expr.freezeArrays_evaluate (values : Store) (expression : Expr) :
    (expression.freezeArrays values).evaluate values = expression.evaluate values := by
  simp only [freezeArrays]
  split <;> rfl

theorem Expr.freezeArrays_safe {values : Store} {expression : Expr} (safe : expression.Safe values) :
    (expression.freezeArrays values).Safe values := by
  unfold freezeArrays
  split
  · exact Expr.safe_value safe
  · exact safe

theorem Expr.hasArray_nonstatic {expression : Expr} {names : Mutability}
    (indexed : expression.hasArray = true) : expression.isStatic names = false := by
  induction expression with
  | literal | snapshot | name => contradiction
  | indexed => rfl
  | positive _ ih | negative _ ih | parenthesized _ ih => exact ih indexed
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
      simp only [hasArray, Bool.or_eq_true] at indexed
      rcases indexed with a | b
      · simp only [isStatic, ihl a, Bool.false_and]
      · simp only [isStatic, ihr b, Bool.and_false]

theorem Expr.freezeArrays_static (values : Store) (expression : Expr) (names : Mutability) :
    (expression.freezeArrays values).isStatic names = expression.isStatic names := by
  unfold freezeArrays
  split
  · rename_i indexed
    simp only [isStatic, hasArray_nonstatic indexed]
  · rfl

/-- A general scalar-only expression can compare two environments without an
assumption about unrelated array cells. The source grammar derives the name
predicate from resolved binding identities. -/
def Expr.ReadsOnly (allowed : Nat → Prop) : Expr → Prop
  | .literal _ | .snapshot _ => True
  | .name index => allowed index
  | .indexed _ _ => False
  | .positive inner | .negative inner | .parenthesized inner => inner.ReadsOnly allowed
  | .add left right | .subtract left right | .multiply left right
  | .divide left right | .modulo left right | .remainder left right =>
      left.ReadsOnly allowed ∧ right.ReadsOnly allowed

theorem Expr.infer_readsOnly {expression : Expr} {allowed : Nat → Prop} {left right : Ranges}
    (reads : expression.ReadsOnly allowed) (same : ∀ index, allowed index → left index = right index) :
    expression.infer left = expression.infer right := by
  induction expression with
  | literal | snapshot => rfl
  | name index => simp only [infer, same index reads]
  | indexed => contradiction
  | positive _ ih | negative _ ih | parenthesized _ ih => simp only [infer, ih reads]
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr
  | divide _ _ ihl ihr | modulo _ _ ihl ihr | remainder _ _ ihl ihr =>
      simp only [infer, ihl reads.1, ihr reads.2]

theorem Expr.evaluate_readsOnly {expression : Expr} {allowed : Nat → Prop} {left right : Store}
    (reads : expression.ReadsOnly allowed) (same : ∀ index, allowed index → left index = right index) :
    expression.evaluate left = expression.evaluate right := by
  induction expression with
  | literal | snapshot => rfl
  | name index => exact same index reads
  | indexed => contradiction
  | positive _ ih | negative _ ih | parenthesized _ ih => simp only [evaluate, ih reads]
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr
  | divide _ _ ihl ihr | modulo _ _ ihl ihr | remainder _ _ ihl ihr =>
      simp only [evaluate, ihl reads.1, ihr reads.2]

/-- The exact root interval is already required by declaration admission.
This theorem retains it after freezing; the scalar-only case explicitly needs
the source-derived agreement of the two scalar environments. -/
theorem Expr.freezeArrays_infer {expression : Expr} {raw projected : Ranges} {values : Store} {value : Int}
    (inferred : expression.infer raw = some (Interval.singleton value)) (fits : Fits raw values)
    (plain : expression.hasArray = false → expression.infer projected = expression.infer raw) :
    (expression.freezeArrays values).infer projected = some (Interval.singleton value) := by
  unfold freezeArrays
  split
  · have sound := Expr.infer_sound inferred fits
    have exactValue := (Interval.singleton_contains _ _).mp sound.1
    have safe : InRange value := by simpa only [exactValue] using Expr.safe_value sound.2
    have bounded : (Interval.singleton value).Bounded := ⟨safe, safe⟩
    have nonempty : (Interval.singleton value).isEmpty = false := by
      simp [Interval.isEmpty, Interval.singleton]
    simp only [infer, exactValue, accepted, checked, nonempty, Bool.false_eq_true, ↓reduceIte, bounded]
  · rename_i noArray
    have absent : expression.hasArray = false := by simpa using noArray
    exact (plain absent).trans inferred

end Silver.Integer
