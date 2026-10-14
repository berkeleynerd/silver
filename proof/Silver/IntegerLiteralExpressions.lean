module

public import Silver.IntegerLiteral
public import Silver.Expressions

@[expose] public section

/-! Typed source expressions for the bounded integer scanner's functional
contracts. Runtime loops are connected by their proved result contracts; all
calls in these trees stay arbitrary until source-equation uniqueness is used. -/
namespace Silver.IntegerLiteral.Native

structure Scaled where
  valid : Bool
  value : Nat
  deriving DecidableEq, Repr

def invalidScaled : Scaled := ⟨false, 0⟩
def scaleResult (base value exponent : Nat) : Scaled :=
  match scale base value exponent with | none => invalidScaled | some value => ⟨true, value⟩

inductive Ty
  | number | truth | source | result | mantissa | scaled | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .source => Source | .result => Result
  | .mantissa => Mantissa | .scaled => Scaled | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .source => [] | .result => invalid
  | .mantissa => ⟨0, 0, 10⟩ | .scaled => invalidScaled | .arrow _ b => fun _ => b.default

inductive Function | digit | tail | numeral | mantissa | scale | start | exponent | model
  deriving DecidableEq, Repr

def Function.name : Function → String
  | .digit => "digit" | .tail => "numeral_tail" | .numeral => "numeral_model"
  | .mantissa => "mantissa_model" | .scale => "scale_model" | .start => "exponent_start"
  | .exponent => "exponent_model" | .model => "model"

def Function.type : Function → Ty
  | .digit => .arrow .number .number
  | .tail => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .truth .result))))
  | .numeral => .arrow .source (.arrow .number (.arrow .number .result))
  | .mantissa => .arrow .source (.arrow .number .mantissa)
  | .scale => .arrow .number (.arrow .number (.arrow .number .scaled))
  | .start => .arrow .source (.arrow .number .number)
  | .exponent => .arrow .source (.arrow .mantissa .result)
  | .model => .arrow .source (.arrow .number .result)

structure Calls where
  digit : Nat → Nat
  tail : Source → Nat → Nat → Nat → Bool → Result
  numeral : Source → Nat → Nat → Result
  mantissa : Source → Nat → Mantissa
  scale : Nat → Nat → Nat → Scaled
  start : Source → Nat → Nat
  exponent : Source → Mantissa → Result
  model : Source → Nat → Result
  identifier : Nat → Bool

def Calls.get (calls : Calls) : (f : Function) → f.type.meaning
  | .digit => calls.digit | .tail => calls.tail | .numeral => calls.numeral
  | .mantissa => calls.mantissa | .scale => calls.scale | .start => calls.start
  | .exponent => calls.exponent | .model => calls.model

inductive Field : Ty → Ty → Type
  | resultAfter : Field .result .number | resultValue : Field .result .number
  | mantissaAfter : Field .mantissa .number | mantissaValue : Field .mantissa .number
  | mantissaBase : Field .mantissa .number
  | scaledValid : Field .scaled .truth | scaledValue : Field .scaled .number

def Field.name : Field a b → String
  | .resultAfter | .mantissaAfter => "after"
  | .resultValue | .mantissaValue | .scaledValue => "value"
  | .mantissaBase => "base" | .scaledValid => "valid"

def Field.get : Field a b → a.meaning → b.meaning
  | .resultAfter, value => value.after | .resultValue, value => value.value
  | .mantissaAfter, value => value.after | .mantissaValue, value => value.value
  | .mantissaBase, value => value.base
  | .scaledValid, value => value.valid | .scaledValue, value => value.value

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | character (value : Nat) : Expr .number
  | truth (value : Bool) : Expr .truth
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | mul : Expr .number → Expr .number → Expr .number
  | div : Expr .number → Expr .number → Expr .number
  | charPos : Expr .number → Expr .number
  | byteAt : Expr .source → Expr .number → Expr .number
  | last : Expr .source → Expr .number
  | maxLength : Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | range : Expr .number → Expr .number → Expr .number → Expr .truth
  | choices : Expr .number → Expr .number → Expr .number → Expr .truth
  | notBase : Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | identifier : Expr .number → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name typeName : String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | result : Expr .number → Expr .number → Expr .result
  | mantissa : Expr .number → Expr .number → Expr .number → Expr .mantissa
  | scaled : Expr .truth → Expr .number → Expr .scaled
  | invalid : Expr .result
  | invalidMantissa : Expr .mantissa
  | invalidScaled : Expr .scaled

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def call := Silver.Expressions.call

def aggregate (fields : List (String × List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","]
    (fields.map fun (name, value) => [name, "=>"] ++ value)) ++ [")"]

def Expr.render : Expr ty → List String
  | .number value => [toString value]
  | .character value => ["'" ++ String.singleton (Char.ofNat value) ++ "'"]
  | .truth value => [if value then "true" else "false"]
  | .variable name => [name]
  | .function symbol => [symbol.name]
  | .app fn argument => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["("] ++ argument.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .mul left right => left.render ++ ["*"] ++ right.render
  | .div left right => left.render ++ ["/"] ++ right.render
  | .charPos value => ["character", "'", "pos", "("] ++ value.render ++ [")"]
  | .byteAt text position => text.render ++ ["("] ++ position.render ++ [")"]
  | .last text => text.render ++ ["'", "last"]
  | .maxLength => ["max_source_length"]
  | .eq left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .lt left right => left.render ++ ["<"] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .gt left right => left.render ++ [">"] ++ right.render
  | .range value lower upper => value.render ++ ["in"] ++ lower.render ++ [".."] ++ upper.render
  | .choices value first second => value.render ++ ["in"] ++ first.render ++ ["|"] ++ second.render
  | .notBase value => value.render ++ ["not", "in", "literal_base"]
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .identifier value => call "is_identifier_character" [value.render]
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .local name typeName value rest => [name, ":", "constant", typeName, ":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .result after value => aggregate [("after", after.render), ("value", value.render)]
  | .mantissa after value base => aggregate [("after", after.render), ("value", value.render), ("base", base.render)]
  | .scaled valid value => aggregate [("valid", valid.render), ("value", value.render)]
  | .invalid => ["invalid"] | .invalidMantissa => ["invalid_mantissa"] | .invalidScaled => ["invalid_scale"]

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number value | .character value => value
  | .truth value => value
  | .variable name => locals _ name
  | .function symbol => calls.get symbol
  | .app fn argument => fn.eval calls locals (argument.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .add left right => left.eval calls locals + right.eval calls locals
  | .sub left right => left.eval calls locals - right.eval calls locals
  | .mul left right => left.eval calls locals * right.eval calls locals
  | .div left right => left.eval calls locals / right.eval calls locals
  | .charPos value => value.eval calls locals
  | .byteAt text position => Cursor.byteAt (text.eval calls locals) (position.eval calls locals)
  | .last text => (text.eval calls locals).length
  | .maxLength => maxSourceLength
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .lt left right => decide (left.eval calls locals < right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .gt left right => decide (left.eval calls locals > right.eval calls locals)
  | .range value lower upper => decide (lower.eval calls locals ≤ value.eval calls locals ∧ value.eval calls locals ≤ upper.eval calls locals)
  | .choices value first second => decide (value.eval calls locals = first.eval calls locals ∨ value.eval calls locals = second.eval calls locals)
  | .notBase value => decide (value.eval calls locals < 2 ∨ 16 < value.eval calls locals)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .not value => !(value.eval calls locals)
  | .identifier value => calls.identifier (value.eval calls locals)
  | .group value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .local name _ value rest => rest.eval calls (locals.set _ name (value.eval calls locals))
  | .locals body => body.eval calls locals
  | .result after value => ⟨after.eval calls locals, value.eval calls locals⟩
  | .mantissa after value base => ⟨after.eval calls locals, value.eval calls locals, base.eval calls locals⟩
  | .scaled valid value => ⟨valid.eval calls locals, value.eval calls locals⟩
  | .invalid => IntegerLiteral.invalid | .invalidMantissa => ⟨0, 0, 10⟩ | .invalidScaled => Native.invalidScaled

structure Context where
  text : Source := []
  position : Nat := 0
  base : Nat := 10
  value : Nat := 0
  needDigit : Bool := true
  exponent : Nat := 0
  item : Nat := 0
  number : Mantissa := ⟨0, 0, 10⟩

def Context.locals (ctx : Context) : Locals
  | .number, "position" => ctx.position
  | .number, "base" => ctx.base
  | .number, "value" => ctx.value
  | .number, "exponent" => ctx.exponent
  | .number, "item" => ctx.item
  | .truth, "need_digit" => ctx.needDigit
  | .source, "text" => ctx.text
  | .mantissa, "number" => ctx.number
  | ty, _ => ty.default


def digitBody : Expr .number :=
  let item : Expr .number := .variable "item"
  .ite (.range item (.character 48) (.character 57)) (.sub (.charPos item) (.charPos (.character 48)))
    (.elsif (.range item (.character 65) (.character 70)) (.add (.group (.sub (.charPos item) (.charPos (.character 65)))) (.number 10))
      (.elsif (.range item (.character 97) (.character 102)) (.add (.group (.sub (.charPos item) (.charPos (.character 97)))) (.number 10))
        (.number 16)))

def tailBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let base : Expr .number := .variable "base"
  let value : Expr .number := .variable "value"
  let need : Expr .truth := .variable "need_digit"
  let digit := Expr.app (.function .digit) (.byteAt text position)
  let tail (v : Expr .number) (n : Expr .truth) := Expr.app (.app (.app (.app (.app (.function .tail) text) base)
    (.add position (.number 1))) v) n
  .ite (.gt position (.last text)) (.group (.ite need .invalid (.result position value)))
    (.elsif (.lt digit base)
      (.group (.ite (.gt value (.div (.group (.sub .maxLength digit)) base)) .invalid
        (tail (.add (.mul value base) digit) (.truth false))))
      (.elsif (.eq (.byteAt text position) (.character 95))
        (.group (.ite need .invalid (tail value (.truth true))))
        (.group (.ite need .invalid (.result position value)))))

def numeralBody : Expr .result :=
  .ite (.eq (.variable "position") (.number 0)) .invalid
    (.app (.app (.app (.app (.app (.function .tail) (.variable "text")) (.variable "base"))
      (.variable "position")) (.number 0)) (.truth true))

def mantissaBody : Expr .mantissa :=
  let text : Expr .source := .variable "text"
  let leading : Expr .result := .variable "leading"
  let number : Expr .result := .variable "number"
  let leadingAfter := Expr.field .resultAfter leading
  let leadingValue := Expr.field .resultValue leading
  let numberAfter := Expr.field .resultAfter number
  .locals <| .local "leading" "literal_result"
    (.app (.app (.app (.function .numeral) text) (.variable "position")) (.number 10)) <|
    .group <| .ite (.eq leadingAfter (.number 0)) .invalidMantissa
      (.elsif (.andThen (.le leadingAfter (.last text)) (.choices (.byteAt text leadingAfter) (.character 35) (.character 58)))
        (.group <| .ite (.notBase leadingValue) .invalidMantissa
          (.group <| .locals <| .local "number" "literal_result"
            (.app (.app (.app (.function .numeral) text) (.add leadingAfter (.number 1))) leadingValue) <|
            .group <| .ite (.eq numberAfter (.number 0)) .invalidMantissa
              (.elsif (.orElse (.gt numberAfter (.last text)) (.ne (.byteAt text numberAfter) (.byteAt text leadingAfter)))
                .invalidMantissa
                (.mantissa (.add numberAfter (.number 1)) (.field .resultValue number) leadingValue))))
        (.mantissa leadingAfter leadingValue (.number 10)))

def scaleBody : Expr .scaled :=
  let base : Expr .number := .variable "base"
  let value : Expr .number := .variable "value"
  let exponent : Expr .number := .variable "exponent"
  .ite (.eq exponent (.number 0)) (.scaled (.truth true) value)
    (.elsif (.gt value (.div .maxLength base)) .invalidScaled
      (.app (.app (.app (.function .scale) base) (.mul value base)) (.sub exponent (.number 1))))

def startBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  .ite (.andThen (.le position (.last text)) (.eq (.byteAt text position) (.character 43)))
    (.add position (.number 1)) position

def exponentBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let number : Expr .mantissa := .variable "number"
  let after := Expr.field .mantissaAfter number
  let exponent : Expr .result := .variable "exponent"
  let exponentAfter := Expr.field .resultAfter exponent
  let scaled : Expr .scaled := .variable "scaled"
  .ite (.andThen (.le after (.last text)) (.choices (.byteAt text after) (.character 101) (.character 69)))
    (.group <| .locals <| .local "exponent" "literal_result"
      (.app (.app (.app (.function .numeral) text)
        (.app (.app (.function .start) text) (.add after (.number 1)))) (.number 10)) <|
      .group <| .ite (.eq exponentAfter (.number 0)) .invalid
        (.group <| .locals <| .local "scaled" "scale_result"
          (.app (.app (.app (.function .scale) (.field .mantissaBase number)) (.field .mantissaValue number))
            (.field .resultValue exponent)) <|
          .group <| .ite (.not (.field .scaledValid scaled)) .invalid
            (.result exponentAfter (.field .scaledValue scaled))))
    (.result after (.field .mantissaValue number))

def modelBody : Expr .result :=
  let text : Expr .source := .variable "text"
  let number : Expr .mantissa := .variable "number"
  let result : Expr .result := .variable "result"
  let after := Expr.field .resultAfter result
  .locals <| .local "number" "mantissa_result"
    (.app (.app (.function .mantissa) text) (.variable "position")) <|
    .group <| .ite (.eq (.field .mantissaAfter number) (.number 0)) .invalid
      (.group <| .locals <| .local "result" "literal_result"
        (.app (.app (.function .exponent) text) number) <|
        .group <| .ite (.orElse (.eq after (.number 0))
          (.group (.andThen (.le after (.last text)) (.identifier (.byteAt text after))))) .invalid result)

def modelCalls : Calls where
  digit := digitValue
  tail := digitsTail
  numeral := numeral
  mantissa := mantissa
  scale := scaleResult
  start := exponentStart
  exponent := powerAt
  model := read
  identifier := identifierCharacter


/-- The shape checks retain the Ada precedence and homogeneous Boolean chains
used by the rendered source; grouping is explicit in the same typed tree. -/
def Expr.primary : Expr ty → Bool
  | .number _ | .character _ | .truth _ | .variable _ | .function _ | .app _ _
  | .field _ _ | .charPos _ | .byteAt _ _ | .last _ | .maxLength
  | .identifier _ | .group _ | .result _ _ | .mantissa _ _ _ | .scaled _ _
  | .invalid | .invalidMantissa | .invalidScaled => true
  | _ => false

def Expr.term : Expr ty → Bool
  | .mul _ _ | .div _ _ => true
  | value => value.primary

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ => true
  | value => value.term

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .lt _ _ | .le _ _ | .gt _ _
  | .range _ _ _ | .choices _ _ _ | .notBase _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.orHead : Expr ty → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.condition (value : Expr .truth) : Bool := value.andHead || value.orHead

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false
def Expr.functionSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.functionSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .character value => decide (32 ≤ value ∧ value ≤ 126 ∧ value ≠ 39)
  | .app fn argument => fn.wellFormed && argument.wellFormed && fn.functionSpine && argument.simple
  | .field _ value | .charPos value | .last value | .identifier value => value.wellFormed && value.primary
  | .add left right | .sub left right => left.wellFormed && right.wellFormed && left.simple && right.term
  | .mul left right | .div left right => left.wellFormed && right.wellFormed && left.term && right.primary
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right =>
      left.wellFormed && right.wellFormed && left.simple && right.simple
  | .range value lower upper | .choices value lower upper =>
      value.wellFormed && lower.wellFormed && upper.wellFormed && value.simple && lower.simple && upper.simple
  | .notBase value => value.wellFormed && value.simple
  | .andThen left right => left.wellFormed && right.wellFormed && left.andHead && right.relation
  | .orElse left right => left.wellFormed && right.wellFormed && left.orHead && right.relation
  | .not value => value.wellFormed && value.primary
  | .group value => value.wellFormed && !value.isElsif
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.condition && yes.wellFormed && yes.simple && no.wellFormed && (no.simple || no.isElsif)
  | .local _ _ value rest => value.wellFormed && value.simple && rest.wellFormed && (rest.isLocal || rest.primary)
  | .locals body => body.wellFormed && body.isLocal
  | .byteAt text position => text.wellFormed && text.primary && position.wellFormed && position.simple
  | .result after value => after.wellFormed && after.simple && value.wellFormed && value.simple
  | .mantissa after value base => after.wellFormed && after.simple && value.wellFormed && value.simple && base.wellFormed && base.simple
  | .scaled valid value => valid.wellFormed && valid.condition && value.wellFormed && value.simple
  | _ => true

abbrev WellFormedTrees : Prop := digitBody.wellFormed = true ∧ tailBody.wellFormed = true ∧
  numeralBody.wellFormed = true ∧ mantissaBody.wellFormed = true ∧ scaleBody.wellFormed = true ∧
  startBody.wellFormed = true ∧ exponentBody.wellFormed = true ∧ modelBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

end Silver.IntegerLiteral.Native
