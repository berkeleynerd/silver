module

public import Silver.ImageModelStringEncoding

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem stringEffects_name (tables : Native.Tables) (state : Core.State) (codes : List Nat) :
    (codes.foldl (stringEffect tables) state).name = codes.foldl DecodedNative.remember state.name := by
  induction codes generalizing state with
  | nil => rfl
  | cons code codes ih =>
      simp only [List.foldl_cons, ih, stringEffect]

theorem stringEffects_matcher (tables : Native.Tables) (state : Core.State) (codes : List Nat) :
    (codes.foldl (stringEffect tables) state).matcher =
      (codes.flatMap DecodedNative.normalizedCode).foldl (Core.matcher tables) state.matcher := by
  induction codes generalizing state with
  | nil => rfl
  | cons code codes ih =>
      simp only [List.foldl_cons, ih, stringEffect, List.flatMap_cons, List.foldl_append]

/-- The scanner's bounded name observation and complete normalized output both
refer to the same decoded string, regardless of its original JSON spelling. -/
theorem string_content_observations (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.StringContent characters input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807) :
    let result := input.foldl (consume (Core.modelHelpers tables)) state
    result.name = characters.foldl DecodedNative.remember state.name ∧
    result.matcher = (characters.flatMap DecodedNative.normalizedCode).foldl (Core.matcher tables) state.matcher ∧
    result.bytes = state.bytes + input.length := by
  obtain ⟨left, value, effect⟩ := string_content_effect tables state characters input encoding good mode room
  simp only [effect, stringEffects_name, stringEffects_matcher, and_self]

/-- A live selected table matcher receives the complete canonical serialization
of every decoded string content. This is independent of the finite templates. -/
theorem string_content_matches (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.StringContent characters input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807)
    (active : state.matcher.inTheory = true) (kind : Native.Theory) (emitted : List Nat)
    (invariant : MatchInvariant (tables.byte kind) (tables.length kind) emitted (state.matcher.cells kind)) :
    MatchInvariant (tables.byte kind) (tables.length kind)
      (emitted ++ characters.flatMap DecodedNative.normalizedCode)
      ((input.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind) := by
  have observation := string_content_observations tables state characters input encoding good mode room
  rw [observation.2.1]
  rw [SourceBridge.interpreted_fold tables (Core.matcher tables) ⟨fun _ _ => rfl⟩ _ state.matcher active kind]
  exact match_fold_preserves _ emitted (state.matcher.cells kind) invariant

end Silver.ImageModel.ScannerNative
