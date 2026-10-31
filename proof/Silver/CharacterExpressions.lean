module

public import Silver.StringIndexing

@[expose] public section

/-! Character values use their enumeration position, and String cells contain
lists of these bytes. Source typing supplies the distinction between a scalar
Character reference and a String reference; this module checks singleton
storage and every component index independently of path reachability. -/
namespace Silver.Character

abbrev Lengths := Nat → Option Nat
abbrev Values := Nat → Source

def Fits (lengths : Lengths) (values : Values) : Prop :=
  ∀ index length, lengths index = some length →
    (values index).length = length ∧ ∀ byte ∈ values index, Output.printable byte = true

inductive Expr
  | literal (byte : Nat)
  | reference (index : Nat)
  | indexed (target : Nat) (baseLower : Int) (index : Integer.Expr)
  | parenthesized (inner : Expr)
  deriving DecidableEq, Repr

def Expr.evaluate (values : Values) (integers : Integer.Store) : Expr → Nat
  | .literal byte => byte
  | .reference index => (values index).headD 32
  | .indexed target base index => StringIndexing.read (values target) base (index.evaluate integers)
  | .parenthesized inner => inner.evaluate values integers

def Expr.Readable (lengths : Lengths) : Expr → Prop
  | .literal _ => True
  | .reference index => lengths index = some 1
  | .indexed target _ _ => ∃ length, lengths target = some length
  | .parenthesized inner => inner.Readable lengths

def Expr.PrintableLiterals : Expr → Prop
  | .literal byte => Output.printable byte = true
  | .reference _ | .indexed _ _ _ => True
  | .parenthesized inner => inner.PrintableLiterals

def Expr.check (lengths : Lengths) (ranges : Integer.Ranges) : Expr → Bool
  | .literal byte => Output.printable byte
  | .reference index => decide (lengths index = some 1)
  | .indexed target base index =>
      match lengths target, index.infer ranges with
      | some length, some indices => StringIndexing.indexCheck base length indices
      | _, _ => false
  | .parenthesized inner => inner.check lengths ranges

def Expr.Safe (values : Values) (integers : Integer.Store) : Expr → Prop
  | .literal _ | .reference _ => True
  | .indexed target base index => index.Safe integers ∧
      StringIndexing.indexValid base (values target).length (index.evaluate integers)
  | .parenthesized inner => inner.Safe values integers

def Expr.checkedEvaluate (values : Values) (integers : Integer.Store) : Expr → Option Nat
  | .literal byte => some byte
  | .reference index => some ((values index).headD 32)
  | .indexed target base index => (index.checkedEvaluate integers).bind fun position =>
      if StringIndexing.indexValid base (values target).length position
      then some (StringIndexing.read (values target) base position) else none
  | .parenthesized inner => inner.checkedEvaluate values integers

theorem Expr.check_readable {expression : Expr} {lengths : Lengths} {ranges : Integer.Ranges}
    (checked : expression.check lengths ranges = true) : expression.Readable lengths := by
  induction expression with
  | literal => trivial
  | reference => simpa only [check, Readable, decide_eq_true_eq] using checked
  | indexed target base index =>
      simp only [check] at checked
      split at checked
      · exact ⟨_, by assumption⟩
      · contradiction
  | parenthesized inner ih => exact ih checked

theorem Expr.check_literals {expression : Expr} {lengths : Lengths} {ranges : Integer.Ranges}
    (checked : expression.check lengths ranges = true) : expression.PrintableLiterals := by
  induction expression with
  | literal => exact checked
  | reference | indexed => trivial
  | parenthesized inner ih => exact ih checked

theorem Expr.check_safe {expression : Expr} {lengths : Lengths} {ranges : Integer.Ranges}
    {values : Values} {integers : Integer.Store}
    (checked : expression.check lengths ranges = true)
    (strings : Fits lengths values) (scalars : Integer.Fits ranges integers) :
    expression.Safe values integers := by
  induction expression with
  | literal | reference => trivial
  | indexed target base index =>
      simp only [check] at checked
      split at checked
      · rename_i length indices targetFound indexFound
        have inferred := Integer.Expr.infer_sound indexFound scalars
        refine ⟨inferred.2, ?_⟩
        rw [(strings target length targetFound).1]
        exact StringIndexing.indexCheck_sound checked inferred.1
      · contradiction
  | parenthesized inner ih => exact ih checked

theorem Expr.printable {expression : Expr} {lengths : Lengths} {values : Values}
    (readable : expression.Readable lengths) (literals : expression.PrintableLiterals)
    (strings : Fits lengths values) (integers : Integer.Store) :
    Output.printable (expression.evaluate values integers) = true := by
  induction expression with
  | literal => exact literals
  | reference index =>
      have known := strings index 1 readable
      cases actual : values index with
      | nil => simp [evaluate, actual, Output.printable]
      | cons head tail => simpa only [evaluate, actual, List.headD_cons] using known.2 head (by simp [actual])
  | indexed target base index =>
      obtain ⟨length, found⟩ := readable
      exact StringIndexing.read_printable (strings target length found).2
  | parenthesized inner ih => exact ih readable literals

theorem Expr.checkedEvaluate_agrees {expression : Expr} {values : Values} {integers : Integer.Store}
    (safe : expression.Safe values integers) :
    expression.checkedEvaluate values integers = some (expression.evaluate values integers) := by
  induction expression with
  | literal | reference => rfl
  | indexed target base index =>
      simp only [checkedEvaluate, Integer.Expr.checkedEvaluate_agrees safe.1,
        Option.bind_some, safe.2, ↓reduceIte, evaluate]
  | parenthesized inner ih => exact ih safe

def Expr.freeze (integers : Integer.Store) : Expr → Expr
  | .indexed target base index => .indexed target base (.snapshot (index.evaluate integers))
  | .parenthesized inner => .parenthesized (inner.freeze integers)
  | expression => expression

theorem Expr.freeze_evaluate (expression : Expr) (values : Values) (before after : Integer.Store) :
    (expression.freeze before).evaluate values after = expression.evaluate values before := by
  induction expression with
  | literal | reference | indexed => rfl
  | parenthesized inner ih => exact ih

theorem Expr.freeze_readable {expression : Expr} {lengths : Lengths}
    (readable : expression.Readable lengths) (integers : Integer.Store) :
    (expression.freeze integers).Readable lengths := by
  induction expression with
  | literal | reference | indexed => exact readable
  | parenthesized inner ih => exact ih readable

theorem Expr.freeze_literals {expression : Expr}
    (literals : expression.PrintableLiterals) (integers : Integer.Store) :
    (expression.freeze integers).PrintableLiterals := by
  induction expression with
  | literal | reference | indexed => exact literals
  | parenthesized inner ih => exact ih literals

theorem Expr.freeze_safe {expression : Expr} {values : Values} {before : Integer.Store}
    (safe : expression.Safe values before) (after : Integer.Store) :
    (expression.freeze before).Safe values after := by
  induction expression with
  | literal | reference => trivial
  | indexed target base index => exact ⟨Integer.Expr.safe_value safe.1, safe.2⟩
  | parenthesized inner ih => exact ih safe

end Silver.Character
