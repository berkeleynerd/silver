module

public import Silver.ComposeAtomReading

@[expose] public section

namespace Silver.Compose
open Named Bindings

/-- The source judgment retains each scalar source tree, its inferred interval,
the actual selected String metadata and the shared operand count. -/
structure IndexedReading (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating element : Bool) (position : Nat)
    (info : BindingInfo) (lower upper : Integer.Expr) : Prop where
  targetPositive : (indexedParts text position names scalarNames arrays initials elaborating element).target ≠ 0
  selected : names.get (indexedParts text position names scalarNames arrays initials elaborating element).target = some info
  stringTyped : info.isCharacter = false
  fixed : info.dynamic = false
  unmasked : ScalarExpression.lookup text scalarNames
    (indexedParts text position names scalarNames arrays initials elaborating element).first
    (indexedParts text position names scalarNames arrays initials elaborating element).after = 0
  lowerSource : ScalarExpression.At text scalarNames
    (fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating element).after "(" false)
    lower (indexedParts text position names scalarNames arrays initials elaborating element).lower
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  lowerNonempty : (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.isEmpty = false
  following : position < (indexedParts text position names scalarNames arrays initials elaborating element).following
  elementBounds : element = true →
    (indexedParts text position names scalarNames arrays initials elaborating element).lower.operands ≠ maxExpressionOperands ∧
    info.firstIndex ≤ (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.lower ∧
    (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.upper ≤ info.lastIndex
  upperSource : element = false → ScalarExpression.At text scalarNames
    (fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating element).lower.after ".." false)
    upper (indexedParts text position names scalarNames arrays initials elaborating element).upper
    (arrays := arrays) (initials := initials) (elaborating := elaborating)
  sliceBounds : element = false →
    (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds.isEmpty = false ∧
    (indexedParts text position names scalarNames arrays initials elaborating element).lower.operands +
      (indexedParts text position names scalarNames arrays initials elaborating element).upper.operands < maxExpressionOperands ∧
    ((indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.lower >
      (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds.upper ∨
      (info.firstIndex ≤ (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.lower ∧
       (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds.upper ≤ info.lastIndex)) ∧
    StringIndexing.sliceMaximum
      (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds
      (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds ≤ maxSourceLength
  nativeSpan : element = false →
    (indexedParts text position names scalarNames arrays initials elaborating element).lower.bounds.upper -
      (indexedParts text position names scalarNames arrays initials elaborating element).upper.bounds.lower ≤ Integer.maxValue
  guardedStatic : element = false →
    ((!((indexedParts text position names scalarNames arrays initials elaborating element).lower.isStatic) ||
      !((indexedParts text position names scalarNames arrays initials elaborating element).upper.isStatic)) &&
      guardedAt text 1 position 0 false false) = false

def indexedValue (parts : IndexedParts) (element : Bool) : ValueResult :=
  if element then
    ⟨parts.following, 0, 1, 1, false, true, false, parts.target,
      parts.lower.operands + 1, .singleton 1, .singleton 1⟩
  else
    ⟨parts.following, 0, StringIndexing.sliceMinimum parts.lower.bounds parts.upper.bounds,
      StringIndexing.sliceMaximum parts.lower.bounds parts.upper.bounds, false, true, false,
      parts.target, parts.lower.operands + parts.upper.operands + 1, parts.lower.bounds, parts.upper.bounds⟩

theorem indexed_complete {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating element : Bool} {position : Nat}
    {info : BindingInfo} {lower upper : Integer.Expr}
    (parsed : IndexedReading text names scalarNames arrays initials elaborating element position info lower upper) :
    indexedAt text position names scalarNames arrays initials elaborating element =
      indexedValue (indexedParts text position names scalarNames arrays initials elaborating element) element := by
  have lowerPositive : (indexedParts text position names scalarNames arrays initials elaborating element).lower.after ≠ 0 :=
    by have := parsed.lowerSource.cursorBounds; omega
  cases element with
  | true =>
      have bounds := parsed.elementBounds rfl
      simp [indexedAt, indexedValue, parsed.selected, parsed.targetPositive, parsed.stringTyped,
        parsed.fixed, parsed.unmasked, lowerPositive, parsed.lowerNonempty,
        Nat.not_le.mpr parsed.following, bounds.1, Int.not_lt.mpr bounds.2.1,
        Int.not_lt.mpr bounds.2.2]
  | false =>
      have bounds := parsed.sliceBounds rfl
      have contained : ¬ ((indexedParts text position names scalarNames arrays initials elaborating false).lower.bounds.lower ≤
          (indexedParts text position names scalarNames arrays initials elaborating false).upper.bounds.upper ∧
          ((indexedParts text position names scalarNames arrays initials elaborating false).lower.bounds.lower < info.firstIndex ∨
           info.lastIndex < (indexedParts text position names scalarNames arrays initials elaborating false).upper.bounds.upper)) := by
        rcases bounds.2.2.1 with empty | contained <;> omega
      simp [indexedAt, indexedValue, parsed.selected, parsed.targetPositive, parsed.stringTyped,
        parsed.fixed, parsed.unmasked, lowerPositive, parsed.lowerNonempty,
        Nat.not_le.mpr parsed.following, bounds.1, Nat.not_le.mpr bounds.2.1,
        contained, Nat.not_lt.mpr bounds.2.2.2, Int.not_lt.mpr (parsed.nativeSpan rfl),
        parsed.guardedStatic rfl]

theorem indexed_sound {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating element : Bool} {position : Nat}
    (accepted : (indexedAt text position names scalarNames arrays initials elaborating element).after ≠ 0) :
    ∃ info lower upper, IndexedReading text names scalarNames arrays initials elaborating element position info lower upper := by
  unfold indexedAt at accepted
  dsimp only at accepted
  split at accepted
  · simp [invalidValue] at accepted
  · rename_i ready
    simp only [not_or, Bool.not_eq_true] at ready
    obtain ⟨_, _, info, present, _⟩ := lookupName_found ready.1
    have present' : names.get (indexedParts text position names scalarNames arrays initials elaborating element).target = some info := present
    simp only [present', Option.getD_some] at ready
    obtain ⟨lower, lowerSource⟩ := ScalarExpression.read_sound
      (fixedAfter_result_bound text _ "(" false (by decide)) ready.2.2.2.2.1
    have source : ScalarExpression.At text scalarNames
        (fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating element).after "(" false)
        lower (indexedParts text position names scalarNames arrays initials elaborating element).lower
        (arrays := arrays) (initials := initials) (elaborating := elaborating) := lowerSource
    cases element with
    | true =>
        simp only [↓reduceIte, present', Option.getD_some] at accepted
        split at accepted
        · simp [invalidValue] at accepted
        · rename_i bounds
          simp only [not_or, Nat.not_le, Int.not_lt] at bounds
          exact ⟨info, lower, .literal 0, ready.1, present', ready.2.1, ready.2.2.1,
            (by omega), source, ready.2.2.2.2.2, bounds.1,
            fun _ => ⟨bounds.2.1, bounds.2.2⟩, by simp, by simp, by simp, by simp⟩
    | false =>
        simp only [Bool.false_eq_true, ↓reduceIte, present', Option.getD_some] at accepted
        split at accepted
        · simp [invalidValue] at accepted
        · rename_i bounds
          simp only [not_or, Nat.not_le, Bool.not_eq_true] at bounds
          split at accepted
          · simp [invalidValue] at accepted
          · rename_i maximum
            have upperPositive : (indexedParts text position names scalarNames arrays initials elaborating false).upper.after ≠ 0 := by
              intro zero
              have progress := bounds.1
              change position < fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating false).upper.after ")" false at progress
              simp [zero, fixedAfter] at progress
            obtain ⟨upper, upperSource⟩ := ScalarExpression.read_sound
              (fixedAfter_result_bound text _ ".." false (by decide)) upperPositive
            have upperSource' : ScalarExpression.At text scalarNames
                (fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating false).lower.after ".." false)
                upper (indexedParts text position names scalarNames arrays initials elaborating false).upper
                (arrays := arrays) (initials := initials) (elaborating := elaborating) := upperSource
            refine ⟨info, lower, upper, ready.1, present', ready.2.1, ready.2.2.1,
              (by omega), source, ready.2.2.2.2.2, bounds.1, by simp,
              fun _ => upperSource', fun _ => ⟨bounds.2.1, bounds.2.2.1, ?_, by omega⟩,
              fun _ => by have span := bounds.2.2.2.1; omega,
              fun _ => bounds.2.2.2.2.1⟩
            have contained := bounds.2.2.2.2.2
            omega

theorem indexed_check {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {info : BindingInfo} {lower upper : Integer.Expr} (normal : NamesNormal names)
    (parsed : IndexedReading text names scalarNames arrays initials elaborating true position info lower upper) :
    (Character.Expr.indexed
      (indexedParts text position names scalarNames arrays initials elaborating true).target info.firstIndex lower).check
      names.shape.fixedLengths (ArrayBindings.integerRanges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = true := by
  have metadata := (normal.typed _ _ parsed.selected).2 parsed.fixed
  have bounds := parsed.elementBounds rfl
  have nonempty := parsed.lowerNonempty
  simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
  simp only [Character.Expr.check, fixedLengths_of_info parsed.selected parsed.fixed,
    parsed.lowerSource.inferred, StringIndexing.indexCheck, decide_eq_true_eq]
  omega

theorem slice_check {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {info : BindingInfo} {lower upper : Integer.Expr} (normal : NamesNormal names)
    (parsed : IndexedReading text names scalarNames arrays initials elaborating false position info lower upper) :
    StringIndexing.sliceCheck info.firstIndex info.staticLength
      (indexedParts text position names scalarNames arrays initials elaborating false).lower.bounds
      (indexedParts text position names scalarNames arrays initials elaborating false).upper.bounds = true := by
  have metadata := (normal.typed _ _ parsed.selected).2 parsed.fixed
  have bounds := parsed.sliceBounds rfl
  have nativeSpan := parsed.nativeSpan rfl
  have nonempty := parsed.lowerNonempty
  have upperNonempty := bounds.1
  simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty upperNonempty
  simp only [StringIndexing.sliceCheck, decide_eq_true_eq]
  rcases bounds.2.2.1 with empty | contained <;> omega

theorem indexed_unique {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating element : Bool} {position : Nat}
    {leftInfo rightInfo : BindingInfo} {leftLower leftUpper rightLower rightUpper : Integer.Expr}
    (left : IndexedReading text names scalarNames arrays initials elaborating element position leftInfo leftLower leftUpper)
    (right : IndexedReading text names scalarNames arrays initials elaborating element position rightInfo rightLower rightUpper) :
    leftInfo = rightInfo ∧ leftLower = rightLower ∧ (element = false → leftUpper = rightUpper) := by
  exact ⟨Option.some.inj (left.selected.symm.trans right.selected),
    (ScalarExpression.at_unique left.lowerSource right.lowerSource).1,
    fun slice => (ScalarExpression.at_unique (left.upperSource slice) (right.upperSource slice)).1⟩

end Silver.Compose
