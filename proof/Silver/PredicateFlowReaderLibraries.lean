module

public import Silver.PredicateFlowReaders
public import Silver.ScalarExpressionNativeEquations
public import Silver.ComposeEquations
public import Silver.ComposeModelCalls

@[expose] public section

namespace Silver.Predicate.FlowReaders
open Compose

variable {domain : Expressions.StateDomain}

/-- The wrapper RHS calls the existing complete scalar reader and expression
reader. The scalar mask remains explicit for loop-bound calls. -/
def inheritedCalls
    (reading : FlowSourceBridge.Context → ActiveFlow.Storage → FlowSourceBridge.NameStorage)
    (composed : Expressions.Calls) (scalars : ScalarExpression.Native.Calls) : Calls where
  reading := reading
  scalar text position names first after := scalars.readExpression text position names first after true
  string text position names scalarNames := composed.function .expression text position names scalarNames false

theorem inherited_meaning {reading composed scalars}
    (readingSource : FlowSourceBridge.InterpretedReadingNames reading)
    (composedEquations : Expressions.HelperEquations composed (domain := domain))
    (primitives : ScalarExpression.Native.Primitives scalars)
    (equations : ScalarExpression.Native.Equations scalars) :
    Meaning (inheritedCalls reading composed scalars) where
  reading := readingSource
  scalar text tv position names first after pv nv mask :=
    ScalarExpression.Native.interpreted_readExpression scalars primitives equations
      text tv position names first after true pv nv mask
  string text tv position names _scalarNames pv nv sv :=
    Expressions.interpreted_expression composed composedEquations text tv position names pv nv sv

abbrev DefaultScalarWrapper := Source → Native.Context → Nat → ActiveFlow → ScalarExpression.Result

/-- Complete wrapper contracts and actual inherited callee identities; the
final current-flow reader equality is derived below. -/
structure Links (composed : Expressions.Calls) (scalar : DefaultScalarWrapper)
    (string : StringWrapper) : Prop where
  source : ∃ reading scalars wrapper,
    FlowSourceBridge.InterpretedReadingNames reading ∧
    ScalarExpression.Native.Primitives scalars ∧ ScalarExpression.Native.Equations scalars ∧
    ScalarRefinement (inheritedCalls reading composed scalars) wrapper ∧
    StringRefinement (inheritedCalls reading composed scalars) string ∧
    ∀ text context position facts, Legal {text, context, position, facts} →
      scalar text context position facts = wrapper text context position facts 0 0

theorem linked_scalar {composed scalar string} (equations : Expressions.HelperEquations composed (domain := domain))
    (links : Links composed scalar string) (inputs : Inputs) (legal : Legal inputs) :
    scalar inputs.text inputs.context inputs.position inputs.facts =
      ScalarExpression.read inputs.text inputs.position (inputs.context.model.readingNames inputs.facts) := by
  obtain ⟨reading, scalars, wrapper, readingSource, primitives, definitions, scalarSource, _, observed⟩ := links.source
  have defaultLegal : Legal {inputs with maskFirst := 0, maskAfter := 0} := legal
  rw [observed inputs.text inputs.context inputs.position inputs.facts legal]
  exact scalar_meaning (inherited_meaning readingSource equations primitives definitions) scalarSource
    {inputs with maskFirst := 0, maskAfter := 0} defaultLegal (Or.inl ⟨rfl, rfl⟩)

theorem linked_string {composed scalar string} (equations : Expressions.HelperEquations composed (domain := domain))
    (links : Links composed scalar string) (inputs : Inputs) (legal : Legal inputs) :
    string inputs.text inputs.context inputs.position inputs.facts =
      expressionAt inputs.text inputs.position inputs.context.names (inputs.context.model.readingNames inputs.facts) := by
  obtain ⟨reading, scalars, wrapper, readingSource, primitives, definitions, _, stringSource, _⟩ := links.source
  exact string_meaning (inherited_meaning readingSource equations primitives definitions) stringSource inputs legal

end Silver.Predicate.FlowReaders
