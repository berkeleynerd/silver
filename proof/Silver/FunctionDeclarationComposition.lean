module

public import Silver.FunctionDeclarationBodyImports
public import Silver.FunctionDeclarationOuterEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

structure DeclarationLexical (calls : Calls) (text : Source) (state : ParserState) : Prop where
  start : calls .take text state.position (.fixed "function" true) = fixedAfter text state.position "function" true
  first : let p := declarationParts modelCalls text state
    calls .skip text p.start = p.first
  after : let p := declarationParts modelCalls text state
    calls .nameAfter text p.first = p.after
  opening : let p := declarationParts modelCalls text state
    calls .take text p.after (.fixed "(" false) = p.opening

theorem declaration_parts_imports (calls : Calls) (text : Source) (state : ParserState)
    (imports : DeclarationLexical calls text state) :
    declarationParts calls text state = declarationParts modelCalls text state := by
  dsimp only [declarationParts]
  rw (transparency := .default) [imports.start, imports.first, imports.after, imports.opening]
  rfl

structure DeclarationTailImports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (parts : DeclarationParts) : Prop where
  initial : declarationInitial calls text state parts = declarationInitial modelCalls text state parts
  parameters : let initial := declarationInitial modelCalls text state parts
    calls .parameters text initial arguments = parametersAt text initial arguments
  returnToken : let header := parametersAt text (declarationInitial modelCalls text state parts) arguments
    header.position ≠ 0 → calls .take text header.position (.fixed "return" true) = fixedAfter text header.position "return" true
  resultType : let header := parametersAt text (declarationInitial modelCalls text state parts) arguments
    header.position ≠ 0 → calls .functionType text header (fixedAfter text header.position "return" true) =
      functionTypeAt text header (fixedAfter text header.position "return" true)
  isToken : let header := parametersAt text (declarationInitial modelCalls text state parts) arguments
    let value := functionTypeAt text header (fixedAfter text header.position "return" true)
    header.position ≠ 0 → calls .take text value.after (.fixed "is" true) = fixedAfter text value.after "is" true
  body : let header := parametersAt text (declarationInitial modelCalls text state parts) arguments
    let value := functionTypeAt text header (fixedAfter text header.position "return" true)
    let bodyStart := fixedAfter text value.after "is" true
    header.position ≠ 0 → value.after ≠ 0 → bodyStart ≠ 0 →
    calls .functionBody text state {header with position := bodyStart} parts.first parts.after value arguments =
      functionBodyAt text state {header with position := bodyStart} parts.first parts.after value arguments

structure DeclarationImports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    : Prop extends DeclarationLexical calls text state where
  newName : let p := declarationParts modelCalls text state
    calls .newName text state p.first p.after arguments = newNameAllowed text state p.first p.after arguments
  tail : let p := declarationParts modelCalls text state
    declarationRejected modelCalls text state arguments p = false → DeclarationTailImports calls text state arguments p

theorem declaration_imports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (imports : DeclarationImports calls text state arguments) :
    functionDeclarationBody.eval calls ({text, state, arguments} : Frame).locals = functionDeclarationAt text state arguments := by
  have rejectedSame : declarationRejected calls text state arguments (declarationParts modelCalls text state) =
      declarationRejected modelCalls text state arguments (declarationParts modelCalls text state) := by
    unfold declarationRejected
    rw [imports.newName]
    rfl
  rw [declaration_denotation, declaration_model_equation]
  unfold declarationEquation
  have modelParameters : modelCalls .parameters = parametersAt := rfl
  have modelType : modelCalls .functionType = functionTypeAt := rfl
  have modelBody : modelCalls .functionBody = functionBodyAt := rfl
  have modelTake : modelCalls .take = tokenAfter := rfl
  simp only [modelParameters, modelType, modelBody, modelTake]
  simp only [decide_eq_true_eq, Bool.or_eq_true]
  rw [declaration_parts_imports calls text state imports.toDeclarationLexical, rejectedSame]
  cases rejected : declarationRejected modelCalls text state arguments (declarationParts modelCalls text state) with
  | true => simp only [↓reduceIte]
  | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      have tail := imports.tail rejected
      rw [tail.initial, tail.parameters]
      dsimp only [tokenAfter]
      by_cases headerZero : (parametersAt text (declarationInitial modelCalls text state (declarationParts modelCalls text state)) arguments).position = 0
      · simp only [headerZero, ↓reduceIte]
      · simp only [headerZero, ↓reduceIte]
        rw [tail.returnToken headerZero, tail.resultType headerZero, tail.isToken headerZero]
        split
        · rfl
        · rename_i accepted
          exact tail.body headerZero (fun zero => accepted (.inl zero)) (fun zero => accepted (.inr zero))

end Silver.Compose.FunctionDeclarationNative
