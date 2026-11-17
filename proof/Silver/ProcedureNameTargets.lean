module

public import Silver.ProcedureNameReadings
public import Silver.PredicateProcedureCallReadings

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

/-- The spelling of a writable actual is tied to its selected scalar or
Boolean binding. Boolean selection also records the native scalar-first rule. -/
inductive CellSpelling (text : Source) (context : ParseContext) (first after : Nat) : Cell → Prop
  | integer {index : Nat} : ScalarExpression.lookup text context.scalarNames first after = index →
      index ≠ 0 → CellSpelling text context first after (.integer index)
  | boolean {index : Nat} : ScalarExpression.lookup text context.scalarNames first after = 0 →
      BooleanBindings.lookup text context.booleanNames first after = index → index ≠ 0 →
      CellSpelling text context first after (.boolean index)

inductive WritableNameAt (text : Source) (context : ParseContext) (position after : Nat)
    (cell : Cell) : Prop
  | name {first : Nat} {bytes : Source} : skipAt text position = first → first ≠ 0 →
      Named.IdentifierAt text first bytes after → CellSpelling text context first after cell →
      WritableNameAt text context position after cell

theorem procedureTargetActual_name {text : Source} {context : ParseContext}
    {position : Nat} {facts : ActiveFlow} {parameter : ProcedureBindings.Formal}
    (accepted : (procedureTargetActual text context position facts parameter).after ≠ 0) :
    WritableNameAt text context position
      (procedureTargetActual text context position facts parameter).after
      (targetCell (procedureTargetIdentity context (procedureTargetActual text context position facts parameter))) := by
  unfold procedureTargetActual at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i named
    simp only [named, ↓reduceIte]
    have positive : skipAt text position ≠ 0 := fun zero => named (Or.inl zero)
    have advanced : skipAt text position < nameAfter text (skipAt text position) := by omega
    have endPositive : Named.identifierEnd text (skipAt text position) ≠ 0 := by
      simpa only [nameAfter, positive, ↓reduceIte] using (show nameAfter text (skipAt text position) ≠ 0 by omega)
    obtain ⟨bytes, identifier⟩ := Named.identifierEnd_sound text _ endPositive
    have identifier' : Named.IdentifierAt text (skipAt text position) bytes
        (nameAfter text (skipAt text position)) := by
      simpa only [nameAfter, positive, ↓reduceIte] using identifier
    split at accepted
    · rename_i integerKind
      simp only [integerKind, ↓reduceIte]
      split at accepted
      · contradiction
      · rename_i checked
        have scalarPositive : scalarTarget text context position ≠ 0 := fun zero => checked (Or.inl zero)
        rw [ite_eq_right checked]
        simp only [procedureTargetIdentity, scalarPositive, ↓reduceIte, targetCell]
        exact .name rfl positive identifier' (.integer rfl scalarPositive)
    · rename_i booleanKind
      simp only [booleanKind, ↓reduceIte]
      split at accepted
      · contradiction
      · rename_i checked
        have flagPositive : booleanTarget text context position ≠ 0 := fun zero => checked (Or.inl zero)
        have noScalar : ScalarExpression.lookup text context.scalarNames (skipAt text position)
            (nameAfter text (skipAt text position)) = 0 := by
          by_cases absent : ScalarExpression.lookup text context.scalarNames (skipAt text position)
              (nameAfter text (skipAt text position)) = 0
          · exact absent
          · simp [booleanTarget, absent] at flagPositive
        have selected : BooleanBindings.lookup text context.booleanNames (skipAt text position)
            (nameAfter text (skipAt text position)) = booleanTarget text context position := by
          simp only [booleanTarget, noScalar, ne_eq, not_true_eq_false, ↓reduceIte]
        simp only [checked, ↓reduceIte, procedureTargetIdentity, targetCell]
        exact .name rfl positive identifier' (.boolean noScalar selected flagPositive)

/-- A lexical name exclusion separates two writable cells without assuming
that all entries in either metadata table have distinct spellings. -/
theorem WritableNameAt.apart {text : Source} {context : ParseContext}
    {position after limit targetFirst targetAfter : Nat} {cell target : Cell}
    (source : WritableNameAt text context position after cell)
    (targetSpelling : CellSpelling text context targetFirst targetAfter target)
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (afterBound : after ≤ limit) :
    cell ≠ target ∧ ActualNameFreeTrace text limit targetFirst targetAfter after := by
  cases source with
  | @name first bytes skipped positive identifier spelling =>
    cases spelling with
    | integer found nonzero =>
        cases targetSpelling with
        | integer targetFound targetPositive =>
            obtain ⟨apart, rest⟩ := trace.scalarName before skipped positive identifier afterBound found targetFound targetPositive
            exact ⟨fun same => apart (Cell.integer.inj same), rest⟩
        | boolean =>
            refine ⟨?_, (trace.identifier before skipped positive identifier afterBound).2⟩
            intro same
            cases same
    | boolean absent found nonzero =>
        cases targetSpelling with
        | integer =>
            refine ⟨?_, (trace.identifier before skipped positive identifier afterBound).2⟩
            intro same
            cases same
        | boolean _ targetFound targetPositive =>
            obtain ⟨apart, rest⟩ := trace.booleanName before skipped positive identifier afterBound found targetFound targetPositive
            exact ⟨fun same => apart (Cell.boolean.inj same), rest⟩

end Silver.Predicate
