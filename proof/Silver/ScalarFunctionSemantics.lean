module

public import Silver.ScalarFunctionDefinition

@[expose] public section

namespace Silver.ScalarFunctions
open Bindings Predicate

private theorem iterations_effectless
    (step : Values → Integer.Store → Boolean.Store → Int → Execution)
    (pure : ∀ values integers booleans value, (step values integers booleans value).effects = [])
    (values : Values) (integers : Integer.Store) (booleans : Boolean.Store) (items : List Int) :
    (executeIterations step values integers booleans items).effects = [] := by
  induction items generalizing values integers booleans with
  | nil => rfl
  | cons value rest ih => simp only [executeIterations, pure, ih, List.nil_append]

mutual
  theorem pure_statement_effectless (earlier : Environment) (item : Statement)
      (pure : pureStatement item = true) (values : Values) (integers : Integer.Store)
      (booleans : Boolean.Store) :
      (item.execute [] true values integers booleans earlier).effects = [] := by
    cases item with
    | simple item => cases item <;> simp_all [pureStatement, Statement.execute, executeSimpleStatement]
    | scalarAssign | callAssign | booleanAssign => simp only [Statement.execute]
    | procedureCall | arrayAssign | booleanArrayAssign | reject | arrayLoop => simp only [pureStatement, Bool.false_eq_true] at pure
    | choice condition yes no =>
        have both : pureStatements yes = true ∧ pureStatements no = true := by
          simpa only [pureStatement, Bool.and_eq_true] using pure
        simp only [Statement.execute]
        split
        · exact pure_statements_effectless earlier yes both.1 values integers booleans
        · exact pure_statements_effectless earlier no both.2 values integers booleans
    | forLoop index reverse lower upper body =>
        simp only [Statement.execute]
        apply iterations_effectless
        intro current scalars flags value
        simpa only [Execution.restoreIndex] using pure_statements_effectless earlier body
          (by simpa only [pureStatement] using pure) current (Integer.put scalars index value) flags
  termination_by sizeOf item
  theorem pure_statements_effectless (earlier : Environment) (items : List Statement)
      (pure : pureStatements items = true) (values : Values) (integers : Integer.Store)
      (booleans : Boolean.Store) :
      (executeStatements [] true values items integers booleans earlier).effects = [] := by
    cases items with
    | nil => simp only [executeStatements]
    | cons item rest =>
        have both : pureStatement item = true ∧ pureStatements rest = true := by
          simpa only [pureStatements, Bool.and_eq_true] using pure
        simp only [executeStatements, pure_statement_effectless earlier item both.1,
          pure_statements_effectless earlier rest both.2, List.nil_append]
  termination_by sizeOf items
end

theorem entryContext_allows (rejected : Bool) : entryContext.Allows true 0 rejected := by
  simp [entryContext, PathFacts.Context.Allows, PathFacts.Region.Contains, PathFacts.Interval.Contains]

theorem Definition.local_fits {definition : Definition} {earlier : Signatures} {after : Flow}
    (checked : definition.check earlier = some after) :
    Integer.Fits definition.localAnalysis.declared definition.localFrame.integers := by
  obtain ⟨constants, declarations⟩ := ((definition.check_iff earlier after).mp checked).1
  simp only [localFrame, localAnalysis, Integer.Analysis.ofDeclarations]
  rw [Integer.elaborate_initial_store]
  exact Integer.ObjectBindings.fits (Integer.elaborate_valid declarations)

theorem Definition.frame_fits {definition : Definition} {earlier : Signatures} {after : Flow}
    (checked : definition.check earlier = some after) {arguments : List Value}
    (fitting : ArgumentsFit definition.signature.formals arguments) :
    Integer.Fits definition.analysis.declared (definition.frame arguments).integers := by
  simp only [analysis, parameterAnalysis_declared, frame]
  exact bindArguments_fits fitting _ _ _ _
    (bindArrayArguments_fits fitting 1 _ _ (definition.local_fits checked))

theorem Definition.initializers_safe {definition : Definition} {earlier : Signatures} {after : Flow}
    (formed : definition.WellFormed) (checked : definition.check earlier = some after) :
    Integer.DeclarationsSafe [] definition.integers ∧
      BooleanDeclarationsSafe emptyShape emptyValues [] true definition.localFrame.integers
        definition.booleans Boolean.emptyStore ∧
      checkedBooleanDeclarations emptyValues [] true definition.localFrame.integers
        definition.booleans Boolean.emptyStore = some definition.localFrame.booleans := by
  have checks := (definition.check_iff earlier after).mp checked
  obtain ⟨constants, declarations⟩ := checks.1
  have locals := boolean_declarations_sound (booleans := Boolean.emptyStore) formed.2.1 checks.2.2.2.1 (empty_fits [])
    (show definition.localFlow.Allows true 0 false definition.localFrame.integers from
      ⟨entryContext_allows false, definition.local_fits checked⟩)
  exact ⟨(Integer.declarations_sound declarations).2, locals⟩

theorem Definition.body_sound {earlier : Environment} {definition : Definition} {after : Flow}
    (certified : earlier.Valid) (formed : definition.WellFormed)
    (checked : definition.check earlier.signatures = some after) {arguments : List Value}
    (fitting : ArgumentsFit definition.signature.formals arguments) :
    ExecutionSound emptyShape definition.analysis after [] true false
      (definition.executeBody earlier arguments)
      (checkedStatements [] true emptyValues definition.body
        (definition.frame arguments).integers (definition.frame arguments).booleans earlier) := by
  have checks := (definition.check_iff earlier.signatures after).mp checked
  have state := definition.frame_fits checked fitting
  exact statements_execution_sound certified formed.2.2.1 checks.2.2.2.2.2.1 (empty_fits [])
    (by simp [Bindings.Printable]) ⟨entryContext_allows false, state⟩ state

theorem Definition.execute_effectless {earlier : Environment} {definition : Definition} {after : Flow}
    (checked : definition.check earlier.signatures = some after) (arguments : List Value) :
    (definition.executeBody earlier arguments).effects = [] :=
  pure_statements_effectless earlier definition.body
    ((definition.check_iff earlier.signatures after).mp checked).2.2.2.2.1 _ _ _

/-- Full-body checked execution and the terminal expression succeed for the
entire product of formal domains; the caller contributes no other facts. -/
theorem Definition.execution_sound {earlier : Environment} {definition : Definition}
    (certified : earlier.Valid) (checked : definition.Checked earlier.signatures)
    (arguments : List Value) (fitting : ArgumentsFit definition.signature.formals arguments) :
    definition.signature.result.Contains (definition.execute earlier arguments) ∧
      definition.checkedExecute earlier arguments = some (definition.execute earlier arguments) ∧
      (definition.executeBody earlier arguments).effects = [] ∧
      definition.result.Safe emptyShape
        ⟨(definition.executeBody earlier arguments).values, [], true,
          (definition.executeBody earlier arguments).integers, (definition.executeBody earlier arguments).booleans⟩ := by
  obtain ⟨formed, after, bodyChecked⟩ := checked
  have checks := (definition.check_iff earlier.signatures after).mp bodyChecked
  have body := definition.body_sound certified formed bodyChecked fitting
  have returned := definition.result.check_sound
    (state := ⟨(definition.executeBody earlier arguments).values, [], true,
      (definition.executeBody earlier arguments).integers, (definition.executeBody earlier arguments).booleans⟩) body.state formed.2.2.2.1
    ⟨body.next, body.scalars⟩ checks.2.2.2.2.2.2
  have agreement := definition.result.checkedEvaluate_agrees body.state returned.1
  refine ⟨returned.2, ?_, definition.execute_effectless bodyChecked arguments, returned.1⟩
  have contained := (ScalarType.contains_iff _ _).mpr returned.2
  simp only [checkedExecute, body.agreement, Option.bind_some, agreement, contained, ↓reduceIte, execute]

end Silver.ScalarFunctions
