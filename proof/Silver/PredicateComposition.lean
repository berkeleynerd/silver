module

public import Silver.PredicateExecution
public import Silver.PredicateObligations
public import Silver.SequenceEffects

@[expose] public section

/-! The shared declaration model initializes predicate-control programs. All
arguments receive one universal execution theorem; effect interpretation reuses
the returning-call trace model, including sticky failure and repeated output. -/

namespace Silver.Predicate
open Bindings Compose PathFacts
open Sequence (Execution Effect EffectsValid)

structure Program where
  declarations : List Declaration
  names : Compose.BindingEnvironment
  fallback : Source
  hasArguments : Bool
  statements : List Statement
  integerDeclarations : List Integer.Declaration := []
  integerConstants : Integer.Constants := []
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
  (Integer.executeDeclarations [] program.integerDeclarations).store

def Program.checkBody (program : Program) : Option Context :=
  if Integer.checkDeclarations [] program.integerDeclarations = some program.integerConstants then
    checkStatements program.names.shape program.initialContext program.statements program.integerConstants.ranges
  else none

theorem Program.checkBody_iff (program : Program) (after : Context) :
    program.checkBody = some after ↔
      Integer.checkDeclarations [] program.integerDeclarations = some program.integerConstants ∧
      checkStatements program.names.shape program.initialContext program.statements program.integerConstants.ranges = some after := by
  simp only [checkBody]
  split <;> simp_all

def Program.execute (program : Program) (arguments : Arguments.Runtime.Arguments) : Execution :=
  executeStatements (program.input arguments) (program.inputValid arguments)
    (program.initialValues arguments) program.statements program.initialIntegers

def Program.checkedExecute (program : Program) (arguments : Arguments.Runtime.Arguments) : Option Execution :=
  checkedStatements (program.input arguments) (program.inputValid arguments)
    (program.initialValues arguments) program.statements program.initialIntegers

def Program.Valid (program : Program) : Prop :=
  DeclarationsValid emptyShape program.declarations program.names.shape ∧
    Bindings.Printable program.fallback ∧ program.fallback.length ≤ maxSourceLength ∧
    program.statements ≠ [] ∧ StatementsWellFormed program.hasArguments program.names.shape program.statements ∧
    ∃ after, program.checkBody = some after ∧ completed after = true

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
  declarations_preserve valid.1 _ (program.input_domain arguments).2 _ (empty_fits _)

theorem Program.initial_integers {program : Program} (valid : program.Valid) :
    program.initialIntegers = program.integerConstants.store ∧
      Integer.DeclarationsSafe [] program.integerDeclarations ∧ program.integerConstants.Valid := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have declarations := ((program.checkBody_iff after).mp checked).1
  have sound := Integer.declarations_sound declarations
  exact ⟨by simp only [initialIntegers, ← sound.1], sound.2,
    Integer.declarations_preserve (by simp [Integer.Constants.Valid]) declarations⟩

theorem Program.initial_integer_fits {program : Program} (valid : program.Valid) :
    Integer.Fits program.integerConstants.ranges program.initialIntegers := by
  rw [(program.initial_integers valid).1]
  exact program.integerConstants.fits

theorem Program.execution_sound {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Fits program.names.shape (program.input arguments) (program.execute arguments).values ∧
      EffectsValid (program.execute arguments).effects ∧
      program.checkedExecute arguments = some (program.execute arguments) := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have bodyChecked := ((program.checkBody_iff after).mp checked).2
  have sound := statements_execution_sound valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2 (program.initial_allowed arguments)
    (program.initial_integer_fits valid)
  exact ⟨sound.state, sound.effects, sound.agreement⟩

theorem Program.invalid_trace {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) (invalid : program.inputValid arguments = false) :
    Effect.reject ∈ (program.execute arguments).effects ∧ NoOutput (program.execute arguments).effects := by
  obtain ⟨after, checked, finished⟩ := valid.2.2.2.2.2
  have allowed := program.initial_allowed arguments
  rw [invalid] at allowed
  have bodyChecked := ((program.checkBody_iff after).mp checked).2
  have behavior := completed_invalid_rejected valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2 allowed finished
    (program.initial_integer_fits valid)
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
    (integerDeclarationChecks program).map scalarObligation ++
    modeledObligations program.names.shape program.initialContext program.statements program.integerConstants.ranges

theorem Program.declaration_checks_valid {program : Program} (valid : program.Valid) :
    ∀ check ∈ declarationChecks program, check.Valid := by
  intro check member
  rcases List.mem_append.mp member with range | length
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp range
    apply Guarded.RangeObligation.valid_of_refines (Compose.declaration_schemas valid.1 schema present)
    exact Compose.uniform_range_valid _ (by simp [Compose.uniformRangeObligations])
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp length
    exact Compose.declaration_lengths_valid valid.1 schema present

theorem Program.integer_declaration_checks_discharge {program : Program} (valid : program.Valid) :
    Integer.discharged (integerDeclarationChecks program) = true := by
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  exact Integer.declaration_obligations_discharge ((program.checkBody_iff after).mp checked).1

theorem Program.all_obligations_discharge {program : Program} (valid : program.Valid) :
    Semantics.discharge program.obligations = true := by
  apply (Semantics.discharge_iff _).mpr
  intro check member
  rcases List.mem_append.mp member with declarations | body
  · rcases List.mem_append.mp declarations with declaration | scalar
    · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp declaration
      exact (Compose.Check.discharge_iff _).mpr (program.declaration_checks_valid valid schema present)
    · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp scalar
      exact List.all_eq_true.mp (program.integer_declaration_checks_discharge valid) schema present
  · obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
    have bodyChecked := ((program.checkBody_iff after).mp checked).2
    exact (Semantics.discharge_iff _).mp (all_modeled_obligations_discharge bodyChecked) check body

/-- Source-reading rules can retain omitted `else` while lowering its meaning
without inventing an effect or bypassing the false path. -/
theorem omitted_else_meaning (condition : Condition) (yes : List Statement)
    (input : Source) (valid : Bool) (values : Values) :
    (Statement.choice condition yes []).execute input valid values =
      if condition.evaluate values input valid then executeStatements input valid values yes else ⟨values, []⟩ := by
  simp only [Statement.execute, executeStatements]

/-- An `elsif` tests its predicate only after all preceding tests were false;
its normalized representation preserves that evaluation order. -/
theorem elsif_meaning (condition next : Condition) (yes following no : List Statement)
    (input : Source) (valid : Bool) (values : Values) :
    (Statement.choice condition yes [.choice next following no]).execute input valid values =
      if condition.evaluate values input valid then executeStatements input valid values yes
      else if next.evaluate values input valid then executeStatements input valid values following
      else executeStatements input valid values no := by
  simp only [Statement.execute, executeStatements, List.append_nil]

end Silver.Predicate
