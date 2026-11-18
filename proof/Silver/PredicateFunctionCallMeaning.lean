module

public import Silver.PredicateFunctionCallReadings
public import Silver.PredicateConditionValidity
public import Silver.PredicateFlowInvariant
public import Silver.ScalarFunctionDefinition

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

private theorem checkActuals_entries {context : ParseContext} {facts : ActiveFlow}
    {catalog : FunctionBindings.Metadata} {entries : List (ScalarAssociations.Entry ScalarFunctions.Actual)}
    {first count : Nat}
    (keys : entries.map Prod.fst = List.range' first count)
    (checked : ∀ entry ∈ entries,
      entry.2.check context.names.shape context.analysis (context.flow facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (formalType (FunctionBindings.parameter catalog entry.1)) = true) :
    ScalarFunctions.checkActuals context.names.shape context.analysis (context.flow facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (formalTypes catalog first count) (entries.map Prod.snd) = true := by
  induction count generalizing first entries with
  | zero =>
      have empty : entries = [] := List.map_eq_nil_iff.mp keys
      subst entries
      rfl
  | succ count ih =>
      cases entries with
      | nil => simp at keys
      | cons entry entries =>
          have parts : entry.1 = first ∧ entries.map Prod.fst = List.range' (first + 1) count := by
            simpa only [List.map_cons, List.range'_succ, List.cons.injEq] using keys
          have head := checked entry (List.mem_cons_self ..)
          rw [parts.1] at head
          have tail := ih parts.2 (fun item member => checked item (List.mem_cons_of_mem _ member))
          simp only [formalTypes, List.map_cons, ScalarFunctions.checkActuals, head, tail, Bool.and_self]

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
  cases parsed with
  | actuals source =>
      have entryMeaning := source.forall_payloads (fun _ _ _ _ payload =>
        actual_meaning normal nv base arraysReady compatible bounded payload)
      have arranged := ScalarAssociations.arrange_all defaultFunctionActual source.fresh.nodup source.complete entryMeaning
      refine ⟨?_, checkActuals_entries (ScalarAssociations.arrange_keys ..) (fun entry member => (arranged entry member).2)⟩
      intro actual present
      obtain ⟨entry, member, same⟩ := List.mem_map.mp present
      subst actual
      exact (arranged entry member).1

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

/-- A function body or initializer has no String, array, or input namespace.
Purity alone is insufficient to rule out all non-scalar source operands. -/
structure ClosedFunctionContext (context : ParseContext) : Prop where
  pure : context.pure = true
  noArguments : context.hasArguments = false
  noNames : context.names = []
  noArrays : context.arrayNames = []

theorem scalarExpression_of_readsOnly {expression : Integer.Expr} {allowed : Nat → Prop}
    (reads : expression.ReadsOnly allowed) : ScalarFunctions.scalarExpression expression = true := by
  induction expression <;> simp_all [Integer.Expr.ReadsOnly, ScalarFunctions.scalarExpression]

theorem scalarExpression_source_scalar {text names position expression result maskFirst maskAfter allowSign initials elaborating}
    (parsed : ScalarExpression.At text names position expression result maskFirst maskAfter allowSign
      [] initials elaborating) : ScalarFunctions.scalarExpression expression = true :=
  scalarExpression_of_readsOnly (ScalarExpression.syntax_readsOnly parsed.grammar)

mutual
  theorem primary_source_scalar {text context position facts condition result initials}
      (closed : ClosedFunctionContext context)
      (parsed : PrimaryAt text context position facts condition result initials) :
      ScalarFunctions.scalarCondition condition = true := by
    cases parsed with
    | group _ _ _ inner _ =>
        have scalar := condition_source_scalar closed inner
        exact scalar
    | boolean _ _ _ _ _ atom => cases atom <;> rfl
    | valid _ _ _ _ arguments _ => simp [closed.noArguments] at arguments
    | booleanArray _ _ _ _ atom =>
        cases atom with
        | read found _ _ _ _ _ _ _ =>
            simp [closed.noArrays, ArrayBindings.lookup, ArrayBindings.lookupFrom] at found
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem booleanFactor_source_scalar {text context position facts condition result initials}
      (closed : ClosedFunctionContext context)
      (parsed : BooleanFactorAt text context position facts condition result initials) :
      ScalarFunctions.scalarCondition condition = true := by
    cases parsed with
    | primary _ inner | negated _ _ inner =>
        have scalar := primary_source_scalar closed inner
        exact scalar
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem booleanRelation_source_scalar {text context position facts condition result initials}
      (closed : ClosedFunctionContext context)
      (parsed : BooleanRelationAt text context position facts condition result initials) :
      ScalarFunctions.scalarCondition condition = true := by
    cases parsed with
    | factor inner _ _ => exact booleanFactor_source_scalar closed inner
    | comparison left _ _ _ _ right _ =>
        exact Bool.and_eq_true_iff.mpr ⟨booleanFactor_source_scalar closed left,
          booleanFactor_source_scalar closed right⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem relation_source_scalar {text context position facts condition result initials}
      (closed : ClosedFunctionContext context)
      (parsed : RelationAt text context position facts condition result initials) :
      ScalarFunctions.scalarCondition condition = true := by
    cases parsed with
    | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner =>
        exact booleanRelation_source_scalar closed inner
    | length _ _ _ left _ _ =>
        cases left with
        | binding _ _ found _ _ _ _ _ =>
            simp [closed.noNames, BindingEnvironment.get] at found
    | scalars _ _ _ _ left right _ =>
        rw [closed.noArrays] at left right
        exact Bool.and_eq_true_iff.mpr ⟨scalarExpression_source_scalar left,
          scalarExpression_source_scalar right⟩
    | strings _ _ _ _ _ _ _ _ impure | character _ _ _ _ _ _ impure
    | primary _ _ _ _ _ _ _ impure => simp [closed.pure] at impure
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_source_scalar {text context condition result chained final finalResult facts initials originalStart}
      (closed : ClosedFunctionContext context)
      (parsed : ChainAt text context condition result chained final finalResult facts initials originalStart)
      (scalar : ScalarFunctions.scalarCondition condition = true) :
      ScalarFunctions.scalarCondition final = true := by
    cases parsed with
    | done => exact scalar
    | @next _ _ condition result chained operator right rightResult final finalResult _ _ _ _ _ _ _ rightRead _ _ _ rest =>
        apply chain_source_scalar closed rest
        have rightScalar := relation_source_scalar closed rightRead
        cases operator <;> exact Bool.and_eq_true_iff.mpr ⟨scalar, rightScalar⟩
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_source_scalar {text context position facts condition result initials}
      (closed : ClosedFunctionContext context)
      (parsed : ConditionAt text context position facts condition result initials) :
      ScalarFunctions.scalarCondition condition = true := by
    cases parsed with
    | condition _ first _ _ tail =>
        exact chain_source_scalar closed tail (relation_source_scalar closed first)
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

theorem actual_source_scalar {text context position facts formal actual after}
    (closed : ClosedFunctionContext context)
    (parsed : ActualAt text context position facts formal actual after) :
    ScalarFunctions.scalarActual actual = true := by
  cases parsed.payload with
  | integer _ source _ _ =>
      rw [closed.noArrays] at source
      exact scalarExpression_source_scalar source
  | boolean _ source => exact condition_source_scalar closed source

theorem actuals_source_scalar {text context facts catalog position first last actuals after}
    (closed : ClosedFunctionContext context)
    (parsed : ActualsAt text context facts catalog position first last actuals after) :
    actuals.all ScalarFunctions.scalarActual = true := by
  cases parsed with
  | actuals source =>
      have original := source.forall_payloads (fun _ _ _ _ payload => actual_source_scalar closed payload)
      have arranged := ScalarAssociations.arrange_all defaultFunctionActual source.fresh.nodup source.complete original
      apply List.all_eq_true.mpr
      intro actual present
      obtain ⟨entry, member, same⟩ := List.mem_map.mp present
      subst actual
      exact arranged entry member

end Silver.Predicate
