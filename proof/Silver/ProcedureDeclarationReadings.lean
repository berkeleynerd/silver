module

public import Silver.ProcedureDeclarationModel
public import Silver.ProcedurePrefixReadings
public import Silver.FunctionDeclarationReadings
public import Silver.FunctionDeclarationMeaning

@[expose] public section

namespace Silver.Compose
open Predicate

/-- Exact initialized locals and source-written out assignments retained before
the ordinary body. Both binding passes use the same current formal suffix. -/
structure ProcedureInitializationSource (text : Source) (frame : ParserState) (arguments : Bool)
    (integers : List Integer.Declaration) (booleans : List BooleanDeclaration)
    (checks : List Integer.Obligation) (booleanChecks : List Predicate.Obligation)
    (actuals : List ScalarFunctions.Actual) : Prop where
  locals : FunctionLocalsAt text arguments frame integers booleans checks booleanChecks
    (functionLocals text frame arguments)
  inputs : ProcedureInputFramesAt (functionLocals text frame arguments)
    (functionLocals text frame arguments).firstProcedureParameter
    (procedureInputFrame text (functionLocals text frame arguments))
  prefixRead : ProcedurePrefixAt text (procedureSourceStart text frame arguments)
    (functionLocals text frame arguments).scalarNames.length (procedureSourceStart text frame arguments)
    (procedureSourceStart text frame arguments).firstProcedureParameter actuals (procedureSourceReady text frame arguments)

theorem procedureBodyAt_initialization {text outer frame first after arguments}
    (textValid : Expressions.ValidText text) (valid : Expressions.ValidState text frame)
    (positive : 0 < frame.firstProcedureParameter)
    (accepted : (procedureBodyAt text outer frame first after arguments).position ≠ 0) :
    ∃ integers booleans checks booleanChecks actuals,
      ProcedureInitializationSource text frame arguments integers booleans checks booleanChecks actuals := by
  have stages := procedureBodyAt_stages accepted
  obtain ⟨integers, booleans, checks, booleanChecks, locals⟩ := functionLocals_reading textValid valid stages.locals
  have inputs := procedureInputFrames_reading stages.inputs
  have firstPositive : 0 < (functionLocals text frame arguments).firstProcedureParameter := by
    rw [locals.preserves.firstProcedureParameter]
    exact positive
  have boundValid := inputs.valid (locals.valid valid) firstPositive
  have names : Expressions.ValidNames text (procedureSourceStart text frame arguments).names := boundValid.2.1
  obtain ⟨actuals, prefixRead⟩ := procedurePrefix_reading
    (readFrame := procedureSourceStart text frame arguments) textValid names stages.prefixReady
  exact ⟨integers, booleans, checks, booleanChecks, actuals, locals, inputs, prefixRead⟩

def procedureNameFirst (text : Source) (state : ParserState) : Nat :=
  skipAt text (fixedAfter text state.position "procedure" true)

def procedureNameAfter (text : Source) (state : ParserState) : Nat := nameAfter text (procedureNameFirst text state)

def procedureHeaderRejected (text : Source) (state : ParserState) (arguments : Bool) : Prop :=
  fixedAfter text state.position "procedure" true = 0 ∨
    fixedAfter text (procedureNameAfter text state) "(" false = 0 ∨ state.pure ∨
    !newNameAllowed text state (procedureNameFirst text state) (procedureNameAfter text state) arguments ∨
    state.procedures.items.length = ProcedureBindings.maxProcedures ∨
    state.procedures.parameters.length = ProcedureBindings.maxFormals

instance (text : Source) (state : ParserState) (arguments : Bool) :
    Decidable (procedureHeaderRejected text state arguments) := inferInstanceAs (Decidable (_ ∨ _))

def procedureHeaderInitial (text : Source) (state : ParserState) : ParserState :=
  {initialState with
    position := fixedAfter text (procedureNameAfter text state) "(" false, pure := true,
    subtypeNames := state.subtypeNames, functions := state.functions, procedures := state.procedures,
    arrayNames := {types := state.arrayNames.types},
    «hiding» := hideName text (hiddenOuter text state) (procedureNameFirst text state) (procedureNameAfter text state),
    firstProcedureParameter := state.procedures.parameters.length + 1}

def procedureHeaderParameters (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  procedureParametersAt text (procedureHeaderInitial text state) arguments

def procedureHeaderFrame (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  {procedureHeaderParameters text state arguments with
    position := fixedAfter text (procedureHeaderParameters text state arguments).position "is" true}

structure ProcedureHeaderStages (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  allowed : ¬procedureHeaderRejected text state arguments
  parameters : (procedureHeaderParameters text state arguments).position ≠ 0
  bodyStart : (procedureHeaderFrame text state arguments).position ≠ 0
  writable : ((procedureHeaderParameters text state arguments).procedures.parameters.drop
    ((procedureHeaderParameters text state arguments).firstProcedureParameter - 1)).any
      (fun parameter => parameter.mode != .input) = true
  body : (procedureBodyAt text state (procedureHeaderFrame text state arguments)
    (procedureNameFirst text state) (procedureNameAfter text state) arguments).position ≠ 0
  equation : procedureDeclarationAt text state arguments =
    procedureBodyAt text state (procedureHeaderFrame text state arguments)
      (procedureNameFirst text state) (procedureNameAfter text state) arguments

theorem procedureDeclarationAt_stages {text state arguments}
    (accepted : (procedureDeclarationAt text state arguments).position ≠ 0) :
    ProcedureHeaderStages text state arguments := by
  dsimp only [procedureDeclarationAt] at accepted
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i allowed
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i parameters
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i ready
        refine ⟨allowed, parameters, fun zero => ready (.inl zero), ?_, accepted, ?_⟩
        · apply Bool.of_not_eq_false
          intro bad
          apply ready
          right
          change (!((procedureHeaderParameters text state arguments).procedures.parameters.drop
            ((procedureHeaderParameters text state arguments).firstProcedureParameter - 1)).any
            (fun parameter => parameter.mode != .input)) = true
          rw [bad]
          rfl
        · dsimp only [procedureDeclarationAt]
          rw [ite_eq_right allowed, ite_eq_right parameters, ite_eq_right ready]
          rfl

end Silver.Compose
