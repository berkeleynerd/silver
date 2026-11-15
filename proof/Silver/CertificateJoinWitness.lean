module

public import Silver.SourceLexer
public meta import Lean.Elab.Tactic.ElabTerm
public meta import Lean.Elab.ElabRules
public meta import Lean.Meta.Tactic.AuxLemma

public section

/-!
Compact untrusted witness construction for the largest source certificate.
This constructs the existing character-list join theorem directly, avoiding
per-character syntax elaboration. Every witness is checked by the kernel at
the exact goal through the same auxiliary-lemma path as `decide +kernel`.
No native evaluation theorem, trusted generator result or axiom is introduced.
-/

open Lean Elab Tactic Meta

namespace Silver.CertificateJoinWitness

/-- Construct the same explicit character-list term as a generated list literal,
without elaborating one syntax node for every character. -/
private meta def charactersExpr (text : String) : Expr := Id.run do
  let char := mkConst ``Char
  let cons := mkApp (mkConst ``List.cons [Level.zero]) char
  let mut result := mkApp (mkConst ``List.nil [Level.zero]) char
  for c in text.toList.reverse do
    result := mkApp2 cons (toExpr c) result
  return result

/-- Build the existing `string_join_ofList` witness from compact string literals
and check it at the exact goal type. The supplied strings and generated term are
untrusted candidates: the kernel checks every character and the complete join. -/
elab "kernel_join " left:str right:str : tactic => withMainContext do
  let expected ← instantiateMVars (← getMainTarget)
  let proof := mkApp2 (mkConst ``Silver.Source.string_join_ofList)
    (charactersExpr left.getString) (charactersExpr right.getString)
  let levelsInType := (collectLevelParams {} expected).params
  let levels := (← Term.getLevelNames).reverse.filter levelsInType.contains
  let name ← withOptions (Elab.async.set · false) do
    mkAuxLemma levels expected proof
  closeMainGoalUsing `kernel_join fun _ _ =>
    pure (mkConst name (levels.map Level.param))


end Silver.CertificateJoinWitness
