module

public import Silver.ScalarFunctionFrame
public import Silver.PredicateExecution
public import Silver.BooleanDeclarationObligations

@[expose] public section

/-! Closed scalar bodies. Locals initialize before immutable formals are bound;
only the earlier definition prefix is available when checking or executing. -/
namespace Silver.ScalarFunctions
open Bindings Predicate

mutual
  def pureStatement : Statement → Bool
    | .simple .null | .scalarAssign _ | .callAssign _ | .booleanAssign _ => true
    | .choice _ yes no => pureStatements yes && pureStatements no
    | .forLoop _ _ _ _ body => pureStatements body
    | _ => false
  termination_by item => sizeOf item
  def pureStatements : List Statement → Bool
    | [] => true
    | item :: rest => pureStatement item && pureStatements rest
  termination_by items => sizeOf items
end


def scalarExpression : Integer.Expr → Bool
  | .literal _ | .snapshot _ | .name _ => true
  | .indexed _ _ => false
  | .positive value | .negative value | .parenthesized value => scalarExpression value
  | .add left right | .subtract left right | .multiply left right | .divide left right |
    .modulo left right | .remainder left right => scalarExpression left && scalarExpression right

def scalarCondition : Condition → Bool
  | .booleanLiteral _ | .booleanName _ => true
  | .scalarCompare _ left right => scalarExpression left && scalarExpression right
  | .parenthesized inner | .negated inner => scalarCondition inner
  | .andThen left right | .orElse left right | .eager _ left right | .booleanCompare _ left right =>
      scalarCondition left && scalarCondition right
  | _ => false

def scalarActual : Actual → Bool
  | .integer expression => scalarExpression expression
  | .boolean condition => scalarCondition condition

mutual
  def scalarStatement : Statement → Bool
    | .simple .null => true
    | .scalarAssign update => scalarExpression update.value
    | .callAssign update => update.call.actuals.all scalarActual
    | .booleanAssign update => scalarCondition update.value
    | .choice condition yes no => scalarCondition condition && scalarStatements yes && scalarStatements no
    | .forLoop _ _ lower upper body => scalarExpression lower && scalarExpression upper && scalarStatements body
    | _ => false
  termination_by item => sizeOf item
  def scalarStatements : List Statement → Bool
    | [] => true
    | item :: rest => scalarStatement item && scalarStatements rest
  termination_by items => sizeOf items
end

structure Definition where
  signature : Signature
  integers : List Integer.Declaration
  booleans : List BooleanDeclaration
  initializerChecks : List Integer.Obligation
  booleanInitializerChecks : List Predicate.Obligation
  body : List Statement
  result : Actual
  deriving Repr

/-- Explicit grammar prevents effect-free but unselected String, Character,
array and input-query expressions from entering the function fragment. -/
def Definition.scalarOnly (definition : Definition) : Bool :=
  definition.integers.all (fun item => scalarExpression item.value) &&
    definition.booleans.all (fun item => scalarCondition item.value) &&
    scalarStatements definition.body && scalarActual definition.result

def entryContext : PathFacts.Context := ⟨some ⟨0, 0⟩, false, false⟩

def Definition.localAnalysis (definition : Definition) : Integer.Analysis :=
  Integer.Analysis.ofDeclarations definition.integers

def Definition.localFlow (definition : Definition) : Flow :=
  ⟨entryContext, definition.localAnalysis.declared⟩

def parameterAnalysis : Nat → List ScalarType → Integer.Analysis → Integer.Analysis
  | count, .integer bounds :: rest, analysis =>
      parameterAnalysis (count + 1) rest (analysis.withIndex (count + 1) bounds)
  | count, .boolean :: rest, analysis => parameterAnalysis count rest analysis
  | _, [], analysis => analysis

theorem parameterAnalysis_declared (count : Nat) (formals : List ScalarType) (analysis : Integer.Analysis) :
    (parameterAnalysis count formals analysis).declared = parameterRanges count formals analysis.declared := by
  induction formals generalizing count analysis with
  | nil => rfl
  | cons formal rest ih => cases formal <;> simp [parameterAnalysis, parameterRanges, ih, Integer.Analysis.withIndex]

def parameterBooleans : Nat → List ScalarType → Boolean.Analysis → Boolean.Analysis
  | count, .integer _ :: rest, analysis => parameterBooleans count rest analysis
  | count, .boolean :: rest, analysis =>
      parameterBooleans (count + 1) rest (analysis.initialize (count + 1) false)
  | _, [], analysis => analysis

def Definition.analysis (definition : Definition) : Integer.Analysis :=
  parameterAnalysis definition.integers.length definition.signature.formals definition.localAnalysis

def Definition.booleanAnalysis (definition : Definition) : Boolean.Analysis :=
  parameterBooleans definition.booleans.length definition.signature.formals (booleanBodyAnalysis definition.booleans)

def Definition.initialFlow (definition : Definition) : Flow := ⟨entryContext, definition.analysis.declared⟩

def Definition.localFrame (definition : Definition) : Frame :=
  let integers := (Integer.executeDeclarations [] definition.integers).store
  ⟨integers, executeBooleanDeclarations emptyValues [] true integers definition.booleans Boolean.emptyStore⟩

def Definition.frame (definition : Definition) (arguments : List Value) : Frame :=
  bindArguments definition.integers.length definition.booleans.length
    definition.signature.formals arguments definition.localFrame

def Definition.check (earlier : Signatures) (definition : Definition) : Option Flow :=
  (Integer.checkDeclarations [] definition.integers).bind fun _ =>
    if Integer.discharged definition.initializerChecks &&
        Predicate.discharged definition.booleanInitializerChecks &&
        checkBooleanDeclarations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans &&
        pureStatements definition.body then
      (checkStatements emptyShape definition.analysis definition.initialFlow definition.body
        definition.booleanAnalysis earlier).bind fun after =>
          if definition.result.check emptyShape definition.analysis after definition.booleanAnalysis definition.signature.result
          then some after else none
    else none

/-- These are syntactic/readability conditions, not semantic correctness premises. -/
def Definition.WellFormed (definition : Definition) : Prop :=
  definition.signature.Valid ∧
    BooleanDeclarationsWellFormed false emptyShape {} definition.booleans ∧
    StatementsWellFormed false emptyShape definition.body definition.booleanAnalysis ∧
    definition.result.Readable false emptyShape definition.booleanAnalysis ∧ definition.scalarOnly = true

def Definition.Checked (earlier : Signatures) (definition : Definition) : Prop :=
  definition.WellFormed ∧ ∃ after, definition.check earlier = some after

theorem Definition.check_iff (definition : Definition) (earlier : Signatures) (after : Flow) :
    definition.check earlier = some after ↔
      (∃ constants, Integer.checkDeclarations [] definition.integers = some constants) ∧
      Integer.discharged definition.initializerChecks = true ∧
      Predicate.discharged definition.booleanInitializerChecks = true ∧
      checkBooleanDeclarations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans = true ∧
      pureStatements definition.body = true ∧
      checkStatements emptyShape definition.analysis definition.initialFlow definition.body
        definition.booleanAnalysis earlier = some after ∧
      definition.result.check emptyShape definition.analysis after definition.booleanAnalysis definition.signature.result = true := by
  simp only [check, Option.bind_eq_some_iff]
  constructor
  · rintro ⟨constants, initialized, rest⟩
    split at rest
    · rename_i checks
      simp only [Option.bind_eq_some_iff] at rest
      obtain ⟨found, body, rest⟩ := rest
      split at rest
      · cases rest
        have checks := Bool.and_eq_true_iff.mp checks
        have preliminary :=  Bool.and_eq_true_iff.mp checks.1
        have first := Bool.and_eq_true_iff.mp preliminary.1
        exact ⟨⟨constants, initialized⟩, first.1, first.2, preliminary.2, checks.2, body, by assumption⟩
      · contradiction
    · contradiction
  · rintro ⟨⟨constants, initialized⟩, scalarChecks, boolChecks, locals, pure, body, returned⟩
    refine ⟨constants, initialized, ?_⟩
    simp only [scalarChecks, boolChecks, locals, pure, Bool.and_self, ↓reduceIte, body,
      Option.bind_some, returned]

/-- Local initializer names resolve against local declarations only; no formal,
outer value, String, array or input environment is supplied. Source order still
controls which local identities may occur in the translated expressions. -/
def Definition.InitializersClosed (definition : Definition) : Prop :=
  (∃ constants, Integer.checkDeclarations [] definition.integers = some constants) ∧
    BooleanDeclarationsWellFormed false emptyShape {} definition.booleans ∧
    checkBooleanDeclarations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans = true ∧
    definition.integers.all (fun item => scalarExpression item.value) = true ∧
    definition.booleans.all (fun item => scalarCondition item.value) = true

theorem Definition.initializers_closed {definition : Definition} {earlier : Signatures}
    (checked : definition.Checked earlier) : definition.InitializersClosed := by
  obtain ⟨formed, after, checked⟩ := checked
  have checks := (definition.check_iff earlier after).mp checked
  have scalar := formed.2.2.2.2
  simp only [scalarOnly, Bool.and_eq_true] at scalar
  exact ⟨checks.1, formed.2.1, checks.2.2.2.1, scalar.1.1.1, scalar.1.1.2⟩

def Definition.executeBody (earlier : Environment) (definition : Definition) (arguments : List Value) : Execution :=
  let frame := definition.frame arguments
  executeStatements [] true emptyValues definition.body frame.integers frame.booleans earlier

def Definition.execute (earlier : Environment) (definition : Definition) (arguments : List Value) : Value :=
  let final := definition.executeBody earlier arguments
  definition.result.evaluate ⟨final.values, [], true, final.integers, final.booleans⟩

def Definition.checkedExecute (earlier : Environment) (definition : Definition) (arguments : List Value) : Option Value :=
  let frame := definition.frame arguments
  (checkedStatements [] true emptyValues definition.body frame.integers frame.booleans earlier).bind fun final =>
    (definition.result.checkedEvaluate ⟨final.values, [], true, final.integers, final.booleans⟩).bind fun result =>
      if definition.signature.result.contains result then some result else none

end Silver.ScalarFunctions
