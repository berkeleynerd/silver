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
    ((program.booleanInitializerChecks ++ booleanDeclarationObligations program.names.shape
      Integer.Analysis.empty program.booleanInitialFlow 0 program.booleanDeclarations).map Check.path) ++
    (statementsObligations program.names.shape program.bodyAnalysis program.initialFlow program.statements program.bodyBooleanAnalysis).map Check.path

theorem Program.declaration_checks_fragment {program : Program} (valid : program.Valid) :
    ∀ check ∈ declarationChecks program, check.InFragment := by
  intro check member
  rcases List.mem_append.mp member with range | length
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp range
    exact ⟨_, by simp [Compose.uniformRangeObligations], Compose.declaration_schemas valid.1.1 schema present⟩
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp length
    have discharged := (Compose.LengthObligation.discharge_iff schema).mpr (Compose.declaration_lengths_valid valid.1.1 schema present)
    simpa [Compose.Check.InFragment, Compose.LengthObligation.discharge] using discharged

theorem Program.checks_fragment {program : Program} (valid : program.Valid) :
    ∀ check ∈ program.checks, check.InFragment := by
  intro check member
  rcases List.mem_append.mp member with declarations | path
  · rcases List.mem_append.mp declarations with declarations | boolean
    · rcases List.mem_append.mp declarations with declaration | scalar
      · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp declaration
        exact program.declaration_checks_fragment valid schema present
      · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp scalar
        exact List.all_eq_true.mp (program.scalar_checks_discharge valid) schema present
    · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp boolean
      exact List.all_eq_true.mp (program.boolean_initializer_checks_discharge valid) schema present
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp path
    obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
    have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
    exact (List.all_eq_true.mp (statements_obligations_discharge bodyChecked)) schema present

theorem Program.checks_obligations (program : Program) :
    program.checks.map Check.toObligation = program.obligations := by
  simp only [Program.checks, Program.obligations, modeledObligations, List.map_append, List.map_map]
  rfl

/-- A loop retains its entry bound after that mutable object is assigned in
its body. The final index value copied to another object witnesses all three
iterations; the lexical index's pre-loop store cell is restored. -/
def frozenBoundWitness : Statement :=
  .forLoop 3 false (.literal 1) (.name 1)
    [.scalarAssign ⟨1, .literal 1, ⟨1, 3⟩⟩,
      .scalarAssign ⟨2, .name 3, ⟨1, 3⟩⟩]

def frozenBoundStore : Integer.Store :=
  Integer.put (Integer.put Integer.emptyStore 1 3) 3 9

theorem mutable_loop_entry_bound_snapshot :
    let result := frozenBoundWitness.execute [] true Bindings.emptyValues frozenBoundStore
    result.integers 1 = 1 ∧ result.integers 2 = 3 ∧ result.integers 3 = 9 := by decide +kernel

/-- A nested loop restores its lexical index independently of the outer
index, while writes to other scalar objects remain visible after both loops. -/
def nestedIndexWitness : Statement :=
  .forLoop 2 false (.literal 4) (.literal 4)
    [.forLoop 4 false (.literal 7) (.literal 7)
      [.scalarAssign ⟨1, .name 4, ⟨0, 10⟩⟩],
      .scalarAssign ⟨3, .name 2, ⟨0, 10⟩⟩]

theorem mutable_nested_index_scope_preserves_writes :
    let result := nestedIndexWitness.execute [] true Bindings.emptyValues
      (Integer.put (Integer.put Integer.emptyStore 2 9) 4 8)
    result.integers 1 = 7 ∧ result.integers 2 = 9 ∧ result.integers 3 = 4 ∧ result.integers 4 = 8 := by decide +kernel

/-- This descriptor deliberately uses an arbitrary generic store identity;
readiness cannot obtain its binder-separation premise from a native limit. -/
def constantIterationArray : Integer.ArrayDescriptor := ⟨100, ⟨-1, 1⟩, .full⟩

def constantIterationAnalysis : Integer.Analysis :=
  ⟨constantIterationArray.bodyRanges (Integer.put Integer.emptyRanges 1 (some Integer.Interval.full)),
    Integer.put Integer.immutable 1 true, Integer.immutable, Integer.put Integer.immutable 1 true⟩

def constantIterationFlow : Flow :=
  ⟨⟨some ⟨0, 0⟩, false, false⟩, constantIterationAnalysis.declared⟩

def constantIterationWitness (reverse : Bool) : Statement :=
  .arrayLoop 2 reverse constantIterationArray [.scalarAssign ⟨1, .name 2, .full⟩]

theorem constant_iteration_forward_reverse_and_restore :
    let initial := constantIterationArray.initializeValues (Integer.put Integer.emptyStore 2 9) [-1, 0, 1]
    let forward := (constantIterationWitness false).execute [] true Bindings.emptyValues initial
    let reverse := (constantIterationWitness true).execute [] true Bindings.emptyValues initial
    forward.integers 1 = 1 ∧ reverse.integers 1 = -1 ∧
      forward.integers 2 = 9 ∧ reverse.integers 2 = 9 ∧
      constantIterationArray.project forward.integers (-1) = -1 ∧
      constantIterationArray.project reverse.integers 1 = 1 := by decide +kernel

/-- Full entry intervals need a fresh guard before incrementing the element. -/
theorem constant_iteration_guard_refines_element :
    ((Statement.arrayLoop 2 false constantIterationArray
      [.choice (.scalarCompare .lt (.name 2) (.literal Integer.maxValue))
        [.scalarAssign ⟨1, .add (.name 2) (.literal 1), .full⟩] []]).check
      (fun _ => none) constantIterationAnalysis constantIterationFlow).isSome = true := by decide +kernel

theorem constant_iteration_rejects_unguarded_increment :
    (Statement.arrayLoop 2 false constantIterationArray
      [.scalarAssign ⟨1, .add (.name 2) (.literal 1), .full⟩]).check
      (fun _ => none) constantIterationAnalysis constantIterationFlow = none := by decide +kernel

/-- A nested loop must not transiently replace a constant component, even
though its ordinary scoped restoration would repair the final store. -/
theorem constant_iteration_rejects_nested_binder_collision :
    (Statement.arrayLoop 2 false constantIterationArray
      [.forLoop 100 false (.literal 0) (.literal 0) [.simple .null]]).check
      (fun _ => none) constantIterationAnalysis constantIterationFlow = none := by decide +kernel

theorem constant_iteration_rejects_nested_element_collision :
    statementsBindersApart constantIterationArray
      [.arrayLoop 101 false ⟨200, ⟨1, 1⟩, .full⟩ [.simple .null]] = false := by decide +kernel

theorem constant_iteration_full_domain_extreme_singletons :
    Integer.iterationValues false Integer.minValue Integer.minValue = [Integer.minValue] ∧
      Integer.iterationValues true Integer.maxValue Integer.maxValue = [Integer.maxValue] := by decide +kernel

/-- Bounded component subtypes make element multiplication safe without an
extra guard, while the existing immutable-array and binder rules still apply. -/
def boundedComponentArray : Integer.ArrayDescriptor := ⟨100, ⟨1, 3⟩, ⟨0, 3⟩⟩

theorem bounded_components_enable_element_square :
    let analysis : Integer.Analysis :=
      ⟨boundedComponentArray.bodyRanges (Integer.put Integer.emptyRanges 1 (some .full)),
        Integer.put Integer.immutable 1 true, Integer.immutable, Integer.put Integer.immutable 1 true⟩
    (Statement.arrayLoop 2 false boundedComponentArray
      [.scalarAssign ⟨1, .multiply (.name 2) (.name 2), .full⟩]).check
      (fun _ => none) analysis ⟨⟨some ⟨0, 0⟩, false, false⟩, analysis.declared⟩ |>.isSome = true := by
  decide +kernel

theorem bounded_components_reject_initializer_outside_subtype :
    (⟨boundedComponentArray, [.literal 0, .literal 4, .literal 1]⟩ : Integer.ArrayDeclaration).check
      Integer.emptyRanges = none := by decide +kernel

theorem bounded_components_reject_write_outside_subtype :
    (⟨boundedComponentArray, .literal 1, .literal 4⟩ : Integer.ArrayAssignment).check
      (boundedComponentArray.bodyRanges Integer.emptyRanges) (fun _ => true) = false := by decide +kernel

end Silver.Predicate
