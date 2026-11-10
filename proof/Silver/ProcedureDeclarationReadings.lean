module

public import Silver.ProcedureDeclarationAdmission
public import Silver.ProcedurePrefixReadings
public import Silver.FunctionDeclarationReadings
public import Silver.FunctionDeclarationMeaning

@[expose] public section

namespace Silver.Compose
open Predicate

def procedureSourceEntry (frame : ParserState) (first after : Nat) : ProcedureBindings.Signature :=
  ⟨first, after, frame.firstProcedureParameter,
    frame.procedures.parameters.length - frame.firstProcedureParameter + 1⟩

def procedureSourceStart (text : Source) (frame : ParserState) (arguments : Bool) : ParserState :=
  let bound := procedureInputFrame text (functionLocals text frame arguments)
  {bound with position := fixedAfter text bound.position "begin" true}

def procedureSourceReady (text : Source) (frame : ParserState) (arguments : Bool) : ParserState :=
  procedurePrefix text (procedureSourceStart text frame arguments)
    (functionLocals text frame arguments).scalarNames.length

def procedureSourceContext (text : Source) (frame : ParserState) (arguments : Bool) : ParseContext :=
  {contextOf ⟨procedureSourceReady text frame arguments, false, false⟩ with
    declarationCount := (functionLocals text frame arguments).scalarNames.length}

def procedureSourceInitialized (text : Source) (frame : ParserState) (arguments : Bool) : Bool :=
  decide ((procedureSourceReady text frame arguments).position > (procedureSourceStart text frame arguments).position)

def procedureSourceScan (text : Source) (frame : ParserState) (arguments : Bool) : BodyScan :=
  bodyOf ⟨procedureSourceReady text frame arguments, procedureSourceInitialized text frame arguments, false⟩

def procedureSourceFinal (text : Source) (frame : ParserState) (arguments : Bool) : BodyScan :=
  if procedureSourceInitialized text frame arguments then
    bodyTail text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
      .endOnly frame.functions frame.procedures
  else readBody text (procedureSourceContext text frame arguments) (procedureSourceScan text frame arguments)
      .endOnly frame.functions frame.procedures

def procedureClosingFirst (text : Source) (frame : ParserState) (arguments : Bool) : Nat :=
  skipAt text (fixedAfter text (procedureSourceFinal text frame arguments).position "end" true)

def procedureClosingAfter (text : Source) (frame : ParserState) (arguments : Bool) : Nat :=
  nameAfter text (procedureClosingFirst text frame arguments)

def procedureBodyRejected (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) : Prop :=
  (procedureSourceFinal text frame arguments).position = 0 ∨
    procedureClosingFirst text frame arguments = 0 ∨
    procedureClosingAfter text frame arguments ≤ procedureClosingFirst text frame arguments ∨
    (!Named.equalName text first after
      (procedureClosingFirst text frame arguments) (procedureClosingAfter text frame arguments)) = true ∨
    fixedAfter text (procedureClosingAfter text frame arguments) ";" false ≤ outer.position

instance (text : Source) (outer frame : ParserState) (first after : Nat) (arguments : Bool) :
    Decidable (procedureBodyRejected text outer frame first after arguments) :=
  inferInstanceAs (Decidable (_ ∨ _))

def procedureBodyInstalled (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) : ParserState :=
  {outer with
    position := fixedAfter text (procedureClosingAfter text frame arguments) ";" false,
    procedures := ProcedureBindings.append frame.procedures (procedureSourceEntry frame first after),
    «hiding» := hideName text outer.hiding first after,
    assignedInFunctions := outer.assignedInFunctions || (procedureSourceFinal text frame arguments).assigned,
    subtypeNames := {outer.subtypeNames with hiddenCalls := outer.subtypeNames.hiddenCalls.add text first after}}

theorem procedureBodyAt_equation (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) : procedureBodyAt text outer frame first after arguments =
    if (functionLocals text frame arguments).position = 0 then invalidState else
    if (procedureInputFrame text (functionLocals text frame arguments)).position = 0 then invalidState else
    if (procedureSourceReady text frame arguments).position = 0 then invalidState else
    if procedureBodyRejected text outer frame first after arguments then invalidState else
      procedureBodyInstalled text outer frame first after arguments := rfl

structure ProcedureBodyStages (text : Source) (outer frame : ParserState) (first after : Nat)
    (arguments : Bool) : Prop where
  locals : (functionLocals text frame arguments).position ≠ 0
  inputs : (procedureInputFrame text (functionLocals text frame arguments)).position ≠ 0
  prefixReady : (procedureSourceReady text frame arguments).position ≠ 0
  body : (procedureSourceFinal text frame arguments).position ≠ 0
  closingPositive : procedureClosingFirst text frame arguments ≠ 0
  closingAdvances : procedureClosingFirst text frame arguments < procedureClosingAfter text frame arguments
  closingMatches : Named.equalName text first after
    (procedureClosingFirst text frame arguments) (procedureClosingAfter text frame arguments) = true
  advances : outer.position < fixedAfter text (procedureClosingAfter text frame arguments) ";" false
  procedures : (procedureBodyAt text outer frame first after arguments).procedures =
    ProcedureBindings.append frame.procedures (procedureSourceEntry frame first after)

theorem procedureBodyAt_stages {text outer frame first after arguments}
    (accepted : (procedureBodyAt text outer frame first after arguments).position ≠ 0) :
    ProcedureBodyStages text outer frame first after arguments := by
  rw [procedureBodyAt_equation] at accepted
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i localsAccepted
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i inputsAccepted
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i prefixAccepted
        split at accepted
        · exact False.elim (accepted rfl)
        · rename_i checked
          unfold procedureBodyRejected at checked
          refine ⟨localsAccepted, inputsAccepted, prefixAccepted,
            fun zero => checked (.inl zero), fun zero => checked (.inr (.inl zero)), ?_, ?_, ?_, ?_⟩
          · have noBack : ¬procedureClosingAfter text frame arguments ≤ procedureClosingFirst text frame arguments :=
              fun bad => checked (.inr (.inr (.inl bad)))
            omega
          · apply Bool.of_not_eq_false
            intro bad
            exact checked (.inr (.inr (.inr (.inl (by simp only [bad, Bool.not_false])))))
          · have noBack : ¬fixedAfter text (procedureClosingAfter text frame arguments) ";" false ≤ outer.position :=
              fun bad => checked (.inr (.inr (.inr (.inr bad))))
            omega
          · rw [procedureBodyAt_equation]
            have acceptedBody : ¬procedureBodyRejected text outer frame first after arguments := checked
            rw [ite_eq_right localsAccepted, ite_eq_right inputsAccepted,
              ite_eq_right prefixAccepted, ite_eq_right acceptedBody]
            rfl

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
