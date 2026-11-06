module

public import Silver.ComposeContracts
public import Silver.ComposeStringPrimitiveEquations

@[expose] public section

namespace Silver.Compose.Expressions
open Named
variable {domain : StateDomain}
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

@[simp] theorem interpreted_skip (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .skip text position = skipAt text position := by
  rw [equations.skip text valid position bound]
  dsimp +instances only [skipBody, Expr.eval, Context.locals, lexical, modelPrimitives, skipAt]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_name (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .nameAfter text position = nameAfter text position := by
  rw [equations.name text valid position bound]
  dsimp +instances only [nameBody, Expr.eval, Context.locals, lexical, modelPrimitives, nameAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_fixed (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .fixedAfter text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.fixed text valid position token bound tokenValid]
  dsimp +instances only [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_take (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .takeToken text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.take text valid position token bound tokenValid]
  dsimp +instances only [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]
  simp only [decide_eq_true_eq]

@[simp] theorem interpreted_literal (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .literal text position = literalAt text position := by
  rw [equations.literal text valid position bound]
  dsimp +instances only [literalBody, Expr.eval, Context.locals, lexical, modelPrimitives, literalAt]
  simp only [Bool.and_eq_true, and_assoc, decide_eq_true_eq]
  rfl

@[simp] theorem interpreted_lookupFrom (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (first after index : Nat)
    (namesValid : NativeNames text names) (nameValid : ValidName text first after)
    (positive : 1 ≤ index) (bounded : index ≤ names.length + 1) :
    calls.function .lookupFrom text names first after index = lookupFrom text names first after index := by
  rw [equations.lookupFrom text valid names first after index namesValid nameValid positive bounded,
    lookupFrom_equation text names first after index (by omega)]
  dsimp +instances only [lookupFromBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get]
  simp only [decide_eq_true_eq]
  split
  · rfl
  · rename_i within
    have nextBound : index + 1 ≤ names.length + 1 := Nat.add_le_add_right (Nat.le_of_not_gt within) 1
    split
    · rfl
    · exact interpreted_lookupFrom calls equations text valid names first after (index + 1)
        namesValid nameValid (by omega) nextBound
termination_by names.length + 1 - index
decreasing_by omega

@[simp] theorem interpreted_lookup (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (first after : Nat)
    (namesValid : NativeNames text names) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .lookupName text names first after = lookupName text names first after := by
  rw [equations.lookup text valid names first after namesValid firstValid afterValid]
  dsimp +instances only [lookupBody, Expr.eval, Context.locals, lexical, Calls.get, lookupName]
  simp only [Bool.or_eq_true, decide_eq_true_eq]
  split
  · rfl
  · rename_i outside
    have firstPositive : 0 < first := Nat.pos_of_ne_zero (fun zero => outside (Or.inl zero))
    have afterGreater : first < after := Nat.lt_of_not_ge (fun low => outside (Or.inr low))
    apply interpreted_lookupFrom calls equations text valid names first after 1 namesValid
        (by exact ⟨firstPositive, afterGreater, afterValid⟩) (by omega) (by omega)


end Silver.Compose.Expressions
