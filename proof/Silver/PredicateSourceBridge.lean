module

public import Silver.PredicateSourceChecks
public import Silver.PredicateAdapterEnvironment
public import Silver.IntegerLiteralSourceBridge
public import Silver.LengthIntervalsSource
public import Silver.ScalarExpressionSourceBridge
public import Silver.ScalarEnvironmentSourceBridge
public import Silver.ScalarsNativeSourceBridge
public import Silver.PredicateEquations
public import Silver.ComposeModel

@[expose] public section

/-! Actual-source correspondence for the complete predicate statement scanner.
The source/frontend interpretation consists of checked typed equations, exact
callee wiring and native contracts, never scanner equality. Native functions are
partial on those contracts; BasicNative.totalize and BodyNative.totalize retain
every legal call and choose model values only outside the executable domain.
GNATprove establishes call legality using the source-checked preconditions,
postconditions and representation ranges. -/
namespace Silver.Predicate.SourceBridge
open Compose

structure CheckedSource : Prop where
  profile : SourceChecks.CheckedSource
  literals : IntegerLiteral.SourceBridge.CheckedSource
  scalarExpressions : ScalarExpression.SourceChecks.CheckedSource
  scalarEnvironments : ScalarExpression.EnvironmentSourceBridge.Checked Source.scalarExpressionSpecTokens
  bodyEnvironmentProjection : Adapter.Environment.Projection
  intervals : Integer.NativeSourceChecks.CheckedSource
  stringIntervals : LengthIntervals.SourceBridge.ActualSource
  stringBodies : LengthIntervals.SourceBridge.BodyInterpretation
  paths : PathFacts.SourceBridge.ActualSource
  pathBodies : PathFacts.SourceBridge.BodyInterpretation
  pathProjection : PathFacts.SourceBridge.ModelProjection

theorem checked_source : CheckedSource where
  profile := SourceChecks.actualSource
  literals := IntegerLiteral.SourceBridge.checked_source
  scalarExpressions := ScalarExpression.SourceChecks.checked_source
  scalarEnvironments := ScalarExpression.EnvironmentSourceBridge.actual_source_checked
  bodyEnvironmentProjection := Adapter.Environment.actual_source_projection.2
  intervals := Integer.NativeSourceChecks.checked_source
  stringIntervals := LengthIntervals.SourceBridge.actual_source
  stringBodies := LengthIntervals.SourceBridge.body_interpretation
  paths := PathFacts.SourceBridge.actual_source
  pathBodies := PathFacts.SourceBridge.actual_body_interpretation
  pathProjection := PathFacts.SourceBridge.actual_model_projection

structure InterpretedSource (calls : Implementation.Calls) : Prop where
  helpers : Compose.SourceBridge.InterpretedSource calls.outer.helpers
  definitions : Implementation.Definitions calls

theorem interpreted_helpers (calls : Implementation.Calls) (source : InterpretedSource calls) :
    Outer.HelperMeaning calls.outer where
  equations := Compose.SourceBridge.interpreted_equations calls.outer.helpers source.helpers
  step text valid form token state tokenValid stateValid :=
    Compose.SourceBridge.interpreted_step calls.outer.helpers source.helpers text valid form.helper token state
      (by cases form <;> simp [Form.helper, Compose.SourceBridge.NativeForm, Compose.SourceBridge.helperForms])
      tokenValid stateValid
  trivia text valid position positive bound :=
    (Compose.SourceBridge.interpreted_primitives calls.outer.helpers source.helpers).trivia
      text valid.1 valid.2 position positive bound

theorem interpreted_correspondence (calls : Implementation.Calls) (source : InterpretedSource calls)
    (text : Source) :
    calls.outer.member text = accepts text ∧ calls.outer.arguments text = hasArguments text ∧
      calls.outer.assignment text = hasAssignment text ∧ calls.outer.output text = hasOutput text :=
  Implementation.correspondence calls
    (Compose.SourceBridge.interpreted_equations calls.outer.helpers source.helpers) source.definitions
    (Compose.SourceBridge.interpreted_primitives calls.outer.helpers source.helpers)
    (interpreted_helpers calls source) text

/-- GNATprove establishes the exact public wrapper postconditions included in
SourceChecks. These are executable-to-source-function refinements. -/
structure ExecutableRefinement (calls : Implementation.Calls)
    (admit arguments assignment output : Source → Bool) : Prop where
  member : ∀ text, admit text = calls.outer.member text
  arguments : ∀ text, arguments text = calls.outer.arguments text
  assignment : ∀ text, assignment text = calls.outer.assignment text
  output : ∀ text, output text = calls.outer.output text

theorem executable_correspondence (calls : Implementation.Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output) (text : Source) :
    admit text = accepts text ∧ arguments text = hasArguments text ∧
      assignment text = hasAssignment text ∧ output text = hasOutput text := by
  obtain ⟨member, args, assigned, writes⟩ := interpreted_correspondence calls source text
  exact ⟨(refinement.member text).trans member, (refinement.arguments text).trans args,
    (refinement.assignment text).trans assigned, (refinement.output text).trans writes⟩

theorem actual_source_correspondence : CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text,
      calls.outer.member text = accepts text ∧ calls.outer.arguments text = hasArguments text ∧
      calls.outer.assignment text = hasAssignment text ∧ calls.outer.output text = hasOutput text :=
  ⟨checked_source, interpreted_correspondence⟩

/-- No extra assumptions are needed to inhabit the complete interpretation,
including its literal, path, predicate, basic, recursive-body and outer calls. -/
theorem model_interpreted : InterpretedSource Implementation.modelCalls where
  helpers := Compose.SourceBridge.model_interpreted
  definitions := Implementation.model_definitions

theorem model_executable :
    ExecutableRefinement Implementation.modelCalls accepts hasArguments hasAssignment hasOutput where
  member _ := rfl
  arguments _ := rfl
  assignment _ := rfl
  output _ := rfl

end Silver.Predicate.SourceBridge
