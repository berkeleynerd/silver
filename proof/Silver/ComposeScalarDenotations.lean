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
    (names : ScalarExpression.Environment) (baseBounds : Integer.Interval) (arrays : ArrayBindings.Table) : ScalarConstraintResult :=
  let rangeAfter := calls.function .takeToken text position (.word "range")
  let low := calls.function .scalarRead text rangeAfter names arrays [] false
  let delimiterAfter := calls.function .takeToken text low.after (.symbol "..")
  let high := calls.function .scalarRead text delimiterAfter names arrays [] false
  if decide (rangeAfter = 0) then ⟨position, baseBounds⟩
  else if decide (low.after = 0) || decide (delimiterAfter = 0) || decide (high.after = 0) ||
      !low.isStatic || !high.isStatic || calls.function .scalarEmpty low.bounds ||
      calls.function .scalarEmpty high.bounds || decide (low.bounds.lower ≠ low.bounds.upper) ||
      decide (high.bounds.lower ≠ high.bounds.upper) || decide (high.bounds.lower < low.bounds.lower) ||
      decide (low.bounds.lower < baseBounds.lower) || decide (high.bounds.lower > baseBounds.upper)
    then ⟨0, Integer.Interval.empty⟩
    else ⟨high.after, ⟨low.bounds.lower, high.bounds.lower⟩⟩

def scalarTypeEquation (calls : Calls) (text : Source) (state : ParserState) (position : Nat) : ScalarConstraintResult :=
  let first := calls.function .skip text position
  let after := calls.function .nameAfter text first
  let target := calls.function .subtypeLookup text state.subtypeNames first after
  if decide (first = 0) || decide (after ≤ first) ||
      decide (calls.function .lookupName text state.names first after ≠ 0) ||
      decide (calls.function .scalarLookup text state.scalarNames first after ≠ 0) ||
      decide (calls.function .arrayLookup text state.arrayNames.table first after ≠ 0) ||
      decide (calls.function .arrayTypeLookup text state.arrayNames.types first after ≠ 0) ||
      decide (calls.function .booleanLookup text state.booleanNames first after ≠ 0) ||
      decide (calls.function .functionLookup text state.functions first after ≠ 0) ||
      decide (calls.function .procedureLookup text state.procedures first after ≠ 0) ||
      calls.function .formalHides text state first after ||
      (state.hiding.integerHidden && calls.function .nameIs text first after "integer")
  then ⟨0, .empty⟩
  else if calls.function .nameIs text first after "integer" then ⟨after, .full⟩
  else if decide (target ≠ 0) then ⟨after, (IntegerSubtypes.binding state.subtypeNames target).bounds⟩
  else ⟨0, .empty⟩

def subtypeDeclarationEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let first := calls.function .skip text (calls.function .takeToken text state.position (.word "subtype"))
  let after := calls.function .nameAfter text first
  let typeFirst := calls.function .skip text (calls.function .takeToken text after (.word "is"))
  let typeAfter := calls.function .takeToken text typeFirst (.word "integer")
  let constraint := calls.function .scalarConstraint text typeAfter state.scalarNames .full state.arrayNames.table
  let following := calls.function .takeToken text constraint.after (.symbol ";")
  if !calls.function .newName text state first after arguments ||
      calls.function .nameIs text first after "integer" ||
      decide (state.subtypeNames.items.length = IntegerSubtypes.maxBindings) ||
      decide (typeAfter = 0) || decide (calls.function .takeToken text typeAfter (.word "range") = 0) ||
      decide (constraint.after = 0) || decide (following ≤ state.position) ||
      calls.function .scalarEmpty constraint.bounds ||
      decide (calls.function .lookupName text state.names typeFirst typeAfter ≠ 0) ||
      decide (calls.function .scalarLookup text state.scalarNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .arrayLookup text state.arrayNames.table typeFirst typeAfter ≠ 0) ||
      decide (calls.function .arrayTypeLookup text state.arrayNames.types typeFirst typeAfter ≠ 0) ||
      decide (calls.function .booleanLookup text state.booleanNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .functionLookup text state.functions typeFirst typeAfter ≠ 0) ||
      decide (calls.function .procedureLookup text state.procedures typeFirst typeAfter ≠ 0) ||
      calls.function .formalHides text state typeFirst typeAfter ||
      (state.hiding.integerHidden && calls.function .nameIs text typeFirst typeAfter "integer") ||
      (state.hiding.booleanHidden && calls.function .nameIs text typeFirst typeAfter "boolean") ||
      (state.hiding.characterHidden && calls.function .nameIs text typeFirst typeAfter "character")
  then invalidState
  else
    let hidden (op : Names.Operation) := state.subtypeNames.hiddenCalls.get op ||
      calls.function .nameIs text first after op.name
    { state with
      position := following
      subtypeNames := {
        items := state.subtypeNames.items ++ [⟨first,after,constraint.bounds⟩]
        trueHidden := state.subtypeNames.trueHidden || calls.function .nameIs text first after "true"
        falseHidden := state.subtypeNames.falseHidden || calls.function .nameIs text first after "false"
        hiddenCalls := {
          output := hidden .output
          partialOutput := hidden .partialOutput
          argument := hidden .argument
          validity := hidden .validity
          reject := hidden .reject } } }

theorem scalarType_denotation (calls : Calls) (text : Source) (state : ParserState) (position : Nat) :
    scalarTypeBody.eval calls (Context.locals {text,state,position}) = scalarTypeEquation calls text state position := by rfl

theorem subtypeDeclaration_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    subtypeDeclarationBody.eval calls (Context.locals {text,state,arguments}) = subtypeDeclarationEquation calls text state arguments := by rfl

def scalarDeclarationEquation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) : ParserState :=
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := calls.function .takeToken text after (.symbol ":")
  let constant := calls.function .takeToken text colon (.word "constant")
  let typeFirst := calls.function .skip text (if decide (constant ≠ 0) then constant else colon)
  let typeMark := calls.function .scalarType text state typeFirst
  let typeAfter := typeMark.after
  let constraint := calls.function .scalarConstraint text typeAfter state.scalarNames typeMark.bounds state.arrayNames.table
  let value := calls.function .scalarRead text
    (calls.function .takeToken text constraint.after (.symbol ":=")) state.scalarNames
    state.arrayNames.table state.arrayNames.values true
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
      decide (calls.function .arrayLookup text state.arrayNames.table typeFirst typeAfter ≠ 0) ||
      decide (calls.function .arrayTypeLookup text state.arrayNames.types typeFirst typeAfter ≠ 0)
    then invalidState
    else {state with position := following, scalarNames := (calls.function .scalarAppend state.scalarNames ⟨first, after, value.bounds, decide (constant ≠ 0) && value.isStatic, constraint.bounds, decide (constant = 0)⟩)}

theorem scalarConstraint_denotation (calls : Calls) (text : Source) (position : Nat)
    (scalarNames : ScalarExpression.Environment) (baseBounds : Integer.Interval) (arrays : ArrayBindings.Table) :
    scalarConstraintBody.eval calls (Context.locals {text,position,scalarNames,baseBounds,arrays}) =
      scalarConstraintEquation calls text position scalarNames baseBounds arrays := by
  rfl

theorem scalarDeclaration_denotation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) :
    scalarDeclarationBody.eval calls (Context.locals {text,state,arguments}) =
      scalarDeclarationEquation calls text state arguments := by
  rfl

end Silver.Compose.Expressions
