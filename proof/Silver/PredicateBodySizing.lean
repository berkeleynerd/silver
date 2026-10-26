module

public import Silver.PredicateBodyExpressions

@[expose] public section

namespace Silver.Predicate.BodyNative

/-- Constrained native locals retain the entry Scan.Count. Every executed
assignment and out-buffer call is checked before projecting that discriminant. -/
def Command.Sized (primitive : Primitives) (calls : Calls) (frame : Frame) : Command → Prop
  | .nothing | .positionAfter | .ret _ => True
  | .assign value => (value.eval primitive calls frame).count = frame.scan.count
  | .condition => frame.result.count = frame.scan.count ∧
      (primitive.predicate frame.text frame.context frame.result.position frame.result.facts).Counts frame.scan.count
  | .facts value => (value.eval frame).count = frame.scan.count
  | .saveYes => frame.result.count = frame.scan.count
  | .joinYes => frame.result.count = frame.scan.count ∧ frame.yes.count = frame.scan.count ∧
      (primitive.joinInto frame.result.facts frame.yes).count = frame.scan.count
  | .sequence first second => first.Sized primitive calls frame ∧
      match first.eval primitive calls frame with
      | (some _, _) => True
      | (none, next) => second.Sized primitive calls next
  | .choose test yes no => if test.eval primitive calls frame then
      yes.Sized primitive calls frame else no.Sized primitive calls frame

def Function.Sized (fn : Function) (primitive : Primitives) (calls : Calls) (frame : Frame) : Prop :=
  frame.scan.count ≤ ScalarExpression.maxBindings ∧
    (fn.initial.eval primitive calls frame).count = frame.scan.count ∧
    fn.body.Sized primitive calls {frame with result := fn.initial.eval primitive calls frame}

def ModelExpr.Sized (primitive : Primitives) (calls : Calls) (frame : Frame) : ModelExpr → Prop
  | .value _ => True
  | .group expression => expression.Sized primitive calls frame
  | .choose test yes no | .elsif test yes no => if test.eval primitive calls frame then
      yes.Sized primitive calls frame else no.Sized primitive calls frame
  | .localResult initial rest => (initial.eval primitive calls frame).count = frame.scan.count ∧
      rest.Sized primitive calls {frame with result := initial.eval primitive calls frame}

end Silver.Predicate.BodyNative
