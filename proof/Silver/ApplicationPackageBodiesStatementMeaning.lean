module

public import Silver.ApplicationPackageBodiesStatementFor
public import Silver.ApplicationPackageBodiesStatementProgress

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

private theorem eval_statement (guard selection check returned : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [guard, selection, check, returned]).eval (functions calls valid) (procedures calls) fuel locals next leave =
    guard.eval (functions calls valid) (procedures calls) fuel locals (fun current =>
      selection.eval (functions calls valid) (procedures calls) fuel current
        (fun l => (Statements.Command.list [check, returned]).eval (functions calls valid) (procedures calls)
          fuel l next leave) leave) leave := rfl

private theorem footer_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [
      .choose (.orElse (.le position.expression inputPos) (.not validScan)) invalid .nothing,
      .returned result.expression]).eval (functions calls valid) (procedures calls) fuel locals next leave =
      checkedResult calls locals := by
  dsimp only [Statements.Command.list, List.foldr, Statements.Command.eval, Expr.eval, Place.expression,
    Field.get, result, scan, position, input, inputPos, inputScan, validScan, text, context, invalid, functions,
    checkedResult, validate, source]
  simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true']
  split <;> simp_all

def initializedLocals (calls : Statement.Calls) (valid : ValidFlow) (locals : Locals) : Locals :=
  declarations.foldl (enter (functions calls valid)) locals

theorem initialization_inputs (calls : Statement.Calls) (valid : ValidFlow) (locals : Locals) :
    let entered := initializedLocals calls valid locals
    source entered = source locals ∧ entered .appScan "result" = (source locals).input ∧
      entered .activeFlow "yes" = (source locals).input.scan.facts ∧ entered .truth "have_yes" = false := by
  dsimp only [initializedLocals, declarations, enter, Declaration.eval, Declaration.names, List.foldl,
    Expr.eval, Field.get, inputFacts, inputScan, input, source]
  simp [Locals.set]

theorem body_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals) :
    body.eval (functions calls valid) (procedures calls) fuel locals = statementFuel calls fuel (source locals) := by
  let entered := initializedLocals calls valid locals
  obtain ⟨sourceEq, resultEq, yesEq, haveYesEq⟩ := initialization_inputs calls valid locals
  change source entered = source locals at sourceEq
  change entered .appScan "result" = (source locals).input at resultEq
  change entered .activeFlow "yes" = (source locals).input.scan.facts at yesEq
  change entered .truth "have_yes" = false at haveYesEq
  change commands.eval _ _ _ entered (fun _ => none) (fun _ => none) = _
  rw [commands, eval_statement, funext (fun current => footer_meaning calls valid fuel current (fun _ => none) (fun _ => none)),
    eval_choose]
  have initial : (zero inputPos).eval (functions calls valid) entered = decide ((source locals).input.scan.position = 0) := by
    change decide ((source entered).input.scan.position = 0) = _
    rw [sourceEq]
  rw [initial, statementFuel]
  by_cases empty : (source locals).input.scan.position = 0
  · simp only [empty, decide_true, ↓reduceIte]
    change some (invalidApplication (source entered).input) = _
    rw [sourceEq]
  · simp only [empty, decide_false, Bool.false_eq_true, ↓reduceIte]
    rw [nothing_eval, eval_choose]
    have takeIf : (nonzero (keyword inputPos "if")).eval (functions calls valid) entered =
        decide (calls.takeToken (source locals).text (source locals).input.scan.position (.word "if") ≠ 0) := by
      change decide (calls.takeToken (source entered).text (source entered).input.scan.position (.word "if") ≠ 0) = _
      rw [sourceEq]
    rw [takeIf]
    by_cases isIf : calls.takeToken (source locals).text (source locals).input.scan.position (.word "if") = 0
    · simp only [isIf, ne_self_iff_false, decide_false, Bool.false_eq_true, ↓reduceIte]
      rw [eval_choose]
      have takeFor : (nonzero (keyword inputPos "for")).eval (functions calls valid) entered =
          decide (startFor calls (source locals) ≠ 0) := by
        change decide (startFor calls (source entered) ≠ 0) = _
        rw [sourceEq]
      rw [takeFor]
      by_cases isBasic : startFor calls (source locals) = 0
      · simp only [isBasic, ne_self_iff_false, decide_false, Bool.false_eq_true, ↓reduceIte]
        change some (calls.applicationBasic (source entered).text (source entered).context (source entered).input
          (source entered).info (source entered).catalog (source entered).procedures) = _
        rw [sourceEq]
        simp [startFor] at isBasic
        simp [isBasic]
      · have original : entered .appScan "result" = (source entered).input := resultEq.trans (congrArg Input.input sourceEq.symm)
        have selected : calls.takeToken (source locals).text (source locals).input.scan.position (.word "for") ≠ 0 := isBasic
        simp only [decide_eq_true_eq, ite_eq_left isBasic, ite_eq_left selected]
        rw [forCommands_meaning calls valid fuel entered original, sourceEq]
        rfl
    · simp only [decide_eq_true_eq, ite_eq_left isIf]
      rw [ifCommands_meaning, sourceEq]
      have state : arms (ifEntry calls entered) = ⟨atPosition (source locals).input
          (calls.takeToken (source locals).text (source locals).input.scan.position (.word "if")),
          (source locals).input.scan.facts, false⟩ := by
        simp only [ifEntry, arms, Locals.set]
        change Arms.mk (atPosition (entered .appScan "result")
          (calls.takeToken (source entered).text (entered .appScan "result").scan.position (.word "if")))
          (entered .activeFlow "yes") (entered .truth "have_yes") = _
        rw [resultEq, sourceEq, yesEq, haveYesEq]
      rw [state]
      rfl

theorem body_total (calls : Statement.Calls) (valid : ValidFlow) (locals : Locals) (fuel : Nat)
    (enough : (source locals).text.length + 2 ≤ fuel) :
    ∃ result, body.eval (functions {calls with takeToken := Compose.tokenAfter} valid)
      (procedures {calls with takeToken := Compose.tokenAfter}) fuel locals = some result := by
  rw [body_meaning]
  exact statementFuel_total calls (source locals) fuel enough

end Silver.ApplicationPackageBodies.Statement.Native
