module

public import Silver.ComposeAtomAdmission
public import Silver.PredicateChecking
public import Silver.IntegerLiteral
public import Silver.PredicateFlowOverlay
public import Silver.PredicateArrayFlow
public import Silver.ArrayBindingsMetadata
public import Silver.IntegerSubtypeBindings
public import Silver.PredicateXorAdmission

@[expose] public section

/-! Scalar predicate scanner. Short-circuit chains are accumulated from left to
right, and each right relation receives exactly the path context in which it is
reached. Source readings recover the expression payloads independently. -/

namespace Silver.Predicate
open Compose Bindings PathFacts

structure ParseContext where
  names : Compose.BindingEnvironment
  hasArguments : Bool
  scalarNames : ScalarExpression.Environment := []
  declarationCount : Nat := 0
  arrayNames : ArrayBindings.Metadata := []
  subtypeHiding : IntegerSubtypes.CallHiding := {}
  booleanNames : BooleanBindings.Environment := []
  trueHidden : Bool := false
  falseHidden : Bool := false
  elaborating : Bool := false
  maskFirst : Nat := 0
  maskAfter : Nat := 0
  pure : Bool := false
  outerIntegerHidden : Bool := false
  arrayTypes : ArrayBindings.TypeEnvironment := []
  deriving Repr

def ParseContext.arrayTable (context : ParseContext) : ArrayBindings.Table :=
  ⟨context.arrayNames, context.arrayTypes⟩

def ParseContext.analysis (context : ParseContext) : Integer.Analysis :=
  ArrayFlow.analysis context.arrayNames (ScalarMetadata.analysis context.scalarNames context.declarationCount)

def ParseContext.flow (context : ParseContext) (facts : ActiveFlow)
    (initials : ArrayBindings.Initials := []) : Flow :=
  ⟨facts.path, ArrayBindings.integerRanges context.arrayNames initials context.elaborating facts.model.scalars⟩

def ParseContext.readingNames (context : ParseContext) (facts : ActiveFlow) : ScalarExpression.Environment :=
  ScalarMetadata.readingNames context.scalarNames context.declarationCount facts

def ParseContext.ArraysReady (context : ParseContext) (text : Source) : Prop :=
  ArrayBindings.ValidMetadata text context.arrayNames ∧
    context.arrayNames.Pairwise (fun left right => left.offset + left.length ≤ right.offset)

theorem ParseContext.reading_ranges {context : ParseContext} {facts : ActiveFlow}
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (initials : ArrayBindings.Initials := []) :
    ArrayBindings.integerRanges context.arrayNames initials context.elaborating
        (ScalarExpression.ranges (context.readingNames facts)) =
      (context.flow facts initials).scalars := by
  unfold ParseContext.readingNames
  rw [ScalarMetadata.readingNames_ranges compatible]
  rfl

@[simp] theorem ParseContext.flow_path (context : ParseContext) (facts : ActiveFlow)
    (initials : ArrayBindings.Initials := []) :
    (context.flow facts initials).path = facts.path := rfl

theorem ParseContext.flow_scalar (context : ParseContext) (facts : ActiveFlow)
    {index : Nat} (low : index ≤ ArrayBindings.scalarLimit)
    (initials : ArrayBindings.Initials := []) :
    (context.flow facts initials).scalars index = facts.model.scalars index :=
  ArrayBindings.ranges_scalar (ArrayBindings.integerNames context.arrayNames) initials context.elaborating facts.model.scalars low

theorem ParseContext.flow_join (context : ParseContext) (left right : ActiveFlow)
    (initials : ArrayBindings.Initials := []) :
    context.flow (left.join right) initials = (context.flow left initials).join (context.flow right initials) := by
  have scalars := congrArg Flow.scalars (ActiveFlow.join_model left right)
  simp only [Flow.join] at scalars
  have path : (left.join right).path = left.path.join right.path := rfl
  simp only [ParseContext.flow, Flow.join, path]
  congr 1
  rw [scalars]
  funext cell
  unfold ArrayBindings.integerRanges ArrayBindings.ranges Integer.Ranges.join
  cases covered : ArrayBindings.covers (ArrayBindings.integerNames context.arrayNames) cell with
  | true =>
    simp only [covered, ↓reduceIte]
    cases context.elaborating
    · exact congrArg some (ArrayBindings.componentRange_join_self (ArrayBindings.integerNames context.arrayNames) cell).symm
    · simp [Integer.Interval.join, Integer.Interval.singleton, Integer.Interval.isEmpty]
  | false => simp only [covered, Bool.false_eq_true, ↓reduceIte]

theorem ParseContext.flow_refine (context : ParseContext) (facts : ActiveFlow)
    (index : Nat) (operator : Integer.Comparison) (threshold : Int) (truth : Bool)
    (low : index ≤ ArrayBindings.scalarLimit) (initials : ArrayBindings.Initials := []) :
    context.flow (facts.refine index operator threshold truth) initials =
      ⟨facts.path, (context.flow facts initials).scalars.refineName index operator threshold truth⟩ := by
  have scalars := congrArg Flow.scalars (ActiveFlow.refine_model facts index operator threshold truth)
  simp only at scalars
  simp only [ParseContext.flow, ActiveFlow.refine_path]
  congr 1
  rw [scalars]
  unfold Integer.Ranges.refineName ArrayBindings.integerRanges
  rw [ArrayBindings.ranges_scalar (ArrayBindings.integerNames context.arrayNames) initials context.elaborating facts.model.scalars low]
  cases facts.model.scalars index with
  | none => rfl
  | some bounds => exact ArrayBindings.ranges_put (ArrayBindings.integerNames context.arrayNames) initials context.elaborating _ low _

@[simp] theorem ParseContext.flow_withPath (context : ParseContext) (facts : ActiveFlow)
    (path : Context) (initials : ArrayBindings.Initials := []) :
    context.flow {facts with path} initials = {context.flow facts initials with path} := rfl

def readScalarInFlow (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (maskFirst maskAfter : Nat := 0) (initials : ArrayBindings.Initials := []) : ScalarExpression.Result :=
  ScalarExpression.read text position (context.readingNames facts) maskFirst maskAfter
    (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating)

def ParseContext.integerHidden (context : ParseContext) (text : Source) : Bool :=
  context.outerIntegerHidden || BooleanBindings.hidesInteger text context.booleanNames ||
      (decide (context.maskFirst ≠ 0) &&
        Named.nameIs text context.maskFirst context.maskAfter ("integer".toList.map Char.toNat))

def ParseContext.validityHidden (context : ParseContext) (text : Source) : Bool :=
  context.subtypeHiding.get .validity || (decide (context.maskFirst ≠ 0) &&
    Named.nameIs text context.maskFirst context.maskAfter ("input_is_valid".toList.map Char.toNat))

def readStringInFlow (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (initials : ArrayBindings.Initials := []) : ExpressionResult :=
  expressionAt text position context.names (context.readingNames facts)
    (context.integerHidden text) context.arrayNames initials context.elaborating

def Comparison.toInteger : Comparison → Integer.Comparison
  | .eq => .eq | .ne => .ne | .lt => .lt | .le => .le | .gt => .gt | .ge => .ge

structure ComparisonResult where
  after : Nat
  operator : Comparison
  deriving DecidableEq, Repr

def comparisonAt (text : Source) (position : Nat) : ComparisonResult :=
  if fixedAfter text position "/=" false ≠ 0 then ⟨fixedAfter text position "/=" false, .ne⟩
  else if fixedAfter text position "<=" false ≠ 0 then ⟨fixedAfter text position "<=" false, .le⟩
  else if fixedAfter text position ">=" false ≠ 0 then ⟨fixedAfter text position ">=" false, .ge⟩
  else if fixedAfter text position "=" false ≠ 0 then ⟨fixedAfter text position "=" false, .eq⟩
  else if fixedAfter text position "<" false ≠ 0 then ⟨fixedAfter text position "<" false, .lt⟩
  else if fixedAfter text position ">" false ≠ 0 then ⟨fixedAfter text position ">" false, .gt⟩
  else ⟨0, .eq⟩

structure LengthResult where
  after : Nat
  value : Bound
  deriving DecidableEq, Repr

def lengthAt (text : Source) (context : ParseContext) (position : Nat) (literal : Bool) : LengthResult :=
  let first := skipAt text position
  let after := nameAfter text first
  let index := lookupName text context.names first after
  let number := IntegerLiteral.read text first
  if literal && decide (number.after ≠ 0) then ⟨number.after, .fixed number.value⟩
  else if index = 0 ∨ ((context.names.get index).getD {}).isCharacter = true ∨
      ScalarExpression.lookup text context.scalarNames first after ≠ 0 then ⟨0, .fixed 0⟩
  else ⟨fixedAfter text (fixedAfter text after "'" false) "length" true,
    ((context.names.get index).getD {}).bound⟩

structure ConditionResult where
  after : Nat
  whenTrue : ActiveFlow
  whenFalse : ActiveFlow
  deriving DecidableEq, Repr

def ConditionResult.count (result : ConditionResult) : Nat := result.whenTrue.count

def invalidCondition (facts : ActiveFlow) : ConditionResult := ⟨0, facts.invalid, facts.invalid⟩

def characterCondition (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials := []) : ConditionResult :=
  let overlay := context.readingNames facts
  let left := characterAt text position context.names overlay context.arrayNames initials context.elaborating
  let operator := comparisonAt text left.after
  let right := characterAt text operator.after context.names overlay context.arrayNames initials context.elaborating
  if left.after = 0 ∨ operator.after = 0 ∨ right.after ≤ position ∨
      !(left.nonliteralSeen || right.nonliteralSeen) then invalidCondition facts
  else ⟨right.after, facts, facts⟩

def bareTarget (text : Source) (context : ParseContext) (position after : Nat) : Nat :=
  let first := skipAt text position
  let last := nameAfter text first
  let index := ScalarExpression.lookup text context.scalarNames first last
  if index ≠ 0 ∧ last = after ∧
      ((ScalarExpression.binding context.scalarNames index).mutable || decide (context.declarationCount < index))
  then index else 0

def scalarCondition (text : Source) (context : ParseContext) (position rightPosition : Nat)
    (facts : ActiveFlow) (left right : ScalarExpression.Result) (operator : Comparison) : ConditionResult :=
  let leftTarget := bareTarget text context position left.after
  let rightTarget := bareTarget text context rightPosition right.after
  let target := if leftTarget ≠ 0 ∧ right.isStatic ∧ right.bounds.lower = right.bounds.upper then leftTarget
    else if rightTarget ≠ 0 ∧ left.isStatic ∧ left.bounds.lower = left.bounds.upper then rightTarget else 0
  let selected := if leftTarget ≠ 0 ∧ right.isStatic ∧ right.bounds.lower = right.bounds.upper
    then operator.toInteger else operator.toInteger.swap
  let threshold := if leftTarget ≠ 0 ∧ right.isStatic ∧ right.bounds.lower = right.bounds.upper
    then right.bounds.lower else left.bounds.lower
  ⟨right.after, facts.refine target selected threshold true, facts.refine target selected threshold false⟩

def refineFlowBounds (facts : ActiveFlow) (operator : Comparison) (left right : Bound) (truth : Bool) : ActiveFlow :=
  {facts with path := refineBounds facts.path operator left right truth}

def summaryOf (value : ExpressionResult) : LengthSummary := value.lengthSummary

def remainingAt (text : Source) (position : Nat) : Nat := text.length + 1 - position

/-- The five Ada logical chains; mixing unparenthesized categories is rejected. -/
inductive ChainKind
  | shortAnd | shortOr | eagerAnd | eagerOr | eagerXor
  deriving DecidableEq, Repr

def chainOperator (text : Source) (position : Nat) : Option ChainKind :=
  if fixedAfter text position "and" true ≠ 0 then
    if fixedAfter text (fixedAfter text position "and" true) "then" true ≠ 0
    then some .shortAnd else some .eagerAnd
  else if fixedAfter text position "or" true ≠ 0 then
    if fixedAfter text (fixedAfter text position "or" true) "else" true ≠ 0
    then some .shortOr else some .eagerOr
  else if fixedAfter text position "xor" true ≠ 0 then some .eagerXor
  else none

def chainAfter (text : Source) (position : Nat) : ChainKind → Nat
  | .shortAnd => fixedAfter text (fixedAfter text position "and" true) "then" true
  | .shortOr => fixedAfter text (fixedAfter text position "or" true) "else" true
  | .eagerAnd => fixedAfter text position "and" true
  | .eagerOr => fixedAfter text position "or" true
  | .eagerXor => fixedAfter text position "xor" true

def chainContext (result : ConditionResult) (operator : ChainKind) (incoming : ActiveFlow) : ActiveFlow :=
  match operator with
  | .shortAnd => result.whenTrue
  | .shortOr => result.whenFalse
  | _ => incoming

def chainJoin (left right : ConditionResult) (operator : ChainKind) (incoming : ActiveFlow) : ConditionResult :=
  match operator with
  | .shortAnd => ⟨right.after, right.whenTrue, left.whenFalse.join right.whenFalse⟩
  | .shortOr => ⟨right.after, left.whenTrue.join right.whenTrue, right.whenFalse⟩
  | _ => ⟨right.after, incoming, incoming⟩

/-- Boolean component reads use the scalar-only index grammar and preserve both
outcome flows. Reserved Integer initial-value slots carry no Boolean meaning. -/
def booleanArrayAfter (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  let target := ArrayBindings.lookup text context.arrayNames first after
  let subscript := ScalarExpression.read text (fixedAfter text after "(" false)
    (context.readingNames facts) context.maskFirst context.maskAfter
  let close := fixedAfter text subscript.after ")" false
  if first = 0 ∨ after ≤ first ∨ target = 0 ∨
      (ArrayBindings.binding context.arrayNames target).isBoolean = false ∨
      ScalarExpression.lookup text context.scalarNames first after ≠ 0 ∨
      (context.maskFirst ≠ 0 ∧ Named.equalName text context.maskFirst context.maskAfter first after = true) ∨
      subscript.operands = ScalarExpression.maxOperands ∨
      ArrayBindings.contains (ArrayBindings.binding context.arrayNames target) subscript.bounds = false ∨
      close ≤ position
  then 0 else close

def booleanAtomAfter (text : Source) (context : ParseContext) (position : Nat) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if first = 0 ∨ after ≤ first ∨
      (context.maskFirst ≠ 0 ∧ Named.equalName text context.maskFirst context.maskAfter first after) ∨
      ScalarExpression.lookup text context.scalarNames first after ≠ 0 ∨
      lookupName text context.names first after ≠ 0 ∨
      ArrayBindings.lookup text context.arrayNames first after ≠ 0 then 0
  else if BooleanBindings.lookup text context.booleanNames first after ≠ 0 then after
  else if (Named.nameIs text first after ("true".toList.map Char.toNat) && !context.trueHidden) ||
      (Named.nameIs text first after ("false".toList.map Char.toNat) && !context.falseHidden)
    then after else 0

mutual
  def readPrimary (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) : ConditionResult :=
    if position = 0 then invalidCondition facts else
    let after := fixedAfter text position "(" false
    if after ≠ 0 then
      if _advanced : remainingAt text after < remainingAt text position then
        let result := readCondition text context after facts initials
        let close := fixedAfter text result.after ")" false
        if close = 0 then invalidCondition facts else {result with after := close}
      else invalidCondition facts
    else if booleanArrayAfter text context position facts ≠ 0 then
      ⟨booleanArrayAfter text context position facts, facts, facts⟩
    else if booleanAtomAfter text context position ≠ 0 then
      ⟨booleanAtomAfter text context position, facts, facts⟩
    else if !context.hasArguments then invalidCondition facts
    else
      let afterCall := callAfter text context.names position .validity context.scalarNames context.arrayNames
        (context.validityHidden text) context.booleanNames
      if afterCall = 0 then invalidCondition facts else
        ⟨afterCall, {facts with path := facts.path.assumeValid}, {facts with path := facts.path.assumeInvalid}⟩
  termination_by remainingAt text position * 7 + 1
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readBooleanFactor (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) : ConditionResult :=
    let after := fixedAfter text position "not" true
    if after = 0 then readPrimary text context position facts initials
    else if _advanced : remainingAt text after < remainingAt text position then
      let result := readPrimary text context after facts initials
      ⟨result.after, result.whenFalse, result.whenTrue⟩
    else invalidCondition facts
  termination_by remainingAt text position * 7 + 2
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readBooleanRelation (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) : ConditionResult :=
    let left := readBooleanFactor text context position facts initials
    let operator := comparisonAt text left.after
    if left.after = 0 then invalidCondition facts
    else if operator.after = 0 then left
    else if operator.operator ≠ .eq ∧ operator.operator ≠ .ne then invalidCondition facts
    else if _advanced : remainingAt text operator.after < remainingAt text position then
      let right := readBooleanFactor text context operator.after facts initials
      if right.after = 0 then invalidCondition facts else ⟨right.after, facts, facts⟩
    else invalidCondition facts
  termination_by remainingAt text position * 7 + 3
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readRelation (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) : ConditionResult :=
    if position = 0 then invalidCondition facts else
    let after := fixedAfter text position "not" true
    if after ≠ 0 then readBooleanRelation text context position facts initials
    else
      let leftLength := lengthAt text context position false
      if leftLength.after ≠ 0 then
        let operator := comparisonAt text leftLength.after
        let rightLength := lengthAt text context operator.after true
        if rightLength.after ≤ position then invalidCondition facts else
        ⟨rightLength.after,
          refineFlowBounds facts operator.operator leftLength.value rightLength.value true,
          refineFlowBounds facts operator.operator leftLength.value rightLength.value false⟩
      else
        let leftScalar := readScalarInFlow text context position facts (initials := initials)
        if leftScalar.after ≠ 0 then
          let operator := comparisonAt text leftScalar.after
          let rightScalar := readScalarInFlow text context operator.after facts (initials := initials)
          if rightScalar.after ≤ position then invalidCondition facts
          else scalarCondition text context position operator.after facts leftScalar rightScalar operator.operator
        else if context.pure then readBooleanRelation text context position facts initials
        else
        let left := readStringInFlow text context position facts initials
        if left.after ≠ 0 then
          let operator := comparisonAt text left.after
          if operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne) then invalidCondition facts
          else
            let right := readStringInFlow text context operator.after facts initials
            if right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
                !fitsLengthSummary facts.path (summaryOf left) ∨ !fitsLengthSummary facts.path (summaryOf right) then invalidCondition facts
            else
              let equalFacts := {facts with path := refineLengthOverlap facts.path (summaryOf left) (summaryOf right)}
              ⟨right.after, if operator.operator == .eq then equalFacts else facts,
                if operator.operator == .eq then facts else equalFacts⟩
        else
          let result := characterCondition text context position facts initials
          if result.after ≠ 0 then result else readBooleanRelation text context position facts initials
  termination_by remainingAt text position * 7 + 4
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def conditionTail (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option ChainKind) (incoming : ActiveFlow)
      (initials : ArrayBindings.Initials := []) (originalStart : Nat := 0) : ConditionResult :=
    if result.after = 0 then invalidCondition result.whenTrue else
    match chainOperator text result.after with
    | none => result
    | some operator =>
        if (chained.isSome && decide (chained ≠ some operator)) ||
            (decide (operator = .eagerXor) && !xorFree text originalStart result.after) then invalidCondition result.whenTrue else
        let after := chainAfter text result.after operator
        if after = 0 then invalidCondition result.whenTrue else
        if _advanced : remainingAt text after < remainingAt text result.after then
          let right := readRelation text context after (chainContext result operator incoming) initials
          if right.after = 0 ∨ (operator = .eagerXor ∧ xorFree text after right.after = false) then invalidCondition result.whenTrue else
          let next := chainJoin result right operator incoming
          if _rightAdvanced : remainingAt text next.after < remainingAt text result.after then
            conditionTail text context next (some operator) incoming initials originalStart
          else invalidCondition result.whenTrue
        else invalidCondition result.whenTrue
  termination_by remainingAt text result.after * 7 + 6
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readCondition (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) : ConditionResult :=
    let result := readRelation text context position facts initials
    if result.after = 0 then invalidCondition facts else
    if _advanced : remainingAt text result.after < remainingAt text position then
      let final := conditionTail text context result none facts initials position
      if final.after = 0 then invalidCondition facts else final
    else invalidCondition facts
  termination_by remainingAt text position * 7 + 5
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega
end

end Silver.Predicate
