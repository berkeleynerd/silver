module

public import Silver.IntegerComparisons

@[expose] public section

/-! Typed rendering and denotation of the authoritative signed-interval helper.
Wide conversions are identity in the mathematical interpretation; native SPARK
verification and endpoint bounds establish that they do not overflow. -/
namespace Silver.Integer.Native

inductive Ty | number | truth | interval | result | comparison | arrow (a b : Ty)
  deriving DecidableEq
@[reducible] def Ty.meaning : Ty → Type
  | .number => Int | .truth => Bool | .interval => Interval | .result => CheckResult
  | .comparison => Comparison | .arrow a b => a.meaning → b.meaning

inductive Function
  | isEmpty | contains | singleton | normalize | join | intersect
  | compare | complement | swap | below | above | refineTrue | refine
  | inRange | checked | add | subtract | negate | productMinimum | productMaximum | multiply
  deriving DecidableEq

def Function.name : Function → String
  | .isEmpty => "is_empty" | .contains => "contains" | .singleton => "singleton"
  | .normalize => "normalize" | .join => "join" | .intersect => "intersect"
  | .compare => "compare" | .complement => "complement" | .swap => "swap"
  | .below => "below" | .above => "above" | .refineTrue => "refine_true" | .refine => "refine"
  | .inRange => "in_range" | .checked => "checked" | .add => "add" | .subtract => "subtract"
  | .negate => "negate" | .productMinimum => "product_minimum"
  | .productMaximum => "product_maximum" | .multiply => "multiply"

def Function.type : Function → Ty
  | .isEmpty => .arrow .interval .truth
  | .contains => .arrow .interval (.arrow .number .truth)
  | .singleton => .arrow .number .interval
  | .normalize => .arrow .interval .interval
  | .join | .intersect => .arrow .interval (.arrow .interval .interval)
  | .compare => .arrow .comparison (.arrow .number (.arrow .number .truth))
  | .complement | .swap => .arrow .comparison .comparison
  | .below | .above => .arrow .interval (.arrow .number .interval)
  | .refineTrue => .arrow .interval (.arrow .comparison (.arrow .number .interval))
  | .refine => .arrow .interval (.arrow .comparison (.arrow .number (.arrow .truth .interval)))
  | .inRange => .arrow .number .truth
  | .checked => .arrow .number (.arrow .number .result)
  | .add | .subtract | .multiply => .arrow .interval (.arrow .interval .result)
  | .negate => .arrow .interval .result
  | .productMinimum | .productMaximum => .arrow .interval (.arrow .interval .number)

def Function.eval : (fn : Function) → fn.type.meaning
  | .isEmpty => Interval.isEmpty | .contains => fun a n => decide (a.Contains n)
  | .singleton => Interval.singleton | .normalize => Interval.normalize
  | .join => Interval.join | .intersect => Interval.intersect
  | .compare => Comparison.evaluate | .complement => Comparison.complement | .swap => Comparison.swap
  | .below => Interval.below | .above => Interval.above | .refineTrue => Interval.refineTrue
  | .refine => Interval.refine | .inRange => fun n => decide (InRange n)
  | .checked => fun a b => Silver.Integer.checked ⟨a,b⟩
  | .add => checkedAdd | .subtract => checkedSubtract | .negate => checkedNegate
  | .productMinimum => fun a b => (a.multiply b).lower
  | .productMaximum => fun a b => (a.multiply b).upper | .multiply => checkedMultiply

inductive BoundConstant | minimum | maximum | first | last
  deriving DecidableEq
def BoundConstant.value : BoundConstant → Int
  | .minimum | .first => minValue | .maximum | .last => maxValue
def BoundConstant.render : BoundConstant → List String
  | .minimum => ["minimum"] | .maximum => ["maximum"]
  | .first => ["value", "'", "first"] | .last => ["value", "'", "last"]

def comparisonName : Comparison → String
  | .eq => "equal" | .ne => "unequal" | .lt => "less" | .le => "less_equal"
  | .gt => "greater" | .ge => "greater_equal"

inductive Expr : Ty → Type
  | number (value : Nat) : Expr .number
  | bound (value : BoundConstant) : Expr .number
  | truth (value : Bool) : Expr .truth
  | comparison (value : Comparison) : Expr .comparison
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | lower : Expr .interval → Expr .number
  | upper : Expr .interval → Expr .number
  | convert (typeName : String) : Expr .number → Expr .number
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | mul : Expr .number → Expr .number → Expr .number
  | neg : Expr .number → Expr .number
  | min (typeName : String) : Expr .number → Expr .number → Expr .number
  | max (typeName : String) : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | ge : Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | cases : Expr .comparison → Expr a → Expr a → Expr a → Expr a → Expr a → Expr a → Expr a
  | interval : Expr .number → Expr .number → Expr .interval
  | result : Expr .truth → Expr .interval → Expr .result
  | empty : Expr .interval
  | invalid : Expr .result
  | unreachable : Expr .result

abbrev Locals := (ty : Ty) → String → ty.meaning
abbrev Calls := (fn : Function) → fn.type.meaning
def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .number n => n | .bound b => b.value | .truth b => b | .comparison c => c
  | .variable n => locals _ n | .function fn => calls fn
  | .app f x => f.eval calls locals (x.eval calls locals)
  | .lower x => (x.eval calls locals).lower | .upper x => (x.eval calls locals).upper
  | .convert _ x => x.eval calls locals
  | .add a b => a.eval calls locals + b.eval calls locals | .sub a b => a.eval calls locals - b.eval calls locals
  | .mul a b => a.eval calls locals * b.eval calls locals | .neg x => -x.eval calls locals
  | .min _ a b => Min.min (a.eval calls locals) (b.eval calls locals)
  | .max _ a b => Max.max (a.eval calls locals) (b.eval calls locals)
  | .eq a b => decide (a.eval calls locals = b.eval calls locals)
  | .ne a b => decide (a.eval calls locals ≠ b.eval calls locals)
  | .lt a b => decide (a.eval calls locals < b.eval calls locals)
  | .le a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .gt a b => decide (a.eval calls locals > b.eval calls locals)
  | .ge a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .andThen a b => a.eval calls locals && b.eval calls locals
  | .orElse a b => a.eval calls locals || b.eval calls locals
  | .group x => x.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals
  | .cases c a b d e f g => match c.eval calls locals with
    | .eq => a.eval calls locals | .ne => b.eval calls locals | .lt => d.eval calls locals
    | .le => e.eval calls locals | .gt => f.eval calls locals | .ge => g.eval calls locals
  | .interval a b => ⟨a.eval calls locals,b.eval calls locals⟩
  | .result a b => ⟨a.eval calls locals,b.eval calls locals⟩
  | .empty => Interval.empty | .invalid => ⟨false,Interval.empty⟩
  | .unreachable => ⟨true,Interval.empty⟩

def caseArm (op : Comparison) (value : List String) : List String :=
  ["when",comparisonName op,"=>"] ++ value
def Expr.render : Expr ty → List String
  | .number n => [toString n] | .bound b => b.render
  | .truth b => [if b then "true" else "false"] | .comparison c => [comparisonName c]
  | .variable n => [n] | .function fn => [fn.name]
  | .app f x => match f with
    | .app _ _ => f.render.dropLast ++ [","] ++ x.render ++ [")"]
    | _ => f.render ++ ["("] ++ x.render ++ [")"]
  | .lower x => x.render ++ [".","lower"] | .upper x => x.render ++ [".","upper"]
  | .convert n x => [n,"("] ++ x.render ++ [")"]
  | .add a b => a.render ++ ["+"] ++ b.render | .sub a b => a.render ++ ["-"] ++ b.render
  | .mul a b => a.render ++ ["*"] ++ b.render | .neg x => ["-"] ++ x.render
  | .min n a b => [n,"'","min","("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .max n a b => [n,"'","max","("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .eq a b => a.render ++ ["="] ++ b.render | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render | .ge a b => a.render ++ [">="] ++ b.render
  | .andThen a b => a.render ++ ["and","then"] ++ b.render
  | .orElse a b => a.render ++ ["or","else"] ++ b.render
  | .group x => ["("] ++ x.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .cases c a b d e f g => ["case"] ++ c.render ++ ["is"] ++
      caseArm .eq a.render ++ [","] ++ caseArm .ne b.render ++ [","] ++
      caseArm .lt d.render ++ [","] ++ caseArm .le e.render ++ [","] ++
      caseArm .gt f.render ++ [","] ++ caseArm .ge g.render
  | .interval a b => ["("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .result a b => ["("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .empty => ["empty"] | .invalid => ["invalid"] | .unreachable => ["unreachable"]

abbrev v (name : String) : Expr ty := .variable name
abbrev f := Expr.function
abbrev ap {a b : Ty} := @Expr.app a b
abbrev bounds : Expr .interval := v "bounds"
abbrev left : Expr ty := v "left"
abbrev right : Expr ty := v "right"
abbrev item : Expr .number := v "item"
abbrev threshold : Expr .number := v "threshold"
abbrev operator : Expr .comparison := v "operator"
abbrev app2 {s t u : Ty} (fn : Expr (.arrow s (.arrow t u))) (a : Expr s) (b : Expr t) : Expr u := ap (ap fn a) b
abbrev wide (x : Expr .number) : Expr .number := .convert "wide" x

def isEmptyBody : Expr .truth := .gt (.lower bounds) (.upper bounds)
def containsBody : Expr .truth := .andThen (.ge item (.lower bounds)) (.le item (.upper bounds))
def singletonBody : Expr .interval := .interval item item
def normalizeBody : Expr .interval := .ite (ap (f .isEmpty) bounds) .empty bounds
def joinBody : Expr .interval := .ite (ap (f .isEmpty) left) (ap (f .normalize) right)
  (.elsif (ap (f .isEmpty) right) left
    (.interval (.min "value" (.lower left) (.lower right)) (.max "value" (.upper left) (.upper right))))
def intersectBody : Expr .interval := ap (f .normalize)
  (.interval (.max "value" (.lower left) (.lower right)) (.min "value" (.upper left) (.upper right)))
def compareBody : Expr .truth := .cases operator (.eq left right) (.ne left right)
  (.lt left right) (.le left right) (.gt left right) (.ge left right)
def complementBody : Expr .comparison := .cases operator (.comparison .ne) (.comparison .eq)
  (.comparison .ge) (.comparison .gt) (.comparison .le) (.comparison .lt)
def swapBody : Expr .comparison := .cases operator (.comparison .eq) (.comparison .ne)
  (.comparison .gt) (.comparison .ge) (.comparison .lt) (.comparison .le)
def belowBody : Expr .interval := .ite (.eq threshold (.bound .first)) .empty
  (app2 (f .intersect) bounds (.interval (.bound .first) (.sub threshold (.number 1))))
def aboveBody : Expr .interval := .ite (.eq threshold (.bound .last)) .empty
  (app2 (f .intersect) bounds (.interval (.add threshold (.number 1)) (.bound .last)))
def refineTrueBody : Expr .interval := .cases operator
  (app2 (f .intersect) bounds (ap (f .singleton) threshold))
  (app2 (f .join) (app2 (f .below) bounds threshold) (app2 (f .above) bounds threshold))
  (app2 (f .below) bounds threshold) (app2 (f .intersect) bounds (.interval (.bound .first) threshold))
  (app2 (f .above) bounds threshold) (app2 (f .intersect) bounds (.interval threshold (.bound .last)))
def refineBody : Expr .interval := ap (ap (ap (f .refineTrue) bounds)
  (.group (.ite (v "truth") operator (ap (f .complement) operator)))) threshold
def inRangeBody : Expr .truth := .andThen (.ge item (.bound .minimum)) (.le item (.bound .maximum))
def checkedBody : Expr .result := .ite (.gt (v "lower") (v "upper")) .unreachable
  (.elsif (.andThen (ap (f .inRange) (v "lower")) (ap (f .inRange) (v "upper")))
    (.result (.truth true) (.interval (.convert "value" (v "lower")) (.convert "value" (v "upper")))) .invalid)
def addBody : Expr .result := .ite (.orElse (ap (f .isEmpty) left) (ap (f .isEmpty) right)) .unreachable
  (app2 (f .checked) (.add (wide (.lower left)) (wide (.lower right))) (.add (wide (.upper left)) (wide (.upper right))))
def subtractBody : Expr .result := .ite (.orElse (ap (f .isEmpty) left) (ap (f .isEmpty) right)) .unreachable
  (app2 (f .checked) (.sub (wide (.lower left)) (wide (.upper right))) (.sub (wide (.upper left)) (wide (.lower right))))
def negateBody : Expr .result := .ite (ap (f .isEmpty) (v "operand")) .unreachable
  (app2 (f .checked) (.neg (wide (.upper (v "operand")))) (.neg (wide (.lower (v "operand")))))
def productMinimumBody : Expr .number := .min "wide"
  (.min "wide" (.mul (wide (.lower left)) (wide (.lower right))) (.mul (wide (.lower left)) (wide (.upper right))))
  (.min "wide" (.mul (wide (.upper left)) (wide (.lower right))) (.mul (wide (.upper left)) (wide (.upper right))))
def productMaximumBody : Expr .number := .max "wide"
  (.max "wide" (.mul (wide (.lower left)) (wide (.lower right))) (.mul (wide (.lower left)) (wide (.upper right))))
  (.max "wide" (.mul (wide (.upper left)) (wide (.lower right))) (.mul (wide (.upper left)) (wide (.upper right))))
def multiplyBody : Expr .result := .ite (.orElse (ap (f .isEmpty) left) (ap (f .isEmpty) right)) .unreachable
  (app2 (f .checked) (app2 (f .productMinimum) left right) (app2 (f .productMaximum) left right))


def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .interval => Interval.empty
  | .result => ⟨false, Interval.empty⟩ | .comparison => .eq
  | .arrow _ b => fun _ => b.default

structure Context where
  bounds : Interval := Interval.empty
  left : Interval := Interval.empty
  right : Interval := Interval.empty
  operand : Interval := Interval.empty
  lhs : Int := 0
  rhs : Int := 0
  item : Int := 0
  threshold : Int := 0
  lower : Int := 0
  upper : Int := 0
  operator : Comparison := .eq
  truth : Bool := false

def Context.locals (ctx : Context) : Locals
  | .interval, "bounds" => ctx.bounds
  | .interval, "left" => ctx.left
  | .interval, "right" => ctx.right
  | .interval, "operand" => ctx.operand
  | .number, "left" => ctx.lhs
  | .number, "right" => ctx.rhs
  | .number, "item" => ctx.item
  | .number, "threshold" => ctx.threshold
  | .number, "lower" => ctx.lower
  | .number, "upper" => ctx.upper
  | .comparison, "operator" => ctx.operator
  | .truth, "truth" => ctx.truth
  | ty, _ => ty.default

def Function.interpret (calls : Calls) : (fn : Function) → fn.type.meaning
  | .isEmpty => fun bounds => isEmptyBody.eval calls ({bounds} : Context).locals
  | .contains => fun bounds item => containsBody.eval calls ({bounds,item} : Context).locals
  | .singleton => fun item => singletonBody.eval calls ({item} : Context).locals
  | .normalize => fun bounds => normalizeBody.eval calls ({bounds} : Context).locals
  | .join => fun left right => joinBody.eval calls ({left,right} : Context).locals
  | .intersect => fun left right => intersectBody.eval calls ({left,right} : Context).locals
  | .compare => fun operator lhs rhs => compareBody.eval calls ({operator,lhs,rhs} : Context).locals
  | .complement => fun operator => complementBody.eval calls ({operator} : Context).locals
  | .swap => fun operator => swapBody.eval calls ({operator} : Context).locals
  | .below => fun bounds threshold => belowBody.eval calls ({bounds,threshold} : Context).locals
  | .above => fun bounds threshold => aboveBody.eval calls ({bounds,threshold} : Context).locals
  | .refineTrue => fun bounds operator threshold => refineTrueBody.eval calls ({bounds,operator,threshold} : Context).locals
  | .refine => fun bounds operator threshold truth => refineBody.eval calls ({bounds,operator,threshold,truth} : Context).locals
  | .inRange => fun item => inRangeBody.eval calls ({item} : Context).locals
  | .checked => fun lower upper => checkedBody.eval calls ({lower,upper} : Context).locals
  | .add => fun left right => addBody.eval calls ({left,right} : Context).locals
  | .subtract => fun left right => subtractBody.eval calls ({left,right} : Context).locals
  | .negate => fun operand => negateBody.eval calls ({operand} : Context).locals
  | .productMinimum => fun left right => productMinimumBody.eval calls ({left,right} : Context).locals
  | .productMaximum => fun left right => productMaximumBody.eval calls ({left,right} : Context).locals
  | .multiply => fun left right => multiplyBody.eval calls ({left,right} : Context).locals

def Function.rank : Function → Nat
  | .isEmpty | .contains | .singleton | .compare | .complement | .swap
  | .inRange | .productMinimum | .productMaximum => 0
  | .normalize | .checked => 1
  | .join | .intersect | .add | .subtract | .negate | .multiply => 2
  | .below | .above => 3
  | .refineTrue => 4
  | .refine => 5

def Expr.primary : Expr ty → Bool
  | .number _ | .bound _ | .truth _ | .comparison _ | .variable _ | .function _
  | .app _ _ | .lower _ | .upper _ | .convert _ _ | .min _ _ _ | .max _ _ _
  | .group _ | .interval _ _ | .result _ _ | .empty | .invalid | .unreachable => true
  | _ => false

def Expr.term : Expr ty → Bool
  | .mul _ _ => true | value => value.primary

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ | .neg _ => true | value => value.term

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .lt _ _ | .le _ _ | .gt _ _ | .ge _ _ => true
  | value => value.simple

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true | value => value.relation

def Expr.orHead : Expr ty → Bool
  | .orElse _ _ => true | value => value.relation

def Expr.condition (value : Expr .truth) : Bool := value.andHead || value.orHead

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.functionSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.functionSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .app fn argument => fn.wellFormed && argument.wellFormed && fn.functionSpine && argument.simple
  | .lower value | .upper value => value.wellFormed && value.primary
  | .convert _ value => value.wellFormed && value.simple
  | .min _ left right | .max _ left right => left.wellFormed && right.wellFormed && left.simple && right.simple
  | .add left right | .sub left right => left.wellFormed && right.wellFormed && left.simple && right.term
  | .mul left right => left.wellFormed && right.wellFormed && left.term && right.primary
  | .neg value => value.wellFormed && value.term
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right | .ge left right =>
      left.wellFormed && right.wellFormed && left.simple && right.simple
  | .andThen left right => left.wellFormed && right.wellFormed && left.andHead && right.relation
  | .orElse left right => left.wellFormed && right.wellFormed && left.orHead && right.relation
  | .group value => value.wellFormed && !value.isElsif
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.condition && yes.wellFormed && yes.simple && no.wellFormed && (no.simple || no.isElsif)
  | .cases value a b c d e f => value.wellFormed && value.simple &&
      a.wellFormed && (a.andHead || a.orHead) && b.wellFormed && (b.andHead || b.orHead) && c.wellFormed && (c.andHead || c.orHead) &&
      d.wellFormed && (d.andHead || d.orHead) && e.wellFormed && (e.andHead || e.orHead) && f.wellFormed && (f.andHead || f.orHead)
  | .interval lo hi => lo.wellFormed && lo.simple && hi.wellFormed && hi.simple
  | .result safe bounds => safe.wellFormed && safe.condition && bounds.wellFormed && bounds.simple
  | _ => true

abbrev WellFormedTrees : Prop :=
  isEmptyBody.wellFormed = true ∧ containsBody.wellFormed = true ∧ singletonBody.wellFormed = true ∧
  normalizeBody.wellFormed = true ∧ joinBody.wellFormed = true ∧ intersectBody.wellFormed = true ∧
  compareBody.wellFormed = true ∧ complementBody.wellFormed = true ∧ swapBody.wellFormed = true ∧
  belowBody.wellFormed = true ∧ aboveBody.wellFormed = true ∧ refineTrueBody.wellFormed = true ∧
  refineBody.wellFormed = true ∧ inRangeBody.wellFormed = true ∧ checkedBody.wellFormed = true ∧
  addBody.wellFormed = true ∧ subtractBody.wellFormed = true ∧ negateBody.wellFormed = true ∧
  productMinimumBody.wellFormed = true ∧ productMaximumBody.wellFormed = true ∧ multiplyBody.wellFormed = true


theorem checked_precedence : WellFormedTrees := by decide +kernel

end Silver.Integer.Native
