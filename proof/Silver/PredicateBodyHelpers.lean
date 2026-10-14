module

public import Silver.PredicateBodyCorrespondence

@[expose] public section

/-! Native callees are partial on their source preconditions. Their interpretation
uses the model only outside those domains, where there is no executable call.
GNATprove and the checked source contracts establish that actual calls stay in
domain. Totalization preserves every in-domain value; its global equality below
is a conclusion of the component correspondences, never an assumption about an
unchecked scanner. -/
namespace Silver.Predicate.BodyNative
open Compose

def bodyTokens : List ShellToken :=
  [.word "if", .word "then", .word "end", .word "elsif", .word "else", .symbol ";"]

structure HelperMeaning (primitive : Primitives) : Prop where
  token : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    ∀ token, token ∈ bodyTokens →
    primitive.token text position token = tokenAfter text position token
  basic : ∀ text, ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, ValidScan text context scan →
    primitive.basic text context scan = basicBody text context.model scan
  predicate : ∀ text, ValidText text → ∀ context, Native.ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    primitive.predicate text context position facts = readCondition text context.model position facts

noncomputable def totalize (primitive : Primitives) : Primitives := by
  classical
  exact {
    token := fun text position token =>
      if ValidText text ∧ position ≤ text.length + 1 ∧ token ∈ bodyTokens then
        primitive.token text position token else tokenAfter text position token
    basic := fun text context scan =>
      if ValidText text ∧ Native.ValidContext text context ∧ ValidScan text context scan then
        primitive.basic text context scan else basicBody text context.model scan
    predicate := fun text context position facts =>
      if ValidText text ∧ Native.ValidContext text context ∧ position ≤ text.length + 1 ∧ facts.Bounded then
        primitive.predicate text context position facts else readCondition text context.model position facts }

theorem totalize_token (primitive : Primitives) (text : Source) (tv : ValidText text)
    (position : Nat) (pv : position ≤ text.length + 1) (token : ShellToken)
    (valid : token ∈ bodyTokens) :
    (totalize primitive).token text position token = primitive.token text position token := by
  classical
  simp only [totalize, tv, pv, valid, and_self, ↓reduceIte]

theorem totalize_basic (primitive : Primitives) (text : Source) (tv : ValidText text)
    (context : Native.Context) (cv : Native.ValidContext text context) (scan : BodyScan)
    (sv : ValidScan text context scan) :
    (totalize primitive).basic text context scan = primitive.basic text context scan := by
  classical
  simp only [totalize, tv, cv, sv, and_self, ↓reduceIte]

theorem totalize_predicate (primitive : Primitives) (text : Source) (tv : ValidText text)
    (context : Native.Context) (cv : Native.ValidContext text context) (position : Nat)
    (pv : position ≤ text.length + 1) (facts : PathFacts.Context) (fv : facts.Bounded) :
    (totalize primitive).predicate text context position facts = primitive.predicate text context position facts := by
  classical
  simp only [totalize, tv, cv, pv, fv, and_self, ↓reduceIte]

theorem totalize_eq_model (primitive : Primitives) (meaning : HelperMeaning primitive) :
    totalize primitive = modelPrimitives := by
  classical
  have tokens : (totalize primitive).token = modelPrimitives.token := by
    funext text position token
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i valid
      exact meaning.token text valid.1 position valid.2.1 token valid.2.2
    · rfl
  have basics : (totalize primitive).basic = modelPrimitives.basic := by
    funext text context scan
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i valid
      exact meaning.basic text valid.1 context valid.2.1 scan valid.2.2
    · rfl
  have predicates : (totalize primitive).predicate = modelPrimitives.predicate := by
    funext text context position facts
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i valid
      exact meaning.predicate text valid.1 context valid.2.1 position valid.2.2.1 facts valid.2.2.2
    · rfl
  cases h : totalize primitive
  simp only [h] at tokens basics predicates
  cases tokens
  cases basics
  cases predicates
  rfl

/-- Interpretation of the exact rendered bodies using domain-preserving helper
extensions. Every recursive callee remains arbitrary. -/
structure DefinitionEquations (primitive : Primitives) (calls : Calls) : Prop where
  statement : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.statement text context scan = statementEval (totalize primitive) calls {text,context,scan}
  conditional : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.conditional text context scan = conditionalFunction.eval (totalize primitive) calls {text,context,scan}
  alternative : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → calls.alternative text context scan = alternativeFunction.eval (totalize primitive) calls {text,context,scan}
  tail : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → calls.tail text context scan stop = tailFunction.eval (totalize primitive) calls {text,context,scan,stop}
  read : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → calls.read text context scan stop = readFunction.eval (totalize primitive) calls {text,context,scan,stop}

theorem equations_of_definitions (primitive : Primitives) (calls : Calls)
    (meaning : HelperMeaning primitive) (definitions : DefinitionEquations primitive calls) : Equations calls := by
  have normalized := totalize_eq_model primitive meaning
  exact {
    statement := by simpa only [normalized] using definitions.statement
    conditional := by simpa only [normalized] using definitions.conditional
    alternative := by simpa only [normalized] using definitions.alternative
    tail := by simpa only [normalized] using definitions.tail
    read := by simpa only [normalized] using definitions.read }

theorem model_helper_meaning : HelperMeaning modelPrimitives where
  token _ _ _ _ _ _ := rfl
  basic _ _ _ _ _ _ := rfl
  predicate _ _ _ _ _ _ _ _ := rfl

theorem model_definition_equations : DefinitionEquations modelPrimitives modelCalls := by
  have normalized := totalize_eq_model modelPrimitives model_helper_meaning
  exact {
    statement := by simpa only [normalized] using model_equations.statement
    conditional := by simpa only [normalized] using model_equations.conditional
    alternative := by simpa only [normalized] using model_equations.alternative
    tail := by simpa only [normalized] using model_equations.tail
    read := by simpa only [normalized] using model_equations.read }

theorem bodyToken_valid (token : ShellToken) (valid : token ∈ bodyTokens) :
    Compose.Expressions.ValidToken token := by
  simp only [bodyTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem bodyToken_model (text : Source) (position : Nat) (token : ShellToken)
    (valid : token ∈ bodyTokens) :
    fixedAfter text position (Compose.Expressions.spelling token) (Compose.Expressions.isWord token) =
      tokenAfter text position token := by
  simp only [bodyTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

def ScanExpr.tokenCalls : ScanExpr → List ShellToken
  | .token tok value => tok :: value.tokenCalls
  | .basic value | .statement value | .conditional value | .alternative value
  | .tail _ value | .read _ value => value.tokenCalls
  | _ => []

def Test.tokenCalls : Test → List ShellToken
  | .present token value => token :: value.tokenCalls
  | .zero value | .nonadvancing value => value.tokenCalls
  | .stop value => [.word "end", .word "else", .word "elsif"] ++ value.tokenCalls

def Command.tokenCalls : Command → List ShellToken
  | .assign value | .ret value => value.tokenCalls
  | .sequence first second => first.tokenCalls ++ second.tokenCalls
  | .choose test yes no => test.tokenCalls ++ yes.tokenCalls ++ no.tokenCalls
  | _ => []

def Function.tokenCalls (fn : Function) : List ShellToken := fn.initial.tokenCalls ++ fn.body.tokenCalls

/-- All literal token calls in the complete recursive-body AST, including the
statement dispatch and every stop alternative, stay in this finite domain. -/
theorem body_tokens_complete :
    ∀ token ∈ [ShellToken.word "if"] ++ conditionalFunction.tokenCalls ++ alternativeFunction.tokenCalls ++
      tailFunction.tokenCalls ++ readFunction.tokenCalls, token ∈ bodyTokens := by
  have checked : ([ShellToken.word "if"] ++ conditionalFunction.tokenCalls ++ alternativeFunction.tokenCalls ++
      tailFunction.tokenCalls ++ readFunction.tokenCalls).all (fun token => decide (token ∈ bodyTokens)) = true := by
    decide +kernel
  intro token present
  exact of_decide_eq_true ((List.all_eq_true.mp checked) token present)

end Silver.Predicate.BodyNative
