module

public import Silver.LengthIntervalModel

@[expose] public section

namespace Silver.LengthIntervals.Native
open Compose Bindings

inductive Ty | number | truth | interval | summary | context
  deriving DecidableEq
@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .interval => LengthSummary
  | .summary => Summary | .context => Paths

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .truth => false | .interval => {} | .summary => {}
  | .context => PathFacts.Native.empty

inductive Field : Ty → Type
  | minimum : Field .number
  | maximum : Field .number
  | count : Field .number
  | empty : Field .truth

def Field.name : Field ty → String
  | .minimum => "minimum_length" | .maximum => "static_length"
  | .count => "dynamic_count" | .empty => "empty_value"
def Field.get : Field ty → LengthSummary → ty.meaning
  | .minimum, value => value.minimumLength | .maximum, value => value.staticLength
  | .count, value => value.dynamicCount | .empty, value => value.empty

inductive Expr : Ty → Type
  | variable (name : String) : Expr ty
  | number (value : Nat) : Expr .number
  | field : Field ty → Expr .interval → Expr ty
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | div : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | group : Expr ty → Expr ty
  | ite : Expr .truth → Expr ty → Expr ty → Expr ty
  | elsif : Expr .truth → Expr ty → Expr ty → Expr ty
  | local (name typeName : String) : Expr .number → Expr ty → Expr ty
  | locals : Expr ty → Expr ty
  | summary : Expr .number → Expr .number → Expr .summary
  | isEmpty : Expr .interval → Expr .truth
  | lower : Expr .interval → Expr .summary
  | upper : Expr .interval → Expr .summary
  | pathsFits : Expr .context → Expr .summary → Expr .truth
  | pathsSame : Expr .context → Expr .summary → Expr .summary → Expr .truth
  | keepIf : Expr .context → Expr .truth → Expr .context
  | intersect : Expr .context → Expr .number → Expr .number → Expr .context
  | increasing : Expr .context → Expr .interval → Expr .interval → Expr .context
  | empty : Expr .context
  | maxLength : Expr .number

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (name : String) (value : Nat) : Locals
  | .number, key => if key = name then value else locals .number key
  | ty, key => locals ty key

def Expr.eval (locals : Locals) : Expr ty → ty.meaning
  | .variable name => locals _ name | .number value => value
  | .field projection value => projection.get (value.eval locals)
  | .add a b => a.eval locals + b.eval locals
  | .sub a b => a.eval locals - b.eval locals
  | .div a b => a.eval locals / b.eval locals
  | .eq a b => decide (a.eval locals = b.eval locals)
  | .ne a b => decide (a.eval locals ≠ b.eval locals)
  | .lt a b => decide (a.eval locals < b.eval locals)
  | .le a b => decide (a.eval locals ≤ b.eval locals)
  | .gt a b => decide (a.eval locals > b.eval locals)
  | .andThen a b => a.eval locals && b.eval locals
  | .orElse a b => a.eval locals || b.eval locals
  | .group value => value.eval locals
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval locals then yes.eval locals else no.eval locals
  | .local name _ value rest => rest.eval (locals.set name (value.eval locals))
  | .locals value => value.eval locals
  | .summary a b => ⟨a.eval locals, b.eval locals⟩
  | .isEmpty value => (value.eval locals).empty
  | .lower value => (value.eval locals).lower
  | .upper value => (value.eval locals).upper
  | .pathsFits facts value => PathFacts.Native.fits (facts.eval locals) (value.eval locals)
  | .pathsSame facts left right => PathFacts.Native.sameLength (facts.eval locals)
      (left.eval locals) (right.eval locals)
  | .keepIf facts condition => PathFacts.Native.keepIf (facts.eval locals) (condition.eval locals)
  | .intersect facts low high => PathFacts.Native.intersect (facts.eval locals) (low.eval locals) (high.eval locals)
  | .increasing facts left right => equalIncreasing (facts.eval locals) (left.eval locals) (right.eval locals)
  | .empty => PathFacts.Native.empty
  | .maxLength => maxSourceLength

def call (name : List String) (args : List (List String)) : List String :=
  name ++ ["("] ++ List.flatten (List.intersperse [","] args) ++ [")"]

def Expr.render : Expr ty → List String
  | .variable name => [name] | .number value => [toString value]
  | .field projection value => value.render ++ [".", projection.name]
  | .add a b => a.render ++ ["+"] ++ b.render
  | .sub a b => a.render ++ ["-"] ++ b.render
  | .div a b => a.render ++ ["/"] ++ b.render
  | .eq a b => a.render ++ ["="] ++ b.render
  | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render
  | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .orElse a b => a.render ++ ["or", "else"] ++ b.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .local name typeName value rest => [name, ":", "constant", typeName, ":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .summary a b => a.render ++ [","] ++ b.render
  | .isEmpty value => call ["is_empty"] [value.render]
  | .lower value => call ["lower"] [value.render]
  | .upper value => call ["upper"] [value.render]
  | .pathsFits facts value => call ["paths", ".", "fits"] [facts.render, value.render]
  | .pathsSame facts left right => call ["paths", ".", "same_length"] [facts.render, left.render, right.render]
  | .keepIf facts condition => call ["paths", ".", "keep_if"] [facts.render, condition.render]
  | .intersect facts low high => call ["paths", ".", "intersect"] [facts.render, low.render, high.render]
  | .increasing facts left right => call ["equal_increasing"] [facts.render, left.render, right.render]
  | .empty => ["paths", ".", "empty_context"]
  | .maxLength => ["paths", ".", "max_length"]

abbrev v (name : String) : Expr ty := .variable name
abbrev value : Expr .interval := v "value"
abbrev left : Expr .interval := v "left"
abbrev right : Expr .interval := v "right"
abbrev facts : Expr .context := v "facts"
abbrev low := Expr.field Field.minimum
abbrev high := Expr.field Field.maximum
abbrev count := Expr.field Field.count

def isEmptyBody : Expr .truth := .field .empty value
def lowerBody : Expr .summary := .summary (low value) (count value)
def upperBody : Expr .summary := .summary (high value) (count value)
def fitsBody : Expr .truth :=
  .andThen (.le (high value) .maxLength)
    (.group (.orElse (.isEmpty value) (.pathsFits facts (.upper value))))
def sameLengthBody : Expr .truth :=
  .ite (.orElse (.isEmpty left) (.isEmpty right))
    (.orElse (.ne (count right) (.number 0)) (.le (low left) (high right)))
    (.andThen (.pathsSame facts (.lower left) (.upper right))
      (.pathsSame facts (.upper left) (.lower right)))
def increasingBody : Expr .context :=
  .ite (.lt (high right) (low left)) .empty
    (.group (.locals (.local "difference" "positive" (.sub (count left) (count right))
      (.local "numerator" "natural"
        (.group (.ite (.gt (low right) (high left)) (.sub (low right) (high left)) (.number 0)))
        (.local "low" "natural"
          (.div (.group (.sub (.group (.add (v "numerator") (v "difference"))) (.number 1))) (v "difference"))
          (.local "high" "natural" (.div (.group (.sub (high right) (low left))) (v "difference"))
            (.intersect facts (v "low") (v "high"))))))))
def refineEqualBody : Expr .context :=
  .ite (.orElse (.isEmpty left) (.isEmpty right)) .empty
    (.elsif (.eq (count left) (count right))
      (.keepIf facts (.andThen (.le (low left) (high right)) (.le (low right) (high left))))
      (.elsif (.gt (count left) (count right))
        (.increasing facts left right) (.increasing facts right left)))

structure Inputs where
  facts : Paths := PathFacts.Native.empty
  value : LengthSummary := {}
  left : LengthSummary := {}
  right : LengthSummary := {}

def Inputs.locals (inputs : Inputs) : Locals
  | .context, "facts" => inputs.facts
  | .interval, "value" => inputs.value
  | .interval, "left" => inputs.left
  | .interval, "right" => inputs.right
  | ty, _ => ty.default

@[simp] theorem isEmptyBody_eval (value : LengthSummary) :
    isEmptyBody.eval ({value} : Inputs).locals = value.empty := rfl
@[simp] theorem lowerBody_eval (value : LengthSummary) :
    lowerBody.eval ({value} : Inputs).locals = value.lower := rfl
@[simp] theorem upperBody_eval (value : LengthSummary) :
    upperBody.eval ({value} : Inputs).locals = value.upper := rfl
@[simp] theorem fitsBody_eval (facts : Paths) (value : LengthSummary) :
    fitsBody.eval ({facts, value} : Inputs).locals = fits facts value := rfl
@[simp] theorem sameLengthBody_eval (facts : Paths) (left right : LengthSummary) :
    sameLengthBody.eval ({facts, left, right} : Inputs).locals = sameLength facts left right := rfl
@[simp] theorem increasingBody_eval (facts : Paths) (left right : LengthSummary) :
    increasingBody.eval ({facts, left, right} : Inputs).locals = equalIncreasing facts left right := by
  dsimp +instances only [increasingBody, Expr.eval, Field.get, Inputs.locals, Locals.set]
  simp only [decide_eq_true_eq, equalIncreasing, String.reduceEq, ↓reduceIte]

@[simp] theorem refineEqualBody_eval (facts : Paths) (left right : LengthSummary) :
    refineEqualBody.eval ({facts, left, right} : Inputs).locals = refineEqual facts left right := by
  dsimp +instances only [refineEqualBody, Expr.eval, Field.get, Inputs.locals]
  simp only [decide_eq_true_eq, refineEqual]


end Silver.LengthIntervals.Native
