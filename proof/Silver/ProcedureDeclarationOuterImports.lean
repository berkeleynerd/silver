module

public import Silver.ProcedureDeclarationOuterNative

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

structure DeclarationLexical (calls : Calls) (text : Source) (state : ParserState) : Prop where
  start : calls .take text state.position (.fixed "procedure" true) = fixedAfter text state.position "procedure" true
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
    calls .procedureParameters text initial arguments = procedureParametersAt text initial arguments
  isToken : let header := procedureParametersAt text (declarationInitial modelCalls text state parts) arguments
    header.position ≠ 0 → calls .take text header.position (.fixed "is" true) = fixedAfter text header.position "is" true
  body : let header := procedureParametersAt text (declarationInitial modelCalls text state parts) arguments
    let bodyStart := fixedAfter text header.position "is" true
    header.position ≠ 0 → bodyStart ≠ 0 →
    (header.procedures.parameters.drop (header.firstProcedureParameter - 1)).any
      (fun parameter => parameter.mode != .input) = true →
    calls .procedureBody text state {header with position := bodyStart} parts.first parts.after arguments =
      procedureBodyAt text state {header with position := bodyStart} parts.first parts.after arguments

structure DeclarationImports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    : Prop extends DeclarationLexical calls text state where
  newName : let p := declarationParts modelCalls text state
    calls .newName text state p.first p.after arguments = newNameAllowed text state p.first p.after arguments
  tail : let p := declarationParts modelCalls text state
    declarationRejected modelCalls text state arguments p = false → DeclarationTailImports calls text state arguments p

theorem declaration_imports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (imports : DeclarationImports calls text state arguments) :
    procedureDeclarationBody.eval calls (DeclarationInput.locals ⟨text, state, arguments⟩) =
      procedureDeclarationAt text state arguments := by
  have rejectedSame : declarationRejected calls text state arguments (declarationParts modelCalls text state) =
      declarationRejected modelCalls text state arguments (declarationParts modelCalls text state) := by
    unfold declarationRejected
    rw [imports.newName]
    rfl
  rw [declaration_denotation, ← declaration_model_equation]
  unfold declarationEquation
  have modelParameters : modelCalls .procedureParameters = procedureParametersAt := rfl
  have modelBody : modelCalls .procedureBody = procedureBodyAt := rfl
  have modelTake : modelCalls .take = tokenAfter := rfl
  simp only [modelParameters, modelBody, modelTake, decide_eq_true_eq, Bool.or_eq_true]
  rw [declaration_parts_imports calls text state imports.toDeclarationLexical, rejectedSame]
  cases rejected : declarationRejected modelCalls text state arguments (declarationParts modelCalls text state) with
  | true => simp only [↓reduceIte]
  | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      have tail := imports.tail rejected
      rw [tail.initial, tail.parameters]
      dsimp only [tokenAfter]
      by_cases headerZero :
          (procedureParametersAt text (declarationInitial modelCalls text state (declarationParts modelCalls text state)) arguments).position = 0
      · simp only [headerZero, ↓reduceIte]
      · simp only [headerZero, ↓reduceIte]
        rw [tail.isToken headerZero]
        split
        · rfl
        · rename_i accepted
          apply tail.body headerZero (fun zero => accepted (.inl zero))
          apply Bool.of_not_eq_false
          intro none
          exact accepted (.inr (by simp only [none, Bool.not_false]))

end Silver.Compose.ProcedureDeclarationNative
