module

public import Silver.PredicateBasicEquations
public import Silver.PredicateNativeLibraries

@[expose] public section
namespace Silver.Predicate.BasicNative
open Compose Bindings

/-- Exactly the literal token arguments occurring in the typed Basic_Body.
The native finite Token_Kind representation excludes arbitrary spellings. -/
def basicTokens : List ShellToken :=
  [.word "null", .word "silver_io", .symbol ".", .word "put_line", .symbol "(",
   .symbol ")", .word "silver_arguments", .word "reject", .symbol ":=", .symbol ";"]

def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position ∧ token ∈ basicTokens

def ExpressionDomain (text : Source) (position : Nat) (names : Compose.BindingEnvironment) (scalarNames : ScalarExpression.Environment) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position ∧ Expressions.ValidNames text names ∧
    ScalarExpression.ValidEnvironment text scalarNames

def TargetDomain (text : Source) (state : ParserState) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidState text state

/-- Pointwise meanings on the checked native call domains. The path operations
already have unconditional scalar projections in PathFactsSourceBridge and
sameLength_project; no out-of-domain Compose helper equality is assumed. -/
structure HelperMeaning (primitive : Primitives) : Prop where
  callAfter : ∀ text names position operation scalarNames, ExpressionDomain text position names scalarNames →
    primitive.callAfter text names position operation scalarNames = Compose.callAfter text names position operation scalarNames
  associationAfter : ∀ text position formal, Expressions.ValidText text → Expressions.ValidCursor text position →
    primitive.associationAfter text position formal = Names.associationAfter text position formal
  token : ∀ text position token, TokenDomain text position token →
    primitive.token text position token = tokenAfter text position token
  expression : ∀ text position names scalarNames, ExpressionDomain text position names scalarNames →
    primitive.expression text position names scalarNames = expressionAt text position names scalarNames
  target : ∀ text state sameTarget, TargetDomain text state →
    primitive.target text state sameTarget = targetAt text state sameTarget
  fits : ∀ facts summary, primitive.fits facts summary = fitsSummary facts summary
  sameLength : ∀ facts left right, primitive.sameLength facts left right = equalSummary facts left right
  reject : ∀ facts, primitive.reject facts = facts.reject

/-- Formal total-function extension, not an executable check or replacement.
Exact native contracts and GNATprove establish legality of executed calls; the
typed source equations use this extension. All legal call values are retained. -/
noncomputable def totalize (primitive : Primitives) : Primitives := by
  classical
  exact {
    callAfter := fun text names position operation scalarNames => if ExpressionDomain text position names scalarNames then
      primitive.callAfter text names position operation scalarNames else Compose.callAfter text names position operation scalarNames
    associationAfter := fun text position formal => if Expressions.ValidText text ∧ Expressions.ValidCursor text position then
      primitive.associationAfter text position formal else Names.associationAfter text position formal
    token := fun text position token => if TokenDomain text position token then
      primitive.token text position token else tokenAfter text position token
    expression := fun text position names scalarNames => if ExpressionDomain text position names scalarNames then
      primitive.expression text position names scalarNames else expressionAt text position names scalarNames
    target := fun text state sameTarget => if TargetDomain text state then
      primitive.target text state sameTarget else targetAt text state sameTarget
    fits := primitive.fits
    sameLength := primitive.sameLength
    reject := primitive.reject }

theorem totalize_callAfter (primitive : Primitives) (text : Source) (names : Compose.BindingEnvironment)
    (position : Nat) (operation : Names.Operation) (scalarNames : ScalarExpression.Environment) (valid : ExpressionDomain text position names scalarNames) :
    (totalize primitive).callAfter text names position operation scalarNames = primitive.callAfter text names position operation scalarNames := by
  simp only [totalize, valid, ↓reduceIte]

theorem totalize_associationAfter (primitive : Primitives) (text : Source) (position : Nat) (formal : Bool)
    (valid : Expressions.ValidText text ∧ Expressions.ValidCursor text position) :
    (totalize primitive).associationAfter text position formal = primitive.associationAfter text position formal := by
  simp only [totalize, valid, and_self, ↓reduceIte]

theorem totalize_token (primitive : Primitives) (text : Source) (position : Nat) (token : ShellToken)
    (valid : TokenDomain text position token) :
    (totalize primitive).token text position token = primitive.token text position token := by
  simp only [totalize, valid, ↓reduceIte]

theorem totalize_expression (primitive : Primitives) (text : Source) (position : Nat) (names : Compose.BindingEnvironment) (scalarNames : ScalarExpression.Environment)
    (valid : ExpressionDomain text position names scalarNames) :
    (totalize primitive).expression text position names scalarNames = primitive.expression text position names scalarNames := by
  simp only [totalize, valid, ↓reduceIte]

theorem totalize_target (primitive : Primitives) (text : Source) (state : ParserState) (sameTarget : Bool)
    (valid : TargetDomain text state) :
    (totalize primitive).target text state sameTarget = primitive.target text state sameTarget := by
  simp only [totalize, valid, ↓reduceIte]

theorem totalize_equations {primitive : Primitives} (meaning : HelperMeaning primitive) :
    PrimitiveEquations (totalize primitive) where
  callAfter := by
    funext text names position operation scalarNames
    dsimp only [totalize]
    split
    · exact meaning.callAfter text names position operation scalarNames ‹_›
    · rfl
  associationAfter := by
    funext text position formal
    dsimp only [totalize]
    split
    · exact meaning.associationAfter text position formal (And.left ‹_›) (And.right ‹_›)
    · rfl
  token := by
    funext text position token
    dsimp only [totalize]
    split
    · exact meaning.token text position token ‹_›
    · rfl
  expression := by
    funext text position names scalarNames
    dsimp only [totalize]
    split
    · exact meaning.expression text position names scalarNames ‹_›
    · rfl
  target := by
    funext text state sameTarget
    dsimp only [totalize]
    split
    · exact meaning.target text state sameTarget ‹_›
    · rfl
  fits := funext fun facts => funext fun summary => meaning.fits facts summary
  sameLength := funext fun facts => funext fun left => funext fun right => meaning.sameLength facts left right
  reject := funext meaning.reject

/-- Source equations interpret a verified native body with totalized primitives.
The derived global equality belongs only to those formal extensions. -/
theorem basicEval_normalized {primitive : Primitives} (meaning : HelperMeaning primitive)
    (text : Source) (context : Native.Context) (scan : BodyScan) :
    basicEval (totalize primitive) text context scan = basicBody text context.model scan :=
  basicEval_of_equations (totalize_equations meaning) text context scan

theorem model_helper_meaning : HelperMeaning modelPrimitives where
  callAfter _ _ _ _ _ _ := rfl
  associationAfter _ _ _ _ _ := rfl
  token _ _ _ _ := rfl
  expression _ _ _ _ _ := rfl
  target _ _ _ _ := rfl
  fits _ _ := rfl
  sameLength _ _ _ := rfl
  reject _ := rfl

theorem basicToken_valid (token : ShellToken) (valid : token ∈ basicTokens) : Expressions.ValidToken token := by
  simp only [basicTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Expressions.ValidToken, Expressions.allTokens]

theorem basicToken_model (text : Source) (position : Nat) (token : ShellToken)
    (valid : token ∈ basicTokens) :
    fixedAfter text position (Expressions.spelling token) (Expressions.isWord token) = tokenAfter text position token := by
  simp only [basicTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

def Test.tokenCalls : Test → List ShellToken
  | .present tok => [tok]
  | .orElse left right | .andThen left right => left.tokenCalls ++ right.tokenCalls
  | _ => []

def Command.tokenCalls : Command → List ShellToken
  | .update (.token tok) => [tok]
  | .sequence first second => first.tokenCalls ++ second.tokenCalls
  | .choose test yes no => test.tokenCalls ++ yes.tokenCalls ++ no.tokenCalls
  | _ => []

/-- The extra finite-token domain restriction is checked against the complete
typed body, including tokens in every unreachable or returning branch. -/
theorem basic_tokens_complete :
    ∀ token ∈ basicCommands.tokenCalls, token ∈ basicTokens := by
  have checked : basicCommands.tokenCalls.all (fun token => decide (token ∈ basicTokens)) = true := by
    decide +kernel
  intro token present
  exact of_decide_eq_true ((List.all_eq_true.mp checked) token present)

/-- Callee wiring to inherited declaration/expression helpers and the exact
typed path-library bodies. Native path records are projected only after body
evaluation; the independent path meanings are derived below. -/
structure Links (primitive : Primitives) (inherited : Expressions.Calls) : Prop where
  callAfter : primitive.callAfter = inherited.function .callAfter
  associationAfter : primitive.associationAfter = inherited.names.associationAfter
  token : primitive.token = inherited.function .takeToken
  expression : primitive.expression = inherited.function .expression
  target : primitive.target = inherited.function .target
  fits : ∀ (facts : PathFacts.Native.Context) summary,
    primitive.fits facts.model summary =
      PathFacts.Native.fitsBody.eval ({facts, value := summary} : Native.Libraries.PathInputs).locals
  sameLength : ∀ (facts : PathFacts.Native.Context) left right,
    primitive.sameLength facts.model left right = PathFacts.Native.sameLengthBody.eval
      ({facts, leftSummary := left, rightSummary := right} : Native.Libraries.PathInputs).locals
  reject : ∀ facts : PathFacts.Native.Context,
    primitive.reject facts.model =
      (PathFacts.Native.rejectedBody.eval ({facts} : Native.Libraries.PathInputs).locals).model

theorem HelperMeaning.of_inherited {primitive : Primitives} {inherited : Expressions.Calls}
    (source : Expressions.HelperEquations inherited) (links : Links primitive inherited) :
    HelperMeaning primitive where
  callAfter text names position operation scalarNames valid := by
    rw [links.callAfter]
    exact Expressions.interpreted_callAfter inherited source text valid.1 names position operation valid.2.2.1 valid.2.1 valid.2.2.2
  associationAfter text position formal valid bounded := by
    rw [links.associationAfter]
    exact Names.interpreted_association inherited.names source.names text valid position formal bounded
  token text position token valid := by
    rw [links.token, Expressions.interpreted_take inherited source text valid.1 position token
      valid.2.1 (basicToken_valid token valid.2.2)]
    exact basicToken_model text position token valid.2.2
  expression text position names scalarNames valid := by
    rw [links.expression]
    exact Expressions.interpreted_expression inherited source text valid.1 position names valid.2.1 valid.2.2.1 valid.2.2.2
  target text state sameTarget valid := by
    rw [links.target]
    exact Expressions.interpreted_target inherited source text valid.1 state sameTarget valid.2
  fits facts summary := by
    have equation := links.fits (Native.Libraries.reify facts) summary
    simpa only [PathFacts.Native.fitsBody_eval, Native.Libraries.PathInputs.locals,
      PathFacts.Native.fits_model, Native.Libraries.reify_model] using equation
  sameLength facts left right := by
    have equation := links.sameLength (Native.Libraries.reify facts) left right
    simpa only [PathFacts.Native.sameLengthBody_eval, Native.Libraries.PathInputs.locals,
      sameLength_project, Native.Libraries.reify_model] using equation
  reject facts := by
    have equation := links.reject (Native.Libraries.reify facts)
    simpa only [PathFacts.Native.rejectedBody_eval, Native.Libraries.PathInputs.locals,
      PathFacts.Native.rejected_model, Native.Libraries.reify_model] using equation

end Silver.Predicate.BasicNative
