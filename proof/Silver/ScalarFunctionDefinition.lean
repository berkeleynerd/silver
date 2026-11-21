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


/-- The source frame contains only array input formals, in their own
one-based slot order. Stored objects from Main are outside this scope. -/
def formalArrays : Nat → List ScalarType → List (Nat × Integer.ArrayDescriptor)
  | _, [] => []
  | slot, .array domain :: rest =>
      (domain.identity, domain.formal slot) :: formalArrays (slot + 1) rest
  | slot, _ :: rest => formalArrays slot rest

def frameExpression (arrays : List (Nat × Integer.ArrayDescriptor)) : Integer.Expr → Bool
  | .literal _ | .snapshot _ | .name _ => true
  | .indexed array index =>
      arrays.any (fun input => input.2 == array) && !index.hasArray && frameExpression arrays index
  | .positive value | .negative value | .parenthesized value => frameExpression arrays value
  | .add left right | .subtract left right | .multiply left right | .divide left right |
    .modulo left right | .remainder left right => frameExpression arrays left && frameExpression arrays right

def frameCondition (arrays : List (Nat × Integer.ArrayDescriptor)) : Condition → Bool
  | .booleanLiteral _ | .booleanName _ => true
  | .scalarCompare _ left right => frameExpression arrays left && frameExpression arrays right
  | .parenthesized inner | .negated inner => frameCondition arrays inner
  | .andThen left right | .orElse left right | .eager _ left right | .booleanCompare _ left right =>
      frameCondition arrays left && frameCondition arrays right
  | _ => false

def frameActual (arrays : List (Nat × Integer.ArrayDescriptor)) : Actual → Bool
  | .integer expression => frameExpression arrays expression
  | .boolean condition => frameCondition arrays condition
  | .array identity source => arrays.contains (identity, source)

def scalarExpression := frameExpression []
def scalarCondition := frameCondition []
def scalarActual := frameActual []

mutual
  def frameStatement (arrays : List (Nat × Integer.ArrayDescriptor)) : Statement → Bool
    | .simple .null => true
    | .scalarAssign update => frameExpression arrays update.value
    | .callAssign update => update.call.actuals.all (frameActual arrays)
    | .booleanAssign update => frameCondition arrays update.value
    | .choice condition yes no =>
        frameCondition arrays condition && frameStatements arrays yes && frameStatements arrays no
    | .forLoop _ _ lower upper body =>
        frameExpression arrays lower && frameExpression arrays upper && frameStatements arrays body
    | _ => false
  termination_by item => sizeOf item
  def frameStatements (arrays : List (Nat × Integer.ArrayDescriptor)) : List Statement → Bool
    | [] => true
    | item :: rest => frameStatement arrays item && frameStatements arrays rest
  termination_by items => sizeOf items
end

def scalarStatement := frameStatement []
def scalarStatements := frameStatements []

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
and input-query expressions. Only visible array formals can occur in the body. -/
def Definition.scalarOnly (definition : Definition) : Bool :=
  definition.integers.all (fun item => scalarExpression item.value) &&
    definition.booleans.all (fun item => scalarCondition item.value) &&
    frameStatements (formalArrays 1 definition.signature.formals) definition.body &&
    frameActual (formalArrays 1 definition.signature.formals) definition.result

def entryContext : PathFacts.Context := ⟨some ⟨0, 0⟩, false, false⟩

def Definition.localAnalysis (definition : Definition) : Integer.Analysis :=
  Integer.Analysis.ofDeclarations definition.integers

def Definition.localFlow (definition : Definition) : Flow :=
  ⟨entryContext, definition.localAnalysis.declared⟩

def parameterAnalysis : Nat → List ScalarType → Integer.Analysis → Integer.Analysis
  | count, .integer bounds :: rest, analysis =>
      parameterAnalysis (count + 1) rest (analysis.withIndex (count + 1) bounds)
  | count, .boolean :: rest, analysis
  | count, .array _ :: rest, analysis => parameterAnalysis count rest analysis
  | _, [], analysis => analysis

theorem parameterAnalysis_declared (count : Nat) (formals : List ScalarType) (analysis : Integer.Analysis) :
    (parameterAnalysis count formals analysis).declared = parameterRanges count formals analysis.declared := by
  induction formals generalizing count analysis with
  | nil => rfl
  | cons formal rest ih => cases formal <;> simp [parameterAnalysis, parameterRanges, ih, Integer.Analysis.withIndex]

def parameterBooleans : Nat → List ScalarType → Boolean.Analysis → Boolean.Analysis
  | count, .integer _ :: rest, analysis
  | count, .array _ :: rest, analysis => parameterBooleans count rest analysis
  | count, .boolean :: rest, analysis =>
      parameterBooleans (count + 1) rest (analysis.initialize (count + 1) false)
  | _, [], analysis => analysis

def Definition.analysis (definition : Definition) : Integer.Analysis :=
  parameterAnalysis definition.integers.length definition.signature.formals
    (arrayAnalysis 1 definition.signature.formals definition.localAnalysis)

def Definition.booleanAnalysis (definition : Definition) : Boolean.Analysis :=
  parameterBooleans definition.booleans.length definition.signature.formals (booleanBodyAnalysis definition.booleans)

def Definition.initialFlow (definition : Definition) : Flow := ⟨entryContext, definition.analysis.declared⟩

def Definition.localFrame (definition : Definition) : Frame :=
  let integers := (Integer.executeDeclarations [] definition.integers).store
  ⟨integers, executeBooleanDeclarations emptyValues [] true integers definition.booleans Boolean.emptyStore⟩

def Definition.frame (definition : Definition) (arguments : List Value) : Frame :=
  let integers := bindArrayArguments 1 definition.signature.formals arguments definition.localFrame.integers
  bindArguments definition.integers.length definition.booleans.length
    definition.signature.formals arguments {definition.localFrame with integers := integers}

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
