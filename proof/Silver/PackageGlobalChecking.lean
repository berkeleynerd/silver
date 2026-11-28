module

public import Silver.PackageChecking

@[expose] public section

namespace Silver.Packages
open Predicate

/-- The checker observes global identities, while persistent local addresses
remain a separate execution concern. Lexical loop extension changes only the
fresh binder's local address. -/
def Address.globalIdentity : Address → Option Nat
  | .global identity => some identity
  | .local _ => none

structure FrameLayout.GlobalAgreement (left right : FrameLayout) : Prop where
  integers : ∀ slot, (left.integers slot).globalIdentity = (right.integers slot).globalIdentity
  booleans : ∀ slot, (left.booleans slot).globalIdentity = (right.booleans slot).globalIdentity

theorem Address.globalIdentity_iff {left right : Address}
    (same : left.globalIdentity = right.globalIdentity) (identity : Nat) :
    left = .global identity ↔ right = .global identity := by
  cases left <;> cases right <;> simp_all [Address.globalIdentity]

theorem FrameLayout.GlobalAgreement.globalCells {left right : FrameLayout}
    (same : left.GlobalAgreement right) (cells : List Cell) :
    globalCells left cells = globalCells right cells := by
  unfold Packages.globalCells
  apply congrArg (fun f => cells.filterMap f)
  funext cell
  cases cell with
  | integer slot =>
    have equal := same.integers slot
    cases l : left.integers slot <;> cases r : right.integers slot <;>
      simp_all [FrameLayout.place, Address.globalIdentity]
  | boolean slot =>
    have equal := same.booleans slot
    cases l : left.booleans slot <;> cases r : right.booleans slot <;>
      simp_all [FrameLayout.place, Address.globalIdentity]

theorem FrameLayout.GlobalAgreement.reset {left right : FrameLayout}
    (same : left.GlobalAgreement right) (declared : Integer.Ranges)
    (writes : List Cell) (flow : Flow) :
    resetGlobalFlow declared left writes flow = resetGlobalFlow declared right writes flow := by
  have ranges : resetGlobalRanges declared flow.scalars left writes =
      resetGlobalRanges declared flow.scalars right writes := by
    funext slot
    have equal := same.integers slot
    cases l : left.integers slot <;> cases r : right.integers slot <;>
      simp_all [resetGlobalRanges, Address.globalIdentity]
  unfold resetGlobalFlow
  rw [ranges]

theorem FrameLayout.GlobalAgreement.procedure {left right : FrameLayout}
    (same : left.GlobalAgreement right) (earlier : EffectEnvironment) (analysis : Integer.Analysis)
    (flow : Flow) (booleans : Boolean.Analysis) (call : ScalarProcedures.Call) :
    checkProcedureCall earlier left analysis flow booleans call =
      checkProcedureCall earlier right analysis flow booleans call := by
  simp only [checkProcedureCall, same.globalCells, same.reset]

mutual
  theorem FrameLayout.GlobalAgreement.statement {left right : FrameLayout}
      (same : left.GlobalAgreement right) (earlier : EffectEnvironment) (analysis : Integer.Analysis)
      (flow : Flow) (booleans : Boolean.Analysis) (item : Predicate.Statement) :
      checkPackageStatement earlier left analysis flow booleans item =
        checkPackageStatement earlier right analysis flow booleans item := by
    cases item with
    | procedureCall call =>
      simpa only [checkPackageStatement] using same.procedure earlier analysis flow booleans call
    | choice condition yes no =>
      simp only [checkPackageStatement,
        same.statements earlier analysis (condition.refine Bindings.emptyShape analysis flow true) booleans yes,
        same.statements earlier analysis (condition.refine Bindings.emptyShape analysis flow false) booleans no]
    | forLoop index reverse lower upper body =>
      simp only [checkPackageStatement]
      congr 1
      funext a
      congr 1
      funext b
      rw [same.statements earlier (analysis.withIndex index (Integer.loopBounds a b))
        (loopEntry analysis flow index (Integer.loopBounds a b)) booleans body]
    | simple item => cases item <;> simp only [checkPackageStatement]
    | scalarAssign | booleanAssign | callAssign | arrayAssign | booleanArrayAssign | reject | arrayLoop =>
      simp only [checkPackageStatement]
  termination_by sizeOf item

  theorem FrameLayout.GlobalAgreement.statements {left right : FrameLayout}
      (same : left.GlobalAgreement right) (earlier : EffectEnvironment) (analysis : Integer.Analysis)
      (flow : Flow) (booleans : Boolean.Analysis) (items : List Predicate.Statement) :
      checkPackageStatements earlier left analysis flow booleans items =
        checkPackageStatements earlier right analysis flow booleans items := by
    cases items with
    | nil => simp only [checkPackageStatements]
    | cons head tail =>
      simp only [checkPackageStatements, same.statement earlier analysis flow booleans head]
      congr 1
      funext next
      exact same.statements earlier analysis next booleans tail
  termination_by sizeOf items
end

end Silver.Packages
