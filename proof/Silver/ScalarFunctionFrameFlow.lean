module

public import Silver.ScalarFunctionFrame
public import Silver.PredicateLoopFlowValidity

@[expose] public section

/-! Native scalar metadata uses the established immutable refinable suffix for
function parameters. Keep these parser-domain lemmas outside execution models. -/
namespace Silver.ScalarFunctions

def parameterBinding (first after : Nat) (bounds : Integer.Interval) : ScalarExpression.Binding :=
  {first, after, bounds, isStatic := false, declaredBounds := bounds, mutable := false}

/-- Formal bindings use the existing immutable refinable suffix convention.
The local declaration count stays fixed while each formal is appended. -/
theorem parameterBinding_refinable (names : ScalarExpression.Environment) (declarations : Nat)
    (count : declarations ≤ names.length) (first after : Nat) (bounds : Integer.Interval) :
    Predicate.ScalarMetadata.refinable (names ++ [parameterBinding first after bounds])
      declarations (names.length + 1) = true := by
  simp only [Predicate.ScalarMetadata.refinable, List.length_append, List.length_singleton,
    ScalarExpression.binding_append_new, parameterBinding, Bool.false_or]
  simp [show declarations < names.length + 1 by omega]

theorem parameterBinding_immutable (names : ScalarExpression.Environment)
    (first after : Nat) (bounds : Integer.Interval) :
    ScalarExpression.mutability (names ++ [parameterBinding first after bounds])
      (names.length + 1) = false := by
  simp [ScalarExpression.mutability, ScalarExpression.binding_append_new, parameterBinding]

theorem parameterBinding_nonstatic (names : ScalarExpression.Environment)
    (first after : Nat) (bounds : Integer.Interval) :
    Predicate.ScalarMetadata.staticness (names ++ [parameterBinding first after bounds])
      (names.length + 1) = false := by
  simp [Predicate.ScalarMetadata.staticness, ScalarExpression.binding_append_new, parameterBinding]

theorem parameterBinding_contextReady {names : ScalarExpression.Environment} {declarations : Nat}
    (ready : Predicate.ScalarMetadata.ContextReady names declarations false)
    (first after : Nat) (bounds : Integer.Interval)
    (space : names.length + 1 ≤ ArrayBindings.scalarLimit) :
    Predicate.ScalarMetadata.ContextReady
      (names ++ [parameterBinding first after bounds]) declarations false :=
  ready.append_immutable _ rfl space

theorem parameterBinding_flowReady {names : ScalarExpression.Environment} {declarations : Nat}
    {flow : Predicate.ActiveFlow}
    (context : Predicate.ScalarMetadata.ContextReady names declarations false)
    (ready : Predicate.ScalarMetadata.FlowReady names declarations flow)
    (first after : Nat) (bounds : Integer.Interval) (typed : bounds.Bounded) :
    Predicate.ScalarMetadata.FlowReady
      (names ++ [parameterBinding first after bounds]) declarations (flow.append bounds) :=
  ready.append_immutable context _ rfl typed

end Silver.ScalarFunctions
