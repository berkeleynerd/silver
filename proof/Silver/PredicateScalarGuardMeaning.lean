module

public import Silver.PredicateConditionReadings
public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate
open Compose PathFacts

private theorem trivia_terminal {text rest : Source} (parsed : Trivia text rest) :
    triviaEnd rest = rest := by
  induction parsed with
  | eof => simp [triviaEnd]
  | stop c text space comment => simp [triviaEnd, space, comment]
  | space _ _ _ _ _ ih | comment _ _ _ _ _ ih => exact ih

private theorem skip_idempotent (text : Source) (position : Nat) :
    ScalarExpression.skip text (ScalarExpression.skip text position) =
      ScalarExpression.skip text position := by
  by_cases zero : ScalarExpression.skip text position = 0
  · rw [zero]; rfl
  · have positionNonzero : position ≠ 0 := by
      intro equal
      simp [ScalarExpression.skip, equal] at zero
    have equation : ScalarExpression.skip text position = Cursor.triviaPosition text position :=
      ite_eq_right positionNonzero
    calc
      ScalarExpression.skip text (ScalarExpression.skip text position) =
          Cursor.triviaPosition text (ScalarExpression.skip text position) := ite_eq_right zero
      _ = Cursor.triviaPosition text (Cursor.triviaPosition text position) := congrArg _ equation
      _ = Cursor.triviaPosition text position := by
        change Cursor.endPosition text (triviaEnd (Cursor.remaining text (Cursor.triviaPosition text position))) = _
        rw [Cursor.remaining_triviaPosition, trivia_terminal (trivia_complete _)]
        rfl
      _ = ScalarExpression.skip text position := equation.symm

private theorem lookup_zero_end (text : Source) (names : ScalarExpression.Environment) (first : Nat) :
    ScalarExpression.lookup text names first 0 = 0 := by
  unfold ScalarExpression.lookup
  cases names.length <;> simp [ScalarExpression.lookupFrom]

private theorem bareTarget_nonletter (text : Source) (context : ParseContext) (position after : Nat)
    (notLetter : Named.letter (Cursor.byteAt text (skipAt text position)) = false) :
    bareTarget text context position after = 0 := by
  have noName : nameAfter text (skipAt text position) = 0 := by
    simp [nameAfter, Named.identifierEnd, notLetter]
  simp only [bareTarget, noName, lookup_zero_end, ne_eq, not_true_eq_false, false_and, ↓reduceIte]

private theorem integer_not_letter {text : Source} {position value finish : Nat}
    (parsed : ScalarLiteral.IntegerAt text position value finish) :
    Named.letter (Cursor.byteAt text position) = false := by
  have decimalDigit : ScalarLiteral.digitValue (Cursor.byteAt text position) < 10 := by
    have firstDigit : ∀ {v b f}, ScalarLiteral.MantissaAt text position v b f →
        ScalarLiteral.digitValue (Cursor.byteAt text position) < 10 := by
      intro v b f mantissa
      cases mantissa with
      | decimal leading _ => exact (ScalarLiteral.numeral_first_digit leading).2
      | based leading _ _ _ _ => exact (ScalarLiteral.numeral_first_digit leading).2
    cases parsed with
    | literal number _ _ => exact firstDigit number
  unfold ScalarLiteral.digitValue at decimalDigit
  split at decimalDigit
  · apply Bool.eq_false_iff.mpr
    intro letter
    simp only [Named.letter, decide_eq_true_eq] at letter
    omega
  · split at decimalDigit
    · omega
    · split at decimalDigit <;> omega

def guardTarget (context : ParseContext) : Integer.Expr → Nat
  | .name index => if context.analysis.refinable index then index else 0
  | _ => 0

private theorem guardTarget_binary {context : ParseContext} {left right combined : ScalarExpression.Parsed}
    {operator : Nat} (found : ScalarExpression.binary left right operator = some combined) :
    guardTarget context combined.expression = 0 := by
  unfold ScalarExpression.binary at found
  repeat' first | split at found | (cases found <;> rfl)

theorem syntax_bareTarget {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : ScalarExpression.Parsed}
    (parsed : ScalarExpression.SyntaxAt text (context.readingNames facts)
      maskFirst maskAfter allowSign position value) :
    bareTarget text context position value.after = guardTarget context value.expression := by
  cases parsed with
  | atom nonzero within notGroup atom =>
      have fixed := skip_idempotent text position
      cases atom with
      | unsigned _ _ _ number =>
          have notLetter := integer_not_letter number
          rw [fixed] at notLetter
          exact bareTarget_nonletter text context position _ notLetter
      | signed _ _ sign _ _ =>
          rw [fixed] at sign
          have notLetter : Named.letter (Cursor.byteAt text (skipAt text position)) = false := by
            rcases sign with plus | minus <;> change Cursor.byteAt text (skipAt text position) = _ at *
            · rw [plus]; decide
            · rw [minus]; decide
          exact bareTarget_nonletter text context position _ notLetter
      | @name bytes finish index _ _ _ _ identifier found nonzeroIndex _ =>
          have nameEnd := Named.identifierEnd_complete identifier
          rw [fixed] at nameEnd found
          have firstNonzero : skipAt text position ≠ 0 := nonzero
          have last : nameAfter text (skipAt text position) = finish := by
            change Named.identifierEnd text (skipAt text position) = finish at nameEnd
            simpa only [nameAfter, firstNonzero, ↓reduceIte] using nameEnd
          have lookup : ScalarExpression.lookup text context.scalarNames (skipAt text position) finish = index := by
            change ScalarExpression.lookup text (context.readingNames facts) (skipAt text position) finish = index at found
            simpa only [ParseContext.readingNames, ScalarMetadata.readingNames_lookup] using found
          have bounded : index ≤ context.scalarNames.length := by
            rw [← lookup]
            exact ScalarExpression.lookup_bound ..
          simp only [bareTarget, last, lookup, nonzeroIndex, ne_eq, not_false_eq_true, true_and,
            guardTarget, ParseContext.analysis, ScalarMetadata.analysis, ScalarMetadata.refinable,
            show 0 < index ∧ index ≤ context.scalarNames.length from ⟨by omega, bounded⟩,
            decide_true, Bool.true_and]
  | signed opened _ _ _ =>
      apply bareTarget_nonletter
      change Named.letter (Cursor.byteAt text (ScalarExpression.skip text position)) = false
      rw [opened.2.2.1]
      decide
  | @unary position closed allowSign value opened _ _ _ _ =>
      have noTarget := bareTarget_nonletter text context position closed (by
        change Named.letter (Cursor.byteAt text (ScalarExpression.skip text position)) = false
        rw [opened.2.2.1]; decide)
      rw [noTarget]
      simp only [ScalarExpression.unary]
      split <;> rfl
  | grouped opened _ _ _ =>
      apply bareTarget_nonletter
      change Named.letter (Cursor.byteAt text (ScalarExpression.skip text position)) = false
      rw [opened.2.2.1]
      decide
  | binary opened _ _ _ _ _ _ combined _ =>
      rw [guardTarget_binary combined]
      apply bareTarget_nonletter
      change Named.letter (Cursor.byteAt text (ScalarExpression.skip text position)) = false
      rw [opened.2.2.1]
      decide

theorem inferred_staticness {names : ScalarExpression.Environment} {expression : Integer.Expr}
    {bounds : Integer.Interval} (found : expression.infer (ScalarExpression.ranges names) = some bounds) :
    ScalarExpression.isStatic names expression = expression.isStatic (ScalarMetadata.staticness names) := by
  induction expression generalizing bounds with
  | literal _ => rfl
  | name index =>
      simp only [Integer.Expr.infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, present, _⟩ := found
      have active : 0 < index ∧ index ≤ names.length := by
        unfold ScalarExpression.ranges at present
        split at present
        · assumption
        · contradiction
      simp [ScalarExpression.isStatic, Integer.Expr.isStatic, ScalarMetadata.staticness, active]
  | positive value ih | parenthesized value ih => exact ih found
  | negative value ih =>
      simp only [Integer.Expr.infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, inferred, _⟩ := found
      exact ih inferred
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
      simp only [Integer.Expr.infer, Option.bind_eq_some_iff] at found
      obtain ⟨a, l, b, r, _⟩ := found
      simp only [ScalarExpression.isStatic, Integer.Expr.isStatic, ihl l, ihr r]

theorem scalarAt_staticness {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position : Nat} {expression : Integer.Expr} {result : ScalarExpression.Result}
    (parsed : ScalarExpression.At text (context.readingNames facts) position expression result) :
    result.isStatic = expression.isStatic context.analysis.static := by
  rw [parsed.staticValue, inferred_staticness parsed.inferred]
  simp only [ParseContext.readingNames, ScalarMetadata.readingNames_staticness]
  rfl

theorem guardTarget_nonzero {context : ParseContext} {expression : Integer.Expr}
    (nonzero : guardTarget context expression ≠ 0) :
    expression = .name (guardTarget context expression) := by
  cases expression <;> simp only [guardTarget] at nonzero ⊢ <;> try contradiction
  split at nonzero
  · rename_i refinable
    simp only [refinable, ↓reduceIte]
  · contradiction

theorem guardCandidate_target (context : ParseContext) (left right : Integer.Expr) (bounds : Integer.Interval) :
    Integer.guardCandidate context.analysis left right bounds =
      if guardTarget context left ≠ 0 ∧ right.isStatic context.analysis.static = true ∧
          bounds.lower = bounds.upper
      then some (guardTarget context left, bounds.lower) else none := by
  cases left <;> simp only [Integer.guardCandidate, guardTarget] <;> try simp
  rename_i index
  by_cases refinable : context.analysis.refinable index = true
  · have positive : 0 < index := by
      simp only [ParseContext.analysis, ScalarMetadata.analysis, ScalarMetadata.refinable,
        Bool.and_eq_true, decide_eq_true_eq] at refinable
      exact refinable.1.1
    simp [refinable, show index ≠ 0 by omega]
  · simp [refinable]

theorem scalarCondition_outcome_model {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position rightPosition : Nat} {left right : Integer.Expr}
    {leftResult rightResult : ScalarExpression.Result} {operator : Comparison}
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (leftRead : ScalarExpression.At text (context.readingNames facts) position left leftResult)
    (rightRead : ScalarExpression.At text (context.readingNames facts) rightPosition right rightResult)
    (truth : Bool) :
    (if truth then (scalarCondition text context position rightPosition facts leftResult rightResult operator).whenTrue
      else (scalarCondition text context position rightPosition facts leftResult rightResult operator).whenFalse).model =
      (Condition.scalarCompare operator.toInteger left right).refine context.names.shape context.analysis facts.model truth := by
  have ranges : ScalarExpression.ranges (context.readingNames facts) = facts.model.scalars :=
    ScalarMetadata.readingNames_ranges compatible
  have l := leftRead.inferred
  have r := rightRead.inferred
  rw [ranges] at l r
  have leftTarget := syntax_bareTarget leftRead.grammar
  have rightTarget := syntax_bareTarget rightRead.grammar
  have leftStatic := scalarAt_staticness leftRead
  have rightStatic := scalarAt_staticness rightRead
  have selected : (if truth then (scalarCondition text context position rightPosition facts leftResult rightResult operator).whenTrue
      else (scalarCondition text context position rightPosition facts leftResult rightResult operator).whenFalse) =
      facts.refine
        (if guardTarget context left ≠ 0 ∧ right.isStatic context.analysis.static = true ∧ rightResult.bounds.lower = rightResult.bounds.upper
          then guardTarget context left
          else if guardTarget context right ≠ 0 ∧ left.isStatic context.analysis.static = true ∧ leftResult.bounds.lower = leftResult.bounds.upper
          then guardTarget context right else 0)
        (if (if guardTarget context left ≠ 0 ∧ right.isStatic context.analysis.static = true ∧ rightResult.bounds.lower = rightResult.bounds.upper
          then guardTarget context left
          else if guardTarget context right ≠ 0 ∧ left.isStatic context.analysis.static = true ∧ leftResult.bounds.lower = leftResult.bounds.upper
          then guardTarget context right else 0) = guardTarget context left
          then operator.toInteger else operator.toInteger.swap)
        (if (if guardTarget context left ≠ 0 ∧ right.isStatic context.analysis.static = true ∧ rightResult.bounds.lower = rightResult.bounds.upper
          then guardTarget context left
          else if guardTarget context right ≠ 0 ∧ left.isStatic context.analysis.static = true ∧ leftResult.bounds.lower = leftResult.bounds.upper
          then guardTarget context right else 0) = guardTarget context left
          then rightResult.bounds.lower else leftResult.bounds.lower) truth := by
    cases truth <;> simp only [scalarCondition, Bool.false_eq_true, ↓reduceIte,
      leftTarget, rightTarget, leftStatic, rightStatic]
  rw [selected, ActiveFlow.refine_model]
  simp only [Condition.refine, Integer.refineComparison, l, r,
    guardCandidate_target]
  by_cases chooseLeft : guardTarget context left ≠ 0 ∧ right.isStatic context.analysis.static = true ∧
      rightResult.bounds.lower = rightResult.bounds.upper
  · simp only [ite_eq_left chooseLeft, ↓reduceIte]
    rfl
  · by_cases chooseRight : guardTarget context right ≠ 0 ∧ left.isStatic context.analysis.static = true ∧
        leftResult.bounds.lower = leftResult.bounds.upper
    · have different : guardTarget context right ≠ guardTarget context left := by
        intro same
        have leftNonzero : guardTarget context left ≠ 0 := by rw [← same]; exact chooseRight.1
        have leftName := guardTarget_nonzero leftNonzero
        have rightName := guardTarget_nonzero chooseRight.1
        have sameExpression : left = right := by rw [leftName, rightName, same]
        have staticRight : right.isStatic context.analysis.static = true := by rw [← sameExpression]; exact chooseRight.2.1
        have boundsEqual : leftResult.bounds = rightResult.bounds := by
          rw [sameExpression] at l
          exact Option.some.inj (l.symm.trans r)
        exact chooseLeft ⟨leftNonzero, staticRight, by rw [← boundsEqual]; exact chooseRight.2.2⟩
      simp only [ite_eq_right chooseLeft, ite_eq_left chooseRight, ite_eq_right different]
      rfl
    · simp only [chooseLeft, chooseRight, ↓reduceIte, Integer.Ranges.refineName,
        ActiveFlow.model, ActiveFlow.ranges, ↓reduceIte]

theorem scalarCondition_whenTrue_model {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position rightPosition : Nat} {left right : Integer.Expr}
    {leftResult rightResult : ScalarExpression.Result} {operator : Comparison}
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (leftRead : ScalarExpression.At text (context.readingNames facts) position left leftResult)
    (rightRead : ScalarExpression.At text (context.readingNames facts) rightPosition right rightResult) :
    (scalarCondition text context position rightPosition facts leftResult rightResult operator).whenTrue.model =
      (Condition.scalarCompare operator.toInteger left right).refine context.names.shape context.analysis facts.model true :=
  scalarCondition_outcome_model compatible leftRead rightRead true

theorem scalarCondition_whenFalse_model {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position rightPosition : Nat} {left right : Integer.Expr}
    {leftResult rightResult : ScalarExpression.Result} {operator : Comparison}
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (leftRead : ScalarExpression.At text (context.readingNames facts) position left leftResult)
    (rightRead : ScalarExpression.At text (context.readingNames facts) rightPosition right rightResult) :
    (scalarCondition text context position rightPosition facts leftResult rightResult operator).whenFalse.model =
      (Condition.scalarCompare operator.toInteger left right).refine context.names.shape context.analysis facts.model false :=
  scalarCondition_outcome_model compatible leftRead rightRead false

end Silver.Predicate
