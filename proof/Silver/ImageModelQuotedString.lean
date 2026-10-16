module

public import Silver.ImageModelStructuralSteps

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- Exact result of the opening quote in the checked scanner. -/
def opened (tables : Native.Tables) (state : Core.State) : Core.State :=
  {(Core.modelHelpers tables).matchByte (quoteContext (counted state)) 34 with previousArrayStart := false}

theorem consume_open_quote (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey)) :
    consume (Core.modelHelpers tables) state 34 = opened tables state := by
  rw [consume_between _ state 34 good room mode,
    structural_quote _ (counted state) (by exact notId) (by exact allowed)]
  rfl

theorem stringEffects_context (tables : Native.Tables) (state : Core.State) (codes : List Nat) :
    (codes.foldl (stringEffect tables) state).failed = state.failed ∧
    (codes.foldl (stringEffect tables) state).mode = state.mode ∧
    (codes.foldl (stringEffect tables) state).bytes = state.bytes := by
  induction codes generalizing state with
  | nil => exact ⟨rfl, rfl, rfl⟩
  | cons code codes ih => exact ih (stringEffect tables state code)

/-- Complete quoted string spellings are interpreted through the actual quote,
decoding, and End_String source paths. The final helper therefore receives the
same decoded characters used by the complete normalized table matcher. -/
theorem quoted_string_effect (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.StringContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey))
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      ([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state =
        (Core.modelHelpers tables).endString
          {characters.foldl (stringEffect tables) (opened tables state) with
            bytes := state.bytes + input.length + 2
            unicodeLeft := unicodeLeft
            unicodeValue := unicodeValue} := by
  have first : consume (Core.modelHelpers tables) state 34 = opened tables state :=
    consume_open_quote tables state good (by omega) mode notId allowed
  have startGood : (opened tables state).failed = false := good
  have startMode : (opened tables state).mode = .string := rfl
  have startRoom : (opened tables state).bytes + input.length ≤ 9223372036854775807 := by
    change state.bytes + 1 + input.length ≤ _
    omega
  obtain ⟨left, value, content⟩ := string_content_effect tables (opened tables state) characters input encoding startGood startMode startRoom
  let next := {characters.foldl (stringEffect tables) (opened tables state) with
    bytes := (opened tables state).bytes + input.length
    unicodeLeft := left
    unicodeValue := value}
  have nextGood : next.failed = false := (stringEffects_context tables _ characters).1.trans startGood
  have nextMode : next.mode = .string := (stringEffects_context tables _ characters).2.1.trans startMode
  have nextRoom : next.bytes ≠ 9223372036854775807 := by
    change state.bytes + 1 + input.length ≠ _
    omega
  refine ⟨left, value, ?_⟩
  simp only [List.foldl_append, List.foldl_cons, List.foldl_nil, first, content]
  rw [consume_quote _ next nextGood nextRoom nextMode]
  congr 1
  simp only [next, counted, opened, Core.modelHelpers, quoteContext]
  congr 1 <;> omega

/-- The string name field supplied to End_String is its complete decoded value,
represented by the already proved bounded raw-name observation. -/
theorem quoted_name_input (tables : Native.Tables) (state : Core.State) (characters : List Nat) :
    (characters.foldl (stringEffect tables) (opened tables state)).name =
      characters.foldl DecodedNative.remember ⟨0, fun _ => 32⟩ := by
  rw [stringEffects_name]
  rfl

end Silver.ImageModel.ScannerNative
