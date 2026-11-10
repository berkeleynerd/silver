module

public import Silver.ProcedureNameIdentity
public import Silver.ProcedureNameTraceTraversal

@[expose] public section

namespace Silver.Predicate
open Compose

/-- The executable lexical exclusion prevents a scalar token from resolving
to the writable target's binding. Lookup identity, rather than its spelling
or a uniqueness assumption about the environment, establishes the conclusion. -/
theorem ActualNameFreeTrace.scalarName {text bytes : Source}
    {names : ScalarExpression.Environment}
    {position first finish limit targetFirst targetAfter index target : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (firstPositive : first ≠ 0) (identifier : Named.IdentifierAt text first bytes finish)
    (finishBound : finish ≤ limit)
    (found : ScalarExpression.lookup text names first finish = index)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetPositive : target ≠ 0) :
    index ≠ target ∧ ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  obtain ⟨excluded, rest⟩ := trace.identifier before skipped firstPositive identifier finishBound
  refine ⟨?_, rest⟩
  intro same
  rw [same] at found
  have equal := scalarLookup_same_spelling found targetFound targetPositive
  rw [excluded] at equal
  contradiction

theorem ActualNameFreeTrace.booleanName {text bytes : Source}
    {names : BooleanBindings.Environment}
    {position first finish limit targetFirst targetAfter index target : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (firstPositive : first ≠ 0) (identifier : Named.IdentifierAt text first bytes finish)
    (finishBound : finish ≤ limit)
    (found : BooleanBindings.lookup text names first finish = index)
    (targetFound : BooleanBindings.lookup text names targetFirst targetAfter = target)
    (targetPositive : target ≠ 0) :
    index ≠ target ∧ ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  obtain ⟨excluded, rest⟩ := trace.identifier before skipped firstPositive identifier finishBound
  refine ⟨?_, rest⟩
  intro same
  rw [same] at found
  have equal := booleanLookup_same_spelling found targetFound targetPositive
  rw [excluded] at equal
  contradiction

end Silver.Predicate
