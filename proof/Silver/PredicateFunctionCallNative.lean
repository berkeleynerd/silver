module

public import Silver.PredicateBodyScanner
public import Silver.PredicateNativeState

@[expose] public section

/-! Typed trees for scalar-call parsing. Recursive calls and inherited readers
remain explicit imports until the source equations and native call domains are
applied. Every actual uses the same incoming flow. -/
namespace Silver.Predicate.FunctionCallNative
open Compose FunctionBindings

structure Imports where
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

structure Calls where
  actual : Source → Native.Context → Nat → ActiveFlow → Formal → Nat
  actuals : Source → Native.Context → Nat → ActiveFlow → Metadata → Nat → Nat → Nat
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
  facts : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  catalog : Metadata := {}
  parameter : Formal := emptyFormal
  scan : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  first : Nat := 0
  last : Nat := 0
  after : Nat := 0
  callee : Nat := 0
  start : Nat := 0
  scalar : Nat := 0
  flag : Nat := 0
  item : Signature := emptySignature
  value : ScalarExpression.Result := ScalarExpression.invalid
  called : CallResult := invalidCall

inductive Expr : Type → Type 1
  | position | scanPosition | first | last | after | callee | start | scalar | flag : Expr Nat
  | value : Expr ScalarExpression.Result
  | called : Expr CallResult
  | parameter : Expr Formal
  | item : Expr Signature
  | number : Nat → Expr Nat
  | kind : ScalarKind → Expr ScalarKind
  | formalKind : Expr Formal → Expr ScalarKind
  | formalBounds : Expr Formal → Expr Integer.Interval
  | formalFirst | formalCount : Expr Signature → Expr Nat
  | resultKind : Expr Signature → Expr ScalarKind
  | resultBounds : Expr Signature → Expr Integer.Interval
  | valueAfter : Expr ScalarExpression.Result → Expr Nat
  | valueBounds : Expr ScalarExpression.Result → Expr Integer.Interval
  | callAfter : Expr CallResult → Expr Nat
  | callKind : Expr CallResult → Expr ScalarKind
  | callBounds : Expr CallResult → Expr Integer.Interval
  | parameterAt : Expr Nat → Expr Formal
  | signatureAt : Expr Nat → Expr Signature
  | scalarMutable | booleanMutable : Expr Nat → Expr Bool
  | declaredBounds : Expr Nat → Expr Integer.Interval
  | skip | nameAfter : Expr Nat → Expr Nat
  | namesLookup | scalarLookup | booleanLookup | arrayLookup | functionLookup : Expr Nat → Expr Nat → Expr Nat
  | token : Expr Nat → ShellToken → Expr Nat
  | readScalar : Expr Nat → Expr ScalarExpression.Result
  | readConditionAfter : Expr Nat → Expr Nat
  | actual : Expr Nat → Expr Formal → Expr Nat
  | actuals : Expr Nat → Expr Nat → Expr Nat → Expr Nat
  | calleeAt : Expr Nat → Expr Nat
  | callModel | readCall : Expr Nat → Expr CallResult
  | scalarTarget | booleanTarget : Expr Nat → Expr Nat
  | assignmentResult : Expr Nat → Expr Nat → Expr CallResult → Expr BodyScan
  | add | sub : Expr Nat → Expr Nat → Expr Nat
  | eq | ne | le : Expr Nat → Expr Nat → Expr Bool
  | kindEq | kindNe : Expr ScalarKind → Expr ScalarKind → Expr Bool
  | empty : Expr Integer.Interval → Expr Bool
  | included : Expr Integer.Interval → Expr Integer.Interval → Expr Bool
  | not : Expr Bool → Expr Bool
  | andThen | orElse : Expr Bool → Expr Bool → Expr Bool
  | invalidCall : Expr CallResult
  | makeCall : Expr Nat → Expr ScalarKind → Expr Integer.Interval → Expr CallResult
  | invalidBody | assignedInteger | assignedBoolean : Expr BodyScan
  | group : Expr α → Expr α
  | ite | elsif : Expr Bool → Expr α → Expr α → Expr α
  | locals : Expr α → Expr α
  | letFirst | letAfter | letCallee | letStart : Expr Nat → Expr α → Expr α
  | letItem : Expr Signature → Expr α → Expr α
  | letValue : Expr ScalarExpression.Result → Expr α → Expr α

def Expr.eval (imports : Imports) (calls : Calls) (frame : Frame) : Expr α → α
  | .position => frame.position | .scanPosition => frame.scan.position
  | .first => frame.first | .last => frame.last | .after => frame.after
  | .callee => frame.callee | .start => frame.start | .scalar => frame.scalar | .flag => frame.flag
  | .value => frame.value | .called => frame.called | .parameter => frame.parameter | .item => frame.item
  | .number value => value | .kind value => value
  | .formalKind value => (value.eval imports calls frame).kind
  | .formalBounds value => (value.eval imports calls frame).bounds
  | .formalFirst value => (value.eval imports calls frame).formalFirst
  | .formalCount value => (value.eval imports calls frame).count
  | .resultKind value => (value.eval imports calls frame).resultKind
  | .resultBounds value => (value.eval imports calls frame).resultBounds
  | .valueAfter value => (value.eval imports calls frame).after
  | .valueBounds value => (value.eval imports calls frame).bounds
  | .callAfter value => (value.eval imports calls frame).after
  | .callKind value => (value.eval imports calls frame).kind
  | .callBounds value => (value.eval imports calls frame).bounds
  | .parameterAt index => FunctionBindings.parameter frame.catalog (index.eval imports calls frame)
  | .signatureAt index => FunctionBindings.signature frame.catalog (index.eval imports calls frame)
  | .scalarMutable index => (ScalarExpression.binding frame.context.scalarNames (index.eval imports calls frame)).mutable
  | .booleanMutable index => (BooleanBindings.binding frame.context.booleanNames (index.eval imports calls frame)).mutable
  | .declaredBounds index => (ScalarExpression.binding frame.context.scalarNames (index.eval imports calls frame)).declaredBounds
  | .skip position => imports.skip frame.text (position.eval imports calls frame)
  | .nameAfter position => imports.nameAfter frame.text (position.eval imports calls frame)
  | .namesLookup first after => imports.namesLookup frame.text frame.context.names (first.eval imports calls frame) (after.eval imports calls frame)
  | .scalarLookup first after => imports.scalarLookup frame.text frame.context.scalarNames (first.eval imports calls frame) (after.eval imports calls frame)
  | .booleanLookup first after => imports.booleanLookup frame.text frame.context.booleanNames (first.eval imports calls frame) (after.eval imports calls frame)
  | .arrayLookup first after => imports.arrayLookup frame.text frame.context.arrayNames (first.eval imports calls frame) (after.eval imports calls frame)
  | .functionLookup first after => imports.functionLookup frame.text frame.catalog (first.eval imports calls frame) (after.eval imports calls frame)
  | .token position token => imports.token frame.text (position.eval imports calls frame) token
  | .readScalar position => imports.scalar frame.text frame.context (position.eval imports calls frame) frame.facts
  | .readConditionAfter position => (imports.condition frame.text frame.context (position.eval imports calls frame) frame.facts).after
  | .actual position parameter => calls.actual frame.text frame.context (position.eval imports calls frame) frame.facts (parameter.eval imports calls frame)
  | .actuals position first last => calls.actuals frame.text frame.context (position.eval imports calls frame) frame.facts frame.catalog (first.eval imports calls frame) (last.eval imports calls frame)
  | .calleeAt position => calls.callee frame.text frame.context (position.eval imports calls frame) frame.catalog
  | .callModel position => calls.callModel frame.text frame.context (position.eval imports calls frame) frame.scan.facts frame.catalog
  | .readCall position => calls.readCall frame.text frame.context (position.eval imports calls frame) frame.scan.facts frame.catalog
  | .scalarTarget position => calls.scalarTarget frame.text frame.context (position.eval imports calls frame)
  | .booleanTarget position => calls.booleanTarget frame.text frame.context (position.eval imports calls frame)
  | .assignmentResult scalar flag value => calls.assignmentResult frame.context frame.scan (scalar.eval imports calls frame) (flag.eval imports calls frame) (value.eval imports calls frame)
  | .add left right => left.eval imports calls frame + right.eval imports calls frame
  | .sub left right => left.eval imports calls frame - right.eval imports calls frame
  | .eq left right => decide (left.eval imports calls frame = right.eval imports calls frame)
  | .ne left right => decide (left.eval imports calls frame ≠ right.eval imports calls frame)
  | .le left right => decide (left.eval imports calls frame ≤ right.eval imports calls frame)
  | .kindEq left right => decide (left.eval imports calls frame = right.eval imports calls frame)
  | .kindNe left right => decide (left.eval imports calls frame ≠ right.eval imports calls frame)
  | .empty value => imports.isEmpty (value.eval imports calls frame)
  | .included left right => imports.included (left.eval imports calls frame) (right.eval imports calls frame)
  | .not value => !value.eval imports calls frame
  | .andThen left right => left.eval imports calls frame && right.eval imports calls frame
  | .orElse left right => left.eval imports calls frame || right.eval imports calls frame
  | .invalidCall => Predicate.invalidCall
  | .makeCall after kind bounds => ⟨after.eval imports calls frame, kind.eval imports calls frame, bounds.eval imports calls frame⟩
  | .invalidBody => imports.invalid frame.scan
  | .assignedInteger => {frame.scan with position := frame.called.after, assigned := true,
      facts := frame.scan.facts.replace frame.scalar frame.called.bounds}
  | .assignedBoolean => {frame.scan with position := frame.called.after, assigned := true}
  | .group value | .locals value => value.eval imports calls frame
  | .ite condition yes no | .elsif condition yes no => if condition.eval imports calls frame then yes.eval imports calls frame else no.eval imports calls frame
  | .letFirst value body => body.eval imports calls {frame with first := value.eval imports calls frame}
  | .letAfter value body => body.eval imports calls {frame with after := value.eval imports calls frame}
  | .letCallee value body => body.eval imports calls {frame with callee := value.eval imports calls frame}
  | .letStart value body => body.eval imports calls {frame with start := value.eval imports calls frame}
  | .letItem value body => body.eval imports calls {frame with item := value.eval imports calls frame}
  | .letValue value body => body.eval imports calls {frame with value := value.eval imports calls frame}

def call (name : List String) (arguments : List (List String)) : List String :=
  name ++ ["("] ++ (arguments.intersperse [","]).flatten ++ [")"]

def Expr.local : Expr α → Bool
  | .letFirst _ _ | .letAfter _ _ | .letCallee _ _ | .letStart _ _ | .letItem _ _ | .letValue _ _ => true
  | _ => false

def localRender (name : String) (typeName value body : List String) (more : Bool) : List String :=
  [name, ":", "constant"] ++ typeName ++ [":="] ++ value ++ [";"] ++ (if more then [] else ["begin"]) ++ body

def Expr.render : Expr α → List String
  | .position => ["position"] | .scanPosition => ["scan", ".", "position"]
  | .first => ["first"] | .last => ["last"] | .after => ["after"] | .callee => ["callee"]
  | .start => ["start"] | .scalar => ["scalar"] | .flag => ["flag"]
  | .value | .called => ["value"] | .parameter => ["parameter"] | .item => ["item"]
  | .number value => [toString value]
  | .kind value => ["functions", ".", if value = .integer then "integer_kind" else "boolean_kind"]
  | .formalKind value | .callKind value => value.render ++ [".", "kind"]
  | .formalBounds value | .valueBounds value | .callBounds value => value.render ++ [".", "bounds"]
  | .formalFirst value => value.render ++ [".", "formal_first"]
  | .formalCount value => value.render ++ [".", "count"]
  | .resultKind value => value.render ++ [".", "result_kind"]
  | .resultBounds value => value.render ++ [".", "result_bounds"]
  | .valueAfter value | .callAfter value => value.render ++ [".", "after"]
  | .parameterAt index => ["catalog", ".", "parameters", "("] ++ index.render ++ [")"]
  | .signatureAt index => ["catalog", ".", "items", "("] ++ index.render ++ [")"]
  | .scalarMutable index => ["context", ".", "scalar_names", ".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .booleanMutable index => ["context", ".", "boolean_names", ".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .declaredBounds index => ["context", ".", "scalar_names", ".", "items", "("] ++ index.render ++ [")", ".", "declared_bounds"]
  | .skip position => call ["skip_at"] [["text"], position.render]
  | .nameAfter position => call ["name_after"] [["text"], position.render]
  | .namesLookup first after => call ["lookup_name"] [["text"], ["context", ".", "names"], first.render, after.render]
  | .scalarLookup first after => call ["scalar_expressions", ".", "lookup"] [["text"], ["context", ".", "scalar_names"], first.render, after.render]
  | .booleanLookup first after => call ["lookup_boolean"] [["text"], ["context", ".", "boolean_names"], first.render, after.render]
  | .arrayLookup first after => call ["array_bindings", ".", "lookup"] [["text"], ["context", ".", "array_names"], first.render, after.render]
  | .functionLookup first after => call ["functions", ".", "lookup"] [["text"], ["catalog"], first.render, after.render]
  | .token position token => call ["take_token"] [["text"], position.render, [Compose.Expressions.tokenName token]]
  | .readScalar position => call ["read_scalar_in_flow"] [["text"], ["context"], position.render, ["facts"]]
  | .readConditionAfter position => call ["condition_model"] [["text"], ["context"], position.render, ["facts"]] ++ [".", "after"]
  | .actual position parameter => call ["actual_model"] [["text"], ["context"], position.render, ["facts"], parameter.render]
  | .actuals position first last => call ["actuals_model"] [["text"], ["context"], position.render, ["facts"], ["catalog"], first.render, last.render]
  | .calleeAt position => call ["callee_at"] [["text"], ["context"], position.render, ["catalog"]]
  | .callModel position => call ["call_model"] [["text"], ["context"], position.render, ["scan", ".", "facts"], ["catalog"]]
  | .readCall position => call ["read_call"] [["text"], ["context"], position.render, ["scan", ".", "facts"], ["catalog"]]
  | .scalarTarget position => call ["scalar_target"] [["text"], ["context"], position.render]
  | .booleanTarget position => call ["boolean_target"] [["text"], ["context"], position.render]
  | .assignmentResult scalar flag value => call ["call_assignment_result"] [["context"], ["scan"], scalar.render, flag.render, value.render]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .eq left right | .kindEq left right => left.render ++ ["="] ++ right.render
  | .ne left right | .kindNe left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .empty value => call ["scalars", ".", "is_empty"] [value.render]
  | .included left right => call ["included"] [left.render, right.render]
  | .not value => ["not"] ++ value.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .invalidCall => ["invalid_call"]
  | .makeCall after kind bounds => ["("] ++ after.render ++ [","] ++ kind.render ++ [","] ++ bounds.render ++ [")"]
  | .invalidBody => call ["invalid_body"] [["scan"]]
  | .assignedInteger => ["(", "scan", "with", "delta", "position", "=>", "value", ".", "after", ",", "assigned", "=>", "true", ",",
      "facts", "=>", "(", "scan", ".", "facts", "with", "delta", "values", "=>", "(", "scan", ".", "facts", ".", "values", "with", "delta", "scalar", "=>", "value", ".", "bounds", ")", ")", ")"]
  | .assignedBoolean => ["(", "scan", "with", "delta", "position", "=>", "value", ".", "after", ",", "assigned", "=>", "true", ")"]
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .locals value => ["declare"] ++ value.render
  | .letFirst value body => localRender "first" ["literal_position"] value.render body.render body.local
  | .letAfter value body => localRender "after" ["literal_position"] value.render body.render body.local
  | .letCallee value body => localRender "callee" ["functions", ".", "function_count"] value.render body.render body.local
  | .letStart value body => localRender "start" ["literal_position"] value.render body.render body.local
  | .letItem value body => localRender "item" ["functions", ".", "signature"] value.render body.render body.local
  | .letValue value body => localRender "value" ["scalar_expressions", ".", "expression_result"] value.render body.render body.local


/-- Fail closed when adding a new operator: bare arithmetic, conditions and
local declarations must never be mistaken for atomic Ada expressions. -/
def Expr.primary : Expr α → Bool
  | .position | .scanPosition | .first | .last | .after | .callee | .start | .scalar | .flag
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
  | value => value.primary

def Expr.relation : Expr α → Bool
  | .eq _ _ | .ne _ _ | .le _ _ | .kindEq _ _ | .kindNe _ _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr α → Bool | .andThen _ _ => true | value => value.relation
def Expr.orHead : Expr α → Bool | .orElse _ _ => true | value => value.relation
def Expr.isElsif : Expr α → Bool | .elsif _ _ _ => true | _ => false

def Expr.wellFormed : Expr α → Bool
  | .position | .scanPosition | .first | .last | .after | .callee | .start | .scalar | .flag
  | .value | .called | .parameter | .item | .number _ | .kind _ | .invalidCall
  | .invalidBody | .assignedInteger | .assignedBoolean => true
  | .formalKind value | .formalBounds value | .formalFirst value | .formalCount value
  | .resultKind value | .resultBounds value | .valueAfter value | .valueBounds value
  | .callAfter value | .callKind value | .callBounds value | .not value => value.primary && value.wellFormed
  | .parameterAt value | .signatureAt value | .scalarMutable value | .booleanMutable value | .declaredBounds value
  | .skip value | .nameAfter value | .readScalar value | .readConditionAfter value | .calleeAt value
  | .callModel value | .readCall value | .scalarTarget value | .booleanTarget value | .empty value
  | .token value _ => value.simple && value.wellFormed
  | .namesLookup left right | .scalarLookup left right | .booleanLookup left right
  | .arrayLookup left right | .functionLookup left right | .included left right | .actual left right
  | .eq left right | .ne left right | .le left right | .kindEq left right | .kindNe left right =>
      left.simple && right.simple && left.wellFormed && right.wellFormed
  | .actuals first second third | .assignmentResult first second third | .makeCall first second third =>
      first.simple && second.simple && third.simple && first.wellFormed && second.wellFormed && third.wellFormed
  | .add left right | .sub left right => left.simple && right.primary && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .group value => value.wellFormed
  | .ite condition yes no | .elsif condition yes no =>
      (condition.andHead || condition.orHead) && condition.wellFormed &&
      yes.simple && yes.wellFormed && (no.simple || no.isElsif) && no.wellFormed
  | .locals value => value.local && value.wellFormed
  | .letFirst value body | .letAfter value body | .letCallee value body | .letStart value body
  | .letItem value body | .letValue value body =>
      value.simple && value.wellFormed && (body.local || body.simple) && body.wellFormed

/-- The scope records source parameter/local names. Type checking of the tree
also fixes each use's type; the two Value slots belong to disjoint functions. -/
def Expr.scoped (scope : List String) : Expr α → Bool
  | .position => "position" ∈ scope | .scanPosition => "scan" ∈ scope
  | .first => "first" ∈ scope | .last => "last" ∈ scope | .after => "after" ∈ scope
  | .callee => "callee" ∈ scope | .start => "start" ∈ scope | .scalar => "scalar" ∈ scope
  | .flag => "flag" ∈ scope | .value | .called => "value" ∈ scope
  | .parameter => "parameter" ∈ scope | .item => "item" ∈ scope
  | .number _ | .kind _ | .invalidCall => true
  | .parameterAt value | .signatureAt value => decide ("catalog" ∈ scope) && value.scoped scope
  | .scalarMutable value | .booleanMutable value | .declaredBounds value => decide ("context" ∈ scope) && value.scoped scope
  | .skip value | .nameAfter value | .token value _ => decide ("text" ∈ scope) && value.scoped scope
  | .namesLookup first after | .scalarLookup first after | .booleanLookup first after | .arrayLookup first after =>
      decide ("text" ∈ scope ∧ "context" ∈ scope) && first.scoped scope && after.scoped scope
  | .functionLookup first after => decide ("text" ∈ scope ∧ "catalog" ∈ scope) && first.scoped scope && after.scoped scope
  | .readScalar value | .readConditionAfter value => decide ("text" ∈ scope ∧ "context" ∈ scope ∧ "facts" ∈ scope) && value.scoped scope
  | .actual position parameter => decide ("text" ∈ scope ∧ "context" ∈ scope ∧ "facts" ∈ scope) && position.scoped scope && parameter.scoped scope
  | .actuals position first last => decide ("text" ∈ scope ∧ "context" ∈ scope ∧ "facts" ∈ scope ∧ "catalog" ∈ scope) && position.scoped scope && first.scoped scope && last.scoped scope
  | .calleeAt value => decide ("text" ∈ scope ∧ "context" ∈ scope ∧ "catalog" ∈ scope) && value.scoped scope
  | .callModel value | .readCall value => decide ("text" ∈ scope ∧ "context" ∈ scope ∧ "scan" ∈ scope ∧ "catalog" ∈ scope) && value.scoped scope
  | .scalarTarget value | .booleanTarget value => decide ("text" ∈ scope ∧ "context" ∈ scope) && value.scoped scope
  | .assignmentResult scalar flag value => decide ("context" ∈ scope ∧ "scan" ∈ scope) && scalar.scoped scope && flag.scoped scope && value.scoped scope
  | .invalidBody => "scan" ∈ scope
  | .assignedInteger => decide ("scan" ∈ scope ∧ "value" ∈ scope ∧ "scalar" ∈ scope)
  | .assignedBoolean => decide ("scan" ∈ scope ∧ "value" ∈ scope)
  | .formalKind value | .formalBounds value | .formalFirst value | .formalCount value | .resultKind value | .resultBounds value
  | .valueAfter value | .valueBounds value | .callAfter value | .callKind value | .callBounds value
  | .empty value | .not value | .group value | .locals value => value.scoped scope
  | .add left right | .sub left right | .eq left right | .ne left right | .le left right
  | .kindEq left right | .kindNe left right | .included left right | .andThen left right | .orElse left right =>
      left.scoped scope && right.scoped scope
  | .makeCall first second third | .ite first second third | .elsif first second third =>
      first.scoped scope && second.scoped scope && third.scoped scope
  | .letFirst value body => value.scoped scope && body.scoped ("first" :: scope)
  | .letAfter value body => value.scoped scope && body.scoped ("after" :: scope)
  | .letCallee value body => value.scoped scope && body.scoped ("callee" :: scope)
  | .letStart value body => value.scoped scope && body.scoped ("start" :: scope)
  | .letItem value body => value.scoped scope && body.scoped ("item" :: scope)
  | .letValue value body => value.scoped scope && body.scoped ("value" :: scope)

def actualBody : Expr Nat :=
  .ite (.kindEq (.formalKind .parameter) (.kind .boolean)) (.readConditionAfter .position)
    (.group <| .locals <| .letValue (.readScalar .position) <|
      .group <| .ite (.orElse (.orElse (.eq (.valueAfter .value) (.number 0)) (.empty (.valueBounds .value)))
        (.not (.included (.valueBounds .value) (.formalBounds .parameter))))
        (.number 0) (.valueAfter .value))

def actualsBody : Expr Nat :=
  .locals <| .letAfter (.actual .position (.parameterAt .first)) <|
    .group <| .ite (.eq .after (.number 0)) (.number 0)
      (.elsif (.eq .first .last) (.token .after (.symbol ")"))
        (.actuals (.token .after (.symbol ",")) (.add .first (.number 1)) .last))

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
  let position := Expr.token (.nameAfter (.skip .scanPosition)) (.symbol ":=")
  .assignmentResult (.scalarTarget .scanPosition) (.booleanTarget .scanPosition)
    (if native then .readCall position else .callModel position)

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

def modelCalls : Calls where
  actual := fun text context position facts parameter => actualAfter text context.model position facts parameter
  actuals := fun text context position facts catalog first last => actualsAfter text context.model position facts catalog first last
  callee := fun text context position catalog => calleeAt text context.model position catalog
  callModel := fun text context position facts catalog => Predicate.readCall text context.model position facts catalog
  readCall := fun text context position facts catalog => Predicate.readCall text context.model position facts catalog
  scalarTarget := fun text context position => Predicate.scalarTarget text context.model position
  booleanTarget := fun text context position => Predicate.booleanTarget text context.model position
  assignmentResult := fun context scan scalar flag value => callAssignmentResult context.model scan scalar flag value

end Silver.Predicate.FunctionCallNative
