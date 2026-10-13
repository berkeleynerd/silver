module

public import Silver.ComposeMain

@[expose] public section

/-! Source-derived range and exact-length schemas. Every declaration, assignment,
comparison and output expression contributes a bounded arithmetic schema;
arbitrary grouped intermediates refine it. Initialization and assignment retain
exact fixed or input-dependent object bounds. Solver implementation, faithful VC
generation and completion remain explicit external-tool premises in `Current`. -/

namespace Silver.Compose
open Bindings

def Body.capacity : Body → Nat
  | .output _ | .assignment _ _ => maxSourceLength
  | .argument capacity _ | .branching capacity _ _ _ _ | .result capacity _ _ _ _ _ =>
      effectiveCapacity capacity

/-- Every expression evaluated by the body, including comparisons and RHSs. -/
def Body.expressions : Body → List Expression
  | .output expression | .argument _ expression => [expression]
  | .assignment update expression => [update.value, expression]
  | .branching _ left right yes no => [left, right, yes, no]
  | .result _ left right yes no expression => [left, right, yes.value, no.value, expression]

def expressionSchema (shape : Shape) (capacity : Nat) (expression : Expression) : Guarded.RangeObligation :=
  ⟨expression.staticLength shape, expression.dynamicCount shape * capacity⟩

/-- Valid declaration sequences retain each declared object's bound in the final shape. -/
def declarationBound (final : Shape) (declaration : Declaration) : Bound :=
  ((final declaration.index).map CellInfo.bound).getD (.fixed 0)

def declarationRangeObligations (shape final : Shape) : List Declaration → List Guarded.RangeObligation
  | [] => []
  | declaration :: rest =>
      expressionSchema shape maxSourceLength declaration.initializer ::
        declarationRangeObligations (declaration.extend shape (declarationBound final declaration)) final rest

def rangeObligations (program : Program) : List Guarded.RangeObligation :=
  declarationRangeObligations emptyShape program.names.shape program.declarations ++
    program.body.expressions.map (expressionSchema program.names.shape program.body.capacity)

def uniformRangeObligations : List Guarded.RangeObligation := [⟨maxSourceLength, maxSourceLength⟩]

theorem uniform_range_valid : ∀ check ∈ uniformRangeObligations, check.Valid := by
  intro check member
  simp only [uniformRangeObligations, List.mem_singleton] at member
  subst check
  exact (Guarded.RangeObligation.discharge_iff _).mp (by decide +kernel)

theorem safe_schema {expression : Expression} {shape : Shape} {capacity : Nat}
    (safe : SafeExpression expression shape capacity) :
    (expressionSchema shape capacity expression).Refines ⟨maxSourceLength, maxSourceLength⟩ := by
  have bounded := safe.2.2.2.2
  simp only [Guarded.RangeObligation.Refines, expressionSchema]
  omega

/-- Prefixes and arbitrary grouped subexpressions have no larger nonnegative
length coefficients than the whole expression. -/
theorem prefix_schema (leading trailing : Expression) (shape : Shape) (capacity : Nat) :
    (expressionSchema shape capacity leading).Refines
      (expressionSchema shape capacity (leading ++ trailing)) := by
  simp only [Guarded.RangeObligation.Refines, expressionSchema,
    Expression.staticLength_append, Expression.dynamicCount_append]
  exact ⟨Nat.le_add_right _ _, Nat.mul_le_mul_right _ (Nat.le_add_right _ _)⟩

theorem grouped_schema {part whole : GroupedExpression}
    (member : GroupedExpression.Subexpression part whole) (shape : Shape) (capacity : Nat) :
    (expressionSchema shape capacity part.flatten).Refines
      (expressionSchema shape capacity whole.flatten) := by
  induction member with
  | self => exact ⟨Nat.le_refl _, Nat.le_refl _⟩
  | left member ih =>
      simpa only [GroupedExpression.flatten] using
        ⟨Nat.le_trans ih.1 (prefix_schema _ _ shape capacity).1,
         Nat.le_trans ih.2 (prefix_schema _ _ shape capacity).2⟩
  | right member ih =>
      simp only [Guarded.RangeObligation.Refines, expressionSchema,
        GroupedExpression.flatten, Expression.staticLength_append,
        Expression.dynamicCount_append] at *
      exact ⟨Nat.le_trans ih.1 (Nat.le_add_left _ _),
        Nat.le_trans ih.2 (Nat.mul_le_mul_right _ (Nat.le_add_left _ _))⟩
  | parens member ih => exact ih

theorem grouped_range_valid {part whole : GroupedExpression} {expression : Expression}
    {shape : Shape} {capacity : Nat} (flattened : whole.flatten = expression)
    (member : GroupedExpression.Subexpression part whole)
    (safe : SafeExpression expression shape capacity) :
    (expressionSchema shape capacity part.flatten).Valid := by
  have bounded := grouped_schema member shape capacity
  rw [flattened] at bounded
  apply Guarded.RangeObligation.valid_of_refines bounded
  exact Guarded.RangeObligation.valid_of_refines (safe_schema safe)
    (uniform_range_valid _ (by simp [uniformRangeObligations]))

theorem body_schemas {body : Body} {shape : Shape} (valid : body.Valid shape) :
    ∀ expression ∈ body.expressions,
      (expressionSchema shape body.capacity expression).Refines ⟨maxSourceLength, maxSourceLength⟩ := by
  intro expression member
  cases body with
  | output value =>
      simp only [Body.expressions, List.mem_singleton] at member
      subst expression
      exact safe_schema valid
  | assignment assignment value =>
      simp only [Body.expressions, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl
      · exact safe_schema valid.2.1
      · exact safe_schema valid.2.2
  | argument capacity value =>
      simp only [Body.expressions, List.mem_singleton] at member
      subst expression
      exact safe_schema valid.2
  | branching capacity left right yes no =>
      simp only [Body.expressions, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl | rfl | rfl
      · exact safe_schema valid.2.1
      · exact safe_schema valid.2.2.1
      · exact safe_schema valid.2.2.2.1
      · exact safe_schema valid.2.2.2.2
  | result capacity left right yes no value =>
      simp only [Body.expressions, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl | rfl | rfl | rfl
      · exact safe_schema valid.2.1
      · exact safe_schema valid.2.2.1
      · exact safe_schema valid.2.2.2.2.1
      · exact safe_schema valid.2.2.2.2.2.2.1
      · exact safe_schema valid.2.2.2.2.2.2.2

theorem declaration_schemas {shape final : Shape} {declarations : List Declaration}
    (valid : DeclarationsValid shape declarations final) :
    ∀ check ∈ declarationRangeObligations shape final declarations,
      check.Refines ⟨maxSourceLength, maxSourceLength⟩ := by
  induction valid with
  | nil => simp [declarationRangeObligations]
  | @cons shape final declaration rest bound first remaining ih =>
      have target : final declaration.index = some ⟨bound, declaration.mutable⟩ :=
        declarations_extend remaining (by simp [Declaration.extend, put_same])
      simp only [declarationRangeObligations, declarationBound, target, Option.map_some,
        Option.getD_some, List.mem_cons]
      intro check member
      rcases member with rfl | member
      · exact safe_schema (declaration_safe first)
      · exact ih check member

theorem program_schemas {program : Program} (valid : program.Valid) :
    ∀ check ∈ rangeObligations program,
      ∃ upper ∈ uniformRangeObligations, check.Refines upper := by
  intro check member
  refine ⟨⟨maxSourceLength, maxSourceLength⟩, by simp [uniformRangeObligations], ?_⟩
  simp only [rangeObligations, List.mem_append] at member
  rcases member with declared | body
  · exact declaration_schemas valid.1 check declared
  · obtain ⟨expression, present, rfl⟩ := List.mem_map.mp body
    exact body_schemas valid.2.2.2 expression present

structure LengthObligation where
  target : Summary
  value : Summary
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
    obtain ⟨⟨targetStatic, targetDynamic⟩, ⟨valueStatic, valueDynamic⟩⟩ := check
    have zero := same 0
    have one := same 1
    simp only [Summary.length] at zero one
    have fixed : targetStatic = valueStatic := by omega
    have dynamic : targetDynamic = valueDynamic := by omega
    cases fixed
    cases dynamic
    rfl

/-- Initialization and assignment compare exact affine lengths, retaining
symbolic input multiplicity as well as fixed bytes. -/
def declarationLengthObligations (shape final : Shape) : List Declaration → List LengthObligation
  | [] => []
  | declaration :: rest =>
      let target := declarationBound final declaration
      ⟨target.summary, (declaration.initializer.infer shape).getD ⟨0, 0⟩⟩ ::
        declarationLengthObligations (declaration.extend shape target) final rest

def assignmentLengthObligation (shape : Shape) (assignment : Assignment) : LengthObligation :=
  ⟨(((shape assignment.target).map CellInfo.bound).getD (.fixed 0)).summary,
   (assignment.value.infer shape).getD ⟨0, 0⟩⟩

def Body.assignments : Body → List Assignment
  | .assignment assigned _ => [assigned]
  | .result _ _ _ yes no _ => [yes, no]
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
      simp only [declarationLengthObligations, declarationBound, first.2.1, target,
        Option.getD_some, Option.map_some, List.mem_cons]
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
  | result capacity left right yes no expression =>
      simp only [Body.assignments, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl
      · exact valid.2.2.2.1
      · exact valid.2.2.2.2.2.1

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
