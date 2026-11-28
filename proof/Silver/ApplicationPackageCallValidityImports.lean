module

public import Silver.ApplicationPackageCallFinishImports
public import Silver.ApplicationPackageCallsValidityMeaning

@[expose] public section

namespace Silver.ApplicationPackageCalls.ValidityImports
open Compose Predicate ApplicationNative
open Compose.Expressions (ValidText StateDomain RawHelperEquations)

set_option backward.dsimp.instances true

/-- Native interval component subtypes only. No declaration, name, active-flow
or semantic validity is required by the original Valid_Flow expression. -/
def ScalarStorage (context : ParseContext) : Prop :=
  ∀ index, (ScalarExpression.binding context.scalarNames index).bounds.Bounded ∧
    (ScalarExpression.binding context.scalarNames index).declaredBounds.Bounded

def ValueStorage (facts : ActiveFlow) : Prop :=
  ∀ value ∈ facts.values, value.Bounded

structure Calls where
  composed : Compose.Expressions.Calls
  included : Integer.Interval → Integer.Interval → Bool
  flow : ParseContext → ActiveFlow → Bool
  body : Source → ParseContext → BodyScan → Bool

def imports (calls : Calls) : ApplicationNative.Calls ValidityNative.Function
  | _, .empty => calls.composed.function .scalarEmpty
  | _, .included => calls.included
  | _, .validFlow => calls.flow

/-- Each equality is the actual typed source expression, evaluated on its
native input fields. The three completed model meanings are conclusions. -/
structure Definitions (calls : Calls) : Prop where
  included : ∀ locals : Locals, (locals .interval "value").Bounded → (locals .interval "bounds").Bounded →
    calls.included (locals .interval "value") (locals .interval "bounds") =
      ValidityNative.includedExpression.eval (imports calls) locals
  flow : ∀ locals : Locals, ScalarStorage (locals .parseContext "context") → ValueStorage (locals .activeFlow "facts") →
    calls.flow (locals .parseContext "context") (locals .activeFlow "facts") =
      ValidityNative.flowExpression.eval (imports calls) locals
  body : ∀ locals : Locals, ValidText (locals .source "text") →
    ScalarStorage (locals .parseContext "context") → ValueStorage (locals .bodyScan "scan").facts →
    calls.body (locals .source "text") (locals .parseContext "context") (locals .bodyScan "scan") =
      ValidityNative.bodyExpression.eval (imports calls) locals

structure Library where
  calls : Calls
  domain : StateDomain
  inherited : RawHelperEquations calls.composed (domain := domain)
  definitions : Definitions calls

theorem value_bound {facts : ActiveFlow} (storage : ValueStorage facts) (index : Nat) :
    (facts.values.getD index Integer.Interval.empty).Bounded := by
  cases found : facts.values[index]? with
  | none => simpa only [List.getD_eq_getElem?_getD, found, Option.getD_none] using Integer.Interval.empty_bounded
  | some value =>
    simpa only [List.getD_eq_getElem?_getD, found, Option.getD_some] using storage value (List.mem_of_getElem? found)

namespace Library

theorem included (library : Library) (prior : Locals) (value bounds : Integer.Interval)
    (valueBound : value.Bounded) (boundsBound : bounds.Bounded) :
    library.calls.included value bounds = includedCheck value bounds := by
  let locals := (prior.set .interval "value" value).set .interval "bounds" bounds
  have defined := library.definitions.included locals
    (show (locals .interval "value").Bounded from valueBound)
    (show (locals .interval "bounds").Bounded from boundsBound)
  change library.calls.included value bounds = _ at defined
  rw [defined]
  change (library.calls.composed.function .scalarEmpty value ||
    (!library.calls.composed.function .scalarEmpty bounds && decide (value.lower ≥ bounds.lower) &&
      decide (value.upper ≤ bounds.upper))) = _
  rw [library.inherited.scalarEmpty value valueBound, library.inherited.scalarEmpty bounds boundsBound]
  rfl

theorem cell (library : Library) (locals : Locals) (offset : Nat)
    (scalars : ScalarStorage (locals .parseContext "context"))
    (values : ValueStorage (locals .activeFlow "facts")) :
    ValidityNative.flowCellExpression.eval (imports library.calls) (locals.set .number "index" (offset + 1)) =
      flowCellCheck (locals .parseContext "context") (locals .activeFlow "facts") (offset + 1) := by
  have current := value_bound values offset
  have row := scalars (offset + 1)
  dsimp only [ValidityNative.flowCellExpression, ValidityNative.binding, ValidityNative.cell,
    ValidityNative.call2, ValidityNative.call1, ValidityNative.context, ValidityNative.facts,
    ValidityNative.index, Expr.eval, Field.get, Index.get, imports, flowCellCheck]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other, decide_eq_true_eq, Nat.add_sub_cancel]
  rw [library.inherited.scalarEmpty _ current, library.included locals _ _ current row.2,
    library.included locals _ _ current row.1]

theorem flow (library : Library) (locals : Locals)
    (scalars : ScalarStorage (locals .parseContext "context"))
    (values : ValueStorage (locals .activeFlow "facts")) :
    library.calls.flow (locals .parseContext "context") (locals .activeFlow "facts") =
      flowValidCheck (locals .parseContext "context") (locals .activeFlow "facts") := by
  rw [library.definitions.flow locals scalars values]
  exact congrArg (fun test : Nat → Bool =>
    decide ((locals .activeFlow "facts").count = (locals .parseContext "context").scalarNames.length) &&
      (List.range (locals .activeFlow "facts").count).all test)
    (funext (fun offset => library.cell locals offset scalars values))

theorem body (library : Library) (locals : Locals) (valid : ValidText (locals .source "text"))
    (scalars : ScalarStorage (locals .parseContext "context"))
    (values : ValueStorage (locals .bodyScan "scan").facts) :
    library.calls.body (locals .source "text") (locals .parseContext "context") (locals .bodyScan "scan") =
      bodyValidCheck (locals .source "text") (locals .parseContext "context") (locals .bodyScan "scan") := by
  rw [library.definitions.body locals valid scalars values]
  have flow := library.flow (locals.set .activeFlow "facts" (locals .bodyScan "scan").facts) scalars values
  change library.calls.flow (locals .parseContext "context") (locals .bodyScan "scan").facts = _ at flow
  change (decide ((locals .bodyScan "scan").position ≤ (locals .source "text").length + 1) &&
    decide ((locals .bodyScan "scan").target ≤ (locals .parseContext "context").names.length) &&
    library.calls.flow (locals .parseContext "context") (locals .bodyScan "scan").facts) = _
  rw [flow]
  rfl

end Library
end Silver.ApplicationPackageCalls.ValidityImports
