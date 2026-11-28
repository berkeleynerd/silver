module

public import Silver.ApplicationPackageExpressionEffects
public import Silver.ProcedureNameConditionReadings

@[expose] public section

/-! Complete parsed conditions cannot read an original package-state cell that
State_Reads omits. Frame indices and declaration-order state identities remain
separate, and visibility is derived from the actual lookup and source spans. -/
namespace Silver.ApplicationPackageEffects
open Compose Predicate

private theorem condition_occurrence {text : Source} {context : ParseContext}
    {position limit first after : Nat} {cell : ScalarProcedures.Cell}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow}
    {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
    (spelling : CellSpelling text context first after cell)
    (bounded : cell.InScalarNamespace)
    (mentioned : ScalarProcedures.conditionMentions cell condition = true) :
    actualNameFree text position limit first after = false := by
  apply Bool.eq_false_iff.mpr
  intro free
  have excluded := ((actualNameFree_sound free).conditionSyntax source
    positionBound finishBound spelling bounded).1
  rw [mentioned] at excluded
  contradiction

theorem condition_integer_read_cell {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {position limit identity slot : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow}
    {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (identityPositive : 0 < identity) (active : identity ≤ info.states.length)
    (capacity : identity ≤ PackageBindings.maxStates)
    (nameValid : PackageBindings.validName (ApplicationPackageNames.metadataText text)
      (info.stateAt identity).name = true)
    (kind : (info.stateAt identity).kind = .integer)
    (found : ScalarExpression.lookup text context.scalarNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after = slot)
    (slotPositive : slot ≠ 0) (slotBound : slot ≤ ArrayBindings.scalarLimit)
    (firstSpan : (ScalarExpression.binding context.scalarNames slot).first =
      (info.stateAt identity).name.first)
    (afterSpan : (ScalarExpression.binding context.scalarNames slot).after =
      (info.stateAt identity).name.after)
    (mentioned : ScalarProcedures.conditionMentions (.integer slot) condition = true) :
    (info.stateAt identity).cell identity ∈
      info.effectCells (stateReads modelCalls text context info position limit) := by
  have advance := condition_source_advance source
  have visible : visibleState modelCalls text context info identity = true := by
    simp [visibleState, modelCalls, Nat.not_lt.mpr active, nameValid, kind,
      found, slotPositive, firstSpan, afterSpan]
  apply (stateReads_cell modelCalls text context info position limit identity
    identityPositive active capacity).mpr
  exact ⟨by omega, visible, condition_occurrence source positionBound finishBound
    (.integer found slotPositive) slotBound mentioned⟩

theorem condition_boolean_read_cell {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {position limit identity slot : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow}
    {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (identityPositive : 0 < identity) (active : identity ≤ info.states.length)
    (capacity : identity ≤ PackageBindings.maxStates)
    (nameValid : PackageBindings.validName (ApplicationPackageNames.metadataText text)
      (info.stateAt identity).name = true)
    (kind : (info.stateAt identity).kind = .boolean)
    (noScalar : ScalarExpression.lookup text context.scalarNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after = 0)
    (found : BooleanBindings.lookup text context.booleanNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after = slot)
    (slotPositive : slot ≠ 0) (slotBound : slot ≤ BooleanBindings.maxBindings)
    (firstSpan : (BooleanBindings.binding context.booleanNames slot).first =
      (info.stateAt identity).name.first)
    (afterSpan : (BooleanBindings.binding context.booleanNames slot).after =
      (info.stateAt identity).name.after)
    (mentioned : ScalarProcedures.conditionMentions (.boolean slot) condition = true) :
    (info.stateAt identity).cell identity ∈
      info.effectCells (stateReads modelCalls text context info position limit) := by
  have advance := condition_source_advance source
  have visible : visibleState modelCalls text context info identity = true := by
    simp [visibleState, modelCalls, Nat.not_lt.mpr active, nameValid, kind,
      noScalar, found, slotPositive, firstSpan, afterSpan]
  apply (stateReads_cell modelCalls text context info position limit identity
    identityPositive active capacity).mpr
  exact ⟨by omega, visible, condition_occurrence source positionBound finishBound
    (.boolean noScalar found slotPositive) slotBound mentioned⟩

end Silver.ApplicationPackageEffects
