module

public import Silver.ScalarsNativeExpressions

@[expose] public section

namespace Silver.Integer.Native
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

theorem Function.model_denotation (fn : Function) : Function.interpret Function.eval fn = fn.eval := by
  cases fn <;> try rfl
  all_goals funext
  all_goals simp only [Function.interpret, containsBody, intersectBody, belowBody, aboveBody,
    inRangeBody, checkedBody, Expr.eval, Context.locals, Function.eval, BoundConstant.value,
    decide_eq_true_eq, Bool.and_eq_true]
  all_goals try rfl
  case contains =>
    exact (Bool.decide_and _ _).symm
  case inRange =>
    exact (Bool.decide_and _ _).symm
  case intersect =>
    simp only [Interval.intersect, Interval.normalize, Interval.isEmpty, decide_eq_true_eq]
    split <;> split <;> first | rfl | omega
  case checked =>
    simp only [Silver.Integer.checked, Interval.isEmpty, Interval.Bounded, decide_eq_true_eq]
    rfl


/-- Source calls remain arbitrary until the acyclic body equations determine them. -/
theorem Function.interpret_eq (calls : Calls) (fn : Function)
    (prior : ∀ dependency, dependency.rank < fn.rank → calls dependency = dependency.eval) :
    Function.interpret calls fn = fn.eval := by
  have same : Function.interpret calls fn = Function.interpret Function.eval fn := by
    cases fn with
    | isEmpty =>
        rfl
    | contains =>
        rfl
    | singleton =>
        rfl
    | normalize =>
        simp only [Function.interpret, normalizeBody, Expr.eval, prior .isEmpty (by decide)] <;> rfl
    | join =>
        simp only [Function.interpret, joinBody, Expr.eval, prior .isEmpty (by decide), prior .normalize (by decide)] <;> rfl
    | intersect =>
        simp only [Function.interpret, intersectBody, Expr.eval, prior .normalize (by decide)] <;> rfl
    | compare =>
        rfl
    | complement =>
        rfl
    | swap =>
        rfl
    | below =>
        simp only [Function.interpret, belowBody, Expr.eval, prior .intersect (by decide)] <;> rfl
    | above =>
        simp only [Function.interpret, aboveBody, Expr.eval, prior .intersect (by decide)] <;> rfl
    | refineTrue =>
        simp only [Function.interpret, refineTrueBody, Expr.eval, prior .intersect (by decide), prior .singleton (by decide), prior .join (by decide), prior .below (by decide), prior .above (by decide)] <;> rfl
    | refine =>
        simp only [Function.interpret, refineBody, Expr.eval, prior .refineTrue (by decide), prior .complement (by decide)] <;> rfl
    | inRange =>
        rfl
    | checked =>
        simp only [Function.interpret, checkedBody, Expr.eval, prior .inRange (by decide)] <;> rfl
    | add =>
        simp only [Function.interpret, addBody, Expr.eval, prior .isEmpty (by decide), prior .checked (by decide)] <;> rfl
    | subtract =>
        simp only [Function.interpret, subtractBody, Expr.eval, prior .isEmpty (by decide), prior .checked (by decide)] <;> rfl
    | negate =>
        simp only [Function.interpret, negateBody, Expr.eval, prior .isEmpty (by decide), prior .checked (by decide)] <;> rfl
    | productMinimum =>
        rfl
    | productMaximum =>
        rfl
    | multiply =>
        simp only [Function.interpret, multiplyBody, Expr.eval, prior .isEmpty (by decide), prior .checked (by decide), prior .productMinimum (by decide), prior .productMaximum (by decide)] <;> rfl
  exact same.trans (Function.model_denotation fn)

structure Equations (calls : Calls) : Prop where
  body : ∀ fn, calls fn = Function.interpret calls fn

theorem interpreted_functions (calls : Calls) (equations : Equations calls) (fn : Function) :
    calls fn = fn.eval := by
  apply Nat.strongRecOn (motive := fun rank => ∀ fn, fn.rank = rank → calls fn = fn.eval) fn.rank
  · intro rank ih item same
    rw [equations.body]
    apply Function.interpret_eq
    intro dependency lower
    exact ih dependency.rank (by omega) dependency rfl
  · rfl

theorem model_equations : Equations Function.eval where
  body fn := (Function.model_denotation fn).symm

end Silver.Integer.Native
