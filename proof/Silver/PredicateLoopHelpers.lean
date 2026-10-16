module

public import Silver.PredicateLoopImports
public import Silver.PredicateNativeLibraries
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

/-- Callee identity and typed library-body interpretation. The inherited source
bridges establish helper meanings separately; no loop scanner equality appears
among these premises. Constants retain the checked native record values. -/
structure Links (imports : Imports) (inherited : Compose.Expressions.Calls)
    (scalars : ScalarExpression.Native.Calls) : Prop where
  token : ∀ text position token, token ∈ loopTokens →
    imports.token text position token = inherited.function .takeToken text position token
  skip : imports.skip = inherited.function .skip
  nameAfter : imports.nameAfter = inherited.function .nameAfter
  forbidden : imports.forbidden = inherited.primitive.forbidden
  nameIs : imports.nameIs = inherited.function .nameIs
  readScalar : ∀ text position names first after,
    imports.readScalar text position names first after = scalars.readExpression text position names first after true
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
    {scalars : ScalarExpression.Native.Calls}
    (source : Compose.Expressions.HelperEquations inherited)
    (lexical : Compose.Lexical.Meaning inherited.primitive)
    (scalarPrimitives : ScalarExpression.Native.Primitives scalars)
    (scalarEquations : ScalarExpression.Native.Equations scalars)
    (links : Links imports inherited scalars) : ImportsMeaning imports where
  token text position token valid := by
    rw [links.token text position token valid.2,
      Compose.Expressions.interpreted_take inherited source text valid.1.1 position token valid.1.2
        (loopToken_valid token valid.2)]
    exact loopToken_model text position token valid.2
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
  readScalar text position names first after valid := by
    rw [links.readScalar]
    exact ScalarExpression.Native.interpreted_readExpression scalars scalarPrimitives scalarEquations
      text valid.1.1 position names first after true valid.1.2 valid.2.1 valid.2.2
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

theorem model_links : Links modelImports Compose.Expressions.modelCalls ScalarExpression.Native.modelCalls where
  token text position token valid := (loopToken_model text position token valid).symm
  skip := rfl
  nameAfter := rfl
  forbidden := rfl
  nameIs := rfl
  readScalar _ _ _ _ _ := rfl
  append := rfl
  isEmpty := rfl
  normalize := rfl
  join left right := by
    rw [PathFacts.Native.joinBody_eval]
    exact (PathFacts.Native.join_model left right).symm
  emptyBounds := rfl
  emptyFacts := rfl

end Silver.Predicate.LoopNative
