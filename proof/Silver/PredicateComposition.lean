module

public import Silver.PredicateExecution
public import Silver.PredicateObligations
public import Silver.SequenceEffects
public import Silver.PredicateArrayFlow
public import Silver.BooleanDeclarationObligations

@[expose] public section

/-! The shared declaration model initializes predicate-control programs. All
arguments receive one universal execution theorem; effect interpretation reuses
the returning-call trace model, including sticky failure and repeated output. -/

namespace Silver.Predicate
open Bindings Compose PathFacts
open Sequence (Effect EffectsValid)

structure Program where
  declarations : List Declaration
  names : Compose.BindingEnvironment
  fallback : Source
  hasArguments : Bool
  statements : List Statement
  integerDeclarations : List Integer.Declaration := []
  integerConstants : Integer.Constants := []
  initializerChecks : List Integer.Obligation := []
  arrays : ArrayBindings.Env := {}
  booleanDeclarations : List BooleanDeclaration := []
  booleanInitializerChecks : List Obligation := []
  deriving Repr

def Program.initialContext (program : Program) : Context :=
  if program.hasArguments then Context.initial maxSourceLength
  else ⟨some ⟨0, 0⟩, false, false⟩

def Program.input (program : Program) (arguments : Arguments.Runtime.Arguments) : Source :=
  if program.hasArguments then selected program.fallback arguments else []

def Program.inputValid (program : Program) (arguments : Arguments.Runtime.Arguments) : Bool :=
  if program.hasArguments then Arguments.Runtime.inputIsValid arguments else true

def Program.initialValues (program : Program) (arguments : Arguments.Runtime.Arguments) : Values :=
  executeDeclarations (program.input arguments) program.declarations emptyValues

def Program.initialIntegers (program : Program) : Integer.Store :=
  ArrayBindings.integerStore program.arrays.names program.arrays.values
    (Integer.executeDeclarations [] program.integerDeclarations).store

def Program.bodyBooleanAnalysis (program : Program) : Boolean.Analysis :=
  booleanBodyAnalysis program.booleanDeclarations

def Program.booleanInitialFlow (program : Program) : Flow :=
  ⟨program.initialContext, Integer.emptyRanges⟩

def Program.initialBooleans (program : Program) (arguments : Arguments.Runtime.Arguments) : Boolean.Store :=
  executeBooleanDeclarations (program.initialValues arguments) (program.input arguments)
    (program.inputValid arguments) Integer.emptyStore program.booleanDeclarations Boolean.emptyStore

def Program.bodyBindings (program : Program) : Integer.ObjectBindings :=
  Integer.elaborate [] program.integerDeclarations

def Program.bodyRanges (program : Program) : Integer.Ranges :=
  ArrayFlow.ranges program.arrays.names program.bodyBindings.ranges

def Program.bodyMutability (program : Program) : Integer.Mutability :=
  ArrayBindings.integerMutability program.arrays.names program.bodyBindings.mutability

def Program.bodyAnalysis (program : Program) : Integer.Analysis :=
  ArrayFlow.analysis program.arrays.names (Integer.Analysis.ofDeclarations program.integerDeclarations)

def Program.initialFlow (program : Program) : Flow :=
  Flow.initial program.bodyAnalysis program.initialContext

instance validArrayInitialsDecidable (values : ArrayBindings.Initials) : Decidable (ArrayBindings.ValidInitials values) :=
  inferInstanceAs (Decidable (values.length ≤ ArrayBindings.maxElements ∧
    ∀ value ∈ values, Integer.InRange value))

def Program.checkBody (program : Program) : Option Flow :=
  if Integer.checkDeclarations [] program.integerDeclarations = some program.integerConstants ∧
      Integer.discharged program.initializerChecks = true ∧
      (ArrayBindings.ValidInitials program.arrays.values ∧
        ArrayBindings.InitialsFit program.arrays.names program.arrays.values) then
    checkStatements program.names.shape program.bodyAnalysis program.initialFlow program.statements program.bodyBooleanAnalysis
  else none

theorem Program.checkBody_iff (program : Program) (after : Flow) :
    program.checkBody = some after ↔
      Integer.checkDeclarations [] program.integerDeclarations = some program.integerConstants ∧
      Integer.discharged program.initializerChecks = true ∧
      (ArrayBindings.ValidInitials program.arrays.values ∧
        ArrayBindings.InitialsFit program.arrays.names program.arrays.values) ∧
      checkStatements program.names.shape program.bodyAnalysis program.initialFlow program.statements program.bodyBooleanAnalysis = some after := by
  simp only [checkBody]
  split <;> simp_all

def Program.execute (program : Program) (arguments : Arguments.Runtime.Arguments) : Execution :=
  executeStatements (program.input arguments) (program.inputValid arguments)
    (program.initialValues arguments) program.statements program.initialIntegers (program.initialBooleans arguments)

def Program.checkedExecute (program : Program) (arguments : Arguments.Runtime.Arguments) : Option Execution :=
  checkedStatements (program.input arguments) (program.inputValid arguments)
    (program.initialValues arguments) program.statements program.initialIntegers (program.initialBooleans arguments)

def Program.InitializersValid (program : Program) : Prop :=
  DeclarationsValid emptyShape program.declarations program.names.shape ∧
    BooleanDeclarationsWellFormed program.hasArguments program.names.shape {} program.booleanDeclarations ∧
    checkBooleanDeclarations program.names.shape Integer.Analysis.empty program.booleanInitialFlow
      {} program.booleanDeclarations = true ∧ discharged program.booleanInitializerChecks = true

def Program.Valid (program : Program) : Prop :=
  program.InitializersValid ∧
    Bindings.Printable program.fallback ∧ program.fallback.length ≤ maxSourceLength ∧
    program.statements ≠ [] ∧ StatementsWellFormed program.hasArguments program.names.shape program.statements program.bodyBooleanAnalysis ∧
    ∃ after, program.checkBody = some after ∧ completed after.path = true

theorem selected_invalid (fallback : Source) (arguments : Arguments.Runtime.Arguments)
    (invalid : Arguments.Runtime.inputIsValid arguments = false) : selected fallback arguments = [] := by
  cases arguments with
  | nil => contradiction
  | cons first rest =>
      cases rest with
      | nil =>
          have invalidMessage : Arguments.Runtime.message first = false := invalid
          simp only [selected, Arguments.Runtime.firstOrDefault, invalidMessage, Bool.false_eq_true, ↓reduceIte]
      | cons second rest => rfl

theorem Program.input_domain (program : Program) (arguments : Arguments.Runtime.Arguments) :
    (program.input arguments).length ≤ maxSourceLength ∧ Bindings.Printable (program.input arguments) := by
  unfold input
  split
  · exact selected_domain program.fallback arguments
  · simp [Bindings.Printable]

theorem Program.initial_allowed (program : Program) (arguments : Arguments.Runtime.Arguments) :
    program.initialContext.Allows (program.inputValid arguments) (program.input arguments).length false := by
  unfold initialContext inputValid input
  cases hasArguments : program.hasArguments with
  | false => simp [Context.Allows, Region.Contains, Interval.Contains]
  | true =>
      simp only [↓reduceIte]
      cases validity : Arguments.Runtime.inputIsValid arguments with
      | true => exact Context.initial_valid (selected_domain program.fallback arguments).1 false
      | false => rw [selected_invalid program.fallback arguments validity]; exact Context.initial_invalid _ _

theorem Program.initial_fits {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Fits program.names.shape (program.input arguments) (program.initialValues arguments) :=
  declarations_preserve valid.1.1 _ (program.input_domain arguments).2 _ (empty_fits _)

theorem Program.boolean_initializers_safe {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    BooleanDeclarationsSafe program.names.shape (program.initialValues arguments) (program.input arguments)
      (program.inputValid arguments) Integer.emptyStore program.booleanDeclarations Boolean.emptyStore ∧
    checkedBooleanDeclarations (program.initialValues arguments) (program.input arguments)
      (program.inputValid arguments) Integer.emptyStore program.booleanDeclarations Boolean.emptyStore =
        some (program.initialBooleans arguments) := by
  apply boolean_declarations_sound valid.1.2.1 valid.1.2.2.1 (program.initial_fits valid arguments)
  exact ⟨program.initial_allowed arguments, fun _ _ absent => by cases absent⟩

theorem Program.initial_integers {program : Program} (valid : program.Valid) :
    program.initialIntegers = ArrayBindings.integerStore program.arrays.names program.arrays.values program.integerConstants.store ∧
      Integer.DeclarationsSafe [] program.integerDeclarations ∧ program.integerConstants.Valid := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have declarations := ((program.checkBody_iff after).mp checked).1
  have sound := Integer.declarations_sound declarations
  exact ⟨by simp only [initialIntegers, ← sound.1], sound.2,
    Integer.declarations_preserve (by simp [Integer.Constants.Valid]) declarations⟩

theorem Program.initial_integer_fits {program : Program} (valid : program.Valid) :
    Integer.Fits program.bodyRanges program.initialIntegers := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have declarations := ((program.checkBody_iff after).mp checked).1
  have arrays := ((program.checkBody_iff after).mp checked).2.2.1
  rw [initialIntegers, Integer.elaborate_initial_store]
  exact ArrayBindings.body_ranges_fits (ArrayBindings.integerNames program.arrays.names)
    (ArrayBindings.integerNames_initialsFit arrays.2)
    (Integer.ObjectBindings.fits (Integer.elaborate_valid declarations))

theorem Program.body_ranges_bounded {program : Program} (valid : program.Valid) :
    program.bodyAnalysis.declared.Bounded := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have declarations := ((program.checkBody_iff after).mp checked).1
  exact ArrayFlow.ranges_bounded _ (((program.checkBody_iff after).mp checked).2.2.1.2)
    (Integer.ObjectBindings.ranges_bounded (Integer.elaborate_valid declarations))

theorem Program.body_flow_invariant {program : Program} (valid : program.Valid) {after : Flow}
    (checked : program.checkBody = some after) :
    after.scalars.Refines program.bodyRanges ∧ after.scalars.Bounded := by
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  exact statements_ranges_invariant bodyChecked (Integer.Ranges.refines_refl _)
    (program.body_ranges_bounded valid) (program.body_ranges_bounded valid)

theorem Program.execution_sound {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Fits program.names.shape (program.input arguments) (program.execute arguments).values ∧
      EffectsValid (program.execute arguments).effects ∧
      program.checkedExecute arguments = some (program.execute arguments) := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  have sound := statements_execution_sound (booleans := program.initialBooleans arguments) valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2
    ⟨program.initial_allowed arguments, program.initial_integer_fits valid⟩ (program.initial_integer_fits valid)
  exact ⟨sound.state, sound.effects, sound.agreement⟩

theorem Program.scalar_execution_invariant {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Integer.Fits program.bodyRanges (program.execute arguments).integers := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  exact (statements_execution_sound (booleans := program.initialBooleans arguments) valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2
    ⟨program.initial_allowed arguments, program.initial_integer_fits valid⟩ (program.initial_integer_fits valid)).declared

theorem Program.current_scalar_execution_invariant {program : Program} (valid : program.Valid)
    {after : Flow} (checked : program.checkBody = some after)
    (arguments : Arguments.Runtime.Arguments) :
    Integer.Fits after.scalars (program.execute arguments).integers := by
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  exact (statements_execution_sound (booleans := program.initialBooleans arguments) valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2
    ⟨program.initial_allowed arguments, program.initial_integer_fits valid⟩
    (program.initial_integer_fits valid)).scalars

theorem Program.immutable_snapshot_preserved {program : Program} (valid : program.Valid)
    {index : Nat} (readonly : program.bodyMutability index = false)
    (arguments : Arguments.Runtime.Arguments) :
    (program.execute arguments).integers index = program.initialIntegers index := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  exact statements_unchanged bodyChecked readonly

theorem Program.immutable_boolean_preserved {program : Program} (valid : program.Valid)
    {index : Nat} (readonly : program.bodyBooleanAnalysis.mutable index = false)
    (arguments : Arguments.Runtime.Arguments) :
    (program.execute arguments).booleans index = program.initialBooleans arguments index := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  exact statements_booleans_unchanged (((program.checkBody_iff after).mp checked).2.2.2) readonly

theorem Program.invalid_trace {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) (invalid : program.inputValid arguments = false) :
    Effect.reject ∈ (program.execute arguments).effects ∧ NoOutput (program.execute arguments).effects := by
  obtain ⟨after, checked, finished⟩ := valid.2.2.2.2.2
  have allowed := program.initial_allowed arguments
  rw [invalid] at allowed
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  have behavior := completed_invalid_rejected (booleans := program.initialBooleans arguments) valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2
    ⟨allowed, program.initial_integer_fits valid⟩ finished (program.initial_integer_fits valid)
  simpa only [Program.execute, invalid] using behavior

theorem noOutput_accepted_empty (effects : List Effect) (noOutput : NoOutput effects)
    (environments : Sequence.OutputEnvironments) (ordinal : Nat) :
    (Sequence.executeEffects environments ordinal effects).accepted = [] := by
  induction effects generalizing ordinal with
  | nil => rfl
  | cons effect rest ih =>
      have restNoOutput : NoOutput rest := fun effect member => noOutput effect (by simp [member])
      cases effect with
      | output bytes => cases noOutput (.output bytes) (by simp)
      | put bytes => cases noOutput (.put bytes) (by simp)
      | reject =>
          simpa only [Sequence.executeEffects, Sequence.combineResults, Sequence.Effect.execute, List.nil_append]
            using ih restNoOutput (ordinal + 1)

theorem noOutput_rejected_effects (effects : List Effect) (noOutput : NoOutput effects)
    (rejected : Effect.reject ∈ effects) (environments : Sequence.OutputEnvironments) (ordinal : Nat) :
    Sequence.executeEffects environments ordinal effects = ⟨1, []⟩ := by
  cases effects with
  | nil => contradiction
  | cons effect rest =>
      cases effect with
      | output bytes => cases noOutput (.output bytes) (by simp)
      | put bytes => cases noOutput (.put bytes) (by simp)
      | reject =>
          have restNoOutput : NoOutput rest := fun effect member => noOutput effect (by simp [member])
          have empty := noOutput_accepted_empty rest restNoOutput environments (ordinal + 1)
          have bound := (Sequence.trace_outcome_bound
            (Sequence.effects_execution_specified environments (ordinal + 1) rest)).1
          simp only [Sequence.executeEffects, Sequence.combineResults, Sequence.Effect.execute,
            empty, List.nil_append, Nat.max_eq_left bound]

def Program.run (program : Program) (environment : Sequence.Environment) : Output.Runtime.ProcessResult :=
  Sequence.executeEffects environment.output 0 (program.execute environment.arguments).effects

theorem Program.invalid_run {program : Program} (valid : program.Valid)
    (environment : Sequence.Environment) (invalid : program.inputValid environment.arguments = false) :
    program.run environment = ⟨1, []⟩ := by
  have behavior := program.invalid_trace valid environment.arguments invalid
  exact noOutput_rejected_effects _ behavior.2 behavior.1 _ _

theorem Program.healthy_run {program : Program} (valid : program.Valid)
    (environment : Sequence.Environment) (healthy : environment.Healthy) :
    program.run environment =
      ⟨Sequence.expectedEffectStatus (program.execute environment.arguments).effects,
       Sequence.intendedEffectBytes (program.execute environment.arguments).effects⟩ :=
  Sequence.healthy_effects _ healthy _ (program.execution_sound valid environment.arguments).2.1

theorem Program.output_bound {program : Program} (valid : program.Valid) (environment : Sequence.Environment) :
    (program.run environment).accepted.length ≤
      Sequence.outputCount (program.execute environment.arguments).effects * (maxSourceLength + 1) :=
  Sequence.accepted_effects_bound _ _ (program.execution_sound valid environment.arguments).2.1

def declarationChecks (program : Program) : List Compose.Check :=
  (Compose.declarationRangeObligations emptyShape program.names.shape program.declarations).map Compose.Check.range ++
    (Compose.declarationLengthObligations emptyShape program.names.shape program.declarations).map Compose.Check.length

def integerDeclarationChecks (program : Program) : List Integer.Obligation :=
  Integer.declarationObligations [] program.integerDeclarations

def scalarObligation (check : Integer.Obligation) : Semantics.Obligation :=
  ⟨.runTimeSafety, check.discharge⟩

def Program.obligations (program : Program) : List Semantics.Obligation :=
  (declarationChecks program).map Compose.Check.toObligation ++
    (integerDeclarationChecks program ++ program.initializerChecks).map scalarObligation ++
    ((program.booleanInitializerChecks ++ booleanDeclarationObligations program.names.shape
      Integer.Analysis.empty program.booleanInitialFlow {} program.booleanDeclarations).map Obligation.toObligation) ++
    modeledObligations program.names.shape program.bodyAnalysis program.initialFlow program.statements program.bodyBooleanAnalysis

theorem Program.declaration_checks_valid {program : Program} (valid : program.Valid) :
    ∀ check ∈ declarationChecks program, check.Valid := by
  intro check member
  rcases List.mem_append.mp member with range | length
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp range
    apply Guarded.RangeObligation.valid_of_refines (Compose.declaration_schemas valid.1.1 schema present)
    exact Compose.uniform_range_valid _ (by simp [Compose.uniformRangeObligations])
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp length
    exact Compose.declaration_lengths_valid valid.1.1 schema present

theorem Program.integer_declaration_checks_discharge {program : Program} (valid : program.Valid) :
    Integer.discharged (integerDeclarationChecks program) = true := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  exact Integer.declaration_obligations_discharge ((program.checkBody_iff after).mp checked).1

theorem Program.initializer_checks_discharge {program : Program} (valid : program.Valid) :
    Integer.discharged program.initializerChecks = true := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  exact ((program.checkBody_iff after).mp checked).2.1

theorem Program.scalar_checks_discharge {program : Program} (valid : program.Valid) :
    Integer.discharged (integerDeclarationChecks program ++ program.initializerChecks) = true := by
  rw [Integer.discharged_append, program.integer_declaration_checks_discharge valid,
    program.initializer_checks_discharge valid]
  rfl

theorem Program.boolean_initializer_checks_discharge {program : Program} (valid : program.Valid) :
    discharged (program.booleanInitializerChecks ++ booleanDeclarationObligations program.names.shape
      Integer.Analysis.empty program.booleanInitialFlow {} program.booleanDeclarations) = true := by
  rw [discharged_append, valid.1.2.2.2, boolean_declaration_obligations_exact, valid.1.2.2.1]
  rfl

theorem Program.all_obligations_discharge {program : Program} (valid : program.Valid) :
    Semantics.discharge program.obligations = true := by
  apply (Semantics.discharge_iff _).mpr
  intro check member
  rcases List.mem_append.mp member with declarations | body
  · rcases List.mem_append.mp declarations with earlier | booleans
    · rcases List.mem_append.mp earlier with declaration | scalar
      · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp declaration
        exact (Compose.Check.discharge_iff _).mpr (program.declaration_checks_valid valid schema present)
      · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp scalar
        exact List.all_eq_true.mp (program.scalar_checks_discharge valid) schema present
    · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp booleans
      exact List.all_eq_true.mp (program.boolean_initializer_checks_discharge valid) schema present
  · obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
    have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
    exact (Semantics.discharge_iff _).mp (all_modeled_obligations_discharge bodyChecked) check body

/-- Source-reading rules can retain omitted `else` while lowering its meaning
without inventing an effect or bypassing the false path. -/
theorem omitted_else_meaning (condition : Condition) (yes : List Statement)
    (input : Source) (valid : Bool) (values : Values) (integers : Integer.Store := Integer.emptyStore)
    (booleans : Boolean.Store := Boolean.emptyStore) :
    (Statement.choice condition yes []).execute input valid values integers booleans =
      if condition.evaluate values input valid integers booleans then executeStatements input valid values yes integers booleans
      else ⟨values, [], integers, booleans⟩ := by
  simp only [Statement.execute, executeStatements]

/-- An `elsif` tests its predicate only after all preceding tests were false;
its normalized representation preserves that evaluation order. -/
theorem elsif_meaning (condition next : Condition) (yes following no : List Statement)
    (input : Source) (valid : Bool) (values : Values) (integers : Integer.Store := Integer.emptyStore)
    (booleans : Boolean.Store := Boolean.emptyStore) :
    (Statement.choice condition yes [.choice next following no]).execute input valid values integers booleans =
      if condition.evaluate values input valid integers booleans then executeStatements input valid values yes integers booleans
      else if next.evaluate values input valid integers booleans then executeStatements input valid values following integers booleans
      else executeStatements input valid values no integers booleans := by
  simp only [Statement.execute, executeStatements, List.append_nil]

end Silver.Predicate
