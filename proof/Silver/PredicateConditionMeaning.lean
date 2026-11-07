module

public import Silver.PredicateConditionReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

structure ConditionMeaning (context : ParseContext) (facts : ActiveFlow)
    (condition : Condition) (result : ConditionResult) (initials : ArrayBindings.Initials := []) : Prop where
  grammatical : condition.Grammatical
  readable : condition.Readable context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
  checked : condition.checkBounds context.names.shape context.analysis (context.flow facts initials)
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = true
  whenTrue : (context.flow result.whenTrue initials) = condition.refine context.names.shape context.analysis (context.flow facts initials) true
  whenFalse : (context.flow result.whenFalse initials) = condition.refine context.names.shape context.analysis (context.flow facts initials) false

def ChainKind.head (operator : ChainKind) (condition : Condition) : Bool :=
  match operator with
  | .shortAnd => condition.isAndHead
  | .shortOr => condition.isOrHead
  | .eagerAnd => condition.isEagerHead .and
  | .eagerOr => condition.isEagerHead .or
  | .eagerXor => condition.isEagerHead .xor

def ChainShape (chained : Option ChainKind) (condition : Condition) : Prop :=
  match chained with
  | none => condition.isRelation = true
  | some operator => operator.head condition = true

theorem chainShape_selected {chained : Option ChainKind} {condition : Condition} {operator : ChainKind}
    (shape : ChainShape chained condition)
    (compatible : ¬(chained.isSome = true ∧ chained ≠ some operator)) :
    operator.head condition = true := by
  cases chained with
  | none => cases condition <;> cases operator <;>
      simp_all [ChainShape, ChainKind.head, Condition.isRelation, Condition.isAndHead,
        Condition.isOrHead, Condition.isEagerHead]
  | some prior =>
      have same : prior = operator := by
        by_cases equal : prior = operator
        · exact equal
        · exact False.elim (compatible ⟨rfl, by simpa using equal⟩)
      subst prior
      exact shape

theorem chainShape_next (left right : Condition) (operator : ChainKind) :
    ChainShape (some operator) (chainCondition left right operator) := by
  cases operator <;> rfl

theorem ConditionMeaning.parenthesized {context facts condition result initials}
    (meaning : ConditionMeaning context facts condition result initials) (after : Nat) :
    ConditionMeaning context facts (.parenthesized condition) {result with after} initials :=
  ⟨meaning.grammatical, meaning.readable, meaning.checked, meaning.whenTrue, meaning.whenFalse⟩

theorem ConditionMeaning.negated {context facts condition result initials}
    (meaning : ConditionMeaning context facts condition result initials) (primary : condition.isPrimary = true) :
    ConditionMeaning context facts (.negated condition) ⟨result.after, result.whenFalse, result.whenTrue⟩ initials :=
  ⟨⟨primary, meaning.grammatical⟩, meaning.readable, meaning.checked, meaning.whenFalse, meaning.whenTrue⟩

theorem ConditionMeaning.booleanCompare {context facts left leftResult right rightResult initials}
    (leftMeaning : ConditionMeaning context facts left leftResult initials)
    (rightMeaning : ConditionMeaning context facts right rightResult initials)
    (leftFactor : left.isFactor = true) (rightFactor : right.isFactor = true) (unequal : Bool) :
    ConditionMeaning context facts (.booleanCompare unequal left right) ⟨rightResult.after, facts, facts⟩ initials := by
  refine ⟨⟨leftFactor, rightFactor, leftMeaning.grammatical, rightMeaning.grammatical⟩,
    ⟨leftMeaning.readable, rightMeaning.readable⟩, ?_, rfl, rfl⟩
  simp only [Condition.checkBounds, leftMeaning.checked, rightMeaning.checked, Bool.and_self]

theorem ConditionMeaning.chain {context facts left leftResult right rightResult operator initials}
    (leftMeaning : ConditionMeaning context facts left leftResult initials)
    (rightMeaning : ConditionMeaning context (chainContext leftResult operator facts) right rightResult initials)
    (head : operator.head left = true) (relation : right.isRelation = true) :
    ConditionMeaning context facts (chainCondition left right operator)
      (chainJoin leftResult rightResult operator facts) initials := by
  have checkedRight := rightMeaning.checked
  have trueRight := rightMeaning.whenTrue
  have falseRight := rightMeaning.whenFalse
  cases operator with
  | shortAnd =>
      simp only [chainContext, leftMeaning.whenTrue] at checkedRight trueRight falseRight
      refine ⟨⟨head, relation, leftMeaning.grammatical, rightMeaning.grammatical⟩,
        ⟨leftMeaning.readable, rightMeaning.readable⟩, ?_, ?_, ?_⟩
      · simp only [chainCondition, Condition.checkBounds, leftMeaning.checked, checkedRight, Bool.and_self]
      · simp only [chainJoin, chainCondition, Condition.refine, trueRight, ↓reduceIte]
      · simp only [chainJoin, chainCondition, Condition.refine, ParseContext.flow_join,
          leftMeaning.whenFalse, falseRight, Bool.false_eq_true, ↓reduceIte]
  | shortOr =>
      simp only [chainContext, leftMeaning.whenFalse] at checkedRight trueRight falseRight
      refine ⟨⟨head, relation, leftMeaning.grammatical, rightMeaning.grammatical⟩,
        ⟨leftMeaning.readable, rightMeaning.readable⟩, ?_, ?_, ?_⟩
      · simp only [chainCondition, Condition.checkBounds, leftMeaning.checked, checkedRight, Bool.and_self]
      · simp only [chainJoin, chainCondition, Condition.refine, ParseContext.flow_join,
          leftMeaning.whenTrue, trueRight, ↓reduceIte]
      · simp only [chainJoin, chainCondition, Condition.refine, falseRight, Bool.false_eq_true, ↓reduceIte]
  | eagerAnd | eagerOr | eagerXor =>
      simp only [chainContext] at checkedRight
      refine ⟨⟨head, relation, leftMeaning.grammatical, rightMeaning.grammatical⟩,
        ⟨leftMeaning.readable, rightMeaning.readable⟩, ?_, rfl, rfl⟩
      simp only [chainCondition, Condition.checkBounds, leftMeaning.checked, checkedRight, Bool.and_self]

end Silver.Predicate
