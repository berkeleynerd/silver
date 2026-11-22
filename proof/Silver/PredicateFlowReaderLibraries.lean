module

public import Silver.PredicateFlowReaders
public import Silver.ScalarExpressionNativeEquations
public import Silver.ComposeHelperEquations
public import Silver.ComposeModelCalls
public import Silver.BooleanBindingsSourceBridge

@[expose] public section

namespace Silver.Predicate.FlowReaders
open Compose

variable {domain : Expressions.StateDomain}

def inheritedCalls
    (reading : FlowSourceBridge.Context → ActiveFlow.Storage → FlowSourceBridge.NameStorage)
    (composed : Expressions.Calls) (scalars : ScalarExpression.Native.Calls)
    (booleans : BooleanBindings.SourceBridge.InterpretedSource) : Calls where
  reading := reading
  scalar text position names first after arrays initials elaborating :=
    scalars.readExpression text position names first after true arrays initials elaborating .allElements
  string text position names scalarNames hidden arrays initials elaborating :=
    composed.function .expression text position names scalarNames hidden arrays initials elaborating
  booleanHidesInteger := booleans.hidesInteger
  nameIs := composed.function .nameIs

theorem inherited_meaning {reading composed scalars}
    (booleans : BooleanBindings.SourceBridge.InterpretedSource)
    (readingSource : FlowSourceBridge.InterpretedReadingNames reading)
    (composedEquations : Expressions.RawHelperEquations composed (domain := domain))
    (primitives : ScalarExpression.Native.Primitives scalars)
    (equations : ScalarExpression.Native.Equations scalars) :
    Meaning (inheritedCalls reading composed scalars booleans) where
  reading := readingSource
  booleanHidesInteger text tv names nv := booleans.hidesInteger_meaning text tv names nv
  nameIs text tv first after nv := composedEquations.nameIs text tv first after "integer" nv (by decide) (by decide)
  scalar text tv position names first after arrays initials elaborating pv nv mask av iv :=
    ScalarExpression.Native.interpreted_readExpression_table scalars primitives equations
      text tv position names first after true arrays initials elaborating .allElements pv nv mask av iv
  string text tv position names scalarNames hidden arrays initials elaborating pv nv sv av iv :=
    Expressions.interpreted_expression composed composedEquations text tv position names pv nv sv av iv

abbrev FullScalarWrapper := Source → Native.Context → Nat → ActiveFlow → ArrayBindings.Initials → ScalarExpression.Result
abbrev DefaultScalarWrapper := Source → Native.Context → Nat → ActiveFlow → ScalarExpression.Result
abbrev DefaultStringWrapper := Source → Native.Context → Nat → ActiveFlow → ExpressionResult

/-- Full native wrapper domain, including every value of the fixed Element_Array
parameter. The default-argument views below are derived from these same calls. -/
structure FullLinks (composed : Expressions.Calls) (scalar : FullScalarWrapper)
    (string : StringWrapper) : Prop where
  source : ∃ reading scalars wrapper booleans,
    FlowSourceBridge.InterpretedReadingNames reading ∧
    ScalarExpression.Native.Primitives scalars ∧ ScalarExpression.Native.Equations scalars ∧
    ScalarRefinement (inheritedCalls reading composed scalars booleans) wrapper ∧
    StringRefinement (inheritedCalls reading composed scalars booleans) string ∧
    ∀ text context position facts initials, Legal {text, context, position, facts, initials} →
      scalar text context position facts initials = wrapper text context position facts 0 0 initials

theorem linked_scalar_full {composed scalar string} (equations : Expressions.RawHelperEquations composed (domain := domain))
    (links : FullLinks composed scalar string) (inputs : Inputs) (legal : Legal inputs) :
    scalar inputs.text inputs.context inputs.position inputs.facts inputs.initials =
      readScalarInFlow inputs.text inputs.context.model inputs.position inputs.facts (initials := inputs.initials) := by
  obtain ⟨reading, scalars, wrapper, booleans, readingSource, primitives, definitions, scalarSource, _, observed⟩ := links.source
  have defaultLegal : Legal {inputs with maskFirst := 0, maskAfter := 0} :=
    ⟨legal.text, legal.context, legal.flow, legal.position, legal.initials⟩
  rw [observed inputs.text inputs.context inputs.position inputs.facts inputs.initials defaultLegal]
  exact scalar_meaning (inherited_meaning booleans readingSource equations primitives definitions) scalarSource
    {inputs with maskFirst := 0, maskAfter := 0} defaultLegal (Or.inl ⟨rfl, rfl⟩)

theorem linked_string_full {composed scalar string} (equations : Expressions.RawHelperEquations composed (domain := domain))
    (links : FullLinks composed scalar string) (inputs : Inputs) (legal : Legal inputs) :
    string inputs.text inputs.context inputs.position inputs.facts inputs.initials =
      readStringInFlow inputs.text inputs.context.model inputs.position inputs.facts inputs.initials := by
  obtain ⟨reading, scalars, wrapper, booleans, readingSource, primitives, definitions, _, stringSource, _⟩ := links.source
  exact string_meaning (inherited_meaning booleans readingSource equations primitives definitions) stringSource inputs legal

structure Links (composed : Expressions.Calls) (scalar : DefaultScalarWrapper)
    (string : DefaultStringWrapper) : Prop where
  source : ∃ fullScalar fullString, FullLinks composed fullScalar fullString ∧
    scalar = (fun text context position facts => fullScalar text context position facts []) ∧
    string = (fun text context position facts => fullString text context position facts [])

theorem FullLinks.defaults {composed scalar string} (links : FullLinks composed scalar string) :
    Links composed (fun text context position facts => scalar text context position facts [])
      (fun text context position facts => string text context position facts []) :=
  ⟨⟨scalar, string, links, rfl, rfl⟩⟩

theorem linked_scalar {composed scalar string} (equations : Expressions.RawHelperEquations composed (domain := domain))
    (links : Links composed scalar string) (inputs : Inputs)
    (legal : Legal {inputs with initials := []}) :
    scalar inputs.text inputs.context inputs.position inputs.facts =
      readScalarInFlow inputs.text inputs.context.model inputs.position inputs.facts := by
  obtain ⟨fullScalar, fullString, full, observed, _⟩ := links.source
  rw [observed]
  exact linked_scalar_full equations full {inputs with initials := []} legal

theorem linked_string {composed scalar string} (equations : Expressions.RawHelperEquations composed (domain := domain))
    (links : Links composed scalar string) (inputs : Inputs)
    (legal : Legal {inputs with initials := []}) :
    string inputs.text inputs.context inputs.position inputs.facts =
      readStringInFlow inputs.text inputs.context.model inputs.position inputs.facts := by
  obtain ⟨fullScalar, fullString, full, _, observed⟩ := links.source
  rw [observed]
  exact linked_string_full equations full {inputs with initials := []} legal

end Silver.Predicate.FlowReaders
