module

public import Silver.ComposeBounds
public import Silver.ScalarExpressionConstants

@[expose] public section

namespace Silver.Compose
open Expressions

attribute [local irreducible] ScalarExpression.read

theorem scalarRead_position_valid (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (bound : position ≤ text.length + 1) :
    (ScalarExpression.read text position names).after ≤ text.length + 1 := by
  by_cases zero : (ScalarExpression.read text position names).after = 0
  · simp [zero]
  · exact (ScalarExpression.read_bounds bound zero).2.1

theorem scalarConstraintAt_position_valid (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) {baseBounds : Integer.Interval}
    (bound : position ≤ text.length + 1) :
    (scalarConstraintAt text position names baseBounds).after ≤ text.length + 1 := by
  have range := model_fixed_valid text position "range" true bound
  have lower := scalarRead_position_valid text _ names range
  have delimiter := model_fixed_valid text _ ".." false lower
  have upper := scalarRead_position_valid text _ names delimiter
  unfold scalarConstraintAt
  dsimp only
  split
  · exact bound
  · split
    · simp
    · exact upper

/-- The exact optional object range, constrained by the resolved type mark.
Both endpoint expressions retain their source and Ada-staticness. -/
inductive ScalarConstraintAt (text : Source) (names : ScalarExpression.Environment)
    (position : Nat) (baseBounds : Integer.Interval) : ScalarConstraintResult → Prop
  | absent : fixedAfter text position "range" true = 0 →
      ScalarConstraintAt text names position baseBounds ⟨position, baseBounds⟩
  | present {low high : Integer.Expr} {lower upper : ScalarExpression.Result} :
      fixedAfter text position "range" true ≠ 0 →
      ScalarExpression.At text names (fixedAfter text position "range" true) low lower →
      fixedAfter text lower.after ".." false ≠ 0 →
      ScalarExpression.At text names (fixedAfter text lower.after ".." false) high upper →
      lower.isStatic = true → upper.isStatic = true →
      lower.bounds.lower = lower.bounds.upper → upper.bounds.lower = upper.bounds.upper →
      lower.bounds.lower ≤ upper.bounds.lower →
      baseBounds.lower ≤ lower.bounds.lower → upper.bounds.lower ≤ baseBounds.upper →
      ScalarConstraintAt text names position baseBounds
        ⟨upper.after, ⟨lower.bounds.lower, upper.bounds.lower⟩⟩

theorem scalarConstraintAt_sound (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) {baseBounds : Integer.Interval}
    (bound : position ≤ text.length + 1)
    (positive : (scalarConstraintAt text position names baseBounds).after ≠ 0) :
    ScalarConstraintAt text names position baseBounds (scalarConstraintAt text position names baseBounds) := by
  have range := model_fixed_valid text position "range" true bound
  have lower := scalarRead_position_valid text _ names range
  have delimiter := model_fixed_valid text _ ".." false lower
  unfold scalarConstraintAt at positive ⊢
  dsimp only at positive ⊢
  split
  · rename_i absent
    exact .absent absent
  · rename_i present
    split
    · simp_all
    · rename_i good
      simp only [not_or, ne_eq, Decidable.not_not, Int.not_lt, Bool.not_eq_false] at good
      obtain ⟨low, lowRead⟩ := ScalarExpression.read_sound range good.1
      obtain ⟨high, highRead⟩ := ScalarExpression.read_sound delimiter good.2.2.1
      rcases good with ⟨_, delimiterPresent, _, lowStatic, highStatic, _, _, lowExact, highExact,
        ordered, lowerBound, upperBound⟩
      exact .present present lowRead delimiterPresent highRead lowStatic highStatic lowExact highExact
        ordered lowerBound upperBound

/-- The absent range inherits the named subtype; a present range keeps exact
source endpoint evaluation and its containment in the named subtype. -/
def ScalarConstraintMeaning (text : Source) (names : ScalarExpression.Environment)
    (position : Nat) (baseBounds : Integer.Interval) (result : ScalarConstraintResult)
    (values : Integer.Store) : Prop :=
  (fixedAfter text position "range" true = 0 ∧ result = ⟨position, baseBounds⟩) ∨
  ∃ (low high : Integer.Expr) (lower upper : ScalarExpression.Result),
    fixedAfter text position "range" true ≠ 0 ∧
    ScalarExpression.At text names (fixedAfter text position "range" true) low lower ∧
    fixedAfter text lower.after ".." false ≠ 0 ∧
    ScalarExpression.At text names (fixedAfter text lower.after ".." false) high upper ∧
    ScalarExpression.isStatic names low = true ∧ ScalarExpression.isStatic names high = true ∧
    result = ⟨upper.after, ⟨low.evaluate values, high.evaluate values⟩⟩ ∧
    low.Safe values ∧ high.Safe values ∧ low.evaluate values ≤ high.evaluate values ∧
    baseBounds.lower ≤ low.evaluate values ∧ high.evaluate values ≤ baseBounds.upper

theorem ScalarConstraintAt.evaluated {text names position baseBounds result values}
    (reading : ScalarConstraintAt text names position baseBounds result)
    (fits : Integer.Fits (ScalarExpression.ranges names) values) :
    ScalarConstraintMeaning text names position baseBounds result values := by
  cases reading with
  | absent missing => exact .inl ⟨missing, rfl⟩
  | @present low high lower upper present lowRead delimiter highRead lowStatic highStatic lowExact highExact ordered lowerBound upperBound =>
      obtain ⟨lowSafe, lowContains, _⟩ := ScalarExpression.at_safe lowRead fits
      obtain ⟨highSafe, highContains, _⟩ := ScalarExpression.at_safe highRead fits
      have lowValue : low.evaluate values = lower.bounds.lower := by
        simp only [Integer.Interval.Contains] at lowContains
        omega
      have highValue : high.evaluate values = upper.bounds.lower := by
        simp only [Integer.Interval.Contains] at highContains
        omega
      refine .inr ⟨low, high, lower, upper, present, lowRead, delimiter, highRead,
        lowRead.staticValue ▸ lowStatic, highRead.staticValue ▸ highStatic, ?_, lowSafe, highSafe, ?_⟩
      · rw [lowValue, highValue]
      · simpa only [lowValue, highValue] using And.intro ordered (And.intro lowerBound upperBound)

theorem ScalarConstraintMeaning.bounded {text names position baseBounds result values}
    (meaning : ScalarConstraintMeaning text names position baseBounds result values)
    (bounded : baseBounds.Bounded) : result.bounds.Bounded := by
  rcases meaning with ⟨_, rfl⟩ | ⟨low, high, lower, upper, _, _, _, _, _, _, rfl, lowSafe, highSafe, _⟩
  · exact bounded
  · exact ⟨Integer.Expr.safe_value lowSafe, Integer.Expr.safe_value highSafe⟩

theorem ScalarConstraintAt.bounded {text names position baseBounds result}
    (reading : ScalarConstraintAt text names position baseBounds result)
    (bounded : baseBounds.Bounded) : result.bounds.Bounded := by
  cases reading with
  | absent => exact bounded
  | present _ lowRead _ highRead _ _ _ _ _ _ _ =>
      exact ⟨(Integer.Expr.infer_bounded lowRead.inferred).1,
        (Integer.Expr.infer_bounded highRead.inferred).1⟩

theorem scalarConstraintAt_bounded (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) {baseBounds : Integer.Interval}
    (bound : position ≤ text.length + 1)
    (positive : (scalarConstraintAt text position names baseBounds).after ≠ 0)
    (bounded : baseBounds.Bounded) :
    (scalarConstraintAt text position names baseBounds).bounds.Bounded :=
  (scalarConstraintAt_sound text position names bound positive).bounded bounded

/-- Rejected optional ranges also return a bounded interval. -/
theorem scalarConstraintAt_bounded_all (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) {baseBounds : Integer.Interval}
    (bound : position ≤ text.length + 1) (bounded : baseBounds.Bounded) :
    (scalarConstraintAt text position names baseBounds).bounds.Bounded := by
  by_cases positive : (scalarConstraintAt text position names baseBounds).after ≠ 0
  · exact scalarConstraintAt_bounded text position names bound positive bounded
  · unfold scalarConstraintAt at positive ⊢
    dsimp only at positive ⊢
    split
    · exact bounded
    · split
      · exact Integer.Interval.empty_bounded
      · simp_all

theorem scalarTypeAt_position_valid (text : Source) (state : ParserState) (position : Nat) :
    (scalarTypeAt text state position).after ≤ text.length + 1 := by
  have bound := model_name_valid text (skipAt text position)
  unfold scalarTypeAt
  dsimp only
  split
  · simp
  · split
    · exact bound
    · split
      · exact bound
      · simp

theorem subtypeBinding_mem {environment : IntegerSubtypes.Environment} {index : Nat}
    (positive : 0 < index) (bound : index ≤ environment.items.length) :
    IntegerSubtypes.binding environment index ∈ environment.items := by
  have within : index - 1 < environment.items.length := by omega
  simp only [IntegerSubtypes.binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within,
    Option.getD_some]
  exact List.getElem_mem within

theorem scalarTypeAt_bounded (text : Source) (state : ParserState) (position : Nat)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    (scalarTypeAt text state position).bounds.Bounded := by
  have bound := IntegerSubtypes.lookup_bound text state.subtypeNames (skipAt text position)
    (nameAfter text (skipAt text position))
  unfold scalarTypeAt
  dsimp only
  split
  · exact Integer.Interval.empty_bounded
  · split
    · exact Integer.Interval.full_bounded
    · rename_i _
      split
      · rename_i present
        exact (valid.2 _ (subtypeBinding_mem (by omega) bound)).2.2.2.1
      · exact Integer.Interval.empty_bounded

/-- Independent type-mark reading: a visible Integer name or an earlier named
subtype resolves without allocating a value cell. -/
inductive ScalarTypeAt (text : Source) (state : ParserState) (position : Nat) :
    ScalarConstraintResult → Prop
  | integer {first after : Nat} :
      first = skipAt text position → after = nameAfter text first →
      first ≠ 0 → first < after →
      lookupName text state.names first after = 0 →
      ScalarExpression.lookup text state.scalarNames first after = 0 →
      ArrayBindings.lookup text state.arrayNames.names first after = 0 →
      BooleanBindings.lookup text state.booleanNames first after = 0 →
      Named.nameIs text first after ("integer".toList.map Char.toNat) = true →
      ScalarTypeAt text state position ⟨after, .full⟩
  | named {first after target : Nat} :
      first = skipAt text position → after = nameAfter text first →
      first ≠ 0 → first < after →
      lookupName text state.names first after = 0 →
      ScalarExpression.lookup text state.scalarNames first after = 0 →
      ArrayBindings.lookup text state.arrayNames.names first after = 0 →
      BooleanBindings.lookup text state.booleanNames first after = 0 →
      Named.nameIs text first after ("integer".toList.map Char.toNat) = false →
      target = IntegerSubtypes.lookup text state.subtypeNames first after → target ≠ 0 →
      ScalarTypeAt text state position ⟨after, (IntegerSubtypes.binding state.subtypeNames target).bounds⟩

theorem scalarTypeAt_sound (text : Source) (state : ParserState) (position : Nat)
    (positive : (scalarTypeAt text state position).after ≠ 0) :
    ScalarTypeAt text state position (scalarTypeAt text state position) := by
  unfold scalarTypeAt at positive ⊢
  dsimp only at positive ⊢
  split
  · simp_all
  · rename_i ready
    have good := ready
    simp only [not_or, Nat.not_le, ne_eq, Decidable.not_not] at good
    split
    · rename_i integer
      exact .integer rfl rfl good.1 good.2.1 good.2.2.1 good.2.2.2.1 good.2.2.2.2.1 good.2.2.2.2.2 integer
    · rename_i named
      split
      · rename_i found
        exact .named rfl rfl good.1 good.2.1 good.2.2.1 good.2.2.2.1 good.2.2.2.2.1 good.2.2.2.2.2
          (Bool.eq_false_iff.mpr named) rfl found
      · simp_all

theorem scalarTypeAt_complete {text state position result}
    (reading : ScalarTypeAt text state position result) : scalarTypeAt text state position = result := by
  cases reading with
  | integer first after positive advance strings scalars arrays booleans integer =>
      subst first; subst after
      simp_all [scalarTypeAt, Nat.not_le.mpr advance]
  | named first after positive advance strings scalars arrays booleans integer target nonzero =>
      subst first; subst after; subst target
      simp_all [scalarTypeAt, Nat.not_le.mpr advance]

theorem ScalarTypeAt.bounded {text state position result}
    (reading : ScalarTypeAt text state position result)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) : result.bounds.Bounded := by
  rw [← scalarTypeAt_complete reading]
  exact scalarTypeAt_bounded text state position valid

theorem ScalarTypeAt.nonempty {text state position result}
    (reading : ScalarTypeAt text state position result)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) : result.bounds.lower ≤ result.bounds.upper := by
  cases reading with
  | integer => exact (by decide : Integer.Interval.full.lower ≤ Integer.Interval.full.upper)
  | @named first after target _ _ _ _ _ _ _ _ _ found nonzero =>
      have bound := IntegerSubtypes.lookup_bound text state.subtypeNames first after
      rw [← found] at bound
      exact (valid.2 _ (subtypeBinding_mem (by omega) bound)).2.2.2.2

/-- Every admitted subtype names Integer directly and has a mandatory,
nonempty static range. Names of value objects remain unavailable as parents. -/
def SubtypeDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : SubtypeDeclarationParts) : Prop :=
  newNameAllowed text state parts.first parts.after arguments = true ∧
    Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) = false ∧
    state.subtypeNames.items.length ≠ IntegerSubtypes.maxBindings ∧
    parts.typeAfter ≠ 0 ∧ fixedAfter text parts.typeAfter "range" true ≠ 0 ∧
    parts.constraint.after ≠ 0 ∧ state.position < parts.following ∧
    parts.constraint.bounds.isEmpty = false ∧
    lookupName text state.names parts.typeFirst parts.typeAfter = 0 ∧
    ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter = 0 ∧
    ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter = 0 ∧
    BooleanBindings.lookup text state.booleanNames parts.typeFirst parts.typeAfter = 0

inductive SubtypeDeclarationAt (text : Source) (arguments : Bool) :
    ParserState → ParserState → Prop
  | declaration {state : ParserState} {parts : SubtypeDeclarationParts} :
      subtypeDeclarationParts text state = parts → SubtypeDeclarationReady text state arguments parts →
      ScalarConstraintAt text state.scalarNames parts.typeAfter .full parts.constraint →
      SubtypeDeclarationAt text arguments state (addSubtypeBinding text state parts)

theorem subtype_declaration_complete {text arguments state next}
    (reading : SubtypeDeclarationAt text arguments state next) : subtypeDeclarationAt text state arguments = next := by
  cases reading with
  | declaration parts ready _ =>
      rcases ready with ⟨allowed, own, count, after, range, constraint, following, nonempty, strings, scalars, arrays, booleans⟩
      simp_all [subtypeDeclarationAt, Nat.not_le.mpr following]

theorem subtype_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (subtypeDeclarationAt text state arguments).position ≠ 0) :
    SubtypeDeclarationAt text arguments state (subtypeDeclarationAt text state arguments) := by
  unfold subtypeDeclarationAt at accepted ⊢
  generalize partsEq : subtypeDeclarationParts text state = parts at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i good
    simp only [good, Bool.false_eq_true, ↓reduceIte]
    have ready : SubtypeDeclarationReady text state arguments parts := by
      simpa [SubtypeDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, and_assoc] using good
    have constraintEq : parts.constraint = scalarConstraintAt text parts.typeAfter state.scalarNames := by
      rw [← partsEq]
      rfl
    have typeBound : parts.typeAfter ≤ text.length + 1 := by
      rw [← partsEq]
      exact fixedAfter_result_bound text _ "integer" true (by decide)
    exact .declaration partsEq ready (constraintEq.symm ▸ scalarConstraintAt_sound text _ state.scalarNames
      typeBound (constraintEq ▸ ready.2.2.2.2.2.1))

theorem subtype_declaration_positive {text arguments state next}
    (reading : SubtypeDeclarationAt text arguments state next) : next.position ≠ 0 := by
  cases reading with
  | declaration _ ready _ =>
      have advance := ready.2.2.2.2.2.2.1
      dsimp only [addSubtypeBinding]
      omega

theorem subtype_declaration_preserves {text arguments state next}
    (reading : SubtypeDeclarationAt text arguments state next) :
    next.names = state.names ∧ next.scalarNames = state.scalarNames ∧ next.arrayNames = state.arrayNames := by
  cases reading
  exact ⟨rfl, rfl, rfl⟩

theorem subtype_declaration_valid {text arguments state next}
    (reading : SubtypeDeclarationAt text arguments state next)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    IntegerSubtypes.ValidEnvironment text next.subtypeNames := by
  cases reading with
  | @declaration parts partsEq ready constraint =>
      apply IntegerSubtypes.valid_append valid
      · have room := ready.2.2.1
        have limit := valid.1
        omega
      · have allowed := ready.1
        simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
        have nameBound : parts.after ≤ text.length + 1 := by
          rw [← partsEq]
          exact model_name_valid text _
        refine ⟨Nat.pos_of_ne_zero allowed.1.1.1.1, allowed.1.1.1.2, nameBound,
          constraint.bounded Integer.Interval.full_bounded, ?_⟩
        have nonempty := ready.2.2.2.2.2.2.2.1
        simpa only [Integer.Interval.isEmpty, decide_eq_false_iff_not, Int.not_lt] using nonempty

theorem subtype_declaration_hiding {text arguments state next} {otherNames : List (Nat × Nat)}
    (reading : SubtypeDeclarationAt text arguments state next)
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames otherNames) :
    IntegerSubtypes.HidingCorrect text next.subtypeNames otherNames := by
  cases reading
  exact IntegerSubtypes.hiding_append correct _

theorem subtype_declaration_unique {text arguments state left right}
    (first : SubtypeDeclarationAt text arguments state left)
    (second : SubtypeDeclarationAt text arguments state right) : left = right :=
  (subtype_declaration_complete first).symm.trans (subtype_declaration_complete second)

/-- An object's constraint is read after the exact type mark selected from
its declaration environment. The type mark and range are separate source facts. -/
structure ScalarObjectConstraintAt (text : Source) (state : ParserState) (position : Nat)
    (result : ScalarConstraintResult) : Prop where
  typeMark : ScalarTypeAt text state position (scalarTypeAt text state position)
  constraint : ScalarConstraintAt text state.scalarNames (scalarTypeAt text state position).after
    (scalarTypeAt text state position).bounds result

theorem ScalarObjectConstraintAt.bounded {text state position result}
    (reading : ScalarObjectConstraintAt text state position result)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) : result.bounds.Bounded :=
  reading.constraint.bounded (scalarTypeAt_bounded text state position valid)

end Silver.Compose
