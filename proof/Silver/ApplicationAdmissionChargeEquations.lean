module

public import Silver.ApplicationAdmissionChargeNative

@[expose] public section

namespace Silver.ApplicationAdmission.Charge
open Compose Compose.Expressions Control

set_option backward.dsimp.instances true

def decrementStep (locals : Locals) : Transfer :=
  if locals .truth "charge" then
    if locals .number "remaining" = 0 then .returned locals
    else .next (locals.set .number "remaining" (locals .number "remaining" - 1))
  else .next locals

def selectStep (calls : Expressions.Calls) (locals : Locals) : Transfer :=
  if locals .number "after_character" ≠ 0 then
    decrementStep (locals.set .number "position" (locals .number "after_character"))
  else if Cursor.byteAt (locals .source "text") (locals .number "first") = 34 then
    let value := calls.function .literal (locals .source "text") (locals .number "first")
    let locals := locals.set .value "quoted" value
    if value.after = 0 then .returned locals
    else decrementStep (locals.set .number "position" value.after)
  else if locals .number "after_name" ≠ 0 then
    let charge := calls.function .nameIs (locals .source "text") (locals .number "first") (locals .number "after_name") "mod" ||
      calls.function .nameIs (locals .source "text") (locals .number "first") (locals .number "after_name") "rem"
    decrementStep ((locals.set .truth "charge" charge).set .number "position" (locals .number "after_name"))
  else if (locals .scalarLiteral "number").after ≠ 0 then
    decrementStep (locals.set .number "position" (locals .scalarLiteral "number").after)
  else if Cursor.byteAt (locals .source "text") (locals .number "first") = 47 ∧
      locals .number "first" < (locals .source "text").length ∧
      Cursor.byteAt (locals .source "text") (locals .number "first" + 1) = 61 then
    decrementStep (locals.set .number "position" (locals .number "first" + 2))
  else
    let charge := decide (Cursor.byteAt (locals .source "text") (locals .number "first") ∈ [38, 43, 45, 42, 47])
    decrementStep ((locals.set .truth "charge" charge).set .number "position" (locals .number "first" + 1))

def iterationStep (calls : Expressions.Calls) (locals : Locals) : Transfer :=
  let first := calls.function .skip (locals .source "text") (locals .number "position")
  let locals := locals.set .number "first" first
  if first = 0 then .returned locals
  else if first > (locals .source "text").length then .returned (locals.set .truth "accepted" true)
  else
    let afterCharacter := calls.function .characterLiteral (locals .source "text") first
    let afterName := calls.function .nameAfter (locals .source "text") first
    let number := calls.function .scalarLiteral (locals .source "text") first
    selectStep calls ((((locals.set .number "after_character" afterCharacter).set .number "after_name" afterName).set
      .scalarLiteral "number" number).set .truth "charge" false)

theorem decrement_meaning (calls : Expressions.Calls) (locals : Locals) :
    decrement.eval calls locals Transfer.next Transfer.returned = decrementStep locals := by
  dsimp only [decrement, Statement.list, List.foldr, Statement.eval, Expr.eval, remaining, decrementStep]
  simp only [decide_eq_true_eq]

theorem select_meaning (calls : Expressions.Calls) (locals : Locals) :
    select.eval calls locals decrementStep Transfer.returned = selectStep calls locals := by
  dsimp only [select, Statement.list, List.foldr, Statement.eval, Expr.eval, text, first, afterName,
    afterCharacter, quoted, number, nameIs, Calls.get, Field.get, Locals.set,
    selectStep]
  simp only [reduceCtorEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.and_eq_true, and_assoc]

theorem iteration_meaning (calls : Expressions.Calls) (locals : Locals) :
    iteration.step calls locals = iterationStep calls locals := by
  dsimp only [Statement.step, iteration, Statement.list, List.foldr, Statement.eval,
    iterationStep, Expr.eval, Calls.get, text, position, first, Locals.set]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  split
  · rfl
  · split
    · rfl
    · change select.eval calls _ (fun store => decrement.eval calls store Transfer.next Transfer.returned) Transfer.returned = _
      simp only [decrement_meaning, select_meaning]

inductive Progress
  | returned (result : ChargeResult)
  | next (position remaining : Nat)

def charged (position remaining : Nat) (charge : Bool) : Progress :=
  if charge then
    if remaining = 0 then .returned ⟨remaining, false⟩ else .next position (remaining - 1)
  else .next position remaining

def selected (calls : Expressions.Calls) (text : Source) (first afterCharacter afterName : Nat)
    (number : ScalarLiteral.Result) (remaining : Nat) : Progress :=
  if afterCharacter ≠ 0 then .next afterCharacter remaining
  else if Cursor.byteAt text first = 34 then
    let value := calls.function .literal text first
    if value.after = 0 then .returned ⟨remaining, false⟩ else .next value.after remaining
  else if afterName ≠ 0 then
    charged afterName remaining (calls.function .nameIs text first afterName "mod" || calls.function .nameIs text first afterName "rem")
  else if number.after ≠ 0 then .next number.after remaining
  else if Cursor.byteAt text first = 47 ∧ first < text.length ∧ Cursor.byteAt text (first + 1) = 61 then
    .next (first + 2) remaining
  else charged (first + 1) remaining (decide (Cursor.byteAt text first ∈ [38, 43, 45, 42, 47]))

def scanStep (calls : Expressions.Calls) (text : Source) (position remaining : Nat) : Progress :=
  let first := calls.function .skip text position
  if first = 0 then .returned ⟨remaining, false⟩
  else if first > text.length then .returned ⟨remaining, true⟩
  else selected calls text first (calls.function .characterLiteral text first)
    (calls.function .nameAfter text first) (calls.function .scalarLiteral text first) remaining

def Ready (text : Source) (position remaining : Nat) (locals : Locals) : Prop :=
  locals .source "text" = text ∧ locals .number "position" = position ∧
    locals .number "remaining" = remaining ∧ locals .truth "accepted" = false

def Represents (text : Source) : Transfer → Progress → Prop
  | .returned locals, .returned result => output locals = result
  | .next locals, .next position remaining => Ready text position remaining locals
  | _, _ => False

theorem decrement_represents (locals : Locals) (unaccepted : locals .truth "accepted" = false) :
    Represents (locals .source "text") (decrementStep locals)
      (charged (locals .number "position") (locals .number "remaining") (locals .truth "charge")) := by
  unfold decrementStep charged
  split
  · split <;> simp_all [Represents, Ready, output, Locals.set]
  · simp_all [Represents, Ready]

theorem select_represents (calls : Expressions.Calls) (locals : Locals)
    (unaccepted : locals .truth "accepted" = false) (uncharged : locals .truth "charge" = false) :
    Represents (locals .source "text") (selectStep calls locals)
      (selected calls (locals .source "text") (locals .number "first") (locals .number "after_character")
        (locals .number "after_name") (locals .scalarLiteral "number") (locals .number "remaining")) := by
  unfold selectStep selected
  split
  · simp_all [decrementStep, Represents, Ready, Locals.set]
  · split
    · dsimp only
      split <;> simp_all [decrementStep, Represents, Ready, output, Locals.set]
    · split
      · simpa only [Locals.set, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte] using
          decrement_represents ((locals.set .truth "charge" _).set .number "position" _) (by simpa [Locals.set] using unaccepted)
      · split
        · simp_all [decrementStep, Represents, Ready, Locals.set]
        · split
          · simp_all [decrementStep, Represents, Ready, Locals.set]
          · simpa only [Locals.set, reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte] using
              decrement_represents ((locals.set .truth "charge" _).set .number "position" _) (by simpa [Locals.set] using unaccepted)

theorem iteration_represents (calls : Expressions.Calls) (locals : Locals)
    (unaccepted : locals .truth "accepted" = false) :
    Represents (locals .source "text") (iteration.step calls locals)
      (scanStep calls (locals .source "text") (locals .number "position") (locals .number "remaining")) := by
  rw [iteration_meaning]
  unfold iterationStep scanStep
  dsimp only [Locals.set]
  simp only [reduceCtorEq, ↓reduceDIte]
  split
  · simp_all [Represents, output, Locals.set]
  · split
    · simp [Represents, output, Locals.set]
    · exact select_represents calls _ (by simpa [Locals.set] using unaccepted) rfl

end Silver.ApplicationAdmission.Charge
