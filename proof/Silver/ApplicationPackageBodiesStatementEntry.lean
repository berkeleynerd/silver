module

public import Silver.ApplicationPackageBodiesStatementCopy

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true
set_option maxRecDepth 12000

abbrev ResultContinuation := Input → ApplicationScan → Option ApplicationScan

def preparedFrame (f : LoopFrame) : LoopFrame :=
  let it := f.current
  let inner := {f.inner with scalarNames := f.inner.scalarNames ++
    [⟨it.first, it.last, it.bounds, false, it.bounds, false, 0, 0⟩]}
  let path := if it.bounds.isEmpty then PathFacts.Context.empty else it.value.scan.facts.path
  {f with inner, inside := withFacts it.value ⟨path, List.replicate f.inside.count .empty⟩}

def copiedFrame (f : LoopFrame) : LoopFrame :=
  let values := f.current.value.scan.facts.values
  f.withValues (copySlots values f.inside.scan.facts.values values.length)

def iteratorFrame (f : LoopFrame) : LoopFrame :=
  f.withValues (f.inside.scan.facts.values.set (f.inside.count - 1) f.current.bounds)

def extendFrame (f : LoopFrame) : LoopFrame :=
  {f with inner := {f.inner with scalarNames := f.inner.scalarNames ++
    [⟨f.current.first, f.current.last, f.current.bounds, false, f.current.bounds, false, 0, 0⟩]}}

def cursorFrame (f : LoopFrame) : LoopFrame :=
  let value := f.current.value.scan
  {f with inside := {f.inside with scan := {f.inside.scan with position := value.position, target := value.target, capacity := value.capacity}}}

def flagsFrame (f : LoopFrame) : LoopFrame :=
  let value := f.current.value.scan
  {f with inside := {f.inside with scan := {f.inside.scan with assigned := value.assigned, output := value.output}}}

def effectsFrame (f : LoopFrame) : LoopFrame :=
  {f with inside := {f.current.value with scan := f.inside.scan}}

def valuesFrame (f : LoopFrame) : LoopFrame :=
  let it := f.current
  let path := if it.bounds.isEmpty then PathFacts.Context.empty else it.value.scan.facts.path
  {f with inside := withFacts f.inside ⟨path, List.replicate f.inside.count .empty⟩}

local macro "reduce_frame_update" : tactic => `(tactic|
  (dsimp only [moveCursor, moveFlags, Statements.Command.list, List.foldr, Statements.Command.eval, Statements.Primitive.eval,
    Place.set, Place.expression, Expr.eval, Field.get, Field.set, Property.get, inner, inside, insideScan, insideFacts,
    first, last, bounds, result, scan, facts, reads, position, isEmpty, functions, frame, iteration, source,
    Locals.set, withFacts, ApplicationScan.count, Predicate.BodyScan.count, Predicate.ActiveFlow.count]
   try rfl))

theorem extendInner_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    extendInner.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (extendFrame (frame locals)) := by
  unfold extendInner extendFrame
  reduce_frame_update

theorem copyCursor_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    copyCursor.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (cursorFrame (frame locals)) := by
  unfold copyCursor cursorFrame
  reduce_frame_update

theorem copyFlags_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    copyFlags.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (flagsFrame (frame locals)) := by
  unfold copyFlags flagsFrame
  reduce_frame_update

theorem copyEffects_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    copyEffects.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (effectsFrame (frame locals)) := by
  unfold copyEffects effectsFrame
  reduce_frame_update

theorem prepareValues_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    prepareValues.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (valuesFrame (frame locals)) := by
  unfold prepareValues valuesFrame
  reduce_frame_update

theorem eval_five (a b c d e : C) (calls : Statement.Calls) (valid : ValidFlow)
    (fuel : Nat) (locals : Locals) (next leave : Continuation) :
    (Statements.Command.list [a,b,c,d,e]).eval (functions calls valid) (procedures calls) fuel locals next leave =
    a.eval (functions calls valid) (procedures calls) fuel locals (fun l =>
      b.eval (functions calls valid) (procedures calls) fuel l (fun l =>
        c.eval (functions calls valid) (procedures calls) fuel l (fun l =>
          d.eval (functions calls valid) (procedures calls) fuel l
            (fun l => e.eval (functions calls valid) (procedures calls) fuel l next leave) leave) leave) leave) leave := rfl

theorem prepareInner_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    prepareInner.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
      next (preparedFrame (frame locals)) := by
  rw [prepareInner, eval_five, funext (fun l => prepareValues_meaning calls valid fuel l next leave)]
  rw [funext (fun l => copyEffects_meaning calls valid fuel l (fun f => next (valuesFrame f)) leave)]
  rw [funext (fun l => copyFlags_meaning calls valid fuel l (fun f => next (valuesFrame (effectsFrame f))) leave)]
  rw [funext (fun l => copyCursor_meaning calls valid fuel l (fun f => next (valuesFrame (effectsFrame (flagsFrame f)))) leave)]
  exact extendInner_meaning calls valid fuel locals
    (fun f => next (valuesFrame (effectsFrame (flagsFrame (cursorFrame f))))) leave

end Silver.ApplicationPackageBodies.Statement.Native
