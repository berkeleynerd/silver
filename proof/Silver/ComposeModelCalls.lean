module

public import Silver.ComposeContracts
public import Silver.ComposeArrayExpressions

@[expose] public section

/-! Concrete callees for the composed recognizer's interpretation. Keeping the
witness downstream of the existing model preserves the source-check cache. -/

namespace Silver.Compose.Expressions

def modelCalls : Calls where
  names := Names.modelCalls
  primitive := modelPrimitives
  function
    | .fixedBoundsValid => fixedBoundsValid
    | .characterLiteral => characterLiteralAfter
    | .guardedAt => guardedAt
    | .indexed => indexedAt
    | .characterValue => fun text position names scalarNames arrays initials elaborating =>
        characterAt text position names scalarNames arrays initials elaborating
    | .concatenatedFirst => concatenatedFirst
    | .concatenatedLast => concatenatedLast
    | .characterDeclaration => characterDeclarationAt
    | .addBindingWithCharacter => fun state first after value mutable following characterObject =>
        addBinding state first after value mutable following characterObject
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
    | .callAfter => fun text names position operation scalarNames arrays subtypeHidden booleans =>
      callAfter text names position operation scalarNames arrays subtypeHidden booleans
    | .skip => skipAt
    | .nameAfter => nameAfter
    | .fixedAfter => fun text position token => fixedAfter text position (spelling token) (isWord token)
    | .takeToken => fun text position token => fixedAfter text position (spelling token) (isWord token)
    | .lookupFrom => lookupFrom
    | .lookupName => lookupName
    | .literal => literalAt
    | .workTail => workTail
    | .workBudget => withinWorkBudget
    | .image => fun text position names scalarNames integerHidden arrays initials elaborating =>
      imageAt text position names scalarNames integerHidden arrays initials elaborating
    | .imageMinimum => fun bounds => (LengthSummary.ofImage bounds).minimumLength
    | .imageMaximum => fun bounds => (LengthSummary.ofImage bounds).staticLength
    | .value => fun text position names scalarNames integerHidden arrays initials elaborating => valueAt text position names scalarNames integerHidden arrays initials elaborating
    | .newName => newNameAllowed
    | .addBinding => addBinding
    | .stringDeclaration => stringDeclarationAt
    | .scalarConstraint => fun text position names bounds => scalarConstraintAt text position names bounds
    | .subtypeLookup => IntegerSubtypes.lookup | .subtypeLookupModel => IntegerSubtypes.lookupFrom
    | .scalarType => scalarTypeAt | .subtypeDeclaration => subtypeDeclarationAt
    | .scalarDeclaration => scalarDeclarationAt
    | .scalarLookup => ScalarExpression.lookup
    | .scalarRead => fun text position names arrays initials elaborating => ScalarExpression.read text position names 0 0 true arrays initials elaborating
    | .booleanHidesInteger => BooleanBindings.hidesInteger
    | .booleanDeclaration => booleanDeclarationAt
    | .booleanLookup => BooleanBindings.lookup
    | .arrayLookup => ArrayBindings.lookup
    | .arrayDeclaration => arrayDeclarationAt
    | .arrayValuesModel | .arrayValues => fun text source result position length parsed bounds =>
        arrayValuesModel text source result position length parsed bounds
    | .arrayPut => putArrayValue
    | .arrayAdd => fun _text => addArrayBinding
    | .scalarAppend => fun names item => names ++ [item]
    | .scalarEmpty => Integer.Interval.isEmpty
    | .scalarLiteral => ScalarLiteral.read
    | .nameIs => fun text first after word => Named.nameIs text first after (word.toList.map Char.toNat)
    | .declaration => declarationAt
    | .argument => argumentAt
    | .declarations => declarationsAt
    | .readDeclarations => declarationsAt
    | .expressionStep => fun text names scan scalarNames integerHidden arrays initials elaborating => expressionStep text names scan scalarNames integerHidden arrays initials elaborating
    | .fits => fits
    | .comparison => comparisonAt
    | .tail => fun text names scan scalarNames integerHidden arrays initials elaborating => expressionTail text names scan scalarNames integerHidden arrays initials elaborating
    | .expression => fun text position names scalarNames integerHidden arrays initials elaborating => expressionAt text position names scalarNames integerHidden arrays initials elaborating
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
