module

public import Silver.SequenceSyntax
public import Silver.ComposeObligations

@[expose] public section

/-! Sequencing reuses the established range and exact-length arithmetic
fragment. Every expression and assignment in either arm contributes its schema;
sequential state changes preserve the fixed shape used by these schemas. -/

namespace Silver.Sequence
open Bindings Compose

def SimpleStatement.expressions : SimpleStatement → List Expression
  | .null => []
  | .assign update => [update.value]
  | .output expression => [expression]

def Statement.expressions : Statement → List Expression
  | .simple item => item.expressions
  | .choice left right yes no => [left, right] ++
      yes.flatMap SimpleStatement.expressions ++ no.flatMap SimpleStatement.expressions

def Body.expressions (body : Body) : List Expression := body.statements.flatMap Statement.expressions

def SimpleStatement.assignments : SimpleStatement → List Assignment
  | .assign update => [update]
  | _ => []

def Statement.assignments : Statement → List Assignment
  | .simple item => item.assignments
  | .choice _ _ yes no => yes.flatMap SimpleStatement.assignments ++ no.flatMap SimpleStatement.assignments

def Body.assignments (body : Body) : List Assignment := body.statements.flatMap Statement.assignments

theorem simple_expressions_safe {item : SimpleStatement} {shape : Shape} {capacity : Nat}
    (valid : item.Valid shape capacity) :
    ∀ expression ∈ item.expressions, Compose.SafeExpression expression shape capacity := by
  intro expression member
  cases item with
  | null => simp [SimpleStatement.expressions] at member
  | assign update =>
      cases List.mem_singleton.mp member
      exact valid.2
  | output value =>
      cases List.mem_singleton.mp member
      exact valid

theorem simple_list_expressions_safe {items : List SimpleStatement} {shape : Shape} {capacity : Nat}
    (valid : SimpleStatementsValid shape capacity items) :
    ∀ expression ∈ items.flatMap SimpleStatement.expressions,
      Compose.SafeExpression expression shape capacity := by
  intro expression member
  obtain ⟨item, present, member⟩ := List.mem_flatMap.mp member
  exact simple_expressions_safe (valid item present) expression member

theorem statement_expressions_safe {item : Statement} {shape : Shape} {capacity : Nat}
    (valid : item.Valid shape capacity) :
    ∀ expression ∈ item.expressions, Compose.SafeExpression expression shape capacity := by
  intro expression member
  cases item with
  | simple item => exact simple_expressions_safe valid expression member
  | choice left right yes no =>
      simp only [Statement.expressions, List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at member
      rcases member with ((rfl | rfl) | yesMember) | noMember
      · exact valid.1
      · exact valid.2.1
      · exact simple_list_expressions_safe valid.2.2.2.2.1 _ yesMember
      · exact simple_list_expressions_safe valid.2.2.2.2.2 _ noMember

theorem body_expressions_safe {body : Body} {shape : Shape} (valid : body.Valid shape) :
    ∀ expression ∈ body.expressions, Compose.SafeExpression expression shape body.shell.capacity := by
  intro expression member
  obtain ⟨item, present, member⟩ := List.mem_flatMap.mp member
  exact statement_expressions_safe (valid.2.2 item present) expression member

theorem simple_assignments_valid {item : SimpleStatement} {shape : Shape} {capacity : Nat}
    (valid : item.Valid shape capacity) : ∀ update ∈ item.assignments, update.Valid shape := by
  intro update member
  cases item with
  | null | output => simp [SimpleStatement.assignments] at member
  | assign assigned =>
      cases List.mem_singleton.mp member
      exact valid.1

theorem simple_list_assignments_valid {items : List SimpleStatement} {shape : Shape} {capacity : Nat}
    (valid : SimpleStatementsValid shape capacity items) :
    ∀ update ∈ items.flatMap SimpleStatement.assignments, update.Valid shape := by
  intro update member
  obtain ⟨item, present, member⟩ := List.mem_flatMap.mp member
  exact simple_assignments_valid (valid item present) update member

theorem statement_assignments_valid {item : Statement} {shape : Shape} {capacity : Nat}
    (valid : item.Valid shape capacity) : ∀ update ∈ item.assignments, update.Valid shape := by
  intro update member
  cases item with
  | simple item => exact simple_assignments_valid valid update member
  | choice left right yes no =>
      rcases List.mem_append.mp member with yesMember | noMember
      · exact simple_list_assignments_valid valid.2.2.2.2.1 _ yesMember
      · exact simple_list_assignments_valid valid.2.2.2.2.2 _ noMember

theorem body_assignments_valid {body : Body} {shape : Shape} (valid : body.Valid shape) :
    ∀ update ∈ body.assignments, update.Valid shape := by
  intro update member
  obtain ⟨item, present, member⟩ := List.mem_flatMap.mp member
  exact statement_assignments_valid (valid.2.2 item present) update member

def rangeObligations (program : Program) : List Guarded.RangeObligation :=
  Compose.declarationRangeObligations emptyShape program.names.shape program.declarations ++
    program.body.expressions.map (Compose.expressionSchema program.names.shape program.body.shell.capacity)

def lengthObligations (program : Program) : List Compose.LengthObligation :=
  Compose.declarationLengthObligations emptyShape program.names.shape program.declarations ++
    program.body.assignments.map (Compose.assignmentLengthObligation program.names.shape)

def checks (program : Program) : List Compose.Check :=
  (rangeObligations program).map Compose.Check.range ++
    (lengthObligations program).map Compose.Check.length

theorem program_schemas {program : Program} (valid : program.Valid) :
    ∀ check ∈ rangeObligations program,
      ∃ upper ∈ Compose.uniformRangeObligations, check.Refines upper := by
  intro check member
  refine ⟨⟨maxSourceLength, maxSourceLength⟩, by simp [Compose.uniformRangeObligations], ?_⟩
  rcases List.mem_append.mp member with declared | body
  · exact Compose.declaration_schemas valid.1 check declared
  · obtain ⟨expression, present, rfl⟩ := List.mem_map.mp body
    exact Compose.safe_schema (body_expressions_safe valid.2.2.2 expression present)

theorem program_lengths_valid {program : Program} (valid : program.Valid) :
    ∀ check ∈ lengthObligations program, check.Valid := by
  intro check member
  rcases List.mem_append.mp member with declared | body
  · exact Compose.declaration_lengths_valid valid.1 check declared
  · obtain ⟨update, present, rfl⟩ := List.mem_map.mp body
    exact Compose.assignment_length_valid (body_assignments_valid valid.2.2.2 update present)

theorem program_checks_fragment {program : Program} (valid : program.Valid) :
    ∀ check ∈ checks program, check.InFragment := by
  intro check member
  rcases List.mem_append.mp member with ranges | lengths
  · obtain ⟨range, present, rfl⟩ := List.mem_map.mp ranges
    exact program_schemas valid range present
  · obtain ⟨length, present, rfl⟩ := List.mem_map.mp lengths
    have discharged := (Compose.LengthObligation.discharge_iff length).mpr
      (program_lengths_valid valid length present)
    simpa [Compose.Check.InFragment, Compose.LengthObligation.discharge] using discharged

end Silver.Sequence
