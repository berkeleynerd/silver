module

public import Silver.PredicateNativeEquations
public import Silver.PredicateNativeProgress

@[expose] public section

namespace Silver.Predicate.Native
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

abbrev ValidText := Compose.Expressions.ValidText

def takeModel (text : Source) (position : Nat) (token : Token) : Nat :=
  tokenAfter text position token.shell

def chainTokenModel (text : Source) (position : Nat) : Token :=
  if fixedAfter text position "and" true ≠ 0 then .andKeyword
  else if fixedAfter text position "or" true ≠ 0 then .orKeyword
  else .endKeyword

def modelCalls : Calls where
  callAfter := fun text names position operation scalarNames arrays => Compose.callAfter text names position operation scalarNames arrays
  take := takeModel
  skip := skipAt
  nameAfter := Compose.nameAfter
  lookup := lookupName
  scalarLookup := ScalarExpression.lookup
  scalarRead := fun text position names => ScalarExpression.read text position names
  scalarInFlow := fun text context position facts => readScalarInFlow text context.model position facts
  stringInFlow := fun text context position facts => readStringInFlow text context.model position facts
  scalarCondition := fun text context position rightPosition facts left right operator =>
    Predicate.scalarCondition text context.model position rightPosition facts left right operator
  invalidCondition := Predicate.invalidCondition
  integer := IntegerLiteral.read
  expression := fun text position names scalarNames => expressionAt text position names scalarNames
  summary := summaryOf
  bound := Bindings.BindingInfo.bound
  bindingSummary := fun binding => LengthSummary.ofExact binding.bound.summary
  comparison := comparisonAt
  length := fun text context position literal => lengthAt text context.model position literal
  primary := fun text context position facts => readPrimary text context.model position facts
  relation := fun text context position facts => readRelation text context.model position facts
  condition := fun text context position facts => readCondition text context.model position facts
  model := fun text context position facts => readCondition text context.model position facts
  chainToken := chainTokenModel
  chainAfter := fun text position token => Predicate.chainAfter text position token.chain
  tail := fun text context result operator chained => conditionTail text context.model result (chainState operator chained)
  assumeValid := PathFacts.Context.assumeValid
  assumeInvalid := PathFacts.Context.assumeInvalid
  refineBounds := Predicate.refineBounds
  fits := fitsLengthSummary
  refineEqual := refineLengthOverlap
  join := ActiveFlow.join

/-- Replace only already interpreted helper calls. The five mutually recursive
condition functions remain arbitrary and are discharged by source equations. -/
def interpreted (calls : Calls) : Calls :=
  { modelCalls with
    primary := calls.primary
    relation := calls.relation
    condition := calls.condition
    model := calls.model
    tail := calls.tail }

@[simp] theorem takeModel_valid (text : Source) (position : Nat) (token : Token)
    (bounded : position ≤ text.length + 1) : takeModel text position token ≤ text.length + 1 := by
  cases token <;> exact model_fixed_valid text position _ _ bounded

theorem takeModel_progress (text : Source) (position : Nat) (token : Token)
    (bounded : position ≤ text.length + 1) (accepted : takeModel text position token ≠ 0) :
    position < takeModel text position token := by
  cases token <;> exact model_fixed_advances text position _ _ bounded (by decide) accepted

theorem remaining_lt {text : Source} {before after : Nat}
    (bounded : after ≤ text.length + 1) (advanced : before < after) :
    remainingAt text after < remainingAt text before := by
  unfold remainingAt
  omega

theorem model_comparison_equation (text : Source) (position : Nat) :
    modelCalls.comparison text position = comparisonEquation modelCalls text position := by rfl

theorem model_length_equation (text : Source) (context : Context) (position : Nat) (literal : Bool) :
    modelCalls.length text context position literal = lengthEquation modelCalls text context position literal := by rfl

theorem model_chainToken_equation (text : Source) (position : Nat) :
    modelCalls.chainToken text position = chainTokenEquation modelCalls text position := by rfl

theorem chain_cases {operator : Token} (valid : operator.isChain = true) :
    operator = .andKeyword ∨ operator = .orKeyword := by
  cases operator <;> simp_all [Token.isChain]

theorem model_chainAfter_equation (text : Source) (position : Nat) (operator : Token)
    (valid : operator.isChain = true) :
    modelCalls.chainAfter text position operator = chainAfterEquation modelCalls text position operator := by
  rcases chain_cases valid with rfl | rfl <;> rfl

theorem model_primary_equation (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow)
    (bounded : position ≤ text.length + 1) :
    modelCalls.primary text context position facts = primaryEquation modelCalls text context position facts := by
  change readPrimary text context.model position facts = _
  rw [readPrimary]
  unfold primaryEquation
  dsimp only [modelCalls, takeModel, Token.shell, tokenAfter, ShellToken.word, ShellToken.symbol]
  by_cases zero : position = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases found : fixedAfter text position "(" false ≠ 0
    · have advanced := remaining_lt (model_fixed_valid text position "(" false bounded)
        (model_fixed_advances text position "(" false bounded (by decide) found)
      simp [found, advanced]
    · simp only [found, ↓reduceIte]
      simp [Context.model]

theorem model_relation_equation (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow)
    (bounded : position ≤ text.length + 1) :
    modelCalls.relation text context position facts = relationEquation modelCalls text context position facts := by
  change readRelation text context.model position facts = _
  rw [readRelation]
  unfold relationEquation
  dsimp only [modelCalls, takeModel, Token.shell, tokenAfter, ShellToken.word, ShellToken.symbol]
  by_cases zero : position = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    by_cases found : fixedAfter text position "not" true ≠ 0
    · have advanced := remaining_lt (model_fixed_valid text position "not" true bounded)
        (model_fixed_advances text position "not" true bounded (by decide) found)
      simp [found, advanced]
    · simp only [found, ↓reduceIte]
      simp only [beq_iff_eq, Context.model, readScalarInFlow, readStringInFlow]
      by_cases equal : (comparisonAt text
          (readStringInFlow text context.model position facts).after).operator = .eq
      · simp only [readStringInFlow, Context.model] at equal
        simp only [equal, ↓reduceIte]
        rfl
      · simp only [readStringInFlow, Context.model] at equal
        simp only [equal, ↓reduceIte]
        rfl

theorem chainAfter_progress (text : Source) (position : Nat) (operator : Bool)
    (bounded : position ≤ text.length + 1) (accepted : Predicate.chainAfter text position operator ≠ 0) :
    position < Predicate.chainAfter text position operator := by
  have firstPositive := Compose.fixedAfter_nonzero accepted
  have first := model_fixed_advances text position (if operator then "and" else "or") true bounded
    (by cases operator <;> decide) firstPositive
  have last := model_fixed_advances text _ (if operator then "then" else "else") true
    (model_fixed_valid text position _ _ bounded) (by cases operator <;> decide) accepted
  exact Nat.lt_trans first last

def tailStep (text : Source) (context : ParseContext) (result : ConditionResult)
    (chained : Option Bool) : ConditionResult :=
  if result.after = 0 then invalidCondition result.whenTrue else
  match chainOperator text result.after with
  | none => result
  | some operator =>
      if chained.isSome && decide (chained ≠ some operator) then invalidCondition result.whenTrue else
      let after := Predicate.chainAfter text result.after operator
      if after = 0 then invalidCondition result.whenTrue else
      let right := readRelation text context after (chainContext result operator)
      if right.after = 0 then invalidCondition result.whenTrue else
      conditionTail text context (chainJoin result right operator) (some operator)

theorem tail_unfold (text : Source) (context : ParseContext) (result : ConditionResult)
    (chained : Option Bool) (tv : ValidText text) (nv : ValidNames text context.names)
    (bounded : result.after ≤ text.length + 1) :
    conditionTail text context result chained = tailStep text context result chained := by
  rw [conditionTail]
  unfold tailStep
  by_cases zero : result.after = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    cases selected : chainOperator text result.after with
    | none => rfl
    | some operator =>
      change (if (chained.isSome && decide (chained ≠ some operator)) then _ else _) =
        (if (chained.isSome && decide (chained ≠ some operator)) then _ else _)
      by_cases wrong : (chained.isSome && decide (chained ≠ some operator)) = true
      · simp only [wrong, ↓reduceIte]
      · simp only [wrong]
        by_cases afterZero : Predicate.chainAfter text result.after operator = 0
        · simp [afterZero]
        · have afterBound := Predicate.chainAfter_bound text result.after operator bounded
          have progress := chainAfter_progress text result.after operator bounded afterZero
          have advanced := remaining_lt afterBound progress
          simp only [afterZero, advanced, ↓reduceIte, ↓reduceDIte]
          let right := readRelation text context (Predicate.chainAfter text result.after operator) (chainContext result operator)
          by_cases rightZero : right.after = 0
          · simp only [show (readRelation text context (Predicate.chainAfter text result.after operator) (chainContext result operator)).after = 0 from rightZero, ↓reduceIte]
          · have rightBound := relation_bound text context (Predicate.chainAfter text result.after operator) (chainContext result operator) tv nv afterBound
            have rightProgress := relation_progress text context _ _ tv nv afterBound rightZero
            have nextAdvanced : remainingAt text (chainJoin result right operator).after < remainingAt text result.after := by
              have nextAfter : (chainJoin result right operator).after = right.after := by cases operator <;> rfl
              rw [nextAfter]
              exact remaining_lt rightBound (Nat.lt_trans progress rightProgress)
            dsimp only [right] at nextAdvanced
            simp only [show (readRelation text context (Predicate.chainAfter text result.after operator) (chainContext result operator)).after ≠ 0 from rightZero, nextAdvanced, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte]

theorem model_tail_equation (text : Source) (context : Context) (result : ConditionResult)
    (operator : Token) (chained : Bool) (tv : ValidText text) (cv : ValidContext text context)
    (bounded : result.after ≤ text.length + 1) (valid : operator.isChain = true) :
    modelCalls.tail text context result operator chained = tailEquation modelCalls text context result operator chained := by
  change conditionTail text context.model result (chainState operator chained) = _
  rw [tail_unfold text context.model result _ tv cv.1 bounded]
  unfold tailStep tailEquation
  dsimp only [modelCalls, chainTokenModel]
  by_cases zero : result.after = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    unfold chainOperator
    by_cases andFound : fixedAfter text result.after "and" true ≠ 0
    · rw [ite_eq_left andFound, ite_eq_left andFound]
      rcases chain_cases valid with rfl | rfl <;> cases chained <;>
        simp [Token.isChain, Token.chain, chainState, chainContext, chainJoin] <;> rfl
    · rw [ite_eq_right andFound, ite_eq_right andFound]
      by_cases orFound : fixedAfter text result.after "or" true ≠ 0
      · rw [ite_eq_left orFound, ite_eq_left orFound]
        rcases chain_cases valid with rfl | rfl <;> cases chained <;>
          simp [Token.isChain, Token.chain, chainState, chainContext, chainJoin] <;> rfl
      · simp [orFound, Token.isChain]

theorem condition_unfold (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (tv : ValidText text) (nv : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    readCondition text context position facts =
      (let result := readRelation text context position facts
       if result.after = 0 then invalidCondition facts else
       let final := conditionTail text context result none
       if final.after = 0 then invalidCondition facts else final) := by
  rw [readCondition]
  by_cases zero : (readRelation text context position facts).after = 0
  · simp only [zero, ↓reduceIte]
  · have advanced := remaining_lt (relation_bound text context position facts tv nv bounded)
      (relation_progress text context position facts tv nv bounded zero)
    simp only [zero, advanced, ↓reduceIte, ↓reduceDIte]

theorem model_model_equation (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow)
    (tv : ValidText text) (cv : ValidContext text context) (bounded : position ≤ text.length + 1) :
    modelCalls.model text context position facts = modelEquation modelCalls text context position facts := by
  exact condition_unfold text context.model position facts tv cv.1 bounded

end Silver.Predicate.Native
