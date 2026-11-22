module

public import Silver.ScalarExpressionNativeDenotations

@[expose] public section

/-! The qualified-name helper is checked independently of the recursive
expression reader. Its imported lexical meanings retain every bounded cursor,
including zero and malformed/failing references. -/
namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem reference_equation_meaning (calls : Calls) (text : Source) (position : Nat)
    (bound : position ≤ text.length + 1)
    (skipMeaning : ∀ next, next ≤ text.length + 1 → calls.skip text next = skip text next)
    (nameMeaning : ∀ next, next ≤ text.length + 1 → calls.nameAfter text next = nameAfter text next) :
    referenceEquation calls text position = readReference text position := by
  have firstBound := skip_bounds text position bound
  have afterBound : nameAfter text (skip text position) ≤ text.length + 1 :=
    QualifiedNames.nameAfter_bounds text (skip text position)
  unfold referenceEquation readReference QualifiedNames.read QualifiedNames.singleDot
  simp only [show QualifiedNames.skip = skip from rfl,
    show QualifiedNames.nameAfter = nameAfter from rfl]
  rw [skipMeaning position bound, nameMeaning _ firstBound.2, skipMeaning _ afterBound]
  by_cases invalid : skip text position = 0 ∨ nameAfter text (skip text position) ≤ skip text position
  · simp only [invalid, ↓reduceIte]
  · simp only [invalid, ↓reduceIte]
    by_cases dot : 0 < skip text (nameAfter text (skip text position)) ∧
        skip text (nameAfter text (skip text position)) ≤ text.length ∧
        Cursor.byteAt text (skip text (nameAfter text (skip text position))) = 46 ∧
        (skip text (nameAfter text (skip text position)) = text.length ∨
          Cursor.byteAt text (skip text (nameAfter text (skip text position)) + 1) ≠ 46)
    · simp only [dot]
      have dotBound : skip text (nameAfter text (skip text position)) + 1 ≤ text.length + 1 := by
        have inside := dot.2.1
        omega
      have memberBound := skip_bounds text _ dotBound
      rw [skipMeaning _ dotBound, nameMeaning _ memberBound.2]
    · simp only [dot, ↓reduceIte]

theorem reference_body_meaning (calls : Calls) (text : Source) (position : Nat)
    (bound : position ≤ text.length + 1)
    (skipMeaning : ∀ next, next ≤ text.length + 1 → calls.skip text next = skip text next)
    (nameMeaning : ∀ next, next ≤ text.length + 1 → calls.nameAfter text next = nameAfter text next) :
    referenceBody.eval calls ({text,position} : Context).locals = readReference text position := by
  rw [reference_denotation]
  exact reference_equation_meaning calls text position bound skipMeaning nameMeaning

theorem reference_interpreted_bounds (calls : Calls) (text : Source) (position : Nat)
    (bound : position ≤ text.length + 1)
    (skipMeaning : ∀ next, next ≤ text.length + 1 → calls.skip text next = skip text next)
    (nameMeaning : ∀ next, next ≤ text.length + 1 → calls.nameAfter text next = nameAfter text next)
    (equation : calls.readReference text position = referenceBody.eval calls ({text,position} : Context).locals) :
    QualifiedNames.ValidSpan text (calls.readReference text position).first (calls.readReference text position).after ∧
      QualifiedNames.ValidSpan text (calls.readReference text position).qualifierFirst
        (calls.readReference text position).qualifierAfter ∧
      ((calls.readReference text position).after = 0 ∨
        (position < (calls.readReference text position).after ∧
          (calls.readReference text position).after ≤ text.length + 1)) := by
  rw [equation, reference_body_meaning calls text position bound skipMeaning nameMeaning]
  exact QualifiedNames.read_bounds text position bound

end Silver.ScalarExpression.Native
