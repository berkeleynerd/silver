module

public import Silver.ComposeArrayExpressions
public import Silver.ComposeModelCalls
public meta import Silver.CertificateWitness

@[expose] public section

namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 300000
set_option backward.dsimp.instances true
attribute [local irreducible] ScalarExpression.read

theorem arrayPut_denotation (calls : Calls) (state : ParserState) (value : Int) :
    arrayPutBody.eval calls (arrayPutLocals state value) = putArrayValue state value := by
  rfl

def arrayValuesEquation (calls : Calls) (text : Source) (source result : ParserState)
    (position length parsed : Nat) : ParserState :=
  if decide (position = 0) then invalidState
  else if decide (parsed = length) then {result with position}
  else
    let value := calls.function .scalarRead text position source.scalarNames
      source.arrayNames.names source.arrayNames.values true
    if decide (value.after = 0) || calls.function .scalarEmpty value.bounds ||
        decide (value.bounds.lower ≠ value.bounds.upper) then invalidState
    else
      let next := calls.function .arrayPut result value.bounds.lower
      let following := if decide (parsed + 1 < length) then
        calls.function .takeToken text value.after (.symbol ",") else value.after
      calls.function .arrayValuesModel text source next following length (parsed + 1)

theorem arrayValues_denotation (calls : Calls) (text : Source) (source result : ParserState)
    (position length parsed : Nat) :
    arrayValuesModelBody.eval calls (arrayValuesLocals text source result position length parsed) =
      arrayValuesEquation calls text source result position length parsed := by
  rfl

theorem model_arrayValues_equation (text : Source) (source result : ParserState)
    (position length parsed : Nat) (bounded : parsed ≤ length) :
    arrayValuesEquation modelCalls text source result position length parsed =
      arrayValuesModel text source result position length parsed := by
  conv => rhs; rw [arrayValuesModel]
  unfold arrayValuesEquation
  simp only [decide_eq_true_eq]
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases done : parsed = length
    · subst parsed
      simp only [Nat.lt_irrefl, ↓reduceDIte, ↓reduceIte]
    · have more : parsed < length := by omega
      simp only [done, more, ↓reduceDIte, ↓reduceIte]
      dsimp +instances only [modelCalls, putArrayValue, spelling, isWord, ShellToken.symbol]
      simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]

def arrayDeclarationEquation (calls : Calls) (executable : Bool)
    (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let take := calls.function .takeToken text
  let read := fun position => calls.function .scalarRead text position state.scalarNames
    state.arrayNames.names state.arrayNames.values true
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := take after (.symbol ":")
  let constant := take colon (.word "constant")
  let arrayAfter := take (if decide (constant ≠ 0) then constant else colon) (.word "array")
  let low := read (take arrayAfter (.symbol "("))
  let high := read (take low.after (.symbol ".."))
  let typeFirst := calls.function .skip text (take (take high.after (.symbol ")")) (.word "of"))
  let typeAfter := take typeFirst (.word "integer")
  let position := take (take typeAfter (.symbol ":=")) (.symbol "(")
  if !calls.function .newName text state first after arguments ||
      calls.function .nameIs text first after "integer" ||
      decide (arrayAfter = 0) || decide (position = 0) ||
      decide (state.arrayNames.names.length = ArrayBindings.maxBindings) ||
      decide (low.after = 0) || decide (high.after = 0) || !low.isStatic || !high.isStatic ||
      calls.function .scalarEmpty low.bounds || calls.function .scalarEmpty high.bounds ||
      decide (low.bounds.lower ≠ low.bounds.upper) || decide (high.bounds.lower ≠ high.bounds.upper) ||
      decide (low.bounds.lower > high.bounds.lower) ||
      decide (high.bounds.lower - low.bounds.lower ≥ (ArrayBindings.maxElements - state.arrayNames.used : Nat)) ||
      decide (calls.function .lookupName text state.names typeFirst typeAfter ≠ 0) ||
      decide (calls.function .scalarLookup text state.scalarNames typeFirst typeAfter ≠ 0) ||
      decide (calls.function .arrayLookup text state.arrayNames.names typeFirst typeAfter ≠ 0)
  then invalidState else
    let length := (high.bounds.lower - low.bounds.lower + 1).toNat
    let choice := if decide (length = 1) then read position else ScalarExpression.invalid
    let valuesFirst := if decide (length = 1) then take choice.after (.symbol "=>") else position
    if decide (length = 1) &&
        (decide (valuesFirst = 0) || !choice.isStatic || calls.function .scalarEmpty choice.bounds ||
          decide (choice.bounds.lower ≠ low.bounds.lower) || decide (choice.bounds.upper ≠ low.bounds.lower))
    then invalidState else
      let values := (if executable then calls.function .arrayValues else calls.function .arrayValuesModel)
        text state state valuesFirst length 0
      let following := take (take values.position (.symbol ")")) (.symbol ";")
      if decide (values.position = 0) || decide (following ≤ state.position) then invalidState else
        {values with position := following, arrayNames := {values.arrayNames with
          names := state.arrayNames.names ++ [⟨first, after, ⟨low.bounds.lower, high.bounds.lower⟩,
            state.arrayNames.used, length, decide (constant = 0)⟩]}}

private theorem arrayDeclaration_false_denotation : ∀ (calls : Calls)
    (text : Source) (state : ParserState) (arguments : Bool),
    (arrayDeclarationBody false).eval calls (Context.locals {text,state,arguments}) =
      arrayDeclarationEquation calls false text state arguments := by
  kernel_exact (fun (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) =>
    Eq.refl ((arrayDeclarationBody false).eval calls (Context.locals {text,state,arguments})))

private theorem arrayDeclaration_true_denotation : ∀ (calls : Calls)
    (text : Source) (state : ParserState) (arguments : Bool),
    (arrayDeclarationBody true).eval calls (Context.locals {text,state,arguments}) =
      arrayDeclarationEquation calls true text state arguments := by
  kernel_exact (fun (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) =>
    Eq.refl ((arrayDeclarationBody true).eval calls (Context.locals {text,state,arguments})))

theorem arrayDeclaration_denotation (calls : Calls) (executable : Bool)
    (text : Source) (state : ParserState) (arguments : Bool) :
    (arrayDeclarationBody executable).eval calls (Context.locals {text,state,arguments}) =
      arrayDeclarationEquation calls executable text state arguments := by
  cases executable
  · exact arrayDeclaration_false_denotation calls text state arguments
  · exact arrayDeclaration_true_denotation calls text state arguments

end Silver.Compose.Expressions
