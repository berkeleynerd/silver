module

public import Silver.SequenceSyntax

@[expose] public section

/-! Assignments update the current store; each output records a returning call.
No output or rejection effect terminates execution of subsequent statements. -/

namespace Silver.Sequence
open Bindings Compose

structure Execution where
  values : Values
  effects : List Effect

def SimpleStatement.execute (input : Source) (values : Values) : SimpleStatement → Execution
  | .null => ⟨values, []⟩
  | .assign update => ⟨update.execute values input, []⟩
  | .output expression => ⟨values, [.output (expression.evaluate values input)]⟩

def executeSimple (input : Source) (values : Values) : List SimpleStatement → Execution
  | [] => ⟨values, []⟩
  | item :: rest =>
      let first := item.execute input values
      let following := executeSimple input first.values rest
      ⟨following.values, first.effects ++ following.effects⟩

mutual
  def Statement.execute (input : Source) (values : Values) : Statement → Execution
    | .simple item => item.execute input values
    | .choice left right yes tail =>
        if left.evaluate values input = right.evaluate values input
        then executeStatements input values yes else tail.execute input values
  termination_by item => sizeOf item
  def Alternative.execute (input : Source) (values : Values) : Alternative → Execution
    | .absent => ⟨values, []⟩
    | .otherwise items => executeStatements input values items
    | .elsif left right yes tail =>
        if left.evaluate values input = right.evaluate values input
        then executeStatements input values yes else tail.execute input values
  termination_by tail => sizeOf tail
  def executeStatements (input : Source) (values : Values) : List Statement → Execution
    | [] => ⟨values, []⟩
    | item :: rest =>
        let first := item.execute input values
        let following := executeStatements input first.values rest
        ⟨following.values, first.effects ++ following.effects⟩
  termination_by items => sizeOf items
end

def Shell.guard (input : Source) (arguments : Arguments.Runtime.Arguments) : Shell → Bool
  | .static => true
  | .argument => Arguments.Runtime.inputIsValid arguments
  | .guardedArgument bound => Arguments.Runtime.inputIsValid arguments && decide (input.length ≤ bound)

def Body.execute (arguments : Arguments.Runtime.Arguments) (input : Source)
    (values : Values) (body : Body) : Execution :=
  if body.shell.guard input arguments then executeStatements input values body.statements
  else ⟨values, [.reject]⟩

def Program.initialValues (program : Program) (arguments : Arguments.Runtime.Arguments) : Values :=
  executeDeclarations (selected program.fallback arguments) program.declarations emptyValues

def Program.execute (arguments : Arguments.Runtime.Arguments) (program : Program) : Execution :=
  program.body.execute arguments (selected program.fallback arguments) (program.initialValues arguments)

def Program.effects (arguments : Arguments.Runtime.Arguments) (program : Program) : List Effect :=
  (program.execute arguments).effects

theorem effects_valid_append {left right : List Effect}
    (first : EffectsValid left) (second : EffectsValid right) : EffectsValid (left ++ right) := by
  intro effect member
  rcases List.mem_append.mp member with member | member
  · exact first effect member
  · exact second effect member

theorem simple_execution_valid {item : SimpleStatement} {shape : Shape} {capacity : Nat}
    {input : Source} {values : Values} (valid : item.Valid shape capacity)
    (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
    Fits shape input (item.execute input values).values ∧
      EffectsValid (item.execute input values).effects := by
  cases item with
  | null => exact ⟨state, by simp [SimpleStatement.execute, EffectsValid]⟩
  | assign update =>
      exact ⟨assignment_preserves state printable valid.1,
        by simp [SimpleStatement.execute, EffectsValid]⟩
  | output expression =>
      refine ⟨state, ?_⟩
      intro effect member
      simp only [SimpleStatement.execute, List.mem_singleton] at member
      subst effect
      exact expression_domain valid state printable bound

theorem simple_sequence_valid {items : List SimpleStatement} {shape : Shape} {capacity : Nat}
    {input : Source} {values : Values} (valid : SimpleStatementsValid shape capacity items)
    (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
    Fits shape input (executeSimple input values items).values ∧
      EffectsValid (executeSimple input values items).effects := by
  induction items generalizing values with
  | nil => exact ⟨state, by simp [executeSimple, EffectsValid]⟩
  | cons item rest ih =>
      have first := simple_execution_valid (valid item (by simp)) state printable bound
      have following := ih (fun item member => valid item (by simp [member])) first.1
      exact ⟨following.1, effects_valid_append first.2 following.2⟩

mutual
  theorem statement_execution_valid {item : Statement} {shape : Shape} {capacity : Nat}
      {input : Source} {values : Values} (valid : item.Valid shape capacity)
      (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
      Fits shape input (item.execute input values).values ∧
        EffectsValid (item.execute input values).effects := by
    cases item with
    | simple item =>
        simp only [Statement.Valid] at valid
        simpa only [Statement.execute] using simple_execution_valid valid state printable bound
    | choice left right yes tail =>
        simp only [Statement.Valid] at valid
        simp only [Statement.execute]
        split
        · exact statements_execution_valid valid.2.2.2.1 state printable bound
        · exact alternative_execution_valid valid.2.2.2.2 state printable bound
  termination_by sizeOf item

  theorem alternative_execution_valid {tail : Alternative} {shape : Shape} {capacity : Nat}
      {input : Source} {values : Values} (valid : tail.Valid shape capacity)
      (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
      Fits shape input (tail.execute input values).values ∧
        EffectsValid (tail.execute input values).effects := by
    cases tail with
    | absent => simpa only [Alternative.execute] using And.intro state (by simp [EffectsValid])
    | otherwise items =>
        simp only [Alternative.Valid] at valid
        simpa only [Alternative.execute] using statements_execution_valid valid.2 state printable bound
    | elsif left right yes tail =>
        simp only [Alternative.Valid] at valid
        simp only [Alternative.execute]
        split
        · exact statements_execution_valid valid.2.2.2.1 state printable bound
        · exact alternative_execution_valid valid.2.2.2.2 state printable bound
  termination_by sizeOf tail

  theorem statements_execution_valid {items : List Statement} {shape : Shape} {capacity : Nat}
      {input : Source} {values : Values} (valid : StatementsValid shape capacity items)
      (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
      Fits shape input (executeStatements input values items).values ∧
        EffectsValid (executeStatements input values items).effects := by
    cases items with
    | nil => simpa only [executeStatements] using And.intro state (by simp [EffectsValid])
    | cons item rest =>
        simp only [StatementsValid] at valid
        have first := statement_execution_valid valid.1 state printable bound
        have following := statements_execution_valid valid.2 first.1 printable bound
        simpa only [executeStatements] using
          And.intro following.1 (effects_valid_append first.2 following.2)
  termination_by sizeOf items
end

theorem shell_guard_bound {shell : Shell} {input : Source}
    {arguments : Arguments.Runtime.Arguments} (domain : input.length ≤ maxSourceLength)
    (accepted : shell.guard input arguments = true) : input.length ≤ shell.capacity := by
  cases shell with
  | static | argument => exact domain
  | guardedArgument capacity =>
      simp only [Shell.guard, Bool.and_eq_true, decide_eq_true_eq] at accepted
      exact accepted.2

theorem body_execution_valid {body : Body} {shape : Shape} {input : Source} {values : Values}
    (valid : body.Valid shape) (state : Fits shape input values)
    (domain : input.length ≤ maxSourceLength ∧ Bindings.Printable input)
    (arguments : Arguments.Runtime.Arguments) :
    Fits shape input (body.execute arguments input values).values ∧
      EffectsValid (body.execute arguments input values).effects := by
  simp only [Body.execute]
  split
  · rename_i accepted
    exact statements_execution_valid valid.2.2 state domain.2 (shell_guard_bound domain.1 accepted)
  · exact ⟨state, by simp [EffectsValid, Effect.Valid]⟩

theorem initial_values_fit {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Fits program.names.shape (selected program.fallback arguments) (program.initialValues arguments) :=
  declarations_preserve valid.1 _ (selected_domain program.fallback arguments).2 _ (empty_fits _)

theorem program_execution_valid {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Fits program.names.shape (selected program.fallback arguments) (program.execute arguments).values ∧
      EffectsValid (program.effects arguments) :=
  body_execution_valid valid.2.2.2 (initial_values_fit valid arguments)
    (selected_domain program.fallback arguments) arguments

/-- Appending statements runs their effects even when earlier calls fail.
Failures are resolved by the effect interpreter, without altering this trace. -/
theorem execute_statements_append (input : Source) (values : Values)
    (first rest : List Statement) :
    executeStatements input values (first ++ rest) =
      let before := executeStatements input values first
      let after := executeStatements input before.values rest
      ⟨after.values, before.effects ++ after.effects⟩ := by
  induction first generalizing values with
  | nil => simp [executeStatements]
  | cons item items ih => simp [executeStatements, ih, List.append_assoc]

end Silver.Sequence
