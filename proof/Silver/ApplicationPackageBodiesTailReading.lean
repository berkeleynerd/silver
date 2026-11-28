module

public import Silver.ApplicationPackageBodiesAccepted

@[expose] public section

namespace Silver.ApplicationPackageBodies.Tail
open ApplicationPackages Predicate

/-- The scans in the list are exactly the statements after each successful
step, in source order. The terminator stays at the last scan for the caller. -/
inductive Reading (calls : TailCalls) (ctx : Context) : TailState → List ApplicationScan → ApplicationScan → Prop where
  | done (state : TailState) (present : state.value.scan.position ≠ 0)
      (stopped : calls.atBodyStop ctx.text state.value.scan.position ctx.stop = true)
      (required : ctx.requireOne = true → state.seen = true) :
      Reading calls ctx state [] state.value
  | cons (state : TailState) (first : ApplicationScan) {rest : List ApplicationScan} {result : ApplicationScan}
      (present : state.value.scan.position ≠ 0)
      (consumes : calls.atBodyStop ctx.text state.value.scan.position ctx.stop = false)
      (scanned : statement calls ctx state = first)
      (advanced : state.value.scan.position < first.scan.position)
      (following : Reading calls ctx ⟨first, true⟩ rest result) :
      Reading calls ctx state (first :: rest) result

private theorem continue_tests {calls : TailCalls} {ctx : Context} {state next : TailState}
    (step : reader calls ctx state = .continued next) :
    state.value.scan.position ≠ 0 ∧ calls.atBodyStop ctx.text state.value.scan.position ctx.stop = false := by
  unfold reader tailStep at step
  split at step
  · rename_i guard
    exact ⟨guard.1, by simpa only [Bool.not_eq_true'] using guard.2⟩
  · split at step <;> contradiction

private theorem seen_state {s : TailState} (seen : s.seen = true) : s = ⟨s.value, true⟩ := by
  cases s
  cases seen
  rfl

theorem execution_reading {calls : TailCalls} {ctx : Context} {state : TailState} {result : ApplicationScan}
    (run : TailExecution (reader calls ctx) state result) (complete : result.scan.position ≠ 0) :
    ∃ items, Reading calls ctx state items result := by
  induction run with
  | returned step =>
    obtain ⟨rfl, stopped, required⟩ := tailStep_accepted step complete
    exact ⟨[], .done _ complete stopped required⟩
  | continued step _ ih =>
    obtain ⟨present, consumes⟩ := continue_tests step
    obtain ⟨advanced, seen, scanned⟩ := tailStep_progress step
    obtain ⟨rest, next⟩ := ih complete
    refine ⟨_ :: rest, .cons _ _ present consumes scanned.symm advanced ?_⟩
    exact (seen_state seen) ▸ next

theorem reading_unique {calls : TailCalls} {ctx : Context} {state : TailState}
    {first second : List ApplicationScan} {left right : ApplicationScan}
    (a : Reading calls ctx state first left) (b : Reading calls ctx state second right) :
    first = second ∧ left = right := by
  induction a generalizing second right with
  | done state _ stopped _ =>
    cases b with
    | done => exact ⟨rfl, rfl⟩
    | cons _ _ _ active => simp only [stopped, reduceCtorEq] at active
  | cons state item _ consume found _ _ ih =>
    cases b with
    | done _ _ stopped => simp only [stopped, reduceCtorEq] at consume
    | cons _ other _ _ same _ following =>
      have firstEq := found.symm.trans same
      cases firstEq
      obtain ⟨rfl, rfl⟩ := ih following
      exact ⟨rfl, rfl⟩

theorem reading_nonempty {calls : TailCalls} {ctx : Context} {state : TailState}
    {items : List ApplicationScan} {value : ApplicationScan}
    (read : Reading calls ctx state items value) (required : ctx.requireOne = true)
    (unread : state.seen = false) : items ≠ [] := by
  cases read with
  | done _ _ _ seen => simp only [unread, Bool.false_eq_true] at seen; exact False.elim (seen required)
  | cons => simp

theorem tailFuel_reading {calls : TailCalls} {ctx : Context} {state : TailState} {fuel : Nat} {result : ApplicationScan}
    (run : tailFuel (reader calls ctx) fuel state = some result) (complete : result.scan.position ≠ 0) :
    ∃ items, Reading calls ctx state items result ∧
      ∀ other final, Reading calls ctx state other final → other = items ∧ final = result := by
  obtain ⟨items, read⟩ := execution_reading (tailFuel_sound run) complete
  exact ⟨items, read, fun _ _ other => reading_unique other read⟩

end Silver.ApplicationPackageBodies.Tail
