module

public import Silver.ApplicationPackageBodiesStatementEntry

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true
set_option maxRecDepth 12000

theorem setIterator_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    setIterator.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (iteratorFrame (frame locals)) := by
  dsimp only [setIterator, Statements.Command.list, List.foldr, Statements.Command.eval, Place.set, Place.expression,
    Expr.eval, Field.get, Field.set, Index.set, Property.get, insideCount, inside, insideScan, insideFacts, bounds,
    frame, iteration, source, Locals.set, iteratorFrame, LoopFrame.withValues, withFacts]
  rfl

theorem eval_three (first second third : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [first, second, third]).eval (functions calls valid) (procedures calls) fuel locals next leave =
    first.eval (functions calls valid) (procedures calls) fuel locals
      (fun l => second.eval (functions calls valid) (procedures calls) fuel l
        (fun m => third.eval (functions calls valid) (procedures calls) fuel m next leave) leave) leave := rfl

theorem innerEntry_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    innerEntry.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (iteratorFrame (copiedFrame (preparedFrame (frame locals)))) := by
  rw [innerEntry, eval_three, funext (fun current => setIterator_meaning calls valid fuel current next leave)]
  have copied := funext (fun current => copyValues_meaning calls valid fuel current (fun f => next (iteratorFrame f)) leave)
  rw [copied]
  exact prepareInner_meaning calls valid fuel locals (fun f => next (iteratorFrame (copiedFrame f))) leave

def readLoop (calls : Statement.Calls) (f : LoopFrame) (next : ResultContinuation) : Option ApplicationScan :=
  let body := tail calls f.scope f.inner f.inside .endOnly
  if body.scan.position = 0 then some (invalidApplication f.scope.input)
  else next f.scope (afterIteration calls f.scope f.current f.current.value.scan.facts body)

def LoopFrame.withResult (f : LoopFrame) (value : ApplicationScan) : LoopFrame :=
  {f with current := {f.current with value}}

def returnedCursor (f : LoopFrame) : LoopFrame :=
  let v := f.current.value
  let updated := {v.scan with
    position := f.inside.scan.position
    target := f.inside.scan.target
    capacity := f.inside.scan.capacity}
  f.withResult {v with scan := updated}

def returnedFlags (f : LoopFrame) : LoopFrame :=
  let v := f.current.value
  f.withResult {v with scan := {v.scan with assigned := f.inside.scan.assigned, output := f.inside.scan.output}}

def returnedEffects (f : LoopFrame) : LoopFrame :=
  f.withResult {f.current.value with reads := f.inside.reads, writes := f.inside.writes}

def returnedPath (calls : Statement.Calls) (f : LoopFrame) : ApplicationScan :=
  let v := f.current.value
  let path := if f.current.definite then f.inside.scan.facts.path
    else calls.pathJoin f.scope.input.scan.facts.path f.inside.scan.facts.path
  let facts := if f.current.bounds.isEmpty then f.scope.input.scan.facts else {v.scan.facts with path}
  withFacts v facts

local macro "reduce_return_fields" : tactic => `(tactic|
  (dsimp only [Statements.Command.list, List.foldr, Statements.Command.eval, Place.set, Place.expression,
    Expr.eval, Field.get, Field.set, result, scan, inside, insideScan, position, facts, reads, frame,
    iteration, source, Locals.set, LoopFrame.withResult]
   try rfl))

theorem returnCursor_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    (moveCursor scan insideScan).eval (functions calls valid) (procedures calls) fuel locals (fun l => next (frame l)) leave =
    next (returnedCursor (frame locals)) := by
  unfold moveCursor returnedCursor
  reduce_return_fields

theorem returnFlags_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    (moveFlags scan insideScan).eval (functions calls valid) (procedures calls) fuel locals (fun l => next (frame l)) leave =
    next (returnedFlags (frame locals)) := by
  unfold moveFlags returnedFlags
  reduce_return_fields

theorem returnEffects_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    returnEffects.eval (functions calls valid) (procedures calls) fuel locals (fun l => next (frame l)) leave =
    next (returnedEffects (frame locals)) := by
  unfold returnEffects returnedEffects
  reduce_return_fields

def finishReturned (calls : Statement.Calls) (f : LoopFrame) (next : ResultContinuation) : Option ApplicationScan :=
  next f.scope (returnedPath calls f)

theorem returnPath_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : ResultContinuation) (leave : Continuation) :
    returnPath.eval (functions calls valid) (procedures calls) fuel locals
      (fun l => next (source l) (l .appScan "result")) leave =
    finishReturned calls (frame locals) next := by
  by_cases empty : (locals .interval "bounds").isEmpty = true
  all_goals by_cases definite : locals .truth "definite" = true
  all_goals
    dsimp only [returnPath, Statements.Command.eval, Place.set, Place.expression, Expr.eval, Field.get, Field.set,
      insideScan, insideFacts, inside, input, inputScan, inputFacts, scan, result, facts, isEmpty, bounds,
      functions, Locals.set, frame, iteration, source, finishReturned, returnedPath, withFacts]
    simp_all

theorem eval_four (a b c d : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [a,b,c,d]).eval (functions calls valid) (procedures calls) fuel locals next leave =
    a.eval (functions calls valid) (procedures calls) fuel locals (fun l =>
      b.eval (functions calls valid) (procedures calls) fuel l (fun l =>
        c.eval (functions calls valid) (procedures calls) fuel l
          (fun l => d.eval (functions calls valid) (procedures calls) fuel l next leave) leave) leave) leave := rfl

theorem returnScan_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : ResultContinuation) (leave : Continuation) :
    returnScan.eval (functions calls valid) (procedures calls) fuel locals
      (fun l => next (source l) (l .appScan "result")) leave =
    next (source locals) (afterIteration calls (source locals) (iteration locals)
      (iteration locals).value.scan.facts (locals .appScan "inside")) := by
  rw [returnScan, eval_four, funext (fun l => returnPath_meaning calls valid fuel l next leave)]
  rw [funext (fun l => returnEffects_meaning calls valid fuel l
    (fun f => finishReturned calls f next) leave)]
  rw [funext (fun l => returnFlags_meaning calls valid fuel l
    (fun f => finishReturned calls (returnedEffects f) next) leave)]
  exact returnCursor_meaning calls valid fuel locals
    (fun f => finishReturned calls (returnedEffects (returnedFlags f)) next) leave

theorem innerReturn_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : ResultContinuation) (leave : Continuation) :
    innerReturn.eval (functions calls valid) (procedures calls) fuel locals
      (fun l => next (source l) (l .appScan "result")) leave = readLoop calls (frame locals) next := by
  rw [innerReturn, eval_three, funext (fun l => returnScan_meaning calls valid fuel l next leave)]
  dsimp only [Statements.Command.eval, Place.set, Place.expression, Expr.eval, Field.get, zero, invalid, input,
    inside, insideScan, inner, text, info, callTail, functions, source, iteration, frame, readLoop, tail, Locals.set]
  simp

def insideLocals (calls : Statement.Calls) (valid : ValidFlow) (locals : Locals) : Locals :=
  innerDeclarations.foldl (enter (functions calls valid)) locals

theorem readyFrame (calls : Statement.Calls) (valid : ValidFlow) (locals : Locals) :
    iteratorFrame (copiedFrame (preparedFrame (frame (insideLocals calls valid locals)))) =
      ⟨source locals, iteration locals, innerContext (source locals) (iteration locals),
        innerInput (source locals) (iteration locals) (iteration locals).value.scan.facts⟩ := by
  let opened := insideLocals calls valid locals
  have inputs : source opened = source locals ∧ iteration opened = iteration locals ∧
      opened .parseContext "inner" = (source locals).context ∧
      (opened .appScan "inside").count = (source locals).input.count + 1 := by
    dsimp only [opened, insideLocals, innerDeclarations, List.foldl, enter, Declaration.eval,
      Declaration.names, Expr.eval, Property.get, input, context, allocate, allocatedFlow,
      Initialization.value, Initialization.applicationScan, source, iteration,
      ApplicationScan.count, Predicate.BodyScan.count, Predicate.ActiveFlow.count]
    simp [Locals.set, allocatedValues_count]
  obtain ⟨sameSource, sameIteration, sameContext, size⟩ := inputs
  change iteratorFrame (copiedFrame (preparedFrame (frame opened))) = _
  simp only [frame, preparedFrame, copiedFrame, iteratorFrame, LoopFrame.withValues, sameSource, sameIteration,
    sameContext, size, innerContext, innerInput, withFacts]
  simp only [ApplicationScan.count, Predicate.BodyScan.count, Predicate.ActiveFlow.count,
    copySlots_length, List.length_replicate, Nat.add_sub_cancel, copy_append_bound]

theorem innerBlock_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : ResultContinuation) (leave : Continuation) :
    (Statements.Command.block innerDeclarations (.sequence innerEntry innerReturn)).eval
      (functions calls valid) (procedures calls) fuel locals (fun l => next (source l) (l .appScan "result")) leave =
      readLoop calls ⟨source locals, iteration locals, innerContext (source locals) (iteration locals),
        innerInput (source locals) (iteration locals) (iteration locals).value.scan.facts⟩ next := by
  have restored (current : Locals) :
      next (source (Declarations.restore innerDeclarations locals current))
        (Declarations.restore innerDeclarations locals current .appScan "result") =
      next (source current) (current .appScan "result") := by
    simp [source, Declarations.restore, innerDeclarations, Declaration.names]
  rw [Statements.Command.eval]
  simp only [restored]
  rw [sequence_eval, funext (fun current => innerReturn_meaning calls valid fuel current next _)]
  exact (innerEntry_meaning calls valid fuel (insideLocals calls valid locals) (fun f => readLoop calls f next)
    (fun updated => leave (Declarations.restore innerDeclarations locals updated))).trans
    (congrArg (fun f => readLoop calls f next) (readyFrame calls valid locals))

end Silver.ApplicationPackageBodies.Statement.Native
