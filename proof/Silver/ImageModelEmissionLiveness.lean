module

public import Silver.ImageModelJsonBodies

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem Emits.of_dead (tables : Native.Tables) (before after : Core.State) (normalized : List Nat)
    (dead : ∀ kind, (after.matcher.cells kind).live = false) : Emits tables before after normalized := by
  intro kind initial invariant live
  rw [dead kind] at live
  contradiction

/-- Because emission transfers every initial invariant, it also proves that a
dead candidate cannot revive. An overlong initial word witnesses impossibility
if a supposedly revived final candidate were live. -/
theorem Emits.live_before {tables : Native.Tables} {before after : Core.State} {normalized : List Nat}
    (emits : Emits tables before after normalized) (kind : Native.Theory)
    (live : (after.matcher.cells kind).live = true) : (before.matcher.cells kind).live = true := by
  cases beforeLive : (before.matcher.cells kind).live with
  | true => rfl
  | false =>
      have initial : MatchInvariant (tables.byte kind) (tables.length kind)
          (List.replicate (tables.length kind + 1) 0) (before.matcher.cells kind) := by
        intro impossible
        rw [beforeLive] at impossible
        contradiction
      have bound := (emits kind _ initial live).2.1
      simp only [List.length_append, List.length_replicate] at bound
      omega

theorem Emits.dead_after {tables : Native.Tables} {before after : Core.State} {normalized : List Nat}
    (emits : Emits tables before after normalized) (kind : Native.Theory)
    (dead : (before.matcher.cells kind).live = false) : (after.matcher.cells kind).live = false := by
  cases live : (after.matcher.cells kind).live with
  | false => rfl
  | true =>
      have prior := emits.live_before kind live
      rw [dead] at prior
      contradiction

end Silver.ImageModel.ScannerNative
