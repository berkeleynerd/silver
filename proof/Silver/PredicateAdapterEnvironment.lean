module

public import Silver.PredicateAdapter
public import Silver.ScalarEnvironmentSourceBridge

@[expose] public section

/-! Justify the adapter's Body_Environment import from the checked native
postcondition. The native array operation remains arbitrary: GNATprove supplies
its Count/Items contract, and the evaluator's active-prefix meaning is derived. -/
namespace Silver.Predicate.Adapter.Environment
open ScalarExpression
open ScalarExpression.EnvironmentSourceBridge

/-- Every legal native storage represented by an adapter expression gives the
same result as that expression's Body_Environment call. Unused array cells do
not enter the language environment. -/
theorem expression_projection (transform : Storage → Storage)
    (verified : InterpretedBodyEnvironment transform) (storage : Storage)
    (bounded : storage.count ≤ ScalarExpression.maxBindings)
    (calls : BodyNative.Calls) (frame : Adapter.Frame)
    (names : Adapter.Expr ScalarExpression.Environment)
    (represented : names.eval calls frame = storage.active) :
    (Adapter.Expr.bodyEnvironment names).eval calls frame = (transform storage).active := by
  change ScalarExpression.bodyEnvironment (names.eval calls frame) = _
  rw [represented]
  exact (interpreted_bodyEnvironment transform verified storage bounded).symm

/-- The actual Context_Of expression uses that imported operation on the
ordered declaration environment before body admission begins. -/
theorem context_projection (transform : Storage → Storage)
    (verified : InterpretedBodyEnvironment transform) (storage : Storage)
    (bounded : storage.count ≤ ScalarExpression.maxBindings)
    (calls : BodyNative.Calls) (frame : Adapter.Frame)
    (represented : frame.scan.state.scalarNames = storage.active) :
    (Adapter.contextExpr.eval calls frame).scalarNames = (transform storage).active :=
  expression_projection transform verified storage bounded calls frame
    (.field .stateScalarNames (.field .scanState .scan)) represented

/-- Both the imported expression and its actual context-construction site are
connected to the native postcondition, rather than assigning an unproved model
meaning to the callee. -/
structure Projection : Prop where
  expression : ∀ transform, InterpretedBodyEnvironment transform → ∀ storage,
    storage.count ≤ ScalarExpression.maxBindings → ∀ calls frame names,
    names.eval calls frame = storage.active →
    (Adapter.Expr.bodyEnvironment names).eval calls frame = (transform storage).active
  context : ∀ transform, InterpretedBodyEnvironment transform → ∀ storage,
    storage.count ≤ ScalarExpression.maxBindings → ∀ calls frame,
    frame.scan.state.scalarNames = storage.active →
    (Adapter.contextExpr.eval calls frame).scalarNames = (transform storage).active

theorem actual_source_projection :
    EnvironmentSourceBridge.Checked Source.scalarExpressionSpecTokens ∧ Projection :=
  ⟨EnvironmentSourceBridge.actual_source_checked, ⟨expression_projection, context_projection⟩⟩

end Silver.Predicate.Adapter.Environment
