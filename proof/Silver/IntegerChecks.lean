module

public import Silver.IntegerDeclarations

@[expose] public section

/-! Explicit safety schemas for every scalar expression node. A missing name
or unsuccessfully checked operand contributes an impossible obligation rather
than silently removing a parent check. All schemas use decidable endpoint
arithmetic; soundness covers every store represented by the input intervals. -/

namespace Silver.Integer

inductive Obligation
  | range (bounds : Interval)
  | negate (bounds : Interval)
  | add (left right : Interval)
  | subtract (left right : Interval)
  | multiply (left right : Interval)
  | impossible
  deriving DecidableEq, Repr

def Obligation.discharge : Obligation → Bool
  | .range bounds => (checked bounds).safe
  | .negate bounds => (checkedNegate bounds).safe
  | .add left right => (checkedAdd left right).safe
  | .subtract left right => (checkedSubtract left right).safe
  | .multiply left right => (checkedMultiply left right).safe
  | .impossible => false

def Obligation.Valid : Obligation → Prop
  | .range bounds => ∀ value, bounds.Contains value → InRange value
  | .negate bounds => ∀ value, bounds.Contains value → InRange (-value)
  | .add left right => ∀ a b, left.Contains a → right.Contains b → InRange (a + b)
  | .subtract left right => ∀ a b, left.Contains a → right.Contains b → InRange (a - b)
  | .multiply left right => ∀ a b, left.Contains a → right.Contains b → InRange (a * b)
  | .impossible => False

theorem Obligation.discharge_sound {obligation : Obligation} (proved : obligation.discharge = true) :
    obligation.Valid := by
  cases obligation with
  | range => exact fun _ within => (checked_sound proved within).2
  | negate => exact fun _ within => (checkedNegate_sound proved within).2
  | add => exact fun _ _ left right => (checkedAdd_sound proved left right).2
  | subtract => exact fun _ _ left right => (checkedSubtract_sound proved left right).2
  | multiply => exact fun _ _ left right => (checkedMultiply_sound proved left right).2
  | impossible => contradiction

def discharged (obligations : List Obligation) : Bool := obligations.all Obligation.discharge

theorem discharged_append (left right : List Obligation) :
    discharged (left ++ right) = (discharged left && discharged right) := List.all_append

def unaryObligation (constructor : Interval → Obligation) (operand : Option Interval) : Obligation :=
  match operand with | some bounds => constructor bounds | none => .impossible

def binaryObligation (constructor : Interval → Interval → Obligation)
    (left right : Option Interval) : Obligation :=
  match left, right with | some a, some b => constructor a b | _, _ => .impossible

def Expr.obligations (ranges : Ranges) : Expr → List Obligation
  | .literal value => [.range (Interval.singleton value)]
  | .name index => [unaryObligation .range (ranges index)]
  | .positive value | .parenthesized value => value.obligations ranges
  | .negative value => value.obligations ranges ++ [unaryObligation .negate (value.infer ranges)]
  | .add left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .add (left.infer ranges) (right.infer ranges)]
  | .subtract left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .subtract (left.infer ranges) (right.infer ranges)]
  | .multiply left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .multiply (left.infer ranges) (right.infer ranges)]

theorem accepted_isSome (result : CheckResult) : (accepted result).isSome = result.safe := by
  simp only [accepted]; cases result.safe <;> rfl

theorem Expr.obligations_exact (expression : Expr) (ranges : Ranges) :
    discharged (expression.obligations ranges) = (expression.infer ranges).isSome := by
  induction expression with
  | literal value => simp [obligations, infer, discharged, Obligation.discharge, accepted_isSome]
  | name index =>
      cases found : ranges index <;>
        simp [obligations, infer, discharged, Obligation.discharge, unaryObligation, found, accepted_isSome]
  | positive _ ih | parenthesized _ ih => exact ih
  | negative value ih =>
      simp only [obligations, discharged, List.all_append] at ih ⊢
      rw [ih]
      cases found : value.infer ranges <;>
        simp [infer, found, unaryObligation, Obligation.discharge, accepted_isSome]
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr =>
      simp only [obligations, discharged, List.all_append] at ihl ihr ⊢
      rw [ihl, ihr]
      cases hl : left.infer ranges <;> cases hr : right.infer ranges <;>
        simp [infer, hl, hr, binaryObligation, Obligation.discharge, accepted_isSome]

theorem Expr.obligations_discharge {expression : Expr} {ranges : Ranges} {bounds : Interval}
    (admitted : expression.infer ranges = some bounds) :
    discharged (expression.obligations ranges) = true := by
  rw [obligations_exact, admitted]; rfl

theorem Expr.obligations_valid {expression : Expr} {ranges : Ranges} {bounds : Interval}
    (admitted : expression.infer ranges = some bounds) :
    ∀ obligation ∈ expression.obligations ranges, obligation.Valid := by
  have all := List.all_eq_true.mp (Expr.obligations_discharge admitted)
  exact fun obligation present => Obligation.discharge_sound (all obligation present)

def Expr.Admitted (expression : Expr) (ranges : Ranges) : Prop :=
  ∃ bounds, expression.infer ranges = some bounds

instance (expression : Expr) (ranges : Ranges) : Decidable (expression.Admitted ranges) := by
  unfold Expr.Admitted
  cases found : expression.infer ranges with
  | none => exact isFalse (by simp)
  | some bounds => exact isTrue ⟨bounds, rfl⟩

theorem Expr.automatic_discharge_complete {expression : Expr} {ranges : Ranges}
    (admitted : expression.Admitted ranges) :
    discharged (expression.obligations ranges) = true ∧
      ∀ values, Fits ranges values → expression.Safe values ∧
        expression.checkedEvaluate values = some (expression.evaluate values) := by
  obtain ⟨bounds, found⟩ := admitted
  exact ⟨obligations_discharge found, fun values fits =>
    ⟨(infer_sound found fits).2, inferred_execution found fits⟩⟩

def declarationObligations : Constants → List Declaration → List Obligation
  | _, [] => []
  | constants, declaration :: rest => declaration.value.obligations constants.ranges ++
      match declaration.check constants with
      | some next => declarationObligations next rest
      | none => [.impossible]

theorem declaration_obligations_discharge {constants next : Constants} {declarations : List Declaration}
    (checked : checkDeclarations constants declarations = some next) :
    discharged (declarationObligations constants declarations) = true := by
  induction declarations generalizing constants with
  | nil => rfl
  | cons declaration rest ih =>
      simp only [checkDeclarations, Option.bind_eq_some_iff] at checked
      obtain ⟨middle, first, restChecked⟩ := checked
      have inferred : ∃ bounds, declaration.value.infer constants.ranges = some bounds := by
        simp only [Declaration.check, Option.bind_eq_some_iff] at first
        obtain ⟨bounds, found, _⟩ := first
        exact ⟨bounds, found⟩
      obtain ⟨bounds, found⟩ := inferred
      simp only [declarationObligations, first, discharged_append,
        Expr.obligations_discharge found, ih restChecked, Bool.and_self]

theorem declaration_obligations_valid {constants next : Constants} {declarations : List Declaration}
    (checked : checkDeclarations constants declarations = some next) :
    ∀ obligation ∈ declarationObligations constants declarations, obligation.Valid := by
  have all := List.all_eq_true.mp (declaration_obligations_discharge checked)
  exact fun obligation present => Obligation.discharge_sound (all obligation present)

end Silver.Integer
