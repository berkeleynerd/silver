module

public import Silver.PredicateReadings
public import Silver.PredicateCharacterReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

set_option backward.dsimp.instances true

/-- String relations retain the named operand required for Ada's overload
resolution. This does not grant byte equalities to mutable objects. -/
def StringRelationReady (facts : ActiveFlow) (left right : ExpressionResult) (operator : ComparisonResult) : Prop :=
  left.after ≠ 0 ∧ operator.after ≠ 0 ∧ (operator.operator = .eq ∨ operator.operator = .ne) ∧
    right.after ≠ 0 ∧ (left.namedSeen || right.namedSeen) = true ∧
    fitsLengthSummary facts.path (summaryOf left) = true ∧ fitsLengthSummary facts.path (summaryOf right) = true

def stringResult (facts : ActiveFlow) (left right : ExpressionResult) (operator : ComparisonResult) : ConditionResult :=
  let equalFacts := {facts with path := refineLengthOverlap facts.path (summaryOf left) (summaryOf right)}
  ⟨right.after, if operator.operator == .eq then equalFacts else facts,
    if operator.operator == .eq then facts else equalFacts⟩

def chainCondition (left right : Condition) : ChainKind → Condition
  | .shortAnd => .andThen left right
  | .shortOr => .orElse left right
  | .eagerAnd => .eager .and left right
  | .eagerOr => .eager .or left right
  | .eagerXor => .eager .xor left right

/-- The atomic meaning is a source identifier lookup or a predefined literal.
The enclosing admission clause separately checks lexical hiding and masks. -/
inductive BooleanAtomAt (text : Source) (context : ParseContext) (position : Nat) :
    Condition → Nat → Prop
  | name {spelling} :
      Named.IdentifierAt text (skipAt text position) spelling (nameAfter text (skipAt text position)) →
      BooleanBindings.lookup text context.booleanNames (skipAt text position) (nameAfter text (skipAt text position)) ≠ 0 →
      BooleanAtomAt text context position
        (.booleanName (BooleanBindings.lookup text context.booleanNames (skipAt text position) (nameAfter text (skipAt text position))))
        (nameAfter text (skipAt text position))
  | literal {value spelling} :
      Named.IdentifierAt text (skipAt text position) spelling (nameAfter text (skipAt text position)) →
      BooleanBindings.lookup text context.booleanNames (skipAt text position) (nameAfter text (skipAt text position)) = 0 →
      Named.nameIs text (skipAt text position) (nameAfter text (skipAt text position))
        ((if value then "true" else "false").toList.map Char.toNat) = true →
      BooleanAtomAt text context position (.booleanLiteral value) (nameAfter text (skipAt text position))

/-- A stored Boolean component retains the raw scalar-only index and its
complete incoming-flow checks. Every target remains the raw metadata index. -/
inductive BooleanArrayAt (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) : Condition → Nat → Prop
  | read {index : Integer.Expr} {subscript : ScalarExpression.Result} :
      (ArrayBindings.lookup text context.arrayNames (skipAt text position) (nameAfter text (skipAt text position))) ≠ 0 → (ArrayBindings.binding context.arrayNames (ArrayBindings.lookup text context.arrayNames (skipAt text position) (nameAfter text (skipAt text position)))).isBoolean = true →
      ScalarExpression.lookup text context.scalarNames (skipAt text position) (nameAfter text (skipAt text position)) = 0 →
      ¬(context.maskFirst ≠ 0 ∧ Named.equalName text context.maskFirst context.maskAfter (skipAt text position) (nameAfter text (skipAt text position)) = true) →
      ScalarExpression.At text (context.readingNames facts) (fixedAfter text (nameAfter text (skipAt text position)) "(" false) index subscript
        context.maskFirst context.maskAfter →
      subscript.operands ≠ ScalarExpression.maxOperands →
      ArrayBindings.contains (ArrayBindings.binding context.arrayNames (ArrayBindings.lookup text context.arrayNames (skipAt text position) (nameAfter text (skipAt text position)))) subscript.bounds = true →
      position < fixedAfter text subscript.after ")" false →
      BooleanArrayAt text context position facts
        (.booleanArrayRead (ArrayBindings.binding context.arrayNames (ArrayBindings.lookup text context.arrayNames (skipAt text position) (nameAfter text (skipAt text position)))).booleanDescriptor index)
        (fixedAfter text subscript.after ")" false)

/-- The indexed atom's descriptor and scalar namespace exclusion are retained
without eliminating a source-dependent end cursor. -/
theorem booleanArrayAt_shape {text context position facts condition finish}
    (reading : BooleanArrayAt text context position facts condition finish) :
    ∃ index, condition = .booleanArrayRead (ArrayBindings.binding context.arrayNames
      (ArrayBindings.lookup text context.arrayNames (skipAt text position)
        (nameAfter text (skipAt text position)))).booleanDescriptor index ∧
      ScalarExpression.lookup text context.scalarNames (skipAt text position)
        (nameAfter text (skipAt text position)) = 0 := by
  cases reading with
  | read target tag scalar mask reading operands inside advance => exact ⟨_, rfl, scalar⟩

mutual
  inductive PrimaryAtCore (text : Source) (context : ParseContext) (initials : ArrayBindings.Initials) :
      Nat → ActiveFlow → Condition → ConditionResult → Prop
    | group {position facts inner result} : position ≠ 0 →
        fixedAfter text position "(" false ≠ 0 →
        remainingAt text (fixedAfter text position "(" false) < remainingAt text position →
        ConditionAtCore text context initials (fixedAfter text position "(" false) facts inner result →
        fixedAfter text result.after ")" false ≠ 0 →
        PrimaryAtCore text context initials position facts (.parenthesized inner)
          {result with after := fixedAfter text result.after ")" false}
    | booleanArray {position facts atom after} : position ≠ 0 → fixedAfter text position "(" false = 0 →
        booleanArrayAfter text context position facts = after → after ≠ 0 →
        BooleanArrayAt text context position facts atom after →
        PrimaryAtCore text context initials position facts atom ⟨after, facts, facts⟩
    | boolean {position facts atom after} : position ≠ 0 → fixedAfter text position "(" false = 0 →
        booleanArrayAfter text context position facts = 0 →
        booleanAtomAfter text context position = after → after ≠ 0 →
        BooleanAtomAt text context position atom after →
        PrimaryAtCore text context initials position facts atom ⟨after, facts, facts⟩
    | valid {position facts} : position ≠ 0 → fixedAfter text position "(" false = 0 →
        booleanArrayAfter text context position facts = 0 →
        booleanAtomAfter text context position = 0 → context.hasArguments = true →
        callAfter text context.names position .validity context.scalarNames context.arrayNames
          (context.validityHidden text) context.booleanNames ≠ 0 →
        PrimaryAtCore text context initials position facts .inputValid
          ⟨callAfter text context.names position .validity context.scalarNames context.arrayNames
            (context.validityHidden text) context.booleanNames,
            {facts with path := facts.path.assumeValid}, {facts with path := facts.path.assumeInvalid}⟩

  inductive BooleanFactorAtCore (text : Source) (context : ParseContext) (initials : ArrayBindings.Initials) :
      Nat → ActiveFlow → Condition → ConditionResult → Prop
    | primary {position facts inner result} : fixedAfter text position "not" true = 0 →
        PrimaryAtCore text context initials position facts inner result →
        BooleanFactorAtCore text context initials position facts inner result
    | negated {position facts inner result} : fixedAfter text position "not" true ≠ 0 →
        remainingAt text (fixedAfter text position "not" true) < remainingAt text position →
        PrimaryAtCore text context initials (fixedAfter text position "not" true) facts inner result →
        BooleanFactorAtCore text context initials position facts (.negated inner)
          ⟨result.after, result.whenFalse, result.whenTrue⟩

  inductive BooleanRelationAtCore (text : Source) (context : ParseContext) (initials : ArrayBindings.Initials) :
      Nat → ActiveFlow → Condition → ConditionResult → Prop
    | factor {position facts inner result} :
        BooleanFactorAtCore text context initials position facts inner result → result.after ≠ 0 →
        (comparisonAt text result.after).after = 0 →
        BooleanRelationAtCore text context initials position facts inner result
    | comparison {position facts left right leftResult rightResult} :
        BooleanFactorAtCore text context initials position facts left leftResult → leftResult.after ≠ 0 →
        (comparisonAt text leftResult.after).after ≠ 0 →
        ((comparisonAt text leftResult.after).operator = .eq ∨ (comparisonAt text leftResult.after).operator = .ne) →
        remainingAt text (comparisonAt text leftResult.after).after < remainingAt text position →
        BooleanFactorAtCore text context initials (comparisonAt text leftResult.after).after facts right rightResult →
        rightResult.after ≠ 0 →
        BooleanRelationAtCore text context initials position facts
          (.booleanCompare ((comparisonAt text leftResult.after).operator != .eq) left right)
          ⟨rightResult.after, facts, facts⟩

  inductive RelationAtCore (text : Source) (context : ParseContext) (initials : ArrayBindings.Initials) :
      Nat → ActiveFlow → Condition → ConditionResult → Prop
    | booleanNot {position facts inner result} : position ≠ 0 →
        fixedAfter text position "not" true ≠ 0 →
        BooleanRelationAtCore text context initials position facts inner result →
        RelationAtCore text context initials position facts inner result
    | length {position facts left right leftResult rightResult} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → leftResult.after ≠ 0 →
        LengthAt text context position false (.binding left) leftResult →
        LengthAt text context (comparisonAt text leftResult.after).after true right rightResult →
        position < rightResult.after →
        RelationAtCore text context initials position facts (.lengthCompare (comparisonAt text leftResult.after).operator left right)
          ⟨rightResult.after,
            refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value true,
            refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value false⟩
    | scalars {position facts left right leftResult rightResult} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        leftResult.after ≠ 0 →
        ScalarExpression.At text (context.readingNames facts) position left leftResult
          (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) →
        ScalarExpression.At text (context.readingNames facts) (comparisonAt text leftResult.after).after right rightResult
          (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) →
        position < rightResult.after →
        RelationAtCore text context initials position facts
          (.scalarCompare (comparisonAt text leftResult.after).operator.toInteger left right)
          (scalarCondition text context position (comparisonAt text leftResult.after).after
            facts leftResult rightResult (comparisonAt text leftResult.after).operator)
    | strings {position facts left right leftResult rightResult} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        (readScalarInFlow text context position facts (initials := initials)).after = 0 →
        ExpressionAt text context.names position left leftResult (scalarNames := context.readingNames facts)
          (integerHidden := context.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) →
        ExpressionAt text context.names (comparisonAt text leftResult.after).after right rightResult
          (scalarNames := context.readingNames facts) (integerHidden := context.integerHidden text)
          (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) →
        StringRelationReady facts leftResult rightResult (comparisonAt text leftResult.after) →
        position < rightResult.after →
        RelationAtCore text context initials position facts
          (.stringCompare ((comparisonAt text leftResult.after).operator != .eq) left right)
          (stringResult facts leftResult rightResult (comparisonAt text leftResult.after))
    | character {position facts inner result} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        (readScalarInFlow text context position facts (initials := initials)).after = 0 →
        (readStringInFlow text context position facts initials).after = 0 →
        CharacterRelationAt text context position facts initials inner result →
        RelationAtCore text context initials position facts inner result
    | primary {position facts inner result} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        (readScalarInFlow text context position facts (initials := initials)).after = 0 →
        (readStringInFlow text context position facts initials).after = 0 →
        (characterCondition text context position facts initials).after = 0 →
        BooleanRelationAtCore text context initials position facts inner result →
        RelationAtCore text context initials position facts inner result

  inductive ChainAtCore (text : Source) (context : ParseContext) (initials : ArrayBindings.Initials) :
      ActiveFlow → Nat → Condition → ConditionResult → Option ChainKind → Condition → ConditionResult → Prop
    | done {incoming originalStart condition result chained} : result.after ≠ 0 → chainOperator text result.after = none →
        ChainAtCore text context initials incoming originalStart condition result chained condition result
    | next {incoming originalStart condition result chained operator right rightResult final finalResult} :
        conditionTail text context result chained incoming initials originalStart = finalResult →
        result.after ≠ 0 → chainOperator text result.after = some operator →
        ¬(chained.isSome = true ∧ chained ≠ some operator) →
        (operator = .eagerXor → xorFree text originalStart result.after = true) →
        chainAfter text result.after operator ≠ 0 →
        remainingAt text (chainAfter text result.after operator) < remainingAt text result.after →
        RelationAtCore text context initials (chainAfter text result.after operator) (chainContext result operator incoming) right rightResult →
        rightResult.after ≠ 0 →
        (operator = .eagerXor → xorFree text (chainAfter text result.after operator) rightResult.after = true) →
        remainingAt text (chainJoin result rightResult operator incoming).after < remainingAt text result.after →
        ChainAtCore text context initials incoming originalStart (chainCondition condition right operator)
          (chainJoin result rightResult operator incoming) (some operator) final finalResult →
        ChainAtCore text context initials incoming originalStart condition result chained final finalResult

  inductive ConditionAtCore (text : Source) (context : ParseContext) (initials : ArrayBindings.Initials) :
      Nat → ActiveFlow → Condition → ConditionResult → Prop
    | condition {position facts first result condition final} :
        readCondition text context position facts initials = final →
        RelationAtCore text context initials position facts first result → result.after ≠ 0 →
        remainingAt text result.after < remainingAt text position →
        ChainAtCore text context initials facts position first result none condition final →
        ConditionAtCore text context initials position facts condition final
end

abbrev PrimaryAt (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (condition : Condition) (result : ConditionResult) (initials : ArrayBindings.Initials := []) : Prop :=
  PrimaryAtCore text context initials position facts condition result
abbrev BooleanFactorAt (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (condition : Condition) (result : ConditionResult) (initials : ArrayBindings.Initials := []) : Prop :=
  BooleanFactorAtCore text context initials position facts condition result
abbrev BooleanRelationAt (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (condition : Condition) (result : ConditionResult) (initials : ArrayBindings.Initials := []) : Prop :=
  BooleanRelationAtCore text context initials position facts condition result
abbrev RelationAt (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (condition : Condition) (result : ConditionResult) (initials : ArrayBindings.Initials := []) : Prop :=
  RelationAtCore text context initials position facts condition result
abbrev ChainAt (text : Source) (context : ParseContext) (condition : Condition) (result : ConditionResult)
    (chained : Option ChainKind) (final : Condition) (finalResult : ConditionResult)
    (incoming : ActiveFlow) (initials : ArrayBindings.Initials := []) (originalStart : Nat := 0) : Prop :=
  ChainAtCore text context initials incoming originalStart condition result chained final finalResult
abbrev ConditionAt (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (condition : Condition) (result : ConditionResult) (initials : ArrayBindings.Initials := []) : Prop :=
  ConditionAtCore text context initials position facts condition result

theorem condition_complete {text context position facts condition result initials}
    (parsed : ConditionAt text context position facts condition result initials) :
    readCondition text context position facts initials = result := by
  cases parsed with | condition scanned => exact scanned

theorem primary_complete {text context position facts condition result initials}
    (parsed : PrimaryAt text context position facts condition result initials) :
    readPrimary text context position facts initials = result := by
  cases parsed with
  | group positive opening advanced inner closed =>
      rw [readPrimary]
      simp [positive, opening, advanced, condition_complete inner, closed]
  | booleanArray positive noOpening afterEq nonzero atom =>
      simp only [readPrimary, positive, noOpening, afterEq, nonzero, ne_eq,
        not_true_eq_false, not_false_eq_true, ↓reduceIte]
  | boolean positive noOpening noArray afterEq nonzero atom =>
      simp only [readPrimary, positive, noOpening, noArray, afterEq, nonzero, ne_eq,
        not_true_eq_false, not_false_eq_true, ↓reduceIte]
  | valid positive noOpening noArray noAtom arguments accepted =>
      simp only [readPrimary, positive, noOpening, noArray, noAtom, arguments, Bool.not_true, Bool.false_eq_true,
        ne_eq, not_true_eq_false, ↓reduceIte, accepted]

theorem booleanFactor_complete {text context position facts condition result initials}
    (parsed : BooleanFactorAt text context position facts condition result initials) :
    readBooleanFactor text context position facts initials = result := by
  cases parsed with
  | primary noNot inner => simp only [readBooleanFactor, noNot, ↓reduceIte, primary_complete inner]
  | negated opening advanced inner =>
      rw [readBooleanFactor]
      simp [opening, advanced, primary_complete inner]

theorem booleanRelation_complete {text context position facts condition result initials}
    (parsed : BooleanRelationAt text context position facts condition result initials) :
    readBooleanRelation text context position facts initials = result := by
  cases parsed with
  | factor inner nonzero noComparison =>
      simp only [readBooleanRelation, booleanFactor_complete inner, nonzero, noComparison, ↓reduceIte]
  | @comparison position facts leftExpr rightExpr leftResult rightResult left nonzero hasComparison allowed advanced right rightNonzero =>
      have admitted : ¬((comparisonAt text leftResult.after).operator ≠ .eq ∧ (comparisonAt text leftResult.after).operator ≠ .ne) := by
        rcases allowed with equal | unequal
        · exact fun bad => bad.1 equal
        · exact fun bad => bad.2 unequal
      simp only [readBooleanRelation, booleanFactor_complete left, nonzero, hasComparison, admitted,
        advanced, booleanFactor_complete right, rightNonzero, ↓reduceIte, ↓reduceDIte]

theorem relation_complete {text context position facts condition result initials}
    (parsed : RelationAt text context position facts condition result initials) :
    readRelation text context position facts initials = result := by
  cases parsed with
  | booleanNot positive opening inner =>
      rw [readRelation]
      simp [positive, opening, booleanRelation_complete inner]
  | length positive noNot leftPositive left right advanced =>
      rw [readRelation]
      simp [positive, noNot, lengthAt_complete left, leftPositive, lengthAt_complete right, Nat.not_le.mpr advanced]
  | scalars positive noNot noLength leftPositive left right advanced =>
      rw [readRelation]
      simp only [readScalarInFlow, positive, noNot, noLength, ScalarExpression.read_complete left,
        leftPositive, ScalarExpression.read_complete right, Nat.not_le.mpr advanced,
        ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
  | @strings position facts leftExpr rightExpr leftResult rightResult positive noNot noLength noScalar left right ready advanced =>
      have leftEq : readStringInFlow text context position facts initials = leftResult := expressionTail_complete left
      have rightEq : readStringInFlow text context (comparisonAt text leftResult.after).after facts initials = rightResult := expressionTail_complete right
      have operatorAllowed : ¬((comparisonAt text leftResult.after).after = 0 ∨
          ((comparisonAt text leftResult.after).operator ≠ .eq ∧ (comparisonAt text leftResult.after).operator ≠ .ne)) := by
        rcases ready with ⟨_, present, kind, _⟩
        rintro (zero | different)
        · exact present zero
        · rcases kind with equal | unequal
          · exact different.1 equal
          · exact different.2 unequal
      simp only [readRelation, positive, noNot, noLength, noScalar, ne_eq, not_true_eq_false, ↓reduceIte,
        leftEq, ready.1, operatorAllowed, rightEq,
        Nat.not_le.mpr advanced, ready.2.2.2.2.1, ready.2.2.2.2.2.1, ready.2.2.2.2.2.2,
        Bool.not_true, Bool.false_eq_true, or_self, not_false_eq_true, stringResult]
  | character positive noNot noLength noScalar noExpression inner =>
      simp only [readRelation, positive, noNot, noLength, noScalar, noExpression,
        ne_eq, not_true_eq_false, ↓reduceIte]
      rw [characterRelation_complete inner, ite_eq_left (characterRelation_positive inner)]
  | primary positive noNot noLength noScalar noExpression noCharacter inner =>
      simp only [readRelation, positive, noNot, noLength, noScalar, noExpression,
        noCharacter, ne_eq, not_true_eq_false, ↓reduceIte, booleanRelation_complete inner]

theorem chain_complete {text context condition result chained final finalResult incoming initials originalStart}
    (parsed : ChainAt text context condition result chained final finalResult incoming initials originalStart) :
    conditionTail text context result chained incoming initials originalStart = finalResult := by
  cases parsed with
  | done positive done => simp only [conditionTail, positive, done, ↓reduceIte]
  | next scanned => exact scanned

end Silver.Predicate
