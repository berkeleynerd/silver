module

public import Silver.PredicateChecking
public import Silver.IntegerIteration

@[expose] public section

/-! Shared path and length checks below declaration/body admission. Their
soundness theorems remain with the full statement semantics. -/
namespace Silver.Predicate
open Bindings Compose PathFacts

def equalSummary (context : Context) (left right : Summary) : Bool :=
  ((decide (right.dynamicCount ≠ 0) ||
      (decide (left.staticLength ≤ right.staticLength) &&
        (decide (left.dynamicCount ≠ 0) || decide (left.staticLength = right.staticLength)))) &&
    (match context.validLengths with
    | none => true
    | some interval => decide (left.length interval.lower = right.length interval.lower ∧
        left.length interval.upper = right.length interval.upper))) &&
    (!context.invalidReachable || decide (left.length 0 = right.length 0))

def equalLengthSummary (context : Context) (left : LengthSummary) (right : Summary) : Bool :=
  if left.empty then
    decide (right.dynamicCount ≠ 0 ∨ left.minimumLength ≤ right.staticLength)
  else equalSummary context left.lower right && equalSummary context left.upper right

def loopContext (context : Context) (bounds : Integer.Interval) : Context :=
  if bounds.isEmpty then Context.empty else context

def loopAfter (before after : Context) (lower upper : Integer.Interval) : Context :=
  if (Integer.loopBounds lower upper).isEmpty then before
  else if Integer.loopDefinite lower upper then after else before.join after

end Silver.Predicate
