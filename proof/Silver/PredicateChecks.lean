module

public import Silver.PredicateComposition

@[expose] public section

namespace Silver.Predicate
open Bindings PathFacts

/-- Declaration checks use the existing uniform arithmetic fragment. Executable
body checks retain the path interval and invalid-input flag proved by the
source checker. Native generation must normalize its obligations to these
schemas; faithful generation and external solver completion remain premises. -/
inductive Check
  | declaration (check : Compose.Check)
  | scalarDeclaration (check : Integer.Obligation)
  | path (check : Obligation)
  deriving DecidableEq, Repr

def Check.Valid : Check → Prop
  | .declaration check => check.Valid
  | .scalarDeclaration check => check.Valid
  | .path check => check.Valid

def Check.discharge : Check → Bool
  | .declaration check => check.discharge
  | .scalarDeclaration check => check.discharge
  | .path check => check.discharge

def Check.InFragment : Check → Prop
  | .declaration check => check.InFragment
  | .scalarDeclaration check => check.discharge = true
  | .path check => check.discharge = true

/-- Optimized checks may be omitted or duplicated. Declaration ranges admit
coefficient domination as before; path checks must retain the exact normalized
context and arithmetic/validity schema. -/
def Check.Refines : Check → Check → Prop
  | .declaration check, .declaration upper => check.Refines upper
  | .scalarDeclaration check, .scalarDeclaration upper => check = upper
  | .path check, .path upper => check = upper
  | _, _ => False

theorem Check.refines_refl (check : Check) : check.Refines check := by
  cases check with
  | declaration check => exact Compose.Check.refines_refl check
  | scalarDeclaration | path => rfl

theorem Check.fragment_of_refines {check upper : Check}
    (refined : check.Refines upper) (fragment : upper.InFragment) : check.InFragment := by
  cases check <;> cases upper <;> try contradiction
  · exact Compose.Check.fragment_of_refines refined fragment
  · cases refined; exact fragment
  · cases refined; exact fragment

theorem Check.fragment_valid {check : Check} (fragment : check.InFragment) : check.Valid := by
  cases check with
  | declaration => exact Compose.Check.fragment_valid fragment
  | scalarDeclaration => exact Integer.Obligation.discharge_sound fragment
  | path => exact Obligation.discharge_sound fragment

theorem Check.fragment_discharge {check : Check} (fragment : check.InFragment) : check.discharge = true := by
  cases check with
  | declaration check => exact (Compose.Check.discharge_iff check).mpr (Compose.Check.fragment_valid fragment)
  | scalarDeclaration | path => exact fragment

def Check.toObligation (check : Check) : Semantics.Obligation := ⟨.runTimeSafety, check.discharge⟩

def Program.checks (program : Program) : List Check :=
  (declarationChecks program).map Check.declaration ++
    (integerDeclarationChecks program ++ program.initializerChecks).map Check.scalarDeclaration ++
    (statementsObligations program.names.shape program.initialContext program.statements program.integerConstants.ranges).map Check.path

theorem Program.declaration_checks_fragment {program : Program} (valid : program.Valid) :
    ∀ check ∈ declarationChecks program, check.InFragment := by
  intro check member
  rcases List.mem_append.mp member with range | length
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp range
    exact ⟨_, by simp [Compose.uniformRangeObligations], Compose.declaration_schemas valid.1 schema present⟩
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp length
    have discharged := (Compose.LengthObligation.discharge_iff schema).mpr (Compose.declaration_lengths_valid valid.1 schema present)
    simpa [Compose.Check.InFragment, Compose.LengthObligation.discharge] using discharged

theorem Program.checks_fragment {program : Program} (valid : program.Valid) :
    ∀ check ∈ program.checks, check.InFragment := by
  intro check member
  rcases List.mem_append.mp member with declarations | path
  · rcases List.mem_append.mp declarations with declaration | scalar
    · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp declaration
      exact program.declaration_checks_fragment valid schema present
    · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp scalar
      exact List.all_eq_true.mp (program.scalar_checks_discharge valid) schema present
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp path
    obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
    have bodyChecked := ((program.checkBody_iff after).mp checked).2.2
    exact (List.all_eq_true.mp (statements_obligations_discharge bodyChecked)) schema present

theorem Program.checks_obligations (program : Program) :
    program.checks.map Check.toObligation = program.obligations := by
  simp only [Program.checks, Program.obligations, modeledObligations, List.map_append, List.map_map]
  rfl

end Silver.Predicate
