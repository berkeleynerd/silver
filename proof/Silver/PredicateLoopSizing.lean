module

public import Silver.PredicateLoopImports
public import Silver.PredicateBodyFlow

@[expose] public section

namespace Silver.Predicate.LoopNative

/-- Each constrained assignment and each indexed access retains the declared
outer or inner Count. Scalar-independent field copies cannot alter the extent. -/
def Update.Sized (imports : Imports) (read : Reader) (frame : Frame) : Update → Prop
  | .widen => (imports.widen frame.context frame.result.facts).count = frame.result.count
  | .inner => frame.context.scalarNames.length < ScalarExpression.maxBindings ∧
      (frame.inner.scalarNames.take frame.context.scalarNames.length ++
        [(⟨frame.first, frame.after, frame.bounds, false, frame.bounds, false⟩ : ScalarExpression.Binding)]).length = frame.scan.count + 1
  | .clearInnerValues =>
      (List.replicate frame.innerScan.count imports.emptyBounds).length = frame.scan.count + 1
  | .copyInnerValues => frame.result.count ≤ frame.innerScan.count ∧
      (copyValuesInto frame.result.facts.values frame.innerScan.facts.values).length = frame.scan.count + 1
  | .indexValue => 0 < frame.innerScan.count ∧ frame.innerScan.count ≤ ScalarExpression.maxBindings ∧
      (frame.innerScan.facts.values.set (frame.innerScan.count - 1) frame.bounds).length = frame.scan.count + 1
  | .restoreFacts => frame.scan.facts.count = frame.result.count
  | .readBody => (read frame.text frame.inner frame.innerScan .endOnly).count = frame.scan.count + 1
  | .token selected => (imports.bodyToken frame.text frame.context frame.result selected).count = frame.scan.count
  | _ => True

/-- Continuation-style size interpretation follows precisely the same early
returns and branches as Command.evalWith. The nested allocation is checked at
the scope command, where the source actually forms Scan.Count + 1. -/
def Command.Sized (imports : Imports) (read : Reader) (frame : Frame)
    (next : Frame → Prop) : Command → Prop
  | .nothing => next frame
  | .update action => action.Sized imports read frame ∧ next (action.evalWith imports read frame)
  | .invalid => (imports.invalid frame.scan).count = frame.scan.count
  | .result => frame.result.count = frame.scan.count
  | .scope body => frame.scan.count + 1 ≤ ScalarExpression.maxBindings ∧
      body.Sized imports read (enterScope frame) next
  | .arrayScope body => body.Sized imports read (enterArrayWith imports frame) next
  | .sequence first second => first.Sized imports read frame
      (fun updated => second.Sized imports read updated next)
  | .choose test yes no => if test.evalWith imports frame then
      yes.Sized imports read frame next else no.Sized imports read frame next

def SizedLoop (imports : Imports) (read : Reader) (text : Source) (context : Native.Context)
    (scan : BodyScan) : Prop :=
  scan.count ≤ ScalarExpression.maxBindings ∧
    (initialWith imports text context scan).result.count = scan.count ∧
    commands.Sized imports read (initialWith imports text context scan) (fun _ => True)

def modelRead : Reader := fun text context scan stop => readBody text context.model scan stop

private theorem modelRead_count (text : Source) (context : Native.Context) (scan : BodyScan) (stop : BodyStop)
    (same : scan.count = context.scalarNames.length) :
    (modelRead text context scan stop).count = scan.count := by
  exact (readBody_count text context.model scan stop same).trans same.symm

/-- After record projections reduce, the size interpreter observes the actual
list extent rather than the count abbreviation. -/
private theorem modelRead_values_length (text : Source) (context : Native.Context)
    (scan : BodyScan) (stop : BodyStop)
    (same : scan.facts.values.length = context.scalarNames.length) :
    (modelRead text context scan stop).facts.values.length = scan.facts.values.length :=
  modelRead_count text context scan stop same

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
attribute [local irreducible] ScalarExpression.read

theorem model_sizedLoop (text : Source) (context : Native.Context) (scan : BodyScan)
    (same : scan.count = context.scalarNames.length)
    (capacity : context.scalarNames.length ≤ ScalarExpression.maxBindings) :
    SizedLoop modelImports modelRead text context scan := by
  have initialSame : initialWith modelImports text context scan = initial text context scan := rfl
  have widened : (ActiveFlow.widen context.scalarNames scan.facts).count = scan.count :=
    ActiveFlow.widen_count context.scalarNames scan.facts same
  unfold SizedLoop
  rw [initialSame]
  refine ⟨by omega, rfl, ?_⟩
  simp only [commands, Command.list, List.foldr_cons, List.foldr_nil, guard, Command.Sized,
    Test.evalWith_model, Update.evalWith_model]
  rw [invalidName_allowed]
  by_cases allowed : loopNameAllowed text context.model (loopHeader text context.model scan) = true
  · have spare : context.scalarNames.length < ScalarExpression.maxBindings := by
      have different : context.scalarNames.length ≠ ScalarExpression.maxBindings := by
        have constraints := allowed
        simp only [loopNameAllowed, Bool.and_eq_true, Native.Context.model] at constraints
        exact of_decide_eq_true constraints.2
      omega
    have scanSpare : scan.facts.values.length + 1 ≤ ScalarExpression.maxBindings := by
      change scan.count + 1 ≤ ScalarExpression.maxBindings
      omega
    simp only [allowed, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    dsimp +instances only [Update.Sized, Update.eval, Test.eval, initial, enterScope, enterArrayWith, enterArray,
      freshInnerScan, ScanField.copy, modelImports, bodyToken, invalidBody, ActiveFlow.invalid]
    simp only [BodyScan.count, ActiveFlow.count] at same widened ⊢
    simp_all [copyValuesInto_count, modelRead_values_length]
  · have disallowed := Bool.eq_false_iff.mpr allowed
    simp only [disallowed, Bool.not_false, ↓reduceIte, modelImports, invalidBody, BodyScan.count,
      ActiveFlow.invalid_count]

end Silver.Predicate.LoopNative
