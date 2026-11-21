module

public import Silver.ComposeArrayTypeNative
public import Silver.ComposeModelCalls

@[expose] public section

namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] ScalarExpression.ArrayGrammar.read

def arrayTypeAtEquation (calls : Calls) (text : Source) (state : ParserState)
    (position : Nat) : Nat :=
  let first := calls.function .skip text position
  let after := calls.function .nameAfter text first
  if decide (first = 0) || decide (after ≤ first) ||
      decide (calls.function .lookupName text state.names first after ≠ 0) ||
      decide (calls.function .scalarLookup text state.scalarNames first after ≠ 0) ||
      decide (calls.function .arrayLookup text state.arrayNames.table first after ≠ 0) ||
      decide (calls.function .booleanLookup text state.booleanNames first after ≠ 0) ||
      decide (calls.function .functionLookup text state.functions first after ≠ 0) ||
      decide (calls.function .procedureLookup text state.procedures first after ≠ 0) ||
      calls.function .formalHides text state first after
  then 0 else calls.function .arrayTypeLookup text state.arrayNames.types first after

theorem arrayTypeAt_denotation (calls : Calls) (text : Source) (state : ParserState)
    (position : Nat) :
    arrayTypeAtBody.eval calls (Context.locals {text,state,position}) =
      arrayTypeAtEquation calls text state position := by
  rfl

def arrayTypeDeclarationEquation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) : ParserState :=
  let take := calls.function .takeToken text
  let first := calls.function .skip text (take state.position (.word "type"))
  let after := calls.function .nameAfter text first
  let start := take (take (take after (.word "is")) (.word "array")) (.symbol "(")
  let low := calls.function .scalarRead text start state.scalarNames state.arrayNames.table [] false
  let high := calls.function .scalarRead text (take low.after (.symbol ".."))
    state.scalarNames state.arrayNames.table [] false
  let component := calls.function .scalarType text state
    (take (take high.after (.symbol ")")) (.word "of"))
  let following := take component.after (.symbol ";")
  if decide (start = 0) || decide (following ≤ state.position) || state.pure ||
      !calls.function .newName text state first after arguments ||
      calls.function .nameIs text first after "integer" ||
      decide (state.arrayNames.types.length = ArrayBindings.maxTypes) ||
      decide (low.after = 0) || decide (high.after = 0) || decide (component.after = 0) ||
      !low.isStatic || !high.isStatic ||
      calls.function .scalarEmpty low.bounds || calls.function .scalarEmpty high.bounds ||
      decide (low.bounds.lower ≠ low.bounds.upper) || decide (high.bounds.lower ≠ high.bounds.upper) ||
      decide (low.bounds.lower > high.bounds.lower) ||
      decide (high.bounds.lower - low.bounds.lower ≥ (ArrayBindings.maxElements : Int))
  then invalidState
  else {state with
    position := following,
    arrayNames := {state.arrayNames with types := state.arrayNames.types ++
      [⟨first, after, ⟨low.bounds.lower, high.bounds.lower⟩, component.bounds⟩]},
    subtypeNames := {state.subtypeNames with
      trueHidden := state.subtypeNames.trueHidden || calls.function .nameIs text first after "true",
      falseHidden := state.subtypeNames.falseHidden || calls.function .nameIs text first after "false",
      hiddenCalls := ⟨state.subtypeNames.hiddenCalls.output || calls.function .nameIs text first after "put_line",
        state.subtypeNames.hiddenCalls.partialOutput || calls.function .nameIs text first after "put",
        state.subtypeNames.hiddenCalls.argument || calls.function .nameIs text first after "first_or_default",
        state.subtypeNames.hiddenCalls.validity || calls.function .nameIs text first after "input_is_valid",
        state.subtypeNames.hiddenCalls.reject || calls.function .nameIs text first after "reject"⟩}}

theorem arrayTypeDeclaration_denotation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) :
    arrayTypeDeclarationBody.eval calls (Context.locals {text,state,arguments}) =
      arrayTypeDeclarationEquation calls text state arguments := by
  rfl

theorem model_arrayTypeAt_equation (text : Source) (state : ParserState) (position : Nat) :
    arrayTypeAtEquation modelCalls text state position = arrayTypeAt text state position := by
  dsimp +instances only [arrayTypeAtEquation, modelCalls, arrayTypeAt]
  simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]
  rfl

theorem model_arrayTypeDeclaration_equation (text : Source) (state : ParserState) (arguments : Bool) :
    arrayTypeDeclarationEquation modelCalls text state arguments = arrayTypeDeclarationAt text state arguments := by
  dsimp +instances only [arrayTypeDeclarationEquation, modelCalls, arrayTypeDeclarationAt,
    IntegerSubtypes.CallHiding.add, spelling, isWord, ShellToken.word, ShellToken.symbol]
  simp only [Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true', or_assoc]
  rfl

end Silver.Compose.Expressions
