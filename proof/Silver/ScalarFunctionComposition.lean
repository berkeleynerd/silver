module

public import Silver.ScalarFunctionSemantics

@[expose] public section

/-! Definition order constructs executable meanings. No recursive lookup sees
its own entry or any later definition, and no semantic premise is stored in the
computational environment. The proof fold certifies every body, including unused ones. -/
namespace Silver.ScalarFunctions
open Bindings Predicate

def Environment.extend (earlier : Environment) (definition : Definition) : Environment :=
  ⟨earlier.signatures ++ [definition.signature],
    fun identity arguments => if identity = earlier.signatures.length + 1
      then definition.execute earlier arguments else earlier.values identity arguments⟩

theorem Environment.extend_valid {earlier : Environment} {definition : Definition}
    (valid : earlier.Valid) (checked : definition.Checked earlier.signatures) :
    (earlier.extend definition).Valid := by
  intro identity signature found arguments fitting
  by_cases newest : identity = earlier.signatures.length + 1
  · subst identity
    have same : definition.signature = signature := by
      simpa only [Environment.extend, lookup_append_new, Option.some.injEq] using found
    subst signature
    simpa only [Environment.extend, ↓reduceIte] using
      (definition.execution_sound valid checked arguments fitting).1
  · have positive := lookup_nonzero found
    have old : lookup earlier.signatures identity = some signature := by
      simp only [Environment.extend, lookup, positive, ↓reduceIte] at found ⊢
      have inside := (List.getElem?_eq_some_iff.mp found).1
      have limit : identity - 1 < earlier.signatures.length := by
        simp only [List.length_append, List.length_singleton] at inside
        omega
      simpa only [List.getElem?_append_left limit] using found
    simpa only [Environment.extend, newest, ↓reduceIte] using valid identity signature old arguments fitting

def compileFrom : Environment → List Definition → Environment
  | earlier, [] => earlier
  | earlier, definition :: rest => compileFrom (earlier.extend definition) rest

def compileDefinitions (definitions : List Definition) : Environment := compileFrom .empty definitions

def DefinitionsChecked : Signatures → List Definition → Prop
  | _, [] => True
  | earlier, definition :: rest => definition.Checked earlier ∧
      DefinitionsChecked (earlier ++ [definition.signature]) rest

theorem compileFrom_signatures (earlier : Environment) (definitions : List Definition) :
    (compileFrom earlier definitions).signatures = earlier.signatures ++ definitions.map Definition.signature := by
  induction definitions generalizing earlier with
  | nil => simp [compileFrom]
  | cons definition rest ih => simp [compileFrom, ih, Environment.extend, List.append_assoc]

@[simp] theorem compileDefinitions_signatures (definitions : List Definition) :
    (compileDefinitions definitions).signatures = definitions.map Definition.signature := by
  simp [compileDefinitions, compileFrom_signatures, Environment.empty]

theorem compileFrom_valid {earlier : Environment} {definitions : List Definition}
    (valid : earlier.Valid) (checked : DefinitionsChecked earlier.signatures definitions) :
    (compileFrom earlier definitions).Valid := by
  induction definitions generalizing earlier with
  | nil => exact valid
  | cons definition rest ih => exact ih (earlier.extend_valid valid checked.1) checked.2

theorem compileDefinitions_valid {definitions : List Definition}
    (checked : DefinitionsChecked [] definitions) : (compileDefinitions definitions).Valid :=
  compileFrom_valid Environment.empty_valid checked

/-- Every definition is safe in exactly the environment used to construct its
meaning. This includes definitions that Main never calls. -/
def DefinitionsSafe : Environment → List Definition → Prop
  | _, [] => True
  | earlier, definition :: rest =>
      (∀ arguments, ArgumentsFit definition.signature.formals arguments →
        definition.signature.result.Contains (definition.execute earlier arguments) ∧
        definition.checkedExecute earlier arguments = some (definition.execute earlier arguments) ∧
        (definition.executeBody earlier arguments).effects = []) ∧
      DefinitionsSafe (earlier.extend definition) rest

theorem definitions_safe {earlier : Environment} {definitions : List Definition}
    (valid : earlier.Valid) (checked : DefinitionsChecked earlier.signatures definitions) :
    DefinitionsSafe earlier definitions := by
  induction definitions generalizing earlier with
  | nil => trivial
  | cons definition rest ih =>
      refine ⟨?_, ih (earlier.extend_valid valid checked.1) checked.2⟩
      intro arguments fitting
      have sound := definition.execution_sound valid checked.1 arguments fitting
      exact ⟨sound.1, sound.2.1, sound.2.2.1⟩

theorem checked_definitions_safe {definitions : List Definition}
    (checked : DefinitionsChecked [] definitions) : DefinitionsSafe .empty definitions :=
  definitions_safe Environment.empty_valid checked

def Definition.obligations (earlier : Signatures) (definition : Definition) : List Predicate.Obligation :=
  ((Integer.declarationObligations [] definition.integers ++ definition.initializerChecks).map Predicate.Obligation.scalar) ++
    definition.booleanInitializerChecks ++
    booleanDeclarationObligations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans ++
    statementsObligations emptyShape definition.analysis definition.initialFlow definition.body definition.booleanAnalysis earlier ++
    match checkStatements emptyShape definition.analysis definition.initialFlow definition.body definition.booleanAnalysis earlier with
    | none => [.impossible]
    | some after => actualObligations emptyShape definition.analysis after definition.booleanAnalysis definition.signature.result definition.result

theorem Definition.obligations_discharge {earlier : Signatures} {definition : Definition}
    (checked : definition.Checked earlier) : Predicate.discharged (definition.obligations earlier) = true := by
  obtain ⟨_, after, checked⟩ := checked
  have checks := (definition.check_iff earlier after).mp checked
  obtain ⟨constants, declarations⟩ := checks.1
  simp only [obligations, checks.2.2.2.2.2.1, Predicate.discharged_append, scalar_discharged,
    Integer.discharged_append, Integer.declaration_obligations_discharge declarations,
    checks.2.1, checks.2.2.1, boolean_declaration_obligations_exact, checks.2.2.2.1,
    statements_obligations_discharge checks.2.2.2.2.2.1,
    actual_obligations_discharge checks.2.2.2.2.2.2, Bool.and_self]

def definitionsObligations : Signatures → List Definition → List Predicate.Obligation
  | _, [] => []
  | earlier, definition :: rest => definition.obligations earlier ++
      definitionsObligations (earlier ++ [definition.signature]) rest

theorem definitions_obligations_discharge {earlier : Signatures} {definitions : List Definition}
    (checked : DefinitionsChecked earlier definitions) :
    Predicate.discharged (definitionsObligations earlier definitions) = true := by
  induction definitions generalizing earlier with
  | nil => rfl
  | cons definition rest ih =>
      rw [definitionsObligations, Predicate.discharged_append, definition.obligations_discharge checked.1, ih checked.2]
      rfl

theorem definitions_obligations_valid {definitions : List Definition}
    (checked : DefinitionsChecked [] definitions) :
    ∀ obligation ∈ definitionsObligations [] definitions, obligation.Valid := by
  intro obligation present
  exact Predicate.Obligation.discharge_sound
    (List.all_eq_true.mp (definitions_obligations_discharge checked) obligation present)

end Silver.ScalarFunctions
