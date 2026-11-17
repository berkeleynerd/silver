module

public import Silver.ScalarProcedureDefinition
public import Silver.ScalarFunctionSemantics

@[expose] public section

namespace Silver.ScalarProcedures
open Bindings Predicate
open ScalarFunctions (ArgumentsFit)

private theorem iterations_effectless
    (step : Values → Integer.Store → Boolean.Store → Int → Execution)
    (pure : ∀ values integers booleans value, (step values integers booleans value).effects = [])
    (values : Values) (integers : Integer.Store) (booleans : Boolean.Store) (items : List Int) :
    (executeIterations step values integers booleans items).effects = [] := by
  induction items generalizing values integers booleans with
  | nil => rfl
  | cons value rest ih => simp only [executeIterations, pure, ih, List.nil_append]

mutual
  theorem scalar_statement_effectless (functions : ScalarFunctions.Environment) (earlier : Environment)
      (item : Statement) (closed : scalarStatement item = true)
      (values : Values) (integers : Integer.Store) (booleans : Boolean.Store) :
      (item.execute [] true values integers booleans functions earlier).effects = [] := by
    cases item with
    | simple item => cases item <;> simp_all [scalarStatement, Statement.execute, executeSimpleStatement]
    | scalarAssign | callAssign | procedureCall | booleanAssign => simp only [Statement.execute]
    | arrayAssign | booleanArrayAssign | reject | arrayLoop =>
        simp only [scalarStatement, Bool.false_eq_true] at closed
    | choice condition yes no =>
        have both : (ScalarFunctions.scalarCondition condition = true ∧ scalarStatements yes = true) ∧
            scalarStatements no = true := by
          simpa only [scalarStatement, Bool.and_eq_true] using closed
        simp only [Statement.execute]
        split
        · exact scalar_statements_effectless functions earlier yes both.1.2 values integers booleans
        · exact scalar_statements_effectless functions earlier no both.2 values integers booleans
    | forLoop index reverse lower upper body =>
        simp only [scalarStatement, Bool.and_eq_true] at closed
        have bodyClosed : scalarStatements body = true := closed.2
        simp only [Statement.execute]
        apply iterations_effectless
        intro current scalars flags value
        simpa only [Execution.restoreIndex] using scalar_statements_effectless functions earlier body
          bodyClosed current (Integer.put scalars index value) flags
  termination_by sizeOf item
  theorem scalar_statements_effectless (functions : ScalarFunctions.Environment) (earlier : Environment)
      (items : List Statement) (closed : scalarStatements items = true)
      (values : Values) (integers : Integer.Store) (booleans : Boolean.Store) :
      (executeStatements [] true values items integers booleans functions earlier).effects = [] := by
    cases items with
    | nil => simp only [executeStatements]
    | cons item rest =>
        have both : scalarStatement item = true ∧ scalarStatements rest = true := by
          simpa only [scalarStatements, Bool.and_eq_true] using closed
        simp only [executeStatements, scalar_statement_effectless functions earlier item both.1,
          scalar_statements_effectless functions earlier rest both.2, List.nil_append]
  termination_by sizeOf items
end

theorem Definition.local_fits {definition : Definition} {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {after : Flow} (checked : definition.check functions earlier = some after) :
    Integer.Fits definition.localAnalysis.declared definition.localFrame.integers := by
  have ready := (definition.ready_iff functions).mp ((definition.check_iff functions earlier after).mp checked).1
  obtain ⟨constants, declarations⟩ := ((definition.localCheck_iff).mp ready.1).1
  simp only [localFrame, localAnalysis, Integer.Analysis.ofDeclarations]
  rw [Integer.elaborate_initial_store]
  exact Integer.ObjectBindings.fits (Integer.elaborate_valid declarations)

theorem Definition.inputFrame_fits {definition : Definition} {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {after : Flow} (checked : definition.check functions earlier = some after)
    {inputs : List ScalarFunctions.Value} (fitting : ArgumentsFit (inputTypes definition.signature.formals) inputs) :
    Integer.Fits definition.inputAnalysis.declared (definition.inputFrame inputs).integers := by
  simp only [inputAnalysis, parameterAnalysis_declared, inputFormals_domains, inputFrame]
  exact ScalarFunctions.bindArguments_fits fitting _ _ _ _ (definition.local_fits checked)

theorem Definition.initializers_safe {definition : Definition} {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {after : Flow} (formed : definition.WellFormed)
    (checked : definition.check functions earlier = some after) :
    Integer.DeclarationsSafe [] definition.integers ∧
      BooleanDeclarationsSafe emptyShape emptyValues [] true definition.localFrame.integers
        definition.booleans Boolean.emptyStore ∧
      checkedBooleanDeclarations emptyValues [] true definition.localFrame.integers
        definition.booleans Boolean.emptyStore = some definition.localFrame.booleans := by
  have ready := (definition.ready_iff functions).mp ((definition.check_iff functions earlier after).mp checked).1
  have localChecks := definition.localCheck_iff.mp ready.1
  obtain ⟨constants, declarations⟩ := localChecks.1
  have locals := boolean_declarations_sound (booleans := Boolean.emptyStore) formed.2.1 localChecks.2.2.2 (empty_fits [])
    (show definition.localFlow.Allows true 0 false definition.localFrame.integers from
      ⟨ScalarFunctions.entryContext_allows false, definition.local_fits checked⟩)
  exact ⟨(Integer.declarations_sound declarations).2, locals⟩

/-- Every mandatory prefix RHS is evaluated against the same initialized
local/input frame. The output tuple is then bound before any ordinary statement. -/
theorem Definition.prefix_sound {definition : Definition} {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {after : Flow} (formed : definition.WellFormed)
    (checked : definition.check functions earlier = some after)
    {inputs : List ScalarFunctions.Value} (fitting : ArgumentsFit (inputTypes definition.signature.formals) inputs) :
    (∀ actual ∈ definition.initializers, actual.Safe emptyShape (definition.prefixState inputs)) ∧
      ArgumentsFit (outTypes definition.signature.formals)
        (ScalarFunctions.evaluateActuals (definition.prefixState inputs) definition.initializers) := by
  have ready := (definition.ready_iff functions).mp ((definition.check_iff functions earlier after).mp checked).1
  exact ScalarFunctions.checkActuals_sound (empty_fits []) formed.2.2.1
    (show definition.prefixFlow.Allows true 0 false (definition.inputFrame inputs).integers from
      ⟨ScalarFunctions.entryContext_allows false, definition.inputFrame_fits checked fitting⟩) ready.2.1

theorem Definition.frame_fits {definition : Definition} {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {after : Flow} (formed : definition.WellFormed)
    (checked : definition.check functions earlier = some after)
    {inputs : List ScalarFunctions.Value} (fitting : ArgumentsFit (inputTypes definition.signature.formals) inputs) :
    Integer.Fits definition.analysis.declared (definition.frame inputs).integers := by
  have outputs := (definition.prefix_sound formed checked fitting).2
  simp only [analysis, parameterAnalysis_declared, outFormals_domains, frame, frameWithOutputs]
  exact ScalarFunctions.bindArguments_fits outputs _ _ _ _ (definition.inputFrame_fits checked fitting)

theorem Definition.body_sound {functions : ScalarFunctions.Environment} {earlier : Environment}
    {definition : Definition} {after : Flow} (functionValid : functions.Valid) (procedureValid : earlier.Valid)
    (formed : definition.WellFormed) (checked : definition.check functions.signatures earlier.signatures = some after)
    {inputs : List ScalarFunctions.Value} (fitting : ArgumentsFit (inputTypes definition.signature.formals) inputs) :
    ExecutionSound emptyShape definition.analysis after [] true false
      (definition.executeBody functions earlier inputs)
      (checkedStatements [] true emptyValues definition.body
        (definition.frame inputs).integers (definition.frame inputs).booleans
        (functionPrefix functions definition.functionCount) earlier) := by
  have checks := (definition.check_iff functions.signatures earlier.signatures after).mp checked
  have state := definition.frame_fits formed checked fitting
  exact statements_execution_sound_with_procedures (functionPrefix_valid functionValid _) procedureValid
    formed.2.2.2.2 checks.2 (empty_fits []) (by simp [Bindings.Printable])
    ⟨ScalarFunctions.entryContext_allows false, state⟩ state

theorem Definition.execute_effectless {functions : ScalarFunctions.Environment} {earlier : Environment}
    {definition : Definition} {after : Flow}
    (checked : definition.check functions.signatures earlier.signatures = some after)
    (inputs : List ScalarFunctions.Value) :
    (definition.executeBody functions earlier inputs).effects = [] := by
  have ready := (definition.ready_iff functions.signatures).mp
    ((definition.check_iff functions.signatures earlier.signatures after).mp checked).1
  have bodyClosed : scalarStatements definition.body = true := (Bool.and_eq_true_iff.mp ready.2.2.2.1).2
  exact scalar_statements_effectless _ _ _ bodyClosed _ _ _

/-- Every fitting input tuple produces fitting outputs, agrees with checked
execution, has no body effects and makes every output read safe. -/
theorem Definition.execution_sound {functions : ScalarFunctions.Environment} {earlier : Environment}
    {definition : Definition} (functionValid : functions.Valid) (procedureValid : earlier.Valid)
    (checked : definition.Checked functions.signatures earlier.signatures)
    (inputs : List ScalarFunctions.Value) (fitting : ArgumentsFit (inputTypes definition.signature.formals) inputs) :
    ArgumentsFit (outputTypes definition.signature.formals) (definition.execute functions earlier inputs) ∧
      definition.checkedExecute functions earlier inputs = some (definition.execute functions earlier inputs) ∧
      (definition.executeBody functions earlier inputs).effects = [] ∧
      (∀ actual ∈ definition.outputReads, actual.Safe emptyShape
        ⟨(definition.executeBody functions earlier inputs).values, [], true,
          (definition.executeBody functions earlier inputs).integers,
          (definition.executeBody functions earlier inputs).booleans⟩) := by
  obtain ⟨formed, after, bodyChecked⟩ := checked
  have ready := (definition.ready_iff functions.signatures).mp
    ((definition.check_iff functions.signatures earlier.signatures after).mp bodyChecked).1
  have initializedPrefix := definition.prefix_sound formed bodyChecked fitting
  have prefixAgreement := ScalarFunctions.checkedActuals_agrees (empty_fits []) initializedPrefix.1
  have body := definition.body_sound functionValid procedureValid formed bodyChecked fitting
  have returned := ScalarFunctions.checkActuals_sound
    (state := ⟨(definition.executeBody functions earlier inputs).values, [], true,
      (definition.executeBody functions earlier inputs).integers,
      (definition.executeBody functions earlier inputs).booleans⟩)
    body.state formed.2.2.2.1
    (show definition.initialFlow.Allows true 0 false (definition.executeBody functions earlier inputs).integers from
      ⟨ScalarFunctions.entryContext_allows false, body.declared⟩) ready.2.2.1
  have outputAgreement := ScalarFunctions.checkedActuals_agrees body.state returned.1
  refine ⟨returned.2, ?_, definition.execute_effectless bodyChecked inputs, returned.1⟩
  have contained := (ScalarFunctions.checkArguments_iff _ _).mpr returned.2
  simp only [checkedExecute, prefixAgreement, Option.bind_some]
  change ((checkedStatements [] true emptyValues definition.body (definition.frame inputs).integers
    (definition.frame inputs).booleans (functionPrefix functions definition.functionCount) earlier).bind _) = _
  simp only [body.agreement, Option.bind_some, outputAgreement, contained, ↓reduceIte, execute]

end Silver.ScalarProcedures
