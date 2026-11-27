module

public import Silver.ApplicationPackageBodiesBasicNative

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open ApplicationNative ApplicationPackages

set_option backward.dsimp.instances true
set_option maxRecDepth 12000
set_option maxHeartbeats 3000000

structure Ready (calls : BasicCalls) (locals : Locals) : Prop where
  result : locals .appScan "result" = locals .appScan "input"
  value : locals .number "value_first" = assignmentFirst calls (locals .source "text") (locals .appScan "input")
  scalar : locals .number "scalar" = calls.scalarTarget (locals .source "text") (locals .parseContext "context")
    (locals .appScan "input").scan.position
  flag : locals .number "flag" = calls.booleanTarget (locals .source "text") (locals .parseContext "context")
    (locals .appScan "input").scan.position
  state : locals .number "state" = calls.stateTarget (locals .source "text") (locals .parseContext "context")
    (locals .metadata "info") (locals .appScan "input").scan.position

def initialized (calls : BasicCalls) (locals : Locals) : Locals :=
  declarations.foldl (Declaration.eval (functions calls)) locals

local macro "reduce_entry" : tactic => `(tactic|
  (dsimp only [initialized, declarations, positionalConstant, List.foldl, Declaration.eval, Declaration.names,
     Expr.eval, Field.get, target, position, inputScan, info, text, input, context, functions]
   simp [assignmentFirst, Locals.set]))

theorem initialized_ready (calls : BasicCalls) (locals : Locals) : Ready calls (initialized calls locals) := by
  constructor <;> reduce_entry

def assignmentResult (calls : BasicCalls) (locals : Locals) : ApplicationScan :=
  functionAssignment calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
    (locals .metadata "info") (locals .functions "catalog") (locals .procedures "procedure_catalog")

local macro "reduce_assignment" : tactic => `(tactic|
  (dsimp only [assignmentCommands, Command.list, List.foldr, Command.eval, Place.set, Place.expression, Expr.eval,
     Updates.eval, Field.get, Field.set, Index.set, packageCall, semicolon, nativeBasic, text, context, input,
     info, result, called, scan, inputScan, position, valueFirst, functions, Locals.set,
     assignmentResult, functionAssignment]
   simp_all [-ne_eq, -Nat.not_le, -Nat.not_lt]))

theorem assignment_meaning (calls : BasicCalls) (locals : Locals) (ready : Ready calls locals)
    (next : ApplicationScan → ApplicationScan → ApplicationScan) :
    assignmentCommands.eval (functions calls) locals (fun updated => next (updated .appScan "input") (updated .appScan "result")) =
      next (locals .appScan "input") (assignmentResult calls locals) := by
  obtain ⟨resultEq, firstEq, scalarEq, flagEq, stateEq⟩ := ready
  by_cases accepted : (calls.packageCallAt (locals .source "text") (locals .parseContext "context")
    (locals .appScan "input") (locals .metadata "info")
    (assignmentFirst calls (locals .source "text") (locals .appScan "input")) .function).value.after ≠ 0
  all_goals by_cases state : (calls.stateTarget (locals .source "text") (locals .parseContext "context") (locals .metadata "info") (locals .appScan "input").scan.position ≠ 0)
  all_goals reduce_assignment

def selected (calls : BasicCalls) (locals : Locals) : ApplicationScan :=
  basicResult calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
    (locals .metadata "info") (locals .functions "catalog") (locals .procedures "procedure_catalog")

theorem dispatch_meaning (calls : BasicCalls) (locals : Locals) (ready : Ready calls locals)
    (next : ApplicationScan → ApplicationScan → ApplicationScan) :
    dispatch.eval (functions calls) locals (fun updated => next (updated .appScan "input") (updated .appScan "result")) =
      next (locals .appScan "input") (selected calls locals) := by
  dsimp only [dispatch, Command.eval, Expr.eval, Field.get, valueFirst, input, text, context, info, position, inputScan, functions]
  simp only [Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq]
  rcases ready with ⟨resultEq, firstEq, scalarEq, flagEq, stateEq⟩
  rw [firstEq, scalarEq, flagEq]
  split
  · rename_i assignment
    rw [assignment_meaning calls locals ⟨resultEq, firstEq, scalarEq, flagEq, stateEq⟩ next]
    simp [selected, basicResult, assignmentResult, assignment]
  · rename_i ordinary
    split <;> rename_i procedure
    all_goals dsimp only [Command.list, List.foldr, Command.eval, Place.set, Place.expression, Expr.eval,
      Field.get, Field.set, packageCall, semicolon, nativeBasic, text, context, input, info,
      result, called, scan, inputScan, position, functions, Locals.set]
    all_goals simp_all [-not_and, -not_or, selected, basicResult, procedureStatement]

def finalResult (input result : ApplicationScan) : ApplicationScan :=
  if decide (result.scan.position ≤ input.scan.position) then invalidApplication input else result

theorem commands_meaning (calls : BasicCalls) (locals : Locals) (ready : Ready calls locals) (next : Locals → ApplicationScan) :
    Command.eval (resultType := .appScan) (functions calls) locals next commands =
      applicationBasic calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
        (locals .metadata "info") (locals .functions "catalog") (locals .procedures "procedure_catalog") := by
  change (if decide ((locals .appScan "input").scan.position = 0) then invalidApplication (locals .appScan "input")
    else Command.eval (resultType := .appScan) (functions calls) locals (fun updated => finalResult (updated .appScan "input") (updated .appScan "result")) dispatch) = _
  rw [dispatch_meaning calls locals ready finalResult]
  by_cases zero : (locals .appScan "input").scan.position = 0
  · simp [applicationBasic, zero]
  · by_cases stalled : (selected calls locals).scan.position ≤ (locals .appScan "input").scan.position
    all_goals dsimp only [selected] at stalled
    all_goals simp [applicationBasic, zero, finalResult, selected, stalled]

theorem body_meaning (calls : BasicCalls) (locals : Locals) :
    body.eval (functions calls) locals =
      applicationBasic calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
        (locals .metadata "info") (locals .functions "catalog") (locals .procedures "procedure_catalog") := by
  change Command.eval (resultType := .appScan) _ (initialized calls locals) _ commands = _
  rw [commands_meaning calls _ (initialized_ready calls locals)]
  reduce_entry

end Silver.ApplicationPackageBodies.Basic
