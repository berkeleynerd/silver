module

public import Silver.PathNativeExpressions

@[expose] public section

namespace Silver.PathFacts.Native
open Bindings Predicate

@[simp] theorem compareBody_eval (locals : Locals) :
    compareBody.eval locals = (locals .comparison "operator").evaluate (locals .number "left") (locals .number "right") := by rfl

@[simp] theorem complementBody_eval (locals : Locals) :
    complementBody.eval locals = (locals .comparison "operator").complement := by rfl

@[simp] theorem swapBody_eval (locals : Locals) :
    swapBody.eval locals = (locals .comparison "operator").swap := by rfl

@[simp] theorem initialBody_eval (locals : Locals) :
    initialBody.eval locals = initial (locals .truth "arguments") := by rfl

@[simp] theorem ceilingBody_eval (locals : Locals) :
    ceilingBody.eval locals = ceiling (locals .context "facts") := by rfl

@[simp] theorem assumeValidBody_eval (locals : Locals) :
    assumeValidBody.eval locals = assumeValid (locals .context "facts") := by rfl

@[simp] theorem assumeInvalidBody_eval (locals : Locals) :
    assumeInvalidBody.eval locals = assumeInvalid (locals .context "facts") := by rfl

@[simp] theorem rejectedBody_eval (locals : Locals) :
    rejectedBody.eval locals = rejected (locals .context "facts") := by rfl

@[simp] theorem completedBody_eval (locals : Locals) :
    completedBody.eval locals = completed (locals .context "facts") := by rfl

@[simp] theorem keepIfBody_eval (locals : Locals) :
    keepIfBody.eval locals = keepIf (locals .context "facts") (locals .truth "condition") := by rfl

@[simp] theorem intersectBody_eval (locals : Locals) :
    intersectBody.eval locals = intersect (locals .context "facts") (locals .number "lower") (locals .number "upper") := by rfl

@[simp] theorem joinBody_eval (locals : Locals) :
    joinBody.eval locals = join (locals .context "left") (locals .context "right") := by rfl

@[simp] theorem belowBody_eval (locals : Locals) :
    belowBody.eval locals = below (locals .context "facts") (locals .number "threshold") := by
  change (if decide (locals .number "threshold" = 0) then empty else
    intersect (locals .context "facts") 0 (locals .number "threshold" - 1)) = _
  simp only [decide_eq_true_eq, below]

@[simp] theorem aboveBody_eval (locals : Locals) :
    aboveBody.eval locals = above (locals .context "facts") (locals .number "threshold") := by rfl

@[simp] theorem refineInputTrueBody_eval (locals : Locals) :
    refineInputTrueBody.eval locals = refineInputTrue (locals .context "facts") (locals .comparison "operator") (locals .number "threshold") := by rfl

@[simp] theorem refineInputBody_eval (locals : Locals) :
    refineInputBody.eval locals = refineInput (locals .context "facts") (locals .comparison "operator") (locals .number "threshold") (locals .truth "truth") := by rfl

@[simp] theorem refineBoundsBody_eval (locals : Locals) :
    refineBoundsBody.eval locals = refineBounds (locals .context "facts") (locals .comparison "operator") (locals .bound "left") (locals .bound "right") (locals .truth "truth") := by rfl

@[simp] theorem lengthAtBody_eval (locals : Locals) :
    lengthAtBody.eval locals = lengthAt (locals .summary "value") (locals .number "input_length") := by rfl

@[simp] theorem fitsBody_eval (locals : Locals) :
    fitsBody.eval locals = fits (locals .context "facts") (locals .summary "value") := by rfl

@[simp] theorem sameLengthBody_eval (locals : Locals) :
    sameLengthBody.eval locals = sameLength (locals .context "facts") (locals .summary "left") (locals .summary "right") := by rfl

@[simp] theorem equalIncreasingBody_eval (locals : Locals) :
    equalIncreasingBody.eval locals = equalIncreasing (locals .context "facts") (locals .summary "left") (locals .summary "right") := by
  simp [equalIncreasingBody, Expr.eval, Function.eval, equalIncreasing, Field.get, Locals.set]
  simp only [Bool.beq_eq_decide_eq]

@[simp] theorem refineEqualBody_eval (locals : Locals) :
    refineEqualBody.eval locals = refineEqual (locals .context "facts") (locals .summary "left") (locals .summary "right") := by
  change (if decide ((locals .summary "left").dynamicCount = (locals .summary "right").dynamicCount) then
    keepIf (locals .context "facts") (decide ((locals .summary "left").staticLength = (locals .summary "right").staticLength))
    else if decide ((locals .summary "right").dynamicCount < (locals .summary "left").dynamicCount) then
      equalIncreasing (locals .context "facts") (locals .summary "left") (locals .summary "right")
    else equalIncreasing (locals .context "facts") (locals .summary "right") (locals .summary "left")) = _
  simp only [decide_eq_true_eq, refineEqual, Bool.beq_eq_decide_eq]

end Silver.PathFacts.Native
