module

public import Silver.PredicateNativePrecedence

@[expose] public section

namespace Silver.Predicate.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure Inputs where
  text : Source := []
  context : Context := { names := [], dynamicFirst := 0, dynamicAfter := 0 }
  position : Nat := 0
  facts : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  value : Compose.ExpressionResult := Compose.invalidExpression
  binding : Bindings.BindingInfo := {}
  result : ConditionResult := invalidCondition ⟨PathFacts.Context.empty, []⟩
  operator : ChainKind := .shortAnd
  initials : ArrayBindings.Initials := []
  originalStart : Nat := 0
  incoming : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  literal : Bool := false
  chained : Bool := false

def Inputs.locals (inputs : Inputs) : Locals
  | .source, "text" => inputs.text
  | .context, "context" => inputs.context
  | .number, "position" => inputs.position
  | .facts, "facts" => inputs.facts
  | .result, "value" => inputs.value
  | .binding, "value" => inputs.binding
  | .condition, "result" => inputs.result
  | .chain, "operator" => inputs.operator
  | .initials, "initials" => inputs.initials
  | .number, "original_start" => inputs.originalStart
  | .facts, "incoming" => inputs.incoming
  | .truth, "literal" => inputs.literal
  | .truth, "chained" => inputs.chained
  | ty, _ => ty.default

def comparisonEquation (calls : Calls) (text : Source) (position : Nat) : ComparisonResult :=
  if calls.take text position .notEqual ≠ 0 then ⟨calls.take text position .notEqual, .ne⟩
  else if calls.take text position .lessEqual ≠ 0 then ⟨calls.take text position .lessEqual, .le⟩
  else if calls.take text position .greaterEqual ≠ 0 then ⟨calls.take text position .greaterEqual, .ge⟩
  else if calls.take text position .equal ≠ 0 then ⟨calls.take text position .equal, .eq⟩
  else if calls.take text position .less ≠ 0 then ⟨calls.take text position .less, .lt⟩
  else if calls.take text position .greater ≠ 0 then ⟨calls.take text position .greater, .gt⟩
  else ⟨0, .eq⟩

def lengthEquation (calls : Calls) (text : Source) (context : Context) (position : Nat) (literal : Bool) : LengthResult :=
  let first := calls.skip text position
  let after := calls.nameAfter text first
  let index := calls.lookup text context.names first after
  let number := calls.integer text first
  if literal && decide (number.after ≠ 0) then ⟨number.after, .fixed number.value⟩
  else if index = 0 ∨ ((context.names.get index).getD {}).isCharacter ∨ calls.scalarLookup text context.scalarNames first after ≠ 0 then ⟨0, .fixed 0⟩
  else ⟨calls.take text (calls.take text after .apostrophe) .lengthName,
    calls.bound ((context.names.get index).getD {})⟩

def booleanAtomEquation (calls : Calls) (text : Source) (context : Context) (position : Nat) : Nat :=
  let first := calls.skip text position
  let after := calls.nameAfter text first
  if first = 0 ∨ after ≤ first ∨
      (context.maskFirst ≠ 0 ∧ calls.equalName text context.maskFirst context.maskAfter first after) ∨
      calls.scalarLookup text context.scalarNames first after ≠ 0 ∨
      calls.lookup text context.names first after ≠ 0 ∨
      calls.arrayLookup text context.arrayNames first after ≠ 0 then 0
  else if calls.booleanLookup text context.booleanNames first after ≠ 0 then after
  else if (calls.nameIs text first after "true" && !context.trueHidden) ||
      (calls.nameIs text first after "false" && !context.falseHidden) then after else 0

def primaryEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : ConditionResult :=
  if position = 0 then calls.invalidCondition facts else
  let after := calls.take text position .leftParenthesis
  if after ≠ 0 then
    let result := calls.model text context after facts initials
    let close := calls.take text result.after .rightParenthesis
    if close = 0 then calls.invalidCondition facts else {result with after := close}
  else if calls.booleanAtom text context position ≠ 0 then
    ⟨calls.booleanAtom text context position, facts, facts⟩
  else if context.dynamicFirst = 0 then calls.invalidCondition facts
  else
    let afterCall := calls.callAfter text context.names position .validity context.scalarNames context.arrayNames
      (context.subtypeHiding.get .validity ||
        (decide (context.maskFirst ≠ 0) && calls.nameIs text context.maskFirst context.maskAfter "input_is_valid"))
      context.booleanNames
    if afterCall = 0 then calls.invalidCondition facts else
      ⟨afterCall, {facts with path := calls.assumeValid facts.path},
        {facts with path := calls.assumeInvalid facts.path}⟩

def booleanFactorEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : ConditionResult :=
  let after := calls.take text position .notKeyword
  if after = 0 then calls.primary text context position facts initials else
  let result := calls.primary text context after facts initials
  ⟨result.after, result.whenFalse, result.whenTrue⟩

def booleanRelationEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : ConditionResult :=
  let left := calls.booleanFactor text context position facts initials
  let operator := calls.comparison text left.after
  if left.after = 0 then calls.invalidCondition facts
  else if operator.after = 0 then left
  else if operator.operator ≠ .eq ∧ operator.operator ≠ .ne then calls.invalidCondition facts
  else
    let right := calls.booleanFactor text context operator.after facts initials
    if right.after = 0 then calls.invalidCondition facts else ⟨right.after, facts, facts⟩

def characterEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : ConditionResult :=
  let overlay := calls.readingNames context facts
  let left := calls.characterAt text position context.names overlay context.arrayNames initials context.elaborating
  let operator := calls.comparison text left.after
  let right := calls.characterAt text operator.after context.names overlay context.arrayNames initials context.elaborating
  if left.after = 0 ∨ operator.after = 0 ∨ right.after ≤ position ∨ !(left.nonliteralSeen || right.nonliteralSeen)
  then invalidCondition facts else ⟨right.after, facts, facts⟩

def relationEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : ConditionResult :=
  if position = 0 then calls.invalidCondition facts else
  let after := calls.take text position .notKeyword
  let leftLength := calls.length text context position false
  let leftScalar := calls.scalarInFlow text context position facts initials
  if after ≠ 0 then calls.booleanRelation text context position facts initials
  else if leftLength.after ≠ 0 then
    let operator := calls.comparison text leftLength.after
    let rightLength := calls.length text context operator.after true
    if rightLength.after ≤ position then calls.invalidCondition facts
    else ⟨rightLength.after,
      {facts with path := calls.refineBounds facts.path operator.operator leftLength.value rightLength.value true},
      {facts with path := calls.refineBounds facts.path operator.operator leftLength.value rightLength.value false}⟩
  else if leftScalar.after ≠ 0 then
    let operator := calls.comparison text leftScalar.after
    let rightScalar := calls.scalarInFlow text context operator.after facts initials
    if rightScalar.after ≤ position then calls.invalidCondition facts
    else calls.scalarCondition text context position operator.after facts leftScalar rightScalar operator.operator
  else
    let left := calls.stringInFlow text context position facts initials
    if left.after ≠ 0 then
      let operator := calls.comparison text left.after
      if operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne) then calls.invalidCondition facts
      else
        let right := calls.stringInFlow text context operator.after facts initials
        if right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
            !calls.fits facts.path (calls.summary left) ∨ !calls.fits facts.path (calls.summary right)
        then calls.invalidCondition facts
        else
          let equalFacts := calls.refineEqual facts.path (calls.summary left) (calls.summary right)
          ⟨right.after, {facts with path := if operator.operator = .eq then equalFacts else facts.path},
            {facts with path := if operator.operator = .eq then facts.path else equalFacts}⟩
    else
      let characterResult := calls.characterCondition text context position facts initials
      if characterResult.after ≠ 0 then characterResult else calls.booleanRelation text context position facts initials

def chainTokenEquation (calls : Calls) (text : Source) (position : Nat) : ChainKind :=
  if calls.take text position .andKeyword ≠ 0 then
    if calls.take text (calls.take text position .andKeyword) .thenKeyword ≠ 0 then .shortAnd else .eagerAnd
  else if calls.take text position .orKeyword ≠ 0 then
    if calls.take text (calls.take text position .orKeyword) .elseKeyword ≠ 0 then .shortOr else .eagerOr
  else if calls.take text position .xorKeyword ≠ 0 then .eagerXor
  else .noChain

def chainAfterEquation (calls : Calls) (text : Source) (position : Nat) (operator : ChainKind) : Nat :=
  match operator with
  | .noChain => 0
  | .shortAnd => calls.take text (calls.take text position .andKeyword) .thenKeyword
  | .shortOr => calls.take text (calls.take text position .orKeyword) .elseKeyword
  | .eagerAnd => calls.take text position .andKeyword
  | .eagerOr => calls.take text position .orKeyword
  | .eagerXor => calls.take text position .xorKeyword

def tailEquation (calls : Calls) (text : Source) (context : Context) (result : ConditionResult)
    (operator : ChainKind) (chained : Bool) (initials : ArrayBindings.Initials) (incoming : ActiveFlow) (originalStart : Nat) : ConditionResult :=
  if result.after = 0 then calls.invalidCondition result.whenTrue else
  let selected := calls.chainToken text result.after
  if selected = .noChain then result
  else if (chained && decide (operator ≠ selected)) ||
      (decide (selected = .eagerXor) && !calls.xorFree text originalStart result.after) then calls.invalidCondition result.whenTrue
  else
    let after := calls.chainAfter text result.after selected
    if after = 0 then calls.invalidCondition result.whenTrue else
    let right := calls.relation text context after
      (if selected = .shortAnd then result.whenTrue else if selected = .shortOr then result.whenFalse else incoming) initials
    if right.after = 0 ∨ (selected = .eagerXor ∧ !calls.xorFree text after right.after) then calls.invalidCondition result.whenTrue else
    calls.tail text context
      (if selected = .shortAnd then ⟨right.after, right.whenTrue, calls.join result.whenFalse right.whenFalse⟩
       else if selected = .shortOr then ⟨right.after, calls.join result.whenTrue right.whenTrue, right.whenFalse⟩
       else ⟨right.after, incoming, incoming⟩) selected true initials incoming originalStart

def modelEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : ConditionResult :=
  let result := calls.relation text context position facts initials
  if result.after = 0 then calls.invalidCondition facts else
  let final := calls.tail text context result .shortAnd false initials facts position
  if final.after = 0 then calls.invalidCondition facts else final

theorem summary_denotation (calls : Calls) (value : Compose.ExpressionResult) :
    summaryBody.eval calls ({value} : Inputs).locals = summaryOf value := by
  dsimp +instances only [summaryBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [summaryOf, Compose.ExpressionResult.lengthSummary]

theorem bound_denotation (calls : Calls) (binding : Bindings.BindingInfo) :
    boundBody.eval calls ({binding} : Inputs).locals = binding.bound := by
  dsimp +instances only [boundBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [Bindings.BindingInfo.bound]

theorem bindingSummary_denotation (calls : Calls) (binding : Bindings.BindingInfo) :
    bindingSummaryBody.eval calls ({binding} : Inputs).locals = Compose.LengthSummary.ofExact binding.bound.summary := by
  dsimp +instances only [bindingSummaryBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  cases dynamic : binding.dynamic <;> simp [Bindings.BindingInfo.bound, Bindings.Bound.summary, Compose.LengthSummary.ofExact, dynamic]

theorem comparison_denotation (calls : Calls) (text : Source) (position : Nat) :
    comparisonBody.eval calls ({text, position} : Inputs).locals = comparisonEquation calls text position := by
  dsimp +instances only [comparisonBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [comparisonEquation]

theorem length_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (literal : Bool) :
    lengthBody.eval calls ({text, context, position, literal} : Inputs).locals = lengthEquation calls text context position literal := by
  dsimp +instances only [lengthBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [lengthEquation, or_assoc]

theorem booleanAtom_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) :
    booleanAtomBody.eval calls ({text, context, position} : Inputs).locals = booleanAtomEquation calls text context position := by
  dsimp +instances only [booleanAtomBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [booleanAtomEquation, or_assoc]

theorem booleanFactor_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    booleanFactorBody.eval calls ({text, context, position, facts, initials} : Inputs).locals = booleanFactorEquation calls text context position facts initials := by
  dsimp +instances only [booleanFactorBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [booleanFactorEquation]

theorem booleanRelation_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    booleanRelationBody.eval calls ({text, context, position, facts, initials} : Inputs).locals = booleanRelationEquation calls text context position facts initials := by
  dsimp +instances only [booleanRelationBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [booleanRelationEquation]

theorem primary_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    primaryBody.eval calls ({text, context, position, facts, initials} : Inputs).locals = primaryEquation calls text context position facts initials := by
  dsimp +instances only [primaryBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [primaryEquation]

theorem character_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    characterBody.eval calls ({text, context, position, facts, initials} : Inputs).locals =
      characterEquation calls text context position facts initials := by
  dsimp +instances only [characterBody, Expr.eval, Inputs.locals, Locals.set, Calls.get, Field.get,
    Expr.callReadingNames, Expr.callCharacterAt, Expr.callComparison]
  simp [characterEquation, invalidCondition, ActiveFlow.invalid, or_assoc]

theorem relation_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    relationBody.eval calls ({text, context, position, facts, initials} : Inputs).locals = relationEquation calls text context position facts initials := by
  dsimp +instances only [relationBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [relationEquation, or_assoc]

theorem chainToken_denotation (calls : Calls) (text : Source) (position : Nat) :
    chainTokenBody.eval calls ({text, position} : Inputs).locals = chainTokenEquation calls text position := by
  dsimp +instances only [chainTokenBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [chainTokenEquation]

theorem chainAfter_denotation (calls : Calls) (text : Source) (position : Nat) (operator : ChainKind) :
    chainAfterBody.eval calls ({text, position, operator} : Inputs).locals = chainAfterEquation calls text position operator := by
  dsimp +instances only [chainAfterBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  cases operator <;> rfl

theorem tail_denotation (calls : Calls) (text : Source) (context : Context) (result : ConditionResult) (operator : ChainKind) (chained : Bool) (initials : ArrayBindings.Initials) (incoming : ActiveFlow) (originalStart : Nat) :
    tailBody.eval calls ({text, context, result, operator, chained, initials, incoming, originalStart} : Inputs).locals = tailEquation calls text context result operator chained initials incoming originalStart := by
  dsimp +instances only [tailBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [tailEquation]

theorem model_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    modelBody.eval calls ({text, context, position, facts, initials} : Inputs).locals = modelEquation calls text context position facts initials := by
  dsimp +instances only [modelBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callEqualName, Expr.callNameIs, Expr.callArrayLookup, Expr.callBooleanLookup, Expr.callBooleanAtom, Expr.callBooleanFactor, Expr.callBooleanRelation, Expr.callCharacterCondition, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callXorFree, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [modelEquation]

theorem condition_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    conditionBody.eval calls ({text, context, position, facts, initials} : Inputs).locals = calls.model text context position facts initials := by rfl

end Silver.Predicate.Native
