module

public import Silver.Names
public import Silver.Expressions
public import Silver.NamedEquations

@[expose] public section

/-! Typed source expressions for context visibility and existing calls. Function
calls remain arbitrary until the source equations identify their meanings. -/
namespace Silver.Names.Native

inductive Ty
  | number | truth | source | spelling | operation | mode | context | state
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .source => Source | .spelling => String
  | .operation => Operation | .mode => Mode | .context => Names.Context | .state => State
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .source => [] | .spelling => ""
  | .operation => .output | .mode => .clauseStart | .context => invalidContext
  | .state => invalidState | .arrow _ b => fun _ => b.default

inductive Function
  | fixedAfter | take | token | trivia | contextStep | contextTail | contextModel
  | readContext | contextAfter | operationName | operationAfter | associationAfter
  | packageNameAfter | equalName
  deriving DecidableEq, Repr

def Function.name : Function → String
  | .fixedAfter => "fixed_after" | .take => "take" | .token => "token_at" | .trivia => "trivia_end"
  | .contextStep => "context_step" | .contextTail => "context_tail" | .contextModel => "context_model"
  | .readContext => "read_context" | .contextAfter => "context_after" | .operationName => "operation_name"
  | .operationAfter => "operation_after" | .associationAfter => "association_after"
  | .packageNameAfter => "package_name_after" | .equalName => "equal_name"

def Function.type : Function → Ty
  | .fixedAfter | .take => .arrow .source (.arrow .number (.arrow .spelling (.arrow .truth .number)))
  | .token => .arrow .source (.arrow .number (.arrow .spelling (.arrow .truth .truth)))
  | .trivia => .arrow .source (.arrow .number .number)
  | .contextStep => .arrow .source (.arrow .state (.arrow .number (.arrow .number .state)))
  | .contextTail => .arrow .source (.arrow .state (.arrow .number (.arrow .number .context)))
  | .contextModel | .readContext => .arrow .source (.arrow .number (.arrow .number (.arrow .number .context)))
  | .contextAfter => .arrow .source (.arrow .truth .number)
  | .operationName => .arrow .operation .spelling
  | .operationAfter => .arrow .source (.arrow .number (.arrow .operation (.arrow .truth
      (.arrow .number (.arrow .number (.arrow .number .number))))))
  | .associationAfter => .arrow .source (.arrow .number (.arrow .truth .number))
  | .packageNameAfter => .arrow .source (.arrow .number (.arrow .number (.arrow .number .number)))
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))

structure Calls where
  fixedAfter : Source → Nat → String → Bool → Nat
  take : Source → Nat → String → Bool → Nat
  token : Source → Nat → String → Bool → Bool
  trivia : Source → Nat → Nat
  identifier : Named.IdentifierCalls
  skipTrivia : Source → Nat → Nat
  matchIdentifier : Source → Nat → Nat × Bool
  packageNameAfter : Source → Nat → Nat → Nat → Nat
  contextStep : Source → State → Nat → Nat → State
  contextTail : Source → State → Nat → Nat → Names.Context
  contextModel : Source → Nat → Nat → Nat → Names.Context
  readContext : Source → Nat → Nat → Nat → Names.Context
  contextAfter : Source → Bool → Nat
  operationName : Operation → String
  operationAfter : Source → Nat → Operation → Bool → Nat → Nat → Nat → Nat
  associationAfter : Source → Nat → Bool → Nat

def Calls.get (calls : Calls) : (f : Function) → f.type.meaning
  | .fixedAfter => calls.fixedAfter | .take => calls.take | .token => calls.token | .trivia => calls.trivia
  | .contextStep => calls.contextStep | .contextTail => calls.contextTail | .contextModel => calls.contextModel
  | .readContext => calls.readContext | .contextAfter => calls.contextAfter | .operationName => calls.operationName
  | .operationAfter => calls.operationAfter | .associationAfter => calls.associationAfter
  | .packageNameAfter => calls.packageNameAfter | .equalName => calls.identifier.equal

inductive Field : Ty → Ty → Type
  | contextAfter : Field .context .number
  | ioWith : Field .context .truth | argumentsWith : Field .context .truth
  | ioUse : Field .context .truth | argumentsUse : Field .context .truth
  | stateContext : Field .state .context | stateMode : Field .state .mode | complete : Field .state .truth

def Field.name : Field a b → String
  | .contextAfter => "after" | .ioWith => "io_with" | .argumentsWith => "arguments_with"
  | .ioUse => "io_use" | .argumentsUse => "arguments_use"
  | .stateContext => "context" | .stateMode => "mode" | .complete => "complete"

def Field.get : Field a b → a.meaning → b.meaning
  | .contextAfter, value => value.after | .ioWith, value => value.ioWith
  | .argumentsWith, value => value.argumentsWith | .ioUse, value => value.ioUse
  | .argumentsUse, value => value.argumentsUse | .stateContext, value => value.context
  | .stateMode, value => value.mode | .complete, value => value.complete

def modeName : Mode → String
  | .clauseStart => "clause_start" | .withName => "with_name" | .useName => "use_name"
  | .withSeparator => "with_separator" | .useSeparator => "use_separator"

def operationName : Operation → String
  | .output => "output_call" | .partialOutput => "partial_output_call" | .argument => "argument_call"
  | .validity => "validity_call" | .reject => "reject_call"

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | truth (value : Bool) : Expr .truth
  | spelling (value : String) : Expr .spelling
  | mode (value : Mode) : Expr .mode
  | operation (value : Operation) : Expr .operation
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | add : Expr .number → Expr .number → Expr .number
  | length : Expr .spelling → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | truthEq : Expr .truth → Expr .truth → Expr .truth
  | modeEq : Expr .mode → Expr .mode → Expr .truth
  | operationEq : Expr .operation → Expr .operation → Expr .truth
  | modeChoices : Expr .mode → Expr .mode → Expr .mode → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name typeName : String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | context : Expr .number → Expr .truth → Expr .truth → Expr .truth → Expr .truth → Expr .context
  | state : Expr .context → Expr .mode → Expr .truth → Expr .state
  | updateAfter : Expr .context → Expr .number → Expr .context
  | updateState : Expr .state → Expr .context → Expr .mode → Expr .state
  | updateComplete : Expr .state → Expr .truth → Expr .state
  | updateContext : Expr .state → Expr .context → Expr .state
  | contextAt : Expr .number → Expr .context
  | readContextDefault : Expr .source → Expr .context
  | nameCase : Expr .operation → Expr .spelling → Expr .spelling → Expr .spelling → Expr .spelling → Expr .spelling → Expr .spelling
  | invalidContext : Expr .context
  | initialState : Expr .state
  | invalidState : Expr .state

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def aggregate (fields : List (String × List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","]
    (fields.map fun (name, value) => [name, "=>"] ++ value)) ++ [")"]

def Expr.render : Expr ty → List String
  | .number value => [toString value]
  | .truth value => [if value then "true" else "false"]
  | .spelling value => ["\"" ++ value ++ "\""]
  | .mode value => [modeName value] | .operation value => [operationName value]
  | .variable name => [name] | .function symbol => [symbol.name]
  | .app fn argument => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["("] ++ argument.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .length value => value.render ++ ["'", "length"]
  | .eq left right | .truthEq left right | .modeEq left right | .operationEq left right =>
      left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .modeChoices value first second => value.render ++ ["in"] ++ first.render ++ ["|"] ++ second.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .local name typeName value rest => [name, ":", "constant", typeName, ":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .context after iw aw iu au => aggregate [("after", after.render), ("io_with", iw.render),
      ("arguments_with", aw.render), ("io_use", iu.render), ("arguments_use", au.render)]
  | .state ctxExpr modeExpr complete => aggregate [("context", ctxExpr.render), ("mode", modeExpr.render),
      ("complete", complete.render)]
  | .updateAfter ctxExpr after => ["("] ++ ctxExpr.render ++ ["with", "delta", "after", "=>"] ++ after.render ++ [")"]
  | .updateState stateExpr ctxExpr modeExpr => ["("] ++ stateExpr.render ++ ["with", "delta", "context", "=>"] ++
      ctxExpr.render ++ [",", "mode", "=>"] ++ modeExpr.render ++ [")"]
  | .updateComplete stateExpr complete => ["("] ++ stateExpr.render ++ ["with", "delta", "complete", "=>"] ++ complete.render ++ [")"]
  | .updateContext stateExpr ctxExpr => ["("] ++ stateExpr.render ++ ["with", "delta", "context", "=>"] ++ ctxExpr.render ++ [")"]
  | .contextAt after => aggregate [("after", after.render), ("others", ["false"])]
  | .readContextDefault text => ["read_context", "("] ++ text.render ++ [")"]
  | .nameCase opExpr output partialOutput argument validity reject => ["case"] ++ opExpr.render ++ ["is", "when", "output_call", "=>"] ++
      output.render ++ [",", "when", "partial_output_call", "=>"] ++ partialOutput.render ++ [",", "when", "argument_call", "=>"] ++ argument.render ++ [",", "when", "validity_call", "=>"] ++
      validity.render ++ [",", "when", "reject_call", "=>"] ++ reject.render
  | .invalidContext => ["invalid_context"] | .initialState => ["initial_state"] | .invalidState => ["invalid_state"]

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .truth value => value | .spelling value => value
  | .mode value => value | .operation value => value
  | .variable name => locals _ name | .function symbol => calls.get symbol
  | .app fn argument => fn.eval calls locals (argument.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .add left right => left.eval calls locals + right.eval calls locals
  | .length value => (value.eval calls locals).toList.length
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .truthEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .modeEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .operationEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .modeChoices value first second => decide (value.eval calls locals = first.eval calls locals ∨ value.eval calls locals = second.eval calls locals)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .not value => !(value.eval calls locals)
  | .group value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no => if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .local name _ value rest => rest.eval calls (locals.set _ name (value.eval calls locals))
  | .locals body => body.eval calls locals
  | .context after iw aw iu au => ⟨after.eval calls locals, iw.eval calls locals, aw.eval calls locals, iu.eval calls locals, au.eval calls locals⟩
  | .state ctxExpr modeExpr complete => ⟨ctxExpr.eval calls locals, modeExpr.eval calls locals, complete.eval calls locals⟩
  | .updateAfter ctxExpr after => {ctxExpr.eval calls locals with after := after.eval calls locals}
  | .updateState stateExpr ctxExpr modeExpr => {stateExpr.eval calls locals with context := ctxExpr.eval calls locals, mode := modeExpr.eval calls locals}
  | .updateComplete stateExpr complete => {stateExpr.eval calls locals with complete := complete.eval calls locals}
  | .updateContext stateExpr ctxExpr => {stateExpr.eval calls locals with context := ctxExpr.eval calls locals}
  | .contextAt after => {after := after.eval calls locals}
  | .readContextDefault text => calls.readContext (text.eval calls locals) 1 0 0
  | .nameCase opExpr output partialOutput argument validity reject => match opExpr.eval calls locals with
    | .output => output.eval calls locals | .partialOutput => partialOutput.eval calls locals | .argument => argument.eval calls locals
    | .validity => validity.eval calls locals | .reject => reject.eval calls locals
  | .invalidContext => Names.invalidContext | .initialState => Names.initialState | .invalidState => Names.invalidState

structure Context where
  text : Source := []
  position : Nat := 0
  word : String := ""
  isWord : Bool := false
  state : State := invalidState
  arguments : Bool := false
  operation : Operation := .output
  hidden : Bool := false
  default : Bool := false
  contextFirst : Nat := 1
  packageFirst : Nat := 0
  packageAfter : Nat := 0

def Context.locals (ctx : Context) : Locals
  | .source, "text" => ctx.text | .number, "position" => ctx.position
  | .spelling, "word" => ctx.word | .truth, "is_word" => ctx.isWord
  | .state, "state" => ctx.state | .truth, "arguments" => ctx.arguments
  | .operation, "operation" => ctx.operation | .truth, "hidden" => ctx.hidden
  | .truth, "default" => ctx.default
  | .number, "context_first" => ctx.contextFirst
  | .number, "package_first" => ctx.packageFirst
  | .number, "package_after" => ctx.packageAfter
  | ty, _ => ty.default

def fixedBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let word : Expr .spelling := .variable "word"
  let isWord : Expr .truth := .variable "is_word"
  let trivia := Expr.app (.app (.function .trivia) text) position
  .ite (.eq position (.number 0)) (.number 0)
    (.elsif (.app (.app (.app (.app (.function .token) text) trivia) word) isWord)
      (.add trivia (.length word)) (.number 0))

def stepBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let context := Expr.field .stateContext state
  let after := Expr.field .contextAfter context
  let mode := Expr.field .stateMode state
  let w : Expr .number := .variable "w"
  let u : Expr .number := .variable "u"
  let i : Expr .number := .variable "i"
  let a : Expr .number := .variable "a"
  let p : Expr .number := .variable "p"
  let s : Expr .number := .variable "s"
  let c : Expr .number := .variable "c"
  let take (word : String) (isWord : Bool) := Expr.app (.app (.app (.app (.function .take) text) after) (.spelling word)) (.truth isWord)
  let present (value : Expr .number) := Expr.ne value (.number 0)
  let inMode (value : Mode) := Expr.modeEq mode (.mode value)
  let next (position : Expr .number) (mode : Expr .mode) := Expr.updateState state (.updateAfter context position) mode
  let flag (field : Field .context .truth) (position : Expr .number) (mode : Mode) :=
    Expr.orElse (.field field context) (.group (.andThen (present position) (inMode mode)))
  .ite (.eq after (.number 0)) .invalidState
    (.elsif (.field .complete state) state
      (.elsif (inMode .clauseStart)
        (.group <| .locals <| .local "w" "literal_position" (take "with" true) <|
          .local "u" "literal_position" (take "use" true) <|
          .group <| .ite (present w) (next w (.mode .withName))
            (.elsif (present u) (next u (.mode .useName)) (.updateComplete state (.truth true))))
        (.elsif (.modeChoices mode (.mode .withName) (.mode .useName))
          (.group <| .locals <| .local "i" "literal_position" (take "silver_io" true) <|
            .local "a" "literal_position" (take "silver_arguments" true) <|
            .local "p" "literal_position" (.group (.ite (inMode .withName)
              (.app (.app (.app (.app (.function .packageNameAfter) text) after)
                (.variable "package_first")) (.variable "package_after")) (.number 0))) <|
            .group <| .ite (.andThen (.andThen (.eq i (.number 0)) (.eq a (.number 0))) (.eq p (.number 0))) .invalidState
              (.elsif (.andThen (inMode .useName)
                (.group (.orElse
                  (.group (.andThen (present i) (.not (.field .ioWith context))))
                  (.group (.andThen (present a) (.not (.field .argumentsWith context))))))) .invalidState
                (.state (.context (.group (.ite (present i) i (.elsif (present a) a p)))
                  (flag .ioWith i .withName) (flag .argumentsWith a .withName)
                  (flag .ioUse i .useName) (flag .argumentsUse a .useName))
                  (.group (.ite (inMode .withName) (.mode .withSeparator) (.mode .useSeparator))) (.truth false))))
          (.group <| .locals <| .local "s" "literal_position" (take ";" false) <|
            .local "c" "literal_position" (take "," false) <|
            .group <| .ite (present s) (next s (.mode .clauseStart))
              (.elsif (present c)
                (next c (.group (.ite (inMode .withSeparator) (.mode .withName) (.mode .useName))))
                .invalidState)))))

def tailBody : Expr .context :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let context := Expr.field .stateContext state
  let next : Expr .state := .variable "next"
  let tail (value : Expr .state) : Expr .context :=
    .app (.app (.app (.app (.function .contextTail) text) value)
      (.variable "package_first")) (.variable "package_after")
  let step := Expr.app (.app (.app (.app (.function .contextStep) text) state)
    (.variable "package_first")) (.variable "package_after")
  .ite (.eq (.field .contextAfter context) (.number 0)) .invalidContext
    (.elsif (.field .complete state) context
      (.group <| .locals <| .local "next" "context_state" step <|
        .group <| .ite (.eq (.field .contextAfter (.field .stateContext next)) (.number 0)) .invalidContext
          (tail next)))

def modelBody : Expr .context :=
  .app (.app (.app (.app (.function .contextTail) (.variable "text"))
    (.updateContext .initialState (.contextAt (.variable "context_first"))))
      (.variable "package_first")) (.variable "package_after")

def contextBody : Expr .number :=
  let context : Expr .context := .variable "context"
  .locals <| .local "context" "context_result" (.readContextDefault (.variable "text")) <|
    .group <| .ite (.andThen (.field .ioWith context) (.truthEq (.field .argumentsWith context) (.variable "arguments")))
      (.field .contextAfter context) (.number 0)

def nameBody : Expr .spelling := .nameCase (.variable "operation")
  (.spelling "put_line") (.spelling "put") (.spelling "first_or_default") (.spelling "input_is_valid") (.spelling "reject")

def operationBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let context : Expr .context := .variable "context"
  let operation : Expr .operation := .variable "operation"
  let qualified : Expr .number := .variable "qualified"
  let output := Expr.orElse (.operationEq operation (.operation .output))
    (.operationEq operation (.operation .partialOutput))
  let take (position : Expr .number) (word : Expr .spelling) (isWord : Bool) :=
    Expr.app (.app (.app (.app (.function .take) text) position) word) (.truth isWord)
  .locals <| .local "context" "context_result"
    (.app (.app (.app (.app (.function .readContext) text) (.variable "context_first"))
      (.variable "package_first")) (.variable "package_after")) <|
    .local "visible" "boolean" (.group (.ite output (.field .ioWith context) (.field .argumentsWith context))) <|
    .local "used" "boolean" (.group (.ite output (.field .ioUse context) (.field .argumentsUse context))) <|
    .local "qualified" "literal_position"
      (take (take position (.group (.ite output (.spelling "silver_io") (.spelling "silver_arguments"))) true) (.spelling ".") false) <|
    .group <| .ite (.orElse (.eq (.field .contextAfter context) (.number 0)) (.not (.variable "visible"))) (.number 0)
      (.elsif (.ne qualified (.number 0)) (take qualified (.app (.function .operationName) operation) true)
        (.elsif (.andThen (.variable "used") (.not (.variable "hidden")))
          (take position (.app (.function .operationName) operation) true) (.number 0)))

def associationBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let named : Expr .number := .variable "named"
  let take (position : Expr .number) (word : Expr .spelling) (isWord : Bool) :=
    Expr.app (.app (.app (.app (.function .take) text) position) word) (.truth isWord)
  .locals <| .local "named" "literal_position"
    (take (take position (.group (.ite (.variable "default") (.spelling "default") (.spelling "item"))) true) (.spelling "=>") false) <|
    .group <| .ite (.ne named (.number 0)) named position

/-! Expression categories check that rendering respects Ada precedence. -/
def Expr.primary : Expr ty → Bool
  | .number _ | .truth _ | .spelling _ | .mode _ | .operation _ | .variable _ | .function _
  | .app _ _ | .field _ _ | .length _ | .group _ | .context _ _ _ _ _ | .state _ _ _
  | .updateAfter _ _ | .updateState _ _ _ | .updateComplete _ _ | .updateContext _ _
  | .contextAt _ | .readContextDefault _
  | .invalidContext | .initialState | .invalidState => true
  | _ => false

def Expr.simple : Expr ty → Bool
  | .add _ _ => true | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .truthEq _ _ | .modeEq _ _ | .operationEq _ _ | .modeChoices _ _ _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr ty → Bool | .andThen _ _ => true | value => value.relation

def Expr.orHead : Expr ty → Bool | .orElse _ _ => true | value => value.relation

def Expr.condition (value : Expr .truth) : Bool := value.andHead || value.orHead

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false

def Expr.functionSpine : Expr ty → Bool | .function _ => true | .app fn _ => fn.functionSpine | _ => false

def localType (ty : Ty) (name : String) : Bool :=
  match ty with
  | .number => name == "literal_position"
  | .truth => name == "boolean"
  | .source | .spelling => name == "string"
  | .operation => name == "operation_kind"
  | .mode => name == "context_mode"
  | .context => name == "context_result"
  | .state => name == "context_state"
  | .arrow _ _ => false

def Expr.wellFormed : Expr ty → Bool
  | .app fn argument => fn.wellFormed && argument.wellFormed && fn.functionSpine && argument.simple
  | .field _ value | .length value => value.wellFormed && value.primary
  | .add left right => left.wellFormed && right.wellFormed && left.simple && right.primary
  | .eq left right | .ne left right | .truthEq left right | .modeEq left right | .operationEq left right =>
      left.wellFormed && right.wellFormed && left.simple && right.simple
  | .modeChoices value first second => value.wellFormed && first.wellFormed && second.wellFormed && value.simple && first.simple && second.simple
  | .andThen left right => left.wellFormed && right.wellFormed && left.andHead && right.relation
  | .orElse left right => left.wellFormed && right.wellFormed && left.orHead && right.relation
  | .not value => value.wellFormed && value.primary
  | .group value => value.wellFormed && !value.isElsif
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.condition && yes.wellFormed && yes.simple && no.wellFormed && (no.simple || no.isElsif)
  | .local (a := localTy) _ typeName value rest => localType localTy typeName && value.wellFormed && value.simple && rest.wellFormed && (rest.isLocal || rest.primary)
  | .locals body => body.wellFormed && body.isLocal
  | .context after iw aw iu au => after.wellFormed && after.simple && iw.wellFormed && iw.condition &&
      aw.wellFormed && aw.condition && iu.wellFormed && iu.condition && au.wellFormed && au.condition
  | .state ctxExpr modeExpr complete => ctxExpr.wellFormed && ctxExpr.simple && modeExpr.wellFormed && modeExpr.simple && complete.wellFormed && complete.condition
  | .updateAfter ctxExpr after => ctxExpr.wellFormed && ctxExpr.primary && after.wellFormed && after.simple
  | .updateState stateExpr ctxExpr modeExpr => stateExpr.wellFormed && stateExpr.primary && ctxExpr.wellFormed && ctxExpr.simple && modeExpr.wellFormed && modeExpr.simple
  | .updateComplete stateExpr complete => stateExpr.wellFormed && stateExpr.primary && complete.wellFormed && complete.condition
  | .updateContext stateExpr ctxExpr => stateExpr.wellFormed && stateExpr.primary && ctxExpr.wellFormed && ctxExpr.simple
  | .contextAt after => after.wellFormed && after.simple
  | .readContextDefault text => text.wellFormed && text.simple
  | .nameCase opExpr output partialOutput argument validity reject => opExpr.wellFormed && opExpr.simple &&
      output.wellFormed && output.simple && partialOutput.wellFormed && partialOutput.simple && argument.wellFormed && argument.simple &&
      validity.wellFormed && validity.simple && reject.wellFormed && reject.simple
  | _ => true

abbrev WellFormedTrees : Prop := fixedBody.wellFormed = true ∧ stepBody.wellFormed = true ∧
  tailBody.wellFormed = true ∧ modelBody.wellFormed = true ∧ contextBody.wellFormed = true ∧
  nameBody.wellFormed = true ∧ operationBody.wellFormed = true ∧ associationBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

abbrev Scope := List (String × Ty)

def Scope.contains (scope : Scope) (name : String) (ty : Ty) : Bool :=
  ((scope.find? (fun entry => entry.1 == name)).map Prod.snd) == some ty

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .variable name => scope.contains name ty
  | .app fn argument => fn.scoped scope && argument.scoped scope
  | .field _ value | .length value | .not value | .group value | .locals value
  | .contextAt value | .readContextDefault value => value.scoped scope
  | .add left right | .eq left right | .ne left right | .truthEq left right | .modeEq left right
  | .operationEq left right | .andThen left right | .orElse left right | .updateAfter left right
  | .updateComplete left right | .updateContext left right => left.scoped scope && right.scoped scope
  | .modeChoices value first second | .ite value first second | .elsif value first second
  | .state value first second | .updateState value first second =>
      value.scoped scope && first.scoped scope && second.scoped scope
  | .local (a := localTy) name _ value rest => value.scoped scope && rest.scoped ((name, localTy) :: scope)
  | .context after iw aw iu au => after.scoped scope && iw.scoped scope && aw.scoped scope && iu.scoped scope && au.scoped scope
  | .nameCase opExpr output partialOutput argument validity reject => opExpr.scoped scope && output.scoped scope && partialOutput.scoped scope && argument.scoped scope && validity.scoped scope && reject.scoped scope
  | _ => true

abbrev WellScopedTrees : Prop :=
  fixedBody.scoped [("text", .source), ("position", .number), ("word", .spelling), ("is_word", .truth)] = true ∧
  stepBody.scoped [("text", .source), ("state", .state), ("package_first", .number), ("package_after", .number)] = true ∧
  tailBody.scoped [("text", .source), ("state", .state), ("package_first", .number), ("package_after", .number)] = true ∧
  modelBody.scoped [("text", .source), ("context_first", .number), ("package_first", .number), ("package_after", .number)] = true ∧
  contextBody.scoped [("text", .source), ("arguments", .truth)] = true ∧
  nameBody.scoped [("operation", .operation)] = true ∧
  operationBody.scoped [("text", .source), ("position", .number), ("operation", .operation), ("hidden", .truth),
    ("context_first", .number), ("package_first", .number), ("package_after", .number)] = true ∧
  associationBody.scoped [("text", .source), ("position", .number), ("default", .truth)] = true

theorem checked_scopes : WellScopedTrees := by decide +kernel

/-- The imperative matcher has only assignments, two lexical procedure calls,
and early returns. Its statement semantics does not assume a matcher equation. -/
inductive Statement where
  | returnValue : Expr .number → Statement
  | returnIf : Expr .truth → Expr .number → Statement → Statement
  | setNumber : String → Expr .number → Statement → Statement
  | skipTrivia : Expr .source → String → Statement → Statement
  | matchIdentifier : Expr .source → String → String → Statement → Statement

def Statement.render : Statement → List String
  | .returnValue value => ["return"] ++ value.render ++ [";"]
  | .returnIf condition value rest => ["if"] ++ condition.render ++ ["then", "return"] ++
      value.render ++ [";", "end", "if", ";"] ++ rest.render
  | .setNumber name value rest => [name, ":="] ++ value.render ++ [";"] ++ rest.render
  | .skipTrivia text position rest => ["skip_trivia", "("] ++ text.render ++
      [",", position, ")", ";"] ++ rest.render
  | .matchIdentifier text position matched rest => ["match_identifier", "("] ++
      text.render ++ [",", position, ",", matched, ")", ";"] ++ rest.render

def Statement.eval (calls : Calls) (locals : Locals) : Statement → Nat
  | .returnValue value => value.eval calls locals
  | .returnIf condition value rest =>
      if condition.eval calls locals then value.eval calls locals else rest.eval calls locals
  | .setNumber name value rest =>
      rest.eval calls (locals.set .number name (value.eval calls locals))
  | .skipTrivia text position rest =>
      rest.eval calls (locals.set .number position
        (calls.skipTrivia (text.eval calls locals) (locals .number position)))
  | .matchIdentifier text position matched rest =>
      let result := calls.matchIdentifier (text.eval calls locals) (locals .number position)
      rest.eval calls ((locals.set .number position result.1).set .truth matched result.2)

def Statement.wellFormed : Statement → Bool
  | .returnValue value => value.wellFormed && value.simple
  | .returnIf condition value rest => condition.wellFormed && condition.condition &&
      value.wellFormed && value.simple && rest.wellFormed
  | .setNumber _ value rest => value.wellFormed && value.simple && rest.wellFormed
  | .skipTrivia text _ rest | .matchIdentifier text _ _ rest =>
      text.wellFormed && text.simple && rest.wellFormed

/-- Reads require initialization. Procedure out-parameters become initialized
only after their call; the failed match cursor is not strengthened here. -/
def Statement.scoped (declared initialized : Scope) : Statement → Bool
  | .returnValue value => value.scoped initialized
  | .returnIf condition value rest => condition.scoped initialized &&
      value.scoped initialized && rest.scoped declared initialized
  | .setNumber name value rest => declared.contains name .number && value.scoped initialized &&
      rest.scoped declared ((name, .number) :: initialized)
  | .skipTrivia text position rest => text.scoped initialized &&
      declared.contains position .number && initialized.contains position .number &&
      rest.scoped declared initialized
  | .matchIdentifier text position matched rest => text.scoped initialized &&
      declared.contains position .number && initialized.contains position .number &&
      declared.contains matched .truth &&
      rest.scoped declared ((matched, .truth) :: initialized)

structure LocalDeclaration where
  names : List String
  nativeType : String
  ty : Ty

def LocalDeclaration.render (decl : LocalDeclaration) : List String :=
  List.intersperse "," decl.names ++ [":", decl.nativeType, ";"]

def LocalDeclaration.scope (decl : LocalDeclaration) : Scope := decl.names.map (·, decl.ty)

def LocalDeclaration.wellFormed (decl : LocalDeclaration) : Bool :=
  !decl.names.isEmpty && (localType decl.ty decl.nativeType ||
    (decl.ty == .number && decl.nativeType == "cursor"))

def packageDeclarations : List LocalDeclaration :=
  [⟨["first", "after"], "literal_position", .number⟩,
   ⟨["next"], "cursor", .number⟩, ⟨["matched"], "boolean", .truth⟩]

def packageParameters : Scope :=
  [("text", .source), ("position", .number), ("package_first", .number), ("package_after", .number)]

def packageBody : Statement :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let next : Expr .number := .variable "next"
  let packageFirst : Expr .number := .variable "package_first"
  let packageAfter : Expr .number := .variable "package_after"
  .returnIf (.orElse (.eq position (.number 0)) (.eq packageFirst (.number 0))) (.number 0) <|
    .setNumber "next" position <|
    .skipTrivia text "next" <|
    .setNumber "first" next <|
    .matchIdentifier text "next" "matched" <|
    .returnIf (.not (.variable "matched")) (.number 0) <|
    .setNumber "after" next <|
    .returnIf (.app (.app (.app (.app (.app (.function .equalName) text) first) after)
      packageFirst) packageAfter) after <|
    .returnValue (.number 0)

def packageImplementation : List String :=
  packageDeclarations.flatMap LocalDeclaration.render ++ ["begin"] ++ packageBody.render ++
    ["end", "package_name_after", ";"]

abbrev PackageTranslation : Prop :=
  packageDeclarations.all LocalDeclaration.wellFormed = true ∧
  ((packageDeclarations.flatMap LocalDeclaration.scope ++ packageParameters).map Prod.fst).Nodup ∧
  packageBody.wellFormed = true ∧
  packageBody.scoped (packageDeclarations.flatMap LocalDeclaration.scope ++ packageParameters)
    packageParameters = true

theorem checked_package_translation : PackageTranslation := by decide +kernel

end Silver.Names.Native

namespace Silver.Names
abbrev Calls := Native.Calls
end Silver.Names
