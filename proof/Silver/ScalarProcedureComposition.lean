module

public import Silver.ScalarProcedureSemantics
public import Silver.ScalarProcedureAliasing

@[expose] public section

/-! Every procedure meaning is constructed from its checked body and exact
earlier procedure prefix. Its own function prefix is retained by the definition.
The fold proves unused bodies as well as definitions reached from Main. -/
namespace Silver.ScalarProcedures
open Bindings Predicate
open ScalarFunctions (ArgumentsFit)

def Environment.extend (functions : ScalarFunctions.Environment) (earlier : Environment)
    (definition : Definition) : Environment :=
  ⟨earlier.signatures ++ [definition.signature],
    fun identity inputs => if identity = earlier.signatures.length + 1
      then definition.execute functions earlier inputs else earlier.values identity inputs⟩

theorem Environment.extend_valid {functions : ScalarFunctions.Environment}
    {earlier : Environment} {definition : Definition}
    (functionValid : functions.Valid) (valid : earlier.Valid)
    (checked : definition.Checked functions.signatures earlier.signatures) :
    (earlier.extend functions definition).Valid := by
  intro identity signature found inputs fitting
  by_cases newest : identity = earlier.signatures.length + 1
  · subst identity
    have same : definition.signature = signature := by
      simpa only [Environment.extend, lookup_append_new, Option.some.injEq] using found
    subst signature
    simpa only [Environment.extend, ↓reduceIte] using
      (definition.execution_sound functionValid valid checked inputs fitting).1
  · have positive := lookup_nonzero found
    have old : lookup earlier.signatures identity = some signature := by
      simp only [Environment.extend, lookup, positive, ↓reduceIte] at found ⊢
      have inside := (List.getElem?_eq_some_iff.mp found).1
      have limit : identity - 1 < earlier.signatures.length := by
        simp only [List.length_append, List.length_singleton] at inside
        omega
      simpa only [List.getElem?_append_left limit] using found
    simpa only [Environment.extend, newest, ↓reduceIte] using valid identity signature old inputs fitting

def compileFrom (functions : ScalarFunctions.Environment) : Environment → List Definition → Environment
  | earlier, [] => earlier
  | earlier, definition :: rest => compileFrom functions (earlier.extend functions definition) rest

def compileDefinitions (functions : ScalarFunctions.Environment) (definitions : List Definition) : Environment :=
  compileFrom functions .empty definitions

def DefinitionsChecked (functions : ScalarFunctions.Signatures) : Signatures → List Definition → Prop
  | _, [] => True
  | earlier, definition :: rest => definition.Checked functions earlier ∧
      DefinitionsChecked functions (earlier ++ [definition.signature]) rest

theorem compileFrom_signatures (functions : ScalarFunctions.Environment) (earlier : Environment)
    (definitions : List Definition) :
    (compileFrom functions earlier definitions).signatures = earlier.signatures ++ definitions.map Definition.signature := by
  induction definitions generalizing earlier with
  | nil => simp [compileFrom]
  | cons definition rest ih => simp [compileFrom, ih, Environment.extend, List.append_assoc]

@[simp] theorem compileDefinitions_signatures (functions : ScalarFunctions.Environment) (definitions : List Definition) :
    (compileDefinitions functions definitions).signatures = definitions.map Definition.signature := by
  simp [compileDefinitions, compileFrom_signatures, Environment.empty]

theorem compileFrom_valid {functions : ScalarFunctions.Environment} {earlier : Environment}
    {definitions : List Definition} (functionValid : functions.Valid) (valid : earlier.Valid)
    (checked : DefinitionsChecked functions.signatures earlier.signatures definitions) :
    (compileFrom functions earlier definitions).Valid := by
  induction definitions generalizing earlier with
  | nil => exact valid
  | cons definition rest ih => exact ih (earlier.extend_valid functionValid valid checked.1) checked.2

theorem compileDefinitions_valid {functions : ScalarFunctions.Environment} {definitions : List Definition}
    (functionValid : functions.Valid) (checked : DefinitionsChecked functions.signatures [] definitions) :
    (compileDefinitions functions definitions).Valid :=
  compileFrom_valid functionValid Environment.empty_valid checked

/-- Every definition returns fitting outputs, agrees with checked execution and
has no effects for every fitting input tuple, whether or not a caller uses it. -/
def DefinitionsSafe (functions : ScalarFunctions.Environment) : Environment → List Definition → Prop
  | _, [] => True
  | earlier, definition :: rest =>
      (∀ inputs, ArgumentsFit (inputTypes definition.signature.formals) inputs →
        ArgumentsFit (outputTypes definition.signature.formals) (definition.execute functions earlier inputs) ∧
        definition.checkedExecute functions earlier inputs = some (definition.execute functions earlier inputs) ∧
        (definition.executeBody functions earlier inputs).effects = []) ∧
      DefinitionsSafe functions (earlier.extend functions definition) rest

theorem definitions_safe {functions : ScalarFunctions.Environment} {earlier : Environment}
    {definitions : List Definition} (functionValid : functions.Valid) (valid : earlier.Valid)
    (checked : DefinitionsChecked functions.signatures earlier.signatures definitions) :
    DefinitionsSafe functions earlier definitions := by
  induction definitions generalizing earlier with
  | nil => trivial
  | cons definition rest ih =>
      refine ⟨?_, ih (earlier.extend_valid functionValid valid checked.1) checked.2⟩
      intro inputs fitting
      have sound := definition.execution_sound functionValid valid checked.1 inputs fitting
      exact ⟨sound.1, sound.2.1, sound.2.2.1⟩

theorem checked_definitions_safe {functions : ScalarFunctions.Environment} {definitions : List Definition}
    (functionValid : functions.Valid) (checked : DefinitionsChecked functions.signatures [] definitions) :
    DefinitionsSafe functions .empty definitions :=
  definitions_safe functionValid Environment.empty_valid checked

def Definition.obligations (functions : ScalarFunctions.Signatures) (earlier : Signatures)
    (definition : Definition) : List Predicate.Obligation :=
  ((Integer.declarationObligations [] definition.integers ++ definition.initializerChecks).map Predicate.Obligation.scalar) ++
    definition.booleanInitializerChecks ++
    booleanDeclarationObligations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans ++
    actualsObligations emptyShape definition.inputAnalysis definition.prefixFlow definition.inputBooleanAnalysis
      (outTypes definition.signature.formals) definition.initializers ++
    statementsObligations emptyShape definition.analysis definition.initialFlow definition.body
      definition.booleanAnalysis (functions.take definition.functionCount) earlier ++
    actualsObligations emptyShape definition.analysis definition.initialFlow definition.booleanAnalysis
      (outputTypes definition.signature.formals) definition.outputReads

theorem Definition.obligations_discharge {functions : ScalarFunctions.Signatures} {earlier : Signatures}
    {definition : Definition} (checked : definition.Checked functions earlier) :
    Predicate.discharged (definition.obligations functions earlier) = true := by
  obtain ⟨_, after, checked⟩ := checked
  have checks := (definition.check_iff functions earlier after).mp checked
  have ready := (definition.ready_iff functions).mp checks.1
  have localChecks := definition.localCheck_iff.mp ready.1
  obtain ⟨constants, declarations⟩ := localChecks.1
  simp only [obligations, Predicate.discharged_append, scalar_discharged,
    Integer.discharged_append, Integer.declaration_obligations_discharge declarations,
    localChecks.2.1, localChecks.2.2.1, boolean_declaration_obligations_exact, localChecks.2.2.2,
    actuals_obligations_discharge ready.2.1, statements_obligations_discharge checks.2,
    actuals_obligations_discharge ready.2.2.1, Bool.and_self]

def definitionsObligations (functions : ScalarFunctions.Signatures) : Signatures → List Definition → List Predicate.Obligation
  | _, [] => []
  | earlier, definition :: rest => definition.obligations functions earlier ++
      definitionsObligations functions (earlier ++ [definition.signature]) rest

theorem definitions_obligations_discharge {functions : ScalarFunctions.Signatures} {earlier : Signatures}
    {definitions : List Definition} (checked : DefinitionsChecked functions earlier definitions) :
    Predicate.discharged (definitionsObligations functions earlier definitions) = true := by
  induction definitions generalizing earlier with
  | nil => rfl
  | cons definition rest ih =>
      rw [definitionsObligations, Predicate.discharged_append, definition.obligations_discharge checked.1, ih checked.2]
      rfl

theorem definitions_obligations_valid {functions : ScalarFunctions.Signatures} {definitions : List Definition}
    (checked : DefinitionsChecked functions [] definitions) :
    ∀ obligation ∈ definitionsObligations functions [] definitions, obligation.Valid := by
  intro obligation present
  exact Predicate.Obligation.discharge_sound
    (List.all_eq_true.mp (definitions_obligations_discharge checked) obligation present)

end Silver.ScalarProcedures
