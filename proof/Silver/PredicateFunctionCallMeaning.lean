module

public import Silver.PredicateFunctionCallReadings
public import Silver.PredicateConditionValidity
public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

/-- The same incoming flow checks every actual. A Boolean actual's branch facts
are local to that expression and do not constrain subsequent actuals. -/
theorem actual_meaning {text context position facts formal actual after}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (arraysReady : context.ArraysReady text)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (bounded : facts.path.Bounded)
    (parsed : ActualAt text context position facts formal actual after) :
    actual.Readable context.hasArguments context.names.shape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
    actual.check context.names.shape context.analysis (context.flow facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (formalType formal) = true := by
  cases parsed.payload with
  | integer kind source nonempty included =>
      have inferred := source.inferred
      rw [context.reading_ranges compatible] at inferred
      simp only [ScalarFunctions.Actual.Readable, ScalarFunctions.Actual.check,
        formalType, kind, inferred, nonempty, included, Bool.not_false, Bool.and_self, and_self]
  | boolean kind source =>
      have meaning := condition_valid normal nv base arraysReady compatible bounded source
      exact ⟨⟨meaning.grammatical, meaning.readable⟩,
        by simpa only [formalType, kind, ScalarFunctions.Actual.check] using meaning.checked⟩

theorem actuals_meaning {text context facts catalog position first last actuals after}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (arraysReady : context.ArraysReady text)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (bounded : facts.path.Bounded)
    (parsed : ActualsAt text context facts catalog position first last actuals after) :
    (∀ actual ∈ actuals, actual.Readable context.hasArguments context.names.shape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))) ∧
    ScalarFunctions.checkActuals context.names.shape context.analysis (context.flow facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (formalTypes catalog first (last - first + 1)) actuals = true := by
  induction parsed with
  | last source _ =>
      have meaning := actual_meaning normal nv base arraysReady compatible bounded source
      simp only [List.mem_singleton, forall_eq, Nat.sub_self, formalTypes,
        ScalarFunctions.checkActuals, meaning.2, Bool.and_self, and_true]
      exact meaning.1
  | @next position first last actual after rest result within source following ih =>
      have meaning := actual_meaning normal nv base arraysReady compatible bounded source
      have remaining : last - first = last - (first + 1) + 1 := by omega
      refine ⟨?_, ?_⟩
      · intro value present
        rcases List.mem_cons.mp present with same | tail
        · simpa only [same] using meaning.1
        · exact ih.1 value tail
      · simp only [formalTypes, ScalarFunctions.checkActuals, meaning.2, Bool.true_and]
        rw [remaining]
        exact ih.2

theorem call_meaning {text context position facts catalog call result}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (arraysReady : context.ArraysReady text)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (bounded : facts.path.Bounded)
    (valid : FunctionBindings.ValidMetadata text catalog)
    (parsed : CallAt text context position facts catalog call result) :
    call.Readable context.hasArguments context.names.shape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
    call.check (catalogSignatures catalog) context.names.shape context.analysis (context.flow facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) =
      some (resultType (FunctionBindings.signature catalog call.callee)) := by
  have inside : call.callee ≤ catalog.items.length := by
    rw [parsed.callee]
    exact calleeAt_bound ..
  have positive : 0 < call.callee := Nat.pos_of_ne_zero parsed.positive
  have signatureValid := valid.2.2.2 _ (FunctionBindings.signature_mem positive inside)
  have count : (FunctionBindings.signature catalog call.callee).formalFirst +
      (FunctionBindings.signature catalog call.callee).count - 1 -
        (FunctionBindings.signature catalog call.callee).formalFirst + 1 =
      (FunctionBindings.signature catalog call.callee).count := by
    have nonempty := signatureValid.2.1
    omega
  have arguments := actuals_meaning normal nv base arraysReady compatible bounded parsed.actuals
  rw [count] at arguments
  refine ⟨arguments.1, ?_⟩
  simp only [ScalarFunctions.Call.check, catalogSignatures_lookup positive inside,
    Option.bind_some, signatureModel, arguments.2, ↓reduceIte]

end Silver.Predicate
