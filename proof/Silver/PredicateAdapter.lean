module

public import Silver.PredicateBodyCorrespondence
public import Silver.PathNativeModel
public import Silver.PredicateOuterReadiness

@[expose] public section

/-! Typed native record adapters and the outer Read_Statements wrapper. Recursive
body calls remain arbitrary; their equations are used only by adapter_unique. -/
namespace Silver.Predicate.Adapter
open Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def contextOf (scan : ScanResult) : Native.Context :=
  ⟨scan.state.names, scan.state.dynamicFirst, scan.state.dynamicAfter,
    ScalarExpression.bodyEnvironment scan.state.scalarNames, scan.state.scalarNames.length⟩

def expand (context : Native.Context) (scan : BodyScan) : ScanResult :=
  ⟨⟨scan.position, context.names, context.dynamicFirst, context.dynamicAfter,
    scan.target, scan.capacity, context.scalarNames⟩, scan.assigned, scan.output⟩

def stopOf (token : ShellToken) : BodyStop :=
  if token = .word "else" then .elseOnly else .endOnly

def adapterEval (calls : BodyNative.Calls) (text : Source) (scan : ScanResult)
    (stop : ShellToken) : ScanResult :=
  let context := contextOf scan
  let result := calls.read text context (bodyOf scan) (stopOf stop)
  if result.position = 0 ∨ !completed result.facts.path then invalidScan else expand context result

@[simp] theorem contextOf_model (scan : ScanResult) : (contextOf scan).model = Predicate.contextOf scan := rfl

@[simp] theorem expand_model (before : ScanResult) (scan : BodyScan) :
    expand (contextOf before) scan = expandBody before.state scan := rfl

theorem initial_model (arguments : Bool) :
    (PathFacts.Native.initial arguments).model = initialFacts arguments := by
  cases arguments <;> rfl

theorem completed_model (facts : PathFacts.Native.Context) :
    PathFacts.Native.completed facts = completed facts.model := rfl

theorem initialFacts_bounded (arguments : Bool) : (initialFacts arguments).Bounded := by
  cases arguments
  · exact Nat.zero_le _
  · exact PathFacts.Context.initial_bounded (Nat.le_refl _)

theorem context_valid (text : Source) (scan : ScanResult)
    (valid : OuterReadiness.ValidState text scan.state) : Native.ValidContext text (contextOf scan) :=
  ⟨valid.1.2.1, valid.1.2.2.1, ScalarExpression.bodyEnvironment_valid valid.1.2.2.2.2.2,
    valid.2.baseReady⟩

theorem initial_flow_valid (text : Source) (scan : ScanResult)
    (valid : OuterReadiness.ValidState text scan.state) :
    Native.ValidFlow (contextOf scan) (bodyOf scan).facts := by
  refine ⟨initialFacts_bounded _, ?_⟩
  have ready := valid.2.bodyEnvironment.initial
    (ScalarExpression.bodyEnvironment_valid valid.1.2.2.2.2.2)
    (initialFacts (decide (scan.state.dynamicFirst ≠ 0)))
  simpa only [bodyOf, Predicate.contextOf, contextOf, ScalarExpression.bodyEnvironment_length] using ready

theorem body_valid (text : Source) (scan : ScanResult)
    (valid : OuterReadiness.ValidState text scan.state) : BodyNative.ValidScan text (contextOf scan) (bodyOf scan) :=
  ⟨valid.1.1, ⟨valid.1.2.2.2.1, valid.1.2.2.2.2.1⟩, initial_flow_valid text scan valid⟩

theorem expand_valid (text : Source) (context : Native.Context) (scan : BodyScan)
    (cv : Native.ValidContext text context) (sv : BodyNative.ValidScan text context scan) :
    Expressions.ValidState text (expand context scan).state :=
  ⟨sv.1, cv.1, cv.2.1, sv.2.1.1, sv.2.1.2, cv.2.2.1⟩

theorem invalidScan_valid (text : Source) : OuterReadiness.ValidState text invalidScan.state :=
  OuterReadiness.invalid_valid text

theorem model_adapter (text : Source) (scan : ScanResult) :
    adapterEval BodyNative.modelCalls text scan (.word "end") = readStatements text scan := by
  simp only [adapterEval, BodyNative.modelCalls, contextOf_model, stopOf]
  rfl

theorem adapter_unique (calls : BodyNative.Calls) (equations : BodyNative.Equations calls)
    (text : Source) (tv : Expressions.ValidText text) (scan : ScanResult)
    (sv : OuterReadiness.ValidState text scan.state) (stop : ShellToken) :
    adapterEval calls text scan stop = adapterEval BodyNative.modelCalls text scan stop := by
  unfold adapterEval
  dsimp only
  rw [BodyNative.read_unique calls equations text tv _ (context_valid text scan sv) _ _
    (body_valid text scan sv)]
  rfl

theorem model_adapter_valid (text : Source) (tv : Expressions.ValidText text)
    (scan : ScanResult) (sv : OuterReadiness.ValidState text scan.state) (stop : ShellToken) :
    OuterReadiness.ValidState text (adapterEval BodyNative.modelCalls text scan stop).state := by
  unfold adapterEval
  dsimp only
  split
  · exact invalidScan_valid text
  · exact ⟨expand_valid text _ _ (context_valid text scan sv)
      (BodyNative.model_read_valid text tv _ (context_valid text scan sv) _ _ (body_valid text scan sv)),
      sv.2.bodyEnvironment⟩

theorem readStatements_valid (text : Source) (tv : Expressions.ValidText text)
    (scan : ScanResult) (sv : OuterReadiness.ValidState text scan.state) :
    OuterReadiness.ValidState text (readStatements text scan).state := by
  rw [← model_adapter]
  exact model_adapter_valid text tv scan sv _

/-- Source projections are typed: a body cursor cannot be substituted for a
context field or a complete parser state. -/
inductive Field : Type → Type → Type
  | scanState : Field ScanResult ParserState
  | scanAssigned : Field ScanResult Bool
  | scanOutput : Field ScanResult Bool
  | statePosition : Field ParserState Nat
  | stateNames : Field ParserState BindingEnvironment
  | stateScalarNames : Field ParserState ScalarExpression.Environment
  | stateFirst : Field ParserState Nat
  | stateAfter : Field ParserState Nat
  | stateTarget : Field ParserState Nat
  | stateCapacity : Field ParserState Nat
  | contextNames : Field Native.Context BindingEnvironment
  | contextScalarNames : Field Native.Context ScalarExpression.Environment
  | contextDeclarationCount : Field Native.Context Nat
  | contextFirst : Field Native.Context Nat
  | contextAfter : Field Native.Context Nat
  | bodyPosition : Field BodyScan Nat
  | bodyTarget : Field BodyScan Nat
  | bodyCapacity : Field BodyScan Nat
  | bodyAssigned : Field BodyScan Bool
  | bodyOutput : Field BodyScan Bool
  | bodyFacts : Field BodyScan ActiveFlow
  | flowPath : Field ActiveFlow PathFacts.Context

def Field.eval : Field α β → α → β
  | .scanState => ScanResult.state | .scanAssigned => ScanResult.assigned | .scanOutput => ScanResult.output
  | .stateScalarNames => ParserState.scalarNames
  | .contextScalarNames => Native.Context.scalarNames
  | .contextDeclarationCount => Native.Context.declarationCount
  | .statePosition => ParserState.position | .stateNames => ParserState.names
  | .stateFirst => ParserState.dynamicFirst | .stateAfter => ParserState.dynamicAfter
  | .stateTarget => ParserState.target | .stateCapacity => ParserState.capacity
  | .contextNames => Native.Context.names | .contextFirst => Native.Context.dynamicFirst
  | .contextAfter => Native.Context.dynamicAfter
  | .bodyPosition => BodyScan.position | .bodyTarget => BodyScan.target | .bodyCapacity => BodyScan.capacity
  | .bodyAssigned => BodyScan.assigned | .bodyOutput => BodyScan.output | .bodyFacts => BodyScan.facts
  | .flowPath => ActiveFlow.path

def Field.name : Field α β → String
  | .scanState => "state" | .scanAssigned => "assigned" | .scanOutput => "output"
  | .stateScalarNames | .contextScalarNames => "scalar_names"
  | .contextDeclarationCount => "declaration_count"
  | .statePosition => "position" | .stateNames => "names" | .stateFirst => "dynamic_first"
  | .stateAfter => "dynamic_after" | .stateTarget => "target" | .stateCapacity => "capacity"
  | .contextNames => "names" | .contextFirst => "dynamic_first" | .contextAfter => "dynamic_after"
  | .bodyPosition => "position" | .bodyTarget => "target" | .bodyCapacity => "capacity"
  | .bodyAssigned => "assigned" | .bodyOutput => "output" | .bodyFacts => "facts"
  | .flowPath => "path"

structure Frame where
  text : Source := []
  scan : ScanResult := invalidScan
  body : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  context : Native.Context := ⟨[], 0, 0, [], 0⟩
  result : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  position : Nat := 0
  token : ShellToken := .word "end"
  stop : BodyStop := .endOnly

inductive Expr : Type → Type 1
  | scan : Expr ScanResult | body : Expr BodyScan | context : Expr Native.Context
  | result : Expr BodyScan | position : Expr Nat | token : Expr ShellToken | stop : Expr BodyStop
  | field (field : Field α β) (value : Expr α) : Expr β
  | zero (value : Expr Nat) : Expr Bool
  | nonzero (value : Expr Nat) : Expr Bool
  | not (value : Expr Bool) : Expr Bool
  | orElse (left right : Expr Bool) : Expr Bool
  | tokenEqual (token : ShellToken) : Expr Bool
  | stopValue (stop : BodyStop) : Expr BodyStop
  | choose (test : Expr Bool) (yes no : Expr α) : Expr α
  | initial (arguments : Expr Bool) : Expr PathFacts.Context
  | initialFlow (context : Expr Native.Context) : Expr ActiveFlow
  | nameCount (names : Expr ScalarExpression.Environment) : Expr Nat
  | completed (facts : Expr PathFacts.Context) : Expr Bool
  | bodyEnvironment (names : Expr ScalarExpression.Environment) : Expr ScalarExpression.Environment
  | contextValue (names : Expr BindingEnvironment) (scalarNames : Expr ScalarExpression.Environment)
      (declarations first after : Expr Nat) : Expr Native.Context
  | bodyValue (count : Expr Nat) (facts : Expr ActiveFlow) (position target capacity : Expr Nat)
      (assigned output : Expr Bool) : Expr BodyScan
  | stateValue (position : Expr Nat) (names : Expr BindingEnvironment) (scalarNames : Expr ScalarExpression.Environment) (first after target capacity : Expr Nat) : Expr ParserState
  | scanValue (state : Expr ParserState) (assigned output : Expr Bool) : Expr ScanResult
  | bodyToken (scan : Expr BodyScan) (token : Expr ShellToken) : Expr BodyScan
  | takeToken (position : Expr Nat) (token : ShellToken) : Expr Nat
  | invalid : Expr ScanResult
  | contextOf (scan : Expr ScanResult) : Expr Native.Context
  | bodyOf (scan : Expr ScanResult) : Expr BodyScan
  | expand (context : Expr Native.Context) (scan : Expr BodyScan) : Expr ScanResult
  | read (context : Expr Native.Context) (scan : Expr BodyScan) (stop : Expr BodyStop) : Expr BodyScan
  | stopCase (ending alternative arm : Expr Bool) : Expr Bool

def initialFlow (context : Native.Context) : ActiveFlow :=
  ActiveFlow.initial context.scalarNames (initialFacts (decide (context.dynamicFirst ≠ 0)))

def Expr.eval (calls : BodyNative.Calls) (frame : Frame)
    (bodyOfCall : ScanResult → BodyScan := Predicate.bodyOf)
    (initialFlowCall : Native.Context → ActiveFlow := Adapter.initialFlow) : Expr α → α
  | .scan => frame.scan | .body => frame.body | .context => frame.context | .result => frame.result
  | .position => frame.position | .token => frame.token | .stop => frame.stop
  | .field projection value => projection.eval (value.eval calls frame bodyOfCall initialFlowCall)
  | .zero value => decide (value.eval calls frame bodyOfCall initialFlowCall = 0)
  | .nonzero value => decide (value.eval calls frame bodyOfCall initialFlowCall ≠ 0)
  | .not value => !(value.eval calls frame bodyOfCall initialFlowCall)
  | .orElse left right => left.eval calls frame bodyOfCall initialFlowCall || right.eval calls frame bodyOfCall initialFlowCall
  | .tokenEqual tok => decide (frame.token = tok)
  | .stopValue boundary => boundary
  | .choose test yes no => if test.eval calls frame bodyOfCall initialFlowCall then yes.eval calls frame bodyOfCall initialFlowCall else no.eval calls frame bodyOfCall initialFlowCall
  | .initial arguments => (PathFacts.Native.initial (arguments.eval calls frame bodyOfCall initialFlowCall)).model
  | .initialFlow ctx => initialFlowCall (ctx.eval calls frame bodyOfCall initialFlowCall)
  | .nameCount names => (names.eval calls frame bodyOfCall initialFlowCall).length
  | .completed facts => Predicate.completed (facts.eval calls frame bodyOfCall initialFlowCall)
  | .bodyEnvironment names => ScalarExpression.bodyEnvironment (names.eval calls frame bodyOfCall initialFlowCall)
  | .contextValue names scalarNames declarations first after =>
      ⟨names.eval calls frame bodyOfCall initialFlowCall, first.eval calls frame bodyOfCall initialFlowCall, after.eval calls frame bodyOfCall initialFlowCall,
        scalarNames.eval calls frame bodyOfCall initialFlowCall, declarations.eval calls frame bodyOfCall initialFlowCall⟩
  | .bodyValue _ facts pos target capacity assigned output =>
      ⟨pos.eval calls frame bodyOfCall initialFlowCall, target.eval calls frame bodyOfCall initialFlowCall, capacity.eval calls frame bodyOfCall initialFlowCall,
        facts.eval calls frame bodyOfCall initialFlowCall, assigned.eval calls frame bodyOfCall initialFlowCall, output.eval calls frame bodyOfCall initialFlowCall⟩
  | .stateValue pos names scalarNames first after target capacity =>
      ⟨pos.eval calls frame bodyOfCall initialFlowCall, names.eval calls frame bodyOfCall initialFlowCall, first.eval calls frame bodyOfCall initialFlowCall,
        after.eval calls frame bodyOfCall initialFlowCall, target.eval calls frame bodyOfCall initialFlowCall, capacity.eval calls frame bodyOfCall initialFlowCall, scalarNames.eval calls frame bodyOfCall initialFlowCall⟩
  | .scanValue state assigned output => ⟨state.eval calls frame bodyOfCall initialFlowCall, assigned.eval calls frame bodyOfCall initialFlowCall, output.eval calls frame bodyOfCall initialFlowCall⟩
  | .bodyToken input tok => Predicate.bodyToken frame.text (input.eval calls frame bodyOfCall initialFlowCall) (tok.eval calls frame bodyOfCall initialFlowCall)
  | .takeToken pos tok => tokenAfter frame.text (pos.eval calls frame bodyOfCall initialFlowCall) tok
  | .invalid => invalidScan
  | .contextOf input => Adapter.contextOf (input.eval calls frame bodyOfCall initialFlowCall)
  | .bodyOf input => bodyOfCall (input.eval calls frame bodyOfCall initialFlowCall)
  | .expand ctx input => Adapter.expand (ctx.eval calls frame bodyOfCall initialFlowCall) (input.eval calls frame bodyOfCall initialFlowCall)
  | .read ctx input boundary => calls.read frame.text (ctx.eval calls frame bodyOfCall initialFlowCall) (input.eval calls frame bodyOfCall initialFlowCall) (boundary.eval calls frame bodyOfCall initialFlowCall)
  | .stopCase ending alternative arm => match frame.stop with
      | .endOnly => ending.eval calls frame bodyOfCall initialFlowCall | .elseOnly => alternative.eval calls frame bodyOfCall initialFlowCall | .arm => arm.eval calls frame bodyOfCall initialFlowCall

def record (fields : List (String × List String)) : List String :=
  ["("] ++ List.intercalate [","] (fields.map fun (name, value) => [name, "=>"] ++ value) ++ [")"]

def Expr.render : Expr α → List String
  | .scan => ["scan"] | .body => ["scan"] | .context => ["context"] | .result => ["result"]
  | .position => ["position"] | .token => ["token"] | .stop => ["stop"]
  | .field projection value => value.render ++ [".", projection.name]
  | .zero value => value.render ++ ["=", "0"]
  | .nonzero value => value.render ++ ["/=", "0"]
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .tokenEqual tok => ["stop", "="] ++ [Expressions.tokenName tok]
  | .stopValue boundary => [BodyNative.stopName boundary]
  | .choose test yes no => ["(", "if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render ++ [")"]
  | .initial arguments => ["paths", "."] ++ Expressions.call "initial" [arguments.render]
  | .initialFlow ctx => Expressions.call "initial_flow" [ctx.render]
  | .nameCount names => names.render ++ [".", "count"]
  | .completed facts => ["paths", "."] ++ Expressions.call "completed" [facts.render]
  | .bodyEnvironment names => ["scalar_expressions", "."] ++ Expressions.call "body_environment" [names.render]
  | .contextValue names scalarNames declarations first after => record [("names", names.render),
      ("scalar_names", scalarNames.render), ("declaration_count", declarations.render),
      ("dynamic_first", first.render), ("dynamic_after", after.render)]
  | .bodyValue count facts pos target capacity assigned output => record [("count", count.render), ("facts", facts.render),
      ("position", pos.render), ("target", target.render), ("capacity", capacity.render),
      ("assigned", assigned.render), ("output", output.render)]
  | .stateValue pos names scalarNames first after target capacity => record [("position", pos.render),
      ("names", names.render), ("scalar_names", scalarNames.render), ("dynamic_first", first.render), ("dynamic_after", after.render),
      ("target", target.render), ("capacity", capacity.render)]
  | .scanValue state assigned output => record [("state", state.render), ("assigned", assigned.render), ("output", output.render)]
  | .bodyToken input tok => ["("] ++ input.render ++ ["with", "delta", "position", "=>"] ++
      Expressions.call "take_token" [["text"], input.render ++ [".", "position"], tok.render] ++ [")"]
  | .takeToken pos tok => Expressions.call "take_token" [["text"], pos.render, [Expressions.tokenName tok]]
  | .invalid => ["invalid_scan"]
  | .contextOf input => Expressions.call "context_of" [input.render]
  | .bodyOf input => Expressions.call "body_of" [input.render]
  | .expand ctx input => Expressions.call "expand_body" [ctx.render, input.render]
  | .read ctx input boundary => Expressions.call "read_body" [["text"], ctx.render, input.render, boundary.render]
  | .stopCase ending alternative arm => ["(", "case", "stop", "is", "when", "end_only", "=>"] ++ ending.render ++
      [",", "when", "else_only", "=>"] ++ alternative.render ++ [",", "when", "arm_boundary", "=>"] ++ arm.render ++ [")"]

def contextExpr : Expr Native.Context :=
  .contextValue (.field .stateNames (.field .scanState .scan)) (.bodyEnvironment (.field .stateScalarNames (.field .scanState .scan)))
    (.nameCount (.field .stateScalarNames (.field .scanState .scan)))
    (.field .stateFirst (.field .scanState .scan)) (.field .stateAfter (.field .scanState .scan))

def bodyExpr : Expr BodyScan :=
  .bodyValue (.nameCount (.field .stateScalarNames (.field .scanState .scan))) (.initialFlow (.contextOf .scan))
    (.field .statePosition (.field .scanState .scan)) (.field .stateTarget (.field .scanState .scan))
    (.field .stateCapacity (.field .scanState .scan)) (.field .scanAssigned .scan) (.field .scanOutput .scan)

def expandExpr : Expr ScanResult :=
  .scanValue (.stateValue (.field .bodyPosition .body) (.field .contextNames .context) (.field .contextScalarNames .context)
    (.field .contextFirst .context) (.field .contextAfter .context)
    (.field .bodyTarget .body) (.field .bodyCapacity .body))
    (.field .bodyAssigned .body) (.field .bodyOutput .body)

def tokenExpr : Expr BodyScan := .bodyToken .body .token

def atStopExpr : Expr Bool :=
  .stopCase (.nonzero (.takeToken .position (.word "end")))
    (.nonzero (.takeToken .position (.word "else")))
    (.orElse (.nonzero (.takeToken .position (.word "elsif")))
      (.orElse (.nonzero (.takeToken .position (.word "else"))) (.nonzero (.takeToken .position (.word "end")))))

structure Function where
  context : Expr Native.Context
  result : Expr BodyScan
  returned : Expr ScanResult

def Function.eval (fn : Function) (calls : BodyNative.Calls) (frame : Frame)
    (bodyOfCall : ScanResult → BodyScan := Predicate.bodyOf)
    (initialFlowCall : Native.Context → ActiveFlow := Adapter.initialFlow) : ScanResult :=
  let next := {frame with context := fn.context.eval calls frame bodyOfCall initialFlowCall}
  let last := {next with result := fn.result.eval calls next bodyOfCall initialFlowCall}
  fn.returned.eval calls last bodyOfCall initialFlowCall

def Function.render (fn : Function) : List String :=
  ["context", ":", "constant", "body_context", ":="] ++ fn.context.render ++ [";",
    "result", ":", "constant", "body_scan", "(", "scan", ".", "state", ".", "scalar_names", ".", "count", ")", ":="] ++ fn.result.render ++ [";", "begin", "return"] ++
    fn.returned.render ++ [";", "end", "read_statements", ";"]

def adapterFunction : Function :=
  ⟨.contextOf .scan,
   .read .context (.bodyOf .scan) (.choose (.tokenEqual (.word "else")) (.stopValue .elseOnly) (.stopValue .endOnly)),
   .choose (.orElse (.zero (.field .bodyPosition .result)) (.not (.completed (.field .flowPath (.field .bodyFacts .result)))))
     .invalid (.expand .context .result)⟩

theorem context_eval (calls : BodyNative.Calls) (frame : Frame) :
    contextExpr.eval calls frame = contextOf frame.scan := rfl

theorem body_eval (calls : BodyNative.Calls) (frame : Frame) :
    bodyExpr.eval calls frame = bodyOf frame.scan := by
  simp only [bodyExpr, Expr.eval, Field.eval, bodyOf, Adapter.contextOf, Predicate.contextOf]
  rfl

/-- The count rendered in Body_Of_Model is exactly the count supplied by its
Initial_Flow field. The active model derives the discriminant from that field. -/
theorem body_count (calls : BodyNative.Calls) (frame : Frame) :
    (bodyExpr.eval calls frame).count = frame.scan.state.scalarNames.length := by
  rw [body_eval]
  simp only [BodyScan.count, bodyOf, ActiveFlow.initial_count, Predicate.contextOf,
    ScalarExpression.bodyEnvironment_length]

theorem expand_eval (calls : BodyNative.Calls) (frame : Frame) :
    expandExpr.eval calls frame = expand frame.context frame.body := rfl

theorem token_eval (calls : BodyNative.Calls) (frame : Frame) :
    tokenExpr.eval calls frame = bodyToken frame.text frame.body frame.token := rfl

theorem atStop_eval (calls : BodyNative.Calls) (frame : Frame) :
    atStopExpr.eval calls frame = atBodyStop frame.text frame.position frame.stop := by
  dsimp +instances only [atStopExpr, Expr.eval, tokenAfter, ShellToken.word]
  apply Bool.eq_iff_iff.mpr
  cases frame.stop <;> simp [atBodyStop]

theorem adapter_eval (calls : BodyNative.Calls) (frame : Frame) :
    adapterFunction.eval calls frame = adapterEval calls frame.text frame.scan frame.token := by
  simp only [adapterFunction, Function.eval, Expr.eval, Field.eval, adapterEval, stopOf]
  simp only [Bool.or_eq_true, decide_eq_true_eq]
  rfl

end Silver.Predicate.Adapter
