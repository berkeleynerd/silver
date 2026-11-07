module

public import Silver.ScalarFunctionDefinition
public import Silver.BooleanFreezing

@[expose] public section

namespace Silver.ScalarFunctions
open Predicate

/-- A scalar Boolean initializer becomes a Boolean-only condition after its
Integer snapshot is frozen. Its checker then ignores both Integer analyses and
flows, so interleaved local declarations can retain separate semantic stores. -/
theorem frozenScalarCondition_checkBounds {condition : Condition}
    (scalar : scalarCondition condition = true) (snapshot : Integer.Store)
    (leftShape rightShape : Bindings.Shape) (leftAnalysis rightAnalysis : Integer.Analysis)
    (leftFlow rightFlow : Flow) (booleans : Boolean.Analysis) :
    (condition.freezeIntegers snapshot).checkBounds leftShape leftAnalysis leftFlow booleans =
      (condition.freezeIntegers snapshot).checkBounds rightShape rightAnalysis rightFlow booleans := by
  induction condition generalizing leftFlow rightFlow with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanArrayRead =>
      simp only [scalarCondition, Bool.false_eq_true] at scalar
  | scalarCompare | booleanLiteral | booleanName => rfl
  | parenthesized inner ih | negated inner ih => exact ih scalar leftFlow rightFlow
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      simp only [scalarCondition, Bool.and_eq_true] at scalar
      simp only [Condition.freezeIntegers, Condition.checkBounds]
      rw [ihl scalar.1, ihr scalar.2]

end Silver.ScalarFunctions
