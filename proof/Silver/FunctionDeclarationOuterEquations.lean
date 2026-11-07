module

public import Silver.FunctionDeclarationHeaderEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

structure DeclarationParts where
  start : Nat
  first : Nat
  after : Nat
  opening : Nat

def declarationParts (calls : Calls) (text : Source) (state : ParserState) : DeclarationParts :=
  let start := calls .take text state.position (.fixed "function" true)
  let first := calls .skip text start
  let after := calls .nameAfter text first
  ⟨start, first, after, calls .take text after (.fixed "(" false)⟩

def declarationRejected (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (parts : DeclarationParts) : Bool :=
  decide (parts.start = 0) || decide (parts.opening = 0) || state.pure ||
    !calls .newName text state parts.first parts.after arguments ||
    decide (state.functions.items.length = FunctionBindings.maxFunctions) ||
    decide (state.functions.parameters.length = FunctionBindings.maxFormals)

def declarationInitial (calls : Calls) (text : Source) (state : ParserState) (parts : DeclarationParts) : ParserState :=
  {initialState with
    position := parts.opening, pure := true,
    subtypeNames := state.subtypeNames, functions := state.functions,
    «hiding» := calls .hideName text (calls .hiddenOuter text state) parts.first parts.after,
    firstParameter := state.functions.parameters.length + 1}

def declarationEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := declarationParts calls text state
  if declarationRejected calls text state arguments parts then invalidState else
  let initial := declarationInitial calls text state parts
  let header := calls .parameters text initial arguments
  if decide (header.position = 0) then invalidState else
  let resultType := calls .functionType text header (calls .take text header.position (.fixed "return" true))
  let bodyStart := calls .take text resultType.after (.fixed "is" true)
  if decide (resultType.after = 0) || decide (bodyStart = 0) then invalidState else
    calls .functionBody text state {header with position := bodyStart} parts.first parts.after resultType arguments

private theorem local_set_here (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) :
    (locals.set ty name value) ty name = value := by
  simp only [Locals.set, ↓reduceDIte, ↓reduceIte]

private theorem local_set_name (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : actual ≠ name) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceIte]
  split <;> rfl

private theorem local_set_type (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : other ≠ ty) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceDIte]

theorem declaration_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    functionDeclarationBody.eval calls ({text, state, arguments} : Frame).locals = declarationEquation calls text state arguments := by
  simp +instances only [functionDeclarationBody, declarationEquation, declarationParts, declarationInitial, declarationRejected,
    ↓Command.eval, ↓Expr.eval, apply2, apply3, apply4, apply5,
    ↓local_set_here, ↓local_set_name, Frame.locals,
    Field.get, StateField.set, Token.shell, ShellToken.word, ShellToken.symbol, Capacity.value,
    String.reduceEq, ne_eq, not_false_eq_true, ↓reduceIte]
  rfl

theorem declaration_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    functionDeclarationAt text state arguments = declarationEquation modelCalls text state arguments := by
  exact (functionDeclaration_model text state arguments).symm.trans
    (declaration_denotation modelCalls text state arguments)

end Silver.Compose.FunctionDeclarationNative
