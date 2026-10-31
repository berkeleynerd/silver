module

public import Silver.ComposeContracts

@[expose] public section
namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- The exact ordinary String declaration body, with callee results named before
interpreting their domains. This retains every native rejection and metadata field. -/
def stringDeclarationEquation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) : ParserState :=
  let take := calls.function .takeToken text
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := take after (.symbol ":")
  let constant := take colon (.word "constant")
  let typeAfter := take (if decide (constant ≠ 0) then constant else colon) (.word "string")
  let hidden := (decide (first ≠ 0) && decide (after > first) &&
    decide (take first (.word "integer") = after)) ||
    calls.function .booleanHidesInteger text state.booleanNames
  let value := calls.function .expression text (take typeAfter (.symbol ":=")) state.names
    state.scalarNames hidden state.arrayNames.names state.arrayNames.values true
  let following := take value.after (.symbol ";")
  if !calls.function .newName text state first after arguments || decide (following = 0) ||
      decide (state.names.length = maxBindings) || !calls.function .fits value maxSourceLength ||
      value.emptyValue || decide (value.minimumLength ≠ value.staticLength) ||
      (decide (value.dynamicCount = 0) &&
        (calls.function .scalarEmpty value.firstIndex || calls.function .scalarEmpty value.lastIndex ||
          decide (value.firstIndex.lower ≠ value.firstIndex.upper) ||
          decide (value.lastIndex.lower ≠ value.lastIndex.upper))) ||
      !calls.function .fixedBoundsValid value.staticLength (decide (value.dynamicCount = 1)) false
        value.firstIndex.lower value.lastIndex.lower (state.names.length + 1)
  then invalidState
  else calls.function .addBinding state first after value.value (decide (constant = 0)) following

theorem stringDeclaration_denotation (calls : Calls) (text : Source) (state : ParserState)
    (arguments : Bool) :
    stringDeclarationBody.eval (lexical calls) (Context.locals {text,state,arguments}) =
      stringDeclarationEquation calls text state arguments := by rfl

end Silver.Compose.Expressions
