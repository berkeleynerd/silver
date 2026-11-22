module

public import Silver.PredicateLoopImports
public import Silver.PredicateNativeLibraries
public import Silver.PredicateFlowReaderLibraries
public import Silver.PredicateAdapterEnvironment
public import Silver.PredicateBodyWrappers
public import Silver.ComposeModelCalls
public import Silver.ComposeLexical
public import Silver.ScalarExpressionNativeEquations
public import Silver.PredicateArrayBodySource
public import Silver.PredicateCountedBoundSource

@[expose] public section
namespace Silver.Predicate.LoopNative
open Compose

attribute [local irreducible] ScalarExpression.read

theorem loopToken_valid (token : ShellToken) (valid : token ∈ loopTokens) : Compose.Expressions.ValidToken token := by
  simp only [loopTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem loopToken_model (text : Source) (position : Nat) (token : ShellToken)
    (valid : token ∈ loopTokens) :
    fixedAfter text position (Compose.Expressions.spelling token) (Compose.Expressions.isWord token) = tokenAfter text position token := by
  simp only [loopTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

theorem loopToken_fixed (token : ShellToken) (valid : token ∈ loopTokens) : Adapter.FixedToken token := by
  simp only [loopTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Adapter.FixedToken, ShellToken.word, ShellToken.symbol]

theorem loop_token_calls_fixed :
    ∀ token ∈ .word "for" :: commands.tokenCalls, Adapter.FixedToken token :=
  fun token present => loopToken_fixed token (loop_tokens_complete token present)

def countedGate (scalars : ScalarExpression.Native.Calls) : CountedBoundNative.Gate :=
  fun text position names first after arrays elaborating =>
    scalars.readExpression text position names first after true arrays [] elaborating .mutableElements

theorem countedGate_meaning (scalars : ScalarExpression.Native.Calls)
    (primitives : ScalarExpression.Native.Primitives scalars)
    (equations : ScalarExpression.Native.Equations scalars) :
    CountedBoundNative.GateMeaning (countedGate scalars) := by
  intro text valid position names first after arrays elaborating bound environment mask table
  exact ScalarExpression.Native.interpreted_readExpression_table scalars primitives equations
    text valid position names first after true arrays [] elaborating .mutableElements
    bound environment mask table (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])

/-- Callee identity and typed library-body interpretation. The inherited source
bridges establish helper meanings separately; no loop scanner equality appears
among these premises. Constants retain the checked native record values. -/
structure Links (imports : Imports) (inherited : Compose.Expressions.Calls)
    (scalars : ScalarExpression.Native.Calls) : Prop where
  token : ∀ text position token, token ∈ loopTokens →
    imports.token text position token = inherited.function .takeToken text position token
  bodyToken : ∃ models wrappers body,
    Adapter.Wrappers.ModelEquations models body (takeTokenCall := inherited.function .takeToken) ∧
    Adapter.Wrappers.Refinement models wrappers ∧
    imports.bodyToken = wrappers.token
  invalid : ∃ calls, BodyWrappers.DefinitionEquations calls ∧ imports.invalid = calls.invalid
  skip : imports.skip = inherited.function .skip
  nameAfter : imports.nameAfter = inherited.function .nameAfter
  forbidden : imports.forbidden = inherited.primitive.forbidden
  nameIs : imports.nameIs = inherited.function .nameIs
  equalName : imports.equalName = inherited.primitive.equal
  arrayTarget : ∃ scalar string calls,
    FlowReaders.Links inherited scalar string ∧ ArrayBodyNative.Links inherited scalar calls ∧
    imports.arrayTarget = calls.target
  readScalar : ∃ reading wrapper booleans,
    FlowSourceBridge.InterpretedReadingNames reading ∧
    FlowReaders.ScalarRefinement
      (FlowReaders.inheritedCalls reading inherited scalars booleans) wrapper ∧
    CountedBoundNative.Refinement
      (FlowReaders.inheritedCalls reading inherited scalars booleans) (countedGate scalars) wrapper imports.readScalar
  readRange : ∀ text context position first after,
    imports.readRange text context position first after =
      scalars.readArrayAttribute text position context.scalarNames context.arrayTable first after true
  widen : ∃ operation, FlowSourceBridge.InterpretedWidenInto operation ∧
    ∀ context facts, WidenDomain context facts →
      imports.widen context facts =
        (operation (FlowReaders.storageContext context) (FlowSourceBridge.ofFlow facts)).active
  isEmpty : imports.isEmpty = inherited.function .scalarEmpty
  normalize : imports.normalize = scalars.scalars.normalize
  join : ∀ left right : PathFacts.Native.Context,
    imports.join left.model right.model =
      (PathFacts.Native.joinBody.eval
        ({leftFacts := left, rightFacts := right} : Native.Libraries.PathInputs).locals).model
  emptyBounds : imports.emptyBounds = ⟨1, 0⟩
  emptyFacts : imports.emptyFacts = PathFacts.Native.empty.model

theorem ImportsMeaning.of_inherited {imports : Imports} {inherited : Compose.Expressions.Calls}
    {scalars : ScalarExpression.Native.Calls} {domain : Compose.Expressions.StateDomain}
    (source : Compose.Expressions.RawHelperEquations inherited (domain := domain))
    (lexical : Compose.Lexical.Meaning inherited.primitive)
    (scalarPrimitives : ScalarExpression.Native.Primitives scalars)
    (scalarEquations : ScalarExpression.Native.Equations scalars)
    (links : Links imports inherited scalars) : ImportsMeaning imports where
  token text position token valid := by
    rw [links.token text position token valid.2,
      Compose.Expressions.interpreted_take inherited source text valid.1.1 position token valid.1.2
        (loopToken_valid token valid.2)]
    exact loopToken_model text position token valid.2
  bodyToken text context scan token valid := by
    obtain ⟨models, wrappers, body, definitions, refinement, observed⟩ := links.bodyToken
    rw [observed]
    exact Adapter.Wrappers.token_interpreted (Adapter.Wrappers.normalize_tokens source definitions)
      refinement text context scan token
      ⟨valid.1.1, valid.1.2.1, valid.1.2.2, loopToken_valid token valid.2⟩ (loopToken_fixed token valid.2)
  invalid scan capacity := by
    obtain ⟨calls, definitions, observed⟩ := links.invalid
    rw [observed]
    exact BodyWrappers.invalid_meaning definitions scan capacity
  skip text position valid := by
    rw [links.skip]
    exact Compose.Expressions.interpreted_skip inherited source text valid.1 position valid.2
  nameAfter text position valid := by
    rw [links.nameAfter]
    exact Compose.Expressions.interpreted_name inherited source text valid.1 position valid.2
  forbidden text first after valid := by
    rw [links.forbidden]
    exact lexical.forbidden text valid.1.1 valid.1.2 first after valid.2.1 valid.2.2.1 valid.2.2.2
  nameIs text first after word valid := by
    rw [links.nameIs]
    exact source.nameIs text valid.1.1 first after word valid.1.2 valid.2.1 valid.2.2
  equalName text first after otherFirst otherAfter valid := by
    rw [links.equalName]
    exact lexical.equal text valid.1.1.1 valid.1.1.2 first after otherFirst otherAfter
      valid.1.2.1 valid.1.2.2.1 valid.1.2.2.2 valid.2.1 valid.2.2.1 valid.2.2.2
  arrayTarget text context position valid := by
    obtain ⟨scalar, string, calls, flow, arrays, observed⟩ := links.arrayTarget
    rw [observed]
    exact ArrayBodyNative.linked_target source flow arrays text context position valid
  readScalar text context position facts first after valid := by
    obtain ⟨reading, wrapper, booleans, readingSource, wrapperSource, countedSource⟩ := links.readScalar
    exact CountedBoundNative.wrapper_meaning
      (FlowReaders.inherited_meaning booleans readingSource source scalarPrimitives scalarEquations)
      (countedGate_meaning scalars scalarPrimitives scalarEquations) wrapperSource countedSource
      ⟨text, context, position, facts, first, after, []⟩
      ⟨valid.1.1, valid.1.2.1, valid.1.2.2, valid.2.1,
        by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements]⟩ valid.2.2
  readRange text context position first after valid := by
    rw [links.readRange]
    exact ScalarExpression.Native.interpreted_arrayAttribute scalars scalarPrimitives scalarEquations
      text valid.1 position context.scalarNames context.arrayTable first after true
      valid.2.2.1 valid.2.1.2.2.1 valid.2.2.2 valid.2.1.arrays
  widen context facts valid := by
    obtain ⟨operation, operationSource, observed⟩ := links.widen
    rw [observed context facts valid]
    simpa only [FlowReaders.storageContext, FlowSourceBridge.ofNames_active,
      FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_widenInto operation operationSource
        (FlowReaders.storageContext context) (FlowSourceBridge.ofFlow facts) valid.2 valid.1
  isEmpty value bounded := by
    rw [links.isEmpty]
    exact source.scalarEmpty value bounded
  normalize value bounded := by
    rw [links.normalize]
    exact scalarPrimitives.normalize value bounded
  join left right := by
    have equation := links.join (Native.Libraries.reify left) (Native.Libraries.reify right)
    simpa only [PathFacts.Native.joinBody_eval, Native.Libraries.PathInputs.locals,
      PathFacts.Native.join_model, Native.Libraries.reify_model] using equation
  emptyBounds := links.emptyBounds
  emptyFacts := links.emptyFacts

theorem model_links {domain : Compose.Expressions.StateDomain}
    (source : Compose.Expressions.RawHelperEquations Compose.Expressions.modelCalls (domain := domain)) :
    Links {modelImports with bodyToken := (Adapter.Wrappers.modelCalls BodyNative.modelCalls).token}
      Compose.Expressions.modelCalls ScalarExpression.Native.modelCalls where
  token text position token valid := (loopToken_model text position token valid).symm
  bodyToken := ⟨Adapter.Wrappers.modelCalls BodyNative.modelCalls,
    Adapter.Wrappers.modelCalls BodyNative.modelCalls, BodyNative.modelCalls,
    Adapter.Wrappers.model_raw_equations source BodyNative.modelCalls,
    Adapter.Wrappers.model_refinement _, rfl⟩
  invalid := ⟨BodyWrappers.modelCalls, BodyWrappers.model_definitions, rfl⟩
  skip := rfl
  nameAfter := rfl
  forbidden := rfl
  nameIs := rfl
  equalName := rfl
  arrayTarget := by
    have flow := Native.Libraries.model_links.readers.defaults
    exact ⟨(fun t c p f => Native.modelCalls.scalarInFlow t c p f []),
      (fun t c p f => Native.modelCalls.stringInFlow t c p f []), ArrayBodyNative.modelCalls,
      flow, ArrayBodyNative.model_links source flow, rfl⟩
  readScalar := by
    let calls := FlowReaders.inheritedCalls FlowSourceBridge.readingStorage
      Compose.Expressions.modelCalls ScalarExpression.Native.modelCalls BooleanBindings.SourceBridge.modelSource
    refine ⟨FlowSourceBridge.readingStorage, FlowReaders.modelScalar calls, BooleanBindings.SourceBridge.modelSource,
      FlowSourceBridge.model_reading_interpreted, FlowReaders.model_scalar_refinement calls, ?_⟩
    constructor
    intro inputs legal mask
    exact (CountedBoundNative.eval_meaning
      (FlowReaders.inherited_meaning BooleanBindings.SourceBridge.modelSource
        FlowSourceBridge.model_reading_interpreted source ScalarExpression.Native.model_primitives
        ScalarExpression.Native.model_equations)
      (countedGate_meaning ScalarExpression.Native.modelCalls ScalarExpression.Native.model_primitives
        ScalarExpression.Native.model_equations)
      (FlowReaders.model_scalar_refinement calls) inputs legal mask).symm
  readRange _ _ _ _ _ := rfl
  widen := by
    refine ⟨FlowSourceBridge.widenedStorage, FlowSourceBridge.model_widen_interpreted, ?_⟩
    intro context facts valid
    symm
    simpa only [modelImports, FlowReaders.storageContext, FlowSourceBridge.ofNames_active,
      FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_widenInto FlowSourceBridge.widenedStorage
        FlowSourceBridge.model_widen_interpreted (FlowReaders.storageContext context)
        (FlowSourceBridge.ofFlow facts) valid.2 valid.1
  isEmpty := rfl
  normalize := rfl
  join left right := by
    rw [PathFacts.Native.joinBody_eval]
    exact (PathFacts.Native.join_model left right).symm
  emptyBounds := rfl
  emptyFacts := rfl

end Silver.Predicate.LoopNative
