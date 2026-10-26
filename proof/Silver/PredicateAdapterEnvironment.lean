module

public import Silver.PredicateAdapter
public import Silver.ScalarEnvironmentSourceBridge
public import Silver.PredicateFlowSourceBridge
public import Silver.ComposeEquations
public import Silver.ComposeModelCalls

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

def flowContext (context : Native.Context) : FlowSourceBridge.Context :=
  ⟨FlowSourceBridge.ofNames context.scalarNames, context.declarationCount, context.dynamicFirst⟩

theorem initial_expression_projection (library : FlowSourceBridge.Calls)
    (meaning : FlowSourceBridge.CallsMeaning library)
    (initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage)
    (verified : FlowSourceBridge.InterpretedInitial library initial)
    (calls : BodyNative.Calls) (frame : Adapter.Frame) (ctx : Adapter.Expr Native.Context)
    (bounded : (ctx.eval calls frame).scalarNames.length ≤ ScalarExpression.maxBindings) :
    (Adapter.Expr.initialFlow ctx).eval calls frame =
      (initial (flowContext (ctx.eval calls frame))).active := by
  have legal : (flowContext (ctx.eval calls frame)).InRange := by
    change (ctx.eval calls frame).scalarNames.length ≤ ScalarExpression.maxBindings
    exact bounded
  rw [FlowSourceBridge.interpreted_initial library meaning initial verified
    (flowContext (ctx.eval calls frame)) legal]
  simp only [Adapter.Expr.eval, Adapter.initialFlow, flowContext, FlowSourceBridge.ofNames_active]
  have path (arguments : Bool) : initialFacts arguments = FlowSourceBridge.initialPath arguments := by
    cases arguments <;> rfl
  rw [path]
  rfl

/-- The actual finite-storage Initial_Flow callee projected to active flow. -/
def initialCall (initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage)
    (context : Native.Context) : ActiveFlow := (initial (flowContext context)).active

theorem initialCall_interpreted (library : FlowSourceBridge.Calls)
    (meaning : FlowSourceBridge.CallsMeaning library)
    (initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage)
    (verified : FlowSourceBridge.InterpretedInitial library initial)
    (context : Native.Context)
    (bounded : context.scalarNames.length ≤ ScalarExpression.maxBindings) :
    initialCall initial context = Adapter.initialFlow context := by
  exact (initial_expression_projection library meaning initial verified
    BodyNative.modelCalls {context} .context bounded).symm

theorem body_expression_projection (library : FlowSourceBridge.Calls)
    (meaning : FlowSourceBridge.CallsMeaning library)
    (initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage)
    (verified : FlowSourceBridge.InterpretedInitial library initial)
    (calls : BodyNative.Calls) (frame : Adapter.Frame)
    (bounded : frame.scan.state.scalarNames.length ≤ ScalarExpression.maxBindings) :
    Adapter.bodyExpr.eval calls frame (initialFlowCall := initialCall initial) =
      Adapter.bodyExpr.eval calls frame := by
  have ready : (Adapter.contextOf frame.scan).scalarNames.length ≤ ScalarExpression.maxBindings := by
    simpa only [Adapter.contextOf, ScalarExpression.bodyEnvironment_length] using bounded
  simp only [Adapter.bodyExpr, Adapter.Expr.eval, Adapter.Field.eval,
    initialCall_interpreted library meaning initial verified _ ready]

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
  initial : ∀ library, FlowSourceBridge.CallsMeaning library → ∀ initial,
    FlowSourceBridge.InterpretedInitial library initial → ∀ calls frame ctx,
    (ctx.eval calls frame).scalarNames.length ≤ ScalarExpression.maxBindings →
    (Adapter.Expr.initialFlow ctx).eval calls frame =
      (initial (flowContext (ctx.eval calls frame))).active

theorem actual_source_projection :
    EnvironmentSourceBridge.Checked Source.scalarExpressionSpecTokens ∧ Projection :=
  ⟨EnvironmentSourceBridge.actual_source_checked,
    ⟨expression_projection, context_projection, initial_expression_projection⟩⟩

end Silver.Predicate.Adapter.Environment

namespace Silver.Predicate.Adapter.Wrappers
open Compose Silver.SourceBridge

/-- Keep model functions and runtime wrappers arbitrary until their own
rendered definitions and Static contracts have been interpreted. -/
structure Calls where
  bodyOf : ScanResult → BodyScan
  token : Source → Native.Context → BodyScan → ShellToken → BodyScan

inductive Rhs | bodyOf | token

def Rhs.eval (calls : Calls) (frame : Adapter.Frame) : Rhs → BodyScan
  | .bodyOf => calls.bodyOf frame.scan
  | .token => calls.token frame.text frame.context frame.body frame.token

def Rhs.render : Rhs → List String
  | .bodyOf => expectedTokens "Body_Of_Model (Scan)"
  | .token => expectedTokens "Body_Token_Model (Text, Context, Scan, Token)"

def BodyDomain (scan : ScanResult) : Prop := scan.state.scalarNames.length ≤ ScalarExpression.maxBindings

def TokenDomain (text : Source) (context : Native.Context) (scan : BodyScan)
    (token : ShellToken) : Prop :=
  Compose.Expressions.ValidText text ∧ Native.ValidContext text context ∧
    BodyNative.ValidScan text context scan ∧ Compose.Expressions.ValidToken token

structure ModelEquations (models : Calls) (body : BodyNative.Calls)
    (initialFlowCall : Native.Context → ActiveFlow := Adapter.initialFlow)
    (takeTokenCall : Source → Nat → ShellToken → Nat := Adapter.takeTokenModel) : Prop where
  bodyOf : ∀ scan, BodyDomain scan → models.bodyOf scan = bodyExpr.eval body {scan} (initialFlowCall := initialFlowCall)
  token : ∀ text context scan token, TokenDomain text context scan token →
    models.token text context scan token =
      tokenExpr.eval body {text,context,body := scan,token} (takeTokenCall := takeTokenCall)

/-- Interpret the raw Take_Token callee on its complete native enum domain.
No fixed-token restriction is needed until projection to the body semantics. -/
theorem token_expression_projection {domain : Expressions.StateDomain} {inherited : Expressions.Calls}
    (source : Expressions.HelperEquations inherited (domain := domain))
    (body : BodyNative.Calls) (text : Source) (context : Native.Context)
    (scan : BodyScan) (token : ShellToken) (legal : TokenDomain text context scan token) :
    tokenExpr.eval body {text,context,body := scan,token}
        (takeTokenCall := inherited.function .takeToken) =
      tokenExpr.eval body {text,context,body := scan,token} := by
  change {scan with position := inherited.function .takeToken text scan.position token} =
    {scan with position := Adapter.takeTokenModel text scan.position token}
  rw [Expressions.interpreted_take inherited source text legal.1 scan.position token
    legal.2.2.1.1 legal.2.2.2]
  rfl

theorem normalize_tokens {domain : Expressions.StateDomain} {inherited : Expressions.Calls}
    (source : Expressions.HelperEquations inherited (domain := domain))
    {models : Calls} {body : BodyNative.Calls} {initialFlowCall : Native.Context → ActiveFlow}
    (definitions : ModelEquations models body initialFlowCall (inherited.function .takeToken)) :
    ModelEquations models body initialFlowCall where
  bodyOf := definitions.bodyOf
  token text context scan token legal := (definitions.token text context scan token legal).trans
    (token_expression_projection source body text context scan token legal)

/-- Normalize the actual Initial_Flow callee only after interpreting its full
Count/Path/Values postcondition. The body model function remains arbitrary. -/
theorem normalize_models (library : FlowSourceBridge.Calls)
    (meaning : FlowSourceBridge.CallsMeaning library)
    (initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage)
    (verified : FlowSourceBridge.InterpretedInitial library initial)
    {models : Calls} {body : BodyNative.Calls}
    (definitions : ModelEquations models body (Environment.initialCall initial)) :
    ModelEquations models body where
  bodyOf scan legal := (definitions.bodyOf scan legal).trans
    (Environment.body_expression_projection library meaning initial verified body {scan} legal)
  token := definitions.token

structure Refinement (models wrappers : Calls) : Prop where
  bodyOf : ∀ scan, BodyDomain scan → wrappers.bodyOf scan = Rhs.bodyOf.eval models {scan}
  token : ∀ text context scan token, TokenDomain text context scan token →
    wrappers.token text context scan token = Rhs.token.eval models {text,context,body := scan,token}

theorem bodyOf_interpreted {models wrappers : Calls} {body : BodyNative.Calls}
    (definitions : ModelEquations models body) (verified : Refinement models wrappers)
    (scan : ScanResult) (legal : BodyDomain scan) : wrappers.bodyOf scan = Predicate.bodyOf scan := by
  rw [verified.bodyOf scan legal]
  change models.bodyOf scan = _
  rw [definitions.bodyOf scan legal, body_eval]

/-- The runtime wrapper's discriminant agrees with the scalar-name count;
this also discharges erasure of the explicit model aggregate discriminant. -/
theorem bodyOf_count {models wrappers : Calls} {body : BodyNative.Calls}
    (definitions : ModelEquations models body) (verified : Refinement models wrappers)
    (scan : ScanResult) (legal : BodyDomain scan) :
    (wrappers.bodyOf scan).count = scan.state.scalarNames.length := by
  rw [verified.bodyOf scan legal]
  change (models.bodyOf scan).count = _
  rw [definitions.bodyOf scan legal]
  exact body_count body {scan}

theorem token_interpreted {models wrappers : Calls} {body : BodyNative.Calls}
    (definitions : ModelEquations models body) (verified : Refinement models wrappers)
    (text : Source) (context : Native.Context) (scan : BodyScan) (token : ShellToken)
    (legal : TokenDomain text context scan token) (fixed : Adapter.FixedToken token) :
    wrappers.token text context scan token = bodyToken text scan token := by
  rw [verified.token text context scan token legal]
  change models.token text context scan token = _
  rw [definitions.token text context scan token legal, token_eval body {text,context,body := scan,token} fixed]

/-- Interpret the Body_Of runtime call at its concrete Read_Statements site,
with arbitrary recursive body calls preserved. -/
theorem adapter_interpreted {models wrappers : Calls} {body : BodyNative.Calls}
    (definitions : ModelEquations models body) (verified : Refinement models wrappers)
    (frame : Adapter.Frame) (legal : BodyDomain frame.scan) :
    Adapter.adapterFunction.eval body frame (bodyOfCall := wrappers.bodyOf) =
      Adapter.adapterFunction.eval body frame := by
  have same := bodyOf_interpreted definitions verified frame.scan legal
  simp only [Adapter.adapterFunction, Adapter.Function.eval, Adapter.Expr.eval,
    Adapter.Field.eval, same]
  rfl

def modelCalls (body : BodyNative.Calls) : Calls where
  bodyOf scan := bodyExpr.eval body {scan}
  token text context scan token := tokenExpr.eval body {text,context,body := scan,token}

theorem model_equations (body : BodyNative.Calls) : ModelEquations (modelCalls body) body :=
  ⟨fun _ _ => rfl, fun _ _ _ _ _ => rfl⟩

/-- The concrete full-enum model also inhabits the raw inherited-callee
interface; this witness includes capacity/literal/pseudo token values. -/
theorem model_raw_equations {domain : Expressions.StateDomain}
    (source : Expressions.HelperEquations Expressions.modelCalls (domain := domain))
    (body : BodyNative.Calls) :
    ModelEquations (modelCalls body) body
      (takeTokenCall := Expressions.modelCalls.function .takeToken) where
  bodyOf _ _ := rfl
  token text context scan token legal :=
    (token_expression_projection source body text context scan token legal).symm

theorem model_refinement (models : Calls) : Refinement models models :=
  ⟨fun _ _ => rfl, fun _ _ _ _ _ => rfl⟩

def bodyHeader : List String := expectedTokens "(Scan : Scan_Result) return Body_Scan"
def bodySpec : List String := bodyHeader ++ expectedTokens
  "with Global => null, Post => (Static => Body_Of'Result =" ++ Rhs.bodyOf.render ++ [")"]

def tokenHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind) return Body_Scan"
def tokenPre : List String := expectedTokens
  "Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)"
def tokenSpec : List String := tokenHeader ++ expectedTokens "with Global => null, Pre =>" ++ tokenPre ++ expectedTokens
  ", Post => (Runtime => Valid_Body (Text, Context, Body_Token'Result) and then (Body_Token'Result.Position = 0 or else Body_Token'Result.Position > Scan.Position), Static => Body_Token'Result =" ++
  Rhs.token.render ++ [")"]

/-- Postfix Ghost aspects, full wrapper contracts, and the interpreted model
expressions are checked together. Body_Of/Body_Token are ordinary constrained
returns; their definitions are not mistaken for expression functions. -/
structure Checked (tokens : List String) : Prop where
  bodyModelHeader : functionHeader "body_of_model" "is" tokens = some bodyHeader
  bodyModel : expressionDeclaration "body_of_model" tokens =
    some ((bodyExpr.render.drop 1).dropLast, expectedTokens "with Ghost => Static")
  bodySpec : functionHeader "body_of" ";" tokens = some bodySpec
  bodyImpl : functionHeader "body_of" "is" tokens = some bodyHeader
  tokenModelHeader : functionHeader "body_token_model" "is" tokens = some tokenHeader
  tokenModel : expressionDeclaration "body_token_model" tokens =
    some ((tokenExpr.render.drop 1).dropLast,
      expectedTokens "with Ghost => Static, Global => null, Pre =>" ++ tokenPre)
  tokenSpec : functionHeader "body_token" ";" tokens = some tokenSpec
  tokenImpl : functionHeader "body_token" "is" tokens = some tokenHeader

structure Projection : Prop where
  bodyOf : ∀ models wrappers body, ModelEquations models body → Refinement models wrappers →
    ∀ scan, BodyDomain scan → wrappers.bodyOf scan = Predicate.bodyOf scan
  token : ∀ models wrappers body, ModelEquations models body → Refinement models wrappers →
    ∀ text context scan token, TokenDomain text context scan token → Adapter.FixedToken token →
      wrappers.token text context scan token = bodyToken text scan token
  bodyCount : ∀ calls frame, (bodyExpr.eval calls frame).count = frame.scan.state.scalarNames.length
  wrapperCount : ∀ models wrappers body, ModelEquations models body → Refinement models wrappers →
    ∀ scan, BodyDomain scan → (wrappers.bodyOf scan).count = scan.state.scalarNames.length

theorem projection : Projection :=
  ⟨fun _ _ _ => bodyOf_interpreted, fun _ _ _ => token_interpreted, body_count,
    fun _ _ _ => bodyOf_count⟩

end Silver.Predicate.Adapter.Wrappers
