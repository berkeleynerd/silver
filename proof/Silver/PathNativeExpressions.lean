module

public import Silver.PathNativeModel

@[expose] public section

/-! Path-library expressions are typed once; rendering and interpretation use
these same trees. Calls are interpreted only by the nonrecursive scalar model. -/
namespace Silver.PathFacts.Native
open Bindings Predicate

inductive Ty | number | truth | context | bound | summary | comparison | arrow (domain codomain : Ty)
  deriving DecidableEq
@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .context => Context | .bound => Bound
  | .summary => Summary | .comparison => Comparison | .arrow a b => a.meaning → b.meaning
def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .context => empty | .bound => ⟨0, false⟩
  | .summary => ⟨0, 0⟩ | .comparison => .eq | .arrow _ b => fun _ => b.default

inductive Function
  | compare | complement | swap | initial | ceiling | assumeValid | assumeInvalid | rejected
  | completed | keepIf | intersect | join | below | above | refineInputTrue | refineInput
  | refineBounds | lengthAt | fits | sameLength | equalIncreasing | refineEqual
  deriving DecidableEq

def Function.name : Function → String
  | .compare => "compare" | .complement => "complement" | .swap => "swap" | .initial => "initial"
  | .ceiling => "ceiling" | .assumeValid => "assume_valid" | .assumeInvalid => "assume_invalid"
  | .rejected => "rejected" | .completed => "completed" | .keepIf => "keep_if"
  | .intersect => "intersect" | .join => "join" | .below => "below" | .above => "above"
  | .refineInputTrue => "refine_input_true" | .refineInput => "refine_input"
  | .refineBounds => "refine_bounds" | .lengthAt => "length_at" | .fits => "fits"
  | .sameLength => "same_length" | .equalIncreasing => "equal_increasing" | .refineEqual => "refine_equal"
def Function.type : Function → Ty
  | .compare => .arrow .comparison (.arrow .number (.arrow .number .truth))
  | .complement | .swap => .arrow .comparison .comparison
  | .initial => .arrow .truth .context
  | .ceiling => .arrow .context .number
  | .assumeValid | .assumeInvalid | .rejected => .arrow .context .context
  | .completed => .arrow .context .truth
  | .keepIf => .arrow .context (.arrow .truth .context)
  | .intersect => .arrow .context (.arrow .number (.arrow .number .context))
  | .join => .arrow .context (.arrow .context .context)
  | .below | .above => .arrow .context (.arrow .number .context)
  | .refineInputTrue => .arrow .context (.arrow .comparison (.arrow .number .context))
  | .refineInput => .arrow .context (.arrow .comparison (.arrow .number (.arrow .truth .context)))
  | .refineBounds => .arrow .context (.arrow .comparison (.arrow .bound (.arrow .bound (.arrow .truth .context))))
  | .lengthAt => .arrow .summary (.arrow .number .number)
  | .fits => .arrow .context (.arrow .summary .truth)
  | .sameLength => .arrow .context (.arrow .summary (.arrow .summary .truth))
  | .equalIncreasing | .refineEqual => .arrow .context (.arrow .summary (.arrow .summary .context))
def Function.eval : (fn : Function) → fn.type.meaning
  | .compare => fun operator left right => operator.evaluate left right | .complement => Comparison.complement | .swap => Comparison.swap
  | .initial => Native.initial | .ceiling => Native.ceiling | .assumeValid => Native.assumeValid | .assumeInvalid => Native.assumeInvalid
  | .rejected => Native.rejected | .completed => Native.completed | .keepIf => Native.keepIf | .intersect => Native.intersect | .join => Native.join
  | .below => Native.below | .above => Native.above | .refineInputTrue => Native.refineInputTrue | .refineInput => Native.refineInput
  | .refineBounds => Native.refineBounds | .lengthAt => Native.lengthAt | .fits => Native.fits | .sameLength => Native.sameLength
  | .equalIncreasing => Native.equalIncreasing | .refineEqual => Native.refineEqual

inductive Field : Ty → Ty → Type
  | lower : Field .context .number | upper : Field .context .number
  | validReachable : Field .context .truth | invalidReachable : Field .context .truth
  | invalidRejected : Field .context .truth
  | boundStatic : Field .bound .number | dynamic : Field .bound .truth
  | summaryStatic : Field .summary .number | dynamicCount : Field .summary .number

def Field.name : Field a b → String
  | .lower => "lower" | .upper => "upper" | .validReachable => "valid_reachable"
  | .invalidReachable => "invalid_reachable" | .invalidRejected => "invalid_rejected"
  | .boundStatic | .summaryStatic => "static_length" | .dynamic => "dynamic"
  | .dynamicCount => "dynamic_count"
def Field.get : Field a b → a.meaning → b.meaning
  | .lower, value => value.lower | .upper, value => value.upper
  | .validReachable, value => value.validReachable | .invalidReachable, value => value.invalidReachable
  | .invalidRejected, value => value.invalidRejected | .boundStatic, value => value.staticLength
  | .dynamic, value => value.dynamic | .summaryStatic, value => value.staticLength
  | .dynamicCount, value => value.dynamicCount

def comparisonName : Comparison → String
  | .eq => "equal" | .ne => "unequal" | .lt => "less" | .le => "less_equal"
  | .gt => "greater" | .ge => "greater_equal"

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | truth (value : Bool) : Expr .truth
  | comparison (value : Comparison) : Expr .comparison
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | mul : Expr .number → Expr .number → Expr .number
  | div : Expr .number → Expr .number → Expr .number
  | min (typeName : String) : Expr .number → Expr .number → Expr .number
  | max (typeName : String) : Expr .number → Expr .number → Expr .number
  | maxLength : Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | ge : Expr .number → Expr .number → Expr .truth
  | boolEq : Expr .truth → Expr .truth → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | cases : Expr .comparison → Expr a → Expr a → Expr a → Expr a → Expr a → Expr a → Expr a
  | local (name typeName : String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | context (named : Bool) : Expr .number → Expr .number → Expr .truth → Expr .truth → Expr .truth → Expr .context
  | assumeValid : Expr .context → Expr .context
  | assumeInvalid : Expr .context → Expr .context
  | rejected : Expr .context → Expr .context
  | empty : Expr .context

abbrev Locals := (ty : Ty) → String → ty.meaning
def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def Expr.eval (locals : Locals) : Expr ty → ty.meaning
  | .number value => value | .truth value => value | .comparison value => value
  | .variable name => locals _ name | .function symbol => symbol.eval
  | .app fn argument => fn.eval locals (argument.eval locals)
  | .field projection value => projection.get (value.eval locals)
  | .add a b => a.eval locals + b.eval locals | .sub a b => a.eval locals - b.eval locals
  | .mul a b => a.eval locals * b.eval locals | .div a b => a.eval locals / b.eval locals
  | .min _ a b => Nat.min (a.eval locals) (b.eval locals) | .max _ a b => Nat.max (a.eval locals) (b.eval locals)
  | .maxLength => maxSourceLength
  | .eq a b => decide (a.eval locals = b.eval locals) | .ne a b => decide (a.eval locals ≠ b.eval locals)
  | .lt a b => decide (a.eval locals < b.eval locals) | .le a b => decide (a.eval locals ≤ b.eval locals)
  | .gt a b => decide (a.eval locals > b.eval locals) | .ge a b => decide (a.eval locals ≥ b.eval locals)
  | .boolEq a b => a.eval locals == b.eval locals
  | .andThen a b => a.eval locals && b.eval locals | .orElse a b => a.eval locals || b.eval locals
  | .not a => !a.eval locals | .group a => a.eval locals
  | .ite c a b | .elsif c a b => if c.eval locals then a.eval locals else b.eval locals
  | .cases operator eqCase neCase ltCase leCase gtCase geCase =>
      match operator.eval locals with
      | .eq => eqCase.eval locals | .ne => neCase.eval locals | .lt => ltCase.eval locals
      | .le => leCase.eval locals | .gt => gtCase.eval locals | .ge => geCase.eval locals
  | .local name _ value rest => rest.eval (locals.set _ name (value.eval locals))
  | .locals body => body.eval locals
  | .context _ lower upper valid invalid rejectedFlag =>
      ⟨lower.eval locals, upper.eval locals, valid.eval locals, invalid.eval locals, rejectedFlag.eval locals⟩
  | .assumeValid facts => Native.assumeValid (facts.eval locals)
  | .assumeInvalid facts => Native.assumeInvalid (facts.eval locals)
  | .rejected facts => Native.rejected (facts.eval locals)
  | .empty => Native.empty

def aggregate (named : Bool) (values : List (String × List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","]
    (values.map fun (name, value) => if named then [name, "=>"] ++ value else value)) ++ [")"]
def caseArm (operator : Comparison) (value : List String) : List String :=
  ["when", comparisonName operator, "=>"] ++ value

def Expr.render : Expr ty → List String
  | .number value => [toString value] | .truth value => [if value then "true" else "false"]
  | .comparison value => [comparisonName value] | .variable name => [name] | .function symbol => [symbol.name]
  | .app fn argument => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["("] ++ argument.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .add a b => a.render ++ ["+"] ++ b.render | .sub a b => a.render ++ ["-"] ++ b.render
  | .mul a b => a.render ++ ["*"] ++ b.render | .div a b => a.render ++ ["/"] ++ b.render
  | .min name a b => [name, "'", "min", "("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .max name a b => [name, "'", "max", "("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .maxLength => ["max_length"]
  | .eq a b => a.render ++ ["="] ++ b.render | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render | .ge a b => a.render ++ [">="] ++ b.render
  | .boolEq a b => a.render ++ ["="] ++ b.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .orElse a b => a.render ++ ["or", "else"] ++ b.render
  | .not a => ["not"] ++ a.render | .group a => ["("] ++ a.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .cases operator eqCase neCase ltCase leCase gtCase geCase =>
      ["case"] ++ operator.render ++ ["is"] ++ caseArm .eq eqCase.render ++ [","] ++ caseArm .ne neCase.render ++ [","] ++
      caseArm .lt ltCase.render ++ [","] ++ caseArm .le leCase.render ++ [","] ++ caseArm .gt gtCase.render ++ [","] ++ caseArm .ge geCase.render
  | .local name typeName value rest => [name, ":", "constant", typeName, ":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .context named lower upper valid invalid rejectedFlag => aggregate named
      [("lower", lower.render), ("upper", upper.render), ("valid_reachable", valid.render),
       ("invalid_reachable", invalid.render), ("invalid_rejected", rejectedFlag.render)]
  | .assumeValid facts => facts.render ++ ["with", "delta", "invalid_reachable", "=>", "false"]
  | .assumeInvalid facts => facts.render ++ ["with", "delta", "lower", "=>", "0", ",", "upper", "=>", "0", ",", "valid_reachable", "=>", "false"]
  | .rejected facts => facts.render ++ ["with", "delta", "invalid_rejected", "=>", "true"]
  | .empty => ["empty_context"]

abbrev v (name : String) : Expr ty := .variable name
abbrev f := Expr.function
abbrev ap {a b : Ty} := @Expr.app a b
abbrev fld {a b : Ty} := @Expr.field a b
abbrev facts : Expr .context := v "facts"
abbrev operator : Expr .comparison := v "operator"
abbrev left : Expr ty := v "left"
abbrev right : Expr ty := v "right"
abbrev threshold : Expr .number := v "threshold"
abbrev truth : Expr .truth := v "truth"
abbrev zero : Expr .number := .number 0
abbrev one : Expr .number := .number 1
abbrev app2 (fn : Function) (a : Expr s) (b : Expr t) (h : fn.type = .arrow s (.arrow t u) := by rfl) : Expr u :=
  ap (ap (h ▸ f fn) a) b

-- Each body omits its expression function's outer parentheses, exactly as the source extractor does.
def compareBody : Expr .truth := .cases operator (.eq left right) (.ne left right) (.lt left right) (.le left right) (.gt left right) (.ge left right)
def complementBody : Expr .comparison := .cases operator (.comparison .ne) (.comparison .eq) (.comparison .ge) (.comparison .gt) (.comparison .le) (.comparison .lt)
def swapBody : Expr .comparison := .cases operator (.comparison .eq) (.comparison .ne) (.comparison .gt) (.comparison .ge) (.comparison .lt) (.comparison .le)
def initialBody : Expr .context := .context false zero (.group (.ite (v "arguments") .maxLength zero)) (.truth true) (v "arguments") (.truth false)
def ceilingBody : Expr .number := .ite (fld .validReachable facts) (fld .upper facts) zero
def assumeValidBody : Expr .context := .assumeValid facts
def assumeInvalidBody : Expr .context := .assumeInvalid facts
def rejectedBody : Expr .context := .rejected facts
def completedBody : Expr .truth := .orElse (.not (fld .invalidReachable facts)) (fld .invalidRejected facts)
def keepIfBody : Expr .context := .ite (v "condition") facts .empty

def intersectBody : Expr .context := .locals <|
  .local "low" "natural" (.max "natural" (fld .lower facts) (v "lower")) <|
  .local "high" "natural" (.min "natural" (fld .upper facts) (v "upper")) <|
  .local "valid" "boolean" (.andThen (fld .validReachable facts) (.le (v "low") (v "high"))) <|
  .context true (.group (.ite (v "valid") (v "low") zero)) (.group (.ite (v "valid") (v "high") zero))
    (v "valid") (.andThen (fld .invalidReachable facts) (.eq (v "lower") zero)) (fld .invalidRejected facts)
def joinBody : Expr .context := .context true
  (.group (.ite (.not (fld .validReachable left)) (fld .lower right)
    (.elsif (.not (fld .validReachable right)) (fld .lower left) (.min "length_value" (fld .lower left) (fld .lower right)))))
  (.group (.ite (.not (fld .validReachable left)) (fld .upper right)
    (.elsif (.not (fld .validReachable right)) (fld .upper left) (.max "length_value" (fld .upper left) (fld .upper right)))))
  (.orElse (fld .validReachable left) (fld .validReachable right))
  (.orElse (fld .invalidReachable left) (fld .invalidReachable right))
  (.andThen (.group (.orElse (.not (fld .invalidReachable left)) (fld .invalidRejected left)))
    (.group (.orElse (.not (fld .invalidReachable right)) (fld .invalidRejected right))))
def belowBody : Expr .context := .ite (.eq threshold zero) .empty (ap (ap (ap (f .intersect) facts) zero) (.sub threshold one))
def aboveBody : Expr .context := ap (ap (ap (f .intersect) facts) (.add threshold one)) (ap (f .ceiling) facts)
def refineInputTrueBody : Expr .context := .cases operator
  (ap (ap (ap (f .intersect) facts) threshold) threshold)
  (app2 .join (app2 .below facts threshold) (app2 .above facts threshold))
  (app2 .below facts threshold) (ap (ap (ap (f .intersect) facts) zero) threshold)
  (app2 .above facts threshold) (ap (ap (ap (f .intersect) facts) threshold) (ap (f .ceiling) facts))
def refineInputBody : Expr .context := ap (ap (ap (f .refineInputTrue) facts)
  (.group (.ite truth operator (ap (f .complement) operator)))) threshold
def refineBoundsBody : Expr .context :=
  .ite (.andThen (fld .dynamic left) (fld .dynamic right))
    (app2 .keepIf facts (.boolEq (ap (ap (ap (f .compare) operator) zero) zero) truth))
  (.elsif (fld .dynamic left) (ap (ap (ap (ap (f .refineInput) facts) operator) (fld .boundStatic right)) truth)
  (.elsif (fld .dynamic right) (ap (ap (ap (ap (f .refineInput) facts) (ap (f .swap) operator)) (fld .boundStatic left)) truth)
    (app2 .keepIf facts (.boolEq (ap (ap (ap (f .compare) operator) (fld .boundStatic left)) (fld .boundStatic right)) truth))))
def lengthAtBody : Expr .number := .add (fld .summaryStatic (v "value")) (.mul (fld .dynamicCount (v "value")) (v "input_length"))
def fitsBody : Expr .truth := .andThen
  (.group (.orElse (.not (fld .validReachable facts)) (.le (app2 .lengthAt (v "value") (fld .upper facts)) .maxLength)))
  (.group (.orElse (.not (fld .invalidReachable facts)) (.le (app2 .lengthAt (v "value") zero) .maxLength)))
def sameLengthBody : Expr .truth := .andThen
  (.andThen
    (.group (.orElse (.orElse (.ne (fld .dynamicCount left) zero)
      (.ne (fld .dynamicCount right) zero)) (.eq (fld .summaryStatic left) (fld .summaryStatic right))))
    (.group (.orElse (.not (fld .validReachable facts))
    (.group (.andThen (.eq (app2 .lengthAt left (fld .lower facts)) (app2 .lengthAt right (fld .lower facts)))
      (.eq (app2 .lengthAt left (fld .upper facts)) (app2 .lengthAt right (fld .upper facts))))))))
  (.group (.orElse (.not (fld .invalidReachable facts)) (.eq (app2 .lengthAt left zero) (app2 .lengthAt right zero))))
def equalIncreasingBody : Expr .context := .locals <|
  .local "numerator" "length_value" (.group (.ite (.ge (fld .summaryStatic right) (fld .summaryStatic left))
    (.sub (fld .summaryStatic right) (fld .summaryStatic left)) zero)) <|
  .local "candidate" "length_value" (.div (v "numerator") (.group (.sub (fld .dynamicCount left) (fld .dynamicCount right)))) <|
  app2 .keepIf (ap (ap (ap (f .intersect) facts) (v "candidate")) (v "candidate"))
    (.eq (app2 .lengthAt left (v "candidate")) (app2 .lengthAt right (v "candidate")))
def refineEqualBody : Expr .context :=
  .ite (.eq (fld .dynamicCount left) (fld .dynamicCount right))
    (app2 .keepIf facts (.eq (fld .summaryStatic left) (fld .summaryStatic right)))
  (.elsif (.gt (fld .dynamicCount left) (fld .dynamicCount right))
    (ap (ap (ap (f .equalIncreasing) facts) left) right) (ap (ap (ap (f .equalIncreasing) facts) right) left))

/-- An aggregate directly inside an expression function shares its outer parentheses. -/
def Expr.renderBody (value : Expr ty) : List String :=
  match value with
  | .context _ _ _ _ _ _ => value.render.drop 1 |>.dropLast
  | _ => value.render

end Silver.PathFacts.Native
