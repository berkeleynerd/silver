module

public import Silver.PredicateBodyScanner
public import Silver.ComposeStringDeclarations
public import Silver.PredicateConditionSound
public import Silver.ScalarArrayAttributeSyntax

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
open Compose Bindings PathFacts Compose.Expressions

attribute [local irreducible] ScalarExpression.ArrayGrammar.read loopRange

theorem scalarRead_bound (text : Source) (position : Nat) (names : ScalarExpression.Environment)
    (first after : Nat) (arrays : ArrayBindings.Table := {}) (bounded : position ≤ text.length + 1)
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) :
    (ScalarExpression.ArrayGrammar.read (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names first after).after ≤ text.length + 1 := by
  by_cases zero : (ScalarExpression.ArrayGrammar.read (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names first after).after = 0
  · simp [zero]
  · obtain ⟨expression, parsed⟩ := ScalarExpression.ArrayGrammar.read_sound bounded zero
    exact parsed.cursorBounds.2.2

theorem loopLowerPosition_bound (text : Source) (scan : BodyScan) :
    loopLowerPosition text scan ≤ text.length + 1 := by
  have name := model_name_valid text (loopFirst text scan)
  have inside : loopInAfter text scan ≤ text.length + 1 := by
    unfold loopInAfter
    split
    · exact model_fixed_valid text _ "of" true name
    · exact model_fixed_valid text _ "in" true name
  unfold loopLowerPosition
  split
  · exact model_fixed_valid text (loopInAfter text scan) "reverse" true inside
  · exact inside

theorem loopRange_bound (text : Source) (context : ParseContext) (scan : BodyScan) :
    (loopRange text context scan).after ≤ text.length + 1 := by
  unfold loopRange ScalarExpression.ArrayAttributes.read
  split
  · exact Nat.zero_le _
  · rename_i parsed found
    exact (ScalarExpression.ArrayAttributes.parse_bounds (loopLowerPosition_bound text scan) found).2

theorem loopRange_of_at {text : Source} {context : ParseContext} {scan : BodyScan}
    {parsed : ScalarExpression.ArrayAttributes.ParsedQuery}
    (reading : ScalarExpression.ArrayAttributes.At text context.scalarNames context.arrayTable
      (loopLowerPosition text scan) (loopFirst text scan) (loopNameAfter text scan) true parsed) :
    loopRange text context scan = ⟨parsed.after, parsed.shape, 1, true⟩ := by
  have range : parsed.query = .range := by
    cases reading with
    | read _ _ _ _ _ _ _ _ word => exact word.1.mpr rfl
  simp only [loopRange, ScalarExpression.ArrayAttributes.read,
    ScalarExpression.ArrayAttributes.at_iff.mp reading,
    ScalarExpression.ArrayAttributes.ParsedQuery.result, range,
    ScalarExpression.ArrayAttributes.Query.bounds]

theorem loopRange_safe {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ArrayBindings.ValidTable text context.arrayTable)
    (positive : (loopRange text context scan).after ≠ 0) :
    (loopRange text context scan).bounds.Bounded ∧
      (loopRange text context scan).bounds.lower ≤ (loopRange text context scan).bounds.upper := by
  have contract := ScalarExpression.ArrayAttributes.read_contract
    (names := context.scalarNames) (maskFirst := loopFirst text scan)
    (maskAfter := loopNameAfter text scan) (rangeQuery := true)
    (loopLowerPosition_bound text scan) valid
  dsimp only at contract
  unfold loopRange at positive ⊢
  exact ⟨(contract.resolve_left positive).2.2.1, (contract.resolve_left positive).2.2.2.1⟩

/-- The source distinguishes ordinary counted bounds from one captured Range
query. Range endpoints are literal semantic values, not fabricated source reads. -/
inductive LoopBoundsAt (text : Source) (context : ParseContext) (scan : BodyScan) :
    Integer.Expr → Integer.Expr → Prop
  | counted {lower upper} : (loopRange text context scan).after = 0 →
      ScalarExpression.ArrayGrammar.At (arrays := context.arrayTable) (elaborating := context.elaborating)
        text (context.readingNames scan.facts) (loopLowerPosition text scan)
        lower (loopHeader text context scan).lower (loopFirst text scan) (loopNameAfter text scan) →
      ScalarExpression.ArrayGrammar.At (arrays := context.arrayTable) (elaborating := context.elaborating)
        text (context.readingNames scan.facts)
        (fixedAfter text (loopHeader text context scan).lower.after ".." false)
        upper (loopHeader text context scan).upper (loopFirst text scan) (loopNameAfter text scan) →
      LoopBoundsAt text context scan lower upper
  | range {parsed} :
      ScalarExpression.ArrayAttributes.At text context.scalarNames context.arrayTable
        (loopLowerPosition text scan) (loopFirst text scan) (loopNameAfter text scan) true parsed →
      LoopBoundsAt text context scan (.literal parsed.shape.lower) (.literal parsed.shape.upper)

theorem LoopBoundsAt.unique {text context scan leftLower leftUpper rightLower rightUpper}
    (left : LoopBoundsAt text context scan leftLower leftUpper)
    (right : LoopBoundsAt text context scan rightLower rightUpper) :
    leftLower = rightLower ∧ leftUpper = rightUpper := by
  have present {parsed} (reading : ScalarExpression.ArrayAttributes.At text context.scalarNames context.arrayTable
      (loopLowerPosition text scan) (loopFirst text scan) (loopNameAfter text scan) true parsed) :
      (loopRange text context scan).after ≠ 0 := by
    rw [loopRange_of_at reading]
    have advance := (ScalarExpression.ArrayAttributes.parse_bounds (loopLowerPosition_bound text scan)
      (ScalarExpression.ArrayAttributes.at_iff.mp reading)).1
    dsimp only
    omega
  cases left with
  | counted absent low high =>
      cases right with
      | counted _ otherLow otherHigh =>
          exact ⟨(ScalarExpression.ArrayGrammar.at_unique low otherLow).1,
            (ScalarExpression.ArrayGrammar.at_unique high otherHigh).1⟩
      | range reading => exact False.elim (present reading absent)
  | range reading =>
      cases right with
      | counted absent _ _ => exact False.elim (present reading absent)
      | range other =>
          have same := Option.some.inj ((ScalarExpression.ArrayAttributes.at_iff.mp reading).symm.trans
            (ScalarExpression.ArrayAttributes.at_iff.mp other))
          cases same
          exact ⟨rfl, rfl⟩

theorem loopHeader_bound (text : Source) (context : ParseContext) (scan : BodyScan) :
    (loopHeader text context scan).entry.position ≤ text.length + 1 := by
  by_cases isArray : loopIsArray text scan = true
  · simp only [loopHeader, isArray, ↓reduceIte]
    split
    · exact model_fixed_valid text _ "loop" true (model_name_valid text _)
    · exact Nat.zero_le _
  · have counted : loopIsArray text scan = false := Bool.eq_false_iff.mpr isArray
    by_cases range : (loopRange text context scan).after ≠ 0
    · simp only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte]
      rw [ite_eq_left range]
      exact model_fixed_valid text _ "loop" true (loopRange_bound text context scan)
    · have lower := readCountedBound_bound text context (loopLowerPosition text scan) scan.facts
        (loopFirst text scan) (loopNameAfter text scan) (loopLowerPosition_bound text scan)
      have delimiter := model_fixed_valid text _ ".." false lower
      have upper := readCountedBound_bound text context _ scan.facts
        (loopFirst text scan) (loopNameAfter text scan) delimiter
      simpa only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte, range, ValidCursor] using
        model_fixed_valid text _ "loop" true upper

theorem loopHeader_readings {text : Source} {context : ParseContext} {scan : BodyScan}
    (counted : loopIsArray text scan = false) (positive : (loopHeader text context scan).entry.position ≠ 0) :
    ∃ lower upper, LoopBoundsAt text context scan lower upper := by
  by_cases range : (loopRange text context scan).after ≠ 0
  · unfold loopRange ScalarExpression.ArrayAttributes.read at range
    split at range
    · exact False.elim (range rfl)
    · rename_i parsed found
      exact ⟨_, _, .range (ScalarExpression.ArrayAttributes.at_iff.mpr found)⟩
  · have absent : (loopRange text context scan).after = 0 := Classical.not_not.mp range
    simp only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte, range] at positive
    have upperPositive := fixedAfter_nonzero positive
    have lowerBound := readCountedBound_bound text context (loopLowerPosition text scan) scan.facts
      (loopFirst text scan) (loopNameAfter text scan) (loopLowerPosition_bound text scan)
    have delimiter := model_fixed_valid text _ ".." false lowerBound
    have upperOriginal := readCountedBound_original upperPositive
    rw [upperOriginal] at upperPositive
    obtain ⟨upper, upperRead⟩ := ScalarExpression.ArrayGrammar.read_sound delimiter upperPositive
    have lowerPositive := fixedAfter_nonzero (Nat.ne_of_gt upperRead.cursorBounds.1)
    have lowerOriginal := readCountedBound_original lowerPositive
    rw [lowerOriginal] at lowerPositive
    obtain ⟨lower, lowerRead⟩ := ScalarExpression.ArrayGrammar.read_sound (loopLowerPosition_bound text scan) lowerPositive
    refine ⟨lower, upper, .counted absent ?_ ?_⟩
    · simpa only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte, range, lowerOriginal, readScalarInFlow] using lowerRead
    · simpa only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte, range, upperOriginal, readScalarInFlow] using upperRead

theorem LoopBoundsAt.inferred {text context scan lower upper}
    (reading : LoopBoundsAt text context scan lower upper)
    (counted : loopIsArray text scan = false)
    (valid : ArrayBindings.ValidTable text context.arrayTable) :
    lower.infer (ArrayBindings.viewRanges context.arrayNames [] context.elaborating
      (ScalarExpression.ranges (context.readingNames scan.facts))) = some (loopHeader text context scan).lower.bounds ∧
    upper.infer (ArrayBindings.viewRanges context.arrayNames [] context.elaborating
      (ScalarExpression.ranges (context.readingNames scan.facts))) = some (loopHeader text context scan).upper.bounds := by
  cases reading with
  | counted _ low high => exact ⟨low.inferred, high.inferred⟩
  | range reading =>
      have found := ScalarExpression.ArrayAttributes.at_iff.mp reading
      have bounds := ScalarExpression.ArrayAttributes.parse_bounds (loopLowerPosition_bound text scan) found
      have shape := ScalarExpression.ArrayAttributes.parse_shape valid found
      have positive : (loopRange text context scan).after ≠ 0 := by
        rw [loopRange_of_at reading]
        dsimp only
        omega
      have literal (value : Int) (bounded : Integer.InRange value) (ranges : Integer.Ranges) :
          (Integer.Expr.literal value).infer ranges = some (.singleton value) := by
        have singleton : (Integer.Interval.singleton value).Bounded := ⟨bounded, bounded⟩
        have nonempty : (Integer.Interval.singleton value).isEmpty = false := by
          simp [Integer.Interval.isEmpty, Integer.Interval.singleton]
        simp only [Integer.Expr.infer, Integer.accepted, Integer.checked, nonempty,
          Bool.false_eq_true, ↓reduceIte, singleton]
      simp only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte]
      rw [ite_eq_left positive, ite_eq_left positive, loopRange_of_at reading]
      exact ⟨literal _ shape.1.1 _, literal _ shape.1.2 _⟩

theorem loopHeader_bounds_bounded {text : Source} {context : ParseContext} {scan : BodyScan}
    (arrays : ArrayBindings.ValidTable text context.arrayTable)
    (positive : (loopHeader text context scan).entry.position ≠ 0) :
    (loopHeader text context scan).bounds.Bounded := by
  by_cases isArray : loopIsArray text scan = true
  · simpa only [LoopHeader.bounds, loopHeader, isArray, ↓reduceIte, ArrayBindings.Binding.descriptor, ParseContext.arrayTable] using
      (ArrayBindings.binding_components_valid (fun entry found => (arrays.member_valid found).2.1.1)
        (loopArrayTarget text context scan)).1
  · have counted := Bool.eq_false_iff.mpr isArray
    obtain ⟨lower, upper, reading⟩ := loopHeader_readings counted positive
    have inferred := reading.inferred counted arrays
    simpa only [LoopHeader.bounds, loopHeader, counted, Bool.false_eq_true, ↓reduceIte] using
      Integer.loopBounds_bounded (Integer.Expr.infer_bounded inferred.1)
        (Integer.Expr.infer_bounded inferred.2)

theorem loopNameAllowed_space {text : Source} {context : ParseContext} {header : LoopHeader}
    (size : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (allowed : loopNameAllowed text context header = true) :
    context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit := by
  simp only [loopNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
  have different := allowed.2
  change context.scalarNames.length ≠ ArrayBindings.scalarLimit at different
  omega

@[simp] theorem loopInner_flow (context : ParseContext) (header : LoopHeader) (facts : ActiveFlow) :
    (loopInner context header).flow facts = context.flow facts := rfl

theorem loopInner_arraysReady {text : Source} {context : ParseContext} (header : LoopHeader)
    (ready : context.ArraysReady text) : (loopInner context header).ArraysReady text := ready

theorem loopInner_valid_environment {text : Source} {context : ParseContext} {scan : BodyScan}
    (arrays : ArrayBindings.ValidTable text context.arrayTable)
    (valid : ScalarExpression.ValidEnvironment text context.scalarNames)
    (allowed : loopNameAllowed text context (loopHeader text context scan) = true)
    (positive : (loopHeader text context scan).entry.position ≠ 0) :
    ScalarExpression.ValidEnvironment text (loopInner context (loopHeader text context scan)).scalarNames := by
  have typed := loopHeader_bounds_bounded arrays positive
  simp only [loopNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
  have firstPositive := allowed.1.1.1.1
  have ordered := allowed.1.1.1.2
  have space := allowed.2
  have afterBound := model_name_valid text (loopFirst text scan)
  exact ScalarExpression.validEnvironment_append valid (by have := valid.1; omega)
    ⟨Nat.pos_of_ne_zero firstPositive, ordered, afterBound,
      typed, typed, Or.inl ⟨rfl, rfl⟩⟩

theorem loopBody_shape {text : Source} {context : ParseContext} {scan : BodyScan}
    (positive : (loopBody (catalog := catalog) (procedures := procedures) text context scan).position ≠ 0) :
    let header := loopHeader text context scan
    let body := readBody (catalog := catalog) (procedures := procedures) text (loopInner context header) header.entry .endOnly
    loopNameAllowed text context header = true ∧
      scan.position < header.entry.position ∧
      bodyRemaining text header.entry < bodyRemaining text scan ∧
      scan.position < body.position ∧
      loopBody (catalog := catalog) (procedures := procedures) text context scan = bodyTokens text
        {body with facts := loopAfterHeader context scan.facts body.facts header}
        [.word "end", .word "loop", .symbol ";"] ∧
      scan.position < (bodyTokens text
        {body with facts := loopAfterHeader context scan.facts body.facts header}
        [.word "end", .word "loop", .symbol ";"]).position := by
  rw [loopBody] at positive ⊢
  dsimp only at positive ⊢
  split at positive
  · exact False.elim (positive rfl)
  · rename_i allowed
    have ready : loopNameAllowed text context (loopHeader text context scan) = true := by
      cases good : loopNameAllowed text context (loopHeader text context scan) <;> simp_all
    simp only [ready, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    split at positive
    · exact False.elim (positive rfl)
    · rename_i advance
      simp only [advance, ↓reduceIte]
      split at positive
      · rename_i remaining
        simp only [remaining, ↓reduceDIte]
        split at positive
        · exact False.elim (positive rfl)
        · rename_i bodyAdvance
          simp only [bodyAdvance, ↓reduceIte]
          split at positive
          · exact False.elim (positive rfl)
          · rename_i finish
            simp only [finish, ↓reduceIte]
            exact ⟨trivial, Nat.lt_of_not_ge advance, trivial, Nat.lt_of_not_ge bodyAdvance, trivial, Nat.lt_of_not_ge finish⟩
      · exact False.elim (positive rfl)

theorem loopBody_progress (text : Source) (context : ParseContext) (scan : BodyScan)
    (positive : (loopBody (catalog := catalog) (procedures := procedures) text context scan).position ≠ 0) :
    scan.position < (loopBody (catalog := catalog) (procedures := procedures) text context scan).position := by
  have shape := loopBody_shape (catalog := catalog) (procedures := procedures) positive
  rw [shape.2.2.2.2.1]
  exact shape.2.2.2.2.2

end Silver.Predicate
