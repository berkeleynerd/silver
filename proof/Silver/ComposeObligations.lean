module

public import Silver.ComposeMain

@[expose] public section

/-! Source-derived range and exact-length schemas. Concatenation prefixes refine
bounded arithmetic checks; initialization copies and assignments preserve their
fixed or input-dependent object bounds. Solver implementation, faithful VC
generation and completion remain explicit external-tool premises in `Current`. -/

namespace Silver.Compose
open Bindings

def Body.expressions : Body → List Expression
  | .output expression | .assignment _ expression | .argument _ expression |
      .result _ _ _ _ expression => [expression]
  | .branching _ _ yes no => [yes, no]

def expressionSchema (shape : Shape) (expression : Expression) : Guarded.RangeObligation :=
  ⟨expression.staticLength shape, expression.dynamicCount shape * maxSourceLength⟩

def rangeObligations (program : Program) : List Guarded.RangeObligation :=
  program.body.expressions.map (expressionSchema program.names.shape)

def uniformRangeObligations : List Guarded.RangeObligation := [⟨maxSourceLength, maxSourceLength⟩]

theorem uniform_range_valid : ∀ check ∈ uniformRangeObligations, check.Valid := by
  intro check member
  simp only [uniformRangeObligations, List.mem_singleton] at member
  subst check
  exact (Guarded.RangeObligation.discharge_iff _).mp (by decide +kernel)

theorem safe_schema {expression : Expression} {shape : Shape} {capacity : Nat}
    (safe : SafeExpression expression shape capacity) :
    (expressionSchema shape expression).Refines ⟨maxSourceLength, maxSourceLength⟩ := by
  have bounded := safe.2.2.2.2.2
  have dynamic := Nat.mul_le_mul_right maxSourceLength safe.2.2.2.2.1
  exact ⟨by simp only [expressionSchema]; omega, by simpa [expressionSchema] using dynamic⟩

/-- Every intermediate left-associated concatenation is an operand-list prefix. -/
theorem prefix_schema (leading trailing : Expression) (shape : Shape) :
    (expressionSchema shape leading).Refines (expressionSchema shape (leading ++ trailing)) := by
  simp only [Guarded.RangeObligation.Refines, expressionSchema,
    Expression.staticLength_append, Expression.dynamicCount_append]
  exact ⟨Nat.le_add_right _ _, Nat.mul_le_mul_right _ (Nat.le_add_right _ _)⟩

theorem body_schemas {body : Body} {shape : Shape} (valid : body.Valid shape) :
    ∀ expression ∈ body.expressions,
      (expressionSchema shape expression).Refines ⟨maxSourceLength, maxSourceLength⟩ := by
  intro expression member
  cases body with
  | output value => simp only [Body.expressions, List.mem_singleton] at member; subst expression; exact safe_schema valid
  | assignment assignment value => simp only [Body.expressions, List.mem_singleton] at member; subst expression; exact safe_schema valid.2
  | argument capacity value => simp only [Body.expressions, List.mem_singleton] at member; subst expression; exact safe_schema valid.2
  | branching capacity comparison yes no =>
      simp only [Body.expressions, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl
      · exact safe_schema valid.2.2.1
      · exact safe_schema valid.2.2.2
  | result capacity comparison yes no value =>
      simp only [Body.expressions, List.mem_singleton] at member
      subst expression
      exact safe_schema valid.2.2.2.2

theorem program_schemas {program : Program} (valid : program.Valid) :
    ∀ check ∈ rangeObligations program,
      ∃ upper ∈ uniformRangeObligations, check.Refines upper := by
  intro check member
  obtain ⟨expression, present, rfl⟩ := List.mem_map.mp member
  exact ⟨_, by simp [uniformRangeObligations], body_schemas valid.2.2.2 expression present⟩

structure LengthObligation where
  target : Bound
  value : Bound
  deriving DecidableEq, Repr

def LengthObligation.Valid (check : LengthObligation) : Prop :=
  ∀ inputLength, check.target.length inputLength = check.value.length inputLength

def LengthObligation.discharge (check : LengthObligation) : Bool :=
  decide (check.target = check.value)

theorem LengthObligation.discharge_iff (check : LengthObligation) :
    check.discharge = true ↔ check.Valid := by
  simp only [discharge, decide_eq_true_eq, Valid]
  constructor
  · intro same inputLength
    rw [same]
  · intro same
    obtain ⟨target, value⟩ := check
    cases target <;> cases value <;> simp_all [Bound.length]
    all_goals have zero := same 0; have one := same 1; omega

/-- The object is initialized from the inferred value; the final shape retains
that bound even when a mutable object is assigned later. -/
def declarationLengthObligations (shape : Shape) (final : Shape) : List Declaration → List LengthObligation
  | [] => []
  | declaration :: rest =>
      let value := (declaration.initializer.infer shape).getD (.fixed 0)
      let target := ((final declaration.index).map CellInfo.bound).getD (.fixed 0)
      ⟨target, value⟩ :: declarationLengthObligations (declaration.extend shape value) final rest

def assignmentLengthObligation (shape : Shape) (assignment : Assignment) : LengthObligation :=
  ⟨((shape assignment.target).map CellInfo.bound).getD (.fixed 0),
   (assignment.value.infer shape).getD (.fixed 0)⟩

def Body.assignments : Body → List Assignment
  | .assignment assigned _ => [assigned]
  | .result _ _ yes no _ => [yes, no]
  | _ => []

def lengthObligations (program : Program) : List LengthObligation :=
  declarationLengthObligations emptyShape program.names.shape program.declarations ++
    program.body.assignments.map (assignmentLengthObligation program.names.shape)

theorem declaration_lengths_valid {shape final : Shape} {declarations : List Declaration}
    (valid : DeclarationsValid shape declarations final) :
    ∀ check ∈ declarationLengthObligations shape final declarations, check.Valid := by
  induction valid with
  | nil => simp [declarationLengthObligations]
  | @cons shape final declaration rest bound first remaining ih =>
      have target : final declaration.index = some ⟨bound, declaration.mutable⟩ :=
        declarations_extend remaining (by simp [Declaration.extend, put_same])
      simp only [declarationLengthObligations, first.2.1, Option.getD_some, target,
        Option.map_some, List.mem_cons]
      intro check member
      rcases member with rfl | member
      · intro inputLength; rfl
      · exact ih check member

theorem assignment_length_valid {shape : Shape} {assignment : Assignment}
    (valid : assignment.Valid shape) : (assignmentLengthObligation shape assignment).Valid := by
  obtain ⟨bound, target, inferred, _⟩ := valid
  simp [assignmentLengthObligation, target, inferred, LengthObligation.Valid]

theorem body_assignments_valid {body : Body} {shape : Shape} (valid : body.Valid shape) :
    ∀ assignment ∈ body.assignments, assignment.Valid shape := by
  intro assignment member
  cases body with
  | output | argument | branching => simp [Body.assignments] at member
  | assignment chosen expression =>
      simp only [Body.assignments, List.mem_singleton] at member
      subst assignment
      exact valid.1
  | result capacity comparison yes no expression =>
      simp only [Body.assignments, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl
      · exact valid.2.2.1
      · exact valid.2.2.2.1

theorem program_lengths_valid {program : Program} (valid : program.Valid) :
    ∀ check ∈ lengthObligations program, check.Valid := by
  intro check member
  simp only [lengthObligations, List.mem_append] at member
  rcases member with declaration | assigned
  · exact declaration_lengths_valid valid.1 check declaration
  · obtain ⟨assignment, present, rfl⟩ := List.mem_map.mp assigned
    exact assignment_length_valid (body_assignments_valid valid.2.2.2 assignment present)

/-- Both native safety-report classes share one complete obligation stream. -/
inductive Check
  | range (check : Guarded.RangeObligation)
  | length (check : LengthObligation)
  deriving DecidableEq, Repr

def Check.Valid : Check → Prop
  | .range check => check.Valid
  | .length check => check.Valid

def Check.discharge : Check → Bool
  | .range check => check.discharge
  | .length check => check.discharge

theorem Check.discharge_iff (check : Check) : check.discharge = true ↔ check.Valid := by
  cases check with
  | range check => exact Guarded.RangeObligation.discharge_iff check
  | length check => exact LengthObligation.discharge_iff check

def Check.toObligation (check : Check) : Semantics.Obligation := ⟨.runTimeSafety, check.discharge⟩

/-- Range schemas permit coefficient domination; exact-length schemas preserve
both symbolic bounds. Optimized checks may be omitted or duplicated. -/
def Check.Refines : Check → Check → Prop
  | .range check, .range upper => check.Refines upper
  | .length check, .length upper => check = upper
  | _, _ => False

theorem Check.refines_refl (check : Check) : check.Refines check := by
  cases check <;> simp [Refines, Guarded.RangeObligation.Refines]

theorem Check.refines_trans {check middle upper : Check}
    (first : check.Refines middle) (second : middle.Refines upper) : check.Refines upper := by
  cases check <;> cases middle <;> cases upper <;> simp_all [Refines, Guarded.RangeObligation.Refines]
  omega

def Check.InFragment : Check → Prop
  | .range check => ∃ upper ∈ uniformRangeObligations, check.Refines upper
  | .length check => check.target = check.value

theorem Check.fragment_valid {check : Check} (fragment : check.InFragment) : check.Valid := by
  cases check with
  | range check =>
      obtain ⟨upper, present, refined⟩ := fragment
      exact Guarded.RangeObligation.valid_of_refines refined (uniform_range_valid upper present)
  | length check =>
      exact (LengthObligation.discharge_iff check).mp (by simpa [LengthObligation.discharge, Check.InFragment] using fragment)

theorem Check.fragment_of_refines {check upper : Check}
    (refined : check.Refines upper) (fragment : upper.InFragment) : check.InFragment := by
  cases check with
  | range check =>
      cases upper with
      | length => cases refined
      | range upper =>
          obtain ⟨largest, present, bound⟩ := fragment
          exact ⟨largest, present, Nat.le_trans refined.1 bound.1, Nat.le_trans refined.2 bound.2⟩
  | length check =>
      cases upper with
      | range => cases refined
      | length upper => simpa [Check.Refines] using refined ▸ fragment

def checks (program : Program) : List Check :=
  (rangeObligations program).map Check.range ++ (lengthObligations program).map Check.length

theorem program_checks_fragment {program : Program} (valid : program.Valid) :
    ∀ check ∈ checks program, check.InFragment := by
  intro check member
  simp only [checks, List.mem_append] at member
  rcases member with ranges | lengths
  · obtain ⟨range, present, rfl⟩ := List.mem_map.mp ranges
    exact program_schemas valid range present
  · obtain ⟨length, present, rfl⟩ := List.mem_map.mp lengths
    have discharged := (LengthObligation.discharge_iff length).mpr (program_lengths_valid valid length present)
    simpa [Check.InFragment, LengthObligation.discharge] using discharged

end Silver.Compose
