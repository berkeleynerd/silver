module

public import Silver.ApplicationPackageHiddenReset
public import Silver.PackageReadMentions

@[expose] public section

namespace Silver.Packages
open Predicate

private theorem guardCandidate_read {analysis : Integer.Analysis} {target threshold : Integer.Expr}
    {bounds : Integer.Interval} {slot : Nat} {value : Int}
    (selected : Integer.guardCandidate analysis target threshold bounds = some (slot, value)) :
    ScalarProcedures.Cell.integer slot ∈ integerReads target := by
  cases target <;> simp only [Integer.guardCandidate] at selected <;> try contradiction
  rename_i identity
  split at selected
  · simp only [Option.some.injEq, Prod.mk.injEq] at selected
    simp only [integerReads, List.mem_singleton, selected.1]
  · contradiction

theorem refineComparison_unread {analysis : Integer.Analysis} {ranges : Integer.Ranges}
    {operator : Integer.Comparison} {left right : Integer.Expr} {truth : Bool} {slot : Nat}
    (leftAbsent : ScalarProcedures.Cell.integer slot ∉ integerReads left)
    (rightAbsent : ScalarProcedures.Cell.integer slot ∉ integerReads right) :
    Integer.refineComparison analysis ranges operator left right truth slot = ranges slot := by
  cases lower : left.infer ranges with
  | none => simp only [Integer.refineComparison, lower]
  | some a =>
    cases upper : right.infer ranges with
    | none => simp only [Integer.refineComparison, lower, upper]
    | some b =>
      simp only [Integer.refineComparison, lower, upper]
      cases first : Integer.guardCandidate analysis left right b with
      | none =>
        cases second : Integer.guardCandidate analysis right left a with
        | none => rfl
        | some choice =>
          have selected := guardCandidate_read second
          exact Integer.Ranges.refineName_other (fun same => rightAbsent (same.symm ▸ selected))
      | some choice =>
        have selected := guardCandidate_read first
        exact Integer.Ranges.refineName_other (fun same => leftAbsent (same.symm ▸ selected))

/-- Short-circuit joins preserve an unread nonempty cell as well as direct
refinement. Declared package state ranges are nonempty, including in arms whose
path predicate is unreachable. -/
theorem condition_refine_unread {shape : Bindings.Shape} {analysis : Integer.Analysis}
    {condition : Condition} {flow : Flow} {truth : Bool} {slot : Nat} {bounds : Integer.Interval}
    (absent : ScalarProcedures.Cell.integer slot ∉ conditionReads condition)
    (incoming : flow.scalars slot = some bounds) (nonempty : bounds.isEmpty = false) :
    (condition.refine shape analysis flow truth).scalars slot = some bounds := by
  induction condition generalizing flow truth with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanName |
      booleanArrayRead | eager | booleanCompare => exact incoming
  | scalarCompare operator left right =>
    have both : ScalarProcedures.Cell.integer slot ∉ integerReads left ∧
        ScalarProcedures.Cell.integer slot ∉ integerReads right := by
      simpa only [conditionReads, List.mem_append, not_or] using absent
    exact (refineComparison_unread both.1 both.2).trans incoming
  | parenthesized inner ih | negated inner ih => exact ih absent incoming
  | andThen left right ihl ihr | orElse left right ihl ihr =>
    have both : ScalarProcedures.Cell.integer slot ∉ conditionReads left ∧
        ScalarProcedures.Cell.integer slot ∉ conditionReads right := by
      simpa only [conditionReads, List.mem_append, not_or] using absent
    simp only [Condition.refine]
    split
    · first
      | exact ihr both.2 (ihl both.1 incoming)
      | exact Integer.Ranges.join_fixed (ihl both.1 incoming) (ihr both.2 (ihl both.1 incoming)) nonempty
    · first
      | exact ihr both.2 (ihl both.1 incoming)
      | exact Integer.Ranges.join_fixed (ihl both.1 incoming) (ihr both.2 (ihl both.1 incoming)) nonempty

/-- A loop widens every mutable outer state before installing its distinct
lexical binder. This supplies the hidden-global reset invariant at loop entry. -/
theorem loopEntry_declared {analysis : Integer.Analysis} {flow : Flow} {binder slot : Nat}
    (bounds : Integer.Interval) (distinct : slot ≠ binder) (mutable : analysis.mutable slot = true) :
    (loopEntry analysis flow binder bounds).scalars slot = analysis.declared slot := by
  simp only [loopEntry, Integer.put, distinct, ite_false, Integer.Analysis.widen, mutable, ite_true]

theorem loopExit_declared {analysis : Integer.Analysis} {before after : Flow} {slot : Nat}
    (lower upper : Integer.Interval) (mutable : analysis.mutable slot = true)
    (incoming : before.scalars slot = analysis.declared slot) :
    (loopExit analysis before after lower upper).scalars slot = analysis.declared slot := by
  simp only [loopExit]
  split
  · exact incoming
  · simp only [Integer.Analysis.widen, mutable, ite_true]

end Silver.Packages
