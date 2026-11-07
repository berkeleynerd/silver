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

def ChainKind.predicate : ChainKind → Predicate.ChainKind
  | .noChain | .shortAnd => .shortAnd
  | .shortOr => .shortOr
  | .eagerAnd => .eagerAnd
  | .eagerOr => .eagerOr
  | .eagerXor => .eagerXor

def chainState (operator : ChainKind) (chained : Bool) : Option Predicate.ChainKind :=
  if chained then some operator.predicate else none

def chainTokenModel (text : Source) (position : Nat) : ChainKind :=
  if fixedAfter text position "and" true ≠ 0 then
    if fixedAfter text (fixedAfter text position "and" true) "then" true ≠ 0 then .shortAnd else .eagerAnd
  else if fixedAfter text position "or" true ≠ 0 then
    if fixedAfter text (fixedAfter text position "or" true) "else" true ≠ 0 then .shortOr else .eagerOr
  else if fixedAfter text position "xor" true ≠ 0 then .eagerXor
  else .noChain

def chainAfterModel (text : Source) (position : Nat) (operator : ChainKind) : Nat :=
  if operator = .noChain then 0 else Predicate.chainAfter text position operator.predicate

def modelCalls : Calls where
  readingNames := fun context facts => context.model.readingNames facts
  characterAt := fun text position names scalarNames arrays initials elaborating =>
    Compose.characterAt text position names scalarNames arrays initials elaborating
  characterCondition := fun text context position facts initials => Predicate.characterCondition text context.model position facts initials
  xorFree := Predicate.xorFree
  callAfter := fun text names position operation scalarNames arrays hidden booleans => Compose.callAfter text names position operation scalarNames arrays hidden booleans
  equalName := Named.equalName
  nameIs := fun text first after word => Named.nameIs text first after (word.toList.map Char.toNat)
  arrayLookup := ArrayBindings.lookup
  arrayContains := ArrayBindings.contains
  scalarIndex := fun text position names first after => ScalarExpression.read text position names first after
  booleanArray := fun text context position facts => booleanArrayAfter text context.model position facts
  booleanLookup := BooleanBindings.lookup
  booleanAtom := fun text context position => booleanAtomAfter text context.model position
  booleanFactor := fun text context position facts initials => readBooleanFactor text context.model position facts initials
  booleanRelation := fun text context position facts initials => readBooleanRelation text context.model position facts initials
  take := takeModel
  skip := skipAt
  nameAfter := Compose.nameAfter
  lookup := lookupName
  scalarLookup := ScalarExpression.lookup
  scalarRead := fun text position names => ScalarExpression.read text position names
  scalarInFlow := fun text context position facts initials => readScalarInFlow text context.model position facts (initials := initials)
  stringInFlow := fun text context position facts initials => readStringInFlow text context.model position facts initials
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
  primary := fun text context position facts initials => readPrimary text context.model position facts initials
  relation := fun text context position facts initials => readRelation text context.model position facts initials
  condition := fun text context position facts initials => readCondition text context.model position facts initials
  model := fun text context position facts initials => readCondition text context.model position facts initials
  chainToken := chainTokenModel
  chainAfter := chainAfterModel
  tail := fun text context result operator chained initials incoming originalStart => conditionTail text context.model result (chainState operator chained) incoming initials originalStart
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
    booleanFactor := calls.booleanFactor
    booleanRelation := calls.booleanRelation
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

theorem model_character_equation (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    modelCalls.characterCondition text context position facts initials = characterEquation modelCalls text context position facts initials := rfl

theorem model_length_equation (text : Source) (context : Context) (position : Nat) (literal : Bool) :
    modelCalls.length text context position literal = lengthEquation modelCalls text context position literal := by rfl

theorem model_chainToken_equation (text : Source) (position : Nat) :
    modelCalls.chainToken text position = chainTokenEquation modelCalls text position := by rfl

theorem chain_cases {operator : ChainKind} (valid : operator.isChain = true) :
    operator = .shortAnd ∨ operator = .shortOr ∨ operator = .eagerAnd ∨ operator = .eagerOr ∨ operator = .eagerXor := by
  cases operator <;> simp_all [ChainKind.isChain]

theorem model_chainAfter_equation (text : Source) (position : Nat) (operator : ChainKind)
    (valid : operator.isChain = true) :
    modelCalls.chainAfter text position operator = chainAfterEquation modelCalls text position operator := by
  cases operator <;> rfl

theorem model_booleanArray_equation (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) :
    modelCalls.booleanArray text context position facts = booleanArrayEquation modelCalls text context position facts := by
  rfl

theorem model_booleanAtom_equation (text : Source) (context : Context) (position : Nat) :
    modelCalls.booleanAtom text context position = booleanAtomEquation modelCalls text context position := rfl

theorem model_primary_equation (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials)
    (bounded : position ≤ text.length + 1) :
    modelCalls.primary text context position facts initials = primaryEquation modelCalls text context position facts initials := by
  change readPrimary text context.model position facts initials = _
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
      simp [Context.model, ParseContext.validityHidden]

theorem model_booleanFactor_equation (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) (bounded : position ≤ text.length + 1) :
    modelCalls.booleanFactor text context position facts initials =
      booleanFactorEquation modelCalls text context position facts initials := by
  change readBooleanFactor text context.model position facts initials = _
  rw [readBooleanFactor]
  unfold booleanFactorEquation
  dsimp only [modelCalls, takeModel, Token.shell, tokenAfter, ShellToken.word, ShellToken.symbol]
  by_cases absent : fixedAfter text position "not" true = 0
  · simp [absent]
  · have advanced := remaining_lt (model_fixed_valid text position "not" true bounded)
      (model_fixed_advances text position "not" true bounded (by decide) absent)
    simp [absent, advanced]

theorem comparison_progress (text : Source) (position : Nat)
    (bounded : position ≤ text.length + 1) (accepted : (comparisonAt text position).after ≠ 0) :
    position < (comparisonAt text position).after := by
  unfold comparisonAt at accepted ⊢
  split <;> first | exact model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split
  · exact model_fixed_advances text position _ _ bounded (by decide) (by assumption)
  · simp_all

theorem model_booleanRelation_equation (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials)
    (tv : ValidText text) (nv : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    modelCalls.booleanRelation text context position facts initials =
      booleanRelationEquation modelCalls text context position facts initials := by
  change readBooleanRelation text context.model position facts initials = _
  rw [readBooleanRelation]
  unfold booleanRelationEquation
  dsimp only [modelCalls]
  let left := readBooleanFactor text context.model position facts initials
  let operator := comparisonAt text left.after
  by_cases leftZero : left.after = 0
  · simp only [show (readBooleanFactor text context.model position facts initials).after = 0 from leftZero, ↓reduceIte]
  · by_cases operatorZero : operator.after = 0
    · simp only [show (readBooleanFactor text context.model position facts initials).after ≠ 0 from leftZero,
        show (comparisonAt text (readBooleanFactor text context.model position facts initials).after).after = 0 from operatorZero, ↓reduceIte]
    · have leftBound := booleanFactor_bound text context.model position facts tv nv bounded (initials := initials)
      have leftProgress := booleanFactor_progress text context.model position facts tv nv bounded leftZero
      have operatorProgress : left.after < operator.after := comparison_progress text left.after leftBound operatorZero
      have advanced := remaining_lt (comparison_bound text left.after leftBound) (Nat.lt_trans leftProgress operatorProgress)
      simp only [show (readBooleanFactor text context.model position facts initials).after ≠ 0 from leftZero,
        show (comparisonAt text (readBooleanFactor text context.model position facts initials).after).after ≠ 0 from operatorZero,
        show remainingAt text (comparisonAt text (readBooleanFactor text context.model position facts initials).after).after < remainingAt text position from advanced,
        ↓reduceIte, ↓reduceDIte]

theorem model_relation_equation (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) (_bounded : position ≤ text.length + 1) :
    modelCalls.relation text context position facts initials = relationEquation modelCalls text context position facts initials := by
  change readRelation text context.model position facts initials = _
  rw [readRelation]
  unfold relationEquation
  dsimp only [modelCalls, takeModel, Token.shell, tokenAfter, ShellToken.word, ShellToken.symbol]
  by_cases equal : (comparisonAt text (readStringInFlow text context.model position facts initials).after).operator = .eq
  · simp only [equal, beq_self_eq_true, ↓reduceIte]
    rfl
  · simp only [beq_iff_eq, equal, ↓reduceIte]
    rfl

theorem chainAfter_progress (text : Source) (position : Nat) (operator : Predicate.ChainKind)
    (bounded : position ≤ text.length + 1) (accepted : Predicate.chainAfter text position operator ≠ 0) :
    position < Predicate.chainAfter text position operator := by
  cases operator with
  | shortAnd | shortOr =>
    have firstPositive := (model_fixed_input_nonzero _ _ _ _) accepted
    have first := model_fixed_advances text position _ true bounded (by decide) firstPositive
    have last := model_fixed_advances text _ _ true
      (model_fixed_valid text position _ _ bounded) (by decide) accepted
    exact Nat.lt_trans first last
  | eagerAnd | eagerOr | eagerXor =>
    exact model_fixed_advances text position _ true bounded (by decide) accepted

def tailStep (text : Source) (context : ParseContext) (result : ConditionResult)
    (chained : Option Predicate.ChainKind) (incoming : ActiveFlow)
    (initials : ArrayBindings.Initials) (originalStart : Nat) : ConditionResult :=
  if result.after = 0 then invalidCondition result.whenTrue else
  match chainOperator text result.after with
  | none => result
  | some operator =>
      if (chained.isSome && decide (chained ≠ some operator)) ||
          (decide (operator = .eagerXor) && !xorFree text originalStart result.after) then invalidCondition result.whenTrue else
      let after := Predicate.chainAfter text result.after operator
      if after = 0 then invalidCondition result.whenTrue else
      let right := readRelation text context after (chainContext result operator incoming) initials
      if right.after = 0 ∨ (operator = .eagerXor ∧ xorFree text after right.after = false) then invalidCondition result.whenTrue else
      conditionTail text context (chainJoin result right operator incoming) (some operator) incoming initials originalStart

theorem tail_unfold (text : Source) (context : ParseContext) (result : ConditionResult)
    (chained : Option Predicate.ChainKind) (incoming : ActiveFlow)
    (initials : ArrayBindings.Initials) (originalStart : Nat) (tv : ValidText text) (nv : ValidNames text context.names)
    (bounded : result.after ≤ text.length + 1) :
    conditionTail text context result chained incoming initials originalStart = tailStep text context result chained incoming initials originalStart := by
  rw [conditionTail]
  unfold tailStep
  by_cases zero : result.after = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    cases selected : chainOperator text result.after with
    | none => rfl
    | some operator =>
      change (if ((chained.isSome && decide (chained ≠ some operator)) ||
          (decide (operator = .eagerXor) && !xorFree text originalStart result.after)) then _ else _) =
        (if ((chained.isSome && decide (chained ≠ some operator)) ||
          (decide (operator = .eagerXor) && !xorFree text originalStart result.after)) then _ else _)
      by_cases wrong : ((chained.isSome && decide (chained ≠ some operator)) ||
          (decide (operator = .eagerXor) && !xorFree text originalStart result.after)) = true
      · simp only [wrong, ↓reduceIte]
      · simp only [wrong]
        by_cases afterZero : Predicate.chainAfter text result.after operator = 0
        · simp [afterZero]
        · have afterBound := Predicate.chainAfter_bound text result.after operator bounded
          have progress := chainAfter_progress text result.after operator bounded afterZero
          have advanced := remaining_lt afterBound progress
          simp only [afterZero, advanced, ↓reduceIte, ↓reduceDIte]
          let right := readRelation text context (Predicate.chainAfter text result.after operator) (chainContext result operator incoming) initials
          by_cases rightZero : right.after = 0
          · simp [show (readRelation text context (Predicate.chainAfter text result.after operator) (chainContext result operator incoming) initials).after = 0 from rightZero]
          · have rightBound := relation_bound text context (Predicate.chainAfter text result.after operator) (chainContext result operator incoming) tv nv afterBound (initials := initials)
            have rightProgress := relation_progress text context _ _ tv nv afterBound rightZero
            have nextAdvanced : remainingAt text (chainJoin result right operator incoming).after < remainingAt text result.after := by
              have nextAfter : (chainJoin result right operator incoming).after = right.after := by cases operator <;> rfl
              rw [nextAfter]
              exact remaining_lt rightBound (Nat.lt_trans progress rightProgress)
            dsimp only [right] at nextAdvanced
            simp only [show (readRelation text context (Predicate.chainAfter text result.after operator) (chainContext result operator incoming) initials).after ≠ 0 from rightZero, nextAdvanced, Bool.false_eq_true, ↓reduceIte, ↓reduceDIte]

theorem model_tail_equation (text : Source) (context : Context) (result : ConditionResult)
    (operator : ChainKind) (chained : Bool) (initials : ArrayBindings.Initials)
    (incoming : ActiveFlow) (originalStart : Nat) (tv : ValidText text) (cv : ValidContext text context)
    (bounded : result.after ≤ text.length + 1) (valid : operator.isChain = true) :
    modelCalls.tail text context result operator chained initials incoming originalStart =
      tailEquation modelCalls text context result operator chained initials incoming originalStart := by
  change conditionTail text context.model result (chainState operator chained) incoming initials originalStart = _
  rw [tail_unfold text context.model result _ incoming initials originalStart tv cv.1 bounded]
  unfold tailStep tailEquation
  dsimp only [modelCalls, chainTokenModel]
  by_cases zero : result.after = 0
  · simp [zero]
  · simp only [zero, ↓reduceIte]
    unfold chainOperator
    by_cases andFound : fixedAfter text result.after "and" true ≠ 0
    · rw [ite_eq_left andFound, ite_eq_left andFound]
      by_cases short : fixedAfter text (fixedAfter text result.after "and" true) "then" true ≠ 0 <;>
        cases operator <;> cases chained <;>
        simp_all [ChainKind.isChain, ChainKind.predicate, chainAfterModel, chainState, chainContext, chainJoin]
    · rw [ite_eq_right andFound, ite_eq_right andFound]
      by_cases orFound : fixedAfter text result.after "or" true ≠ 0
      · rw [ite_eq_left orFound, ite_eq_left orFound]
        by_cases short : fixedAfter text (fixedAfter text result.after "or" true) "else" true ≠ 0 <;>
            cases operator <;> cases chained <;>
          simp_all [ChainKind.isChain, ChainKind.predicate, chainAfterModel, chainState, chainContext, chainJoin]
      · rw [ite_eq_right orFound, ite_eq_right orFound]
        by_cases xorFound : fixedAfter text result.after "xor" true ≠ 0 <;>
          cases operator <;> cases chained <;>
          simp_all [ChainKind.isChain, ChainKind.predicate, chainAfterModel, chainState, chainContext, chainJoin]

theorem condition_unfold (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials)
    (tv : ValidText text) (nv : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    readCondition text context position facts initials =
      (let result := readRelation text context position facts initials
       if result.after = 0 then invalidCondition facts else
       let final := conditionTail text context result none facts initials position
       if final.after = 0 then invalidCondition facts else final) := by
  rw [readCondition]
  by_cases zero : (readRelation text context position facts initials).after = 0
  · simp only [zero, ↓reduceIte]
  · have advanced := remaining_lt (relation_bound text context position facts tv nv bounded)
      (relation_progress text context position facts tv nv bounded zero)
    simp only [zero, advanced, ↓reduceIte, ↓reduceDIte]

theorem model_model_equation (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials)
    (tv : ValidText text) (cv : ValidContext text context) (bounded : position ≤ text.length + 1) :
    modelCalls.model text context position facts initials = modelEquation modelCalls text context position facts initials := by
  exact condition_unfold text context.model position facts initials tv cv.1 bounded

end Silver.Predicate.Native
