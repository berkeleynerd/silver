module

public import Silver.IntegerMutable

@[expose] public section

/-! Explicit safety schemas for every scalar expression node. A missing name
or unsuccessfully checked operand contributes an impossible obligation rather
than silently removing a parent check. All schemas use decidable endpoint
arithmetic; soundness covers every store represented by the input intervals. -/

namespace Silver.Integer

inductive Obligation
  | range (bounds : Interval)
  | arrayIndex (array : ArrayDescriptor) (indices : Interval)
  | arrayLength (actual expected : Nat)
  | negate (bounds : Interval)
  | add (left right : Interval)
  | subtract (left right : Interval)
  | multiply (left right : Interval)
  | divide (left right : Interval)
  | modulo (left right : Interval)
  | remainder (left right : Interval)
  | within (value target : Interval)
  | impossible
  deriving DecidableEq, Repr

def Obligation.discharge : Obligation → Bool
  | .range bounds => (checked bounds).safe
  | .arrayIndex array indices => arrayIndexCheck array indices
  | .arrayLength actual expected => decide (actual = expected)
  | .negate bounds => (checkedNegate bounds).safe
  | .add left right => (checkedAdd left right).safe
  | .subtract left right => (checkedSubtract left right).safe
  | .multiply left right => (checkedMultiply left right).safe
  | .divide left right => (checkedDivide left right).safe
  | .modulo left right => (checkedModulo left right).safe
  | .remainder left right => (checkedRemainder left right).safe
  | .within value target => value.included target
  | .impossible => false

def Obligation.Valid : Obligation → Prop
  | .range bounds => ∀ value, bounds.Contains value → InRange value
  | .arrayIndex array indices => ∀ index, indices.Contains index → array.bounds.Contains index
  | .arrayLength actual expected => actual = expected
  | .negate bounds => ∀ value, bounds.Contains value → InRange (-value)
  | .add left right => ∀ a b, left.Contains a → right.Contains b → InRange (a + b)
  | .subtract left right => ∀ a b, left.Contains a → right.Contains b → InRange (a - b)
  | .multiply left right => ∀ a b, left.Contains a → right.Contains b → InRange (a * b)
  | .divide left right => ∀ a b, left.Contains a → right.Contains b →
      DivideDefined a b ∧ InRange (a.tdiv b)
  | .modulo left right => ∀ a b, left.Contains a → right.Contains b →
      ModuloDefined a b ∧ InRange (a.fmod b)
  | .remainder left right => ∀ a b, left.Contains a → right.Contains b →
      RemainderDefined a b ∧ InRange (a.tmod b)
  | .within value target => ∀ item, value.Contains item → target.Contains item
  | .impossible => False

theorem Obligation.discharge_sound {obligation : Obligation} (proved : obligation.discharge = true) :
    obligation.Valid := by
  cases obligation with
  | range => exact fun _ within => (checked_sound proved within).2
  | arrayIndex array indices =>
      simp only [Obligation.discharge, arrayIndexCheck, decide_eq_true_eq] at proved
      intro index inside
      simp only [Interval.Contains] at *
      omega
  | arrayLength => simpa only [Obligation.discharge, Obligation.Valid, decide_eq_true_eq] using proved
  | negate => exact fun _ within => (checkedNegate_sound proved within).2
  | add => exact fun _ _ left right => (checkedAdd_sound proved left right).2
  | subtract => exact fun _ _ left right => (checkedSubtract_sound proved left right).2
  | multiply => exact fun _ _ left right => (checkedMultiply_sound proved left right).2
  | divide => exact fun _ _ left right => (checkedDivide_sound proved left right).2
  | modulo => exact fun _ _ left right => (checkedModulo_sound proved left right).2
  | remainder => exact fun _ _ left right => (checkedRemainder_sound proved left right).2
  | within => exact fun _ inside => Interval.included_sound proved inside
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
  | .indexed array index => index.obligations ranges ++
      match index.infer ranges with
      | none => [.impossible]
      | some indices => [.arrayIndex array indices,
          unaryObligation .range (arrayReadRange ranges array indices)]
  | .positive value | .parenthesized value => value.obligations ranges
  | .negative value => value.obligations ranges ++ [unaryObligation .negate (value.infer ranges)]
  | .add left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .add (left.infer ranges) (right.infer ranges)]
  | .subtract left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .subtract (left.infer ranges) (right.infer ranges)]
  | .multiply left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .multiply (left.infer ranges) (right.infer ranges)]
  | .divide left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .divide (left.infer ranges) (right.infer ranges)]
  | .modulo left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .modulo (left.infer ranges) (right.infer ranges)]
  | .remainder left right => left.obligations ranges ++ right.obligations ranges ++
      [binaryObligation .remainder (left.infer ranges) (right.infer ranges)]

theorem accepted_isSome (result : CheckResult) : (accepted result).isSome = result.safe := by
  simp only [accepted]; cases result.safe <;> rfl

theorem arrayReadRange_checked {ranges : Ranges} {array : ArrayDescriptor} {indices bounds : Interval}
    (found : arrayReadRange ranges array indices = some bounds) : (checked bounds).safe = true := by
  have bounded := arrayReadRange_bounded found
  simp only [checked]
  split <;> simp_all

theorem Expr.obligations_exact (expression : Expr) (ranges : Ranges) :
    discharged (expression.obligations ranges) = (expression.infer ranges).isSome := by
  induction expression with
  | literal value => simp [obligations, infer, discharged, Obligation.discharge, accepted_isSome]
  | name index =>
      cases found : ranges index <;>
        simp [obligations, infer, discharged, Obligation.discharge, unaryObligation, found, accepted_isSome]
  | indexed array index ih =>
      simp only [obligations, discharged_append, ih]
      cases hi : index.infer ranges with
      | none => simp [infer, hi]
      | some indices =>
          cases hr : arrayReadRange ranges array indices with
          | none => simp [infer, hi, hr, discharged, Obligation.discharge, unaryObligation]
          | some bounds =>
              simp [infer, hi, hr, discharged, Obligation.discharge, unaryObligation,
                arrayReadRange_index hr, arrayReadRange_checked hr]
  | positive _ ih | parenthesized _ ih => exact ih
  | negative value ih =>
      simp only [obligations, discharged, List.all_append] at ih ⊢
      rw [ih]
      cases found : value.infer ranges <;>
        simp [infer, found, unaryObligation, Obligation.discharge, accepted_isSome]
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
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
      [unaryObligation (fun value => .within value declaration.bounds)
        (declaration.value.infer constants.ranges)] ++
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
      have included : bounds.included declaration.bounds = true := by
        simp only [Declaration.check, found, Option.bind_some] at first
        split at first
        · rename_i good
          simp only [Interval.included, Interval.isEmpty, good.1, Int.lt_irrefl,
            decide_false, Bool.false_or, decide_eq_true_eq]
          simpa only [Interval.Contains, good.1] using good.2.2
        · contradiction
      rw [declarationObligations, first, discharged_append, discharged_append,
        Expr.obligations_discharge found, ih restChecked]
      simp only [found, unaryObligation, discharged, List.all_cons, List.all_nil,
        Obligation.discharge, included, Bool.and_self]

def Assignment.obligations (assignment : Assignment) (ranges : Ranges) : List Obligation :=
  assignment.value.obligations ranges ++
    [unaryObligation (fun value => .within value assignment.bounds) (assignment.value.infer ranges)]

theorem Assignment.obligations_discharge {assignment : Assignment} {ranges declared : Ranges}
    {mutable : Mutability} (checked : assignment.check ranges mutable declared = true) :
    discharged (assignment.obligations ranges) = true := by
  simp only [Assignment.check, Bool.and_eq_true] at checked
  cases target : declared assignment.target with
  | none => simp [target] at checked
  | some targetBounds =>
    cases value : assignment.value.infer ranges with
    | none => simp [value, target] at checked
    | some valueBounds =>
      have compatible : assignment.bounds = targetBounds ∧
          valueBounds.isEmpty = false ∧ valueBounds.included targetBounds = true := by
        simpa only [target, value, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] using checked.2
      rw [obligations, discharged_append, Expr.obligations_discharge value]
      simp only [value, unaryObligation, discharged, List.all_cons, List.all_nil,
        Obligation.discharge, compatible.1, compatible.2.2, Bool.and_self]

theorem declaration_obligations_valid {constants next : Constants} {declarations : List Declaration}
    (checked : checkDeclarations constants declarations = some next) :
    ∀ obligation ∈ declarationObligations constants declarations, obligation.Valid := by
  have all := List.all_eq_true.mp (declaration_obligations_discharge checked)
  exact fun obligation present => Obligation.discharge_sound (all obligation present)

end Silver.Integer
