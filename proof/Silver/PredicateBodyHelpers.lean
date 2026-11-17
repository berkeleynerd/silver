module

public import Silver.PredicateBodyModelSizing
public import Silver.PredicateLoopImports

@[expose] public section

/-! Native callees are partial on their source preconditions. Their interpretation
uses the model only outside those domains, where there is no executable call.
GNATprove and the checked source contracts establish that actual calls stay in
domain. Totalization preserves every in-domain value; its global equality below
is a conclusion of the component correspondences, never an assumption about an
unchecked scanner. -/
namespace Silver.Predicate.BodyNative
open Compose

variable {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}

def bodyTokens : List ShellToken :=
  [.word "if", .word "for", .word "then", .word "end", .word "elsif", .word "else", .word "return", .symbol ";"]

structure HelperMeaning (primitive : Primitives) : Prop where
  loop : LoopNative.ImportsMeaning primitive.loop
  token : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    ∀ token, token ∈ bodyTokens →
    primitive.token text position token = tokenAfter text position token
  bodyToken : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → ∀ token, token ∈ bodyTokens →
    primitive.bodyToken text context scan token = Predicate.bodyToken text scan token
  basic : ∀ text, ValidText text → ∀ context, Native.ValidContext text context →
    ∀ scan, ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures →
    primitive.basic text context scan catalog procedures = basicBody text context.model scan catalog procedures
  predicate : ∀ text, ValidText text → ∀ context, Native.ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, Native.ValidFlow context facts →
    primitive.predicate text context position facts = readCondition text context.model position facts
  invalidModel : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → primitive.invalidModel scan = invalidBody scan
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → primitive.invalid scan = invalidBody scan
  joinInto : ∀ left right, left.count ≤ ScalarExpression.maxBindings → left.count = right.count →
    primitive.joinInto left right = left.join right

noncomputable def totalize (primitive : Primitives) : Primitives := by
  classical
  exact {
    loop := LoopNative.totalizeImports primitive.loop
    token := fun text position token =>
      if ValidText text ∧ position ≤ text.length + 1 ∧ token ∈ bodyTokens then
        primitive.token text position token else tokenAfter text position token
    bodyToken := fun text context scan token =>
      if ValidText text ∧ Native.ValidContext text context ∧ ValidScan text context scan ∧ token ∈ bodyTokens then
        primitive.bodyToken text context scan token else Predicate.bodyToken text scan token
    basic := fun text context scan catalog procedures =>
      if ValidText text ∧ Native.ValidContext text context ∧ ValidScan text context scan ∧ FunctionBindings.ValidMetadata text catalog ∧ ProcedureBindings.ValidMetadata text procedures then
        primitive.basic text context scan catalog procedures else basicBody text context.model scan catalog procedures
    predicate := fun text context position facts =>
      if ValidText text ∧ Native.ValidContext text context ∧ position ≤ text.length + 1 ∧ Native.ValidFlow context facts then
        primitive.predicate text context position facts else readCondition text context.model position facts
    invalidModel := fun scan => if scan.count ≤ ScalarExpression.maxBindings then primitive.invalidModel scan else invalidBody scan
    invalid := fun scan => if scan.count ≤ ScalarExpression.maxBindings then primitive.invalid scan else invalidBody scan
    joinInto := fun left right => if left.count ≤ ScalarExpression.maxBindings ∧ left.count = right.count then
      primitive.joinInto left right else left.join right }

theorem totalize_token (primitive : Primitives) (text : Source) (tv : ValidText text)
    (position : Nat) (pv : position ≤ text.length + 1) (token : ShellToken)
    (valid : token ∈ bodyTokens) :
    (totalize primitive).token text position token = primitive.token text position token := by
  classical
  simp only [totalize, tv, pv, valid, and_self, ↓reduceIte]

theorem totalize_basic (primitive : Primitives) (text : Source) (tv : ValidText text)
    (context : Native.Context) (cv : Native.ValidContext text context) (scan : BodyScan)
    (sv : ValidScan text context scan) (fv : FunctionBindings.ValidMetadata text catalog) (pv : ProcedureBindings.ValidMetadata text procedures) :
    (totalize primitive).basic text context scan catalog procedures = primitive.basic text context scan catalog procedures := by
  classical
  simp only [totalize, tv, cv, sv, fv, pv, and_self, ↓reduceIte]

theorem totalize_predicate (primitive : Primitives) (text : Source) (tv : ValidText text)
    (context : Native.Context) (cv : Native.ValidContext text context) (position : Nat)
    (pv : position ≤ text.length + 1) (facts : ActiveFlow) (fv : Native.ValidFlow context facts) :
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
  have bodyTokensSame : (totalize primitive).bodyToken = modelPrimitives.bodyToken := by
    funext text context scan token
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i valid
      exact meaning.bodyToken text valid.1 context valid.2.1 scan valid.2.2.1 token valid.2.2.2
    · rfl
  have basics : (totalize primitive).basic = modelPrimitives.basic := by
    funext text context scan catalog procedures
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i valid
      exact meaning.basic text valid.1 context valid.2.1 scan valid.2.2.1 catalog procedures valid.2.2.2.1 valid.2.2.2.2
    · rfl
  have predicates : (totalize primitive).predicate = modelPrimitives.predicate := by
    funext text context position facts
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i valid
      exact meaning.predicate text valid.1 context valid.2.1 position valid.2.2.1 facts valid.2.2.2
    · rfl
  have invalidModels : (totalize primitive).invalidModel = modelPrimitives.invalidModel := by
    funext scan
    dsimp only [totalize, modelPrimitives]
    split
    · exact meaning.invalidModel scan ‹_›
    · rfl
  have invalids : (totalize primitive).invalid = modelPrimitives.invalid := by
    funext scan
    dsimp only [totalize, modelPrimitives]
    split
    · exact meaning.invalid scan ‹_›
    · rfl
  have joins : (totalize primitive).joinInto = modelPrimitives.joinInto := by
    funext left right
    dsimp only [totalize, modelPrimitives]
    split
    · rename_i legal
      exact meaning.joinInto left right legal.1 legal.2
    · rfl
  have loops : (totalize primitive).loop = modelPrimitives.loop :=
    LoopNative.totalizeImports_eq_model meaning.loop
  cases h : totalize primitive
  simp only [h] at loops tokens bodyTokensSame basics predicates invalidModels invalids joins
  cases loops
  cases tokens
  cases bodyTokensSame
  cases basics
  cases predicates
  cases invalidModels
  cases invalids
  cases joins
  rfl

/-- Interpretation of the exact rendered bodies using domain-preserving helper
extensions. Every recursive callee remains arbitrary. -/
structure DefinitionEquations (primitive : Primitives) (calls : Calls) : Prop where
  sized : SizedBodies (totalize primitive) calls
  statement : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.statement text context scan catalog procedures = statementEval (totalize primitive) calls {text,context,scan,catalog,procedures}
  loop : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.loop text context scan catalog procedures = LoopNative.evalWith (LoopNative.totalizeImports primitive.loop) calls.read text context scan catalog procedures
  conditional : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.conditional text context scan catalog procedures = conditionalFunction.eval (totalize primitive) calls {text,context,scan,catalog,procedures}
  alternative : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.alternative text context scan catalog procedures = alternativeFunction.eval (totalize primitive) calls {text,context,scan,catalog,procedures}
  tailModel : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.tailModel text context scan stop catalog procedures = tailModelBody.eval (totalize primitive) calls {text,context,scan,catalog,procedures,stop}
  tail : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.tail text context scan stop catalog procedures =
      (ScanExpr.tailModel .current .input).eval (totalize primitive) calls {text,context,scan,catalog,procedures,stop}
  read : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → ∀ catalog procedures, FunctionBindings.ValidMetadata text catalog → ProcedureBindings.ValidMetadata text procedures → calls.read text context scan stop catalog procedures = readContractBody.eval (totalize primitive) calls {text,context,scan,catalog,procedures,stop}

theorem equations_of_definitions (primitive : Primitives) (calls : Calls)
    (meaning : HelperMeaning primitive) (definitions : DefinitionEquations primitive calls) : Equations calls := by
  have normalized := totalize_eq_model primitive meaning
  exact {
    statement := by simpa only [normalized] using definitions.statement
    loop := by
      simpa only [LoopNative.evalWith_of_meaning meaning.loop] using definitions.loop
    conditional := by simpa only [normalized] using definitions.conditional
    alternative := by simpa only [normalized] using definitions.alternative
    tailModel := by simpa only [normalized] using definitions.tailModel
    tail := definitions.tail
    read := by simpa only [normalized] using definitions.read }

theorem model_helper_meaning : HelperMeaning modelPrimitives where
  loop := LoopNative.model_imports_meaning
  token _ _ _ _ _ _ := rfl
  bodyToken _ _ _ _ _ _ _ _ := rfl
  basic _ _ _ _ _ _ _ _ _ _ := rfl
  predicate _ _ _ _ _ _ _ _ := rfl
  invalidModel _ _ := rfl
  invalid _ _ := rfl
  joinInto _ _ _ _ := rfl

theorem model_definition_equations : DefinitionEquations modelPrimitives modelCalls := by
  have normalized := totalize_eq_model modelPrimitives model_helper_meaning
  exact {
    sized := by simpa only [normalized] using model_sizedBodies
    statement := by simpa only [normalized] using model_equations.statement
    loop := by
      simpa only [LoopNative.evalWith_of_meaning model_helper_meaning.loop] using model_equations.loop
    conditional := by simpa only [normalized] using model_equations.conditional
    alternative := by simpa only [normalized] using model_equations.alternative
    tailModel := by simpa only [normalized] using model_equations.tailModel
    tail := model_equations.tail
    read := by simpa only [normalized] using model_equations.read }

theorem bodyToken_valid (token : ShellToken) (valid : token ∈ bodyTokens) :
    Compose.Expressions.ValidToken token := by
  simp only [bodyTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    simp [Compose.Expressions.ValidToken, Compose.Expressions.allTokens]

theorem bodyToken_model (text : Source) (position : Nat) (token : ShellToken)
    (valid : token ∈ bodyTokens) :
    fixedAfter text position (Compose.Expressions.spelling token) (Compose.Expressions.isWord token) =
      tokenAfter text position token := by
  simp only [bodyTokens, List.mem_cons, List.mem_nil_iff, or_false] at valid
  rcases valid with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

def ScanExpr.tokenCalls : ScanExpr → List ShellToken
  | .token tok value => tok :: value.tokenCalls
  | .invalid value | .invalidModel value
  | .basic value | .statement value | .loop value | .conditional value | .alternative value
  | .tailModel _ value | .tail _ value | .read _ value => value.tokenCalls
  | _ => []

def Test.tokenCalls : Test → List ShellToken
  | .present token value => token :: value.tokenCalls
  | .zero value | .nonadvancing value => value.tokenCalls
  | .stop value => [.word "end", .word "else", .word "elsif", .word "return"] ++ value.tokenCalls

def Command.tokenCalls : Command → List ShellToken
  | .assign value | .ret value => value.tokenCalls
  | .sequence first second => first.tokenCalls ++ second.tokenCalls
  | .choose test yes no => test.tokenCalls ++ yes.tokenCalls ++ no.tokenCalls
  | _ => []

def Function.tokenCalls (fn : Function) : List ShellToken := fn.initial.tokenCalls ++ fn.body.tokenCalls

def ModelExpr.tokenCalls : ModelExpr → List ShellToken
  | .value expression => expression.tokenCalls
  | .group expression => expression.tokenCalls
  | .choose test yes no | .elsif test yes no => test.tokenCalls ++ yes.tokenCalls ++ no.tokenCalls
  | .localResult initial rest => initial.tokenCalls ++ rest.tokenCalls

/-- All literal token calls in the complete recursive-body AST, including the
statement dispatch and every stop alternative, stay in this finite domain. -/
theorem body_tokens_complete :
    ∀ token ∈ [ShellToken.word "if", ShellToken.word "for"] ++ conditionalFunction.tokenCalls ++ alternativeFunction.tokenCalls ++
      tailModelBody.tokenCalls ++ readFunction.tokenCalls, token ∈ bodyTokens := by
  have checked : ([ShellToken.word "if", ShellToken.word "for"] ++ conditionalFunction.tokenCalls ++ alternativeFunction.tokenCalls ++
      tailModelBody.tokenCalls ++ readFunction.tokenCalls).all (fun token => decide (token ∈ bodyTokens)) = true := by
    decide +kernel
  intro token present
  exact of_decide_eq_true ((List.all_eq_true.mp checked) token present)

end Silver.Predicate.BodyNative
