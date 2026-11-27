module

public import Silver.ApplicationPackageDeclarationsObjectFrameDomains
public import Silver.ApplicationPackageObjectRows
public import Silver.ComposeBooleanArrayTrace
public import Silver.IntegerExpressions

@[expose] public section

/-! The inventory is obtained from the original Object reader's successful
execution. In particular its expressions, scopes and arithmetic obligations
are conclusions of that execution, not an additional acceptance certificate. -/
namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations
open ApplicationPackageObjectRows ApplicationPackageNames

set_option backward.dsimp.instances true

/-- Exact calls made before the new binding is appended. The scalar interval
is the inferred initializer interval; the type interval remains separate. -/
structure ValueCalls (text : Source) (base : ParserState) (first last : Nat)
    (out : ObjectResult) : Prop where
  cursor : ValidCursor text out.initFirst
  scalar : out.mark.kind = .integer →
    let value := ScalarExpression.read text out.initFirst base.scalarNames first last (elaborating := true)
    value.after = out.initAfter ∧ value.after ≠ 0 ∧ value.bounds = out.initialBounds ∧
      value.bounds.isEmpty = false ∧ value.bounds.included out.mark.bounds = true
  boolean : out.mark.kind = .boolean →
    booleanInitializerAfter text base out.initFirst first last = out.initAfter ∧ out.initAfter ≠ 0

private def ValueSuccess (text : Source) (base : ParserState) (first last : Nat)
    (out : ObjectResult) : Prop := out.frame.position ≠ 0 → ValueCalls text base first last out

private theorem rejected_value (text : Source) (base : ParserState) (first last : Nat) :
    ValueSuccess text base first last invalidObject := fun present => (present rfl).elim

private theorem finish_value (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original base : ParserState) (first last : Nat) (out : ObjectResult)
    (calls : ValueCalls text base first last out) :
    ValueSuccess text base first last (finishObject (modelObjectCalls reader) text original out) := by
  dsimp only [finishObject]
  split
  · exact rejected_value _ _ _ _
  · exact fun _ => ⟨calls.cursor, calls.scalar, calls.boolean⟩

private theorem scalar_value (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original : ParserState) (first last constant : Nat) (localObject : Bool)
    (seed : ObjectResult) (range : ScalarConstraintResult)
    (cursor : ValidCursor text seed.initFirst) (kind : seed.mark.kind = .integer)
    (declared : seed.mark.bounds = range.bounds) :
    ValueSuccess text seed.frame first last
      (objectScalar (modelObjectCalls reader) text original first last constant localObject seed range) := by
  dsimp only [objectScalar, modelObjectCalls]
  split
  · exact rejected_value _ _ _ _
  · rename_i accepted
    let value := ScalarExpression.read text seed.initFirst seed.frame.scalarNames first last (elaborating := true)
    have positive : value.after ≠ 0 := fun missing => accepted (by
      change ((((decide (value.after = 0) || value.bounds.isEmpty) || _) || _) || _) = true
      simp only [missing, decide_true, Bool.true_or])
    have nonempty : value.bounds.isEmpty = false := by
      cases empty : value.bounds.isEmpty
      · rfl
      · exact (accepted (by
          change ((((decide (value.after = 0) || value.bounds.isEmpty) || _) || _) || _) = true
          simp only [empty, Bool.or_true, Bool.true_or])).elim
    have inside : (!range.bounds.isEmpty && decide (value.bounds.lower ≥ range.bounds.lower) &&
        decide (value.bounds.upper ≤ range.bounds.upper)) = true := by
      cases found : !range.bounds.isEmpty && decide (value.bounds.lower ≥ range.bounds.lower) &&
          decide (value.bounds.upper ≤ range.bounds.upper)
      · exact (accepted (by
          change ((((decide (value.after = 0) || value.bounds.isEmpty) ||
            !(value.bounds.isEmpty || (!range.bounds.isEmpty && decide (value.bounds.lower ≥ range.bounds.lower) &&
              decide (value.bounds.upper ≤ range.bounds.upper)))) || _) || _) = true
          simp only [nonempty, found, Bool.false_or, Bool.not_false, Bool.or_true, Bool.true_or])).elim
      · rfl
    have parts := Bool.and_eq_true_iff.mp inside
    have included : value.bounds.included range.bounds = true := by
      simp only [Integer.Interval.included, nonempty, Bool.false_or, decide_eq_true_eq]
      exact ⟨of_decide_eq_true (Bool.and_eq_true_iff.mp parts.1).2, of_decide_eq_true parts.2⟩
    apply finish_value
    refine ⟨cursor, fun _ => ⟨rfl, positive, rfl, nonempty, ?_⟩, ?_⟩
    · simpa only [declared] using included
    · intro impossible
      simp [kind] at impossible

private theorem boolean_finish_value (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original base : ParserState) (first last constant after : Nat) (localObject : Bool)
    (seed : ObjectResult) (cursor : ValidCursor text seed.initFirst)
    (kind : seed.mark.kind = .boolean)
    (read : booleanInitializerAfter text base seed.initFirst first last = after)
    (positive : after ≠ 0) :
    ValueSuccess text base first last
      (objectBooleanFinish (modelObjectCalls reader) text original first last constant after localObject seed) := by
  dsimp only [objectBooleanFinish]
  apply finish_value
  refine ⟨cursor, ?_, fun _ => ⟨read, positive⟩⟩
  intro impossible
  simp [kind] at impossible

private theorem boolean_value (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original : ParserState) (first last constant : Nat) (localObject : Bool)
    (seed : ObjectResult) (cursor : ValidCursor text seed.initFirst) (kind : seed.mark.kind = .boolean) :
    ValueSuccess text seed.frame first last
      (objectBoolean (modelObjectCalls reader) text original first last constant localObject seed) := by
  dsimp only [objectBoolean]
  split
  · exact rejected_value _ _ _ _
  · rename_i accepted
    have positive : booleanInitializerAfter text seed.frame seed.initFirst first last ≠ 0 :=
      fun missing => accepted (by simp only [modelObjectCalls, missing, decide_true, Bool.true_or])
    split
    · split
      · exact rejected_value _ _ _ _
      · exact boolean_finish_value reader text original seed.frame first last constant _ localObject _ cursor kind rfl positive
    · exact boolean_finish_value reader text original seed.frame first last constant _ localObject _ cursor kind rfl positive

private theorem initialized_value (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original : ParserState) (first last constant : Nat) (localObject : Bool)
    (seed : ObjectResult) (range : ScalarConstraintResult) (cursor : ValidCursor text range.after) :
    ValueSuccess text seed.frame first last
      (objectInitialized (modelObjectCalls reader) text original first last constant localObject seed range) := by
  let marked := {seed with mark := {seed.mark with bounds := range.bounds}}
  let started := {marked with initFirst := skipAt text (tokenAfter text range.after (.symbol ":="))}
  change ValueSuccess text seed.frame first last (if decide (started.initFirst = 0) then invalidObject else
    if decide (started.mark.kind = .integer) then
      objectScalar (modelObjectCalls reader) text original first last constant localObject started range
    else objectBoolean (modelObjectCalls reader) text original first last constant localObject started)
  have start : ValidCursor text started.initFirst :=
    model_skip_valid text _ (model_fixed_valid text _ ":=" false cursor)
  split
  · exact rejected_value _ _ _ _
  · split
    · exact scalar_value reader text original first last constant localObject started range start
        (of_decide_eq_true ‹_›) rfl
    · rename_i other
      have flag : started.mark.kind = .boolean := by
        cases kind : started.mark.kind
        · exact (other (by simp only [kind, decide_true])).elim
        · rfl
      exact boolean_value reader text original first last constant localObject started start flag


private theorem typed_value (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original : ParserState) (info : PackageBindings.Metadata) (first last colon constant : Nat)
    (localObject : Bool) (seed : ObjectResult)
    (framed : seed.frame.position ≠ 0 → ReaderFrame text seed.frame)
    (colonBound : ValidCursor text colon) (constantBound : ValidCursor text constant) :
    ValueSuccess text seed.frame first last
      (objectTyped (modelObjectCalls reader) text original info first last colon constant localObject seed) := by
  unfold objectTyped
  by_cases zero : seed.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte]
    exact rejected_value _ _ _ _
  · let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text seed.frame info position
    have bounded : ValidCursor text position := by dsimp only [position]; split <;> assumption
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte]
    change ValueSuccess text seed.frame first last (if decide (mark.after = 0) then invalidObject else _)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
      exact rejected_value _ _ _ _
    · have found := (package_type_domain text seed.frame info position (framed zero) bounded).resolve_left absent
      simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      let marked := {seed with constantObject := decide (constant ≠ 0), mark := mark}
      change ValueSuccess text seed.frame first last (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant localObject marked
          (scalarConstraintAt text mark.after seed.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant localObject marked
          ⟨mark.after, mark.bounds⟩)
      split
      · exact initialized_value reader text original first last constant localObject marked _
          (scalarConstraintAt_position_valid text mark.after seed.frame.scalarNames found.cursor)
      · exact initialized_value reader text original first last constant localObject marked _ found.cursor

/-- The exact initializer environment is the one after native shadow removal,
before append. This theorem covers both local and package-level Objects. -/
theorem object_value_calls (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (framed : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    let name := objectName text frame
    let base := initializerBase text frame info name localObject
    ValueCalls text base name.first name.after (objectStep (modelObjectCalls reader) text frame info localObject) := by
  have succeeded : ValueSuccess text (initializerBase text frame info (objectName text frame) localObject)
      (objectName text frame).first (objectName text frame).after
      (objectStep (modelObjectCalls reader) text frame info localObject) := by
    dsimp only [objectStep, objectNameStep, modelObjectCalls]
    split
    · exact rejected_value _ _ _ _
    · cases localObject with
      | true =>
        simp only [↓reduceIte]
        apply typed_value reader text frame info
        · exact fun accepted => framed.hide_outer info _ accepted
        · exact fixedAfter_result_bound text _ ":" false (by decide)
        · exact fixedAfter_result_bound text _ "constant" true (by decide)
      | false =>
        simp only [Bool.false_eq_true, ↓reduceIte]
        split
        · apply typed_value reader text frame info
          · exact fun _ => framed.hidden_name _
          · exact fixedAfter_result_bound text _ ":" false (by decide)
          · exact fixedAfter_result_bound text _ "constant" true (by decide)
        · exact rejected_value _ _ _ _
  exact succeeded present

/-- Native shadow removal supplies the same full reader domain used by the
initializer; success does not authorize replacing its names with the final frame. -/
theorem object_initializer_frame (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (framed : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    ReaderFrame text (initializerBase text frame info (objectName text frame) localObject) := by
  cases localObject with
  | false => exact framed.hidden_name _
  | true =>
    apply framed.hide_outer
    intro missing
    apply present
    dsimp only [objectStep, objectNameStep, modelObjectCalls]
    split
    · rfl
    · simp only [↓reduceIte]
      unfold objectTyped
      rw [ite_eq_left (by simpa only [decide_eq_true_eq, objectName] using missing)]
      rfl

/-- Every scalar intermediate comes from the original, masked raw expression.
The source grammar and successful inference are derived together from the
retained read call. No frozen or final-value expression is substituted. -/
theorem ValueCalls.scalar_inventory {text : Source} {base : ParserState} {first last : Nat}
    {out : ObjectResult} (calls : ValueCalls text base first last out)
    (kind : out.mark.kind = .integer) :
    ∃ expression,
      ScalarExpression.At text base.scalarNames out.initFirst expression
        (ScalarExpression.read text out.initFirst base.scalarNames first last (elaborating := true))
        first last (elaborating := true) ∧
      expression.infer (ScalarExpression.ranges base.scalarNames) = some out.initialBounds ∧
      Integer.discharged (expression.obligations (ScalarExpression.ranges base.scalarNames)) = true ∧
      out.initialBounds.isEmpty = false ∧ out.initialBounds.included out.mark.bounds = true := by
  have values := calls.scalar kind
  obtain ⟨expression, reading⟩ := ScalarExpression.read_sound
    (arrays := []) (initials := []) (elaborating := true) calls.cursor values.2.1
  have inferred : expression.infer (ScalarExpression.ranges base.scalarNames) = some out.initialBounds := by
    simpa only [ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil,
      ArrayBindings.ranges_nil, values.2.2.1] using reading.inferred
  exact ⟨expression, reading, inferred, Integer.Expr.obligations_discharge inferred,
    values.2.2.1 ▸ values.2.2.2.1, values.2.2.1 ▸ values.2.2.2.2⟩

def booleanObligations (base : ParserState) (first last : Nat) (condition : Condition) :
    List Predicate.Obligation :=
  let context := booleanInitializerContext base first last
  condition.obligations context.names.shape context.analysis
    (context.flow (booleanInitializerFacts base) base.arrayNames.values)
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))

/-- Boolean initializers retain all short-circuit path and arithmetic schemas
in their original declaration scope, including the original array initial store. -/
theorem ValueCalls.boolean_inventory {text : Source} {base : ParserState} {first last : Nat}
    {out : ObjectResult} (calls : ValueCalls text base first last out)
    (textValid : ValidText text) (framed : ReaderFrame text base)
    (kind : out.mark.kind = .boolean) :
    ∃ condition result,
      ConditionAt text (booleanInitializerContext base first last) out.initFirst
        (booleanInitializerFacts base) condition result base.arrayNames.values ∧
      result.after = out.initAfter ∧
      ConditionMeaning (booleanInitializerContext base first last)
        (booleanInitializerFacts base) condition result base.arrayNames.values ∧
      Predicate.discharged (booleanObligations base first last condition) = true := by
  have values := calls.boolean kind
  have present : booleanInitializerAfter text base out.initFirst first last ≠ 0 :=
    fun missing => values.2 (values.1.symm.trans missing)
  obtain ⟨⟨condition, reading⟩, _⟩ := condition_sound text (booleanInitializerContext base first last)
    out.initFirst (booleanInitializerFacts base) textValid framed.native.base.2.1 calls.cursor present
  have meaning := boolean_initializer_meaning framed.native.bounds.normal framed.native.base framed.native.ready reading
  refine ⟨condition, _, reading, values.1, meaning, ?_⟩
  let context := booleanInitializerContext base first last
  exact (Condition.obligations_exact condition context.names.shape context.analysis
    (context.flow (booleanInitializerFacts base) base.arrayNames.values)
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))).trans meaning.checked

private def Origin (mark : PackageTypeResult) (start : Nat) (out : ObjectResult) : Prop :=
  out.frame.position ≠ 0 → out.mark = mark ∧ out.initFirst = start

private theorem rejected_origin (mark : PackageTypeResult) (start : Nat) : Origin mark start invalidObject :=
  fun present => (present rfl).elim

private theorem finish_origin (calls : ObjectCalls) (text : Source) (original : ParserState) (seed : ObjectResult) :
    Origin seed.mark seed.initFirst (finishObject calls text original seed) := by
  dsimp only [finishObject]
  split
  · exact rejected_origin _ _
  · exact fun _ => ⟨rfl, rfl⟩

private theorem scalar_origin (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (seed : ObjectResult) (range : ScalarConstraintResult) :
    Origin seed.mark seed.initFirst (objectScalar calls text original first last constant localObject seed range) := by
  dsimp only [objectScalar]
  split
  · exact rejected_origin _ _
  · exact finish_origin calls text original _

private theorem boolean_origin (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constant : Nat) (localObject : Bool) (seed : ObjectResult) :
    Origin seed.mark seed.initFirst (objectBoolean calls text original first last constant localObject seed) := by
  dsimp only [objectBoolean]
  split
  · exact rejected_origin _ _
  · split
    · split
      · exact rejected_origin _ _
      · exact finish_origin calls text original _
    · exact finish_origin calls text original _


private theorem initialized_origin (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original : ParserState) (first last constant : Nat) (localObject : Bool)
    (seed : ObjectResult) (range : ScalarConstraintResult)
    (present : (objectInitialized (modelObjectCalls reader) text original first last constant localObject seed range).frame.position ≠ 0) :
    let out := objectInitialized (modelObjectCalls reader) text original first last constant localObject seed range
    out.mark = {seed.mark with bounds := range.bounds} ∧
      out.initFirst = skipAt text (tokenAfter text range.after (.symbol ":=")) ∧ range.after ≠ 0 := by
  dsimp only [objectInitialized] at present ⊢
  split at present
  · exact (present rfl).elim
  · rename_i started
    rw [ite_eq_right started]
    have initial : skipAt text (fixedAfter text range.after ":=" false) ≠ 0 := by
      change ¬ decide (skipAt text (fixedAfter text range.after ":=" false) = 0) = true at started
      simpa only [decide_eq_true_eq] using started
    have token : fixedAfter text range.after ":=" false ≠ 0 := by
      intro absent
      simp only [absent, skipAt, ↓reduceIte] at initial
      exact initial rfl
    have nonzero := fixedAfter_nonzero token
    split at present
    · rename_i integer
      rw [ite_eq_left integer]
      exact ⟨(scalar_origin _ _ _ _ _ _ _ _ _ present).1,
        (scalar_origin _ _ _ _ _ _ _ _ _ present).2, nonzero⟩
    · rename_i boolean
      rw [ite_eq_right boolean]
      exact ⟨(boolean_origin _ _ _ _ _ _ _ _ present).1,
        (boolean_origin _ _ _ _ _ _ _ _ present).2, nonzero⟩

/-- Original type and optional range-reader calls, including the raw type
position and both pre- and post-constraint intervals. -/
def HeaderCalls (_reader : BooleanElaboration.Native.Reader) (text : Source) (base : ParserState)
    (info : PackageBindings.Metadata) (colon constant : Nat) (out : ObjectResult) : Prop :=
  let position := if decide (constant = 0) then colon else constant
  let mark := packageTypeAt text base info position
  let range := if mark.kind = .integer then scalarConstraintAt text mark.after base.scalarNames mark.bounds
    else ⟨mark.after, mark.bounds⟩
  ValidCursor text position ∧ mark.after ≠ 0 ∧ ValidCursor text mark.after ∧ range.after ≠ 0 ∧
    out.mark = {mark with bounds := range.bounds} ∧
    out.initFirst = skipAt text (tokenAfter text range.after (.symbol ":="))

private theorem typed_header (reader : BooleanElaboration.Native.Reader) (text : Source)
    (original : ParserState) (info : PackageBindings.Metadata) (first last colon constant : Nat)
    (localObject : Bool) (seed : ObjectResult)
    (framed : seed.frame.position ≠ 0 → ReaderFrame text seed.frame)
    (colonBound : ValidCursor text colon) (constantBound : ValidCursor text constant)
    (present : (objectTyped (modelObjectCalls reader) text original info first last colon constant localObject seed).frame.position ≠ 0) :
    HeaderCalls reader text seed.frame info colon constant
      (objectTyped (modelObjectCalls reader) text original info first last colon constant localObject seed) := by
  unfold objectTyped at present ⊢
  by_cases zero : seed.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte] at present
    exact (present rfl).elim
  · let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text seed.frame info position
    let marked := {seed with constantObject := decide (constant ≠ 0), mark := mark}
    have bounded : ValidCursor text position := by dsimp only [position]; split <;> assumption
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte] at present ⊢
    change (if decide (mark.after = 0) then invalidObject else _).frame.position ≠ 0 at present
    change HeaderCalls reader text seed.frame info colon constant
      (if decide (mark.after = 0) then invalidObject else _)
    by_cases absent : mark.after = 0
    · rw [ite_eq_left (by simp only [absent, decide_true])] at present
      exact (present rfl).elim
    · rw [ite_eq_right (by simpa only [decide_eq_true_eq] using absent)] at present ⊢
      have domain := (package_type_domain text seed.frame info position (framed zero) bounded).resolve_left absent
      change (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant localObject marked
          (scalarConstraintAt text mark.after seed.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant localObject marked
          ⟨mark.after, mark.bounds⟩).frame.position ≠ 0 at present
      change HeaderCalls reader text seed.frame info colon constant (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant localObject marked
          (scalarConstraintAt text mark.after seed.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant localObject marked
          ⟨mark.after, mark.bounds⟩)
      by_cases kind : mark.kind = .integer
      · rw [ite_eq_left (by simpa only [decide_eq_true_eq] using kind)] at present ⊢
        have origin := initialized_origin reader text original first last constant localObject _ _ present
        change HeaderCalls reader text seed.frame info colon constant _
        dsimp only [HeaderCalls]
        change ValidCursor text position ∧ mark.after ≠ 0 ∧ ValidCursor text mark.after ∧ _
        dsimp only [mark, position] at kind
        simp only [kind, ↓reduceIte]
        exact ⟨bounded, absent, domain.cursor, origin.2.2,
          by simpa only [marked, mark, position, kind] using origin.1, origin.2.1⟩
      · rw [ite_eq_right (by simpa only [decide_eq_true_eq] using kind)] at present ⊢
        have origin := initialized_origin reader text original first last constant localObject _ _ present
        dsimp only [HeaderCalls]
        change ValidCursor text position ∧ mark.after ≠ 0 ∧ ValidCursor text mark.after ∧ _
        dsimp only [mark, position] at kind
        simp only [kind, ↓reduceIte]
        exact ⟨bounded, absent, domain.cursor, origin.2.2, origin.1, origin.2.1⟩

theorem object_header_calls (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (framed : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (localObject : Bool)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    let name := objectName text frame
    let colon := tokenAfter text name.after (.symbol ":")
    let constant := tokenAfter text colon (.word "constant")
    HeaderCalls reader text (initializerBase text frame info name localObject) info colon constant
      (objectStep (modelObjectCalls reader) text frame info localObject) := by
  dsimp only [objectStep, objectNameStep, modelObjectCalls] at present ⊢
  split at present
  · exact (present rfl).elim
  · rename_i named
    rw [ite_eq_right named]
    cases localObject with
    | true =>
      simp only [↓reduceIte] at present ⊢
      apply typed_header reader text frame info _ _ _ _ true _ _ _ _ present
      · exact fun accepted => framed.hide_outer info _ accepted
      · exact fixedAfter_result_bound text _ ":" false (by decide)
      · exact fixedAfter_result_bound text _ "constant" true (by decide)
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte] at present ⊢
      split at present
      · rename_i fresh
        rw [ite_eq_left fresh]
        apply typed_header reader text frame info _ _ _ _ false _ _ _ _ present
        · exact fun _ => framed.hidden_name _
        · exact fixedAfter_result_bound text _ ":" false (by decide)
        · exact fixedAfter_result_bound text _ "constant" true (by decide)
      · exact (present rfl).elim

/-- Raw optional range syntax and original read results. There is no inferred
interval or discharged-check premise in this source representation. -/
inductive RangeSyntaxAt (text : Source) (names : ScalarExpression.Environment)
    (position : Nat) (base : Integer.Interval) : ScalarConstraintResult → List Integer.Expr → Prop
  | absent (missing : fixedAfter text position "range" true = 0) :
      RangeSyntaxAt text names position base ⟨position, base⟩ []
  | present {low high : Integer.Expr} {lower upper : ScalarExpression.Result}
      (start : fixedAfter text position "range" true ≠ 0)
      (lowRead : ScalarExpression.ArrayGrammar.read text (fixedAfter text position "range" true) names {} = lower)
      (lowSource : ScalarExpression.ArrayGrammar.SourceAt text names {} 0 0 .allElements true
        (fixedAfter text position "range" true) ⟨lower.after, low⟩)
      (delimiter : fixedAfter text lower.after ".." false ≠ 0)
      (highRead : ScalarExpression.ArrayGrammar.read text (fixedAfter text lower.after ".." false) names {} = upper)
      (highSource : ScalarExpression.ArrayGrammar.SourceAt text names {} 0 0 .allElements true
        (fixedAfter text lower.after ".." false) ⟨upper.after, high⟩) :
      RangeSyntaxAt text names position base ⟨upper.after, ⟨lower.bounds.lower, upper.bounds.lower⟩⟩ [low, high]

def rangeObligations (names : ScalarExpression.Environment) (expressions : List Integer.Expr) :
    List Integer.Obligation :=
  expressions.flatMap fun expression => expression.obligations
    (ArrayBindings.viewRanges [] [] false (ScalarExpression.ranges names))

/-- Even a declaration with no value cell contributes both raw endpoint
expressions. The proof follows the original constraint reader's result. -/
theorem constraint_inventory {text : Source} {names : ScalarExpression.Environment}
    {position : Nat} {base : Integer.Interval} {result : ScalarConstraintResult}
    (reading : ScalarConstraintAt (arrays := {}) text names position base result) :
    ∃ expressions, RangeSyntaxAt text names position base result expressions ∧
      Integer.discharged (rangeObligations names expressions) = true := by
  cases reading with
  | absent missing => exact ⟨[], .absent missing, rfl⟩
  | @present low high lower upper start lowRead delimiter highRead _ _ _ _ _ _ _ =>
    refine ⟨[low, high], .present start (ScalarExpression.ArrayGrammar.read_complete lowRead)
      lowRead.source delimiter (ScalarExpression.ArrayGrammar.read_complete highRead) highRead.source, ?_⟩
    simp only [rangeObligations, List.flatMap_cons, List.flatMap_nil, List.append_nil,
      Integer.discharged_append, Integer.Expr.obligations_discharge lowRead.inferred,
      Integer.Expr.obligations_discharge highRead.inferred, Bool.and_self]

inductive ValueSyntax where
  | integer (expression : Integer.Expr)
  | boolean (condition : Condition)

/-- Syntax and original reader history only. Scalar inference and Boolean
semantic validity are derived below from the accepted Object execution. -/
def ValueSyntax.SourceAt (text : Source) (base : ParserState) (first last : Nat)
    (out : ObjectResult) : ValueSyntax → Prop
  | .integer expression => out.mark.kind = .integer ∧
      ScalarExpression.sourceSyntaxAt text base.scalarNames [] first last true out.initFirst
        ⟨out.initAfter, expression⟩
  | .boolean condition => out.mark.kind = .boolean ∧ ∃ result,
      ConditionAt text (booleanInitializerContext base first last) out.initFirst
        (booleanInitializerFacts base) condition result base.arrayNames.values ∧ result.after = out.initAfter

def ValueSyntax.obligations (base : ParserState) (first last : Nat) (out : ObjectResult) :
    ValueSyntax → List Predicate.Obligation
  | .integer expression =>
      ((expression.obligations (ScalarExpression.ranges base.scalarNames)) ++
        [Integer.Obligation.within out.initialBounds out.mark.bounds]).map .scalar
  | .boolean condition => booleanObligations base first last condition

theorem ValueCalls.syntax {text : Source} {base : ParserState} {first last : Nat}
    {out : ObjectResult} (calls : ValueCalls text base first last out)
    (textValid : ValidText text) (framed : ReaderFrame text base) :
    ∃ value : ValueSyntax, value.SourceAt text base first last out ∧
      Predicate.discharged (value.obligations base first last out) = true := by
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨expression, reading, _, checked, _, included⟩ := calls.scalar_inventory kind
    have finish := (calls.scalar kind).1
    refine ⟨.integer expression, ⟨kind, ?_⟩, ?_⟩
    · simpa only [finish] using reading.grammar
    · rw [ValueSyntax.obligations, Predicate.scalar_discharged,
        Integer.discharged_append, checked]
      simp only [Integer.discharged, List.all_cons, List.all_nil,
        Integer.Obligation.discharge, included, Bool.and_self]
  | boolean =>
    obtain ⟨condition, result, reading, finish, _, checked⟩ := calls.boolean_inventory textValid framed kind
    exact ⟨.boolean condition, ⟨kind, result, reading, finish⟩, checked⟩

def objectTypePosition (text : Source) (frame : ParserState) : Nat :=
  let colon := tokenAfter text (objectName text frame).after (.symbol ":")
  let constant := tokenAfter text colon (.word "constant")
  if decide (constant = 0) then colon else constant

def objectRange (text : Source) (frame base : ParserState) (info : PackageBindings.Metadata) : ScalarConstraintResult :=
  let mark := packageTypeAt text base info (objectTypePosition text frame)
  if mark.kind = .integer then scalarConstraintAt text mark.after base.scalarNames mark.bounds
  else ⟨mark.after, mark.bounds⟩

structure ObjectSyntax where
  ranges : List Integer.Expr
  value : ValueSyntax

def ObjectSyntax.SourceAt (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (localObject : Bool) (out : ObjectResult) (inventory : ObjectSyntax) : Prop :=
  let name := objectName text frame
  let base := initializerBase text frame info name localObject
  let mark := packageTypeAt text base info (objectTypePosition text frame)
  (if mark.kind = .integer then
      RangeSyntaxAt text base.scalarNames mark.after mark.bounds (objectRange text frame base info) inventory.ranges
    else inventory.ranges = []) ∧ inventory.value.SourceAt text base name.first name.after out

def ObjectSyntax.obligations (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (localObject : Bool) (out : ObjectResult) (inventory : ObjectSyntax) : List Predicate.Obligation :=
  let name := objectName text frame
  let base := initializerBase text frame info name localObject
  (rangeObligations base.scalarNames inventory.ranges).map .scalar ++
    inventory.value.obligations base name.first name.after out

/-- Complete per-Object inventory from its original execution, for either
public/private elaboration or routine-local declarations. Raw syntax and all
range/initializer arithmetic checks are derived, including target containment. -/
theorem object_inventory (reader : BooleanElaboration.Native.Reader) (text : Source)
    (textValid : ValidText text) (frame : ParserState) (framed : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (localObject : Bool) {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info localObject = out)
    (present : out.frame.position ≠ 0) :
    ∃ inventory : ObjectSyntax, inventory.SourceAt text frame info localObject out ∧
      Predicate.discharged (inventory.obligations text frame info localObject out) = true := by
  let name := objectName text frame
  let base := initializerBase text frame info name localObject
  let mark := packageTypeAt text base info (objectTypePosition text frame)
  have accepted := parsed ▸ object_value_calls reader text frame framed info localObject (parsed ▸ present)
  have baseFrame := object_initializer_frame reader text frame framed info localObject (parsed ▸ present)
  obtain ⟨value, valueSource, valueChecks⟩ := accepted.syntax textValid baseFrame
  have header := parsed ▸ object_header_calls reader text frame framed info localObject (parsed ▸ present)
  change ValidCursor text (objectTypePosition text frame) ∧ mark.after ≠ 0 ∧ ValidCursor text mark.after ∧
    (objectRange text frame base info).after ≠ 0 ∧ _ at header
  by_cases integer : mark.kind = .integer
  · have selected : objectRange text frame base info =
        scalarConstraintAt text mark.after base.scalarNames mark.bounds := by
      change (if mark.kind = .integer then _ else _) = _
      rw [ite_eq_left integer]
    have rangeRead : ScalarConstraintAt (arrays := {}) text base.scalarNames mark.after mark.bounds
        (objectRange text frame base info) := by
      have live : (scalarConstraintAt text mark.after base.scalarNames mark.bounds).after ≠ 0 := by
        simpa only [selected] using header.2.2.2.1
      rw [selected]
      exact scalarConstraintAt_sound text mark.after base.scalarNames header.2.2.1 live
    obtain ⟨expressions, rangeSource, rangeChecks⟩ := constraint_inventory rangeRead
    refine ⟨⟨expressions, value⟩, ?_, ?_⟩
    · change (if mark.kind = .integer then _ else _) ∧ _
      rw [ite_eq_left integer]
      exact ⟨rangeSource, valueSource⟩
    · exact (Predicate.discharged_append _ _).trans (by rw [Predicate.scalar_discharged, rangeChecks, valueChecks]; rfl)
  · refine ⟨⟨[], value⟩, ?_, ?_⟩
    · change (if mark.kind = .integer then _ else _) ∧ _
      rw [ite_eq_right integer]
      exact ⟨rfl, valueSource⟩
    · exact valueChecks

private def SingletonSuccess (out : ObjectResult) : Prop :=
  out.frame.position ≠ 0 → out.initialBounds.lower = out.initialBounds.upper

private theorem singleton_rejected : SingletonSuccess invalidObject := fun present => (present rfl).elim

private theorem singleton_finish (calls : ObjectCalls) (text : Source) (original : ParserState)
    (out : ObjectResult) (same : out.initialBounds.lower = out.initialBounds.upper) :
    SingletonSuccess (finishObject calls text original out) := by
  dsimp only [finishObject]
  split
  · exact singleton_rejected
  · exact fun _ => same

private theorem singleton_boolean_finish (reader : BooleanElaboration.Native.Reader)
    (text : Source) (original : ParserState) (first last constant after : Nat) (out : ObjectResult) :
    SingletonSuccess (objectBooleanFinish (modelObjectCalls reader) text original first last constant after false out) := by
  dsimp only [objectBooleanFinish]
  apply singleton_finish
  rfl

private theorem singleton_boolean (reader : BooleanElaboration.Native.Reader)
    (text : Source) (original : ParserState) (first last constant : Nat) (out : ObjectResult) :
    SingletonSuccess (objectBoolean (modelObjectCalls reader) text original first last constant false out) := by
  dsimp only [objectBoolean]
  split
  · exact singleton_rejected
  · simp only [Bool.not_false, ↓reduceIte]
    split
    · exact singleton_rejected
    · exact singleton_boolean_finish reader text original first last constant _ _

private theorem singleton_scalar (reader : BooleanElaboration.Native.Reader)
    (text : Source) (original : ParserState) (first last constant : Nat) (out : ObjectResult)
    (range : ScalarConstraintResult) :
    SingletonSuccess (objectScalar (modelObjectCalls reader) text original first last constant false out range) := by
  dsimp only [objectScalar, modelObjectCalls]
  split
  · exact singleton_rejected
  · rename_i accepted
    apply singleton_finish
    by_cases same : (ScalarExpression.read text out.initFirst out.frame.scalarNames first last
        (elaborating := true)).bounds.lower =
      (ScalarExpression.read text out.initFirst out.frame.scalarNames first last (elaborating := true)).bounds.upper
    · exact same
    · have different : decide ((ScalarExpression.read text out.initFirst out.frame.scalarNames first last
          (elaborating := true)).bounds.lower ≠
        (ScalarExpression.read text out.initFirst out.frame.scalarNames first last (elaborating := true)).bounds.upper) = true :=
        decide_eq_true same
      exact (accepted (by
        rw [different]
        simp only [Bool.not_false, Bool.and_self, Bool.or_true, Bool.true_or])).elim

private theorem singleton_initialized (reader : BooleanElaboration.Native.Reader)
    (text : Source) (original : ParserState) (first last constant : Nat) (out : ObjectResult)
    (range : ScalarConstraintResult) :
    SingletonSuccess (objectInitialized (modelObjectCalls reader) text original first last constant false out range) := by
  dsimp only [objectInitialized]
  split
  · exact singleton_rejected
  · split
    · exact singleton_scalar reader text original first last constant _ range
    · exact singleton_boolean reader text original first last constant _

private theorem singleton_typed (reader : BooleanElaboration.Native.Reader)
    (text : Source) (original : ParserState) (info : PackageBindings.Metadata)
    (first last colon constant : Nat) (out : ObjectResult) :
    SingletonSuccess (objectTyped (modelObjectCalls reader) text original info first last colon constant false out) := by
  unfold objectTyped
  by_cases zero : out.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte]
    exact singleton_rejected
  · let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text out.frame info position
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte]
    change SingletonSuccess (if decide (mark.after = 0) then invalidObject else _)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
      exact singleton_rejected
    · simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      let seed := {out with constantObject := decide (constant ≠ 0), mark := mark}
      change SingletonSuccess (if decide (mark.kind = .integer) then
        objectInitialized (modelObjectCalls reader) text original first last constant false seed
          (scalarConstraintAt text mark.after out.frame.scalarNames mark.bounds)
        else objectInitialized (modelObjectCalls reader) text original first last constant false seed
          ⟨mark.after, mark.bounds⟩)
      split <;> exact singleton_initialized reader text original first last constant seed _

/-- The original nonlocal Object guard requires exact elaboration. This fact
comes from that guard, rather than treating an arbitrary inferred interval's
lower endpoint as the initializer value. -/
theorem object_global_singleton (reader : BooleanElaboration.Native.Reader) (text : Source)
    (frame : ParserState) (info : PackageBindings.Metadata) {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) : out.initialBounds.lower = out.initialBounds.upper := by
  have exactValue : SingletonSuccess (objectStep (modelObjectCalls reader) text frame info false) := by
    dsimp only [objectStep, objectNameStep, modelObjectCalls]
    split
    · exact singleton_rejected
    · simp only [Bool.false_eq_true, ↓reduceIte]
      split
      · exact singleton_typed reader text frame info _ _ _ _ _
      · exact singleton_rejected
  exact parsed ▸ exactValue (parsed ▸ present)

/-- The seed value of a public/private scalar initializer is its original raw
expression's value for every store fitting the original elaboration frame. -/
theorem ValueCalls.scalar_exact {text : Source} {base : ParserState} {first last : Nat}
    {out : ObjectResult} (calls : ValueCalls text base first last out)
    (kind : out.mark.kind = .integer) (singleton : out.initialBounds.lower = out.initialBounds.upper) :
    ∃ expression,
      ScalarExpression.sourceSyntaxAt text base.scalarNames [] first last true out.initFirst
        ⟨out.initAfter, expression⟩ ∧
      (∀ values, Integer.Fits (ScalarExpression.ranges base.scalarNames) values →
        expression.evaluate values = out.initialBounds.lower) := by
  obtain ⟨expression, reading, inferred, _, _, _⟩ := calls.scalar_inventory kind
  refine ⟨expression, ?_, fun values fit => ?_⟩
  · simpa only [(calls.scalar kind).1] using reading.grammar
  · exact BooleanElaboration.singleton_infer_value inferred fit singleton

end Silver.ApplicationPackageInitializers
