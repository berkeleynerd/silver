module

public import Silver.PredicateNativePrecedence

@[expose] public section

namespace Silver.Predicate.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure Inputs where
  text : Source := []
  context : Context := ⟨[], 0, 0, [], 0, [], {}⟩
  position : Nat := 0
  facts : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  value : Compose.ExpressionResult := Compose.invalidExpression
  binding : Bindings.BindingInfo := {}
  result : ConditionResult := invalidCondition ⟨PathFacts.Context.empty, []⟩
  operator : Token := .andKeyword
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
  | .token, "operator" => inputs.operator
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
  else if index = 0 ∨ calls.scalarLookup text context.scalarNames first after ≠ 0 then ⟨0, .fixed 0⟩
  else ⟨calls.take text (calls.take text after .apostrophe) .lengthName,
    calls.bound ((context.names.get index).getD {})⟩

def primaryEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) : ConditionResult :=
  if position = 0 then calls.invalidCondition facts else
  let after := calls.take text position .leftParenthesis
  if after ≠ 0 then
    let result := calls.model text context after facts
    let close := calls.take text result.after .rightParenthesis
    if close = 0 then calls.invalidCondition facts else {result with after := close}
  else if context.dynamicFirst = 0 then calls.invalidCondition facts
  else
    let afterCall := calls.callAfter text context.names position .validity context.scalarNames context.arrayNames (context.subtypeHiding.get .validity)
    if afterCall = 0 then calls.invalidCondition facts else
      ⟨afterCall, {facts with path := calls.assumeValid facts.path},
        {facts with path := calls.assumeInvalid facts.path}⟩

def relationEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) : ConditionResult :=
  if position = 0 then calls.invalidCondition facts else
  let after := calls.take text position .notKeyword
  let leftLength := calls.length text context position false
  let leftScalar := calls.scalarInFlow text context position facts
  if after ≠ 0 then
    let result := calls.primary text context after facts
    ⟨result.after, result.whenFalse, result.whenTrue⟩
  else if leftLength.after ≠ 0 then
    let operator := calls.comparison text leftLength.after
    let rightLength := calls.length text context operator.after true
    if rightLength.after ≤ position then calls.invalidCondition facts
    else ⟨rightLength.after,
      {facts with path := calls.refineBounds facts.path operator.operator leftLength.value rightLength.value true},
      {facts with path := calls.refineBounds facts.path operator.operator leftLength.value rightLength.value false}⟩
  else if leftScalar.after ≠ 0 then
    let operator := calls.comparison text leftScalar.after
    let rightScalar := calls.scalarInFlow text context operator.after facts
    if rightScalar.after ≤ position then calls.invalidCondition facts
    else calls.scalarCondition text context position operator.after facts leftScalar rightScalar operator.operator
  else
    let left := calls.stringInFlow text context position facts
    if left.after ≠ 0 then
      let operator := calls.comparison text left.after
      if operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne) then calls.invalidCondition facts
      else
        let right := calls.stringInFlow text context operator.after facts
        if right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
            !calls.fits facts.path (calls.summary left) ∨ !calls.fits facts.path (calls.summary right)
        then calls.invalidCondition facts
        else
          let equalFacts := calls.refineEqual facts.path (calls.summary left) (calls.summary right)
          ⟨right.after, {facts with path := if operator.operator = .eq then equalFacts else facts.path},
            {facts with path := if operator.operator = .eq then facts.path else equalFacts}⟩
    else calls.primary text context position facts

def chainTokenEquation (calls : Calls) (text : Source) (position : Nat) : Token :=
  if calls.take text position .andKeyword ≠ 0 then .andKeyword
  else if calls.take text position .orKeyword ≠ 0 then .orKeyword
  else .endKeyword

def chainAfterEquation (calls : Calls) (text : Source) (position : Nat) (operator : Token) : Nat :=
  calls.take text (calls.take text position operator) (if operator = .andKeyword then .thenKeyword else .elseKeyword)

def tailEquation (calls : Calls) (text : Source) (context : Context) (result : ConditionResult)
    (operator : Token) (chained : Bool) : ConditionResult :=
  if result.after = 0 then calls.invalidCondition result.whenTrue else
  let selected := calls.chainToken text result.after
  if !selected.isChain then result
  else if chained && decide (operator ≠ selected) then calls.invalidCondition result.whenTrue
  else
    let after := calls.chainAfter text result.after selected
    if after = 0 then calls.invalidCondition result.whenTrue else
    let right := calls.relation text context after (if selected = .andKeyword then result.whenTrue else result.whenFalse)
    if right.after = 0 then calls.invalidCondition result.whenTrue else
    calls.tail text context
      (if selected = .andKeyword then ⟨right.after, right.whenTrue, calls.join result.whenFalse right.whenFalse⟩
       else ⟨right.after, calls.join result.whenTrue right.whenTrue, right.whenFalse⟩) selected true

def modelEquation (calls : Calls) (text : Source) (context : Context) (position : Nat)
    (facts : ActiveFlow) : ConditionResult :=
  let result := calls.relation text context position facts
  if result.after = 0 then calls.invalidCondition facts else
  let final := calls.tail text context result .andKeyword false
  if final.after = 0 then calls.invalidCondition facts else final

theorem summary_denotation (calls : Calls) (value : Compose.ExpressionResult) :
    summaryBody.eval calls ({value} : Inputs).locals = summaryOf value := by
  dsimp +instances only [summaryBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [summaryOf, Compose.ExpressionResult.lengthSummary]

theorem bound_denotation (calls : Calls) (binding : Bindings.BindingInfo) :
    boundBody.eval calls ({binding} : Inputs).locals = binding.bound := by
  dsimp +instances only [boundBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [Bindings.BindingInfo.bound]

theorem bindingSummary_denotation (calls : Calls) (binding : Bindings.BindingInfo) :
    bindingSummaryBody.eval calls ({binding} : Inputs).locals = Compose.LengthSummary.ofExact binding.bound.summary := by
  dsimp +instances only [bindingSummaryBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  cases dynamic : binding.dynamic <;> simp [Bindings.BindingInfo.bound, Bindings.Bound.summary, Compose.LengthSummary.ofExact, dynamic]

theorem comparison_denotation (calls : Calls) (text : Source) (position : Nat) :
    comparisonBody.eval calls ({text, position} : Inputs).locals = comparisonEquation calls text position := by
  dsimp +instances only [comparisonBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [comparisonEquation]

theorem length_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (literal : Bool) :
    lengthBody.eval calls ({text, context, position, literal} : Inputs).locals = lengthEquation calls text context position literal := by
  dsimp +instances only [lengthBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [lengthEquation]

theorem primary_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) :
    primaryBody.eval calls ({text, context, position, facts} : Inputs).locals = primaryEquation calls text context position facts := by
  dsimp +instances only [primaryBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [primaryEquation]

theorem relation_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) :
    relationBody.eval calls ({text, context, position, facts} : Inputs).locals = relationEquation calls text context position facts := by
  dsimp +instances only [relationBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [relationEquation, or_assoc]

theorem chainToken_denotation (calls : Calls) (text : Source) (position : Nat) :
    chainTokenBody.eval calls ({text, position} : Inputs).locals = chainTokenEquation calls text position := by
  dsimp +instances only [chainTokenBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [chainTokenEquation]

theorem chainAfter_denotation (calls : Calls) (text : Source) (position : Nat) (operator : Token) :
    chainAfterBody.eval calls ({text, position, operator} : Inputs).locals = chainAfterEquation calls text position operator := by
  dsimp +instances only [chainAfterBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [chainAfterEquation]

theorem tail_denotation (calls : Calls) (text : Source) (context : Context) (result : ConditionResult) (operator : Token) (chained : Bool) :
    tailBody.eval calls ({text, context, result, operator, chained} : Inputs).locals = tailEquation calls text context result operator chained := by
  dsimp +instances only [tailBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [tailEquation]

theorem model_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) :
    modelBody.eval calls ({text, context, position, facts} : Inputs).locals = modelEquation calls text context position facts := by
  dsimp +instances only [modelBody, Expr.eval, Expr.declared, Expr.declaredCondition, Inputs.locals, Locals.set, Calls.get, Field.get, Expr.callOperation, Expr.callTake, Expr.callSkip, Expr.callNameAfter, Expr.callLookup, Expr.callInteger, Expr.callScalarLookup, Expr.callScalarRead, Expr.callScalarInFlow, Expr.callStringInFlow, Expr.callScalarCondition, Expr.callExpression, Expr.callSummary, Expr.callBound, Expr.callBindingSummary, Expr.callComparison, Expr.callLength, Expr.callPrimary, Expr.callRelation, Expr.callCondition, Expr.callModel, Expr.callChainToken, Expr.callChainAfter, Expr.callTail, Expr.callAssumeValid, Expr.callAssumeInvalid, Expr.callRefineBounds, Expr.callFits, Expr.callRefineEqual, Expr.callJoin]
  simp [modelEquation]

theorem condition_denotation (calls : Calls) (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) :
    conditionBody.eval calls ({text, context, position, facts} : Inputs).locals = calls.model text context position facts := by rfl

end Silver.Predicate.Native
