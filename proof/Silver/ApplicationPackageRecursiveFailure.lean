module

public import Silver.ApplicationPackageRecursiveReading

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open ApplicationPackages

theorem validate_rejected {calls : Calls} {source : Input} {value : ApplicationScan}
    (rejected : (validate calls source value).scan.position = 0) :
    validate calls source value = invalidApplication source.input := by
  unfold validate at rejected ⊢
  split at rejected
  · rename_i rejectedGuard
    exact ite_eq_left rejectedGuard
  · rename_i ready
    exact False.elim (ready (Or.inl (by omega)))

theorem closeIf_rejected {calls : Calls} {source : Input} {state : Arms}
    (rejected : (closeIf calls source state).scan.position = 0) :
    closeIf calls source state = invalidApplication source.input := by
  let branch := elseResult calls source state
  let result := closeTokens calls source
    (withFacts branch (calls.joinInto branch.scan.facts state.yes)) (.word "if")
  have equation : closeIf calls source state =
      if branch.scan.position = 0 then invalidApplication source.input else validate calls source result := rfl
  rw [equation] at rejected ⊢
  by_cases missing : branch.scan.position = 0
  · exact ite_eq_left missing
  · rw [ite_eq_right missing] at rejected ⊢
    exact validate_rejected rejected

theorem forStatement_rejected {calls : Calls} {source : Input} {afterFor : Nat}
    (rejected : (forStatement calls source afterFor).scan.position = 0) :
    forStatement calls source afterFor = invalidApplication source.input := by
  unfold forStatement at rejected ⊢
  cases header : forHeader calls source afterFor with
  | none => rfl
  | some iteration =>
    simp only [header] at rejected ⊢
    by_cases stopped : iteration.value.scan.position ≤ source.input.scan.position
    · exact ite_eq_left stopped
    · rw [ite_eq_right stopped] at rejected ⊢
      by_cases missing : (tail calls source (innerContext source iteration)
          (innerInput source iteration (calls.widenInto source.context iteration.value.scan.facts)) .endOnly).scan.position = 0
      · exact ite_eq_left missing
      · rw [ite_eq_right missing] at rejected ⊢
        exact validate_rejected rejected

/-- Every rejected control statement returns the original invalidated scan.
The direct Basic branch retains its own checked return contract. This covers
all failure paths without assuming facts about an unexecuted successful arm. -/
theorem statementFuel_rejected {calls : Calls} {source : Input} {fuel : Nat} {result : ApplicationScan}
    (evaluated : statementFuel calls fuel source = some result) (rejected : result.scan.position = 0) :
    result = invalidApplication source.input ∨
      result = calls.applicationBasic source.text source.context source.input source.info source.catalog source.procedures := by
  unfold statementFuel at evaluated
  split at evaluated
  · cases evaluated
    exact Or.inl rfl
  · dsimp only at evaluated
    split at evaluated
    · obtain ⟨state, _, same⟩ := Option.map_eq_some_iff.mp evaluated
      cases state with
      | none => cases same; exact Or.inl rfl
      | some state => cases same; exact Or.inl (closeIf_rejected rejected)
    · split at evaluated
      · cases evaluated
        exact Or.inl (forStatement_rejected rejected)
      · cases evaluated
        exact Or.inr rfl

end Silver.ApplicationPackageBodies.Statement
