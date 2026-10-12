module

public import Silver.ComposeMain

@[expose] public section

/-! Each complete expression bounds every left-associated concatenation prefix.
These source-derived schemas also dominate checks simplified by the frontend.
They do not model solver implementation or a universal 10000-step bound. -/

namespace Silver.Compose

def Program.expressions : Program → List (Nat × Expression)
  | .direct expression | .argument _ _ expression => [(0, expression)]
  | .static initial expression | .assignment initial _ expression |
      .result _ initial _ _ _ _ expression => [(initial.length, expression)]
  | .branching _ _ _ yes no => [(0, yes), (0, no)]

def expressionSchema (length : Nat) (expression : Expression) : Guarded.RangeObligation :=
  ⟨expression.staticLength length, expression.dynamicCount * maxSourceLength⟩

def rangeObligations (program : Program) : List Guarded.RangeObligation :=
  program.expressions.map fun (length, expression) => expressionSchema length expression

def uniformRangeObligations : List Guarded.RangeObligation := [⟨maxSourceLength, maxSourceLength⟩]

theorem uniform_range_valid : ∀ check ∈ uniformRangeObligations, check.Valid := by
  intro check member
  simp only [uniformRangeObligations, List.mem_singleton] at member
  subst check
  exact (Guarded.RangeObligation.discharge_iff _).mp (by decide +kernel)

theorem safe_schema {expression : Expression} {length capacity : Nat}
    (safe : SafeExpression expression length capacity) :
    (expressionSchema length expression).Refines ⟨maxSourceLength, maxSourceLength⟩ := by
  have bounded := safe.1.2.2
  have dynamic := Nat.mul_le_mul_right maxSourceLength safe.1.2.1
  exact ⟨by simp only [expressionSchema]; omega, by simpa [expressionSchema] using dynamic⟩

theorem Expression.staticLength_append (left right : Expression) (length : Nat) :
    (left ++ right).staticLength length = left.staticLength length + right.staticLength length := by
  induction left with
  | nil => simp [staticLength]
  | cons atom rest ih => simp [staticLength, ih, Nat.add_assoc]

theorem Expression.dynamicCount_append (left right : Expression) :
    (left ++ right).dynamicCount = left.dynamicCount + right.dynamicCount := by
  induction left with
  | nil => simp [dynamicCount]
  | cons atom rest ih => simp [dynamicCount, ih, Nat.add_assoc]

/-- Every intermediate source concatenation is a prefix of the operand list,
including prefixes containing only empty operands or repeated fixed references. -/
theorem prefix_schema (leading trailing : Expression) (length : Nat) :
    (expressionSchema length leading).Refines (expressionSchema length (leading ++ trailing)) := by
  simp only [Guarded.RangeObligation.Refines, expressionSchema,
    Expression.staticLength_append, Expression.dynamicCount_append]
  exact ⟨Nat.le_add_right _ _, Nat.mul_le_mul_right _ (Nat.le_add_right _ _)⟩

theorem program_schemas {program : Program} (valid : program.Valid) :
    ∀ check ∈ rangeObligations program,
      ∃ upper ∈ uniformRangeObligations, check.Refines upper := by
  intro check member
  refine ⟨⟨maxSourceLength, maxSourceLength⟩, by simp [uniformRangeObligations], ?_⟩
  cases program with
  | direct expression =>
      simp only [rangeObligations, Program.expressions, List.map_cons, List.map_nil,
        List.mem_singleton] at member
      subst check
      exact safe_schema valid
  | static initial expression =>
      simp only [rangeObligations, Program.expressions, List.map_cons, List.map_nil,
        List.mem_singleton] at member
      subst check
      exact safe_schema valid.2
  | assignment initial replacement expression =>
      simp only [rangeObligations, Program.expressions, List.map_cons, List.map_nil,
        List.mem_singleton] at member
      subst check
      exact safe_schema valid.2.2.2
  | argument fallback capacity expression =>
      simp only [rangeObligations, Program.expressions, List.map_cons, List.map_nil,
        List.mem_singleton] at member
      subst check
      exact safe_schema valid.2.2.2
  | branching fallback capacity comparison yes no =>
      simp only [rangeObligations, Program.expressions, List.map_cons, List.map_nil,
        List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with rfl | rfl
      · exact safe_schema valid.2.2.2.2.1
      · exact safe_schema valid.2.2.2.2.2
  | result fallback initial capacity comparison yes no expression =>
      simp only [rangeObligations, Program.expressions, List.map_cons, List.map_nil,
        List.mem_singleton] at member
      subst check
      exact safe_schema valid.2.2.2.2.2.2.2.2.2

end Silver.Compose
