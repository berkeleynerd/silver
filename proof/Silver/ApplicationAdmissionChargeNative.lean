module

public import Silver.ApplicationAdmissionChargeControl
public import Silver.ApplicationAdmissionBudget

@[expose] public section

namespace Silver.ApplicationAdmission.Charge
open Compose Compose.Expressions Control

abbrev text : Expr .source := .variable "text"
abbrev position : Expr .number := .variable "position"
abbrev first : Expr .number := .variable "first"
abbrev afterName : Expr .number := .variable "after_name"
abbrev afterCharacter : Expr .number := .variable "after_character"
abbrev number : Expr .scalarLiteral := .variable "number"
abbrev quoted : Expr .value := .variable "quoted"
abbrev remaining : Expr .number := .variable "remaining"
def nameIs (word : String) : Expr .truth :=
  .app (.app (.app (.app (.function .nameIs) text) first) afterName) (.word word)

def declarations : List Declaration := [
  ⟨.number, ["position"], ["cursor"], some (.number 1)⟩,
  ⟨.number, ["first", "after_name", "after_character"], ["literal_position"], none⟩,
  ⟨.scalarLiteral, ["number"], ["silver_scalar_literals", ".", "literal_result"], none⟩,
  ⟨.value, ["quoted"], ["value_result"], none⟩,
  ⟨.truth, ["charge"], ["boolean"], none⟩]

def select : Statement :=
  .choose (.ne afterCharacter (.number 0)) (.assign "position" afterCharacter)
    (.choose (.eq (.byteAt text first) (.characterVal (.number 34))) (.list [
      .assign "quoted" (.app (.app (.function .literal) text) first),
      .choose (.eq (.field .valueAfter quoted) (.number 0)) .returned .nothing,
      .assign "position" (.field .valueAfter quoted)])
    (.choose (.ne afterName (.number 0)) (.list [
      .assign "charge" (.orElse (nameIs "mod") (nameIs "rem")),
      .assign "position" afterName])
    (.choose (.ne (.field .scalarLiteralAfter number) (.number 0)) (.assign "position" (.field .scalarLiteralAfter number))
    (.choose (.andThen (.andThen (.eq (.byteAt text first) (.character 47)) (.lt first (.sourceLast text)))
      (.eq (.byteAt text (.add first (.number 1))) (.character 61)))
      (.assign "position" (.add first (.number 2))) (.list [
        .assign "charge" (.operatorByte (.byteAt text first)),
        .assign "position" (.add first (.number 1))])))))

def decrement : Statement := .choose (.variable "charge") (.list [
  .choose (.eq remaining (.number 0)) .returned .nothing,
  .assign "remaining" (.sub remaining (.number 1))]) .nothing

def iteration : Statement := .list [
  .annotate (.invariant (.le position (.add (.sourceLast text) (.number 1)))),
  .annotate (.increases position),
  .assign "first" (.app (.app (.function .skip) text) position),
  .choose (.eq first (.number 0)) .returned .nothing,
  .choose (.gt first (.sourceLast text)) (.list [.assign "accepted" (.truth true), .returned]) .nothing,
  .assign "after_character" (.app (.app (.function .characterLiteral) text) first),
  .assign "after_name" (.app (.app (.function .nameAfter) text) first),
  .assign "number" (.app (.app (.function .scalarLiteral) text) first),
  .assign "charge" (.truth false), select, decrement]

def body : Body := ⟨"charge_unit", declarations, .assign "accepted" (.truth false), iteration⟩

def CheckedTree : Prop :=
  body.checked [("text", .source), ("remaining", .number), ("accepted", .truth)] ["remaining", "accepted"] = true

theorem checked_tree : CheckedTree := by unfold CheckedTree; decide +kernel

def output (locals : Locals) : ChargeResult := ⟨locals .number "remaining", locals .truth "accepted"⟩

def inputLocals (prior : Locals) (source : Source) (allowance : Nat) : Locals :=
  (prior.set .source "text" source).set .number "remaining" allowance

def initial (locals : Locals) : Locals :=
  (locals.set .number "position" 1).set .truth "accepted" false

theorem body_exec (calls : Expressions.Calls) (locals : Locals) (result : Locals → Prop) :
    body.Exec calls locals result ↔ ∃ after, LoopExec (iteration.step calls) (initial locals) after ∧ result after := by
  rfl

end Silver.ApplicationAdmission.Charge
