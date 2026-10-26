module

public import Silver.PredicateLoopImports
public import Silver.PredicateNativeLibraries
public import Silver.PredicateFlowReaderLibraries
public import Silver.PredicateAdapterEnvironment
public import Silver.PredicateBodyWrappers
public import Silver.ComposeModelCalls
public import Silver.ComposeLexical
public import Silver.ScalarExpressionNativeEquations

@[expose] public section
namespace Silver.Predicate.LoopNative
open Compose

attribute [local irreducible] ScalarExpression.read

theorem loopToken_valid (token : ShellToken) (valid : token ∈ loopTokens) : Compose.Expressions.ValidToken token := by
  simp only [loopTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem loopToken_model (text : Source) (position : Nat) (token : ShellToken)
    (valid : token ∈ loopTokens) :
    fixedAfter text position (Compose.Expressions.spelling token) (Compose.Expressions.isWord token) = tokenAfter text position token := by
  simp only [loopTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

theorem loopToken_fixed (token : ShellToken) (valid : token ∈ loopTokens) : Adapter.FixedToken token := by
  simp only [loopTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Adapter.FixedToken, ShellToken.word, ShellToken.symbol]

theorem loop_token_calls_fixed :
    ∀ token ∈ .word "for" :: commands.tokenCalls, Adapter.FixedToken token :=
  fun token present => loopToken_fixed token (loop_tokens_complete token present)

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
  readScalar : ∃ reading,
    FlowSourceBridge.InterpretedReadingNames reading ∧
    FlowReaders.ScalarRefinement (FlowReaders.inheritedCalls reading inherited scalars) imports.readScalar
  widen : ∃ operation, FlowSourceBridge.InterpretedWidenInto operation ∧
    ∀ context facts, WidenDomain context facts →
      imports.widen context facts =
        (operation (FlowReaders.storageContext context) (FlowSourceBridge.ofFlow facts)).active
  append : imports.append = inherited.function .scalarAppend
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
    (source : Compose.Expressions.HelperEquations inherited (domain := domain))
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
  readScalar text context position facts first after valid := by
    obtain ⟨reading, readingSource, wrapperSource⟩ := links.readScalar
    exact FlowReaders.scalar_meaning
      (FlowReaders.inherited_meaning readingSource source scalarPrimitives scalarEquations) wrapperSource
      ⟨text, context, position, facts, first, after⟩
      ⟨valid.1.1, valid.1.2.1, valid.1.2.2, valid.2.1⟩ valid.2.2
  widen context facts valid := by
    obtain ⟨operation, operationSource, observed⟩ := links.widen
    rw [observed context facts valid]
    simpa only [FlowReaders.storageContext, FlowSourceBridge.ofNames_active,
      FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_widenInto operation operationSource
        (FlowReaders.storageContext context) (FlowSourceBridge.ofFlow facts) valid.2 valid.1
  append names item space := by
    rw [links.append]
    exact source.scalarAppend names item space
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
    (source : Compose.Expressions.HelperEquations Compose.Expressions.modelCalls (domain := domain)) :
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
  readScalar := by
    refine ⟨FlowSourceBridge.readingStorage, FlowSourceBridge.model_reading_interpreted, ⟨?_⟩⟩
    intro inputs legal _mask
    simp only [FlowReaders.scalarRhs, FlowReaders.Expr.eval, FlowReaders.inheritedCalls,
      ScalarExpression.Native.modelCalls,
      FlowReaders.overlay_meaning FlowSourceBridge.model_reading_interpreted legal.2.1 legal.2.2.1] <;> rfl
  widen := by
    refine ⟨FlowSourceBridge.widenedStorage, FlowSourceBridge.model_widen_interpreted, ?_⟩
    intro context facts valid
    symm
    simpa only [modelImports, FlowReaders.storageContext, FlowSourceBridge.ofNames_active,
      FlowSourceBridge.ofFlow_active] using
      FlowSourceBridge.interpreted_widenInto FlowSourceBridge.widenedStorage
        FlowSourceBridge.model_widen_interpreted (FlowReaders.storageContext context)
        (FlowSourceBridge.ofFlow facts) valid.2 valid.1
  append := rfl
  isEmpty := rfl
  normalize := rfl
  join left right := by
    rw [PathFacts.Native.joinBody_eval]
    exact (PathFacts.Native.join_model left right).symm
  emptyBounds := rfl
  emptyFacts := rfl

end Silver.Predicate.LoopNative
