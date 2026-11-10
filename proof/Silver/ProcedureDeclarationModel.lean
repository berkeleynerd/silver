module

public import Silver.ProcedureDeclarationAdmission

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

/-- The successful model result is the exact outer-frame update, retaining the
ordinary body's actual assignment flag together with any initialization prefix. -/
theorem procedureBodyAt_installed {text outer frame first after arguments}
    (accepted : (procedureBodyAt text outer frame first after arguments).position ≠ 0) :
    procedureBodyAt text outer frame first after arguments =
      procedureBodyInstalled text outer frame first after arguments := by
  have stages := procedureBodyAt_stages accepted
  rw [procedureBodyAt_equation] at accepted ⊢
  simp only [stages.locals, stages.inputs, stages.prefixReady, ↓reduceIte] at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i good
    rw [ite_eq_right good]

theorem procedureBodyAt_assigned {text outer frame first after arguments}
    (accepted : (procedureBodyAt text outer frame first after arguments).position ≠ 0) :
    (procedureBodyAt text outer frame first after arguments).assignedInFunctions =
      (outer.assignedInFunctions || (procedureSourceFinal text frame arguments).assigned) := by
  rw [procedureBodyAt_installed accepted]
  rfl

end Silver.Compose
