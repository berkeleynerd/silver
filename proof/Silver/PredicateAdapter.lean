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
    ScalarExpression.bodyEnvironment scan.state.scalarNames, scan.state.scalarNames.length, scan.state.arrayNames.names, scan.state.subtypeNames.hiddenCalls,
    scan.state.booleanNames, scan.state.subtypeNames.trueHidden || scan.state.hiding.trueHidden,
    scan.state.subtypeNames.falseHidden || scan.state.hiding.falseHidden, false, 0, 0,
    scan.state.pure, scan.state.hiding.integerHidden⟩

def expand (context : Native.Context) (scan : BodyScan) (original : ParserState) : ScanResult :=
  ⟨{original with
      position := scan.position
      names := context.names
      scalarNames := context.scalarNames
      booleanNames := context.booleanNames
      dynamicFirst := context.dynamicFirst
      dynamicAfter := context.dynamicAfter
      target := scan.target
      capacity := scan.capacity}, scan.assigned, scan.output⟩

def stopOf (token : ShellToken) : BodyStop :=
  if token = .word "else" then .elseOnly else .endOnly

def adapterEval (calls : BodyNative.Calls) (text : Source) (scan : ScanResult)
    (stop : ShellToken) : ScanResult :=
  let context := contextOf scan
  let result := calls.read text context (bodyOf scan) (stopOf stop) scan.state.functions scan.state.procedures
  if result.position = 0 ∨ !completed result.facts.path then invalidScan else expand context result scan.state

@[simp] theorem contextOf_model (scan : ScanResult) : (contextOf scan).model = Predicate.contextOf scan := rfl

@[simp] theorem expand_model (before : ScanResult) (scan : BodyScan) :
    expand (contextOf before) scan before.state = expandBody before.state scan := rfl

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
  ⟨valid.1.2.1, valid.1.2.2.1, ScalarExpression.bodyEnvironment_valid valid.1.2.2.2.2.2.1,
    (valid.2.baseReady valid.1.2.2.2.2.2.1.1).toContextReady,
    valid.1.2.2.2.2.2.2.1.1, valid.base.booleans, Or.inl ⟨rfl, rfl⟩, valid.bounds⟩

theorem initial_flow_valid (text : Source) (scan : ScanResult)
    (valid : OuterReadiness.ValidState text scan.state) :
    Native.ValidFlow (contextOf scan) (bodyOf scan).facts := by
  refine ⟨initialFacts_bounded _, ?_⟩
  have ready := valid.2.bodyEnvironment.initial
    (ScalarExpression.bodyEnvironment_valid valid.1.2.2.2.2.2.1)
    (initialFacts (decide (scan.state.dynamicFirst ≠ 0)))
  simpa only [bodyOf, Predicate.contextOf, contextOf, ScalarExpression.bodyEnvironment_length] using ready

theorem body_valid (text : Source) (scan : ScanResult)
    (valid : OuterReadiness.ValidState text scan.state) : BodyNative.ValidScan text (contextOf scan) (bodyOf scan) :=
  ⟨valid.1.1, ⟨valid.1.2.2.2.1, valid.1.2.2.2.2.1⟩, initial_flow_valid text scan valid⟩

theorem expand_valid (text : Source) (context : Native.Context) (scan : BodyScan)
    (cv : Native.ValidContext text context) (sv : BodyNative.ValidScan text context scan)
    (original : ParserState) (ov : Expressions.ValidState text original) :
    Expressions.ValidState text (expand context scan original).state :=
  ⟨sv.1, cv.1, cv.2.1, sv.2.1.1, sv.2.1.2, cv.2.2.1,
    ov.2.2.2.2.2.2.1, ov.2.2.2.2.2.2.2.1, cv.booleans, ov.functions,
    ov.2.2.2.2.2.2.2.2.2.2⟩

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
    (body_valid text scan sv) sv.base.functions sv.base.procedures]
  rfl

theorem model_adapter_valid (text : Source) (tv : Expressions.ValidText text)
    (scan : ScanResult) (sv : OuterReadiness.ValidState text scan.state) (stop : ShellToken) :
    OuterReadiness.ValidState text (adapterEval BodyNative.modelCalls text scan stop).state := by
  unfold adapterEval
  dsimp only
  split
  · exact invalidScan_valid text
  · exact ⟨expand_valid text _ _ (context_valid text scan sv)
      (BodyNative.model_read_valid text tv _ (context_valid text scan sv) _ _
        (body_valid text scan sv) sv.base.functions sv.base.procedures) scan.state sv.base,
      sv.ready.bodyEnvironment, sv.bounds⟩

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
  | stateArrays : Field ParserState ArrayBindings.Env
  | stateSubtypes : Field ParserState IntegerSubtypes.Environment
  | stateFunctions : Field ParserState FunctionBindings.Metadata
  | stateProcedures : Field ParserState ProcedureBindings.Metadata
  | statePure : Field ParserState Bool
  | stateHiding : Field ParserState HiddenMarks
  | hiddenTrue : Field HiddenMarks Bool
  | hiddenFalse : Field HiddenMarks Bool
  | hiddenInteger : Field HiddenMarks Bool
  | stateBooleans : Field ParserState BooleanBindings.Environment
  | contextBooleans : Field Native.Context BooleanBindings.Environment
  | subtypeTrueHidden : Field IntegerSubtypes.Environment Bool
  | subtypeFalseHidden : Field IntegerSubtypes.Environment Bool
  | subtypeHiding : Field IntegerSubtypes.Environment IntegerSubtypes.CallHiding
  | arrayMetadata : Field ArrayBindings.Env ArrayBindings.Metadata
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
  | .stateFunctions => ParserState.functions
  | .stateProcedures => ParserState.procedures
  | .statePure => ParserState.pure
  | .stateHiding => ParserState.hiding
  | .hiddenTrue => HiddenMarks.trueHidden
  | .hiddenFalse => HiddenMarks.falseHidden
  | .hiddenInteger => HiddenMarks.integerHidden
  | .stateScalarNames => ParserState.scalarNames
  | .stateArrays => ParserState.arrayNames | .arrayMetadata => ArrayBindings.Env.names
  | .stateBooleans => ParserState.booleanNames | .contextBooleans => Native.Context.booleanNames
  | .subtypeTrueHidden => IntegerSubtypes.Environment.trueHidden
  | .subtypeFalseHidden => IntegerSubtypes.Environment.falseHidden
  | .stateSubtypes => ParserState.subtypeNames | .subtypeHiding => IntegerSubtypes.Environment.hiddenCalls
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
  | .stateProcedures => "procedures"
  | .stateFunctions => "functions" | .statePure => "pure" | .stateHiding => "hiding"
  | .hiddenTrue => "true_hidden" | .hiddenFalse => "false_hidden" | .hiddenInteger => "integer_hidden"
  | .stateScalarNames | .contextScalarNames => "scalar_names"
  | .stateArrays => "array_names" | .arrayMetadata => "names"
  | .stateBooleans | .contextBooleans => "boolean_names"
  | .subtypeTrueHidden => "true_hidden" | .subtypeFalseHidden => "false_hidden"
  | .stateSubtypes => "subtype_names" | .subtypeHiding => "hidden_calls"
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
  context : Native.Context := {names := [], dynamicFirst := 0, dynamicAfter := 0}
  original : ParserState := {}
  result : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  position : Nat := 0
  token : ShellToken := .word "end"
  stop : BodyStop := .endOnly

inductive Expr : Type → Type 1
  | scan : Expr ScanResult | body : Expr BodyScan | context : Expr Native.Context
  | truth (value : Bool) : Expr Bool | number (value : Nat) : Expr Nat
  | original : Expr ParserState
  | result : Expr BodyScan | position : Expr Nat | token : Expr ShellToken | stop : Expr BodyStop
  | field (field : Field α β) (value : Expr α) : Expr β
  | zero (value : Expr Nat) : Expr Bool
  | nonzero (value : Expr Nat) : Expr Bool
  | not (value : Expr Bool) : Expr Bool
  | orElse (left right : Expr Bool) : Expr Bool
  | or (left right : Expr Bool) : Expr Bool
  | tokenEqual (token : ShellToken) : Expr Bool
  | stopValue (stop : BodyStop) : Expr BodyStop
  | choose (test : Expr Bool) (yes no : Expr α) : Expr α
  | initial (arguments : Expr Bool) : Expr PathFacts.Context
  | initialFlow (context : Expr Native.Context) : Expr ActiveFlow
  | nameCount (names : Expr ScalarExpression.Environment) : Expr Nat
  | completed (facts : Expr PathFacts.Context) : Expr Bool
  | bodyEnvironment (names : Expr ScalarExpression.Environment) : Expr ScalarExpression.Environment
  | contextValue (names : Expr BindingEnvironment) (scalarNames : Expr ScalarExpression.Environment)
      (arrays : Expr ArrayBindings.Metadata) (hiddenCalls : Expr IntegerSubtypes.CallHiding)
      (booleans : Expr BooleanBindings.Environment) (trueHidden falseHidden pure integerHidden elaborating : Expr Bool)
      (maskFirst maskAfter declarations first after : Expr Nat) : Expr Native.Context
  | bodyValue (count : Expr Nat) (facts : Expr ActiveFlow) (position target capacity : Expr Nat)
      (assigned output : Expr Bool) : Expr BodyScan
  | stateValue (original : Expr ParserState) (position : Expr Nat) (names : Expr BindingEnvironment) (scalarNames : Expr ScalarExpression.Environment)
      (booleans : Expr BooleanBindings.Environment)
      (first after target capacity : Expr Nat) : Expr ParserState
  | scanValue (state : Expr ParserState) (assigned output : Expr Bool) : Expr ScanResult
  | bodyToken (scan : Expr BodyScan) (token : Expr ShellToken) : Expr BodyScan
  | takeToken (position : Expr Nat) (token : ShellToken) : Expr Nat
  | invalid : Expr ScanResult
  | contextOf (scan : Expr ScanResult) : Expr Native.Context
  | bodyOf (scan : Expr ScanResult) : Expr BodyScan
  | expand (context : Expr Native.Context) (scan : Expr BodyScan) (original : Expr ParserState) : Expr ScanResult
  | read (context : Expr Native.Context) (scan : Expr BodyScan) (stop : Expr BodyStop) (catalog : Expr FunctionBindings.Metadata) (procedures : Expr ProcedureBindings.Metadata) : Expr BodyScan
  | stopCase (ending alternative arm returning : Expr Bool) : Expr Bool

def initialFlow (context : Native.Context) : ActiveFlow :=
  ActiveFlow.initial context.scalarNames (initialFacts (decide (context.dynamicFirst ≠ 0)))

/-- The native Take_Token operation uses Spelling/Is_Word_Token for every
Token_Kind, including the literal and capacity enum values. -/
def takeTokenModel (text : Source) (position : Nat) (token : ShellToken) : Nat :=
  fixedAfter text position (Expressions.spelling token) (Expressions.isWord token)

/-- Semantic body-token calls use fixed words or symbols. The native token
operation above remains defined on the complete checked enumeration. -/
def FixedToken : ShellToken → Prop
  | .fixed _ _ => True
  | _ => False

theorem takeTokenModel_fixed (text : Source) (position : Nat) (token : ShellToken)
    (fixed : FixedToken token) : takeTokenModel text position token = tokenAfter text position token := by
  cases token <;> simp_all [FixedToken, takeTokenModel, tokenAfter, Expressions.spelling, Expressions.isWord]

def Expr.eval (calls : BodyNative.Calls) (frame : Frame)
    (bodyOfCall : ScanResult → BodyScan := Predicate.bodyOf)
    (initialFlowCall : Native.Context → ActiveFlow := Adapter.initialFlow)
    (takeTokenCall : Source → Nat → ShellToken → Nat := takeTokenModel) : Expr α → α
  | .truth value => value | .number value => value
  | .scan => frame.scan | .body => frame.body | .context => frame.context | .result => frame.result
  | .original => frame.original
  | .position => frame.position | .token => frame.token | .stop => frame.stop
  | .field projection value => projection.eval (value.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .zero value => decide (value.eval calls frame bodyOfCall initialFlowCall takeTokenCall = 0)
  | .nonzero value => decide (value.eval calls frame bodyOfCall initialFlowCall takeTokenCall ≠ 0)
  | .not value => !(value.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .orElse left right | .or left right => left.eval calls frame bodyOfCall initialFlowCall takeTokenCall || right.eval calls frame bodyOfCall initialFlowCall takeTokenCall
  | .tokenEqual tok => decide (frame.token = tok)
  | .stopValue boundary => boundary
  | .choose test yes no => if test.eval calls frame bodyOfCall initialFlowCall takeTokenCall then yes.eval calls frame bodyOfCall initialFlowCall takeTokenCall else no.eval calls frame bodyOfCall initialFlowCall takeTokenCall
  | .initial arguments => (PathFacts.Native.initial (arguments.eval calls frame bodyOfCall initialFlowCall takeTokenCall)).model
  | .initialFlow ctx => initialFlowCall (ctx.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .nameCount names => (names.eval calls frame bodyOfCall initialFlowCall takeTokenCall).length
  | .completed facts => Predicate.completed (facts.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .bodyEnvironment names => ScalarExpression.bodyEnvironment (names.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .contextValue names scalarNames arrayNames hiddenCalls booleans trueHidden falseHidden pure integerHidden elaborating maskFirst maskAfter declarations first after =>
      ⟨names.eval calls frame bodyOfCall initialFlowCall takeTokenCall, first.eval calls frame bodyOfCall initialFlowCall takeTokenCall, after.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        scalarNames.eval calls frame bodyOfCall initialFlowCall takeTokenCall, declarations.eval calls frame bodyOfCall initialFlowCall takeTokenCall, arrayNames.eval calls frame bodyOfCall initialFlowCall takeTokenCall, hiddenCalls.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        booleans.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        trueHidden.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        falseHidden.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        elaborating.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        maskFirst.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        maskAfter.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        pure.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        integerHidden.eval calls frame bodyOfCall initialFlowCall takeTokenCall⟩
  | .bodyValue _ facts pos target capacity assigned output =>
      ⟨pos.eval calls frame bodyOfCall initialFlowCall takeTokenCall, target.eval calls frame bodyOfCall initialFlowCall takeTokenCall, capacity.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        facts.eval calls frame bodyOfCall initialFlowCall takeTokenCall, assigned.eval calls frame bodyOfCall initialFlowCall takeTokenCall, output.eval calls frame bodyOfCall initialFlowCall takeTokenCall⟩
  | .stateValue originalExpr pos names scalarNames booleans first after target capacity =>
      {originalExpr.eval calls frame bodyOfCall initialFlowCall takeTokenCall with
        position := pos.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        names := names.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        scalarNames := scalarNames.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        booleanNames := booleans.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        dynamicFirst := first.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        dynamicAfter := after.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        target := target.eval calls frame bodyOfCall initialFlowCall takeTokenCall,
        capacity := capacity.eval calls frame bodyOfCall initialFlowCall takeTokenCall}
  | .scanValue state assigned output => ⟨state.eval calls frame bodyOfCall initialFlowCall takeTokenCall, assigned.eval calls frame bodyOfCall initialFlowCall takeTokenCall, output.eval calls frame bodyOfCall initialFlowCall takeTokenCall⟩
  | .bodyToken input tok =>
      let scan := input.eval calls frame bodyOfCall initialFlowCall takeTokenCall
      {scan with position := takeTokenCall frame.text scan.position (tok.eval calls frame bodyOfCall initialFlowCall takeTokenCall)}
  | .takeToken pos tok => takeTokenCall frame.text (pos.eval calls frame bodyOfCall initialFlowCall takeTokenCall) tok
  | .invalid => invalidScan
  | .contextOf input => Adapter.contextOf (input.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .bodyOf input => bodyOfCall (input.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .expand ctx input originalExpr => Adapter.expand (ctx.eval calls frame bodyOfCall initialFlowCall takeTokenCall) (input.eval calls frame bodyOfCall initialFlowCall takeTokenCall) (originalExpr.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .read ctx input boundary catalog procedures => calls.read frame.text (ctx.eval calls frame bodyOfCall initialFlowCall takeTokenCall) (input.eval calls frame bodyOfCall initialFlowCall takeTokenCall) (boundary.eval calls frame bodyOfCall initialFlowCall takeTokenCall) (catalog.eval calls frame bodyOfCall initialFlowCall takeTokenCall) (procedures.eval calls frame bodyOfCall initialFlowCall takeTokenCall)
  | .stopCase ending alternative arm returning => match frame.stop with
      | .endOnly => ending.eval calls frame bodyOfCall initialFlowCall takeTokenCall | .elseOnly => alternative.eval calls frame bodyOfCall initialFlowCall takeTokenCall | .arm => arm.eval calls frame bodyOfCall initialFlowCall takeTokenCall
      | .returnOnly => returning.eval calls frame bodyOfCall initialFlowCall takeTokenCall

def record (fields : List (String × List String)) : List String :=
  ["("] ++ List.intercalate [","] (fields.map fun (name, value) => [name, "=>"] ++ value) ++ [")"]

def Expr.render : Expr α → List String
  | .truth value => [if value then "true" else "false"] | .number value => [toString value]
  | .scan => ["scan"] | .body => ["scan"] | .context => ["context"] | .result => ["result"]
  | .original => ["original"]
  | .position => ["position"] | .token => ["token"] | .stop => ["stop"]
  | .field projection value => value.render ++ [".", projection.name]
  | .zero value => value.render ++ ["=", "0"]
  | .nonzero value => value.render ++ ["/=", "0"]
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .or left right => left.render ++ ["or"] ++ right.render
  | .tokenEqual tok => ["stop", "="] ++ [Expressions.tokenName tok]
  | .stopValue boundary => [BodyNative.stopName boundary]
  | .choose test yes no => ["(", "if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render ++ [")"]
  | .initial arguments => ["paths", "."] ++ Expressions.call "initial" [arguments.render]
  | .initialFlow ctx => Expressions.call "initial_flow" [ctx.render]
  | .nameCount names => names.render ++ [".", "count"]
  | .completed facts => ["paths", "."] ++ Expressions.call "completed" [facts.render]
  | .bodyEnvironment names => ["scalar_expressions", "."] ++ Expressions.call "body_environment" [names.render]
  | .contextValue names scalarNames arrayNames hiddenCalls booleans trueHidden falseHidden pure integerHidden elaborating maskFirst maskAfter declarations first after => record [("names", names.render),
      ("scalar_names", scalarNames.render), ("array_names", arrayNames.render), ("subtype_hiding", hiddenCalls.render), ("boolean_names", booleans.render),
      ("true_hidden", trueHidden.render), ("false_hidden", falseHidden.render), ("pure", pure.render), ("integer_hidden", integerHidden.render), ("elaborating", elaborating.render),
      ("mask_first", maskFirst.render), ("mask_after", maskAfter.render), ("declaration_count", declarations.render),
      ("dynamic_first", first.render), ("dynamic_after", after.render)]
  | .bodyValue count facts pos target capacity assigned output => record [("count", count.render), ("facts", facts.render),
      ("position", pos.render), ("target", target.render), ("capacity", capacity.render),
      ("assigned", assigned.render), ("output", output.render)]
  | .stateValue originalExpr pos names scalarNames booleans first after target capacity =>
      ["("] ++ originalExpr.render ++ ["with", "delta"] ++
      List.intercalate [","] ([("position", pos.render), ("names", names.render),
        ("scalar_names", scalarNames.render), ("boolean_names", booleans.render),
        ("dynamic_first", first.render), ("dynamic_after", after.render),
        ("target", target.render), ("capacity", capacity.render)].map fun (name, value) =>
          [name, "=>"] ++ value) ++ [")"]
  | .scanValue state assigned output => record [("state", state.render), ("assigned", assigned.render), ("output", output.render)]
  | .bodyToken input tok => ["("] ++ input.render ++ ["with", "delta", "position", "=>"] ++
      Expressions.call "take_token" [["text"], input.render ++ [".", "position"], tok.render] ++ [")"]
  | .takeToken pos tok => Expressions.call "take_token" [["text"], pos.render, [Expressions.tokenName tok]]
  | .invalid => ["invalid_scan"]
  | .contextOf input => Expressions.call "context_of" [input.render]
  | .bodyOf input => Expressions.call "body_of" [input.render]
  | .expand ctx input originalExpr => Expressions.call "expand_body" [ctx.render, input.render, originalExpr.render]
  | .read ctx input boundary catalog procedures => Expressions.call "read_body" [["text"], ctx.render, input.render, boundary.render, catalog.render, procedures.render]
  | .stopCase ending alternative arm returning => ["(", "case", "stop", "is", "when", "return_only", "=>"] ++ returning.render ++
      [",", "when", "end_only", "=>"] ++ ending.render ++
      [",", "when", "else_only", "=>"] ++ alternative.render ++ [",", "when", "arm_boundary", "=>"] ++ arm.render ++ [")"]

def contextExpr : Expr Native.Context :=
  .contextValue (.field .stateNames (.field .scanState .scan)) (.bodyEnvironment (.field .stateScalarNames (.field .scanState .scan)))
    (.field .arrayMetadata (.field .stateArrays (.field .scanState .scan)))
    (.field .subtypeHiding (.field .stateSubtypes (.field .scanState .scan)))
    (.field .stateBooleans (.field .scanState .scan))
    (.or (.field .subtypeTrueHidden (.field .stateSubtypes (.field .scanState .scan)))
      (.field .hiddenTrue (.field .stateHiding (.field .scanState .scan))))
    (.or (.field .subtypeFalseHidden (.field .stateSubtypes (.field .scanState .scan)))
      (.field .hiddenFalse (.field .stateHiding (.field .scanState .scan))))
    (.field .statePure (.field .scanState .scan))
    (.field .hiddenInteger (.field .stateHiding (.field .scanState .scan)))
    (.truth false) (.number 0) (.number 0)
    (.nameCount (.field .stateScalarNames (.field .scanState .scan)))
    (.field .stateFirst (.field .scanState .scan)) (.field .stateAfter (.field .scanState .scan))

def bodyExpr : Expr BodyScan :=
  .bodyValue (.nameCount (.field .stateScalarNames (.field .scanState .scan))) (.initialFlow (.contextOf .scan))
    (.field .statePosition (.field .scanState .scan)) (.field .stateTarget (.field .scanState .scan))
    (.field .stateCapacity (.field .scanState .scan)) (.field .scanAssigned .scan) (.field .scanOutput .scan)

def expandExpr : Expr ScanResult :=
  .scanValue (.stateValue .original (.field .bodyPosition .body) (.field .contextNames .context) (.field .contextScalarNames .context) (.field .contextBooleans .context)
    (.field .contextFirst .context) (.field .contextAfter .context)
    (.field .bodyTarget .body) (.field .bodyCapacity .body))
    (.field .bodyAssigned .body) (.field .bodyOutput .body)

def tokenExpr : Expr BodyScan := .bodyToken .body .token

def atStopExpr : Expr Bool :=
  .stopCase (.nonzero (.takeToken .position (.word "end")))
    (.nonzero (.takeToken .position (.word "else")))
    (.orElse (.nonzero (.takeToken .position (.word "elsif")))
      (.orElse (.nonzero (.takeToken .position (.word "else"))) (.nonzero (.takeToken .position (.word "end")))))
    (.nonzero (.takeToken .position (.word "return")))

structure Function where
  context : Expr Native.Context
  result : Expr BodyScan
  returned : Expr ScanResult

def Function.eval (fn : Function) (calls : BodyNative.Calls) (frame : Frame)
    (bodyOfCall : ScanResult → BodyScan := Predicate.bodyOf)
    (initialFlowCall : Native.Context → ActiveFlow := Adapter.initialFlow)
    (takeTokenCall : Source → Nat → ShellToken → Nat := takeTokenModel) : ScanResult :=
  let next := {frame with context := fn.context.eval calls frame bodyOfCall initialFlowCall takeTokenCall}
  let last := {next with result := fn.result.eval calls next bodyOfCall initialFlowCall takeTokenCall}
  fn.returned.eval calls last bodyOfCall initialFlowCall takeTokenCall

def Function.render (fn : Function) : List String :=
  ["context", ":", "constant", "body_context", ":="] ++ fn.context.render ++ [";",
    "result", ":", "constant", "body_scan", "(", "scan", ".", "state", ".", "scalar_names", ".", "count", ")", ":="] ++ fn.result.render ++ [";", "begin", "return"] ++
    fn.returned.render ++ [";", "end", "read_statements", ";"]

def adapterFunction : Function :=
  ⟨.contextOf .scan,
   .read .context (.bodyOf .scan) (.choose (.tokenEqual (.word "else")) (.stopValue .elseOnly) (.stopValue .endOnly)) (.field .stateFunctions (.field .scanState .scan)) (.field .stateProcedures (.field .scanState .scan)),
   .choose (.orElse (.zero (.field .bodyPosition .result)) (.not (.completed (.field .flowPath (.field .bodyFacts .result)))))
     .invalid (.expand .context .result (.field .scanState .scan))⟩

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
    expandExpr.eval calls frame = expand frame.context frame.body frame.original := rfl

theorem token_eval (calls : BodyNative.Calls) (frame : Frame) (fixed : FixedToken frame.token) :
    tokenExpr.eval calls frame = bodyToken frame.text frame.body frame.token := by
  change {frame.body with position := takeTokenModel frame.text frame.body.position frame.token} = _
  rw [takeTokenModel_fixed frame.text frame.body.position frame.token fixed]
  rfl

theorem atStop_eval (calls : BodyNative.Calls) (frame : Frame) :
    atStopExpr.eval calls frame = atBodyStop frame.text frame.position frame.stop := by
  dsimp +instances only [atStopExpr, Expr.eval, takeTokenModel, Expressions.spelling, Expressions.isWord, ShellToken.word]
  apply Bool.eq_iff_iff.mpr
  cases frame.stop <;> simp [atBodyStop]

theorem adapter_eval (calls : BodyNative.Calls) (frame : Frame) :
    adapterFunction.eval calls frame = adapterEval calls frame.text frame.scan frame.token := by
  simp only [adapterFunction, Function.eval, Expr.eval, Field.eval, adapterEval, stopOf]
  simp only [Bool.or_eq_true, decide_eq_true_eq]
  rfl

end Silver.Predicate.Adapter
