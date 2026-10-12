module

public meta import Lean.Elab.Tactic.ElabTerm
public meta import Lean.Elab.ElabRules
public meta import Lean.Meta.Tactic.AuxLemma

public section

/-!
Proof-artifact support for generated source reconstruction. Elaborating a large
concrete witness against its expected equality repeats expensive conversion in
the elaborator. Instead, elaborate the witness independently and let Lean's
kernel check it at the exact goal type before returning an auxiliary theorem.
This uses the same checked auxiliary-lemma path as `decide +kernel`; it adds no
axiom and does not disable kernel checking. Every returned goal type has a
kernel-checked proof; the type-indexed cache may reuse an existing such proof.
-/

open Lean Elab Tactic Meta

namespace Silver.CertificateWitness

/-- Check a closed reconstruction witness at the goal type in the kernel.
Generated witnesses supply all arguments explicitly; this tactic does not infer
missing arguments from the goal or capture local hypotheses. -/
elab "kernel_exact " term:term : tactic => withMainContext do
  let expected ← getMainTarget
  let proof ← Term.elabTerm term none
  Term.synthesizeSyntheticMVarsNoPostponing
  let proof ← instantiateMVars proof
  let expected ← instantiateMVars expected
  let levelsInType := (collectLevelParams {} expected).params
  let levels := (← Term.getLevelNames).reverse.filter levelsInType.contains
  let name ← withOptions (Elab.async.set · false) do
    mkAuxLemma levels expected proof
  closeMainGoalUsing `kernel_exact fun _ _ =>
    pure (mkConst name (levels.map Level.param))

end Silver.CertificateWitness
