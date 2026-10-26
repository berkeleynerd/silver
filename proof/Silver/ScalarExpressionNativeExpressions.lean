module

public import Silver.ScalarExpressionNativeModel

@[expose] public section

/-! Typed source-expression trees. Rendering is checked against the actual
Ada bodies; evaluation leaves every source call arbitrary until equations and
their well-founded uniqueness theorem identify the implementation. -/
namespace Silver.ScalarExpression.Native

inductive Ty
  | number | integer | truth | source | environment | binding | interval | check | literal | result
  | arrow (domain codomain : Ty)
  deriving DecidableEq

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .integer => Int | .truth => Bool | .source => Source
  | .environment => Environment | .binding => Binding | .interval => Integer.Interval
  | .check => Integer.CheckResult | .literal => ScalarLiteral.Result | .result => Result
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .integer => 0 | .truth => false | .source => [] | .environment => []
  | .binding => emptyBinding | .interval => Integer.Interval.empty
  | .check => ⟨false, Integer.Interval.empty⟩ | .literal => ScalarLiteral.invalid | .result => invalid
  | .arrow _ b => fun _ => b.default

inductive Function
  | lookupModel | lookup | skip | symbol | nameAfter | binaryAfter | nameIs | lowercase
  | literalResult | unaryResult | binaryResult | closeResult
  | readAtom | readUnary | readCompound | readGroup | readExpression | readExpressionDefault
  | integerLiteral | equalName | scalarChecked | scalarNegate | scalarAdd | scalarSubtract | scalarMultiply | scalarDivide | scalarModulo | scalarRemainder | scalarNormalize
  deriving DecidableEq

def Function.name : Function → List String
  | .lookupModel => ["lookup_model"] | .lookup => ["lookup"] | .skip => ["skip"]
  | .symbol => ["symbol"] | .nameAfter => ["name_after"]
  | .binaryAfter => ["binary_after"] | .nameIs => ["name_is"] | .lowercase => ["lowercase"]
  | .literalResult => ["literal_result"] | .unaryResult => ["unary_result"]
  | .binaryResult => ["binary_result"] | .closeResult => ["close_result"]
  | .readAtom => ["read_atom"] | .readUnary => ["read_unary"] | .readCompound => ["read_compound"]
  | .readGroup => ["read_group"] | .readExpression | .readExpressionDefault => ["read_expression"]
  | .integerLiteral => ["silver_scalar_literals", ".", "read_integer"]
  | .equalName => ["equal_name"] | .scalarChecked => ["scalars", ".", "checked"]
  | .scalarNegate => ["scalars", ".", "negate"] | .scalarAdd => ["scalars", ".", "add"]
  | .scalarSubtract => ["scalars", ".", "subtract"] | .scalarMultiply => ["scalars", ".", "multiply"]
  | .scalarDivide => ["scalars", ".", "divide"]
  | .scalarModulo => ["scalars", ".", "modulo"]
  | .scalarRemainder => ["scalars", ".", "remainder"]
  | .scalarNormalize => ["scalars", ".", "normalize"]

def Function.type : Function → Ty
  | .lookupModel => .arrow .source (.arrow .environment (.arrow .number (.arrow .number (.arrow .number .number))))
  | .lookup => .arrow .source (.arrow .environment (.arrow .number (.arrow .number .number)))
  | .skip | .nameAfter | .binaryAfter => .arrow .source (.arrow .number .number)
  | .nameIs => .arrow .source (.arrow .number (.arrow .number (.arrow .source .truth)))
  | .lowercase => .arrow .number .number
  | .symbol => .arrow .source (.arrow .number (.arrow .number .number))
  | .literalResult => .arrow .literal (.arrow .truth .result)
  | .unaryResult => .arrow .result (.arrow .truth .result)
  | .binaryResult => .arrow .result (.arrow .result (.arrow .number .result))
  | .closeResult => .arrow .source (.arrow .result .result)
  | .readAtom | .readExpression => .arrow .source (.arrow .number (.arrow .environment
      (.arrow .number (.arrow .number (.arrow .truth .result)))))
  | .readUnary | .readGroup | .readExpressionDefault => .arrow .source (.arrow .number (.arrow .environment
      (.arrow .number (.arrow .number .result))))
  | .readCompound => .arrow .source (.arrow .number (.arrow .environment
      (.arrow .result (.arrow .number (.arrow .number .result)))))
  | .integerLiteral => .arrow .source (.arrow .number .literal)
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))
  | .scalarChecked => .arrow .integer (.arrow .integer .check)
  | .scalarNegate => .arrow .interval .check
  | .scalarAdd | .scalarSubtract | .scalarMultiply | .scalarDivide | .scalarModulo | .scalarRemainder => .arrow .interval (.arrow .interval .check)
  | .scalarNormalize => .arrow .interval .interval

def Calls.get (calls : Calls) : (fn : Function) → fn.type.meaning
  | .lookupModel => calls.lookupModel | .lookup => calls.lookup | .skip => calls.skip
  | .symbol => calls.symbol | .nameAfter => calls.nameAfter
  | .binaryAfter => calls.binaryAfter | .nameIs => calls.nameIs | .lowercase => calls.lowercase
  | .literalResult => calls.literalResult | .unaryResult => calls.unaryResult
  | .binaryResult => calls.binaryResult | .closeResult => calls.closeResult
  | .readAtom => calls.readAtom | .readUnary => calls.readUnary | .readCompound => calls.readCompound
  | .readGroup => calls.readGroup | .readExpression => calls.readExpression
  | .readExpressionDefault => fun text position names maskFirst maskAfter =>
      calls.readExpression text position names maskFirst maskAfter true
  | .integerLiteral => calls.integerLiteral | .equalName => calls.equalName
  | .scalarChecked => calls.scalars.checked | .scalarNegate => calls.scalars.negate
  | .scalarAdd => calls.scalars.add | .scalarSubtract => calls.scalars.subtract
  | .scalarMultiply => calls.scalars.multiply | .scalarNormalize => calls.scalars.normalize
  | .scalarDivide => calls.scalars.divide | .scalarModulo => calls.scalars.modulo
  | .scalarRemainder => calls.scalars.remainder

inductive Field : Ty → Ty → Type
  | resultAfter : Field .result .number | literalAfter : Field .literal .number
  | bindingFirst : Field .binding .number | bindingAfter : Field .binding .number
  | bindingBounds : Field .binding .interval | resultBounds : Field .result .interval
  | checkBounds : Field .check .interval | checkSafe : Field .check .truth
  | bindingStatic : Field .binding .truth | resultStatic : Field .result .truth
  | resultOperands : Field .result .number | literalValue : Field .literal .integer
  | count : Field .environment .number

def Field.name : Field a b → String
  | .resultAfter | .literalAfter | .bindingAfter => "after" | .bindingFirst => "first"
  | .bindingBounds | .resultBounds | .checkBounds => "bounds" | .checkSafe => "safe"
  | .bindingStatic | .resultStatic => "static" | .resultOperands => "operands"
  | .literalValue => "value" | .count => "count"

def Field.get : Field a b → a.meaning → b.meaning
  | .resultAfter, value => value.after | .literalAfter, value => value.after
  | .bindingFirst, value => value.first | .bindingAfter, value => value.after
  | .bindingBounds, value => value.bounds | .resultBounds, value => value.bounds
  | .checkBounds, value => value.bounds | .checkSafe, value => value.safe
  | .bindingStatic, value => value.isStatic | .resultStatic, value => value.isStatic
  | .resultOperands, value => value.operands | .literalValue, value => Int.ofNat value.value
  | .count, value => value.length

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | word (value : String) : Expr .source
  | character (value : Nat) : Expr .number
  | characterVal (value : Nat) : Expr .number
  | truth (value : Bool) : Expr .truth
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | binding : Expr .environment → Expr .number → Expr .binding
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | neg : Expr .integer → Expr .integer
  | byteAt : Expr .source → Expr .number → Expr .number
  | last : Expr .source → Expr .number
  | maxOperands : Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | choices : Expr .number → Expr .number → Expr .number → Expr .truth
  | operators : Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name : String) (typeName : List String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | result : Expr .number → Expr .interval → Expr .number → Expr .truth → Expr .result
  | check : Expr .truth → Expr .interval → Expr .check
  | deltaAfter : Expr .result → Expr .number → Expr .result
  | deltaBounds : Expr .result → Expr .interval → Expr .result
  | operatorCase : Expr .number → Expr .check → Expr .check → Expr .check → Expr .check → Expr .check → Expr .check → Expr .check → Expr .check
  | invalid : Expr .result
  | invalidCheck : Expr .check

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def positional (values : List (List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","] values) ++ [")"]

def Expr.render : Expr ty → List String
  | .number value => [toString value]
  | .word value => ["\"" ++ value ++ "\""]
  | .character value => ["'" ++ String.singleton (Char.ofNat value) ++ "'"]
  | .characterVal value => ["character", "'", "val", "(", toString value, ")"]
  | .truth value => [if value then "true" else "false"]
  | .variable name => [name] | .function fn => fn.name
  | .app fn argument => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["("] ++ argument.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .binding names index => names.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .neg value => ["-"] ++ value.render
  | .byteAt text position => text.render ++ ["("] ++ position.render ++ [")"]
  | .last text => text.render ++ ["'", "last"] | .maxOperands => ["max_operands"]
  | .eq left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .lt left right => left.render ++ ["<"] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .gt left right => left.render ++ [">"] ++ right.render
  | .choices item left right => item.render ++ ["in"] ++ left.render ++ ["|"] ++ right.render
  | .operators item => item.render ++ ["in", "'+'", "|", "'-'", "|", "'*'"]
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .local name typeName value rest => [name, ":", "constant"] ++ typeName ++ [":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .result after bounds operands static => positional [after.render, bounds.render, operands.render, static.render]
  | .check safe bounds => positional [safe.render, bounds.render]
  | .deltaAfter value after => ["("] ++ value.render ++ ["with", "delta", "after", "=>"] ++ after.render ++ [")"]
  | .deltaBounds value bounds => ["("] ++ value.render ++ ["with", "delta", "bounds", "=>"] ++ bounds.render ++ [")"]
  | .operatorCase operator adding subtracting multiplying dividing modulo remainder otherwise =>
      ["case"] ++ operator.render ++ ["is", "when", "'+'", "=>"] ++ adding.render ++
      [",", "when", "'-'", "=>"] ++ subtracting.render ++ [",", "when", "'*'", "=>"] ++
      multiplying.render ++ [",", "when", "'/'", "=>"] ++ dividing.render ++
      [",", "when", "'m'", "=>"] ++ modulo.render ++
      [",", "when", "'r'", "=>"] ++ remainder.render ++
      [",", "when", "others", "=>"] ++ otherwise.render
  | .invalid => ["invalid"] | .invalidCheck => ["scalars", ".", "invalid"]

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value | .character value | .characterVal value => value
  | .word value => value.toList.map Char.toNat
  | .truth value => value | .variable name => locals _ name | .function fn => calls.get fn
  | .app fn argument => fn.eval calls locals (argument.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .binding names index => ScalarExpression.binding (names.eval calls locals) (index.eval calls locals)
  | .add left right => left.eval calls locals + right.eval calls locals
  | .sub left right => left.eval calls locals - right.eval calls locals
  | .neg value => -value.eval calls locals
  | .byteAt text position => Cursor.byteAt (text.eval calls locals) (position.eval calls locals)
  | .last text => (text.eval calls locals).length | .maxOperands => ScalarExpression.maxOperands
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .lt left right => decide (left.eval calls locals < right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .gt left right => decide (left.eval calls locals > right.eval calls locals)
  | .choices item left right => decide (item.eval calls locals = left.eval calls locals ∨ item.eval calls locals = right.eval calls locals)
  | .operators item => decide (item.eval calls locals = 43 ∨ item.eval calls locals = 45 ∨ item.eval calls locals = 42)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .not value => !(value.eval calls locals) | .group value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .local name _ value rest => rest.eval calls (locals.set _ name (value.eval calls locals))
  | .locals body => body.eval calls locals
  | .result after bounds operands static => ⟨after.eval calls locals, bounds.eval calls locals,
      operands.eval calls locals, static.eval calls locals⟩
  | .check safe bounds => ⟨safe.eval calls locals, bounds.eval calls locals⟩
  | .deltaAfter value after => {value.eval calls locals with after := after.eval calls locals}
  | .deltaBounds value bounds => {value.eval calls locals with bounds := bounds.eval calls locals}
  | .operatorCase operator adding subtracting multiplying dividing modulo remainder otherwise =>
      if operator.eval calls locals = 43 then adding.eval calls locals
      else if operator.eval calls locals = 45 then subtracting.eval calls locals
      else if operator.eval calls locals = 42 then multiplying.eval calls locals
      else if operator.eval calls locals = 47 then dividing.eval calls locals
      else if operator.eval calls locals = 109 then modulo.eval calls locals
      else if operator.eval calls locals = 114 then remainder.eval calls locals else otherwise.eval calls locals
  | .invalid => ScalarExpression.invalid | .invalidCheck => ⟨false, Integer.Interval.empty⟩

structure Context where
  text : Source := []
  position : Nat := 0
  names : Environment := []
  first : Nat := 0
  after : Nat := 0
  index : Nat := 0
  maskFirst : Nat := 0
  maskAfter : Nat := 0
  allowSign : Bool := true
  negative : Bool := false
  operator : Nat := 0
  item : Nat := 0
  number : ScalarLiteral.Result := ScalarLiteral.invalid
  operand : Result := invalid
  value : Result := invalid
  left : Result := invalid
  right : Result := invalid

def Context.locals (context : Context) : Locals
  | .source, "text" => context.text | .environment, "names" => context.names
  | .number, "position" => context.position | .number, "first" => context.first
  | .number, "after" => context.after | .number, "index" => context.index
  | .number, "mask_first" => context.maskFirst | .number, "mask_after" => context.maskAfter
  | .number, "operator" => context.operator | .number, "item" => context.item
  | .truth, "allow_sign" => context.allowSign | .truth, "negative" => context.negative
  | .literal, "number" => context.number | .result, "operand" => context.operand
  | .result, "value" => context.value | .result, "left" => context.left | .result, "right" => context.right
  | ty, _ => ty.default

def apply2 {a b c : Ty} (fn : Expr (.arrow a (.arrow b c))) (x : Expr a) (y : Expr b) : Expr c :=
  .app (.app fn x) y
def apply3 {a b c d : Ty} (fn : Expr (.arrow a (.arrow b (.arrow c d))))
    (x : Expr a) (y : Expr b) (z : Expr c) : Expr d := .app (apply2 fn x y) z
def apply4 {a b c d e : Ty} (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (w : Expr a) (x : Expr b) (y : Expr c) (z : Expr d) : Expr e := .app (apply3 fn w x y) z
def apply5 {a b c d e f : Ty} (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (v : Expr a) (w : Expr b) (x : Expr c) (y : Expr d) (z : Expr e) : Expr f := .app (apply4 fn v w x y) z
def apply6 {a b c d e f g : Ty} (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f g)))))))
    (u : Expr a) (v : Expr b) (w : Expr c) (x : Expr d) (y : Expr e) (z : Expr f) : Expr g :=
  .app (apply5 fn u v w x y) z

def lookupBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let names : Expr .environment := .variable "names"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let item := Expr.binding names index
  .ite (.orElse (.orElse (.eq first (.number 0)) (.le after first)) (.eq index (.number 0))) (.number 0)
    (.elsif (apply5 (.function .equalName) text (.field .bindingFirst item) (.field .bindingAfter item) first after)
      index (apply5 (.function .lookupModel) text names first after (.sub index (.number 1))))

def symbolBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let first : Expr .number := .variable "first"
  .locals <| .local "first" ["literal_position"]
    (apply2 (.function .skip) text (.variable "position")) <|
    .group <| .ite (.orElse (.orElse (.eq first (.number 0)) (.gt first (.last text)))
      (.ne (.byteAt text first) (.variable "item"))) (.number 0) (.add first (.number 1))

def literalBody : Expr .result :=
  let number : Expr .literal := .variable "number"
  let value := Expr.field .literalValue number
  let signed := Expr.group (.ite (.variable "negative") (.neg value) value)
  let checked : Expr .check := .variable "checked"
  .locals <| .local "checked" ["scalars", ".", "check_result"]
    (apply2 (.function .scalarChecked) signed signed) <|
    .group <| .ite (.orElse (.eq (.field .literalAfter number) (.number 0)) (.not (.field .checkSafe checked)))
      .invalid (.result (.field .literalAfter number) (.field .checkBounds checked) (.number 1) (.truth true))

def unaryBody : Expr .result :=
  let operand : Expr .result := .variable "operand"
  let checked : Expr .check := .variable "checked"
  .locals <| .local "checked" ["scalars", ".", "check_result"]
    (.group <| .ite (.variable "negative") (.app (.function .scalarNegate) (.field .resultBounds operand))
      (.check (.truth true) (.field .resultBounds operand))) <|
    .group <| .ite (.orElse (.eq (.field .resultAfter operand) (.number 0)) (.not (.field .checkSafe checked)))
      .invalid (.deltaBounds operand (.field .checkBounds checked))

def binaryBody : Expr .result :=
  let left : Expr .result := .variable "left"
  let right : Expr .result := .variable "right"
  let checked : Expr .check := .variable "checked"
  let apply (body : Expr (.arrow .interval (.arrow .interval .check))) :=
    apply2 body (.field .resultBounds left) (.field .resultBounds right)
  .locals <| .local "checked" ["scalars", ".", "check_result"]
    (.group <| .operatorCase (.variable "operator")
      (apply (.function .scalarAdd)) (apply (.function .scalarSubtract))
      (apply (.function .scalarMultiply)) (apply (.function .scalarDivide))
      (apply (.function .scalarModulo)) (apply (.function .scalarRemainder)) .invalidCheck) <|
    .group <| .ite (.orElse (.orElse (.orElse
      (.eq (.field .resultAfter left) (.number 0)) (.eq (.field .resultAfter right) (.number 0)))
      (.not (.field .checkSafe checked)))
      (.gt (.field .resultOperands left) (.sub .maxOperands (.field .resultOperands right))))
      .invalid (.result (.field .resultAfter right) (.field .checkBounds checked)
        (.add (.field .resultOperands left) (.field .resultOperands right))
        (.andThen (.field .resultStatic left) (.field .resultStatic right)))

def closeBody : Expr .result :=
  let value : Expr .result := .variable "value"
  let after : Expr .number := .variable "after"
  .locals <| .local "after" ["literal_position"]
    (apply3 (.function .symbol) (.variable "text") (.field .resultAfter value) (.character 41)) <|
    .group <| .ite (.eq after (.number 0)) .invalid (.deltaAfter value after)

def readCall (position : Expr .number) (allowSign : Expr .truth) : Expr .result :=
  apply6 (.function .readExpression) (.variable "text") position (.variable "names")
    (.variable "mask_first") (.variable "mask_after") allowSign

def readDefaultCall (position : Expr .number) : Expr .result :=
  apply5 (.function .readExpressionDefault) (.variable "text") position (.variable "names")
    (.variable "mask_first") (.variable "mask_after")

def atomBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let names : Expr .environment := .variable "names"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let number : Expr .literal := .variable "number"
  .locals <| .local "first" ["literal_position"] (apply2 (.function .skip) text (.variable "position")) <|
    .local "after" ["literal_position"] (apply2 (.function .nameAfter) text first) <|
    .local "index" ["binding_count"] (apply4 (.function .lookup) text names first after) <|
    .group <| .ite (.orElse (.eq first (.number 0)) (.gt first (.last text))) .invalid <|
    .elsif (.choices (.byteAt text first) (.character 43) (.character 45))
      (.group <| .ite (.not (.variable "allow_sign")) .invalid
        (apply2 (.function .literalResult)
          (apply2 (.function .integerLiteral) text (apply2 (.function .skip) text (.add first (.number 1))))
          (.eq (.byteAt text first) (.character 45)))) <|
    .group <| .locals <| .local "number" ["silver_scalar_literals", ".", "literal_result"]
      (apply2 (.function .integerLiteral) text first) <|
      .group <| .ite (.ne (.field .literalAfter number) (.number 0))
        (apply2 (.function .literalResult) number (.truth false)) <|
      .elsif (.orElse (.eq index (.number 0)) (.group <| .andThen (.ne (.variable "mask_first") (.number 0))
        (apply5 (.function .equalName) text (.variable "mask_first") (.variable "mask_after") first after)))
        .invalid (.result after (.app (.function .scalarNormalize) (.field .bindingBounds (.binding names index)))
          (.number 1) (.field .bindingStatic (.binding names index)))

def readUnaryBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let next : Expr .number := .variable "next"
  let number : Expr .literal := .variable "number"
  .locals <| .local "next" ["literal_position"] (apply2 (.function .skip) text (.add position (.number 1))) <|
    .local "number" ["silver_scalar_literals", ".", "literal_result"] (apply2 (.function .integerLiteral) text next) <|
    apply2 (.function .closeResult) text (.group <| .ite (.ne (.field .literalAfter number) (.number 0))
      (apply2 (.function .literalResult) number (.eq (.byteAt text position) (.character 45)))
      (apply2 (.function .unaryResult) (readCall next (.truth false)) (.eq (.byteAt text position) (.character 45))))

def binaryAfterBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let after : Expr .number := .variable "after"
  .locals <| .local "after" ["literal_position"] (apply2 (.function .nameAfter) text position) <|
    .group <| .ite (.orElse (.eq position (.number 0)) (.gt position (.last text))) (.number 0) <|
    .elsif (.operators (.byteAt text position)) (.add position (.number 1)) <|
    .elsif (.eq (.byteAt text position) (.character 47))
      (.group <| .ite (.andThen (.lt position (.last text))
        (.eq (.byteAt text (.add position (.number 1))) (.character 61)))
        (.number 0) (.add position (.number 1))) <|
    .elsif (.andThen (.ne after (.number 0)) (.group <| .orElse
      (apply4 (.function .nameIs) text position after (.word "mod"))
      (apply4 (.function .nameIs) text position after (.word "rem")))) after (.number 0)

def compoundBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let next : Expr .number := .variable "next"
  let left : Expr .result := .variable "left"
  let after : Expr .number := .variable "after"
  .locals <| .local "next" ["literal_position"] (apply2 (.function .skip) text (.field .resultAfter left)) <|
    .local "after" ["literal_position"] (apply2 (.function .binaryAfter) text next) <|
    .group <| .ite (.orElse (.eq next (.number 0)) (.gt next (.last text))) .invalid <|
    .elsif (.eq (.byteAt text next) (.character 41)) (.deltaAfter left (.add next (.number 1))) <|
    .elsif (.eq after (.number 0)) .invalid <|
    apply2 (.function .closeResult) text (apply3 (.function .binaryResult) left
      (readCall after (.truth false)) (.app (.function .lowercase) (.byteAt text next)))

def groupBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let first : Expr .number := .variable "first"
  .locals <| .local "first" ["literal_position"] (apply2 (.function .skip) text (.add position (.number 1))) <|
    .group <| .ite (.gt first (.last text)) .invalid <|
    .elsif (.choices (.byteAt text first) (.character 43) (.character 45))
      (apply5 (.function .readUnary) text first (.variable "names") (.variable "mask_first") (.variable "mask_after"))
      (apply6 (.function .readCompound) text position (.variable "names") (readDefaultCall first)
        (.variable "mask_first") (.variable "mask_after"))

def expressionBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let first : Expr .number := .variable "first"
  .locals <| .local "first" ["literal_position"] (apply2 (.function .skip) text (.variable "position")) <|
    .group <| .ite (.orElse (.eq first (.number 0)) (.gt first (.last text))) .invalid <|
    .elsif (.eq (.byteAt text first) (.characterVal 40))
      (apply5 (.function .readGroup) text first (.variable "names") (.variable "mask_first") (.variable "mask_after"))
      (apply6 (.function .readAtom) text first (.variable "names") (.variable "mask_first")
        (.variable "mask_after") (.variable "allow_sign"))

/-- Rendering retains Ada precedence, homogeneous Boolean chains and explicit
parentheses. This is checked independently for every body translated below. -/
def Expr.primary : Expr ty → Bool
  | .number _ | .word _ | .character _ | .characterVal _ | .truth _ | .variable _ | .function _ | .app _ _
  | .field _ _ | .binding _ _ | .byteAt _ _ | .last _ | .maxOperands | .group _
  | .result _ _ _ _ | .check _ _ | .deltaAfter _ _ | .deltaBounds _ _ | .invalid | .invalidCheck => true
  | _ => false

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ | .neg _ => true
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .lt _ _ | .le _ _ | .gt _ _ | .choices _ _ _ | .operators _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true | value => value.relation

def Expr.orHead : Expr ty → Bool
  | .orElse _ _ => true | value => value.relation

def Expr.condition (value : Expr ty) : Bool := value.andHead || value.orHead

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false
def Expr.functionSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.functionSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .character value => decide (32 ≤ value ∧ value ≤ 126 ∧ value ≠ 39 ∧ value ≠ 40)
  | .characterVal value => decide (value ≤ 255)
  | .app fn argument => fn.wellFormed && argument.wellFormed && fn.functionSpine && argument.condition
  | .field _ value | .last value => value.wellFormed && value.primary
  | .binding names index => names.wellFormed && names.primary && index.wellFormed && index.simple
  | .add left right | .sub left right => left.wellFormed && right.wellFormed && left.simple && right.primary
  | .neg value => value.wellFormed && value.primary
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right =>
      left.wellFormed && right.wellFormed && left.simple && right.simple
  | .choices value lower upper =>
      value.wellFormed && lower.wellFormed && upper.wellFormed && value.simple && lower.simple && upper.simple
  | .operators value => value.wellFormed && value.simple
  | .andThen left right => left.wellFormed && right.wellFormed && left.andHead && right.relation
  | .orElse left right => left.wellFormed && right.wellFormed && left.orHead && right.relation
  | .not value => value.wellFormed && value.primary
  | .group value => value.wellFormed && !value.isElsif
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.condition && yes.wellFormed && yes.simple && no.wellFormed && (no.simple || no.isElsif)
  | .local _ _ value rest => value.wellFormed && value.simple && rest.wellFormed && (rest.isLocal || rest.primary)
  | .locals body => body.wellFormed && body.isLocal
  | .byteAt text position => text.wellFormed && text.primary && position.wellFormed && position.simple
  | .result after bounds operands static => after.wellFormed && after.simple && bounds.wellFormed && bounds.simple &&
      operands.wellFormed && operands.simple && static.wellFormed && static.condition
  | .check safe bounds => safe.wellFormed && safe.condition && bounds.wellFormed && bounds.simple
  | .deltaAfter value after => value.wellFormed && value.primary && after.wellFormed && after.simple
  | .deltaBounds value bounds => value.wellFormed && value.primary && bounds.wellFormed && bounds.simple
  | .operatorCase operator adding subtracting multiplying dividing modulo remainder otherwise => operator.wellFormed && operator.simple &&
      adding.wellFormed && adding.simple && subtracting.wellFormed && subtracting.simple &&
      multiplying.wellFormed && multiplying.simple && dividing.wellFormed && dividing.simple &&
      modulo.wellFormed && modulo.simple && remainder.wellFormed && remainder.simple && otherwise.wellFormed && otherwise.simple
  | _ => true

abbrev WellFormedTrees : Prop := lookupBody.wellFormed = true ∧ symbolBody.wellFormed = true ∧
  literalBody.wellFormed = true ∧ unaryBody.wellFormed = true ∧ binaryBody.wellFormed = true ∧
  closeBody.wellFormed = true ∧ atomBody.wellFormed = true ∧ readUnaryBody.wellFormed = true ∧
  binaryAfterBody.wellFormed = true ∧ compoundBody.wellFormed = true ∧ groupBody.wellFormed = true ∧ expressionBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

end Silver.ScalarExpression.Native
