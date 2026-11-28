module

public import Silver.ApplicationPackageBasicHidden
public import Silver.ApplicationPackageLoopFlow
public import Silver.PackageGlobalChecking

@[expose] public section

namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageObjectRows ApplicationPackageBodies

set_option backward.dsimp.instances true

theorem stateIndex_fresh {info : PackageBindings.Metadata} {kind : FunctionBindings.ScalarKind}
    {row : Row} (fresh : ∀ state ∈ info.states, row.first ≠ state.name.first) :
    stateIndex info kind row = none := by
  cases found : stateIndex info kind row with
  | none => rfl
  | some identity =>
    have active := stateIndex_some found
    exact False.elim (fresh _ (info.stateAt_mem identity active.1 active.2.1) active.2.2.2.2.1.symm)

theorem slotAddress_append_global {bound : Nat} {info : PackageBindings.Metadata}
    {kind : FunctionBindings.ScalarKind} {rows : List Row} {row : Row}
    (fresh : stateIndex info kind row = none) (slot : Nat) :
    (slotAddress bound info kind (rows ++ [row]) slot).globalIdentity =
      (slotAddress bound info kind rows slot).globalIdentity := by
  by_cases active : 0 < slot ∧ slot ≤ rows.length
  · have extended : 0 < slot ∧ slot ≤ (rows ++ [row]).length := by
      simp only [List.length_append, List.length_singleton]; omega
    simp only [slotAddress, active, extended]
    simp only [List.getD_eq_getElem?_getD, List.getElem?_append_left (by omega : slot - 1 < rows.length)]
  · by_cases next : slot = rows.length + 1
    · subst slot
      have last : (rows ++ [row]).getD rows.length {} = row := by
        simp only [List.getD_eq_getElem?_getD,
          List.getElem?_append_right (Nat.le_refl rows.length), Nat.sub_self,
          List.getElem?_cons_zero, Option.getD_some]
      have extended : 0 < rows.length + 1 ∧ rows.length + 1 ≤ (rows ++ [row]).length := by
        simp only [List.length_append, List.length_singleton]; omega
      rw [slotAddress, ite_eq_left extended, slotAddress, ite_eq_right active]
      simp only [Nat.add_sub_cancel, last, rowAddress, fresh, Address.globalIdentity]
    · have outside : ¬(0 < slot ∧ slot ≤ (rows ++ [row]).length) := by
        simp only [List.length_append, List.length_singleton]; omega
      simp only [slotAddress, active, outside, ite_false]

theorem inner_global_agreement {source : Statement.Input} {iteration : Statement.Iteration} (bound : Nat)
    (fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first) :
    (layout bound source.info (Statement.innerContext source iteration)).GlobalAgreement
      (layout bound source.info source.context) := by
  constructor
  · intro slot
    simpa only [layout, scalarRows, Statement.innerContext, List.map_append, List.map_cons, List.map_nil] using
      slotAddress_append_global (bound := bound) (rows := scalarRows source.context)
        (stateIndex_fresh (kind := .integer) (row := ⟨iteration.first, iteration.last, 0, 0⟩) fresh) slot
  · intro slot
    rfl

theorem inner_scalar_fields {source : Statement.Input} {iteration : Statement.Iteration}
    (fields : ScalarStateFields source.info.states source.context.scalarNames)
    (fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first) :
    ScalarStateFields source.info.states (Statement.innerContext source iteration).scalarNames := by
  intro row member state declared same
  rcases List.mem_append.mp member with old | added
  · exact fields row old state declared same
  · cases List.mem_singleton.mp added
    exact False.elim (fresh state declared same)

/-- Widening at native loop entry gives every global its declaration interval,
including a private name newly hidden by the lexical loop binder. -/
theorem inner_global_range {calls : Statement.Calls} {source : Statement.Input}
    {iteration : Statement.Iteration} (bound : Nat)
    (original : Statement.OriginalHeader source iteration)
    (fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first)
    (fields : ScalarStateFields source.info.states source.context.scalarNames)
    (body : source.context.elaborating = false)
    (base : ScalarMetadata.BaseReady source.context.scalarNames source.context.declarationCount)
    (count : source.input.scan.facts.count = source.context.scalarNames.length)
    (space : source.context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit)
    {slot identity : Nat}
    (selected : (layout bound source.info (Statement.innerContext source iteration)).integers slot = .global identity) :
    ((Statement.innerContext source iteration).flow
      (Statement.innerInput source iteration (Statement.widened (Statement.loopHeaderReaders calls) source iteration)).scan.facts).scalars slot =
      (Statement.innerContext source iteration).analysis.declared slot := by
  have agreement := inner_global_agreement bound fresh
  have outer := (Address.globalIdentity_iff (agreement.integers slot) identity).mp selected
  have live := slotAddress_global outer
  have inside : slot ≤ source.context.scalarNames.length := by
    simpa only [scalarRows, List.length_map] using live.2.1
  have mutable := (scalar_global_analysis base.size base.body fields.globalRows outer).2
  rw [original.innerFlow body base.body count space, original.innerAnalysis base.count space]
  rw [loopEntry_declared iteration.bounds (by omega) mutable]
  simp only [Integer.Analysis.withIndex, Integer.put, show slot ≠ source.context.scalarNames.length + 1 by omega, ite_false]

end Silver.ApplicationPackageFrameLayout
