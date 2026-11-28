module

public import Silver.ApplicationPackageBodiesStatementMeaning
public import Silver.ApplicationPackageBodiesTailMeaning

@[expose] public section

namespace Silver.ApplicationPackageBodies
open ApplicationPackages Predicate

/-- A successful return from one tail step is the same scan at its delimiter.
A recursive statement rejection or a required empty tail has zero position. -/
theorem tailStep_accepted {calls : TailCalls} {text : Source} {ctx : ParseContext}
    {info : PackageBindings.Metadata} {stop : BodyStop} {required : Bool}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    {state : TailState} {value : ApplicationScan}
    (step : tailStep calls text ctx info stop required catalog procedures state = .returned value)
    (accepted : value.scan.position ≠ 0) :
    value = state.value ∧ calls.atBodyStop text state.value.scan.position stop = true ∧
      (required = true → state.seen = true) := by
  unfold tailStep at step
  split at step
  · dsimp only at step
    split at step <;> cases step
    exact False.elim (accepted rfl)
  · rename_i inactive
    split at step
    · cases step
      exact False.elim (accepted rfl)
    · rename_i valid
      cases step
      simp only [not_or, not_and] at valid
      exact ⟨rfl, by simpa [accepted] using inactive, fun req => Bool.eq_true_of_ne_false (valid.2 req)⟩

theorem tailExecution_accepted {calls : TailCalls} {text : Source} {ctx : ParseContext}
    {info : PackageBindings.Metadata} {stop : BodyStop} {required : Bool}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    {state : TailState} {value : ApplicationScan}
    (run : TailExecution (tailStep calls text ctx info stop required catalog procedures) state value)
    (accepted : value.scan.position ≠ 0) :
    state.value.scan.position ≤ value.scan.position ∧ calls.atBodyStop text value.scan.position stop = true ∧
      (required = true → state.seen = false → state.value.scan.position < value.scan.position) := by
  induction run with
  | returned step =>
    obtain ⟨rfl, stopped, seen⟩ := tailStep_accepted step accepted
    exact ⟨Nat.le_refl _, stopped, fun req notSeen => False.elim (by simpa only [notSeen, Bool.false_eq_true] using seen req)⟩
  | continued step _ ih =>
    obtain ⟨greater, _, _⟩ := tailStep_progress step
    obtain ⟨bounded, stopped, _⟩ := ih accepted
    exact ⟨by omega, stopped, fun _ _ => by omega⟩

namespace Statement

def ValidReturn (calls : Calls) (s : Input) (value : ApplicationScan) : Prop :=
  s.input.scan.position < value.scan.position ∧ calls.validBody s.text s.context value.scan = true

private def AcceptedReturn (calls : Calls) (s : Input) (value : ApplicationScan) : Prop :=
  value.scan.position ≠ 0 → ValidReturn calls s value

private theorem invalid_return (calls : Calls) (s : Input) :
    AcceptedReturn calls s (invalidApplication s.input) := fun ok => False.elim (ok rfl)

theorem validate_accepted {calls : Calls} {s : Input} {value : ApplicationScan} :
    (validate calls s value).scan.position ≠ 0 → ValidReturn calls s (validate calls s value) := by
  change AcceptedReturn calls s (validate calls s value)
  unfold validate
  split
  · exact invalid_return calls s
  · rename_i checked
    exact fun _ => ⟨Nat.lt_of_not_ge (fun stalled => checked (Or.inl stalled)),
      Bool.eq_true_of_ne_false (fun invalid => checked (Or.inr (by simp [invalid])))⟩

private theorem accepted_guard (calls : Calls) (s : Input) (test : Prop) [Decidable test]
    (result : ApplicationScan) :
    AcceptedReturn calls s (if test then invalidApplication s.input else validate calls s result) := by
  split
  · exact invalid_return calls s
  · exact validate_accepted

theorem closeIf_accepted {calls : Calls} {s : Input} {arms : Arms} :
    (closeIf calls s arms).scan.position ≠ 0 → ValidReturn calls s (closeIf calls s arms) :=
  accepted_guard calls s _ _

theorem forStatement_accepted {calls : Calls} {s : Input} {afterFor : Nat} :
    (forStatement calls s afterFor).scan.position ≠ 0 → ValidReturn calls s (forStatement calls s afterFor) := by
  change AcceptedReturn calls s (forStatement calls s afterFor)
  unfold forStatement
  cases forHeader calls s afterFor with
  | none => exact invalid_return calls s
  | some it =>
    dsimp only
    split
    · exact invalid_return calls s
    · let widened := calls.widenInto s.context it.value.scan.facts
      let inside := tail calls s (innerContext s it) (innerInput s it widened) .endOnly
      exact accepted_guard calls s (inside.scan.position = 0)
        (closeTokens calls s (afterIteration calls s it widened inside) (.word "loop"))

theorem statementFuel_accepted {calls : Calls} {s : Input} {fuel : Nat} {value : ApplicationScan}
    (basic : let result := calls.applicationBasic s.text s.context s.input s.info s.catalog s.procedures
      result.scan.position ≠ 0 → ValidReturn calls s result)
    (found : statementFuel calls fuel s = some value) (ok : value.scan.position ≠ 0) :
    ValidReturn calls s value := by
  dsimp only [statementFuel] at found
  split at found
  · cases found
    exact False.elim (ok rfl)
  · split at found
    · obtain ⟨done, _, rfl⟩ := Option.map_eq_some_iff.mp found
      cases done with
      | none => exact False.elim (ok rfl)
      | some arms => exact closeIf_accepted ok
    · split at found
      · cases found
        exact forStatement_accepted ok
      · cases found
        exact basic ok

end Statement
end Silver.ApplicationPackageBodies
