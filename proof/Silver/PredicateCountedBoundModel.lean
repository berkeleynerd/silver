module

public import Silver.PredicateConditionAdmission
public import Silver.ScalarArrayGrammarRecognition

@[expose] public section

namespace Silver.Predicate
open Compose

/-- The counted-bound gate keeps original bindings, offsets and relative order.
It changes only which arrays may be resolved while checking the written bound. -/
def countedArrays (names : ArrayBindings.Metadata) : ArrayBindings.Metadata :=
  names.filter ArrayBindings.Binding.mutable

theorem countedArrays_valid {text : Source} {names : ArrayBindings.Metadata}
    (valid : ArrayBindings.ValidMetadata text names) :
    ArrayBindings.ValidMetadata text (countedArrays names) := by
  refine ⟨Nat.le_trans (List.length_filter_le _ _) valid.1, ?_, ?_⟩
  · intro item present
    exact valid.2.1 item (List.mem_filter.mp present).1
  · exact valid.2.2.filter _

def countedBoundGate (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (first after : Nat) : ScalarExpression.Result :=
  ScalarExpression.ArrayGrammar.read text position (context.readingNames facts)
    context.arrayTable first after (elaborating := context.elaborating) (arrayReads := .mutableElements)

/-- Filtering is an admission gate. Successful readings retain the original
scalar reader's complete result and its original array symbolic identities. -/
def readCountedBound (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (first after : Nat) : ScalarExpression.Result :=
  if (countedBoundGate text context position facts first after).after = 0 then ScalarExpression.invalid
  else readScalarInFlow text context position facts first after

theorem readCountedBound_original {text : Source} {context : ParseContext} {position : Nat}
    {facts : ActiveFlow} {first after : Nat}
    (accepted : (readCountedBound text context position facts first after).after ≠ 0) :
    readCountedBound text context position facts first after =
      readScalarInFlow text context position facts first after := by
  unfold readCountedBound at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i nonzero
    simp only [nonzero, ↓reduceIte]

theorem readCountedBound_bound (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (first after : Nat) (bounded : position ≤ text.length + 1) :
    (readCountedBound text context position facts first after).after ≤ text.length + 1 := by
  by_cases zero : (readCountedBound text context position facts first after).after = 0
  · simp [zero]
  · have original := readCountedBound_original zero
    rw [original] at zero ⊢
    obtain ⟨expression, parsed⟩ := ScalarExpression.ArrayGrammar.read_sound bounded zero
    exact parsed.cursorBounds.2.2

end Silver.Predicate
