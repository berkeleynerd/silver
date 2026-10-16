module

public import Silver.IntegerImageNative

@[expose] public section

/-! Typed denotation and token rendering for every operation in the three
native Image length helpers. Calls remain arbitrary until their source
equations and the imported scalar source interpretation determine them. -/
namespace Silver.Integer.Image.Native

inductive Threshold | t10 | t100 | t1000 | t10000 | t100000 | t1000000
  | t10000000 | t100000000 | t1000000000
  deriving DecidableEq

def Threshold.value : Threshold → Nat
  | .t10 => 10 | .t100 => 100 | .t1000 => 1000 | .t10000 => 10000
  | .t100000 => 100000 | .t1000000 => 1000000 | .t10000000 => 10000000
  | .t100000000 => 100000000 | .t1000000000 => 1000000000

def Threshold.spelling : Threshold → String
  | .t10 => "10" | .t100 => "100" | .t1000 => "1_000" | .t10000 => "10_000"
  | .t100000 => "100_000" | .t1000000 => "1_000_000" | .t10000000 => "10_000_000"
  | .t100000000 => "100_000_000" | .t1000000000 => "1_000_000_000"

theorem Threshold.spelling_value (value : Threshold) :
    ((value.spelling.toList.filter (· != '_')).foldl
      (fun total digit => 10 * total + (digit.toNat - '0'.toNat)) 0) = value.value := by
  cases value <;> decide +kernel

theorem Threshold.spelling_digits (value : Threshold) :
    (value.spelling.toList.filter (· != '_')).all Char.isDigit = true := by
  cases value <;> decide +kernel

inductive Ty | signed | length | truth | interval
  deriving DecidableEq

@[reducible] def Ty.meaning : Ty → Type
  | .signed => Int | .length => Nat | .truth => Bool | .interval => Interval

structure Calls where
  lengthOf : Int → Nat
  minimumLength : Interval → Nat
  maximumLength : Interval → Nat
  isEmpty : Interval → Bool

def modelCalls : Calls := ⟨lengthOf, minimumLength, maximumLength, Interval.isEmpty⟩

structure Context where
  item : Int := 0
  bounds : Interval := Interval.empty

inductive Expr : Ty → Type
  | item : Expr .signed
  | bounds : Expr .interval
  | threshold (value : Threshold) : Expr .signed
  | zero : Expr .signed
  | length (value : Nat) : Expr .length
  | lower : Expr .interval → Expr .signed
  | upper : Expr .interval → Expr .signed
  | neg : Expr .signed → Expr .signed
  | gt : Expr .signed → Expr .signed → Expr .truth
  | lt : Expr .signed → Expr .signed → Expr .truth
  | le : Expr .signed → Expr .signed → Expr .truth
  | ge : Expr .signed → Expr .signed → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | ite : Expr .truth → Expr .length → Expr .length → Expr .length
  | elsif : Expr .truth → Expr .length → Expr .length → Expr .length
  | callLength : Expr .signed → Expr .length
  | callEmpty : Expr .interval → Expr .truth
  | min : Expr .length → Expr .length → Expr .length
  | max : Expr .length → Expr .length → Expr .length

def Expr.eval (calls : Calls) (context : Context) : Expr ty → ty.meaning
  | .item => context.item | .bounds => context.bounds
  | .threshold value => value.value | .zero => 0 | .length value => value
  | .lower value => (value.eval calls context).lower
  | .upper value => (value.eval calls context).upper
  | .neg value => -value.eval calls context
  | .gt a b => decide (a.eval calls context > b.eval calls context)
  | .lt a b => decide (a.eval calls context < b.eval calls context)
  | .le a b => decide (a.eval calls context ≤ b.eval calls context)
  | .ge a b => decide (a.eval calls context ≥ b.eval calls context)
  | .andThen a b => a.eval calls context && b.eval calls context
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls context then yes.eval calls context else no.eval calls context
  | .callLength value => calls.lengthOf (value.eval calls context)
  | .callEmpty value => calls.isEmpty (value.eval calls context)
  | .min a b => Min.min (a.eval calls context) (b.eval calls context)
  | .max a b => Max.max (a.eval calls context) (b.eval calls context)

def Expr.render : Expr ty → List String
  | .item => ["item"] | .bounds => ["bounds"]
  | .threshold value => [value.spelling] | .zero => ["0"] | .length value => [toString value]
  | .lower value => value.render ++ [".", "lower"]
  | .upper value => value.render ++ [".", "upper"]
  | .neg value => ["-"] ++ value.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render
  | .le a b => a.render ++ ["<="] ++ b.render
  | .ge a b => a.render ++ [">="] ++ b.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .callLength value => ["length_of", "("] ++ value.render ++ [")"]
  | .callEmpty value => ["silver_scalars", ".", "is_empty", "("] ++ value.render ++ [")"]
  | .min a b => ["image_length", "'", "min", "("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .max a b => ["image_length", "'", "max", "("] ++ a.render ++ [","] ++ b.render ++ [")"]

def withinThreshold (value : Threshold) : Expr .truth :=
  .andThen (.gt .item (.neg (.threshold value))) (.lt .item (.threshold value))

def lengthTail : List (Threshold × Nat) → Expr .length
  | [] => .length 11
  | (limit, result) :: rest => .elsif (withinThreshold limit) (.length result) (lengthTail rest)

def lengthBody : Expr .length :=
  .ite (withinThreshold .t10) (.length 2) (lengthTail
    [(.t100, 3), (.t1000, 4), (.t10000, 5), (.t100000, 6),
     (.t1000000, 7), (.t10000000, 8), (.t100000000, 9), (.t1000000000, 10)])

def minimumBody : Expr .length :=
  .ite (.callEmpty .bounds) (.length 0)
    (.elsif (.andThen (.le (.lower .bounds) .zero) (.ge (.upper .bounds) .zero)) (.length 2)
      (.min (.callLength (.lower .bounds)) (.callLength (.upper .bounds))))

def maximumBody : Expr .length :=
  .ite (.callEmpty .bounds) (.length 0)
    (.max (.callLength (.lower .bounds)) (.callLength (.upper .bounds)))

def Expr.primary : Expr ty → Bool
  | .neg _ | .gt _ _ | .lt _ _ | .le _ _ | .ge _ _ | .andThen _ _
  | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Expr.simple : Expr ty → Bool
  | .neg _ => true | value => value.primary

def Expr.relation : Expr ty → Bool
  | .gt _ _ | .lt _ _ | .le _ _ | .ge _ _ => true | value => value.simple

def Expr.condition : Expr ty → Bool
  | .andThen _ _ => true | value => value.relation

def Expr.isElsif : Expr ty → Bool
  | .elsif _ _ _ => true | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .lower value | .upper value | .neg value => value.wellFormed && value.primary
  | .gt a b | .lt a b | .le a b | .ge a b =>
      a.wellFormed && b.wellFormed && a.simple && b.simple
  | .andThen a b => a.wellFormed && b.wellFormed && a.condition && b.relation
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.condition && yes.wellFormed && yes.simple &&
        no.wellFormed && (no.simple || no.isElsif)
  | .callLength value | .callEmpty value => value.wellFormed && value.simple
  | .min a b | .max a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | _ => true

theorem checked_precedence : lengthBody.wellFormed = true ∧
    minimumBody.wellFormed = true ∧ maximumBody.wellFormed = true := by decide +kernel

private theorem add_conditional (condition : Prop) [Decidable condition] (a b : Nat) :
    1 + (if condition then a else b) = if condition then 1 + a else 1 + b := by
  split <;> rfl

theorem lengthBody_eval (calls : Calls) (item : Int) :
    lengthBody.eval calls {item} = lengthOf item := by
  dsimp +instances only [lengthBody, lengthTail, withinThreshold, Expr.eval, Threshold.value,
    lengthOf, digitTable, selectSigned]
  simp only [Bool.and_eq_true, decide_eq_true_eq, add_conditional]

theorem minimumBody_eval (calls : Calls) (bounds : Interval) :
    minimumBody.eval calls {bounds} =
      if calls.isEmpty bounds then 0
      else if bounds.lower ≤ 0 ∧ 0 ≤ bounds.upper then 2
      else min (calls.lengthOf bounds.lower) (calls.lengthOf bounds.upper) := by
  dsimp +instances only [minimumBody, Expr.eval]
  simp only [Bool.and_eq_true, decide_eq_true_eq]

theorem maximumBody_eval (calls : Calls) (bounds : Interval) :
    maximumBody.eval calls {bounds} =
      if calls.isEmpty bounds then 0 else max (calls.lengthOf bounds.lower) (calls.lengthOf bounds.upper) := rfl

structure Equations (calls : Calls) : Prop where
  length : ∀ item, calls.lengthOf item = lengthBody.eval calls {item}
  minimum : ∀ bounds, calls.minimumLength bounds = minimumBody.eval calls {bounds}
  maximum : ∀ bounds, calls.maximumLength bounds = maximumBody.eval calls {bounds}

structure Meaning (calls : Calls) : Prop where
  length : calls.lengthOf = lengthOf
  minimum : calls.minimumLength = minimumLength
  maximum : calls.maximumLength = maximumLength

theorem equations_meaning (calls : Calls) (source : Equations calls)
    (scalar : calls.isEmpty = Interval.isEmpty) : Meaning calls where
  length := funext fun item => (source.length item).trans (lengthBody_eval calls item)
  minimum := by
    funext bounds
    rw [source.minimum, minimumBody_eval, scalar]
    simp only [minimumLength, source.length, lengthBody_eval]
  maximum := by
    funext bounds
    rw [source.maximum, maximumBody_eval, scalar]
    simp only [maximumLength, source.length, lengthBody_eval]

theorem model_equations : Equations modelCalls where
  length item := (lengthBody_eval modelCalls item).symm
  minimum bounds := by rw [minimumBody_eval]; rfl
  maximum bounds := rfl

end Silver.Integer.Image.Native
