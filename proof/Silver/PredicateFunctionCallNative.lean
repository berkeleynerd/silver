module

public import Silver.PredicateBodyScanner
public import Silver.PredicateNativeState
public import Silver.PredicateAssociationAdmission

@[expose] public section

/-! Typed trees for scalar-call parsing. Recursive calls and inherited readers
remain explicit imports until the source equations and native call domains are
applied. Every actual uses the same incoming flow. -/
namespace Silver.Predicate.FunctionCallNative
open Compose FunctionBindings

@[ext] structure Imports where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  namesLookup : Source → BindingEnvironment → Nat → Nat → Nat
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  booleanLookup : Source → BooleanBindings.Environment → Nat → Nat → Nat
  arrayLookup : Source → ArrayBindings.Metadata → Nat → Nat → Nat
  functionLookup : Source → Metadata → Nat → Nat → Nat
  token : Source → Nat → ShellToken → Nat
  condition : Source → Native.Context → Nat → ActiveFlow → ConditionResult
  scalar : Source → Native.Context → Nat → ActiveFlow → ScalarExpression.Result
  isEmpty : Integer.Interval → Bool
  included : Integer.Interval → Integer.Interval → Bool
  invalid : BodyScan → BodyScan
  association : Source → Nat → Metadata → Nat → Nat → Nat → Bool → ActualAssociation
  markFormal : FormalSet → Nat → FormalSet

@[ext] structure Calls where
  actual : Source → Native.Context → Nat → ActiveFlow → Formal → Nat
  actuals : Source → Native.Context → Nat → ActiveFlow → Metadata → Nat → Nat → Nat
  actualsTail : Source → Native.Context → Nat → ActiveFlow → Metadata → Nat → Nat → Nat → Bool → FormalSet → Nat
  callee : Source → Native.Context → Nat → Metadata → Nat
  callModel : Source → Native.Context → Nat → ActiveFlow → Metadata → CallResult
  readCall : Source → Native.Context → Nat → ActiveFlow → Metadata → CallResult
  scalarTarget : Source → Native.Context → Nat → Nat
  booleanTarget : Source → Native.Context → Nat → Nat
  assignmentResult : Native.Context → BodyScan → Nat → Nat → CallResult → BodyScan

structure Frame where
  text : Source := []
  context : Native.Context := {names := [], dynamicFirst := 0, dynamicAfter := 0}
  position : Nat := 0
  cursor : Nat := 0
  index : Nat := 0
  facts : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  catalog : Metadata := {}
  parameter : Formal := emptyFormal
  scan : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  first : Nat := 0
  last : Nat := 0
  ordinal : Nat := 0
  named : Bool := false
  seen : FormalSet := noFormals
  association : ActualAssociation := invalidAssociation
  after : Nat := 0
  callee : Nat := 0
  start : Nat := 0
  scalar : Nat := 0
  flag : Nat := 0
  item : Signature := emptySignature
  value : ScalarExpression.Result := ScalarExpression.invalid
  called : CallResult := invalidCall
  intervalValue : Integer.Interval := .empty
  intervalBounds : Integer.Interval := .empty

inductive Expr : Type → Type 1
  | position : Expr Nat
  | loopCursor : Expr Nat
  | loopIndex : Expr Nat
  | scanPosition : Expr Nat
  | first : Expr Nat
  | last : Expr Nat
  | ordinal : Expr Nat
  | named : Expr Bool
  | seen : Expr FormalSet
  | associationValue : Expr ActualAssociation
  | associationFormal : Expr ActualAssociation → Expr Nat
  | associationPayload : Expr ActualAssociation → Expr Nat
  | associationNamed : Expr ActualAssociation → Expr Bool
  | noFormals : Expr FormalSet
  | seenAt : Expr FormalSet → Expr Nat → Expr Bool
  | markSeen : Expr FormalSet → Expr Nat → Expr FormalSet
  | truth : Bool → Expr Bool
  | after : Expr Nat
  | callee : Expr Nat
  | start : Expr Nat
  | scalar : Expr Nat
  | flag : Expr Nat
  | intervalValue : Expr Integer.Interval
  | intervalBounds : Expr Integer.Interval
  | lower : Expr Integer.Interval → Expr Int
  | upper : Expr Integer.Interval → Expr Int
  | geInt : Expr Int → Expr Int → Expr Bool
  | leInt : Expr Int → Expr Int → Expr Bool
  | value : Expr ScalarExpression.Result
  | called : Expr CallResult
  | parameter : Expr Formal
  | item : Expr Signature
  | number : Nat → Expr Nat
  | kind : ScalarKind → Expr ScalarKind
  | formalKind : Expr Formal → Expr ScalarKind
  | formalBounds : Expr Formal → Expr Integer.Interval
  | formalFirst : Expr Signature → Expr Nat
  | formalCount : Expr Signature → Expr Nat
  | resultKind : Expr Signature → Expr ScalarKind
  | resultBounds : Expr Signature → Expr Integer.Interval
  | valueAfter : Expr ScalarExpression.Result → Expr Nat
  | valueBounds : Expr ScalarExpression.Result → Expr Integer.Interval
  | callAfter : Expr CallResult → Expr Nat
  | callKind : Expr CallResult → Expr ScalarKind
  | callBounds : Expr CallResult → Expr Integer.Interval
  | parameterAt : Expr Nat → Expr Formal
  | signatureAt : Expr Nat → Expr Signature
  | scalarMutable : Expr Nat → Expr Bool
  | booleanMutable : Expr Nat → Expr Bool
  | declaredBounds : Expr Nat → Expr Integer.Interval
  | skip : Expr Nat → Expr Nat
  | nameAfter : Expr Nat → Expr Nat
  | namesLookup : Expr Nat → Expr Nat → Expr Nat
  | scalarLookup : Expr Nat → Expr Nat → Expr Nat
  | booleanLookup : Expr Nat → Expr Nat → Expr Nat
  | arrayLookup : Expr Nat → Expr Nat → Expr Nat
  | functionLookup : Expr Nat → Expr Nat → Expr Nat
  | token : Expr Nat → ShellToken → Expr Nat
  | readScalar : Expr Nat → Expr ScalarExpression.Result
  | readConditionAfter : Expr Nat → Expr Nat
  | actual : Expr Nat → Expr Formal → Expr Nat
  | actuals : Expr Nat → Expr Nat → Expr Nat → Expr Nat
  | actualsTail : Expr Nat → Expr Nat → Expr Nat → Expr Nat → Expr Bool → Expr FormalSet → Expr Nat
  | association : Expr Nat → Expr Nat → Expr Nat → Expr Nat → Expr Bool → Expr ActualAssociation
  | calleeAt : Expr Nat → Expr Nat
  | callModel : Expr Nat → Expr CallResult
  | readCall : Expr Nat → Expr CallResult
  | scalarTarget : Expr Nat → Expr Nat
  | booleanTarget : Expr Nat → Expr Nat
  | assignmentResult : Expr Nat → Expr Nat → Expr CallResult → Expr BodyScan
  | add : Expr Nat → Expr Nat → Expr Nat
  | sub : Expr Nat → Expr Nat → Expr Nat
  | eq : Expr Nat → Expr Nat → Expr Bool
  | ne : Expr Nat → Expr Nat → Expr Bool
  | le : Expr Nat → Expr Nat → Expr Bool
  | kindEq : Expr ScalarKind → Expr ScalarKind → Expr Bool
  | kindNe : Expr ScalarKind → Expr ScalarKind → Expr Bool
  | empty : Expr Integer.Interval → Expr Bool
  | included : Expr Integer.Interval → Expr Integer.Interval → Expr Bool
  | not : Expr Bool → Expr Bool
  | andThen : Expr Bool → Expr Bool → Expr Bool
  | orElse : Expr Bool → Expr Bool → Expr Bool
  | invalidCall : Expr CallResult
  | makeCall : Expr Nat → Expr ScalarKind → Expr Integer.Interval → Expr CallResult
  | invalidBody : Expr BodyScan
  | assignedInteger : Expr BodyScan
  | assignedBoolean : Expr BodyScan
  | group : Expr α → Expr α
  | ite : Expr Bool → Expr α → Expr α → Expr α
  | elsif : Expr Bool → Expr α → Expr α → Expr α
  | locals : Expr α → Expr α
  | letFirst : Expr Nat → Expr α → Expr α
  | letAfter : Expr Nat → Expr α → Expr α
  | letCallee : Expr Nat → Expr α → Expr α
  | letStart : Expr Nat → Expr α → Expr α
  | letItem : Expr Signature → Expr α → Expr α
  | letValue : Expr ScalarExpression.Result → Expr α → Expr α
  | letAssociation : Expr ActualAssociation → Expr α → Expr α

def Expr.eval (imports : Imports) (calls : Calls) (frame : Frame) : Expr α → α
  | .loopCursor => frame.cursor | .loopIndex => frame.index
  | .position => frame.position | .scanPosition => frame.scan.position
  | .first => frame.first | .last => frame.last | .after => frame.after
  | .ordinal => frame.ordinal | .named => frame.named | .seen => frame.seen
  | .associationValue => frame.association
  | .associationFormal node => (node.eval imports calls frame).formal
  | .associationPayload node => (node.eval imports calls frame).payloadFirst
  | .associationNamed node => (node.eval imports calls frame).named
  | .noFormals => Predicate.noFormals
  | .seenAt setExpr formalExpr => (setExpr.eval imports calls frame) (formalExpr.eval imports calls frame)
  | .markSeen setExpr formalExpr => imports.markFormal (setExpr.eval imports calls frame) (formalExpr.eval imports calls frame)
  | .truth literal => literal
  | .callee => frame.callee | .start => frame.start | .scalar => frame.scalar | .flag => frame.flag
  | .intervalValue => frame.intervalValue | .intervalBounds => frame.intervalBounds
  | .lower node => (node.eval imports calls frame).lower
  | .upper node => (node.eval imports calls frame).upper
  | .geInt left right => decide (left.eval imports calls frame ≥ right.eval imports calls frame)
  | .leInt left right => decide (left.eval imports calls frame ≤ right.eval imports calls frame)
  | .value => frame.value | .called => frame.called | .parameter => frame.parameter | .item => frame.item
  | .number node => node | .kind node => node
  | .formalKind node => (node.eval imports calls frame).kind
  | .formalBounds node => (node.eval imports calls frame).bounds
  | .formalFirst node => (node.eval imports calls frame).formalFirst
  | .formalCount node => (node.eval imports calls frame).count
  | .resultKind node => (node.eval imports calls frame).resultKind
  | .resultBounds node => (node.eval imports calls frame).resultBounds
  | .valueAfter node => (node.eval imports calls frame).after
  | .valueBounds node => (node.eval imports calls frame).bounds
  | .callAfter node => (node.eval imports calls frame).after
  | .callKind node => (node.eval imports calls frame).kind
  | .callBounds node => (node.eval imports calls frame).bounds
  | .parameterAt index => FunctionBindings.parameter frame.catalog (index.eval imports calls frame)
  | .signatureAt index => FunctionBindings.signature frame.catalog (index.eval imports calls frame)
  | .scalarMutable index => (ScalarExpression.binding frame.context.scalarNames (index.eval imports calls frame)).mutable
  | .booleanMutable index => (BooleanBindings.binding frame.context.booleanNames (index.eval imports calls frame)).mutable
  | .declaredBounds index => (ScalarExpression.binding frame.context.scalarNames (index.eval imports calls frame)).declaredBounds
  | .skip cursor => imports.skip frame.text (cursor.eval imports calls frame)
  | .nameAfter cursor => imports.nameAfter frame.text (cursor.eval imports calls frame)
  | .namesLookup startExpr endExpr => imports.namesLookup frame.text frame.context.names (startExpr.eval imports calls frame) (endExpr.eval imports calls frame)
  | .scalarLookup startExpr endExpr => imports.scalarLookup frame.text frame.context.scalarNames (startExpr.eval imports calls frame) (endExpr.eval imports calls frame)
  | .booleanLookup startExpr endExpr => imports.booleanLookup frame.text frame.context.booleanNames (startExpr.eval imports calls frame) (endExpr.eval imports calls frame)
  | .arrayLookup startExpr endExpr => imports.arrayLookup frame.text frame.context.arrayNames (startExpr.eval imports calls frame) (endExpr.eval imports calls frame)
  | .functionLookup startExpr endExpr => imports.functionLookup frame.text frame.catalog (startExpr.eval imports calls frame) (endExpr.eval imports calls frame)
  | .token cursor tokenValue => imports.token frame.text (cursor.eval imports calls frame) tokenValue
  | .readScalar cursor => imports.scalar frame.text frame.context (cursor.eval imports calls frame) frame.facts
  | .readConditionAfter cursor => (imports.condition frame.text frame.context (cursor.eval imports calls frame) frame.facts).after
  | .actual cursor formalExpr => calls.actual frame.text frame.context (cursor.eval imports calls frame) frame.facts (formalExpr.eval imports calls frame)
  | .actuals cursor startExpr endExpr => calls.actuals frame.text frame.context (cursor.eval imports calls frame) frame.facts frame.catalog (startExpr.eval imports calls frame) (endExpr.eval imports calls frame)
  | .actualsTail cursor firstExpr lastExpr ordinalExpr namedExpr seenExpr => calls.actualsTail frame.text frame.context
      (cursor.eval imports calls frame) frame.facts frame.catalog (firstExpr.eval imports calls frame)
      (lastExpr.eval imports calls frame) (ordinalExpr.eval imports calls frame) (namedExpr.eval imports calls frame) (seenExpr.eval imports calls frame)
  | .association cursor firstExpr lastExpr ordinalExpr namedExpr => imports.association frame.text
      (cursor.eval imports calls frame) frame.catalog (firstExpr.eval imports calls frame)
      (lastExpr.eval imports calls frame) (ordinalExpr.eval imports calls frame) (namedExpr.eval imports calls frame)
  | .calleeAt cursor => calls.callee frame.text frame.context (cursor.eval imports calls frame) frame.catalog
  | .callModel cursor => calls.callModel frame.text frame.context (cursor.eval imports calls frame) frame.scan.facts frame.catalog
  | .readCall cursor => calls.readCall frame.text frame.context (cursor.eval imports calls frame) frame.scan.facts frame.catalog
  | .scalarTarget cursor => calls.scalarTarget frame.text frame.context (cursor.eval imports calls frame)
  | .booleanTarget cursor => calls.booleanTarget frame.text frame.context (cursor.eval imports calls frame)
  | .assignmentResult scalarExpr flagExpr node => calls.assignmentResult frame.context frame.scan (scalarExpr.eval imports calls frame) (flagExpr.eval imports calls frame) (node.eval imports calls frame)
  | .add left right => left.eval imports calls frame + right.eval imports calls frame
  | .sub left right => left.eval imports calls frame - right.eval imports calls frame
  | .eq left right => decide (left.eval imports calls frame = right.eval imports calls frame)
  | .ne left right => decide (left.eval imports calls frame ≠ right.eval imports calls frame)
  | .le left right => decide (left.eval imports calls frame ≤ right.eval imports calls frame)
  | .kindEq left right => decide (left.eval imports calls frame = right.eval imports calls frame)
  | .kindNe left right => decide (left.eval imports calls frame ≠ right.eval imports calls frame)
  | .empty node => imports.isEmpty (node.eval imports calls frame)
  | .included left right => imports.included (left.eval imports calls frame) (right.eval imports calls frame)
  | .not node => !node.eval imports calls frame
  | .andThen left right => left.eval imports calls frame && right.eval imports calls frame
  | .orElse left right => left.eval imports calls frame || right.eval imports calls frame
  | .invalidCall => Predicate.invalidCall
  | .makeCall endExpr kindExpr bounds => ⟨endExpr.eval imports calls frame, kindExpr.eval imports calls frame, bounds.eval imports calls frame⟩
  | .invalidBody => imports.invalid frame.scan
  | .assignedInteger =>
      {frame.scan with
        position := frame.called.after
        assigned := true
        facts := frame.scan.facts.replace frame.scalar frame.called.bounds}
  | .assignedBoolean => {frame.scan with position := frame.called.after, assigned := true}
  | .group node | .locals node => node.eval imports calls frame
  | .ite condition yes no | .elsif condition yes no => if condition.eval imports calls frame then yes.eval imports calls frame else no.eval imports calls frame
  | .letFirst node body => body.eval imports calls {frame with first := node.eval imports calls frame}
  | .letAfter node body => body.eval imports calls {frame with after := node.eval imports calls frame}
  | .letCallee node body => body.eval imports calls {frame with callee := node.eval imports calls frame}
  | .letStart node body => body.eval imports calls {frame with start := node.eval imports calls frame}
  | .letItem node body => body.eval imports calls {frame with item := node.eval imports calls frame}
  | .letValue node body => body.eval imports calls {frame with value := node.eval imports calls frame}
  | .letAssociation node body => body.eval imports calls {frame with association := node.eval imports calls frame}

def call (name : List String) (arguments : List (List String)) : List String :=
  name ++ ["("] ++ (arguments.intersperse [","]).flatten ++ [")"]

def Expr.local : Expr α → Bool
  | .letFirst _ _ | .letAfter _ _ | .letCallee _ _ | .letStart _ _ | .letItem _ _ | .letValue _ _ | .letAssociation _ _ => true
  | _ => false

def localRender (name : String) (typeName node body : List String) (more : Bool) : List String :=
  [name, ":", "constant"] ++ typeName ++ [":="] ++ node ++ [";"] ++ (if more then [] else ["begin"]) ++ body

def Expr.render : Expr α → List String
  | .loopCursor => ["cursor"] | .loopIndex => ["index"]
  | .position => ["position"] | .scanPosition => ["scan", ".", "position"]
  | .first => ["first"] | .last => ["last"] | .after => ["after"] | .callee => ["callee"]
  | .start => ["start"] | .scalar => ["scalar"] | .flag => ["flag"]
  | .ordinal => ["ordinal"] | .named => ["named"] | .seen => ["seen"]
  | .associationValue => ["association"]
  | .associationFormal node => node.render ++ [".", "formal"]
  | .associationPayload node => node.render ++ [".", "payload_first"]
  | .associationNamed node => node.render ++ [".", "named"]
  | .noFormals => ["no_formals"]
  | .seenAt setExpr formalExpr => setExpr.render ++ ["("] ++ formalExpr.render ++ [")"]
  | .markSeen setExpr formalExpr => call ["mark_formal"] [setExpr.render, formalExpr.render]
  | .truth literal => [if literal then "true" else "false"]
  | .intervalValue => ["value"] | .intervalBounds => ["bounds"]
  | .lower node => node.render ++ [".", "lower"]
  | .upper node => node.render ++ [".", "upper"]
  | .geInt left right => left.render ++ [">="] ++ right.render
  | .leInt left right => left.render ++ ["<="] ++ right.render
  | .value | .called => ["value"] | .parameter => ["parameter"] | .item => ["item"]
  | .number node => [toString node]
  | .kind node => ["functions", ".", if node = .integer then "integer_kind" else "boolean_kind"]
  | .formalKind node | .callKind node => node.render ++ [".", "kind"]
  | .formalBounds node | .valueBounds node | .callBounds node => node.render ++ [".", "bounds"]
  | .formalFirst node => node.render ++ [".", "formal_first"]
  | .formalCount node => node.render ++ [".", "count"]
  | .resultKind node => node.render ++ [".", "result_kind"]
  | .resultBounds node => node.render ++ [".", "result_bounds"]
  | .valueAfter node | .callAfter node => node.render ++ [".", "after"]
  | .parameterAt index => ["catalog", ".", "parameters", "("] ++ index.render ++ [")"]
  | .signatureAt index => ["catalog", ".", "items", "("] ++ index.render ++ [")"]
  | .scalarMutable index => ["context", ".", "scalar_names", ".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .booleanMutable index => ["context", ".", "boolean_names", ".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .declaredBounds index => ["context", ".", "scalar_names", ".", "items", "("] ++ index.render ++ [")", ".", "declared_bounds"]
  | .skip cursor => call ["skip_at"] [["text"], cursor.render]
  | .nameAfter cursor => call ["name_after"] [["text"], cursor.render]
  | .namesLookup startExpr endExpr => call ["lookup_name"] [["text"], ["context", ".", "names"], startExpr.render, endExpr.render]
  | .scalarLookup startExpr endExpr => call ["scalar_expressions", ".", "lookup"] [["text"], ["context", ".", "scalar_names"], startExpr.render, endExpr.render]
  | .booleanLookup startExpr endExpr => call ["lookup_boolean"] [["text"], ["context", ".", "boolean_names"], startExpr.render, endExpr.render]
  | .arrayLookup startExpr endExpr => call ["array_bindings", ".", "lookup"] [["text"], ["context", ".", "array_names"], startExpr.render, endExpr.render]
  | .functionLookup startExpr endExpr => call ["functions", ".", "lookup"] [["text"], ["catalog"], startExpr.render, endExpr.render]
  | .token cursor tokenValue => call ["take_token"] [["text"], cursor.render, [Compose.Expressions.tokenName tokenValue]]
  | .readScalar cursor => call ["read_scalar_in_flow"] [["text"], ["context"], cursor.render, ["facts"]]
  | .readConditionAfter cursor => call ["condition_model"] [["text"], ["context"], cursor.render, ["facts"]] ++ [".", "after"]
  | .actual cursor formalExpr => call ["actual_model"] [["text"], ["context"], cursor.render, ["facts"], formalExpr.render]
  | .actuals cursor startExpr endExpr => call ["actuals_model"] [["text"], ["context"], cursor.render, ["facts"], ["catalog"], startExpr.render, endExpr.render]
  | .actualsTail cursor firstExpr lastExpr ordinalExpr namedExpr seenExpr => call ["function_actuals_tail_model"]
      [["text"], ["context"], cursor.render, ["facts"], ["catalog"], firstExpr.render, lastExpr.render, ordinalExpr.render, namedExpr.render, seenExpr.render]
  | .association cursor firstExpr lastExpr ordinalExpr namedExpr => call ["function_association"]
      [["text"], cursor.render, ["catalog"], firstExpr.render, lastExpr.render, ordinalExpr.render, namedExpr.render]
  | .calleeAt cursor => call ["callee_at"] [["text"], ["context"], cursor.render, ["catalog"]]
  | .callModel cursor => call ["call_model"] [["text"], ["context"], cursor.render, ["scan", ".", "facts"], ["catalog"]]
  | .readCall cursor => call ["read_call"] [["text"], ["context"], cursor.render, ["scan", ".", "facts"], ["catalog"]]
  | .scalarTarget cursor => call ["scalar_target"] [["text"], ["context"], cursor.render]
  | .booleanTarget cursor => call ["boolean_target"] [["text"], ["context"], cursor.render]
  | .assignmentResult scalarExpr flagExpr node => call ["call_assignment_result"] [["context"], ["scan"], scalarExpr.render, flagExpr.render, node.render]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .eq left right | .kindEq left right => left.render ++ ["="] ++ right.render
  | .ne left right | .kindNe left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .empty node => call ["scalars", ".", "is_empty"] [node.render]
  | .included left right => call ["included"] [left.render, right.render]
  | .not node => ["not"] ++ node.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .invalidCall => ["invalid_call"]
  | .makeCall endExpr kindExpr bounds => ["("] ++ endExpr.render ++ [","] ++ kindExpr.render ++ [","] ++ bounds.render ++ [")"]
  | .invalidBody => call ["invalid_body"] [["scan"]]
  | .assignedInteger => ["(", "scan", "with", "delta", "position", "=>", "value", ".", "after", ",", "assigned", "=>", "true", ",",
      "facts", "=>", "(", "scan", ".", "facts", "with", "delta", "values", "=>", "(", "scan", ".", "facts", ".", "values", "with", "delta", "scalar", "=>", "value", ".", "bounds", ")", ")", ")"]
  | .assignedBoolean => ["(", "scan", "with", "delta", "position", "=>", "value", ".", "after", ",", "assigned", "=>", "true", ")"]
  | .group node => ["("] ++ node.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .locals node => ["declare"] ++ node.render
  | .letFirst node body => localRender "first" ["literal_position"] node.render body.render body.local
  | .letAfter node body => localRender "after" ["literal_position"] node.render body.render body.local
  | .letCallee node body => localRender "callee" ["functions", ".", "function_count"] node.render body.render body.local
  | .letStart node body => localRender "start" ["literal_position"] node.render body.render body.local
  | .letItem node body => localRender "item" ["functions", ".", "signature"] node.render body.render body.local
  | .letValue node body => localRender "value" ["scalar_expressions", ".", "expression_result"] node.render body.render body.local
  | .letAssociation node body => localRender "association" ["actual_association"] node.render body.render body.local


/-- Prefixes of selected components must render names. Explicit groups and
record aggregates are primaries, but cannot be selected without qualification. -/
def Expr.prefix : Expr α → Bool
  | .loopCursor | .loopIndex => true
  | .ordinal | .named | .seen | .associationValue | .associationFormal _ | .associationPayload _
  | .associationNamed _ | .noFormals | .seenAt _ _ | .actualsTail _ _ _ _ _ _ | .association _ _ _ _ _ => true
  | .markSeen _ _ => true
  | .truth _ | .letAssociation _ _ => false
  | .position | .scanPosition | .first | .last | .after | .callee | .start | .scalar | .flag
  | .intervalValue | .intervalBounds | .lower _ | .upper _
  | .value | .called | .parameter | .item | .kind _
  | .formalKind _ | .formalBounds _ | .formalFirst _ | .formalCount _ | .resultKind _ | .resultBounds _
  | .valueAfter _ | .valueBounds _ | .callAfter _ | .callKind _ | .callBounds _
  | .parameterAt _ | .signatureAt _ | .scalarMutable _ | .booleanMutable _ | .declaredBounds _
  | .skip _ | .nameAfter _ | .namesLookup _ _ | .scalarLookup _ _ | .booleanLookup _ _
  | .arrayLookup _ _ | .functionLookup _ _ | .token _ _ | .readScalar _ | .readConditionAfter _
  | .actual _ _ | .actuals _ _ _ | .calleeAt _ | .callModel _ | .readCall _ | .scalarTarget _
  | .booleanTarget _ | .assignmentResult _ _ _ | .empty _ | .included _ _ | .invalidCall | .invalidBody => true
  | .number _ | .geInt _ _ | .leInt _ _ | .add _ _ | .sub _ _ | .eq _ _ | .ne _ _ | .le _ _
  | .kindEq _ _ | .kindNe _ _ | .not _ | .andThen _ _ | .orElse _ _ | .makeCall _ _ _
  | .assignedInteger | .assignedBoolean | .group _ | .ite _ _ _ | .elsif _ _ _ | .locals _
  | .letFirst _ _ | .letAfter _ _ | .letCallee _ _ | .letStart _ _ | .letItem _ _ | .letValue _ _ => false

/-- Fail closed when adding a new operator: bare arithmetic, conditions and
local declarations must never be mistaken for atomic Ada expressions. -/
def Expr.primary : Expr α → Bool
  | .loopCursor | .loopIndex => true
  | .ordinal | .named | .seen | .associationValue | .associationFormal _ | .associationPayload _
  | .associationNamed _ | .noFormals | .seenAt _ _ | .actualsTail _ _ _ _ _ _ | .association _ _ _ _ _
  | .truth _ | .markSeen _ _ => true
  | .position | .scanPosition | .first | .last | .after | .callee | .start | .scalar | .flag
  | .intervalValue | .intervalBounds | .lower _ | .upper _
  | .value | .called | .parameter | .item | .number _ | .kind _
  | .formalKind _ | .formalBounds _ | .formalFirst _ | .formalCount _ | .resultKind _ | .resultBounds _
  | .valueAfter _ | .valueBounds _ | .callAfter _ | .callKind _ | .callBounds _
  | .parameterAt _ | .signatureAt _ | .scalarMutable _ | .booleanMutable _ | .declaredBounds _
  | .skip _ | .nameAfter _ | .namesLookup _ _ | .scalarLookup _ _ | .booleanLookup _ _
  | .arrayLookup _ _ | .functionLookup _ _ | .token _ _ | .readScalar _ | .readConditionAfter _
  | .actual _ _ | .actuals _ _ _ | .calleeAt _ | .callModel _ | .readCall _ | .scalarTarget _
  | .booleanTarget _ | .assignmentResult _ _ _ | .empty _ | .included _ _
  | .invalidCall | .makeCall _ _ _ | .invalidBody | .assignedInteger | .assignedBoolean | .group _ => true
  | _ => false

def Expr.simple : Expr α → Bool
  | .add _ _ | .sub _ _ => true
  | node => node.primary

def Expr.relation : Expr α → Bool
  | .geInt _ _ | .leInt _ _ | .eq _ _ | .ne _ _ | .le _ _ | .kindEq _ _ | .kindNe _ _ | .not _ => true
  | node => node.simple

def Expr.andHead : Expr α → Bool | .andThen _ _ => true | node => node.relation
def Expr.orHead : Expr α → Bool | .orElse _ _ => true | node => node.relation
def Expr.isElsif : Expr α → Bool | .elsif _ _ _ => true | _ => false

def Expr.wellFormed : Expr α → Bool
  | .loopCursor | .loopIndex => true
  | .ordinal | .named | .seen | .associationValue | .noFormals | .truth _ => true
  | .associationFormal node | .associationPayload node | .associationNamed node => node.prefix && node.wellFormed
  | .seenAt setExpr formalExpr => setExpr.prefix && formalExpr.simple && setExpr.wellFormed && formalExpr.wellFormed
  | .markSeen setExpr formalExpr => setExpr.simple && formalExpr.simple && setExpr.wellFormed && formalExpr.wellFormed
  | .actualsTail cursor firstExpr lastExpr ordinalExpr namedExpr seenExpr =>
      cursor.simple && firstExpr.simple && lastExpr.simple && ordinalExpr.simple && namedExpr.simple && seenExpr.simple &&
      cursor.wellFormed && firstExpr.wellFormed && lastExpr.wellFormed && ordinalExpr.wellFormed && namedExpr.wellFormed && seenExpr.wellFormed
  | .association cursor firstExpr lastExpr ordinalExpr namedExpr =>
      cursor.simple && firstExpr.simple && lastExpr.simple && ordinalExpr.simple && namedExpr.simple &&
      cursor.wellFormed && firstExpr.wellFormed && lastExpr.wellFormed && ordinalExpr.wellFormed && namedExpr.wellFormed
  | .letAssociation node body => node.simple && node.wellFormed && (body.local || body.simple) && body.wellFormed
  | .position | .scanPosition | .first | .last | .after | .callee | .start | .scalar | .flag
  | .value | .called | .parameter | .item | .number _ | .kind _ | .invalidCall
  | .intervalValue | .intervalBounds | .invalidBody | .assignedInteger | .assignedBoolean => true
  | .lower node | .upper node
  | .formalKind node | .formalBounds node | .formalFirst node | .formalCount node
  | .resultKind node | .resultBounds node | .valueAfter node | .valueBounds node
  | .callAfter node | .callKind node | .callBounds node => node.prefix && node.wellFormed
  | .not node => node.primary && node.wellFormed
  | .parameterAt node | .signatureAt node | .scalarMutable node | .booleanMutable node | .declaredBounds node
  | .skip node | .nameAfter node | .readScalar node | .readConditionAfter node | .calleeAt node
  | .callModel node | .readCall node | .scalarTarget node | .booleanTarget node | .empty node
  | .token node _ => node.simple && node.wellFormed
  | .geInt left right | .leInt left right
  | .namesLookup left right | .scalarLookup left right | .booleanLookup left right
  | .arrayLookup left right | .functionLookup left right | .included left right | .actual left right
  | .eq left right | .ne left right | .le left right | .kindEq left right | .kindNe left right =>
      left.simple && right.simple && left.wellFormed && right.wellFormed
  | .actuals startExpr second third | .assignmentResult startExpr second third | .makeCall startExpr second third =>
      startExpr.simple && second.simple && third.simple && startExpr.wellFormed && second.wellFormed && third.wellFormed
  | .add left right | .sub left right => left.simple && right.primary && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .group node => node.wellFormed
  | .ite condition yes no | .elsif condition yes no =>
      (condition.andHead || condition.orHead) && condition.wellFormed &&
      yes.simple && yes.wellFormed && (no.simple || no.isElsif) && no.wellFormed
  | .locals node => node.local && node.wellFormed
  | .letFirst node body | .letAfter node body | .letCallee node body | .letStart node body
  | .letItem node body | .letValue node body =>
      node.simple && node.wellFormed && (body.local || body.simple) && body.wellFormed

/-- Scope keys retain the source name and its type. Binding a scalar Value
cannot make the separate Call_Result projection well scoped. -/
abbrev Scope := List (String × Nat)
def Scope.bind (scope : Scope) (name : String) (kindExpr : Nat) : Scope :=
  (name, kindExpr) :: scope.filter (fun entry => entry.1 != name)

def Expr.scoped (scope : Scope) : Expr α → Bool
  | .loopCursor => ("cursor", 0) ∈ scope | .loopIndex => ("index", 0) ∈ scope
  | .ordinal => ("ordinal", 0) ∈ scope | .named => ("named", 11) ∈ scope
  | .seen => ("seen", 12) ∈ scope | .associationValue => ("association", 13) ∈ scope
  | .noFormals | .truth _ => true
  | .associationFormal node | .associationPayload node | .associationNamed node => node.scoped scope
  | .seenAt setExpr formalExpr | .markSeen setExpr formalExpr => setExpr.scoped scope && formalExpr.scoped scope
  | .actualsTail cursor firstExpr lastExpr ordinalExpr namedExpr seenExpr =>
      decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("facts", 7) ∈ scope ∧ ("catalog", 8) ∈ scope) &&
      cursor.scoped scope && firstExpr.scoped scope && lastExpr.scoped scope && ordinalExpr.scoped scope && namedExpr.scoped scope && seenExpr.scoped scope
  | .association cursor firstExpr lastExpr ordinalExpr namedExpr =>
      decide (("text", 5) ∈ scope ∧ ("catalog", 8) ∈ scope) &&
      cursor.scoped scope && firstExpr.scoped scope && lastExpr.scoped scope && ordinalExpr.scoped scope && namedExpr.scoped scope
  | .letAssociation node body => node.scoped scope && body.scoped (scope.bind "association" 13)
  | .intervalValue => ("value", 10) ∈ scope | .intervalBounds => ("bounds", 10) ∈ scope
  | .position => ("position", 0) ∈ scope | .scanPosition => ("scan", 9) ∈ scope
  | .first => ("first", 0) ∈ scope | .last => ("last", 0) ∈ scope | .after => ("after", 0) ∈ scope
  | .callee => ("callee", 0) ∈ scope | .start => ("start", 0) ∈ scope | .scalar => ("scalar", 0) ∈ scope
  | .flag => ("flag", 0) ∈ scope | .value => ("value", 1) ∈ scope | .called => ("value", 2) ∈ scope
  | .parameter => ("parameter", 3) ∈ scope | .item => ("item", 4) ∈ scope
  | .number _ | .kind _ | .invalidCall => true
  | .parameterAt node | .signatureAt node => decide (("catalog", 8) ∈ scope) && node.scoped scope
  | .scalarMutable node | .booleanMutable node | .declaredBounds node => decide (("context", 6) ∈ scope) && node.scoped scope
  | .skip node | .nameAfter node | .token node _ => decide (("text", 5) ∈ scope) && node.scoped scope
  | .namesLookup startExpr endExpr | .scalarLookup startExpr endExpr | .booleanLookup startExpr endExpr | .arrayLookup startExpr endExpr =>
      decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope) && startExpr.scoped scope && endExpr.scoped scope
  | .functionLookup startExpr endExpr => decide (("text", 5) ∈ scope ∧ ("catalog", 8) ∈ scope) && startExpr.scoped scope && endExpr.scoped scope
  | .readScalar node | .readConditionAfter node => decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("facts", 7) ∈ scope) && node.scoped scope
  | .actual cursor formalExpr => decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("facts", 7) ∈ scope) && cursor.scoped scope && formalExpr.scoped scope
  | .actuals cursor startExpr endExpr => decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("facts", 7) ∈ scope ∧ ("catalog", 8) ∈ scope) && cursor.scoped scope && startExpr.scoped scope && endExpr.scoped scope
  | .calleeAt node => decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("catalog", 8) ∈ scope) && node.scoped scope
  | .callModel node | .readCall node => decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope ∧ ("scan", 9) ∈ scope ∧ ("catalog", 8) ∈ scope) && node.scoped scope
  | .scalarTarget node | .booleanTarget node => decide (("text", 5) ∈ scope ∧ ("context", 6) ∈ scope) && node.scoped scope
  | .assignmentResult scalarExpr flagExpr node => decide (("context", 6) ∈ scope ∧ ("scan", 9) ∈ scope) && scalarExpr.scoped scope && flagExpr.scoped scope && node.scoped scope
  | .invalidBody => ("scan", 9) ∈ scope
  | .assignedInteger => decide (("scan", 9) ∈ scope ∧ ("value", 2) ∈ scope ∧ ("scalar", 0) ∈ scope)
  | .assignedBoolean => decide (("scan", 9) ∈ scope ∧ ("value", 2) ∈ scope)
  | .lower node | .upper node
  | .formalKind node | .formalBounds node | .formalFirst node | .formalCount node | .resultKind node | .resultBounds node
  | .valueAfter node | .valueBounds node | .callAfter node | .callKind node | .callBounds node
  | .empty node | .not node | .group node | .locals node => node.scoped scope
  | .geInt left right | .leInt left right
  | .add left right | .sub left right | .eq left right | .ne left right | .le left right
  | .kindEq left right | .kindNe left right | .included left right | .andThen left right | .orElse left right =>
      left.scoped scope && right.scoped scope
  | .makeCall startExpr second third | .ite startExpr second third | .elsif startExpr second third =>
      startExpr.scoped scope && second.scoped scope && third.scoped scope
  | .letFirst node body => node.scoped scope && body.scoped (scope.bind "first" 0)
  | .letAfter node body => node.scoped scope && body.scoped (scope.bind "after" 0)
  | .letCallee node body => node.scoped scope && body.scoped (scope.bind "callee" 0)
  | .letStart node body => node.scoped scope && body.scoped (scope.bind "start" 0)
  | .letItem node body => node.scoped scope && body.scoped (scope.bind "item" 4)
  | .letValue node body => node.scoped scope && body.scoped (scope.bind "value" 1)

def includedBody : Expr Bool :=
  .orElse (.empty .intervalValue) (.group <|
    .andThen (.andThen (.not (.empty .intervalBounds))
      (.geInt (.lower .intervalValue) (.lower .intervalBounds)))
      (.leInt (.upper .intervalValue) (.upper .intervalBounds)))

def actualBody : Expr Nat :=
  .ite (.kindEq (.formalKind .parameter) (.kind .boolean)) (.readConditionAfter .position)
    (.group <| .locals <| .letValue (.readScalar .position) <|
      .group <| .ite (.orElse (.orElse (.eq (.valueAfter .value) (.number 0)) (.empty (.valueBounds .value)))
        (.not (.included (.valueBounds .value) (.formalBounds .parameter))))
        (.number 0) (.valueAfter .value))

def actualsTailBody : Expr Nat :=
  .locals <| .letAssociation (.association .position .first .last .ordinal .named) <|
    .group <| .ite (.orElse (.eq (.associationFormal .associationValue) (.number 0))
      (.seenAt .seen (.associationFormal .associationValue))) (.number 0)
      (.group <| .locals <| .letAfter (.actual (.associationPayload .associationValue)
        (.parameterAt (.associationFormal .associationValue))) <|
        .group <| .ite (.eq .after (.number 0)) (.number 0)
          (.elsif (.eq .ordinal .last) (.token .after (.symbol ")"))
            (.elsif (.eq (.token .after (.symbol ",")) (.number 0)) (.number 0)
              (.actualsTail (.token .after (.symbol ",")) .first .last (.add .ordinal (.number 1))
                (.associationNamed .associationValue) (.markSeen .seen (.associationFormal .associationValue))))))

def actualsBody : Expr Nat :=
  .actualsTail .position .first .last .first (.truth false) .noFormals

def calleeBody : Expr Nat :=
  .locals <| .letFirst (.skip .position) <| .letAfter (.nameAfter .first) <|
    .group <| .ite (.orElse (.orElse (.orElse (.orElse (.orElse (.eq .first (.number 0)) (.le .after .first))
      (.ne (.namesLookup .first .after) (.number 0))) (.ne (.scalarLookup .first .after) (.number 0)))
      (.ne (.booleanLookup .first .after) (.number 0))) (.ne (.arrayLookup .first .after) (.number 0)))
      (.number 0) (.functionLookup .first .after)

def callBody : Expr CallResult :=
  .locals <| .letCallee (.calleeAt .position) <|
    .group <| .ite (.eq .callee (.number 0)) .invalidCall
      (.group <| .locals <| .letItem (.signatureAt .callee) <|
        .letStart (.token (.nameAfter (.skip .position)) (.symbol "(")) <|
        .letAfter (.actuals .start (.formalFirst .item)
          (.sub (.add (.formalFirst .item) (.formalCount .item)) (.number 1))) <|
        .group <| .ite (.le .after .position) .invalidCall
          (.makeCall .after (.resultKind .item) (.resultBounds .item)))

def assignmentResultBody : Expr BodyScan :=
  .ite (.le (.callAfter .called) .scanPosition) .invalidBody
    (.elsif (.ne .scalar (.number 0))
      (.group <| .ite (.orElse (.orElse (.orElse (.kindNe (.callKind .called) (.kind .integer))
        (.not (.scalarMutable .scalar))) (.empty (.callBounds .called)))
        (.not (.included (.callBounds .called) (.declaredBounds .scalar))))
        .invalidBody .assignedInteger)
      (.elsif (.andThen (.andThen (.ne .flag (.number 0)) (.booleanMutable .flag))
        (.kindEq (.callKind .called) (.kind .boolean))) .assignedBoolean .invalidBody))

def assignmentBody (native : Bool) : Expr BodyScan :=
  let cursor := Expr.token (.nameAfter (.skip .scanPosition)) (.symbol ":=")
  .assignmentResult (.scalarTarget .scanPosition) (.booleanTarget .scanPosition)
    (if native then .readCall cursor else .callModel cursor)

def modelImports : Imports where
  skip := skipAt
  nameAfter := Compose.nameAfter
  namesLookup := lookupName
  scalarLookup := ScalarExpression.lookup
  booleanLookup := BooleanBindings.lookup
  arrayLookup := ArrayBindings.lookup
  functionLookup := FunctionBindings.lookup
  token := tokenAfter
  condition := fun text context position facts => readCondition text context.model position facts
  scalar := fun text context position facts => readScalarInFlow text context.model position facts
  isEmpty := Integer.Interval.isEmpty
  included := Integer.Interval.included
  invalid := Predicate.invalidBody
  association := functionAssociation
  markFormal := Predicate.markFormal

def modelCalls : Calls where
  actual := fun text context position facts parameter => actualAfter text context.model position facts parameter
  actuals := fun text context position facts catalog first last => actualsAfter text context.model position facts catalog first last
  actualsTail := fun text context position facts catalog first last ordinal named seen =>
    functionActualsTailModel text context.model position facts catalog first last ordinal named seen
  callee := fun text context position catalog => calleeAt text context.model position catalog
  callModel := fun text context position facts catalog => Predicate.readCall text context.model position facts catalog
  readCall := fun text context position facts catalog => Predicate.readCall text context.model position facts catalog
  scalarTarget := fun text context position => Predicate.scalarTarget text context.model position
  booleanTarget := fun text context position => Predicate.booleanTarget text context.model position
  assignmentResult := fun context scan scalar flag value => callAssignmentResult context.model scan scalar flag value

namespace StructuralControls

theorem selected_prefixes :
    (Expr.valueAfter (.group .value)).wellFormed = false ∧
    (Expr.callAfter (.group (.ite (.empty .intervalValue) .called .called))).wellFormed = false ∧
    (Expr.callAfter (.makeCall (.number 1) (.kind .integer) .intervalBounds)).wellFormed = false ∧
    (Expr.formalKind (.group .parameter)).wellFormed = false ∧
    (Expr.lower (.group .intervalValue)).wellFormed = false ∧
    (Expr.valueAfter .value).wellFormed = true ∧
    (Expr.callAfter (.readCall .position)).wellFormed = true ∧
    (Expr.formalBounds (.parameterAt (.number 1))).wellFormed = true ∧
    (Expr.lower (.callBounds (.readCall .position))).wellFormed = true := by decide +kernel

end StructuralControls

end Silver.Predicate.FunctionCallNative
