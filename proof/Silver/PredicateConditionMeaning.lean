module

public import Silver.PredicateConditionReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

structure ConditionMeaning (context : ParseContext) (facts : Context)
    (condition : Condition) (result : ConditionResult) : Prop where
  grammatical : condition.Grammatical
  readable : condition.Readable context.hasArguments context.names.shape
  checked : condition.checkBounds context.names.shape facts = true
  whenTrue : result.whenTrue = condition.refine context.names.shape facts true
  whenFalse : result.whenFalse = condition.refine context.names.shape facts false

def ChainShape (chained : Option Bool) (condition : Condition) : Prop :=
  match chained with
  | none => condition.isRelation = true
  | some true => condition.isAndHead = true
  | some false => condition.isOrHead = true

theorem chainShape_selected {chained : Option Bool} {condition : Condition} {operator : Bool}
    (shape : ChainShape chained condition)
    (compatible : ¬(chained.isSome = true ∧ chained ≠ some operator)) :
    (if operator then condition.isAndHead else condition.isOrHead) = true := by
  cases chained with
  | none => cases condition <;> cases operator <;> simp_all [ChainShape, Condition.isRelation, Condition.isAndHead, Condition.isOrHead]
  | some prior =>
      have same : prior = operator := by
        by_cases equal : prior = operator
        · exact equal
        · exact False.elim (compatible ⟨rfl, by simpa using equal⟩)
      subst prior
      cases operator <;> exact shape

theorem chainShape_next (left right : Condition) (operator : Bool) :
    ChainShape (some operator) (chainCondition left right operator) := by
  cases operator <;> rfl

theorem ConditionMeaning.parenthesized {context facts condition result}
    (meaning : ConditionMeaning context facts condition result) (after : Nat) :
    ConditionMeaning context facts (.parenthesized condition) {result with after} :=
  ⟨meaning.grammatical, meaning.readable, meaning.checked, meaning.whenTrue, meaning.whenFalse⟩

theorem ConditionMeaning.negated {context facts condition result}
    (meaning : ConditionMeaning context facts condition result) (primary : condition.isPrimary = true) :
    ConditionMeaning context facts (.negated condition) ⟨result.after, result.whenFalse, result.whenTrue⟩ :=
  ⟨⟨primary, meaning.grammatical⟩, meaning.readable, meaning.checked, meaning.whenFalse, meaning.whenTrue⟩

theorem ConditionMeaning.chain {context facts left leftResult right rightResult operator}
    (leftMeaning : ConditionMeaning context facts left leftResult)
    (rightMeaning : ConditionMeaning context (chainContext leftResult operator) right rightResult)
    (head : (if operator then left.isAndHead else left.isOrHead) = true)
    (relation : right.isRelation = true) :
    ConditionMeaning context facts (chainCondition left right operator) (chainJoin leftResult rightResult operator) := by
  cases operator with
  | false =>
      simp only [chainContext, Bool.false_eq_true, ↓reduceIte, leftMeaning.whenFalse] at rightMeaning
      refine ⟨⟨head, relation, leftMeaning.grammatical, rightMeaning.grammatical⟩,
        ⟨leftMeaning.readable, rightMeaning.readable⟩, ?_, ?_, ?_⟩
      · simp only [chainCondition, Bool.false_eq_true, ↓reduceIte, Condition.checkBounds,
          leftMeaning.checked, rightMeaning.checked, Bool.and_self]
      · simp only [chainJoin, chainCondition, Bool.false_eq_true, ↓reduceIte, Condition.refine,
          leftMeaning.whenTrue, rightMeaning.whenTrue]
      · simp only [chainJoin, chainCondition, Bool.false_eq_true, ↓reduceIte, Condition.refine,
          rightMeaning.whenFalse]
  | true =>
      simp only [chainContext, ↓reduceIte, leftMeaning.whenTrue] at rightMeaning
      refine ⟨⟨head, relation, leftMeaning.grammatical, rightMeaning.grammatical⟩,
        ⟨leftMeaning.readable, rightMeaning.readable⟩, ?_, ?_, ?_⟩
      · simp only [chainCondition, ↓reduceIte, Condition.checkBounds,
          leftMeaning.checked, rightMeaning.checked, Bool.and_self]
      · simp only [chainJoin, chainCondition, ↓reduceIte, Condition.refine, rightMeaning.whenTrue]
      · simp only [chainJoin, chainCondition, ↓reduceIte, Condition.refine,
          leftMeaning.whenFalse, rightMeaning.whenFalse, Bool.false_eq_true]

end Silver.Predicate
