module

public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- Value equations for the typed declaration bodies. Naming the intermediate
values keeps dependent local lookup reduction separate from callee refinement. -/
def scalarConstraintEquation (calls : Calls) (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) : ScalarConstraintResult :=
  let rangeAfter := calls.function .takeToken text position (.word "range")
  let low := calls.function .scalarRead text rangeAfter names [] [] false
  let delimiterAfter := calls.function .takeToken text low.after (.symbol "..")
  let high := calls.function .scalarRead text delimiterAfter names [] [] false
  if decide (rangeAfter = 0) then ⟨position, Integer.Interval.full⟩
  else if decide (low.after = 0) || decide (delimiterAfter = 0) || decide (high.after = 0) ||
      !low.isStatic || !high.isStatic || calls.function .scalarEmpty low.bounds ||
      calls.function .scalarEmpty high.bounds || decide (low.bounds.lower ≠ low.bounds.upper) ||
      decide (high.bounds.lower ≠ high.bounds.upper) || decide (high.bounds.lower < low.bounds.lower)
    then ⟨0, Integer.Interval.empty⟩
    else ⟨high.after, ⟨low.bounds.lower, high.bounds.lower⟩⟩

def scalarDeclarationEquation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) : ParserState :=
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := calls.function .takeToken text after (.symbol ":")
  let constant := calls.function .takeToken text colon (.word "constant")
  let typeFirst := calls.function .skip text (if decide (constant ≠ 0) then constant else colon)
  let typeAfter := calls.function .takeToken text typeFirst (.word "integer")
  let constraint := calls.function .scalarConstraint text typeAfter state.scalarNames
  let value := calls.function .scalarRead text
    (calls.function .takeToken text constraint.after (.symbol ":=")) state.scalarNames
    state.arrayNames.names state.arrayNames.values true
  let following := calls.function .takeToken text value.after (.symbol ";")
  if !calls.function .newName text state first after arguments ||
      decide (typeAfter = 0) || decide (constraint.after = 0) ||
      decide (following ≤ state.position) ||
      decide (state.scalarNames.length = ScalarExpression.maxBindings) ||
      calls.function .scalarEmpty value.bounds ||
      decide (value.bounds.lower ≠ value.bounds.upper) ||
      decide (value.bounds.lower < constraint.bounds.lower) ||
      decide (constraint.bounds.upper < value.bounds.upper) ||
      calls.function .nameIs text first after "integer" ||
      decide (calls.function .lookupName text state.names typeFirst typeAfter ≠ 0) ||
      decide (calls.function .scalarLookup text state.scalarNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .arrayLookup text state.arrayNames.names typeFirst typeAfter ≠ 0)
    then invalidState
    else {state with position := following, scalarNames := (calls.function .scalarAppend state.scalarNames ⟨first, after, value.bounds, decide (constant ≠ 0) && value.isStatic, constraint.bounds, decide (constant = 0)⟩)}

theorem scalarConstraint_denotation (calls : Calls) (text : Source) (position : Nat)
    (scalarNames : ScalarExpression.Environment) :
    scalarConstraintBody.eval calls (Context.locals {text,position,scalarNames}) =
      scalarConstraintEquation calls text position scalarNames := by
  rfl

theorem scalarDeclaration_denotation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) :
    scalarDeclarationBody.eval calls (Context.locals {text,state,arguments}) =
      scalarDeclarationEquation calls text state arguments := by
  rfl

end Silver.Compose.Expressions
