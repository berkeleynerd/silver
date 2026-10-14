module

public import Silver.ComposeEquations

@[expose] public section

/-! Concrete callees for the composed recognizer's interpretation. Keeping the
witness downstream of the existing model preserves the source-check cache. -/

namespace Silver.Compose.Expressions

def modelCalls : Calls where
  names := Names.modelCalls
  primitive := modelPrimitives
  function
    | .trivia => Cursor.triviaPosition
    | .literalEnd => Output.literalEnd
    | .literalLength => Guarded.literalLength
    | .identifier => Named.identifierEnd
    | .forbidden => Named.forbiddenName
    | .forbiddenArgument => Arguments.forbiddenName
    | .equal => Named.equalName
    | .decimal => Guarded.decimalAt
    | .tokenAt => fixedAt
    | .normalize => id
    | .allowed => fun text => text.all allowedCharacter
    | .contextAfter => Names.contextAfter
    | .operationAfter => Names.operationAfter
    | .associationAfter => Names.associationAfter
    | .callAfter => callAfter
    | .skip => skipAt
    | .nameAfter => nameAfter
    | .fixedAfter => fun text position token => fixedAfter text position (spelling token) (isWord token)
    | .takeToken => fun text position token => fixedAfter text position (spelling token) (isWord token)
    | .lookupFrom => lookupFrom
    | .lookupName => lookupName
    | .literal => literalAt
    | .workTail => workTail
    | .workBudget => withinWorkBudget
    | .value => valueAt
    | .newName => newNameAllowed
    | .addBinding => addBinding
    | .declaration => declarationAt
    | .argument => argumentAt
    | .declarations => declarationsAt
    | .readDeclarations => declarationsAt
    | .expressionStep => expressionStep
    | .fits => fits
    | .comparison => comparisonAt
    | .tail => expressionTail
    | .expression => expressionAt
    | .target => targetAt
    | .dynamic => dynamicAt
    | .assignmentValue => assignmentAt
    | .output => outputAt
    | .capacity => capacityAt
    | .step => step
    | .suffix => suffixAtIndex
    | .formMember => formAccepts
    | .member => accepts
    | .arguments => hasArguments
    | .assignment => hasAssignment

@[simp] theorem lexical_modelCalls : lexical modelCalls = modelCalls := rfl

end Silver.Compose.Expressions
