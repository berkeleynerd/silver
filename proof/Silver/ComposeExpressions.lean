module

public import Silver.ComposeAdmission
public import Silver.NamesEquations
public import Silver.ScalarExpressionEnvironment

@[expose] public section

/-! A typed interpretation of the restricted Ada expression forms used by the
binding recognizer. Local declarations, record fields and updates have explicit
semantics; calls remain arbitrary until their actual source equations are used.
The interpreter is intentionally limited to this implementation's expressions. -/

namespace Silver.Compose.Expressions

structure Primitives where
  trivia : Source → Nat → Nat
  literal : Source → Nat → Nat
  length : Source → Nat → Nat
  identifier : Source → Nat → Nat
  forbidden : Source → Nat → Nat → Bool
  forbiddenArgument : Source → Nat → Nat → Bool
  equal : Source → Nat → Nat → Nat → Nat → Bool
  decimal : Source → Nat → Guarded.DecimalResult
  token : Source → Nat → String → Bool → Bool
  normalize : Source → Source
  allowed : Source → Bool

inductive Ty
  | number | integer | truth | source | spelling | token | form | operation
  | binding | names | state | value | result | scan | decimal
  | scalarNames | scalarBinding | scalarResult | scalarLiteral | interval | scalarConstraint
  | arrayMetadata | arrayInitials | arrayEnv
  | subtypeNames | subtypeBinding | callHiding | booleanNames
  | functionMetadata | hiddenMarks
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .integer => Int | .truth => Bool | .source => Source | .spelling => String
  | .token => ShellToken | .form => Form | .operation => Names.Operation | .binding => BindingInfo
  | .names => BindingEnvironment | .state => ParserState
  | .value => ValueResult | .result => ExpressionResult | .scan => ExpressionState
  | .decimal => Guarded.DecimalResult
  | .scalarNames => ScalarExpression.Environment | .scalarBinding => ScalarExpression.Binding
  | .scalarResult => ScalarExpression.Result | .scalarLiteral => ScalarLiteral.Result
  | .interval => Integer.Interval | .scalarConstraint => ScalarConstraintResult
  | .arrayMetadata => ArrayBindings.Metadata | .arrayInitials => ArrayBindings.Initials
  | .arrayEnv => ArrayBindings.Env
  | .subtypeNames => IntegerSubtypes.Environment | .subtypeBinding => IntegerSubtypes.Binding
  | .callHiding => IntegerSubtypes.CallHiding
  | .booleanNames => BooleanBindings.Environment
  | .functionMetadata => FunctionBindings.Metadata | .hiddenMarks => HiddenMarks
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | Ty.number => 0 | Ty.integer => 0 | Ty.truth => false | Ty.source => [] | Ty.spelling => ""
  | Ty.token => .symbol ";" | Ty.form => .direct | Ty.operation => .output | Ty.binding => {}
  | Ty.names => [] | Ty.state => invalidState | Ty.value => invalidValue
  | Ty.result => invalidExpression | Ty.scan => invalidExpressionState | Ty.decimal => ⟨0, 0⟩
  | Ty.scalarNames => [] | Ty.scalarBinding => ScalarExpression.emptyBinding
  | Ty.scalarResult => ScalarExpression.invalid | Ty.scalarLiteral => ScalarLiteral.invalid
  | Ty.interval => Integer.Interval.empty | Ty.scalarConstraint => ⟨0, Integer.Interval.empty⟩
  | Ty.arrayMetadata => [] | Ty.arrayInitials => [] | Ty.arrayEnv => {}
  | Ty.subtypeNames => {} | Ty.subtypeBinding => {} | Ty.callHiding => {} | Ty.booleanNames => []
  | Ty.functionMetadata => {} | Ty.hiddenMarks => {}
  | Ty.arrow _ b => fun _ => b.default

inductive Function
  | fixedBoundsValid
  | characterLiteral
  | guardedAt
  | indexed
  | characterValue
  | concatenatedFirst
  | concatenatedLast
  | characterDeclaration
  | addBindingWithCharacter
  | trivia
  | literalEnd
  | literalLength
  | identifier
  | forbidden
  | forbiddenArgument
  | equal
  | decimal
  | tokenAt
  | normalize
  | allowed
  | contextAfter | operationAfter | associationAfter | callAfter
  | skip
  | nameAfter
  | fixedAfter
  | takeToken
  | lookupFrom
  | lookupName
  | literal
  | workTail
  | workBudget
  | image | imageMinimum | imageMaximum
  | value
  | newName
  | functionLookup | formalHides | functionDeclaration
  | addBinding
  | declaration
  | stringDeclaration | scalarConstraint | scalarDeclaration | scalarLookup | scalarRead | scalarAppend | scalarEmpty | scalarLiteral | nameIs
  | subtypeLookup | subtypeLookupModel | scalarType | subtypeDeclaration
  | booleanHidesInteger | booleanDeclaration | booleanLookup | arrayLookup | arrayDeclaration | arrayValuesModel | arrayValues | arrayPut | arrayAdd
  | booleanInitializer | booleanArrayValuesModel | booleanArrayValues
  | argument
  | declarations
  | readDeclarations
  | expressionStep
  | fits
  | comparison
  | tail
  | expression
  | target
  | dynamic
  | assignmentValue
  | output
  | capacity
  | step
  | suffix
  | formMember
  | member
  | arguments
  | assignment
  deriving DecidableEq, Repr

def Function.name : Function → String
  | .functionLookup => "functions.lookup"
  | .formalHides => "formal_hides"
  | .functionDeclaration => "function_declaration_at"
  | .fixedBoundsValid => "fixed_bounds_valid"
  | .characterLiteral => "character_literal_after"
  | .guardedAt => "guarded_at"
  | .indexed => "indexed_at"
  | .characterValue => "character_at"
  | .concatenatedFirst => "concatenated_first"
  | .concatenatedLast => "concatenated_last"
  | .characterDeclaration => "character_declaration_at"
  | .addBindingWithCharacter => "add_binding"
  | .trivia => "trivia_end"
  | .literalEnd => "literal_end"
  | .literalLength => "literal_length"
  | .identifier => "identifier_end"
  | .forbidden => "forbidden_name"
  | .forbiddenArgument => "forbidden_argument_name"
  | .equal => "equal_name"
  | .decimal => "decimal_at"
  | .tokenAt => "token_at"
  | .normalize => "normalized"
  | .allowed => "allowed_source"
  | .contextAfter => "names.context_after"
  | .operationAfter => "names.operation_after"
  | .associationAfter => "names.association_after"
  | .callAfter => "call_after"
  | .skip => "skip_at"
  | .nameAfter => "name_after"
  | .fixedAfter => "fixed_after"
  | .takeToken => "take_token"
  | .lookupFrom => "lookup_from"
  | .lookupName => "lookup_name"
  | .literal => "literal_at"
  | .workTail => "work_tail"
  | .workBudget => "within_work_budget"
  | .image => "image_at"
  | .imageMinimum => "image_lengths.minimum_length"
  | .imageMaximum => "image_lengths.maximum_length"
  | .value => "value_at"
  | .newName => "new_name_allowed"
  | .addBinding => "add_binding"
  | .declaration => "declaration_at"
  | .stringDeclaration => "string_declaration_at"
  | .scalarConstraint => "scalar_constraint_at"
  | .subtypeLookup => "lookup_subtype" | .subtypeLookupModel => "lookup_subtype_model"
  | .scalarType => "scalar_type_at" | .subtypeDeclaration => "subtype_declaration_at"
  | .scalarDeclaration => "scalar_declaration_at"
  | .scalarLookup => "scalar_expressions.lookup"
  | .scalarRead => "scalar_expressions.read_expression"
  | .scalarAppend => "scalar_expressions.append"
  | .scalarEmpty => "scalars.is_empty"
  | .scalarLiteral => "silver_scalar_literals.read_integer"
  | .nameIs => "name_is"
  | .booleanHidesInteger => "boolean_hides_integer"
  | .booleanDeclaration => "boolean_declaration_at"
  | .booleanLookup => "lookup_boolean"
  | .arrayLookup => "array_bindings.lookup"
  | .arrayDeclaration => "array_declaration_at"
  | .booleanInitializer => "boolean_initializer_model"
  | .booleanArrayValuesModel => "boolean_array_values_model"
  | .booleanArrayValues => "boolean_array_values_at"
  | .arrayValuesModel => "array_values_model"
  | .arrayValues => "array_values_at"
  | .arrayPut => "put_array_value"
  | .arrayAdd => "add_array_binding"
  | .argument => "argument_at"
  | .declarations => "declarations_at"
  | .readDeclarations => "read_declarations"
  | .expressionStep => "expression_step"
  | .fits => "fits"
  | .comparison => "comparison_at"
  | .tail => "expression_tail"
  | .expression => "expression_at"
  | .target => "target_at"
  | .dynamic => "dynamic_at"
  | .assignmentValue => "assignment_at"
  | .output => "output_at"
  | .capacity => "capacity_at"
  | .step => "step"
  | .suffix => "suffix_matches"
  | .formMember => "form_member"
  | .member => "is_member"
  | .arguments => "has_arguments"
  | .assignment => "has_assignment"

@[reducible] def Function.type : Function → Ty
  | .functionLookup => .arrow .source (.arrow .functionMetadata (.arrow .number (.arrow .number .number)))
  | .formalHides => .arrow .source (.arrow .state (.arrow .number (.arrow .number .truth)))
  | .functionDeclaration => .arrow .source (.arrow .state (.arrow .truth .state))
  | .fixedBoundsValid => .arrow .number (.arrow .truth (.arrow .truth (.arrow .integer (.arrow .integer (.arrow .number .truth)))))
  | .characterLiteral => .arrow .source (.arrow .number .number)
  | .guardedAt => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .truth (.arrow .truth .truth)))))
  | .indexed => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth (.arrow .truth .value)))))))
  | .characterValue => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .value))))))
  | .concatenatedFirst => .arrow .scan (.arrow .value .interval)
  | .concatenatedLast => .arrow .scan (.arrow .value .interval)
  | .characterDeclaration => .arrow .source (.arrow .state (.arrow .truth .state))
  | .addBindingWithCharacter => .arrow .state (.arrow .number (.arrow .number (.arrow .value (.arrow .truth (.arrow .number (.arrow .truth .state))))))
  | .trivia => .arrow .source (.arrow .number (.number))
  | .literalEnd => .arrow .source (.arrow .number (.number))
  | .literalLength => .arrow .source (.arrow .number (.number))
  | .identifier => .arrow .source (.arrow .number (.number))
  | .forbidden => .arrow .source (.arrow .number (.arrow .number (.truth)))
  | .forbiddenArgument => .arrow .source (.arrow .number (.arrow .number (.truth)))
  | .equal => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number (.truth)))))
  | .decimal => .arrow .source (.arrow .number (.decimal))
  | .tokenAt => .arrow .source (.arrow .number (.arrow .spelling (.arrow .truth (.truth))))
  | .normalize => .arrow .source (.source)
  | .allowed => .arrow .source (.truth)
  | .contextAfter => .arrow .source (.arrow .truth .number)
  | .operationAfter => .arrow .source (.arrow .number (.arrow .operation (.arrow .truth .number)))
  | .associationAfter => .arrow .source (.arrow .number (.arrow .truth .number))
  | .callAfter => .arrow .source (.arrow .names (.arrow .number (.arrow .operation (.arrow .scalarNames (.arrow .arrayMetadata (.arrow .truth (.arrow .booleanNames .number)))))))
  | .skip => .arrow .source (.arrow .number (.number))
  | .nameAfter => .arrow .source (.arrow .number (.number))
  | .fixedAfter => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .takeToken => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .lookupFrom => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.arrow .number (.number)))))
  | .lookupName => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.number))))
  | .literal => .arrow .source (.arrow .number (.value))
  | .workTail => .arrow .source (.arrow .number (.arrow .number .truth))
  | .workBudget => .arrow .source .truth
  | .image => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames (.arrow .truth (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .value)))))))
  | .imageMinimum | .imageMaximum => .arrow .interval .number
  | .value => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames (.arrow .truth (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .value)))))))
  | .newName => .arrow .source (.arrow .state (.arrow .number (.arrow .number (.arrow .truth (.truth)))))
  | .addBinding => .arrow .state (.arrow .number (.arrow .number (.arrow .value (.arrow .truth (.arrow .number (.state))))))
  | .declaration => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .stringDeclaration | .scalarDeclaration => .arrow .source (.arrow .state (.arrow .truth .state))
  | .scalarConstraint => .arrow .source (.arrow .number (.arrow .scalarNames (.arrow .interval .scalarConstraint)))
  | .subtypeLookup => .arrow .source (.arrow .subtypeNames (.arrow .number (.arrow .number .number)))
  | .subtypeLookupModel => .arrow .source (.arrow .subtypeNames (.arrow .number (.arrow .number (.arrow .number .number))))
  | .scalarType => .arrow .source (.arrow .state (.arrow .number .scalarConstraint))
  | .subtypeDeclaration => .arrow .source (.arrow .state (.arrow .truth .state))
  | .scalarLookup => .arrow .source (.arrow .scalarNames (.arrow .number (.arrow .number .number)))
  | .scalarRead => .arrow .source (.arrow .number (.arrow .scalarNames (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .scalarResult)))))
  | .scalarAppend => .arrow .scalarNames (.arrow .scalarBinding .scalarNames)
  | .scalarEmpty => .arrow .interval .truth
  | .scalarLiteral => .arrow .source (.arrow .number .scalarLiteral)
  | .nameIs => .arrow .source (.arrow .number (.arrow .number (.arrow .spelling .truth)))
  | .booleanHidesInteger => .arrow .source (.arrow .booleanNames .truth)
  | .booleanDeclaration => .arrow .source (.arrow .state (.arrow .truth .state))
  | .booleanLookup => .arrow .source (.arrow .booleanNames (.arrow .number (.arrow .number .number)))
  | .arrayLookup => .arrow .source (.arrow .arrayMetadata (.arrow .number (.arrow .number .number)))
  | .arrayDeclaration => .arrow .source (.arrow .state (.arrow .truth .state))
  | .arrayValuesModel | .arrayValues => .arrow .source (.arrow .state (.arrow .state
      (.arrow .number (.arrow .number (.arrow .number (.arrow .interval .state))))))
  | .booleanInitializer => .arrow .source (.arrow .state (.arrow .number (.arrow .number (.arrow .number .number))))
  | .booleanArrayValuesModel | .booleanArrayValues => .arrow .source (.arrow .state (.arrow .state
      (.arrow .number (.arrow .number (.arrow .number (.arrow .number (.arrow .number .state)))))))
  | .arrayPut => .arrow .state (.arrow .integer .state)
  | .arrayAdd => .arrow .source (.arrow .state (.arrow .number (.arrow .number
      (.arrow .interval (.arrow .number (.arrow .number (.arrow .truth (.arrow .number (.arrow .interval (.arrow .truth .state))))))))))
  | .argument => .arrow .source (.arrow .state (.state))
  | .declarations => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .readDeclarations => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .expressionStep => .arrow .source (.arrow .names (.arrow .scan (.arrow .scalarNames (.arrow .truth (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .scan)))))))
  | .fits => .arrow .result (.arrow .number .truth)
  | .comparison => .arrow .source (.arrow .state .state)
  | .tail => .arrow .source (.arrow .names (.arrow .scan (.arrow .scalarNames (.arrow .truth (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .result)))))))
  | .expression => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames (.arrow .truth (.arrow .arrayMetadata (.arrow .arrayInitials (.arrow .truth .result)))))))
  | .target => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .dynamic => .arrow .source (.arrow .state (.state))
  | .assignmentValue => .arrow .source (.arrow .state (.state))
  | .output => .arrow .source (.arrow .state (.state))
  | .capacity => .arrow .source (.arrow .state (.state))
  | .step => .arrow .source (.arrow .form (.arrow .token (.arrow .state (.state))))
  | .suffix => .arrow .source (.arrow .form (.arrow .number (.arrow .state (.truth))))
  | .formMember => .arrow .source (.arrow .form (.truth))
  | .member => .arrow .source (.truth)
  | .arguments => .arrow .source (.truth)
  | .assignment => .arrow .source (.truth)

structure Calls where
  names : Names.Calls
  primitive : Primitives
  function : (symbol : Function) → symbol.type.meaning

/-- Lexical symbols are projected from the established lexical interface.
Every recognizer helper is left arbitrary. -/
def Calls.get (calls : Calls) : (symbol : Function) → symbol.type.meaning
  | .functionLookup => calls.function .functionLookup
  | .formalHides => calls.function .formalHides
  | .functionDeclaration => calls.function .functionDeclaration
  | .fixedBoundsValid => calls.function .fixedBoundsValid
  | .characterLiteral => calls.function .characterLiteral
  | .guardedAt => calls.function .guardedAt
  | .indexed => calls.function .indexed
  | .characterValue => calls.function .characterValue
  | .concatenatedFirst => calls.function .concatenatedFirst
  | .concatenatedLast => calls.function .concatenatedLast
  | .characterDeclaration => calls.function .characterDeclaration
  | .addBindingWithCharacter => calls.function .addBindingWithCharacter
  | .trivia => calls.primitive.trivia
  | .literalEnd => calls.primitive.literal
  | .literalLength => calls.primitive.length
  | .identifier => calls.primitive.identifier
  | .forbidden => calls.primitive.forbidden
  | .forbiddenArgument => calls.primitive.forbiddenArgument
  | .equal => calls.primitive.equal
  | .decimal => calls.primitive.decimal
  | .tokenAt => calls.primitive.token
  | .normalize => calls.primitive.normalize
  | .allowed => calls.primitive.allowed
  | .contextAfter => calls.names.contextAfter
  | .operationAfter => calls.names.operationAfter
  | .associationAfter => calls.names.associationAfter
  | .callAfter => calls.function .callAfter
  | .skip => calls.function .skip
  | .nameAfter => calls.function .nameAfter
  | .fixedAfter => calls.function .fixedAfter
  | .takeToken => calls.function .takeToken
  | .lookupFrom => calls.function .lookupFrom
  | .lookupName => calls.function .lookupName
  | .literal => calls.function .literal
  | .workTail => calls.function .workTail
  | .workBudget => calls.function .workBudget
  | .image => calls.function .image
  | .imageMinimum => calls.function .imageMinimum
  | .imageMaximum => calls.function .imageMaximum
  | .value => calls.function .value
  | .newName => calls.function .newName
  | .addBinding => calls.function .addBinding
  | .declaration => calls.function .declaration
  | .stringDeclaration => calls.function .stringDeclaration
  | .scalarConstraint => calls.function .scalarConstraint
  | .subtypeLookup => calls.function .subtypeLookup | .subtypeLookupModel => calls.function .subtypeLookupModel
  | .scalarType => calls.function .scalarType | .subtypeDeclaration => calls.function .subtypeDeclaration
  | .scalarDeclaration => calls.function .scalarDeclaration
  | .scalarLookup => calls.function .scalarLookup
  | .scalarRead => calls.function .scalarRead
  | .scalarAppend => calls.function .scalarAppend
  | .scalarEmpty => calls.function .scalarEmpty
  | .scalarLiteral => calls.function .scalarLiteral
  | .nameIs => calls.function .nameIs
  | .booleanHidesInteger => calls.function .booleanHidesInteger
  | .booleanDeclaration => calls.function .booleanDeclaration
  | .booleanLookup => calls.function .booleanLookup
  | .arrayLookup => calls.function .arrayLookup
  | .arrayDeclaration => calls.function .arrayDeclaration
  | .arrayValuesModel => calls.function .arrayValuesModel
  | .arrayValues => calls.function .arrayValues
  | .booleanInitializer => calls.function .booleanInitializer
  | .booleanArrayValuesModel => calls.function .booleanArrayValuesModel
  | .booleanArrayValues => calls.function .booleanArrayValues
  | .arrayPut => calls.function .arrayPut
  | .arrayAdd => calls.function .arrayAdd
  | .argument => calls.function .argument
  | .declarations => calls.function .declarations
  | .readDeclarations => calls.function .readDeclarations
  | .expressionStep => calls.function .expressionStep
  | .fits => calls.function .fits
  | .comparison => calls.function .comparison
  | .tail => calls.function .tail
  | .expression => calls.function .expression
  | .target => calls.function .target
  | .dynamic => calls.function .dynamic
  | .assignmentValue => calls.function .assignmentValue
  | .output => calls.function .output
  | .capacity => calls.function .capacity
  | .step => calls.function .step
  | .suffix => calls.function .suffix
  | .formMember => calls.function .formMember
  | .member => calls.function .member
  | .arguments => calls.function .arguments
  | .assignment => calls.function .assignment

inductive Field : Ty → Ty → Type
  | stateFunctions : Field .state .functionMetadata
  | statePure : Field .state .truth
  | stateAssignedInFunctions : Field .state .truth
  | stateHiding : Field .state .hiddenMarks
  | stateFirstParameter : Field .state .number
  | hiddenInteger : Field .hiddenMarks .truth
  | hiddenBoolean : Field .hiddenMarks .truth
  | hiddenCharacter : Field .hiddenMarks .truth
  | hiddenTrue : Field .hiddenMarks .truth
  | hiddenFalse : Field .hiddenMarks .truth
  | bindingCharacter : Field .binding .truth
  | bindingFirstIndex : Field .binding .integer
  | bindingLastIndex : Field .binding .integer
  | valueOperands : Field .value .number
  | valueFirstIndex : Field .value .interval
  | valueLastIndex : Field .value .interval
  | resultFirstIndex : Field .result .interval
  | resultLastIndex : Field .result .interval
  | scanFirstIndex : Field .scan .interval
  | scanLastIndex : Field .scan .interval
  | scalarOperands : Field .scalarResult .number
  | scanEmpty : Field .scan .truth
  | scanMinimum : Field .scan .number
  | resultEmpty : Field .result .truth
  | resultMinimum : Field .result .number
  | valueEmpty : Field .value .truth
  | valueNonliteral : Field .value .truth
  | valueMinimum : Field .value .number
  | bindingFirst : Field .binding .number
  | bindingAfter : Field .binding .number
  | bindingValueFirst : Field .binding .number
  | bindingLength : Field .binding .number
  | bindingDynamic : Field .binding .truth
  | bindingMutable : Field .binding .truth
  | statePosition : Field .state .number
  | stateNames : Field .state .names
  | stateScalarNames : Field .state .scalarNames
  | stateArrayNames : Field .state .arrayEnv
  | stateBooleanNames : Field .state .booleanNames
  | subtypeTrueHidden : Field .subtypeNames .truth | subtypeFalseHidden : Field .subtypeNames .truth
  | stateSubtypeNames : Field .state .subtypeNames
  | subtypeFirst : Field .subtypeBinding .number | subtypeAfter : Field .subtypeBinding .number
  | subtypeBounds : Field .subtypeBinding .interval | subtypeHiding : Field .subtypeNames .callHiding
  | arrayNames : Field .arrayEnv .arrayMetadata
  | arrayValues : Field .arrayEnv .arrayInitials
  | arrayUsed : Field .arrayEnv .number
  | constraintAfter : Field .scalarConstraint .number
  | constraintBounds : Field .scalarConstraint .interval
  | intervalLower : Field .interval .integer
  | intervalUpper : Field .interval .integer
  | scalarAfter : Field .scalarResult .number
  | scalarBounds : Field .scalarResult .interval
  | scalarStatic : Field .scalarResult .truth
  | scalarLiteralAfter : Field .scalarLiteral .number
  | stateDynamicFirst : Field .state .number
  | stateDynamicAfter : Field .state .number
  | stateTarget : Field .state .number
  | stateCapacity : Field .state .number
  | valueAfter : Field .value .number
  | valueFirst : Field .value .number
  | valueLength : Field .value .number
  | valueDynamic : Field .value .truth
  | valueReference : Field .value .number
  | resultAfter : Field .result .number
  | resultLength : Field .result .number
  | resultDynamic : Field .result .number
  | resultNamed : Field .result .truth
  | scanPosition : Field .scan .number
  | scanLength : Field .scan .number
  | scanDynamic : Field .scan .number
  | scanOperands : Field .scan .number
  | scanDepth : Field .scan .number
  | scanNamed : Field .scan .truth
  | scanNeed : Field .scan .truth
  | scanComplete : Field .scan .truth
  | decimalAfter : Field .decimal .number
  | decimalValue : Field .decimal .number

def Field.name : Field a b → String
  | .stateFunctions => "functions" | .statePure => "pure"
  | .stateAssignedInFunctions => "assigned_in_functions" | .stateHiding => "hiding"
  | .stateFirstParameter => "first_parameter"
  | .hiddenInteger => "integer_hidden" | .hiddenBoolean => "boolean_hidden"
  | .hiddenCharacter => "character_hidden" | .hiddenTrue => "true_hidden" | .hiddenFalse => "false_hidden"
  | .bindingCharacter => "is_character"
  | .bindingFirstIndex => "first_index"
  | .bindingLastIndex => "last_index"
  | .valueOperands => "operands"
  | .valueFirstIndex => "first_index"
  | .valueLastIndex => "last_index"
  | .resultFirstIndex => "first_index"
  | .resultLastIndex => "last_index"
  | .scanFirstIndex => "first_index"
  | .scanLastIndex => "last_index"
  | .scalarOperands => "operands"
  | .scanEmpty => "empty_value"
  | .scanMinimum => "minimum_length"
  | .resultEmpty => "empty_value"
  | .resultMinimum => "minimum_length"
  | .valueEmpty => "empty_value"
  | .valueNonliteral => "nonliteral_seen"
  | .valueMinimum => "minimum_length"
  | .bindingFirst => "first"
  | .bindingAfter => "after"
  | .bindingValueFirst => "value_first"
  | .bindingLength => "static_length"
  | .bindingDynamic => "dynamic"
  | .bindingMutable => "mutable"
  | .statePosition => "position"
  | .stateNames => "names"
  | .stateScalarNames => "scalar_names"
  | .stateBooleanNames => "boolean_names"
  | .subtypeTrueHidden => "true_hidden" | .subtypeFalseHidden => "false_hidden"
  | .stateSubtypeNames => "subtype_names" | .subtypeFirst => "first" | .subtypeAfter => "after"
  | .subtypeBounds => "bounds" | .subtypeHiding => "hidden_calls"
  | .stateArrayNames => "array_names" | .arrayNames => "names" | .arrayValues => "values"
  | .arrayUsed => "used"
  | .constraintAfter => "after" | .constraintBounds => "bounds"
  | .intervalLower => "lower" | .intervalUpper => "upper"
  | .scalarAfter => "after" | .scalarBounds => "bounds" | .scalarStatic => "static"
  | .scalarLiteralAfter => "after"
  | .stateDynamicFirst => "dynamic_first"
  | .stateDynamicAfter => "dynamic_after"
  | .stateTarget => "target"
  | .stateCapacity => "capacity"
  | .valueAfter => "after"
  | .valueFirst => "value_first"
  | .valueLength => "static_length"
  | .valueDynamic => "dynamic_seen"
  | .valueReference => "reference"
  | .resultAfter => "after"
  | .resultLength => "static_length"
  | .resultDynamic => "dynamic_count"
  | .resultNamed => "named_seen"
  | .scanPosition => "position"
  | .scanLength => "static_length"
  | .scanDynamic => "dynamic_count"
  | .scanOperands => "operands"
  | .scanDepth => "depth"
  | .scanNamed => "named_seen"
  | .scanNeed => "need_operand"
  | .scanComplete => "complete"
  | .decimalAfter => "after"
  | .decimalValue => "value"

def Field.get : Field a b → a.meaning → b.meaning
  | .stateFunctions, state => state.functions | .statePure, state => state.pure
  | .stateAssignedInFunctions, state => state.assignedInFunctions
  | .stateHiding, state => state.hiding | .stateFirstParameter, state => state.firstParameter
  | .hiddenInteger, marks => marks.integerHidden | .hiddenBoolean, marks => marks.booleanHidden
  | .hiddenCharacter, marks => marks.characterHidden | .hiddenTrue, marks => marks.trueHidden
  | .hiddenFalse, marks => marks.falseHidden
  | .bindingCharacter, value => value.isCharacter
  | .bindingFirstIndex, value => value.firstIndex
  | .bindingLastIndex, value => value.lastIndex
  | .valueOperands, value => value.operands
  | .valueFirstIndex, value => value.firstIndex
  | .valueLastIndex, value => value.lastIndex
  | .resultFirstIndex, value => value.firstIndex
  | .resultLastIndex, value => value.lastIndex
  | .scanFirstIndex, value => value.firstIndex
  | .scanLastIndex, value => value.lastIndex
  | .scalarOperands, value => value.operands
  | .scanEmpty, value => value.emptyValue
  | .scanMinimum, value => value.minimumLength
  | .resultEmpty, value => value.emptyValue
  | .resultMinimum, value => value.minimumLength
  | .valueEmpty, value => value.emptyValue
  | .valueNonliteral, value => value.nonliteralSeen
  | .valueMinimum, value => value.minimumLength
  | .bindingFirst, value => value.first
  | .bindingAfter, value => value.after
  | .bindingValueFirst, value => value.valueFirst
  | .bindingLength, value => value.staticLength
  | .bindingDynamic, value => value.dynamic
  | .bindingMutable, value => value.mutable
  | .statePosition, value => value.position
  | .stateNames, value => value.names
  | .stateScalarNames, value => value.scalarNames
  | .stateArrayNames, value => value.arrayNames
  | .stateBooleanNames, value => value.booleanNames
  | .subtypeTrueHidden, value => value.trueHidden | .subtypeFalseHidden, value => value.falseHidden
  | .stateSubtypeNames, value => value.subtypeNames | .subtypeFirst, value => value.first
  | .subtypeAfter, value => value.after | .subtypeBounds, value => value.bounds
  | .subtypeHiding, value => value.hiddenCalls
  | .arrayNames, value => value.names | .arrayValues, value => value.values
  | .arrayUsed, value => value.used
  | .constraintAfter, value => value.after | .constraintBounds, value => value.bounds
  | .intervalLower, value => value.lower | .intervalUpper, value => value.upper
  | .scalarAfter, value => value.after | .scalarBounds, value => value.bounds
  | .scalarStatic, value => value.isStatic | .scalarLiteralAfter, value => value.after
  | .stateDynamicFirst, value => value.dynamicFirst
  | .stateDynamicAfter, value => value.dynamicAfter
  | .stateTarget, value => value.target
  | .stateCapacity, value => value.capacity
  | .valueAfter, value => value.after
  | .valueFirst, value => value.valueFirst
  | .valueLength, value => value.staticLength
  | .valueDynamic, value => value.dynamicSeen
  | .valueReference, value => value.reference
  | .resultAfter, value => value.after
  | .resultLength, value => value.staticLength
  | .resultDynamic, value => value.dynamicCount
  | .resultNamed, value => value.namedSeen
  | .scanPosition, value => value.position
  | .scanLength, value => value.staticLength
  | .scanDynamic, value => value.dynamicCount
  | .scanOperands, value => value.operands
  | .scanDepth, value => value.depth
  | .scanNamed, value => value.namedSeen
  | .scanNeed, value => value.needOperand
  | .scanComplete, value => value.complete
  | .decimalAfter, value => value.after
  | .decimalValue, value => value.value

inductive Expr : Ty → Type
  | nativeBinding : Expr .number → Expr .number → Expr .number → Expr .number → Expr .truth → Expr .truth → Expr .truth → Expr .integer → Expr .integer → Expr .binding
  | nativeValue : Expr .number → Expr .number → Expr .number → Expr .number → Expr .truth → Expr .truth → Expr .truth → Expr .number → Expr .number → Expr .interval → Expr .interval → Expr .value
  | nativeResult : Expr .number → Expr .number → Expr .number → Expr .number → Expr .truth → Expr .truth → Expr .interval → Expr .interval → Expr .result
  | nativeScan : Expr .number → Expr .number → Expr .number → Expr .number → Expr .number → Expr .number → Expr .truth → Expr .truth → Expr .truth → Expr .truth → Expr .interval → Expr .interval → Expr .scan
  | nativeScanAtom : Expr .scan → Expr .number → Expr .number → Expr .number → Expr .number → Expr .number → Expr .interval → Expr .interval → Expr .truth → Expr .truth → Expr .scan
  | valueAfter : Expr .value → Expr .number → Expr .value
  | integerMul : Expr .integer → Expr .integer → Expr .integer
  | integerEq : Expr .integer → Expr .integer → Expr .truth
  | wideMaximum : Expr .integer → Expr .integer → Expr .integer
  | valueNumber : Expr .number → Expr .integer
  | valueInteger : Expr .integer → Expr .integer
  | capacityInteger : Expr .integer → Expr .number
  | singleton : Expr .integer → Expr .interval
  | joinInterval : Expr .interval → Expr .interval → Expr .interval
  | minimumInteger : Expr .integer
  | maximumInteger : Expr .integer
  /-- Implicit Integer interpretation of the native Max_Source_Length constant. -/
  | maximumLength : Expr .integer
  | lexTrivia : Expr .source → Expr .number → Expr .number
  | lexLiteralEnd : Expr .source → Expr .number → Expr .number
  | lexLiteralLength : Expr .source → Expr .number → Expr .number
  | lexIdentifier : Expr .source → Expr .number → Expr .number
  | lexForbidden : Expr .source → Expr .number → Expr .number → Expr .truth
  | lexForbiddenArgument : Expr .source → Expr .number → Expr .number → Expr .truth
  | lexEqual : Expr .source → Expr .number → Expr .number → Expr .number → Expr .number → Expr .truth
  | lexDecimal : Expr .source → Expr .number → Expr .decimal
  | lexTokenAt : Expr .source → Expr .number → Expr .spelling → Expr .truth → Expr .truth
  | lexNormalize : Expr .source → Expr .source
  | lexAllowed : Expr .source → Expr .truth
  | operation (value : Names.Operation) : Expr .operation
  | number (n : Nat) : Expr .number
  | character (n : Nat) : Expr .number
  | truth (b : Bool) : Expr .truth
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | defaultFalse : Expr (.arrow .truth ty) → Expr ty
  | defaultFull : Expr (.arrow .interval .scalarConstraint) → Expr .scalarConstraint
  | subtypeCount : Expr .subtypeNames → Expr .number
  | subtypeItem : Expr .subtypeNames → Expr .number → Expr .subtypeBinding
  | hiddenFlag : Expr .callHiding → Expr .operation → Expr .truth
  | operationName : Expr .operation → Expr .spelling
  | forOperations (name : String) : Expr .truth → Expr .callHiding
  | subtypeAppend : Expr .subtypeNames → Expr .number → Expr .number → Expr .interval → Expr .truth → Expr .truth → Expr .callHiding → Expr .subtypeNames
  | stateSubtype : Expr .state → Expr .number → Expr .subtypeNames → Expr .state
  | maxSubtypeBindings : Expr .number
  | scalarReadDefault : Expr .source → Expr .number → Expr .scalarNames → Expr .scalarResult
  | scalarReadArrays : Expr .source → Expr .number → Expr .scalarNames →
      Expr .arrayMetadata → Expr .arrayInitials → Expr .truth → Expr .scalarResult
  | expressionArrays : Expr .source → Expr .number → Expr .names → Expr .scalarNames →
      Expr .arrayMetadata → Expr .arrayInitials → Expr .truth → Expr .result
  | field : Field a b → Expr a → Expr b
  | count : Expr .names → Expr .number
  | scalarCount : Expr .scalarNames → Expr .number
  | word (value : String) : Expr .spelling
  | integerTypeWord : Expr .spelling
  | booleanTypeWord : Expr .spelling
  | characterTypeWord : Expr .spelling
  | operatorByte : Expr .number → Expr .truth
  | arrayCount : Expr .arrayMetadata → Expr .number
  | maxArrayBindings : Expr .number
  | maxArrayElements : Expr .number
  | invalidScalar : Expr .scalarResult
  | integerNumber (n : Nat) : Expr .integer
  | wideInteger : Expr .integer → Expr .integer
  | wideNumber : Expr .number → Expr .integer
  | elementCount : Expr .integer → Expr .number
  | integerSub : Expr .integer → Expr .integer → Expr .integer
  | integerAdd : Expr .integer → Expr .integer → Expr .integer
  | integerGt : Expr .integer → Expr .integer → Expr .truth
  | integerGe : Expr .integer → Expr .integer → Expr .truth
  | arrayPut : Expr .arrayInitials → Expr .number → Expr .integer → Expr .arrayInitials
  | arrayUsedValues : Expr .arrayEnv → Expr .number → Expr .arrayInitials → Expr .arrayEnv
  | arrayNamesOnly : Expr .arrayEnv → Expr .arrayMetadata → Expr .arrayEnv
  | stateArray : Expr .state → Expr .arrayEnv → Expr .state
  | statePositionArray : Expr .state → Expr .number → Expr .arrayEnv → Expr .state
  | arrayAppend : Expr .arrayMetadata → Expr .number → Expr .number → Expr .interval →
      Expr .number → Expr .number → Expr .truth → Expr .interval → Expr .truth → Expr .arrayMetadata
  | maxScalarBindings : Expr .number
  | fullInterval : Expr .interval
  | emptyInterval : Expr .interval
  | interval : Expr .integer → Expr .integer → Expr .interval
  | integerNe : Expr .integer → Expr .integer → Expr .truth
  | integerLe : Expr .integer → Expr .integer → Expr .truth
  | integerLt : Expr .integer → Expr .integer → Expr .truth
  | constraint : Expr .number → Expr .interval → Expr .scalarConstraint
  | scalarBinding : Expr .number → Expr .number → Expr .interval → Expr .truth → Expr .interval → Expr .truth → Expr .scalarBinding
  | stateScalar : Expr .state → Expr .number → Expr .scalarNames → Expr .state
  | item : Expr .names → Expr .number → Expr .binding
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | mul : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | boolNe : Expr .truth → Expr .truth → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | ge : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | range : Expr .number → Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name typeName : String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | byteAt : Expr .source → Expr .number → Expr .number
  | sourceLast : Expr .source → Expr .number
  | sourceLength : Expr .source → Expr .number
  | characterVal : Expr .number → Expr .number
  | maxLength : Expr .number
  | maxBindings : Expr .number
  | maxOperands : Expr .number
  | maxConcatenations : Expr .number
  | token (token : ShellToken) : Expr .token
  | tokenEq : Expr .token → Expr .token → Expr .truth
  | tokenSpelling : Expr .token → Expr .spelling
  | spellingLength : Expr .spelling → Expr .number
  | wordToken : Expr .token → Expr .truth
  | hasArguments : Expr .form → Expr .truth
  | tokensLast : Expr .form → Expr .number
  | tokenIndex : Expr .form → Expr .number → Expr .token
  | initial : Expr .state
  | invalid : Expr .state
  | invalidValue : Expr .value
  | invalidResult : Expr .result
  | invalidScan : Expr .scan
  | binding : Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .binding
  | value : Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .truth → Expr .number → Expr .value
  | result : Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .result
  | scan : Expr .number → Expr .number → Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .truth → Expr .truth → Expr .scan
  | scanDepth : Expr .scan → Expr .number → Expr .number → Expr .scan
  | scanAtom : Expr .scan → Expr .number → Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .scan
  | scanNeed : Expr .scan → Expr .number → Expr .scan
  | scanComplete : Expr .scan → Expr .scan
  | statePosition : Expr .state → Expr .number → Expr .state
  | stateTarget : Expr .state → Expr .number → Expr .number → Expr .state
  | stateCapacity : Expr .state → Expr .number → Expr .number → Expr .state
  | stateDynamic : Expr .state → Expr .number → Expr .number → Expr .state
  | stateBinding : Expr .state → Expr .number → Expr .binding → Expr .state
  | someForm : Expr .source → Expr .truth
  | firstForm (arguments : Bool) : Expr .source → Expr .truth

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def call (name : String) (arguments : List (List String)) : List String :=
  [name, "("] ++ List.flatten (List.intersperse [","] arguments) ++ [")"]

def formName : Form → String
  | .direct => "direct_form" | .assignment => "assignment_form"
  | .argument => "argument_form" | .guardedArgument => "guarded_argument_form"
  | .branching => "branching_form" | .guardedBranching => "guarded_branching_form"
  | .result => "result_form" | .guardedResult => "guarded_result_form"

def tokenName : ShellToken → String
  | .contextClauses => "context_clauses"
  | .declarations => "declarations" | .argumentDeclaration => "argument_declaration"
  | .assignmentTarget => "assignment_target" | .targetReference => "target_reference"
  | .dynamicReference => "dynamic_reference" | .assignmentValue => "assignment_value"
  | .outputExpression => "output_expression" | .comparisonExpression => "comparison_expression" | .literal => "string_literal" | .capacity => "capacity_literal"
  | .fixed spelling _ => match spelling with
    | "with" => "with_keyword" | "silver_io" => "io_name" | "procedure" => "procedure_keyword"
    | "main" => "main_name" | "is" => "is_keyword" | "pragma" => "pragma_keyword"
    | "spark_mode" => "spark_mode_name" | "on" => "on_name" | "begin" => "begin_keyword"
    | "put_line" => "put_line_name" | "end" => "end_keyword" | "(" => "left_parenthesis"
    | ")" => "right_parenthesis" | ";" => "semicolon" | "." => "dot" | ":" => "colon"
    | "constant" => "constant_keyword" | "string" => "string_name" | ":=" => "assignment"
    | "silver_arguments" => "arguments_name" | "first_or_default" => "first_or_default_name"
    | "if" => "if_keyword" | "input_is_valid" => "input_is_valid_name" | "then" => "then_keyword"
    | "else" => "else_keyword" | "elsif" => "elsif_keyword" | "reject" => "reject_name" | "&" => "ampersand"
    | "and" => "and_keyword" | "or" => "or_keyword" | "not" => "not_keyword"
    | "function" => "function_keyword" | "return" => "return_keyword"
    | "character" => "character_name"
    | "boolean" => "boolean_name" | "true" => "true_name" | "false" => "false_name" | "xor" => "xor_keyword"
    | "/=" => "not_equal" | "<" => "less" | ">" => "greater" | ">=" => "greater_equal" | "'" => "apostrophe" | "length" => "length_name"
    | "<=" => "less_equal" | "null" => "null_keyword" | "integer" => "integer_name"
    | "for" => "for_keyword" | "in" => "in_keyword" | "reverse" => "reverse_keyword"
    | "array" => "array_keyword" | "of" => "of_keyword" | "," => "comma" | "=>" => "arrow"
    | "subtype" => "subtype_keyword" | "range" => "range_keyword" | "loop" => "loop_keyword" | ".." => "range_delimiter" | _ => "equal"

def spelling : ShellToken → String
  | .fixed word _ => word
  | .literal => "\"" | .capacity => "0" | _ => "_"
def isWord : ShellToken → Bool | .fixed _ word => word | _ => false

def aggregate (fields : List (String × List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","]
    (fields.map fun (field,value) => [field,"=>"] ++ value)) ++ [")"]
def updated (base : List String) (fields : List (String × List String)) : List String :=
  ["("] ++ base ++ ["with", "delta"] ++
    List.flatten (List.intersperse [","] (fields.map fun (field,value) => [field,"=>"] ++ value)) ++ [")"]

/-- Application uses a token-list spine so nested typed applications render as
one ordinary Ada call, without changing the meaning of argument evaluation. -/
def Expr.render : Expr ty → List String
  | .nativeBinding a b c d e f isCharacter first last => aggregate [("first",a.render),("after",b.render),("value_first",c.render), ("static_length",d.render),("dynamic",e.render),("mutable",f.render), ("is_character",isCharacter.render),("first_index",first.render),("last_index",last.render)]
  | .nativeValue a b m c d n e r operands first last => aggregate [("after",a.render),("value_first",b.render), ("minimum_length",m.render),("static_length",c.render),("dynamic_seen",d.render), ("nonliteral_seen",n.render),("empty_value",e.render),("reference",r.render), ("operands",operands.render),("first_index",first.render),("last_index",last.render)]
  | .nativeResult a m b c d e first last => aggregate [("after",a.render),("minimum_length",m.render), ("static_length",b.render),("dynamic_count",c.render),("named_seen",d.render),("empty_value",e.render), ("first_index",first.render),("last_index",last.render)]
  | .nativeScan p m l d o depth named need complete empty first last => aggregate [("position",p.render), ("minimum_length",m.render),("static_length",l.render),("dynamic_count",d.render),("operands",o.render), ("depth",depth.render),("named_seen",named.render),("need_operand",need.render), ("complete",complete.render),("empty_value",empty.render),("first_index",first.render),("last_index",last.render)]
  | .nativeScanAtom s p m l d o first last n e => updated s.render [("position",p.render),("minimum_length",m.render), ("static_length",l.render),("dynamic_count",d.render),("operands",o.render), ("first_index",first.render),("last_index",last.render), ("named_seen",n.render),("empty_value",e.render),("need_operand",["false"])]
  | .valueAfter localValue after => updated localValue.render [("after",after.render)]
  | .integerMul left right => left.render ++ ["*"] ++ right.render
  | .integerEq left right => left.render ++ ["="] ++ right.render
  | .wideMaximum left right => ["scalars", ".", "wide", "'", "max", "("] ++ left.render ++ [","] ++ right.render ++ [")"]
  | .valueNumber localValue => ["scalars", ".", "value", "("] ++ localValue.render ++ [")"]
  | .valueInteger localValue => ["scalars", ".", "value", "("] ++ localValue.render ++ [")"]
  | .capacityInteger localValue => ["capacity_value", "("] ++ localValue.render ++ [")"]
  | .singleton localValue => ["scalars", "."] ++ call "singleton" [localValue.render]
  | .joinInterval left right => ["scalars", "."] ++ call "join" [left.render,right.render]
  | .minimumInteger => ["scalars", ".", "minimum"]
  | .maximumInteger => ["scalars", ".", "maximum"]
  | .maximumLength => ["max_source_length"]
  | .lexTrivia a b => call "trivia_end" [a.render, b.render]
  | .lexLiteralEnd a b => call "literal_end" [a.render, b.render]
  | .lexLiteralLength a b => call "literal_length" [a.render, b.render]
  | .lexIdentifier a b => call "identifier_end" [a.render, b.render]
  | .lexForbidden a b c => call "forbidden_name" [a.render, b.render, c.render]
  | .lexForbiddenArgument a b c => call "forbidden_argument_name" [a.render, b.render, c.render]
  | .lexEqual a b c d e => call "equal_name" [a.render, b.render, c.render, d.render, e.render]
  | .lexDecimal a b => call "decimal_at" [a.render, b.render]
  | .lexTokenAt a b c d => call "token_at" [a.render, b.render, c.render, d.render]
  | .lexNormalize a => call "normalized" [a.render]
  | .lexAllowed a => call "allowed_source" [a.render]
  | .operation op => ["names", ".", match op with
      | .output => "output_call" | .partialOutput => "partial_output_call" | .argument => "argument_call" | .validity => "validity_call" | .reject => "reject_call"]
  | .number n => [toString n]
  | .character n => ["'" ++ String.singleton (Char.ofNat n) ++ "'"]
  | .truth b => [if b then "true" else "false"]
  | .variable name => [name]
  | .function .contextAfter => ["names", ".", "context_after"]
  | .function .operationAfter => ["names", ".", "operation_after"]
  | .function .associationAfter => ["names", ".", "association_after"]
  | .function .functionLookup => ["functions", ".", "lookup"]
  | .function .arrayLookup => ["array_bindings", ".", "lookup"]
  | .function .scalarLookup => ["scalar_expressions", ".", "lookup"]
  | .function .scalarRead => ["scalar_expressions", ".", "read_expression"]
  | .function .scalarAppend => ["scalar_expressions", ".", "append"]
  | .function .scalarEmpty => ["scalars", ".", "is_empty"]
  | .function .scalarLiteral => ["silver_scalar_literals", ".", "read_integer"]
  | .function .imageMinimum => ["image_lengths", ".", "minimum_length"]
  | .function .imageMaximum => ["image_lengths", ".", "maximum_length"]
  | .function symbol => [symbol.name]
  | .defaultFalse f => f.render
  | .defaultFull f => f.render
  | .subtypeCount names => names.render ++ [".", "count"]
  | .subtypeItem names index => names.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .hiddenFlag flags op => flags.render ++ ["("] ++ op.render ++ [")"]
  | .operationName op => ["(", "case"] ++ op.render ++ ["is",
      "when", "names", ".", "output_call", "=>", "\"put_line\"", ",",
      "when", "names", ".", "partial_output_call", "=>", "\"put\"", ",",
      "when", "names", ".", "argument_call", "=>", "\"first_or_default\"", ",",
      "when", "names", ".", "validity_call", "=>", "\"input_is_valid\"", ",",
      "when", "names", ".", "reject_call", "=>", "\"reject\"", ")"]
  | .forOperations name body => ["(", "for", name, "in", "names", ".", "operation_kind", "=>"] ++ body.render ++ [")"]
  | .subtypeAppend names first after bounds trueHidden falseHidden flags =>
      let count := names.render ++ [".", "count", "+", "1"]
      aggregate [("count", count), ("items", ["("] ++ names.render ++ [".", "items", "with", "delta"] ++
        count ++ ["=>", "("] ++ first.render ++ [","] ++ after.render ++ [","] ++ bounds.render ++ [")", ")"]),
        ("true_hidden", trueHidden.render), ("false_hidden", falseHidden.render), ("hidden_calls", flags.render)]
  | .stateSubtype state position names => updated state.render [("position",position.render),("subtype_names",names.render)]
  | .maxSubtypeBindings => ["max_subtype_bindings"]
  | .scalarReadDefault t p n => ["scalar_expressions", "."] ++ call "read_expression" [t.render, p.render, n.render]
  | .scalarReadArrays t p n a i e => ["scalar_expressions", "."] ++ call "read_expression"
      [t.render, p.render, n.render, ["arrays", "=>"] ++ a.render,
        ["initials", "=>"] ++ i.render, ["elaborating", "=>"] ++ e.render]
  | .expressionArrays t p n sn a i e => call "expression_at"
      [t.render, p.render, n.render, sn.render, ["arrays", "=>"] ++ a.render,
        ["initials", "=>"] ++ i.render, ["elaborating", "=>"] ++ e.render]
  | .app f x =>
      match f with
      | .app _ _ => f.render.dropLast ++ [","] ++ x.render ++ [")"]
      | _ => f.render ++ ["("] ++ x.render ++ [")"]
  | .field projection x => x.render ++ [".", projection.name]
  | .scalarCount x => x.render ++ [".", "count"]
  | .word spellingValue => ["\"" ++ spellingValue ++ "\""]
  | .integerTypeWord => ["integer_type_word"]
  | .booleanTypeWord => ["boolean_type_word"]
  | .characterTypeWord => ["character_type_word"]
  | .operatorByte x => x.render ++ ["in", "'&'", "|", "'+'", "|", "'-'", "|", "'*'", "|", "'/'"]
  | .arrayCount a => a.render ++ [".", "count"]
  | .maxArrayBindings => ["array_bindings", ".", "max_bindings"]
  | .maxArrayElements => ["array_bindings", ".", "max_elements"]
  | .invalidScalar => ["scalar_expressions", ".", "invalid"]
  | .integerNumber n => [toString n]
  | .wideInteger a => ["scalars", "."] ++ call "wide" [a.render]
  | .wideNumber a => ["scalars", "."] ++ call "wide" [a.render]
  | .elementCount a => ["array_bindings", "."] ++ call "element_count" [a.render]
  | .integerSub a b => a.render ++ ["-"] ++ b.render
  | .integerAdd a b => a.render ++ ["+"] ++ b.render
  | .integerGt a b => a.render ++ [">"] ++ b.render
  | .integerGe a b => a.render ++ [">="] ++ b.render
  | .arrayPut a b c => ["("] ++ a.render ++ ["with", "delta"] ++ b.render ++ ["=>"] ++ c.render ++ [")"]
  | .arrayUsedValues a b c => updated a.render [("used", b.render), ("values", c.render)]
  | .arrayNamesOnly a b => updated a.render [("names", b.render)]
  | .stateArray a b => updated a.render [("array_names", b.render)]
  | .statePositionArray a b c => updated a.render [("position", b.render), ("array_names", c.render)]
  | .arrayAppend names first after bounds offset length mutable componentBounds isBoolean =>
      let count := names.render ++ [".", "count", "+", "1"]
      let item := ["("] ++ first.render ++ [","] ++ after.render ++ [","] ++ bounds.render ++
        [","] ++ offset.render ++ [","] ++ length.render ++ [","] ++ mutable.render ++ [","] ++ componentBounds.render ++ [","] ++ isBoolean.render ++ [")"]
      aggregate [("count", count), ("items", ["("] ++ names.render ++ [".", "items", "with", "delta"] ++
        count ++ ["=>"] ++ item ++ [")"])]
  | .maxScalarBindings => ["scalar_expressions", ".", "max_bindings"]
  | .fullInterval => ["scalars", ".", "full"]
  | .emptyInterval => ["scalars", ".", "empty"]
  | .interval a b => ["("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .integerNe a b => a.render ++ ["/="] ++ b.render
  | .integerLe a b => a.render ++ ["<="] ++ b.render
  | .integerLt a b => a.render ++ ["<"] ++ b.render
  | .constraint a b => ["("] ++ a.render ++ [","] ++ b.render ++ [")"]
  | .scalarBinding a b c d e f => ["("] ++ a.render ++ [","] ++ b.render ++ [","] ++ c.render ++ [","] ++ d.render ++ [","] ++ e.render ++ [","] ++ f.render ++ [")"]
  | .stateScalar state position names => updated state.render [("position",position.render),("scalar_names",names.render)]
  | .count x => x.render ++ [".", "count"]
  | .item x i => x.render ++ [".", "items", "("] ++ i.render ++ [")"]
  | .add x y => x.render ++ ["+"] ++ y.render
  | .sub x y => x.render ++ ["-"] ++ y.render
  | .mul x y => x.render ++ ["*"] ++ y.render
  | .eq x y => x.render ++ ["="] ++ y.render
  | .ne x y => x.render ++ ["/="] ++ y.render
  | .boolNe x y => x.render ++ ["/="] ++ y.render
  | .lt x y => x.render ++ ["<"] ++ y.render
  | .ge x y => x.render ++ [">="] ++ y.render
  | .le x y => x.render ++ ["<="] ++ y.render
  | .gt x y => x.render ++ [">"] ++ y.render
  | .range x a b => x.render ++ ["in"] ++ a.render ++ [".."] ++ b.render
  | .andThen x y => x.render ++ ["and", "then"] ++ y.render
  | .orElse x y => x.render ++ ["or", "else"] ++ y.render
  | .not x => ["not"] ++ x.render
  | .group x => ["("] ++ x.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .local name typeName localValue rest => [name, ":", "constant"] ++ (if typeName == "array_bindings.element_count" then ["array_bindings", ".", "element_count"]
      else if typeName == "scalar_expressions.expression_result" then ["scalar_expressions", ".", "expression_result"]
        else if typeName == "silver_scalar_literals.literal_result" then ["silver_scalar_literals", ".", "literal_result"]
        else [typeName]) ++ [":="] ++ localValue.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .byteAt text position => text.render ++ ["("] ++ position.render ++ [")"]
  | .sourceLast text => text.render ++ ["'", "last"]
  | .sourceLength text => text.render ++ ["'", "length"]
  | .characterVal localValue => ["character", "'", "val", "("] ++ localValue.render ++ [")"]
  | .maxLength => ["max_source_length"] | .maxBindings => ["max_bindings"]
  | .maxOperands => ["max_expression_operands"]
  | .maxConcatenations => ["max_concatenations"]
  | .token tok => [tokenName tok]
  | .tokenEq a b => a.render ++ ["="] ++ b.render
  | .tokenSpelling t => call "spelling" [t.render]
  | .spellingLength s => s.render ++ ["'", "length"]
  | .wordToken t => call "is_word_token" [t.render]
  | .hasArguments f => call "is_argument_form" [f.render]
  | .tokensLast f => call "tokens" [f.render] ++ ["'", "last"]
  | .tokenIndex f i => call "tokens" [f.render] ++ ["("] ++ i.render ++ [")"]
  | .initial => ["initial_state"] | .invalid => ["invalid_state"]
  | .invalidValue => ["invalid_value"] | .invalidResult => ["invalid_expression"]
  | .invalidScan => ["invalid_expression_state"]
  | .binding a b c d e f => aggregate [("first",a.render),("after",b.render),("value_first",c.render),
      ("static_length",d.render),("dynamic",e.render),("mutable",f.render)]
  | .value a b m c d n e r => aggregate [("after",a.render),("value_first",b.render),
      ("minimum_length",m.render),("static_length",c.render),("dynamic_seen",d.render),
      ("nonliteral_seen",n.render),("empty_value",e.render),("reference",r.render)]
  | .result a m b c d e => aggregate [("after",a.render),("minimum_length",m.render),
      ("static_length",b.render),("dynamic_count",c.render),("named_seen",d.render),("empty_value",e.render)]
  | .scan p m l d o depth named need complete empty => aggregate [("position",p.render),
      ("minimum_length",m.render),("static_length",l.render),("dynamic_count",d.render),("operands",o.render),
      ("depth",depth.render),("named_seen",named.render),("need_operand",need.render),
      ("complete",complete.render),("empty_value",empty.render)]
  | .scanDepth s p d => updated s.render [("position",p.render),("depth",d.render)]
  | .scanAtom s p m l d o n e => updated s.render [("position",p.render),("minimum_length",m.render),
      ("static_length",l.render),("dynamic_count",d.render),("operands",o.render),
      ("named_seen",n.render),("empty_value",e.render),("need_operand",["false"])]
  | .scanNeed s p => updated s.render [("position",p.render),("need_operand",["true"])]
  | .scanComplete s => updated s.render [("complete",["true"])]
  | .statePosition s p => updated s.render [("position",p.render)]
  | .stateTarget s p t => updated s.render [("position",p.render),("target",t.render)]
  | .stateCapacity s p c => updated s.render [("position",p.render),("capacity",c.render)]
  | .stateDynamic s a b => updated s.render [("dynamic_first",a.render),("dynamic_after",b.render)]
  | .stateBinding s p info => updated s.render [("position",p.render),("names",
      aggregate [("count", s.render ++ [".", "names", ".", "count", "+", "1"]),
        ("items", (["("] ++ s.render ++ [".","names",".","items","with","delta"] ++
          s.render ++ [".","names",".","count","+","1","=>"] ++ info.render ++ [")"]))])]
  | .someForm source => ["for","some","form","in","form_kind","=>"] ++
      call "form_member" [source.render,["form"]]
  | .firstForm arguments source => ["for","some","form","in","form_kind","=>"] ++
      call "form_member" [source.render,["form"]] ++ ["and","then"] ++
      call (if arguments then "is_argument_form" else "is_assignment_form") [["form"]] ++
      ["and","then","(","for","all","previous","in","form_kind","'","first","..","form","=>","(","if","previous","/=","form","then","not"] ++
      call "form_member" [source.render,["previous"]] ++ [")",")"]

-- The append constructor above is exactly the bounded Ada array update at
-- Count+1. The active-prefix representation discards unused fixed-array cells.
def firstFlag (text : Source) (member : Source → Form → Bool) (flag : Form → Bool) : Bool :=
  allForms.any fun form => member text form && flag form &&
    (allForms.takeWhile fun previous => previous != form).all (fun previous => !member text previous)

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .nativeBinding a b c d e f isCharacter first last => ⟨a.eval calls locals, b.eval calls locals, c.eval calls locals, d.eval calls locals, e.eval calls locals, f.eval calls locals, isCharacter.eval calls locals, first.eval calls locals, last.eval calls locals⟩
  | .nativeValue a b m c d n e r operands first last => ⟨a.eval calls locals, b.eval calls locals, m.eval calls locals, c.eval calls locals, d.eval calls locals, n.eval calls locals, e.eval calls locals, r.eval calls locals, operands.eval calls locals, first.eval calls locals, last.eval calls locals⟩
  | .nativeResult a m b c d e first last => ⟨a.eval calls locals, m.eval calls locals, b.eval calls locals, c.eval calls locals, d.eval calls locals, e.eval calls locals, first.eval calls locals, last.eval calls locals⟩
  | .nativeScan p m l d o depth named need complete empty first last => ⟨p.eval calls locals, m.eval calls locals, l.eval calls locals, d.eval calls locals, o.eval calls locals, depth.eval calls locals, named.eval calls locals, need.eval calls locals, complete.eval calls locals, empty.eval calls locals, first.eval calls locals, last.eval calls locals⟩
  | .nativeScanAtom s p m l d o first last n e => {(s.eval calls locals) with position := p.eval calls locals, minimumLength := m.eval calls locals, staticLength := l.eval calls locals, dynamicCount := d.eval calls locals, operands := o.eval calls locals, firstIndex := first.eval calls locals, lastIndex := last.eval calls locals, namedSeen := n.eval calls locals, emptyValue := e.eval calls locals, needOperand := false}
  | .valueAfter localValue after => {(localValue.eval calls locals) with after := after.eval calls locals}
  | .integerMul left right => left.eval calls locals * right.eval calls locals
  | .integerEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .wideMaximum left right => max (left.eval calls locals) (right.eval calls locals)
  | .valueNumber localValue => Int.ofNat (localValue.eval calls locals)
  | .valueInteger localValue => localValue.eval calls locals
  | .capacityInteger localValue => (localValue.eval calls locals).toNat
  | .singleton localValue => Integer.Interval.singleton (localValue.eval calls locals)
  | .joinInterval left right => (left.eval calls locals).join (right.eval calls locals)
  | .minimumInteger => Integer.minValue
  | .maximumInteger => Integer.maxValue
  | .maximumLength => maxSourceLength
  | .lexTrivia a b => calls.primitive.trivia (a.eval calls locals) (b.eval calls locals)
  | .lexLiteralEnd a b => calls.primitive.literal (a.eval calls locals) (b.eval calls locals)
  | .lexLiteralLength a b => calls.primitive.length (a.eval calls locals) (b.eval calls locals)
  | .lexIdentifier a b => calls.primitive.identifier (a.eval calls locals) (b.eval calls locals)
  | .lexForbidden a b c => calls.primitive.forbidden (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .lexForbiddenArgument a b c => calls.primitive.forbiddenArgument (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .lexEqual a b c d e => calls.primitive.equal (a.eval calls locals) (b.eval calls locals) (c.eval calls locals) (d.eval calls locals) (e.eval calls locals)
  | .lexDecimal a b => calls.primitive.decimal (a.eval calls locals) (b.eval calls locals)
  | .lexTokenAt a b c d => calls.primitive.token (a.eval calls locals) (b.eval calls locals) (c.eval calls locals) (d.eval calls locals)
  | .lexNormalize a => calls.primitive.normalize (a.eval calls locals)
  | .lexAllowed a => calls.primitive.allowed (a.eval calls locals)
  | .operation op => op
  | .number n | .character n => n | .truth b => b | .variable name => locals _ name
  | .function symbol => calls.get symbol
  | .app f x => f.eval calls locals (x.eval calls locals)
  | .defaultFalse f => f.eval calls locals false
  | .defaultFull f => f.eval calls locals Integer.Interval.full
  | .subtypeCount names => (names.eval calls locals).items.length
  | .subtypeItem names index => IntegerSubtypes.binding (names.eval calls locals) (index.eval calls locals)
  | .hiddenFlag flags op => (flags.eval calls locals).get (op.eval calls locals)
  | .operationName op => (op.eval calls locals).name
  | .forOperations name body =>
      { output := body.eval calls (locals.set .operation name .output)
        partialOutput := body.eval calls (locals.set .operation name .partialOutput)
        argument := body.eval calls (locals.set .operation name .argument)
        validity := body.eval calls (locals.set .operation name .validity)
        reject := body.eval calls (locals.set .operation name .reject) }
  | .subtypeAppend names first after bounds trueHidden falseHidden flags =>
      { items := (names.eval calls locals).items ++ [⟨first.eval calls locals, after.eval calls locals, bounds.eval calls locals⟩]
        hiddenCalls := flags.eval calls locals
        trueHidden := trueHidden.eval calls locals
        falseHidden := falseHidden.eval calls locals }
  | .stateSubtype state position names => {state.eval calls locals with position := position.eval calls locals, subtypeNames := names.eval calls locals}
  | .maxSubtypeBindings => IntegerSubtypes.maxBindings
  | .scalarReadDefault t p n => calls.function .scalarRead
      (t.eval calls locals) (p.eval calls locals) (n.eval calls locals) [] [] false
  | .scalarReadArrays t p n a i e => calls.function .scalarRead
      (t.eval calls locals) (p.eval calls locals) (n.eval calls locals)
      (a.eval calls locals) (i.eval calls locals) (e.eval calls locals)
  | .expressionArrays t p n sn a i e => calls.function .expression
      (t.eval calls locals) (p.eval calls locals) (n.eval calls locals) (sn.eval calls locals) false
      (a.eval calls locals) (i.eval calls locals) (e.eval calls locals)
  | .field projection x => projection.get (x.eval calls locals)
  | .scalarCount x => (x.eval calls locals).length
  | .word spellingValue => spellingValue
  | .integerTypeWord => "integer"
  | .booleanTypeWord => "boolean"
  | .characterTypeWord => "character"
  | .operatorByte x => decide (x.eval calls locals ∈ [38, 43, 45, 42, 47])
  | .arrayCount a => (a.eval calls locals).length
  | .maxArrayBindings => ArrayBindings.maxBindings
  | .maxArrayElements => ArrayBindings.maxElements
  | .invalidScalar => ScalarExpression.invalid
  | .integerNumber n => n
  | .wideInteger a => a.eval calls locals
  | .wideNumber a => (a.eval calls locals : Nat)
  | .elementCount a => (a.eval calls locals).toNat
  | .integerSub a b => a.eval calls locals - b.eval calls locals
  | .integerAdd a b => a.eval calls locals + b.eval calls locals
  | .integerGt a b => decide (a.eval calls locals > b.eval calls locals)
  | .integerGe a b => decide (a.eval calls locals ≥ b.eval calls locals)
  | .arrayPut a b c => ArrayBindings.putInitial (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .arrayUsedValues a b c => {a.eval calls locals with used := b.eval calls locals, values := c.eval calls locals}
  | .arrayNamesOnly a b => {a.eval calls locals with names := b.eval calls locals}
  | .stateArray a b => {a.eval calls locals with arrayNames := b.eval calls locals}
  | .statePositionArray a b c => {a.eval calls locals with position := b.eval calls locals, arrayNames := c.eval calls locals}
  | .arrayAppend a b c d e f g h i => a.eval calls locals ++
      [⟨b.eval calls locals, c.eval calls locals, d.eval calls locals, e.eval calls locals,
        f.eval calls locals, g.eval calls locals, h.eval calls locals, i.eval calls locals⟩]
  | .maxScalarBindings => ScalarExpression.maxBindings
  | .fullInterval => Integer.Interval.full
  | .emptyInterval => Integer.Interval.empty
  | .interval a b => ⟨a.eval calls locals, b.eval calls locals⟩
  | .integerNe a b => decide (a.eval calls locals ≠ b.eval calls locals)
  | .integerLe a b => decide (a.eval calls locals ≤ b.eval calls locals)
  | .integerLt a b => decide (a.eval calls locals < b.eval calls locals)
  | .constraint a b => ⟨a.eval calls locals, b.eval calls locals⟩
  | .scalarBinding a b c d e f => ⟨a.eval calls locals, b.eval calls locals, c.eval calls locals, d.eval calls locals, e.eval calls locals, f.eval calls locals⟩
  | .stateScalar state position names => {state.eval calls locals with position := position.eval calls locals, scalarNames := names.eval calls locals}
  | .count x => (x.eval calls locals).length
  | .item x i => ((x.eval calls locals).get (i.eval calls locals)).getD {}
  | .add x y => x.eval calls locals + y.eval calls locals
  | .sub x y => x.eval calls locals - y.eval calls locals
  | .mul x y => x.eval calls locals * y.eval calls locals
  | .eq x y => decide (x.eval calls locals = y.eval calls locals)
  | .ne x y => decide (x.eval calls locals ≠ y.eval calls locals)
  | .boolNe x y => x.eval calls locals != y.eval calls locals
  | .lt x y => decide (x.eval calls locals < y.eval calls locals)
  | .ge x y => decide (x.eval calls locals ≥ y.eval calls locals)
  | .le x y => decide (x.eval calls locals ≤ y.eval calls locals)
  | .gt x y => decide (x.eval calls locals > y.eval calls locals)
  | .range x a b => decide (a.eval calls locals ≤ x.eval calls locals ∧ x.eval calls locals ≤ b.eval calls locals)
  | .andThen x y => x.eval calls locals && y.eval calls locals
  | .orElse x y => x.eval calls locals || y.eval calls locals
  | .not x => !x.eval calls locals | .group x => x.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals
  | .local name _ localValue rest => rest.eval calls (locals.set _ name (localValue.eval calls locals))
  | .locals body => body.eval calls locals
  | .byteAt text position => Cursor.byteAt (text.eval calls locals) (position.eval calls locals)
  | .sourceLast text | .sourceLength text => (text.eval calls locals).length
  | .characterVal localValue => localValue.eval calls locals
  | .maxLength => maxSourceLength | .maxBindings => Compose.maxBindings | .maxOperands => maxExpressionOperands
  | .maxConcatenations => Compose.maxConcatenations
  | .token tok => tok | .tokenEq a b => a.eval calls locals == b.eval calls locals
  | .tokenSpelling t => spelling (t.eval calls locals)
  | .spellingLength s => (s.eval calls locals).toList.length
  | .wordToken t => isWord (t.eval calls locals)
  | .hasArguments f => (f.eval calls locals).hasArguments
  | .tokensLast f => (f.eval calls locals).tokens.length
  | .tokenIndex f i => (f.eval calls locals).tokens.getD (i.eval calls locals - 1) (.symbol ";")
  | .initial => initialState | .invalid => invalidState
  | .invalidValue => Compose.invalidValue | .invalidResult => invalidExpression
  | .invalidScan => invalidExpressionState
  -- These existing constructors specify their original fields; the newly
  -- introduced Character and String-index fields retain record defaults.
  -- Their expanded native aggregates require separate renderer integration.
  | .binding a b c d e f =>
      { first := a.eval calls locals, after := b.eval calls locals,
        valueFirst := c.eval calls locals, staticLength := d.eval calls locals,
        dynamic := e.eval calls locals, mutable := f.eval calls locals }
  | .value a b m c d n e r =>
      { after := a.eval calls locals, valueFirst := b.eval calls locals,
        minimumLength := m.eval calls locals, staticLength := c.eval calls locals,
        dynamicSeen := d.eval calls locals, nonliteralSeen := n.eval calls locals,
        emptyValue := e.eval calls locals, reference := r.eval calls locals }
  | .result a m b c d e =>
      { after := a.eval calls locals, minimumLength := m.eval calls locals,
        staticLength := b.eval calls locals, dynamicCount := c.eval calls locals,
        namedSeen := d.eval calls locals, emptyValue := e.eval calls locals }
  | .scan p m l d o depth named need complete empty =>
      { position := p.eval calls locals,
        minimumLength := m.eval calls locals, staticLength := l.eval calls locals,
        dynamicCount := d.eval calls locals, operands := o.eval calls locals,
        depth := depth.eval calls locals, namedSeen := named.eval calls locals,
        needOperand := need.eval calls locals, complete := complete.eval calls locals,
        emptyValue := empty.eval calls locals }
  | .scanDepth s p d => {(s.eval calls locals) with position := p.eval calls locals, depth := d.eval calls locals}
  | .scanAtom s p m l d o n e => {(s.eval calls locals) with
      position := p.eval calls locals,
      minimumLength := m.eval calls locals, staticLength := l.eval calls locals,
      dynamicCount := d.eval calls locals, operands := o.eval calls locals, namedSeen := n.eval calls locals,
      emptyValue := e.eval calls locals, needOperand := false}
  | .scanNeed s p => {(s.eval calls locals) with position := p.eval calls locals, needOperand := true}
  | .scanComplete s => {(s.eval calls locals) with complete := true}
  | .statePosition s p => {(s.eval calls locals) with position := p.eval calls locals}
  | .stateTarget s p t => {(s.eval calls locals) with position := p.eval calls locals, target := t.eval calls locals}
  | .stateCapacity s p c => {(s.eval calls locals) with position := p.eval calls locals, capacity := c.eval calls locals}
  | .stateDynamic s a b => {(s.eval calls locals) with dynamicFirst := a.eval calls locals, dynamicAfter := b.eval calls locals}
  | .stateBinding s p info =>
      {(s.eval calls locals) with position := p.eval calls locals, names := (s.eval calls locals).names ++ [info.eval calls locals]}
  | .someForm source => allForms.any (calls.function .formMember (source.eval calls locals))
  | .firstForm arguments source => firstFlag (source.eval calls locals) (calls.function .formMember)
      (if arguments then Form.hasArguments else Form.hasAssignment)

def skipBody : Expr .number :=
  (.ite (.eq (.variable "position") (.number 0)) (.number 0) (.lexTrivia (.variable "text") (.variable "position")))

def nameBody : Expr .number :=
  (.ite (.eq (.variable "position") (.number 0)) (.number 0) (.lexIdentifier (.variable "text") (.variable "position")))

def fixedBody : Expr .number :=
  (.ite (.eq (.variable "position") (.number 0)) (.number 0) (.elsif (.lexTokenAt (.variable "text") (.lexTrivia (.variable "text") (.variable "position")) (.tokenSpelling (.variable "token")) (.wordToken (.variable "token"))) (.add (.lexTrivia (.variable "text") (.variable "position")) (.spellingLength (.tokenSpelling (.variable "token")))) (.number 0)))

def lookupFromBody : Expr .number :=
  (.ite (.gt (.variable "index") (.count (.variable "names"))) (.number 0) (.elsif (.lexEqual (.variable "text") (.field .bindingFirst (.item (.variable "names") (.variable "index"))) (.field .bindingAfter (.item (.variable "names") (.variable "index"))) (.variable "first") (.variable "after")) (.variable "index") (.app (.app (.app (.app (.app (.function .lookupFrom) (.variable "text")) (.variable "names")) (.variable "first")) (.variable "after")) (.add (.variable "index") (.number 1)))))

def lookupBody : Expr .number :=
  (.ite (.orElse (.eq (.variable "first") (.number 0)) (.le (.variable "after") (.variable "first"))) (.number 0) (.app (.app (.app (.app (.app (.function .lookupFrom) (.variable "text")) (.variable "names")) (.variable "first")) (.variable "after")) (.number 1)))

def literalBody : Expr .value :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let start := Expr.add position (.number 1)
  .ite (.andThen (.andThen (.andThen (.ne position (.number 0)) (.le position (.sourceLast text)))
    (.eq (.byteAt text position) (.characterVal (.number 34))))
    (.ne (.lexLiteralEnd text start) (.number 0)))
    (.nativeValue (.lexLiteralEnd text start) start (.lexLiteralLength text start) (.lexLiteralLength text start)
      (.truth false) (.truth false) (.truth false) (.number 0) (.number 1)
      (.singleton (.integerNumber 1)) (.singleton (.valueNumber (.lexLiteralLength text start)))) .invalidValue

def workTailBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let first : Expr .number := .variable "first"
  let quoted : Expr .value := .variable "quoted"
  let afterName : Expr .number := .variable "after_name"
  let number : Expr .scalarLiteral := .variable "number"
  let remaining : Expr .number := .variable "remaining"
  let recurse (p r : Expr .number) := Expr.app (.app (.app (.function .workTail) text) p) r
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.variable "position")) <|
    .local "quoted" "value_result" (.app (.app (.function .literal) text) first) <|
    .local "after_name" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "number" "silver_scalar_literals.literal_result" (.app (.app (.function .scalarLiteral) text) first) <|
    .group <| .ite (.eq first (.number 0)) (.truth false) <|
    .elsif (.gt first (.sourceLast text)) (.truth true) <|
    .elsif (.ne (.app (.app (.function .characterLiteral) text) first) (.number 0))
      (recurse (.app (.app (.function .characterLiteral) text) first) remaining) <|
    .elsif (.eq (.byteAt text first) (.characterVal (.number 34)))
      (.andThen (.ne (.field .valueAfter quoted) (.number 0))
        (recurse (.field .valueAfter quoted) remaining)) <|
    .elsif (.ne afterName (.number 0))
      (.group <| .ite (.orElse
        (.app (.app (.app (.app (.function .nameIs) text) first) afterName) (.word "mod"))
        (.app (.app (.app (.app (.function .nameIs) text) first) afterName) (.word "rem")))
        (.andThen (.ne remaining (.number 0)) (recurse afterName (.sub remaining (.number 1))))
        (recurse afterName remaining)) <|
    .elsif (.ne (.field .scalarLiteralAfter number) (.number 0)) (recurse (.field .scalarLiteralAfter number) remaining) <|
    .elsif (.andThen (.andThen (.eq (.byteAt text first) (.character 47)) (.lt first (.sourceLast text)))
      (.eq (.byteAt text (.add first (.number 1))) (.character 61))) (recurse (.add first (.number 2)) remaining) <|
    .elsif (.operatorByte (.byteAt text first))
      (.andThen (.ne remaining (.number 0))
        (recurse (.add first (.number 1)) (.sub remaining (.number 1))))
      (recurse (.add first (.number 1)) remaining)

def workBudgetBody : Expr .truth :=
  .app (.app (.app (.function .workTail) (.variable "text")) (.number 1)) .maxConcatenations

def imageBody : Expr .value :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let names : Expr .names := .variable "names"
  let scalarNames : Expr .scalarNames := .variable "scalar_names"
  let first : Expr .number := .variable "first"
  let typeAfter : Expr .number := .variable "type_after"
  let attributeFirst : Expr .number := .variable "attribute_first"
  let attributeAfter : Expr .number := .variable "attribute_after"
  let value : Expr .scalarResult := .variable "value"
  let following : Expr .number := .variable "following"
  let take (p : Expr .number) (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) p) (.token t)
  let skip (p : Expr .number) := Expr.app (.app (.function .skip) text) p
  .locals <| .local "first" "literal_position" (skip position) <|
    .local "type_after" "literal_position" (take first (.word "integer")) <|
    .local "attribute_first" "literal_position" (skip (take typeAfter (.symbol "'"))) <|
    .local "attribute_after" "literal_position" (.app (.app (.function .nameAfter) text) attributeFirst) <|
    .local "value" "scalar_expressions.expression_result"
      (.scalarReadArrays text (take attributeAfter (.symbol "(")) scalarNames (.variable "arrays") (.variable "initials") (.variable "elaborating")) <|
    .local "following" "literal_position" (take (.field .scalarAfter value) (.symbol ")")) <|
    .group <| .ite
      (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
        (.variable "integer_hidden")
        (.eq typeAfter (.number 0)))
        (.ne (.app (.app (.app (.app (.function .lookupName) text) names) first) typeAfter) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .scalarLookup) text) scalarNames) first) typeAfter) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .arrayLookup) text) (.variable "arrays")) first) typeAfter) (.number 0)))
        (.eq attributeFirst (.number 0)))
        (.le attributeAfter attributeFirst))
        (.not <| .app (.app (.app (.app (.function .nameIs) text) attributeFirst) attributeAfter) (.word "image")))
        (.le following position))
      .invalidValue
      (.nativeValue following (.number 0)
        (.app (.function .imageMinimum) (.field .scalarBounds value))
        (.app (.function .imageMaximum) (.field .scalarBounds value))
        (.truth false) (.truth true)
        (.app (.function .scalarEmpty) (.field .scalarBounds value)) (.number 0) (.number 1)
        (.singleton (.integerNumber 1))
        (.interval (.valueNumber (.app (.function .imageMinimum) (.field .scalarBounds value)))
          (.valueNumber (.app (.function .imageMaximum) (.field .scalarBounds value)))))

def valueBody : Expr .value :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let names : Expr .names := .variable "names"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let quoted : Expr .value := .variable "quoted"
  let info := Expr.item names index
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) position) <|
    .local "quoted" "value_result" (.app (.app (.function .literal) text) first) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "index" "binding_count" (.app (.app (.app (.app (.function .lookupName) text) names) first) after) <|
    .group <| .ite (.ne (.field .valueAfter quoted) (.number 0)) quoted <|
    .elsif (.andThen (.andThen (.ne index (.number 0)) (.not (.field .bindingCharacter info)))
      (.ne (.app (.app (.app (.function .takeToken) text) after) (.token (.symbol "("))) (.number 0)))
      (.app (.app (.app (.app (.app (.app (.app (.app (.function .indexed) text) position) names)
        (.variable "scalar_names")) (.variable "arrays")) (.variable "initials")) (.variable "elaborating")) (.truth false)) <|
    .elsif (.andThen (.andThen (.ne index (.number 0)) (.not (.field .bindingCharacter info)))
      (.eq (.app (.app (.app (.app (.function .scalarLookup) text) (.variable "scalar_names")) first) after) (.number 0)))
      (.nativeValue after (.field .bindingValueFirst info) (.field .bindingLength info) (.field .bindingLength info)
        (.field .bindingDynamic info) (.truth true) (.truth false) index (.number 1)
        (.singleton (.field .bindingFirstIndex info))
        (.group <| .ite (.field .bindingDynamic info) (.interval (.integerNumber 0) .maximumLength)
          (.singleton (.field .bindingLastIndex info))))
      (.app (.app (.app (.app (.app (.app (.app (.app (.function .image) text) position) names)
        (.variable "scalar_names")) (.variable "integer_hidden")) (.variable "arrays")) (.variable "initials")) (.variable "elaborating"))

def newNameBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let existing := Expr.andThen (.andThen (.andThen (.andThen (.andThen (.andThen (.andThen (.andThen
    (.ne first (.number 0)) (.gt after first))
    (.not (.lexForbidden text first after)))
    (.group (.orElse (.not (.variable "arguments")) (.not (.lexForbiddenArgument text first after)))))
    (.eq (.app (.app (.app (.app (.function .lookupName) text) (.field .stateNames state)) first) after) (.number 0)))
    (.eq (.app (.app (.app (.app (.function .scalarLookup) text) (.field .stateScalarNames state)) first) after) (.number 0)))
    (.eq (.app (.app (.app (.app (.function .arrayLookup) text) (.field .arrayNames (.field .stateArrayNames state))) first) after) (.number 0)))
    (.eq (.app (.app (.app (.app (.function .booleanLookup) text) (.field .stateBooleanNames state)) first) after) (.number 0)))
    (.eq (.app (.app (.app (.app (.function .subtypeLookup) text) (.field .stateSubtypeNames state)) first) after) (.number 0))
  .andThen (.andThen existing
    (.not (.app (.app (.app (.app (.function .formalHides) text) state) first) after)))
    (.group (.orElse (.field .statePure state)
      (.eq (.app (.app (.app (.app (.function .functionLookup) text)
        (.field .stateFunctions state)) first) after) (.number 0))))

def addBindingBody : Expr .state :=
  .stateBinding (.variable "state") (.variable "following")
    (.nativeBinding (.variable "first") (.variable "after") (.field .valueFirst (.variable "value"))
      (.field .valueLength (.variable "value")) (.field .valueDynamic (.variable "value"))
      (.variable "mutable") (.variable "character_object")
      (.field .intervalLower (.field .valueFirstIndex (.variable "value")))
      (.field .intervalLower (.field .valueLastIndex (.variable "value"))))

def stringDeclarationBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let value : Expr .result := .variable "value"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let take (p : Expr .number) (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) p) (.token t)
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.field .statePosition state)) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "colon_after" "literal_position" (take after (.symbol ":")) <|
    .local "constant_after" "literal_position" (take (.variable "colon_after") (.word "constant")) <|
    .local "type_after" "literal_position" (take (.group <| .ite (.ne (.variable "constant_after") (.number 0))
      (.variable "constant_after") (.variable "colon_after")) (.word "string")) <|
    .local "value" "expression_result" (.app (.app (.app (.app (.app (.app (.app (.app (.function .expression) text)
      (take (.variable "type_after") (.symbol ":="))) (.field .stateNames state)) (.field .stateScalarNames state))
      (.orElse (.orElse (.group (.andThen (.andThen (.ne first (.number 0)) (.gt after first)) (.eq (take first (.word "integer")) after)))
        (.app (.app (.function .booleanHidesInteger) text) (.field .stateBooleanNames state))) (.field .hiddenInteger (.field .stateHiding state)))) (.field .arrayNames (.field .stateArrayNames state))) (.field .arrayValues (.field .stateArrayNames state))) (.truth true)) <|
    .local "following" "literal_position" (take (.field .resultAfter value) (.symbol ";")) <|
    .group <| .ite (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
      (.not <| .app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.variable "arguments"))
      (.eq (.variable "following") (.number 0)))
      (.eq (.count (.field .stateNames state)) .maxBindings))
      (.not <| .app (.app (.function .fits) value) .maxLength))
      (.field .resultEmpty value))
      (.ne (.field .resultMinimum value) (.field .resultLength value)))
      (.group <| .andThen (.eq (.field .resultDynamic value) (.number 0))
        (.group <| .orElse (.orElse (.orElse
          (.app (.function .scalarEmpty) (.field .resultFirstIndex value))
          (.app (.function .scalarEmpty) (.field .resultLastIndex value)))
          (.integerNe (.field .intervalLower (.field .resultFirstIndex value)) (.field .intervalUpper (.field .resultFirstIndex value))))
          (.integerNe (.field .intervalLower (.field .resultLastIndex value)) (.field .intervalUpper (.field .resultLastIndex value))))))
      (.not <| .app (.app (.app (.app (.app (.app (.function .fixedBoundsValid)
        (.field .resultLength value)) (.eq (.field .resultDynamic value) (.number 1))) (.truth false))
        (.field .intervalLower (.field .resultFirstIndex value)))
        (.field .intervalLower (.field .resultLastIndex value))) (.add (.count (.field .stateNames state)) (.number 1)))) .invalid
      (.app (.app (.app (.app (.app (.app (.function .addBinding) state) first) after)
        (.nativeValue (.field .resultAfter value) (.number 0) (.field .resultMinimum value) (.field .resultLength value)
          (.eq (.field .resultDynamic value) (.number 1)) (.field .resultNamed value) (.field .resultEmpty value) (.number 0) (.number 1)
          (.field .resultFirstIndex value) (.field .resultLastIndex value)))
        (.eq (.variable "constant_after") (.number 0))) (.variable "following"))

def scalarConstraintBody : Expr .scalarConstraint :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let names : Expr .scalarNames := .variable "scalar_names"
  let rangeAfter : Expr .number := .variable "range_after"
  let delimiterAfter : Expr .number := .variable "delimiter_after"
  let low : Expr .scalarResult := .variable "low"
  let high : Expr .scalarResult := .variable "high"
  let take (p : Expr .number) (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) p) (.token t)
  let read (p : Expr .number) := Expr.scalarReadDefault text p names
  let lower (v : Expr .scalarResult) := Expr.field .intervalLower (.field .scalarBounds v)
  let upper (v : Expr .scalarResult) := Expr.field .intervalUpper (.field .scalarBounds v)
  .locals <| .local "range_after" "literal_position" (take position (.word "range")) <|
    .local "low" "scalar_expressions.expression_result" (read rangeAfter) <|
    .local "delimiter_after" "literal_position" (take (.field .scalarAfter low) (.symbol "..")) <|
    .local "high" "scalar_expressions.expression_result" (read delimiterAfter) <|
    .group <| .ite (.eq rangeAfter (.number 0)) (.constraint position (.variable "base_bounds")) <|
      .elsif
        (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
          (.eq (.field .scalarAfter low) (.number 0))
          (.eq delimiterAfter (.number 0)))
          (.eq (.field .scalarAfter high) (.number 0)))
          (.not (.field .scalarStatic low))) (.not (.field .scalarStatic high)))
          (.app (.function .scalarEmpty) (.field .scalarBounds low)))
          (.app (.function .scalarEmpty) (.field .scalarBounds high)))
          (.integerNe (lower low) (upper low))) (.integerNe (lower high) (upper high)))
          (.integerLt (lower high) (lower low)))
          (.integerLt (lower low) (.field .intervalLower (.variable "base_bounds"))))
          (.integerGt (lower high) (.field .intervalUpper (.variable "base_bounds"))))
        (.constraint (.number 0) .emptyInterval)
        (.constraint (.field .scalarAfter high) (.interval (lower low) (lower high)))

def subtypeLookupModelBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let names : Expr .subtypeNames := .variable "subtypes"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let index : Expr .number := .variable "index"
  let item := Expr.subtypeItem names index
  .ite (.orElse (.orElse (.eq first (.number 0)) (.le after first)) (.eq index (.number 0))) (.number 0)
    (.elsif (.lexEqual text (.field .subtypeFirst item) (.field .subtypeAfter item) first after) index
      (.app (.app (.app (.app (.app (.function .subtypeLookupModel) text) names) first) after) (.sub index (.number 1))))

/-- Extend an existing left-associated rejection condition with the actual
function/formal visibility checks. This builds ordinary guarded trees; it does
not introduce a new permissive rendering constructor. -/
def withFunctionTypeHiding (rejected : Expr .truth) (text : Expr .source)
    (state : Expr .state) (first after : Expr .number) (allMarks : Bool := true) : Expr .truth :=
  let same (word : String) := Expr.app (.app (.app (.app (.function .nameIs) text) first) after) (.word word)
  let hidden (field : Field .hiddenMarks .truth) (word : String) :=
    Expr.group (.andThen (.field field (.field .stateHiding state)) (same word))
  let common := Expr.orElse (.orElse (.orElse rejected
    (.ne (.app (.app (.app (.app (.function .functionLookup) text)
      (.field .stateFunctions state)) first) after) (.number 0)))
    (.app (.app (.app (.app (.function .formalHides) text) state) first) after))
    (hidden .hiddenInteger "integer")
  if allMarks then .orElse (.orElse common (hidden .hiddenBoolean "boolean"))
    (hidden .hiddenCharacter "character") else common

def scalarTypeBody : Expr .scalarConstraint :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let target : Expr .number := .variable "target"
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.variable "position")) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "target" "subtype_count" (.app (.app (.app (.app (.function .subtypeLookup) text) (.field .stateSubtypeNames state)) first) after) <|
    .group <| .ite
      (withFunctionTypeHiding (.orElse (.orElse (.orElse (.orElse (.orElse (.eq first (.number 0)) (.le after first))
        (.ne (.app (.app (.app (.app (.function .lookupName) text) (.field .stateNames state)) first) after) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .scalarLookup) text) (.field .stateScalarNames state)) first) after) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .arrayLookup) text) (.field .arrayNames (.field .stateArrayNames state))) first) after) (.number 0)))
    (.ne (.app (.app (.app (.app (.function .booleanLookup) text) (.field .stateBooleanNames state)) first) after) (.number 0))) text state first after false)
      (.constraint (.number 0) .emptyInterval)
      (.elsif (.app (.app (.app (.app (.function .nameIs) text) first) after) (.word "integer")) (.constraint after .fullInterval)
        (.elsif (.ne target (.number 0)) (.constraint after (.field .subtypeBounds (.subtypeItem (.field .stateSubtypeNames state) target)))
          (.constraint (.number 0) .emptyInterval)))

def subtypeDeclarationBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let typeFirst : Expr .number := .variable "type_first"
  let typeAfter : Expr .number := .variable "type_after"
  let constraint : Expr .scalarConstraint := .variable "constraint"
  let following : Expr .number := .variable "following"
  let take (position : Expr .number) (token : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) position) (.token token)
  let subtypes := Expr.field .stateSubtypeNames state
  let flags := Expr.field .subtypeHiding subtypes
  let operation : Expr .operation := .variable "operation"
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (take (.field .statePosition state) (.word "subtype"))) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "type_first" "literal_position" (.app (.app (.function .skip) text) (take after (.word "is"))) <|
    .local "type_after" "literal_position" (take typeFirst (.word "integer")) <|
    .local "constraint" "scalar_constraint_result" (.defaultFull (.app (.app (.app (.function .scalarConstraint) text) typeAfter) (.field .stateScalarNames state))) <|
    .local "following" "literal_position" (take (.field .constraintAfter constraint) (.symbol ";")) <|
    .group <| .ite
      (withFunctionTypeHiding (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
        (.not (.app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.variable "arguments")))
        (.app (.app (.app (.app (.function .nameIs) text) first) after) (.word "integer")))
        (.eq (.subtypeCount subtypes) .maxSubtypeBindings))
        (.eq typeAfter (.number 0))) (.eq (take typeAfter (.word "range")) (.number 0)))
        (.eq (.field .constraintAfter constraint) (.number 0))) (.le following (.field .statePosition state)))
        (.app (.function .scalarEmpty) (.field .constraintBounds constraint)))
        (.ne (.app (.app (.app (.app (.function .lookupName) text) (.field .stateNames state)) typeFirst) typeAfter) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .scalarLookup) text) (.field .stateScalarNames state)) typeFirst) typeAfter) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .arrayLookup) text) (.field .arrayNames (.field .stateArrayNames state))) typeFirst) typeAfter) (.number 0)))
    (.ne (.app (.app (.app (.app (.function .booleanLookup) text) (.field .stateBooleanNames state)) typeFirst) typeAfter) (.number 0))) text state typeFirst typeAfter true)
      .invalid
      (.stateSubtype state following (.subtypeAppend subtypes first after (.field .constraintBounds constraint)
        (.orElse (.field .subtypeTrueHidden subtypes) (.app (.app (.app (.app (.function .nameIs) text) first) after) (.word "true")))
        (.orElse (.field .subtypeFalseHidden subtypes) (.app (.app (.app (.app (.function .nameIs) text) first) after) (.word "false")))
        (.forOperations "operation" (.orElse (.hiddenFlag flags operation)
          (.app (.app (.app (.app (.function .nameIs) text) first) after) (.operationName operation))))))

def scalarDeclarationBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let value : Expr .scalarResult := .variable "value"
  let constraint : Expr .scalarConstraint := .variable "constraint"
  let following : Expr .number := .variable "following"
  let take (p : Expr .number) (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) p) (.token t)
  let skip (p : Expr .number) := Expr.app (.app (.function .skip) text) p
  let hidden (f : Expr (.arrow .source (.arrow .scalarNames (.arrow .number (.arrow .number .number))))) :=
    Expr.app (.app (.app (.app f text) (.field .stateScalarNames state)) (.variable "type_first")) (.variable "type_after")
  .locals <| .local "first" "literal_position" (skip (.field .statePosition state)) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "colon_after" "literal_position" (take after (.symbol ":")) <|
    .local "constant_after" "literal_position" (take (.variable "colon_after") (.word "constant")) <|
    .local "type_first" "literal_position" (skip (.group <| .ite (.ne (.variable "constant_after") (.number 0))
      (.variable "constant_after") (.variable "colon_after"))) <|
    .local "type_mark" "scalar_constraint_result" (.app (.app (.app (.function .scalarType) text) state) (.variable "type_first")) <|
    .local "type_after" "literal_position" (.field .constraintAfter (.variable "type_mark")) <|
    .local "constraint" "scalar_constraint_result"
      (.app (.app (.app (.app (.function .scalarConstraint) text) (.variable "type_after")) (.field .stateScalarNames state)) (.field .constraintBounds (.variable "type_mark"))) <|
    .local "value" "scalar_expressions.expression_result"
      (.scalarReadArrays text (take (.field .constraintAfter constraint) (.symbol ":=")) (.field .stateScalarNames state) (.field .arrayNames (.field .stateArrayNames state)) (.field .arrayValues (.field .stateArrayNames state)) (.truth true)) <|
    .local "following" "literal_position" (take (.field .scalarAfter value) (.symbol ";")) <|
    .group <| .ite
      (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
        (.not <| .app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.variable "arguments"))
        (.eq (.variable "type_after") (.number 0)))
        (.eq (.field .constraintAfter constraint) (.number 0)))
        (.le following (.field .statePosition state)))
        (.eq (.scalarCount (.field .stateScalarNames state)) .maxScalarBindings))
        (.app (.function .scalarEmpty) (.field .scalarBounds value)))
        (.integerNe (.field .intervalLower (.field .scalarBounds value)) (.field .intervalUpper (.field .scalarBounds value))))
        (.integerLt (.field .intervalLower (.field .scalarBounds value)) (.field .intervalLower (.field .constraintBounds constraint))))
        (.integerLt (.field .intervalUpper (.field .constraintBounds constraint)) (.field .intervalUpper (.field .scalarBounds value))))
        (.app (.app (.app (.app (.function .nameIs) text) first) after) (.word "integer")))
        (.ne (.app (.app (.app (.app (.function .lookupName) text) (.field .stateNames state)) (.variable "type_first")) (.variable "type_after")) (.number 0)))
        (.ne (hidden (.function .scalarLookup)) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .arrayLookup) text) (.field .arrayNames (.field .stateArrayNames state))) (.variable "type_first")) (.variable "type_after")) (.number 0)))
      .invalid
      (.stateScalar state following (.app (.app (.function .scalarAppend) (.field .stateScalarNames state))
        (.scalarBinding first after (.field .scalarBounds value)
          (.andThen (.ne (.variable "constant_after") (.number 0)) (.field .scalarStatic value))
          (.field .constraintBounds constraint) (.eq (.variable "constant_after") (.number 0)))))

def declarationBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let scalar : Expr .state := .variable "scalar_state"
  let array : Expr .state := .variable "array_state"
  .locals <| .local "function_state" "parser_state" (.app (.app (.app (.function .functionDeclaration) text) state) arguments) <|
    .local "subtype_state" "parser_state" (.app (.app (.app (.function .subtypeDeclaration) text) state) arguments) <| .local "scalar_state" "parser_state" (.app (.app (.app (.function .scalarDeclaration) text) state) arguments) <|
    .local "array_state" "parser_state" (.app (.app (.app (.function .arrayDeclaration) text) state) arguments) <|
    .local "boolean_state" "parser_state" (.app (.app (.app (.function .booleanDeclaration) text) state) arguments) <|
    .local "character_state" "parser_state" (.app (.app (.app (.function .characterDeclaration) text) state) arguments) <|
    .group <| .ite (.ne (.field .statePosition (.variable "function_state")) (.number 0)) (.variable "function_state")
      (.elsif (.ne (.field .statePosition (.variable "subtype_state")) (.number 0)) (.variable "subtype_state")
      (.elsif (.ne (.field .statePosition scalar) (.number 0)) scalar
      (.elsif (.ne (.field .statePosition array) (.number 0)) array
      (.elsif (.ne (.field .statePosition (.variable "boolean_state")) (.number 0)) (.variable "boolean_state")
      (.elsif (.ne (.field .statePosition (.variable "character_state")) (.number 0)) (.variable "character_state")
      (.app (.app (.app (.function .stringDeclaration) text) state) arguments))))))

def callAfterBody : Expr .number :=
  let text : Expr .source := .variable "text"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.variable "position")) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .app (.app (.app (.app (.function .operationAfter) text) (.variable "position")) (.variable "operation"))
      (.orElse (.orElse (.orElse (.orElse (.ne (.app (.app (.app (.app (.function .lookupName) text) (.variable "environment")) first) after) (.number 0)) (.ne (.app (.app (.app (.app (.function .scalarLookup) text) (.variable "scalar_names")) first) after) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .arrayLookup) text) (.variable "arrays")) first) after) (.number 0)))
        (.ne (.app (.app (.app (.app (.function .booleanLookup) text) (.variable "booleans")) first) after) (.number 0))) (.variable "subtype_hidden"))

def argumentBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let fallback : Expr .value := .variable "default_value"
  let following : Expr .number := .variable "following"
  let take (position : Expr .number) (token : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) position) (.token token)
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.field .statePosition state)) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) first) <|
    .local "start" "literal_position" (take (take (take (take after (.symbol ":")) (.word "constant")) (.word "string")) (.symbol ":=")) <|
    .local "hidden" "boolean" (.andThen (.andThen (.ne first (.number 0)) (.gt after first))
      (.eq (take first (.word "first_or_default")) after)) <|
    .local "prefix" "literal_position" (.app (.app (.app (.function .associationAfter) text)
      (take (.app (.app (.app (.app (.function .operationAfter) text) (.variable "start")) (.operation .argument)) (.variable "hidden")) (.symbol "("))) (.truth true)) <|
    .local "default_value" "value_result" (.app (.app (.function .literal) text)
      (.app (.app (.function .skip) text) (.variable "prefix"))) <|
    .local "following" "literal_position" (take (take (.field .valueAfter fallback) (.symbol ")")) (.symbol ";")) <|
    .group <| .ite (.orElse (.orElse
      (.not <| .app (.app (.app (.app (.app (.function .newName) text) state) first) after) (.truth true))
      (.eq following (.number 0))) (.ne (.count (.field .stateNames state)) (.number 0))) .invalid
      (.stateDynamic (.app (.app (.app (.app (.app (.app (.function .addBinding) state) first) after)
        (.nativeValue following (.number 0) (.number 0) (.number 0) (.truth true) (.truth true) (.truth false) (.number 0) (.number 1)
          (.singleton (.integerNumber 1)) (.interval (.integerNumber 0) .maximumLength))) (.truth false)) following) first after)

def declarationsBody : Expr .state :=
  (.ite (.eq (.field .statePosition (.variable "state")) (.number 0)) (.invalid) (.elsif (.ne (.app (.app (.app (.function .takeToken) (.variable "text")) (.field .statePosition (.variable "state"))) (.token (.fixed "begin" true))) (.number 0)) (.variable "state") (.elsif (.eq (.field .statePosition (.app (.app (.app (.function .declaration) (.variable "text")) (.variable "state")) (.variable "arguments"))) (.number 0)) (.invalid) (.app (.app (.app (.function .declarations) (.variable "text")) (.app (.app (.app (.function .declaration) (.variable "text")) (.variable "state")) (.variable "arguments"))) (.variable "arguments")))))

def expressionStepBody : Expr .scan :=
  let text : Expr .source := .variable "text"
  let state : Expr .scan := .variable "state"
  let atom : Expr .value := .variable "atom"
  let take (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text)
    (.field .scanPosition state)) (.token t)
  let static : Expr .truth := .andThen
    (.andThen (.variable "elaborating") (.eq (.field .scanDynamic state) (.number 0)))
    (.not (.field .valueDynamic atom))
  let first : Expr .interval := .app (.app (.function .concatenatedFirst) state) atom
  let last : Expr .interval := .app (.app (.function .concatenatedLast) state) atom
  let boundsFailure : Expr .truth := .group <| .andThen static
    (.group <| .orElse (.app (.function .scalarEmpty) first) (.app (.function .scalarEmpty) last))
  let rejected := Expr.orElse
    (.orElse (.orElse (.orElse (.eq (.field .valueAfter atom) (.number 0))
      (.gt (.field .valueOperands atom) (.sub .maxOperands (.field .scanOperands state)))) boundsFailure)
      (.gt (.field .valueLength atom) (.sub .maxLength (.field .scanLength state))))
    (.gt (.field .valueMinimum atom) (.sub .maxLength (.field .scanMinimum state)))
  .locals <| .local "open_after" "literal_position" (take (.symbol "(")) <|
    .local "atom" "value_result" (.app (.app (.app (.app (.app (.app (.app (.app (.function .value) text)
      (.field .scanPosition state)) (.variable "names")) (.variable "scalar_names")) (.variable "integer_hidden")) (.variable "arrays")) (.variable "initials")) (.variable "elaborating")) <|
    .local "join_after" "literal_position" (take (.symbol "&")) <|
    .local "close_after" "literal_position" (take (.symbol ")")) <|
    .group <| .ite (.eq (.field .scanPosition state) (.number 0)) .invalidScan <|
    .elsif (.field .scanComplete state) state <|
    .elsif (.field .scanNeed state)
      (.group <| .ite (.ne (.variable "open_after") (.number 0))
        (.scanDepth state (.variable "open_after") (.add (.field .scanDepth state) (.number 1))) <|
        .elsif rejected .invalidScan <|
        .nativeScanAtom state (.field .valueAfter atom)
          (.add (.field .scanMinimum state) (.field .valueMinimum atom))
          (.add (.field .scanLength state) (.field .valueLength atom))
          (.add (.field .scanDynamic state) (.group <| .ite (.field .valueDynamic atom) (.number 1) (.number 0)))
          (.add (.field .scanOperands state) (.field .valueOperands atom))
          (.group <| .ite static first (.singleton (.integerNumber 1)))
          (.group <| .ite static last (.singleton (.integerNumber 0)))
          (.orElse (.field .scanNamed state) (.field .valueNonliteral atom))
          (.orElse (.field .scanEmpty state) (.field .valueEmpty atom))) <|
    .elsif (.ne (.variable "join_after") (.number 0)) (.scanNeed state (.variable "join_after")) <|
    .elsif (.andThen (.ne (.variable "close_after") (.number 0)) (.ne (.field .scanDepth state) (.number 0)))
      (.scanDepth state (.variable "close_after") (.sub (.field .scanDepth state) (.number 1))) <|
    .elsif (.eq (.field .scanDepth state) (.number 0)) (.scanComplete state) .invalidScan

def tailBody : Expr .result :=
  let state : Expr .scan := .variable "state"
  let next : Expr .scan := .variable "next"
  let result (s : Expr .scan) := Expr.nativeResult (.field .scanPosition s) (.field .scanMinimum s) (.field .scanLength s)
    (.field .scanDynamic s) (.field .scanNamed s) (.field .scanEmpty s) (.field .scanFirstIndex s) (.field .scanLastIndex s)
  .ite (.eq (.field .scanPosition state) (.number 0)) .invalidResult <|
    .elsif (.field .scanComplete state) (result state) <|
    .group <| .locals <| .local "next" "expression_state"
      (.app (.app (.app (.app (.app (.app (.app (.app (.function .expressionStep) (.variable "text")) (.variable "names")) state)
        (.variable "scalar_names")) (.variable "integer_hidden")) (.variable "arrays")) (.variable "initials")) (.variable "elaborating")) <|
    .group <| .ite (.eq (.field .scanPosition next) (.number 0)) .invalidResult <|
    .elsif (.field .scanComplete next) (result next)
      (.app (.app (.app (.app (.app (.app (.app (.app (.function .tail) (.variable "text")) (.variable "names")) next)
        (.variable "scalar_names")) (.variable "integer_hidden")) (.variable "arrays")) (.variable "initials")) (.variable "elaborating"))

def expressionBody : Expr .result :=
  (.app (.app (.app (.app (.app (.app (.app (.app (.function .tail) (.variable "text")) (.variable "names"))
    (.nativeScan (.variable "position") (.number 0) (.number 0) (.number 0) (.number 0) (.number 0)
      (.truth false) (.truth true) (.truth false) (.truth false)
      (.singleton (.integerNumber 1)) (.singleton (.integerNumber 0)))) (.variable "scalar_names")) (.variable "integer_hidden")) (.variable "arrays")) (.variable "initials")) (.variable "elaborating"))

def fitsBody : Expr .truth :=
  let value : Expr .result := .variable "value"
  .andThen (.ne (.field .resultAfter value) (.number 0))
    (.group <| .orElse (.field .resultEmpty value)
      (.le (.add (.field .resultLength value) (.mul (.field .resultDynamic value) (.variable "capacity"))) .maxLength))

def targetBody : Expr .state :=
  (.locals (.local "first" "literal_position" (.app (.app (.function .skip) (.variable "text")) (.field .statePosition (.variable "state"))) (.local "after" "literal_position" (.app (.app (.function .nameAfter) (.variable "text")) (.variable "first")) (.local "index" "binding_count" (.app (.app (.app (.app (.function .lookupName) (.variable "text")) (.field .stateNames (.variable "state"))) (.variable "first")) (.variable "after")) (.group (.ite (.orElse (.orElse (.orElse (.eq (.variable "index") (.number 0)) (.ne (.app (.app (.app (.app (.function .scalarLookup) (.variable "text")) (.field .stateScalarNames (.variable "state"))) (.variable "first")) (.variable "after")) (.number 0))) (.not (.field .bindingMutable (.item (.field .stateNames (.variable "state")) (.variable "index"))))) (.group (.andThen (.variable "same_target") (.ne (.variable "index") (.field .stateTarget (.variable "state")))))) (.invalid) (.stateTarget (.variable "state") (.variable "after") (.variable "index"))))))))

def dynamicBody : Expr .state :=
  (.locals (.local "first" "literal_position" (.app (.app (.function .skip) (.variable "text")) (.field .statePosition (.variable "state"))) (.local "after" "literal_position" (.app (.app (.function .nameAfter) (.variable "text")) (.variable "first")) (.group (.ite (.orElse (.orElse (.orElse (.eq (.variable "first") (.number 0)) (.eq (.variable "after") (.number 0))) (.eq (.field .stateDynamicFirst (.variable "state")) (.number 0))) (.not (.lexEqual (.variable "text") (.field .stateDynamicFirst (.variable "state")) (.field .stateDynamicAfter (.variable "state")) (.variable "first") (.variable "after")))) (.invalid) (.statePosition (.variable "state") (.variable "after")))))))

def assignmentBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let value : Expr .result := .variable "value"
  let target := Expr.item (.field .stateNames state) (.field .stateTarget state)
  .locals <| .local "value" "expression_result"
    (.expressionArrays text (.field .statePosition state) (.field .stateNames state) (.field .stateScalarNames state) (.field .arrayNames (.field .stateArrayNames state)) (.field .arrayValues (.field .stateArrayNames state)) (.truth true)) <|
    .group <| .ite (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
      (.not <| .app (.app (.function .fits) value) (.field .stateCapacity state))
      (.eq (.field .stateTarget state) (.number 0)))
      (.field .bindingCharacter target))
      (.field .resultEmpty value))
      (.ne (.field .resultMinimum value) (.field .resultLength value)))
      (.ne (.field .resultLength value) (.field .bindingLength target)))
      (.ne (.field .resultDynamic value) (.group <| .ite (.field .bindingDynamic target) (.number 1) (.number 0))))
      .invalid (.statePosition state (.field .resultAfter value))

def outputBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let value : Expr .result := .variable "value"
  .locals <| .local "value" "expression_result"
    (.expressionArrays (.variable "text") (.field .statePosition state) (.field .stateNames state) (.field .stateScalarNames state) (.field .arrayNames (.field .stateArrayNames state)) (.field .arrayValues (.field .stateArrayNames state)) (.truth true)) <|
    .group <| .ite (.not <| .app (.app (.function .fits) value) (.field .stateCapacity state))
      .invalid (.statePosition state (.field .resultAfter value))

def comparisonBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let text : Expr .source := .variable "text"
  let lhs : Expr .result := .variable "left"
  let rhs : Expr .result := .variable "right"
  .locals <| .local "left" "expression_result"
    (.expressionArrays text (.field .statePosition state) (.field .stateNames state) (.field .stateScalarNames state) (.field .arrayNames (.field .stateArrayNames state)) (.field .arrayValues (.field .stateArrayNames state)) (.truth true)) <|
    .local "right" "expression_result" (.expressionArrays text (.app (.app (.app (.function .takeToken) text) (.field .resultAfter lhs)) (.token (.symbol "="))) (.field .stateNames state) (.field .stateScalarNames state) (.field .arrayNames (.field .stateArrayNames state)) (.field .arrayValues (.field .stateArrayNames state)) (.truth true)) <|
    .group <| .ite (.orElse (.orElse
      (.not <| .app (.app (.function .fits) lhs) (.field .stateCapacity state))
      (.not <| .app (.app (.function .fits) rhs) (.field .stateCapacity state)))
      (.not <| .group <| .orElse (.field .resultNamed lhs) (.field .resultNamed rhs)))
      .invalid (.statePosition state (.field .resultAfter rhs))

def capacityBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let position := Expr.field .statePosition state
  let parsed := Expr.lexDecimal (.variable "text") (.lexTrivia (.variable "text") position)
  .ite (.eq position (.number 0)) .invalid
    (.elsif (.eq (.field .decimalAfter parsed) (.number 0)) .invalid
      (.stateCapacity state (.field .decimalAfter parsed) (.field .decimalValue parsed)))

def stepBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let is (t : ShellToken) := Expr.tokenEq (.variable "token") (.token t)
  let action (f : Function) (h : f.type = .arrow .source (.arrow .state .state)) : Expr .state :=
    .app (.app (h ▸ Expr.function f) text) state
  .ite (.eq (.field .statePosition state) (.number 0)) .invalid <|
    .elsif (is .contextClauses) (.statePosition state (.app (.app (.function .contextAfter) text) (.hasArguments (.variable "form")))) <|
    .elsif (is .argumentDeclaration) (action .argument rfl) <|
    .elsif (is .declarations) (.app (.app (.app (.function .readDeclarations) text) state) (.hasArguments (.variable "form"))) <|
    .elsif (is .assignmentTarget) (.app (.app (.app (.function .target) text) state) (.truth false)) <|
    .elsif (is .targetReference) (.app (.app (.app (.function .target) text) state) (.truth true)) <|
    .elsif (is .dynamicReference) (action .dynamic rfl) <|
    .elsif (is .assignmentValue) (action .assignmentValue rfl) <|
    .elsif (is .outputExpression) (action .output rfl) <|
    .elsif (is .comparisonExpression) (action .comparison rfl) <|
    .elsif (is .capacity) (action .capacity rfl) <|
    .elsif (is .literal) (.statePosition state (.field .valueAfter
      (.app (.app (.function .literal) text) (.app (.app (.function .skip) text) (.field .statePosition state)))))
      (.statePosition state (.app (.app (.app (.function .takeToken) text) (.field .statePosition state)) (.variable "token")))

def suffixBody : Expr .truth :=
  (.ite (.eq (.field .statePosition (.variable "state")) (.number 0)) (.truth false) (.elsif (.gt (.variable "next_token") (.tokensLast (.variable "form"))) (.eq (.lexTrivia (.variable "text") (.field .statePosition (.variable "state"))) (.add (.sourceLast (.variable "text")) (.number 1))) (.app (.app (.app (.app (.function .suffix) (.variable "text")) (.variable "form")) (.add (.variable "next_token") (.number 1))) (.app (.app (.app (.app (.function .step) (.variable "text")) (.variable "form")) (.tokenIndex (.variable "form") (.variable "next_token"))) (.variable "state")))))

def formBody : Expr .truth :=
  let source : Expr .source := .variable "source"
  .andThen (.andThen (.andThen
    (.range (.sourceLength source) (.number 1) .maxLength)
    (.lexAllowed (.lexNormalize source)))
    (.app (.function .workBudget) (.lexNormalize source)))
    (.app (.app (.app (.app (.function .suffix) (.lexNormalize source))
      (.variable "form")) (.number 1)) .initial)

def memberBody : Expr .truth :=
  (.someForm (.variable "source"))

def argumentsBody : Expr .truth :=
  (.firstForm true (.variable "source"))

def assignmentSelectorBody : Expr .truth :=
  (.firstForm false (.variable "source"))

def modelPrimitives : Primitives where
  trivia := Cursor.triviaPosition
  literal := Output.literalEnd
  length := Guarded.literalLength
  identifier := Named.identifierEnd
  forbidden := Named.forbiddenName
  forbiddenArgument := Arguments.forbiddenName
  equal := Named.equalName
  decimal := Guarded.decimalAt
  token := fixedAt
  normalize := id
  allowed := fun text => text.all allowedCharacter

def lexical (calls : Calls) : Calls := {calls with primitive := modelPrimitives}


def Function.isLexical : Function → Bool
  | .trivia | .literalEnd | .literalLength | .identifier | .forbidden | .forbiddenArgument | .equal | .decimal | .tokenAt | .normalize | .allowed => true
  | _ => false

/-- Names usable before a selector, index or attribute. Calls and conversions
are names; parenthesized expressions and unqualified aggregates are not.
Delta-aggregate bases that are not also selected retain their existing rules. -/
def Expr.prefix : Expr ty → Bool
  | .wideMaximum _ _ | .valueNumber _ | .valueInteger _ | .capacityInteger _ |
    .singleton _ | .joinInterval _ _ | .minimumInteger | .maximumInteger | .maximumLength |
    .lexTrivia _ _ | .lexLiteralEnd _ _ | .lexLiteralLength _ _ | .lexIdentifier _ _ |
    .lexForbidden _ _ _ | .lexForbiddenArgument _ _ _ | .lexEqual _ _ _ _ _ |
    .lexDecimal _ _ | .lexTokenAt _ _ _ _ | .lexNormalize _ | .lexAllowed _ |
    .operation _ | .variable _ | .function _ | .app _ _ | .defaultFalse _ | .defaultFull _ |
    .subtypeCount _ | .subtypeItem _ _ | .hiddenFlag _ _ | .maxSubtypeBindings |
    .scalarReadDefault _ _ _ | .scalarReadArrays _ _ _ _ _ _ | .expressionArrays _ _ _ _ _ _ _ |
    .field _ _ | .count _ | .scalarCount _ | .integerTypeWord | .booleanTypeWord | .characterTypeWord |
    .arrayCount _ | .maxArrayBindings | .maxArrayElements | .invalidScalar |
    .wideInteger _ | .wideNumber _ | .elementCount _ | .maxScalarBindings |
    .fullInterval | .emptyInterval | .item _ _ | .byteAt _ _ | .sourceLast _ | .sourceLength _ |
    .characterVal _ | .maxLength | .maxBindings | .maxOperands | .maxConcatenations | .token _ |
    .tokenSpelling _ | .spellingLength _ | .wordToken _ | .hasArguments _ | .tokensLast _ | .tokenIndex _ _ |
    .initial | .invalid | .invalidValue | .invalidResult | .invalidScan => true
  | _ => false

/-- Ada 2022 expression categories. Renderers preserve explicit grouping;
these checks prevent a flattened tree from changing precedence or association. -/
def Expr.primary : Expr ty → Bool
  | .nativeBinding _ _ _ _ _ _ _ _ _ => true
  | .nativeValue _ _ _ _ _ _ _ _ _ _ _ => true
  | .nativeResult _ _ _ _ _ _ _ _ => true
  | .nativeScan _ _ _ _ _ _ _ _ _ _ _ _ => true
  | .nativeScanAtom _ _ _ _ _ _ _ _ _ _ => true
  | .valueAfter _ _ => true
  | .wideMaximum _ _ => true
  | .valueNumber _ => true
  | .valueInteger _ => true
  | .capacityInteger _ => true
  | .singleton _ => true
  | .joinInterval _ _ => true
  | .minimumInteger => true
  | .maximumInteger | .maximumLength => true
  | .lexTrivia _ _ | .lexLiteralEnd _ _ | .lexLiteralLength _ _ | .lexIdentifier _ _
  | .lexForbidden _ _ _ | .lexForbiddenArgument _ _ _ | .lexEqual _ _ _ _ _
  | .lexDecimal _ _ | .lexTokenAt _ _ _ _ | .lexNormalize _ | .lexAllowed _
  | .operation _ | .number _ | .character _ | .truth _ | .variable _ | .function _
  | .app _ _ | .defaultFalse _ | .scalarReadDefault _ _ _ | .scalarReadArrays _ _ _ _ _ _
  | .expressionArrays _ _ _ _ _ _ _ | .field _ _ | .count _ | .scalarCount _
  | .word _ | .integerTypeWord | .booleanTypeWord | .characterTypeWord | .arrayCount _ | .maxArrayBindings | .maxArrayElements
  | .invalidScalar | .integerNumber _ | .wideInteger _ | .wideNumber _ | .elementCount _
  | .arrayPut _ _ _ | .arrayUsedValues _ _ _ | .arrayNamesOnly _ _ | .stateArray _ _
  | .statePositionArray _ _ _ | .arrayAppend _ _ _ _ _ _ _ _ _ | .maxScalarBindings
  | .defaultFull _ | .subtypeCount _ | .subtypeItem _ _ | .hiddenFlag _ _ | .operationName _
  | .forOperations _ _ | .subtypeAppend _ _ _ _ _ _ _ | .stateSubtype _ _ _ | .maxSubtypeBindings
  | .fullInterval | .emptyInterval | .interval _ _ | .constraint _ _
  | .scalarBinding _ _ _ _ _ _ | .stateScalar _ _ _ | .item _ _ | .group _
  | .byteAt _ _ | .sourceLast _ | .sourceLength _ | .characterVal _
  | .maxLength | .maxBindings | .maxOperands | .maxConcatenations | .token _
  | .tokenSpelling _ | .spellingLength _ | .wordToken _ | .hasArguments _
  | .tokensLast _ | .tokenIndex _ _ | .initial | .invalid | .invalidValue
  | .invalidResult | .invalidScan | .binding _ _ _ _ _ _ | .value _ _ _ _ _ _ _ _
  | .result _ _ _ _ _ _ | .scan _ _ _ _ _ _ _ _ _ _ | .scanDepth _ _ _
  | .scanAtom _ _ _ _ _ _ _ _ | .scanNeed _ _ | .scanComplete _ | .statePosition _ _
  | .stateTarget _ _ _ | .stateCapacity _ _ _ | .stateDynamic _ _ _ | .stateBinding _ _ _ => true
  | _ => false

def Expr.term : Expr ty → Bool
  | .integerMul _ _ => true
  | .mul _ _ | .not _ => true
  | x => x.primary

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ | .integerAdd _ _ | .integerSub _ _ => true
  | x => x.term

def Expr.relation : Expr ty → Bool
  | .integerEq _ _ => true
  | .integerNe _ _ | .integerLt _ _ | .integerLe _ _ | .integerGt _ _ | .integerGe _ _
  | .eq _ _ | .ne _ _ | .boolNe _ _ | .lt _ _ | .le _ _ | .ge _ _ | .gt _ _
  | .operatorByte _ | .range _ _ _ | .tokenEq _ _ => true
  | x => x.simple

/-- Full expressions may be logical; relational operands must be simple
expressions. Bare conditional/declaration expressions require grouping. -/
def Expr.expression : Expr ty → Bool
  | .andThen _ _ | .orElse _ _ => true
  | x => x.relation

def Expr.logical (value : Expr .truth) : Bool := value.expression

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.andLeft : Expr .truth → Bool | .andThen _ _ => true | x => x.relation

def Expr.orLeft : Expr .truth → Bool | .orElse _ _ => true | x => x.relation

def Expr.functionSpine : Expr ty → Bool
  | .function _ => true
  | .app f _ => f.functionSpine
  | _ => false

def localType : (ty : Ty) → String → Bool
  | .number, name => decide (name ∈ ["literal_position", "binding_count", "capacity_value", "operand_count", "array_bindings.element_count", "subtype_count"])
  | .state, name => name == "parser_state"
  | .scalarConstraint, name => name == "scalar_constraint_result"
  | .scalarResult, name => name == "scalar_expressions.expression_result"
  | .scalarLiteral, name => name == "silver_scalar_literals.literal_result"
  | .truth, name => name == "boolean"
  | .value, name => name == "value_result"
  | .result, name => name == "expression_result"
  | .scan, name => name == "expression_state"
  | _, _ => false

/-- Only the four source helpers below declare this omitted Boolean default.
The application spine must already supply every preceding argument. -/
def Expr.falseDefaultSpine : Expr ty → Nat → Bool
  | .function symbol, 0 => match symbol with
      | .value | .expressionStep | .tail | .expression => true
      | _ => false
  | .app f _, remaining + 1 => f.falseDefaultSpine remaining
  | _, _ => false

def Expr.hasFalseDefault (value : Expr (.arrow .truth ty)) : Bool :=
  value.falseDefaultSpine 4

def Expr.fullDefaultSpine : Expr ty → Nat → Bool
  | .function symbol, 0 => symbol == .scalarConstraint
  | .app f _, remaining + 1 => f.fullDefaultSpine remaining
  | _, _ => false

def Expr.hasFullDefault (value : Expr (.arrow .interval .scalarConstraint)) : Bool :=
  value.fullDefaultSpine 3

def Expr.wellFormed : Expr ty → Bool
  | .nativeBinding a b c d e f isCharacter first last => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed && isCharacter.wellFormed && first.wellFormed && last.wellFormed
  | .nativeValue a b m c d n e r operands first last => a.wellFormed && b.wellFormed && m.wellFormed && c.wellFormed && d.wellFormed && n.wellFormed && e.wellFormed && r.wellFormed && operands.wellFormed && first.wellFormed && last.wellFormed
  | .nativeResult a m b c d e first last => a.wellFormed && m.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && first.wellFormed && last.wellFormed
  | .nativeScan p m l d o depth named need complete empty first last => p.wellFormed && m.wellFormed && l.wellFormed && d.wellFormed && o.wellFormed && depth.wellFormed && named.wellFormed && need.wellFormed && complete.wellFormed && empty.wellFormed && first.wellFormed && last.wellFormed
  | .nativeScanAtom s p m l d o first last n e => s.wellFormed && p.wellFormed && m.wellFormed && l.wellFormed && d.wellFormed && o.wellFormed && first.wellFormed && last.wellFormed && n.wellFormed && e.wellFormed
  | .valueAfter localValue after => localValue.wellFormed && after.wellFormed
  | .integerMul left right => left.wellFormed && right.wellFormed && left.primary && right.primary
  | .integerEq left right => left.wellFormed && right.wellFormed && left.simple && right.simple
  | .wideMaximum left right => left.wellFormed && right.wellFormed
  | .valueNumber localValue => localValue.wellFormed
  | .valueInteger localValue => localValue.wellFormed
  | .capacityInteger localValue => localValue.wellFormed
  | .singleton localValue => localValue.wellFormed
  | .joinInterval left right => left.wellFormed && right.wellFormed
  | .minimumInteger => true
  | .maximumInteger | .maximumLength => true
  | .lexTrivia a b => a.wellFormed && b.wellFormed
  | .lexLiteralEnd a b => a.wellFormed && b.wellFormed
  | .lexLiteralLength a b => a.wellFormed && b.wellFormed
  | .lexIdentifier a b => a.wellFormed && b.wellFormed
  | .lexForbidden a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .lexForbiddenArgument a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .lexEqual a b c d e => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed
  | .lexDecimal a b => a.wellFormed && b.wellFormed
  | .lexTokenAt a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed
  | .lexNormalize a => a.wellFormed
  | .lexAllowed a => a.wellFormed
  | .app f x => f.wellFormed && x.wellFormed && f.functionSpine && x.expression
  | .defaultFalse f => f.wellFormed && f.hasFalseDefault
  | .defaultFull f => f.wellFormed && f.hasFullDefault
  | .subtypeCount names => names.wellFormed && names.prefix
  | .subtypeItem names index => names.wellFormed && names.prefix && index.wellFormed && index.expression
  | .hiddenFlag flags op => flags.wellFormed && flags.prefix && op.wellFormed && op.expression
  | .operationName op => op.wellFormed && op.expression
  | .forOperations _ body => body.wellFormed && body.expression
  | .subtypeAppend names first after bounds trueHidden falseHidden flags => names.wellFormed && names.prefix &&
      first.wellFormed && first.expression && after.wellFormed && after.expression &&
      bounds.wellFormed && bounds.expression && trueHidden.wellFormed && trueHidden.expression &&
      falseHidden.wellFormed && falseHidden.expression && flags.wellFormed && flags.expression
  | .stateSubtype state position names => state.wellFormed && state.primary && position.wellFormed && position.expression && names.wellFormed && names.expression
  | .maxSubtypeBindings => true
  | .scalarReadDefault t p n => t.wellFormed && p.wellFormed && n.wellFormed && t.expression && p.expression && n.expression
  | .scalarReadArrays t p n a i e => t.wellFormed && p.wellFormed && n.wellFormed &&
      a.wellFormed && i.wellFormed && e.wellFormed && t.expression && p.expression && n.expression && a.expression && i.expression && e.expression
  | .expressionArrays t p n sn a i e => t.wellFormed && p.wellFormed && n.wellFormed && sn.wellFormed &&
      a.wellFormed && i.wellFormed && e.wellFormed && t.expression && p.expression && n.expression && sn.expression && a.expression && i.expression && e.expression
  | .field _ x => x.wellFormed && x.prefix
  | .scalarCount x => x.wellFormed && x.prefix
  | .arrayCount a => a.wellFormed && a.prefix
  | .wideInteger a => a.wellFormed
  | .wideNumber a => a.wellFormed
  | .elementCount a => a.wellFormed
  | .integerSub a b | .integerAdd a b => a.wellFormed && b.wellFormed && a.simple && b.term
  | .integerGt a b | .integerGe a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .arrayPut a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .arrayUsedValues a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .arrayNamesOnly a b => a.wellFormed && b.wellFormed
  | .stateArray a b => a.wellFormed && b.wellFormed
  | .statePositionArray a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .arrayAppend a b c d e f g h i => a.wellFormed && a.prefix && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed && g.wellFormed && h.wellFormed && i.wellFormed
  | .maxArrayBindings | .maxArrayElements | .invalidScalar | .integerNumber _ => true
  | .word _ | .integerTypeWord | .booleanTypeWord | .characterTypeWord | .maxScalarBindings => true
  | .operatorByte x => x.wellFormed && x.simple
  | .fullInterval | .emptyInterval => true
  | .interval a b => a.wellFormed && b.wellFormed
  | .integerNe a b | .integerLt a b | .integerLe a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .constraint a b => a.wellFormed && b.wellFormed
  | .scalarBinding a b c d e f => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed
  | .stateScalar a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .count x => x.wellFormed && x.prefix
  | .item x i => x.wellFormed && x.prefix && i.wellFormed
  | .add x y => x.wellFormed && y.wellFormed && x.simple && y.term
  | .sub x y => x.wellFormed && y.wellFormed && x.simple && y.term
  | .mul x y => x.wellFormed && y.wellFormed && x.primary && y.primary
  | .eq x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .ne x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .boolNe x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .lt x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .ge x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .le x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .gt x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .range x a b => x.wellFormed && a.wellFormed && b.wellFormed && x.simple && a.simple && b.simple
  | .not x => x.wellFormed && x.primary
  | .group x => x.wellFormed && !x.isElsif
  | .locals x => x.wellFormed
  | .byteAt text position => text.wellFormed && text.prefix && position.wellFormed
  | .sourceLast text => text.wellFormed && text.prefix
  | .sourceLength text => text.wellFormed && text.prefix
  | .characterVal x => x.wellFormed
  | .tokenEq x y => x.wellFormed && y.wellFormed
  | .tokenSpelling x => x.wellFormed
  | .spellingLength x => x.wellFormed && x.prefix
  | .wordToken x => x.wellFormed
  | .hasArguments x => x.wellFormed
  | .tokensLast x => x.wellFormed
  | .tokenIndex x i => x.wellFormed && i.wellFormed
  | .binding a b c d e f => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed
  | .value a b m c d n e r => a.wellFormed && b.wellFormed && m.wellFormed && c.wellFormed && d.wellFormed && n.wellFormed && e.wellFormed && r.wellFormed
  | .result a m b c d e => a.wellFormed && m.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed
  | .scan p m l d o depth named need complete empty => p.wellFormed && m.wellFormed && l.wellFormed && d.wellFormed && o.wellFormed && depth.wellFormed && named.wellFormed && need.wellFormed && complete.wellFormed && empty.wellFormed
  | .scanDepth s p d => s.wellFormed && p.wellFormed && d.wellFormed
  | .scanAtom s p m l d o n e => s.wellFormed && p.wellFormed && m.wellFormed && l.wellFormed && d.wellFormed && o.wellFormed && n.wellFormed && e.wellFormed
  | .scanNeed s p => s.wellFormed && p.wellFormed
  | .scanComplete s => s.wellFormed
  | .statePosition s p => s.wellFormed && p.wellFormed
  | .stateTarget s p t => s.wellFormed && p.wellFormed && t.wellFormed
  | .stateCapacity s p c => s.wellFormed && p.wellFormed && c.wellFormed
  | .stateDynamic s a b => s.wellFormed && a.wellFormed && b.wellFormed
  | .stateBinding s p info => s.wellFormed && s.prefix && p.wellFormed && info.wellFormed
  | .someForm source => source.wellFormed
  | .firstForm _ source => source.wellFormed
  | .operation _ => true
  | .number _ => true
  | .character n => decide (32 ≤ n ∧ n ≤ 126 ∧ n ≠ 39 ∧ n ≠ 40)
  | .truth _ => true
  | .variable _ => true
  | .maxLength  => true
  | .maxBindings  => true
  | .maxOperands  => true
  | .maxConcatenations => true
  | .token _ => true
  | .initial  => true
  | .invalid  => true
  | .invalidValue  => true
  | .invalidResult  => true
  | .invalidScan => true
  | .function _ => true
  | .andThen a b => a.wellFormed && b.wellFormed && a.andLeft && b.relation
  | .orElse a b => a.wellFormed && b.wellFormed && a.orLeft && b.relation
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.expression &&
      b.wellFormed && (b.expression || b.isElsif)
  | .local (a := ty) _ typeName localValue rest => localType ty typeName && localValue.wellFormed &&
      localValue.expression && rest.wellFormed

abbrev WellFormedTrees : Prop :=
  subtypeLookupModelBody.wellFormed = true ∧
  scalarTypeBody.wellFormed = true ∧
  subtypeDeclarationBody.wellFormed = true ∧
  callAfterBody.wellFormed = true ∧
  skipBody.wellFormed = true ∧
  nameBody.wellFormed = true ∧
  fixedBody.wellFormed = true ∧
  lookupFromBody.wellFormed = true ∧
  lookupBody.wellFormed = true ∧
  literalBody.wellFormed = true ∧
  workTailBody.wellFormed = true ∧
  workBudgetBody.wellFormed = true ∧
  imageBody.wellFormed = true ∧
  valueBody.wellFormed = true ∧
  newNameBody.wellFormed = true ∧
  addBindingBody.wellFormed = true ∧
  declarationBody.wellFormed = true ∧
  stringDeclarationBody.wellFormed = true ∧
  scalarConstraintBody.wellFormed = true ∧
  scalarDeclarationBody.wellFormed = true ∧
  argumentBody.wellFormed = true ∧
  declarationsBody.wellFormed = true ∧
  expressionStepBody.wellFormed = true ∧
  fitsBody.wellFormed = true ∧
  comparisonBody.wellFormed = true ∧
  tailBody.wellFormed = true ∧
  expressionBody.wellFormed = true ∧
  targetBody.wellFormed = true ∧
  dynamicBody.wellFormed = true ∧
  assignmentBody.wellFormed = true ∧
  outputBody.wellFormed = true ∧
  capacityBody.wellFormed = true ∧
  stepBody.wellFormed = true ∧
  suffixBody.wellFormed = true ∧
  formBody.wellFormed = true ∧
  memberBody.wellFormed = true ∧
  argumentsBody.wellFormed = true ∧
  assignmentSelectorBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

namespace PrecedenceChecks

private theorem selected_prefixes :
    (Expr.field .statePosition (.group .initial)).wellFormed = false ∧
    (Expr.field .statePosition (.group (.ite (.truth true) .initial .invalid))).wellFormed = false ∧
    (Expr.field .statePosition (.statePosition .initial (.number 1))).wellFormed = false ∧
    (Expr.field .intervalLower (.interval (.integerNumber 0) (.integerNumber 1))).wellFormed = false ∧
    (Expr.count (.group (.variable "names"))).wellFormed = false ∧
    (Expr.scalarCount (.group (.variable "scalars"))).wellFormed = false ∧
    (Expr.arrayCount (.group (.variable "arrays"))).wellFormed = false ∧
    (Expr.subtypeCount (.group (.variable "subtypes"))).wellFormed = false ∧
    (Expr.field .statePosition .initial).wellFormed = true ∧
    (Expr.field .bindingFirst (.item (.variable "names") (.number 1))).wellFormed = true ∧
    (Expr.field .scalarAfter
      (.scalarReadDefault (.variable "text") (.number 1) (.variable "scalars"))).wellFormed = true := by decide +kernel

private theorem indexed_and_attribute_prefixes :
    (Expr.item (.group (.variable "names")) (.number 1)).wellFormed = false ∧
    (Expr.subtypeItem (.group (.variable "subtypes")) (.number 1)).wellFormed = false ∧
    (Expr.hiddenFlag (.group (.variable "flags")) (.operation .output)).wellFormed = false ∧
    (Expr.byteAt (.group (.variable "text")) (.number 1)).wellFormed = false ∧
    (Expr.sourceLast (.group (.variable "text"))).wellFormed = false ∧
    (Expr.sourceLength (.group (.variable "text"))).wellFormed = false ∧
    (Expr.spellingLength (.group .integerTypeWord)).wellFormed = false ∧
    (Expr.item (.variable "names") (.number 1)).wellFormed = true ∧
    (Expr.hiddenFlag (.variable "flags") (.operation .output)).wellFormed = true ∧
    (Expr.byteAt (.variable "text") (.number 1)).wellFormed = true ∧
    (Expr.spellingLength (.tokenSpelling (.token (.symbol ":")))).wellFormed = true := by decide +kernel

private theorem aggregate_base_categories :
    (Expr.stateBinding (.group .initial) (.number 1) (.variable "info")).wellFormed = false ∧
    (Expr.subtypeAppend (.group (.variable "subtypes")) (.number 1) (.number 2)
      .fullInterval (.truth false) (.truth false) (.variable "flags")).wellFormed = false ∧
    (Expr.arrayAppend (.group (.variable "arrays")) (.number 1) (.number 2)
      .fullInterval (.number 0) (.number 1) (.truth false) .fullInterval (.truth false)).wellFormed = false ∧
    (Expr.stateBinding .initial (.number 1) (.variable "info")).wellFormed = true ∧
    (Expr.statePosition (.group .initial) (.number 1)).wellFormed = true ∧
    (Expr.statePosition (.statePosition .initial (.number 1)) (.number 2)).wellFormed = true := by decide +kernel

private def rightSub : Expr .integer := .integerSub (.integerNumber 10)
  (.integerSub (.integerNumber 3) (.integerNumber 1))
private def leftSub : Expr .integer := .integerSub
  (.integerSub (.integerNumber 10) (.integerNumber 3)) (.integerNumber 1)
private def integerChoice : Expr .integer := .ite (.truth true) (.integerNumber 3) (.integerNumber 1)
private def logicalOperand : Expr .truth := .andThen (.truth false) (.truth false)

/-- Equal flattened tokens do not imply equal tree meanings. -/
private theorem subtraction_collision (calls : Calls) (locals : Locals) :
    rightSub.render = leftSub.render ∧ rightSub.eval calls locals = 8 ∧ leftSub.eval calls locals = 6 := by
  exact ⟨rfl, rfl, rfl⟩

private theorem arithmetic_categories :
    rightSub.wellFormed = false ∧ leftSub.wellFormed = true ∧
    (Expr.integerSub (.integerNumber 10) (.group (.integerSub (.integerNumber 3) (.integerNumber 1)))).wellFormed = true ∧
    (Expr.integerSub (.integerNumber 10) (.integerAdd (.integerNumber 3) (.integerNumber 1))).wellFormed = false ∧
    (Expr.integerSub (.integerNumber 10) (.group (.integerAdd (.integerNumber 3) (.integerNumber 1)))).wellFormed = true ∧
    (Expr.integerAdd (.integerNumber 10) (.integerAdd (.integerNumber 3) (.integerNumber 1))).wellFormed = false ∧
    (Expr.integerAdd (.integerNumber 10) (.group (.integerAdd (.integerNumber 3) (.integerNumber 1)))).wellFormed = true ∧
    (Expr.not (.integerGt (.integerNumber 3) (.integerNumber 1))).wellFormed = false ∧
    (Expr.not (.group (.integerGt (.integerNumber 3) (.integerNumber 1)))).wellFormed = true ∧
    (Expr.not (.integerGe (.integerNumber 3) (.integerNumber 1))).wellFormed = false := by decide +kernel

private theorem conditional_categories :
    (Expr.integerSub integerChoice (.integerNumber 1)).wellFormed = false ∧
    (Expr.integerAdd (.integerNumber 1) integerChoice).wellFormed = false ∧
    (Expr.integerGt integerChoice (.integerNumber 1)).wellFormed = false ∧
    (Expr.integerGe (.integerNumber 1) integerChoice).wellFormed = false ∧
    (Expr.integerNe integerChoice (.integerNumber 1)).wellFormed = false ∧
    (Expr.integerLt (.integerNumber 1) integerChoice).wellFormed = false ∧
    (Expr.integerSub (.group integerChoice) (.integerNumber 1)).wellFormed = true ∧
    (Expr.integerGe (.integerNumber 1) (.group integerChoice)).wellFormed = true ∧
    (Expr.group (.integerAdd integerChoice (.integerNumber 1))).wellFormed = false ∧
    (Expr.group (.integerAdd (.group integerChoice) (.integerNumber 1))).wellFormed = true ∧
    (Expr.app (.app (.function .arrayPut) (.variable "state"))
      (.integerSub integerChoice (.integerNumber 1))).wellFormed = false ∧
    (Expr.app (.app (.function .arrayPut) (.variable "state"))
      (.integerSub (.group integerChoice) (.integerNumber 1))).wellFormed = true ∧
    (Expr.ite (.truth true) integerChoice (.integerNumber 0)).wellFormed = false ∧
    (Expr.ite (.truth true) (.group integerChoice) (.integerNumber 0)).wellFormed = true := by decide +kernel

private theorem boolean_collision (calls : Calls) (locals : Locals) :
    (Expr.boolNe logicalOperand (.truth true)).render =
      (Expr.andThen (.truth false) (.boolNe (.truth false) (.truth true))).render ∧
    (Expr.boolNe logicalOperand (.truth true)).eval calls locals = true ∧
    (Expr.andThen (.truth false) (.boolNe (.truth false) (.truth true))).eval calls locals = false := by
  exact ⟨rfl, rfl, rfl⟩

private theorem boolean_categories :
    (Expr.boolNe logicalOperand (.truth true)).wellFormed = false ∧
    (Expr.boolNe (.group logicalOperand) (.truth true)).wellFormed = true ∧
    (Expr.boolNe (.truth true) (.boolNe (.truth true) (.truth false))).wellFormed = false ∧
    (Expr.boolNe (.truth true) (.group (.boolNe (.truth true) (.truth false)))).wellFormed = true ∧
    (Expr.boolNe (.not (.truth true)) (.truth false)).wellFormed = true ∧
    (Expr.ite (.truth true) logicalOperand (.truth false)).wellFormed = true ∧
    (Expr.app (.app (.function .contextAfter) (.variable "text")) logicalOperand).wellFormed = true := by decide +kernel

end PrecedenceChecks

/-- Names are checked against the parameter/local declaration scope. The
first binding wins, matching Ada lexical shadowing; a variable of another type
cannot accidentally read a default value from the semantic environment. -/
abbrev Scope := List (String × Ty)

def Scope.contains (scope : Scope) (name : String) (ty : Ty) : Bool :=
  ((scope.find? (fun item => item.1 == name)).map Prod.snd) == some ty

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .nativeBinding a b c d e f isCharacter first last => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope && f.scoped scope && isCharacter.scoped scope && first.scoped scope && last.scoped scope
  | .nativeValue a b m c d n e r operands first last => a.scoped scope && b.scoped scope && m.scoped scope && c.scoped scope && d.scoped scope && n.scoped scope && e.scoped scope && r.scoped scope && operands.scoped scope && first.scoped scope && last.scoped scope
  | .nativeResult a m b c d e first last => a.scoped scope && m.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope && first.scoped scope && last.scoped scope
  | .nativeScan p m l d o depth named need complete empty first last => p.scoped scope && m.scoped scope && l.scoped scope && d.scoped scope && o.scoped scope && depth.scoped scope && named.scoped scope && need.scoped scope && complete.scoped scope && empty.scoped scope && first.scoped scope && last.scoped scope
  | .nativeScanAtom s p m l d o first last n e => s.scoped scope && p.scoped scope && m.scoped scope && l.scoped scope && d.scoped scope && o.scoped scope && first.scoped scope && last.scoped scope && n.scoped scope && e.scoped scope
  | .valueAfter localValue after => localValue.scoped scope && after.scoped scope
  | .integerMul left right => left.scoped scope && right.scoped scope
  | .integerEq left right => left.scoped scope && right.scoped scope
  | .wideMaximum left right => left.scoped scope && right.scoped scope
  | .valueNumber localValue => localValue.scoped scope
  | .valueInteger localValue => localValue.scoped scope
  | .capacityInteger localValue => localValue.scoped scope
  | .singleton localValue => localValue.scoped scope
  | .joinInterval left right => left.scoped scope && right.scoped scope
  | .minimumInteger => true
  | .maximumInteger | .maximumLength => true
  | .lexTrivia a b => a.scoped scope && b.scoped scope
  | .lexLiteralEnd a b => a.scoped scope && b.scoped scope
  | .lexLiteralLength a b => a.scoped scope && b.scoped scope
  | .lexIdentifier a b => a.scoped scope && b.scoped scope
  | .lexForbidden a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .lexForbiddenArgument a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .lexEqual a b c d e => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope
  | .lexDecimal a b => a.scoped scope && b.scoped scope
  | .lexTokenAt a b c d => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope
  | .lexNormalize a => a.scoped scope
  | .lexAllowed a => a.scoped scope
  | .app f x => f.scoped scope && x.scoped scope
  | .defaultFalse f => f.scoped scope
  | .defaultFull f => f.scoped scope
  | .subtypeCount names => names.scoped scope
  | .subtypeItem names index => names.scoped scope && index.scoped scope
  | .hiddenFlag flags op => flags.scoped scope && op.scoped scope
  | .operationName op => op.scoped scope
  | .forOperations name body => body.scoped ((name, .operation) :: scope)
  | .subtypeAppend names first after bounds trueHidden falseHidden flags => names.scoped scope && first.scoped scope && after.scoped scope && bounds.scoped scope && trueHidden.scoped scope && falseHidden.scoped scope && flags.scoped scope
  | .stateSubtype state position names => state.scoped scope && position.scoped scope && names.scoped scope
  | .maxSubtypeBindings => true
  | .scalarReadDefault t p n => t.scoped scope && p.scoped scope && n.scoped scope
  | .scalarReadArrays t p n a i e => t.scoped scope && p.scoped scope && n.scoped scope && a.scoped scope && i.scoped scope && e.scoped scope
  | .expressionArrays t p n sn a i e => t.scoped scope && p.scoped scope && n.scoped scope && sn.scoped scope && a.scoped scope && i.scoped scope && e.scoped scope
  | .field _ x => x.scoped scope
  | .scalarCount x => x.scoped scope
  | .arrayCount a => a.scoped scope
  | .wideInteger a => a.scoped scope
  | .wideNumber a => a.scoped scope
  | .elementCount a => a.scoped scope
  | .integerSub a b => a.scoped scope && b.scoped scope
  | .integerAdd a b => a.scoped scope && b.scoped scope
  | .integerGt a b => a.scoped scope && b.scoped scope
  | .integerGe a b => a.scoped scope && b.scoped scope
  | .arrayPut a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .arrayUsedValues a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .arrayNamesOnly a b => a.scoped scope && b.scoped scope
  | .stateArray a b => a.scoped scope && b.scoped scope
  | .statePositionArray a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .arrayAppend a b c d e f g h i => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope && f.scoped scope && g.scoped scope && h.scoped scope && i.scoped scope
  | .maxArrayBindings | .maxArrayElements | .invalidScalar | .integerNumber _ => true
  | .word _ | .integerTypeWord | .booleanTypeWord | .characterTypeWord | .maxScalarBindings => true
  | .operatorByte x => x.scoped scope
  | .fullInterval | .emptyInterval => true
  | .interval a b | .integerNe a b | .integerLt a b | .integerLe a b => a.scoped scope && b.scoped scope
  | .constraint a b => a.scoped scope && b.scoped scope
  | .scalarBinding a b c d e f => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope && f.scoped scope
  | .stateScalar a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .count x => x.scoped scope
  | .item x i => x.scoped scope && i.scoped scope
  | .add x y => x.scoped scope && y.scoped scope
  | .sub x y => x.scoped scope && y.scoped scope
  | .mul x y => x.scoped scope && y.scoped scope
  | .eq x y => x.scoped scope && y.scoped scope
  | .ne x y => x.scoped scope && y.scoped scope
  | .boolNe x y => x.scoped scope && y.scoped scope
  | .lt x y => x.scoped scope && y.scoped scope
  | .ge x y => x.scoped scope && y.scoped scope
  | .le x y => x.scoped scope && y.scoped scope
  | .gt x y => x.scoped scope && y.scoped scope
  | .range x a b => x.scoped scope && a.scoped scope && b.scoped scope
  | .not x => x.scoped scope
  | .group x => x.scoped scope
  | .locals x => x.scoped scope
  | .byteAt text position => text.scoped scope && position.scoped scope
  | .sourceLast text => text.scoped scope
  | .sourceLength text => text.scoped scope
  | .characterVal x => x.scoped scope
  | .tokenEq x y => x.scoped scope && y.scoped scope
  | .tokenSpelling x => x.scoped scope
  | .spellingLength x => x.scoped scope
  | .wordToken x => x.scoped scope
  | .hasArguments x => x.scoped scope
  | .tokensLast x => x.scoped scope
  | .tokenIndex x i => x.scoped scope && i.scoped scope
  | .binding a b c d e f => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope && f.scoped scope
  | .value a b m c d n e r => a.scoped scope && b.scoped scope && m.scoped scope && c.scoped scope && d.scoped scope && n.scoped scope && e.scoped scope && r.scoped scope
  | .result a m b c d e => a.scoped scope && m.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope
  | .scan p m l d o depth named need complete empty => p.scoped scope && m.scoped scope && l.scoped scope && d.scoped scope && o.scoped scope && depth.scoped scope && named.scoped scope && need.scoped scope && complete.scoped scope && empty.scoped scope
  | .scanDepth s p d => s.scoped scope && p.scoped scope && d.scoped scope
  | .scanAtom s p m l d o n e => s.scoped scope && p.scoped scope && m.scoped scope && l.scoped scope && d.scoped scope && o.scoped scope && n.scoped scope && e.scoped scope
  | .scanNeed s p => s.scoped scope && p.scoped scope
  | .scanComplete s => s.scoped scope
  | .statePosition s p => s.scoped scope && p.scoped scope
  | .stateTarget s p t => s.scoped scope && p.scoped scope && t.scoped scope
  | .stateCapacity s p c => s.scoped scope && p.scoped scope && c.scoped scope
  | .stateDynamic s a b => s.scoped scope && a.scoped scope && b.scoped scope
  | .stateBinding s p info => s.scoped scope && p.scoped scope && info.scoped scope
  | .someForm source => source.scoped scope
  | .firstForm _ source => source.scoped scope
  | .operation _ => true
  | .number _ | .character _ => true
  | .truth _ => true
  | .maxLength  => true
  | .maxBindings  => true
  | .maxOperands  => true
  | .maxConcatenations => true
  | .token _ => true
  | .initial  => true
  | .invalid  => true
  | .invalidValue  => true
  | .invalidResult  => true
  | .invalidScan => true
  | .variable (ty := ty) name => scope.contains name ty
  | .function _ => true
  | .andThen a b | .orElse a b => a.scoped scope && b.scoped scope
  | .ite c a b | .elsif c a b => c.scoped scope && a.scoped scope && b.scoped scope
  | .local (a := ty) name _ localValue rest => localValue.scoped scope && rest.scoped ((name,ty) :: scope)

abbrev WellScopedTrees : Prop :=
  subtypeLookupModelBody.scoped [("text", .source), ("subtypes", .subtypeNames), ("first", .number), ("after", .number), ("index", .number)] = true ∧
  scalarTypeBody.scoped [("text", .source), ("state", .state), ("position", .number)] = true ∧
  subtypeDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  callAfterBody.scoped [("booleans", .booleanNames), ("subtype_hidden", .truth), ("arrays", .arrayMetadata), ("scalar_names", .scalarNames), ("text", .source), ("environment", .names), ("position", .number), ("operation", .operation)] = true ∧
  skipBody.scoped [("text", .source), ("position", .number)] = true ∧
  nameBody.scoped [("text", .source), ("position", .number)] = true ∧
  fixedBody.scoped [("text", .source), ("position", .number), ("token", .token)] = true ∧
  lookupFromBody.scoped [("text", .source), ("names", .names), ("first", .number), ("after", .number), ("index", .number)] = true ∧
  lookupBody.scoped [("text", .source), ("names", .names), ("first", .number), ("after", .number)] = true ∧
  literalBody.scoped [("text", .source), ("position", .number)] = true ∧
  workTailBody.scoped [("text", .source), ("position", .number), ("remaining", .number)] = true ∧
  workBudgetBody.scoped [("text", .source)] = true ∧
  imageBody.scoped [("arrays", .arrayMetadata), ("initials", .arrayInitials), ("elaborating", .truth), ("integer_hidden", .truth), ("scalar_names", .scalarNames), ("text", .source), ("position", .number), ("names", .names)] = true ∧
  valueBody.scoped [("arrays", .arrayMetadata), ("initials", .arrayInitials), ("elaborating", .truth), ("integer_hidden", .truth), ("scalar_names", .scalarNames), ("text", .source), ("position", .number), ("names", .names)] = true ∧
  newNameBody.scoped [("text", .source), ("state", .state), ("first", .number), ("after", .number), ("arguments", .truth)] = true ∧
  addBindingBody.scoped [("character_object", .truth), ("state", .state), ("first", .number), ("after", .number), ("value", .value), ("mutable", .truth), ("following", .number)] = true ∧
  stringDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  scalarConstraintBody.scoped [("base_bounds", .interval), ("text", .source), ("position", .number), ("scalar_names", .scalarNames)] = true ∧
  scalarDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  declarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  argumentBody.scoped [("text", .source), ("state", .state)] = true ∧
  declarationsBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  expressionStepBody.scoped [("arrays", .arrayMetadata), ("initials", .arrayInitials), ("elaborating", .truth), ("integer_hidden", .truth), ("scalar_names", .scalarNames), ("text", .source), ("names", .names), ("state", .scan)] = true ∧
  tailBody.scoped [("arrays", .arrayMetadata), ("initials", .arrayInitials), ("elaborating", .truth), ("integer_hidden", .truth), ("scalar_names", .scalarNames), ("text", .source), ("names", .names), ("state", .scan)] = true ∧
  fitsBody.scoped [("value", .result), ("capacity", .number)] = true ∧
  comparisonBody.scoped [("text", .source), ("state", .state)] = true ∧
  expressionBody.scoped [("arrays", .arrayMetadata), ("initials", .arrayInitials), ("elaborating", .truth), ("integer_hidden", .truth), ("scalar_names", .scalarNames), ("text", .source), ("position", .number), ("names", .names)] = true ∧
  targetBody.scoped [("text", .source), ("state", .state), ("same_target", .truth)] = true ∧
  dynamicBody.scoped [("text", .source), ("state", .state)] = true ∧
  assignmentBody.scoped [("text", .source), ("state", .state)] = true ∧
  outputBody.scoped [("text", .source), ("state", .state)] = true ∧
  capacityBody.scoped [("text", .source), ("state", .state)] = true ∧
  stepBody.scoped [("text", .source), ("form", .form), ("token", .token), ("state", .state)] = true ∧
  suffixBody.scoped [("text", .source), ("form", .form), ("next_token", .number), ("state", .state)] = true ∧
  formBody.scoped [("source", .source), ("form", .form)] = true ∧
  memberBody.scoped [("source", .source)] = true ∧
  argumentsBody.scoped [("source", .source)] = true ∧
  assignmentSelectorBody.scoped [("source", .source)] = true

theorem checked_scopes : WellScopedTrees := by decide +kernel

/-- Active entries of the native fixed array. Unused cells are irrelevant:
lookup reads only 1..Count and extension writes exactly Count+1. -/
structure ArrayNames where
  count : Nat
  items : Nat → BindingInfo

def ArrayNames.active (names : ArrayNames) : BindingEnvironment :=
  List.ofFn (fun i : Fin names.count => names.items (i.val + 1))

def ArrayNames.extend (names : ArrayNames) (info : BindingInfo) : ArrayNames :=
  ⟨names.count + 1, fun i => if i = names.count + 1 then info else names.items i⟩

theorem ArrayNames.active_length (names : ArrayNames) : names.active.length = names.count := by
  simp [active]

theorem ArrayNames.active_get (names : ArrayNames) (index : Nat)
    (first : 0 < index) (last : index ≤ names.count) :
    names.active.get index = some (names.items index) := by
  have positive : index ≠ 0 := by omega
  have bounded : index - 1 < names.count := by omega
  simp [Bindings.BindingEnvironment.get, positive, active, bounded,
    Nat.sub_add_cancel first]

theorem ArrayNames.extend_active (names : ArrayNames) (info : BindingInfo) :
    (names.extend info).active = names.active ++ [info] := by
  simp only [active, extend]
  rw [List.ofFn_succ_last]
  congr 1
  · apply congrArg List.ofFn
    funext i
    have different : i.val ≠ names.count := Nat.ne_of_lt i.isLt
    simp [different]
  · simp [Fin.val_last]

end Silver.Compose.Expressions
