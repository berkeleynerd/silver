module

public import Silver.ScalarProcedureFrame
public import Silver.ScalarFunctionDefinition

@[expose] public section

/-! Closed procedures initialize every out formal from an explicit leading
assignment. Prefix expressions see exactly the frozen local/input frame;
ordinary statements start only after all output bindings have been initialized. -/
namespace Silver.ScalarProcedures
open Bindings Predicate
open ScalarFunctions (ScalarType Frame State ArgumentsFit)

def frameActual (arrays : List (Nat × Integer.ArrayDescriptor)) : Actual → Bool
  | .value value => ScalarFunctions.frameActual arrays value
  | .target _ => true

def scalarActual := frameActual []

mutual
  def frameStatement (arrays : List (Nat × Integer.ArrayDescriptor)) : Statement → Bool
    | .simple .null => true
    | .scalarAssign update => ScalarFunctions.frameExpression arrays update.value
    | .callAssign update => update.call.actuals.all (ScalarFunctions.frameActual arrays)
    | .procedureCall call => call.actuals.all (frameActual arrays)
    | .booleanAssign update => ScalarFunctions.frameCondition arrays update.value
    | .choice condition yes no =>
        ScalarFunctions.frameCondition arrays condition && frameStatements arrays yes && frameStatements arrays no
    | .forLoop _ _ lower upper body =>
        ScalarFunctions.frameExpression arrays lower && ScalarFunctions.frameExpression arrays upper &&
          frameStatements arrays body
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
  functionCount : Nat
  integers : List Integer.Declaration
  booleans : List BooleanDeclaration
  initializerChecks : List Integer.Obligation
  booleanInitializerChecks : List Predicate.Obligation
  initializers : List ScalarFunctions.Actual
  body : List Statement
  deriving Repr

def Definition.localAnalysis (definition : Definition) : Integer.Analysis :=
  Integer.Analysis.ofDeclarations definition.integers

def Definition.localFlow (definition : Definition) : Flow :=
  ⟨ScalarFunctions.entryContext, definition.localAnalysis.declared⟩

def Definition.inputAnalysis (definition : Definition) : Integer.Analysis :=
  parameterAnalysis definition.integers.length (inputFormals definition.signature.formals)
    (ScalarFunctions.arrayAnalysis 1 (inputTypes definition.signature.formals) definition.localAnalysis)

def Definition.inputBooleanAnalysis (definition : Definition) : Boolean.Analysis :=
  parameterBooleans definition.booleans.length (inputFormals definition.signature.formals)
    (booleanBodyAnalysis definition.booleans)

def Definition.inputIntegerCount (definition : Definition) : Nat :=
  definition.integers.length + integerCount (inputTypes definition.signature.formals)

def Definition.inputBooleanCount (definition : Definition) : Nat :=
  definition.booleans.length + booleanCount (inputTypes definition.signature.formals)

def Definition.analysis (definition : Definition) : Integer.Analysis :=
  parameterAnalysis definition.inputIntegerCount (outFormals definition.signature.formals) definition.inputAnalysis

def Definition.booleanAnalysis (definition : Definition) : Boolean.Analysis :=
  parameterBooleans definition.inputBooleanCount (outFormals definition.signature.formals) definition.inputBooleanAnalysis

def Definition.prefixFlow (definition : Definition) : Flow :=
  ⟨ScalarFunctions.entryContext, definition.inputAnalysis.declared⟩

/-- This deliberate widening matches native Context_Of/Body_Of: prefix RHS
precision is not an exported invariant for the ordinary procedure body. -/
def Definition.initialFlow (definition : Definition) : Flow :=
  ⟨ScalarFunctions.entryContext, definition.analysis.declared⟩

def Definition.outputTargets (definition : Definition) : List ScalarFunctions.Target :=
  ScalarProcedures.outputTargets definition.integers.length definition.booleans.length
    definition.inputIntegerCount definition.inputBooleanCount definition.signature.formals

def Definition.outputReads (definition : Definition) : List ScalarFunctions.Actual :=
  definition.outputTargets.map targetRead

def Definition.localFrame (definition : Definition) : Frame :=
  let integers := (Integer.executeDeclarations [] definition.integers).store
  ⟨integers, executeBooleanDeclarations emptyValues [] true integers definition.booleans Boolean.emptyStore⟩

def Definition.inputFrame (definition : Definition) (inputs : List ScalarFunctions.Value) : Frame :=
  let integers := ScalarFunctions.bindArrayArguments 1 (inputTypes definition.signature.formals)
    inputs definition.localFrame.integers
  ScalarFunctions.bindArguments definition.integers.length definition.booleans.length
    (inputTypes definition.signature.formals) inputs {definition.localFrame with integers := integers}

def Definition.prefixState (definition : Definition) (inputs : List ScalarFunctions.Value) : State :=
  let frame := definition.inputFrame inputs
  ⟨emptyValues, [], true, frame.integers, frame.booleans⟩

def Definition.frameWithOutputs (definition : Definition) (inputs outputs : List ScalarFunctions.Value) : Frame :=
  ScalarFunctions.bindArguments definition.inputIntegerCount definition.inputBooleanCount
    (outTypes definition.signature.formals) outputs (definition.inputFrame inputs)

/-- Out values come from the actual prefix expressions, never caller values,
zero-filling, an assumed postcondition or an imported result oracle. -/
def Definition.frame (definition : Definition) (inputs : List ScalarFunctions.Value) : Frame :=
  definition.frameWithOutputs inputs
    (ScalarFunctions.evaluateActuals (definition.prefixState inputs) definition.initializers)

def Definition.localCheck (definition : Definition) : Bool :=
  match Integer.checkDeclarations [] definition.integers with
  | none => false
  | some _ => Integer.discharged definition.initializerChecks &&
      Predicate.discharged definition.booleanInitializerChecks &&
      checkBooleanDeclarations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans

def Definition.prefixCheck (definition : Definition) : Bool :=
  ScalarFunctions.checkActuals emptyShape definition.inputAnalysis definition.prefixFlow
    definition.inputBooleanAnalysis (outTypes definition.signature.formals) definition.initializers

/-- The fixed interface read check follows from the parameter layout and is
independent of the body's final refinements. Source correspondence must derive
this fact from that layout, not assume a completed body meaning. -/
def Definition.outputCheck (definition : Definition) : Bool :=
  ScalarFunctions.checkActuals emptyShape definition.analysis definition.initialFlow
    definition.booleanAnalysis (outputTypes definition.signature.formals) definition.outputReads

def Definition.scalarOnly (definition : Definition) : Bool :=
  let arrays := ScalarFunctions.formalArrays 1 (inputTypes definition.signature.formals)
  definition.integers.all (fun item => ScalarFunctions.scalarExpression item.value) &&
    definition.booleans.all (fun item => ScalarFunctions.scalarCondition item.value) &&
    definition.initializers.all (ScalarFunctions.frameActual arrays) && frameStatements arrays definition.body

def Definition.ready (functions : ScalarFunctions.Signatures) (definition : Definition) : Bool :=
  definition.localCheck && definition.prefixCheck && definition.outputCheck && definition.scalarOnly &&
    (!(outTypes definition.signature.formals).isEmpty || !definition.body.isEmpty) &&
    decide (definition.functionCount ≤ functions.length)

def Definition.check (functions : ScalarFunctions.Signatures) (earlier : Signatures)
    (definition : Definition) : Option Flow :=
  if definition.ready functions then
    checkStatements emptyShape definition.analysis definition.initialFlow definition.body
      definition.booleanAnalysis (functions.take definition.functionCount) earlier
  else none

/-- Readability and source grammar conditions carry no unproved callee law. -/
def Definition.WellFormed (definition : Definition) : Prop :=
  definition.signature.Valid ∧
    BooleanDeclarationsWellFormed false emptyShape {} definition.booleans ∧
    (∀ actual ∈ definition.initializers, actual.Readable false emptyShape definition.inputBooleanAnalysis) ∧
    (∀ actual ∈ definition.outputReads, actual.Readable false emptyShape definition.booleanAnalysis) ∧
    StatementsWellFormed false emptyShape definition.body definition.booleanAnalysis

def Definition.Checked (functions : ScalarFunctions.Signatures) (earlier : Signatures)
    (definition : Definition) : Prop :=
  definition.WellFormed ∧ ∃ after, definition.check functions earlier = some after

theorem Definition.localCheck_iff (definition : Definition) :
    definition.localCheck = true ↔
      (∃ constants, Integer.checkDeclarations [] definition.integers = some constants) ∧
      Integer.discharged definition.initializerChecks = true ∧
      Predicate.discharged definition.booleanInitializerChecks = true ∧
      checkBooleanDeclarations emptyShape definition.localAnalysis definition.localFlow {} definition.booleans = true := by
  cases found : Integer.checkDeclarations [] definition.integers with
  | none => simp [localCheck, found]
  | some constants => simp [localCheck, found, Bool.and_eq_true, and_assoc]

theorem Definition.ready_iff (definition : Definition) (functions : ScalarFunctions.Signatures) :
    definition.ready functions = true ↔
      definition.localCheck = true ∧ definition.prefixCheck = true ∧ definition.outputCheck = true ∧
      definition.scalarOnly = true ∧
      (outTypes definition.signature.formals ≠ [] ∨ definition.body ≠ []) ∧
      definition.functionCount ≤ functions.length := by
  simp [ready, Bool.and_eq_true, Bool.or_eq_true, List.isEmpty_eq_false_iff, and_assoc]

theorem Definition.check_iff (definition : Definition) (functions : ScalarFunctions.Signatures)
    (earlier : Signatures) (after : Flow) :
    definition.check functions earlier = some after ↔
      definition.ready functions = true ∧
      checkStatements emptyShape definition.analysis definition.initialFlow definition.body
        definition.booleanAnalysis (functions.take definition.functionCount) earlier = some after := by
  simp only [check]
  split <;> simp_all

def Definition.executeBody (functions : ScalarFunctions.Environment) (earlier : Environment)
    (definition : Definition) (inputs : List ScalarFunctions.Value) : Execution :=
  let frame := definition.frame inputs
  executeStatements [] true emptyValues definition.body frame.integers frame.booleans
    (functionPrefix functions definition.functionCount) earlier

def Definition.execute (functions : ScalarFunctions.Environment) (earlier : Environment)
    (definition : Definition) (inputs : List ScalarFunctions.Value) : List ScalarFunctions.Value :=
  let final := definition.executeBody functions earlier inputs
  ScalarFunctions.evaluateActuals ⟨final.values, [], true, final.integers, final.booleans⟩ definition.outputReads

def Definition.checkedExecute (functions : ScalarFunctions.Environment) (earlier : Environment)
    (definition : Definition) (inputs : List ScalarFunctions.Value) : Option (List ScalarFunctions.Value) :=
  (ScalarFunctions.checkedActuals (definition.prefixState inputs) definition.initializers).bind fun outputs =>
    let frame := definition.frameWithOutputs inputs outputs
    (checkedStatements [] true emptyValues definition.body frame.integers frame.booleans
      (functionPrefix functions definition.functionCount) earlier).bind fun final =>
        (ScalarFunctions.checkedActuals ⟨final.values, [], true, final.integers, final.booleans⟩ definition.outputReads).bind fun result =>
          if ScalarFunctions.checkArguments (outputTypes definition.signature.formals) result
          then some result else none

end Silver.ScalarProcedures
