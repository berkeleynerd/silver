module

public import Silver.ScalarExpressionNativeTableAlgebra
public import Silver.ScalarArrayGrammarFrames

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option linter.unusedSimpArgs false

private theorem trivia_terminal {text rest : Source} (parsed : Trivia text rest) :
    triviaEnd rest = rest := by
  induction parsed with
  | eof => simp [triviaEnd]
  | stop _ _ space comment => simp [triviaEnd, space, comment]
  | space _ _ _ _ _ ih | comment _ _ _ _ _ ih => exact ih

theorem table_skip_idempotent (text : Source) (position : Nat) :
    skip text (skip text position) = skip text position := by
  by_cases zero : skip text position = 0
  · rw [zero]; rfl
  · have positionNonzero : position ≠ 0 := by
      intro equal
      simp [skip, equal] at zero
    have equation : skip text position = Cursor.triviaPosition text position := ite_eq_right positionNonzero
    calc
      skip text (skip text position) = Cursor.triviaPosition text (skip text position) := ite_eq_right zero
      _ = Cursor.triviaPosition text (Cursor.triviaPosition text position) := congrArg _ equation
      _ = Cursor.triviaPosition text position := by
        change Cursor.endPosition text (triviaEnd (Cursor.remaining text (Cursor.triviaPosition text position))) = _
        rw [Cursor.remaining_triviaPosition, trivia_terminal (trivia_complete _)]
        rfl
      _ = skip text position := equation.symm

theorem attribute_table_correspondence {text : Source} {names : Environment}
    {arrays : ArrayBindings.Table} (metadata : ArrayBindings.ValidTable text arrays)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (position maskFirst maskAfter : Nat)
    (bound : position ≤ text.length + 1) :
    ArrayAttributes.read text position names arrays maskFirst maskAfter false =
      ArrayGrammar.summarize names arrays initials elaborating
        (ArrayGrammar.attributeAtom text position names arrays maskFirst maskAfter) := by
  unfold ArrayAttributes.read ArrayGrammar.attributeAtom
  cases found : ArrayAttributes.parse text position names arrays maskFirst maskAfter false with
  | none => rfl
  | some query =>
      dsimp only [Bind.bind, Option.bind]
      have cursor := ArrayAttributes.parse_bounds bound found
      have shape := ArrayAttributes.parse_shape metadata found
      have scalar := ArrayAttributes.parse_scalar found
      have single := query.query.scalar_singleton scalar query.shape
      have bounded := query.query.bounds_bounded shape
      have integer : Integer.InRange (query.query.bounds query.shape).lower := bounded.1
      have literalBounds : (Integer.Interval.singleton (query.query.bounds query.shape).lower).Bounded :=
        ⟨integer, integer⟩
      have present : (Integer.Interval.singleton (query.query.bounds query.shape).lower).isEmpty = false := by
        simp [Integer.Interval.singleton, Integer.Interval.isEmpty]
      simp only [Option.bind_some, ArrayGrammar.summarize, leaves,
        show query.after ≠ 0 by omega, maxOperands, show ¬ 64 < 1 by decide,
        or_self, ↓reduceIte, Integer.Expr.infer, Integer.accepted,
        Integer.checked, present, Bool.false_eq_true, literalBounds, isStatic]
      exact congrArg (fun bounds => Result.mk query.after bounds 1 true) single

theorem table_nameAfter_letter {text : Source} {position : Nat}
    (named : nameAfter text position ≠ 0) : Named.letter (Cursor.byteAt text position) = true := by
  unfold nameAfter at named
  split at named
  · contradiction
  · unfold Named.identifierEnd at named
    split at named
    · rename_i first
      exact first.2
    · contradiction

theorem table_nameAfter_sign_zero {text : Source} {position : Nat}
    (sign : Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45) :
    nameAfter text position = 0 := by
  by_cases named : nameAfter text position = 0
  · exact named
  · have first := table_nameAfter_letter named
    rcases sign with sign | sign <;> simp [Named.letter, sign] at first

theorem table_integer_first_digit {text : Source} {position : Nat}
    (bound : position ≤ text.length + 1) (number : (ScalarLiteral.read text position).after ≠ 0) :
    ScalarLiteral.digitValue (Cursor.byteAt text position) < 10 := by
  have parsed := ScalarLiteral.read_sound bound number
  cases parsed with
  | @literal literalValue _ _ mantissa _ _ =>
      cases literalValue
      cases mantissa with
      | decimal numeral _ => exact (ScalarLiteral.numeral_first_digit numeral).2
      | based numeral _ _ _ _ => exact (ScalarLiteral.numeral_first_digit numeral).2

theorem table_nameAfter_integer_zero {text : Source} {position : Nat}
    (bound : position ≤ text.length + 1) (number : (ScalarLiteral.read text position).after ≠ 0) :
    nameAfter text position = 0 := by
  by_cases named : nameAfter text position = 0
  · exact named
  · have first := table_nameAfter_letter named
    have digit := table_integer_first_digit bound number
    simp only [Named.letter, decide_eq_true_eq] at first
    unfold ScalarLiteral.digitValue at digit
    split at digit
    · omega
    · split at digit
      · omega
      · split at digit <;> omega

theorem indexed_summary_table_correspondence {text : Source} {names : Environment}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {target : Nat}
    (capacity : names.length ≤ ArrayBindings.scalarLimit)
    (metadata : ArrayBindings.ValidTable text arrays)
    (initialsValid : ArrayBindings.ValidInitials initials)
    (member : ArrayBindings.binding arrays.items target ∈ arrays.items)
    (itemValid : ArrayBindings.ValidBinding (ArrayBindings.binding arrays.items target))
    (integerKind : (ArrayBindings.binding arrays.items target).isBoolean = false)
    (elaborating : Bool) (position afterName : Nat) (index : Parsed)
    (before : position ≤ afterName) (advanced : afterName < index.after)
    (indexBound : index.after ≤ text.length + 1)
    (reads : index.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length)) :
    (let subscript := summarize names (some index)
     let closed := symbol text subscript.after 41
     if closed ≤ afterName ∨ subscript.operands = maxOperands ∨
         ArrayBindings.contains (ArrayBindings.binding arrays.items target) subscript.bounds = false then invalid
     else ⟨closed, ArrayBindings.readViewBounds arrays.items initials elaborating target subscript.bounds,
       subscript.operands + 1, false⟩) =
      ArrayGrammar.summarize names arrays initials elaborating
        (if symbol text index.after 41 ≤ position then none
         else some ⟨symbol text index.after 41,
           .indexed (ArrayBindings.binding arrays.items target).viewDescriptor index.expression⟩) := by
  have positive : index.after ≠ 0 := by omega
  have inferredSame : index.expression.infer (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) =
      index.expression.infer (ranges names) := by
    apply Integer.Expr.infer_readsOnly reads
    intro scalar inside
    exact ArrayBindings.viewRanges_scalar arrays.items initials elaborating (ranges names) (by omega)
  by_cases closed : symbol text index.after 41 = 0
  · simp only [closed, Nat.zero_le, ↓reduceIte, ArrayGrammar.summarize]
    by_cases rejected : (summarize names (some index)).after = 0
    · rw [summarize_zero rejected]
      simp [invalid, symbol, skip]
    · obtain ⟨value, bounds, same, valuePositive, leavesBound, inferred, summary⟩ := summarize_success rejected
      have equal : value = index := by simpa using same.symm
      subst value
      rw [summary]
      simp only [closed, Nat.zero_le, true_or, ↓reduceIte]
  · have closing := symbol_bounds indexBound closed
    have closedPosition : ¬ symbol text index.after 41 ≤ position := by omega
    have closedName : ¬ symbol text index.after 41 ≤ afterName := by omega
    simp only [closedPosition, ↓reduceIte, ArrayGrammar.summarize, closed, leaves, false_or,
      Integer.Expr.infer, inferredSame]
    by_cases many : maxOperands < leaves index.expression
    · have more : maxOperands < 1 + leaves index.expression := by omega
      simp [summarize, positive, many, more, invalid, symbol, skip]
    · simp only [summarize, positive, many, or_self, ↓reduceIte]
      cases inferred : index.expression.infer (ranges names) with
      | none => simp [invalid, symbol, skip]
      | some bounds =>
          simp only [Option.bind_some, closedName, false_or]
          have count : (leaves index.expression = maxOperands) =
              (maxOperands < 1 + leaves index.expression) := by apply propext; omega
          by_cases full : leaves index.expression = maxOperands
          · simp only [full, true_or, ↓reduceIte, count]
            simp [maxOperands]
          · have space : ¬ maxOperands < 1 + leaves index.expression := by omega
            simp only [full, false_or, space, ↓reduceIte]
            cases inside : ArrayBindings.contains (ArrayBindings.binding arrays.items target) bounds with
            | false =>
                have rejected : Integer.arrayIndexCheck (ArrayBindings.binding arrays.items target).viewDescriptor bounds = false := by
                  rw [← ArrayBindings.contains_viewIndexCheck itemValid]; exact inside
                simp [Integer.arrayReadRange, rejected]
            | true =>
                rw [ArrayBindings.readViewBounds_correspondence metadata initialsValid member integerKind inside elaborating]
                simp [isStatic, Nat.add_comm]

theorem tableArrayAtomStep_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {target : Nat}
    (metadata : ArrayBindings.ValidTable text arrays)
    (initialsValid : ArrayBindings.ValidInitials initials)
    (member : ArrayBindings.binding arrays.items target ∈ arrays.items)
    (integerKind : (ArrayBindings.binding arrays.items target).isBoolean = false)
    (fuel position afterName maskFirst maskAfter : Nat) (elaborating : Bool)
    (before : position ≤ afterName) (afterBound : afterName ≤ text.length + 1)
    (recurse : TableReader)
    (child : ∀ next, afterName < next → next ≤ text.length + 1 →
      recurse text next names maskFirst maskAfter true arrays [] false .noElements =
        ArrayGrammar.summarize names arrays [] false
          (ArrayGrammar.parseFuel fuel text next names arrays maskFirst maskAfter true .noElements)) :
    tableArrayAtomStep (@recurse) text afterName names maskFirst maskAfter target arrays initials elaborating =
      ArrayGrammar.summarize names arrays initials elaborating
        (if symbol text afterName 40 = 0 then none else do
          let index ← ArrayGrammar.parseFuel fuel text (symbol text afterName 40) names arrays maskFirst maskAfter true .noElements
          let closed := symbol text index.after 41
          if closed ≤ position then none else
            some ⟨closed, .indexed (ArrayBindings.binding arrays.items target).viewDescriptor index.expression⟩) := by
  unfold tableArrayAtomStep
  dsimp only
  simp only [integerKind, Bool.false_eq_true, or_false]
  split
  · rfl
  · rename_i opened
    have opening := symbol_bounds afterBound opened
    rw [child _ opening.1 opening.2]
    cases parsed : ArrayGrammar.parseFuel fuel text (symbol text afterName 40) names arrays maskFirst maskAfter true .noElements with
    | none => simp [ArrayGrammar.summarize, invalid, symbol, skip]
    | some index =>
        have bounds := ArrayGrammar.parseFuel_bounds opening.2 parsed
        have reads := ArrayGrammar.parseFuel_noElements_readsOnly opening.2 parsed
        rw [summarizeTable_readsOnly arrays [] false valid.1 reads]
        exact indexed_summary_table_correspondence valid.1 metadata initialsValid member
          (metadata.member_valid member).2.1.1 integerKind elaborating
          position afterName index before (by omega) bounds.2 reads

end Silver.ScalarExpression.Native
