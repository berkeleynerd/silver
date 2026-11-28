module

public import Silver.ApplicationPackageEffectBits
public import Silver.ProcedureNameIdentity
public import Silver.ProcedureNameArrayReadings

@[expose] public section

/-! Source-name identity connects a resolved package-state read to its native
effect bit. Lookups remain in the actual compacted frame; declaration ordinals
are separate identities and are never substituted for those lookup slots. -/
namespace Silver.ApplicationPackageEffects
open Compose Predicate

theorem equalName_right_congr {text : Source} {first after otherFirst otherAfter : Nat}
    (same : Named.equalName text first after otherFirst otherAfter = true)
    (leftFirst leftAfter : Nat) :
    Named.equalName text leftFirst leftAfter first after =
      Named.equalName text leftFirst leftAfter otherFirst otherAfter := by
  apply Bool.eq_iff_iff.mpr
  exact ⟨fun found => equalName_trans found same,
    fun found => equalName_trans found (equalName_symm same)⟩

theorem scalarLookup_retarget {text : Source} {names : ScalarExpression.Environment}
    {first after otherFirst otherAfter : Nat}
    (firstPositive : first ≠ 0) (firstOrdered : first < after)
    (otherPositive : otherFirst ≠ 0) (otherOrdered : otherFirst < otherAfter)
    (same : Named.equalName text first after otherFirst otherAfter = true) :
    ScalarExpression.lookup text names first after =
      ScalarExpression.lookup text names otherFirst otherAfter := by
  have loop (count : Nat) : ScalarExpression.lookupFrom text names first after count =
      ScalarExpression.lookupFrom text names otherFirst otherAfter count := by
    induction count with
    | zero => rfl
    | succ count ih =>
        simp only [ScalarExpression.lookupFrom, firstPositive, Nat.not_le.mpr firstOrdered,
          otherPositive, Nat.not_le.mpr otherOrdered, or_self, ite_false,
          equalName_right_congr same, ih]
  exact loop names.length

theorem booleanLookup_retarget {text : Source} {names : BooleanBindings.Environment}
    {first after otherFirst otherAfter : Nat}
    (firstPositive : first ≠ 0) (firstOrdered : first < after)
    (otherPositive : otherFirst ≠ 0) (otherOrdered : otherFirst < otherAfter)
    (same : Named.equalName text first after otherFirst otherAfter = true) :
    BooleanBindings.lookup text names first after =
      BooleanBindings.lookup text names otherFirst otherAfter := by
  have loop (count : Nat) : BooleanBindings.lookupFrom text names first after count =
      BooleanBindings.lookupFrom text names otherFirst otherAfter count := by
    induction count with
    | zero => rfl
    | succ count ih =>
        simp only [BooleanBindings.lookupFrom, firstPositive, Nat.not_le.mpr firstOrdered,
          otherPositive, Nat.not_le.mpr otherOrdered, or_self, ite_false,
          equalName_right_congr same, ih]
  exact loop names.length

/-- A bare Integer identifier resolving to an original package declaration is
visible and selected by State_Reads, even after local compaction changes its
frame slot. No uniqueness assumption about arbitrary environments is needed. -/
theorem scalarIdentifier_read_cell {text bytes : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {position first finish limit identity slot : Nat}
    (identityPositive : 0 < identity) (active : identity ≤ info.states.length)
    (capacity : identity ≤ PackageBindings.maxStates)
    (nameValid : PackageBindings.validName (ApplicationPackageNames.metadataText text)
      (info.stateAt identity).name = true)
    (kind : (info.stateAt identity).kind = .integer)
    (positionPositive : position ≠ 0) (before : position < limit)
    (skipped : skipAt text position = first) (firstPositive : first ≠ 0)
    (identifier : Named.IdentifierAt text first bytes finish) (finishBound : finish ≤ limit)
    (found : ScalarExpression.lookup text context.scalarNames first finish = slot)
    (slotPositive : slot ≠ 0)
    (firstSpan : (ScalarExpression.binding context.scalarNames slot).first =
      (info.stateAt identity).name.first)
    (afterSpan : (ScalarExpression.binding context.scalarNames slot).after =
      (info.stateAt identity).name.after) :
    (info.stateAt identity).cell identity ∈
      info.effectCells (stateReads modelCalls text context info position limit) := by
  have spelling := equalName_symm (scalarLookupFrom_spelling found slotPositive)
  rw [firstSpan, afterSpan] at spelling
  have domain := (ApplicationPackageNames.Native.validName_domain nameValid).2
  have bounds := Named.identifier_bounds identifier
  have original : ScalarExpression.lookup text context.scalarNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after = slot := by
    rw [← scalarLookup_retarget firstPositive bounds.2.2.1
      (Nat.ne_of_gt domain.1) domain.2.1 spelling]
    exact found
  have visible : visibleState modelCalls text context info identity = true := by
    simp [visibleState, modelCalls, Nat.not_lt.mpr active, nameValid, kind,
      original, slotPositive, firstSpan, afterSpan]
  apply (stateReads_cell modelCalls text context info position limit identity
    identityPositive active capacity).mpr
  refine ⟨by omega, visible, ?_⟩
  exact actualNameFree_identifier_alias before skipped firstPositive identifier finishBound spelling

/-- Every scalar dependency in a complete inherited expression contributes the
original package cell. The inherited grammar carries all signs, operators,
parentheses, indexed reads and masks; visibility is derived from actual lookup
and original declaration spans, rather than assumed as an effect obligation. -/
theorem scalar_read_cell {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {position limit identity slot maskFirst maskAfter : Nat}
    {expression : Integer.Expr} {result : ScalarExpression.Result}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {elaborating allowSign : Bool} {mode : ScalarExpression.ArrayReadMode}
    (source : ScalarExpression.ArrayGrammar.At text context.scalarNames position expression result
      maskFirst maskAfter allowSign arrays initials elaborating mode)
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
    (mentioned : ScalarProcedures.integerMentions slot expression = true) :
    (info.stateAt identity).cell identity ∈
      info.effectCells (stateReads modelCalls text context info position limit) := by
  have bounds := source.cursorBounds
  have visible : visibleState modelCalls text context info identity = true := by
    simp [visibleState, modelCalls, Nat.not_lt.mpr active, nameValid, kind,
      found, slotPositive, firstSpan, afterSpan]
  apply (stateReads_cell modelCalls text context info position limit identity
    identityPositive active capacity).mpr
  refine ⟨by omega, visible, ?_⟩
  apply Bool.eq_false_iff.mpr
  intro free
  have excluded := ((actualNameFree_sound free).scalar source finishBound found slotBound).1
  rw [mentioned] at excluded
  contradiction

end Silver.ApplicationPackageEffects
