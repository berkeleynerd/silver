module

public import Silver.PredicateBodyScanner
public import Silver.ComposeStringDeclarations
public import Silver.PredicateConditionSound

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata}
open Compose Bindings PathFacts Compose.Expressions

attribute [local irreducible] ScalarExpression.read

theorem scalarRead_bound (text : Source) (position : Nat) (names : ScalarExpression.Environment)
    (first after : Nat) (arrays : ArrayBindings.Metadata := []) (bounded : position ≤ text.length + 1)
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) :
    (ScalarExpression.read (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names first after).after ≤ text.length + 1 := by
  by_cases zero : (ScalarExpression.read (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names first after).after = 0
  · simp [zero]
  · obtain ⟨expression, parsed⟩ := ScalarExpression.read_sound bounded zero
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

theorem loopHeader_bound (text : Source) (context : ParseContext) (scan : BodyScan) :
    (loopHeader text context scan).entry.position ≤ text.length + 1 := by
  by_cases isArray : loopIsArray text scan = true
  · simp only [loopHeader, isArray, ↓reduceIte]
    split
    · exact model_fixed_valid text _ "loop" true (model_name_valid text _)
    · exact Nat.zero_le _
  · have counted : loopIsArray text scan = false := Bool.eq_false_iff.mpr isArray
    have lower := readCountedBound_bound text context (loopLowerPosition text scan) scan.facts
      (loopFirst text scan) (loopNameAfter text scan) (loopLowerPosition_bound text scan)
    have delimiter := model_fixed_valid text _ ".." false lower
    have upper := readCountedBound_bound text context _ scan.facts
      (loopFirst text scan) (loopNameAfter text scan) delimiter
    simpa only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte, ValidCursor] using
      model_fixed_valid text _ "loop" true upper

theorem loopHeader_readings {text : Source} {context : ParseContext} {scan : BodyScan}
    (counted : loopIsArray text scan = false) (positive : (loopHeader text context scan).entry.position ≠ 0) :
    ∃ lower upper,
      ScalarExpression.At (arrays := context.arrayNames) (elaborating := context.elaborating) text (context.readingNames scan.facts) (loopLowerPosition text scan)
        lower (loopHeader text context scan).lower (loopFirst text scan) (loopNameAfter text scan) ∧
      ScalarExpression.At (arrays := context.arrayNames) (elaborating := context.elaborating) text (context.readingNames scan.facts)
        (fixedAfter text (loopHeader text context scan).lower.after ".." false)
        upper (loopHeader text context scan).upper (loopFirst text scan) (loopNameAfter text scan) := by
  simp only [loopHeader, counted, Bool.false_eq_true, ↓reduceIte] at positive ⊢
  have upperPositive := fixedAfter_nonzero positive
  have lowerBound := readCountedBound_bound text context (loopLowerPosition text scan) scan.facts
    (loopFirst text scan) (loopNameAfter text scan) (loopLowerPosition_bound text scan)
  have delimiter := model_fixed_valid text _ ".." false lowerBound
  have upperOriginal := readCountedBound_original upperPositive
  rw [upperOriginal] at upperPositive
  obtain ⟨upper, upperRead⟩ := ScalarExpression.read_sound delimiter upperPositive
  have lowerPositive := fixedAfter_nonzero (Nat.ne_of_gt upperRead.cursorBounds.1)
  have lowerOriginal := readCountedBound_original lowerPositive
  rw [lowerOriginal] at lowerPositive
  obtain ⟨lower, lowerRead⟩ := ScalarExpression.read_sound (loopLowerPosition_bound text scan) lowerPositive
  exact ⟨lower, upper, by simpa only [lowerOriginal, readScalarInFlow] using lowerRead,
    by simpa only [upperOriginal, readScalarInFlow] using upperRead⟩

theorem loopHeader_bounds_bounded {text : Source} {context : ParseContext} {scan : BodyScan}
    (arrays : ArrayBindings.ValidMetadata text context.arrayNames)
    (positive : (loopHeader text context scan).entry.position ≠ 0) :
    (loopHeader text context scan).bounds.Bounded := by
  by_cases isArray : loopIsArray text scan = true
  · simpa only [LoopHeader.bounds, loopHeader, isArray, ↓reduceIte, ArrayBindings.Binding.descriptor] using
      (ArrayBindings.binding_components_valid (fun entry found => (arrays.2.1 entry found).2.2.2)
        (loopArrayTarget text context scan)).1
  · have counted := Bool.eq_false_iff.mpr isArray
    obtain ⟨lower, upper, lowerRead, upperRead⟩ := loopHeader_readings counted positive
    simpa only [LoopHeader.bounds, loopHeader, counted, Bool.false_eq_true, ↓reduceIte] using
      Integer.loopBounds_bounded (Integer.Expr.infer_bounded lowerRead.inferred)
        (Integer.Expr.infer_bounded upperRead.inferred)

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
    (arrays : ArrayBindings.ValidMetadata text context.arrayNames)
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
      typed, typed⟩

theorem loopBody_shape {text : Source} {context : ParseContext} {scan : BodyScan}
    (positive : (loopBody (catalog := catalog) text context scan).position ≠ 0) :
    let header := loopHeader text context scan
    let body := readBody (catalog := catalog) text (loopInner context header) header.entry .endOnly
    loopNameAllowed text context header = true ∧
      scan.position < header.entry.position ∧
      bodyRemaining text header.entry < bodyRemaining text scan ∧
      scan.position < body.position ∧
      loopBody (catalog := catalog) text context scan = bodyTokens text
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
    (positive : (loopBody (catalog := catalog) text context scan).position ≠ 0) :
    scan.position < (loopBody (catalog := catalog) text context scan).position := by
  have shape := loopBody_shape (catalog := catalog) positive
  rw [shape.2.2.2.2.1]
  exact shape.2.2.2.2.2

end Silver.Predicate
