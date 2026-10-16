module

public import Silver.ImageModelRootScan

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

theorem remembered_observation (characters : List Nat) (buffer : Nat → Nat) :
    (characters.foldl DecodedNative.remember ⟨0, buffer⟩).observe = nameObservation characters := by
  rw [NameNative.remember_fold_observe]
  exact remember_fold characters {} [] rfl

theorem raw_prefix_two (name : DecodedNative.RawName) (long : 2 ≤ name.length) :
    name.observe.characters.take 2 = [name.buffer 1, name.buffer 2] := by
  simp only [DecodedNative.RawName.observe, ← List.map_take, List.take_range]
  rw [Nat.min_eq_left (by omega : 2 ≤ min name.length 21)]
  rfl

/-- The bounded name buffer recognizes a W-node tag by the first two decoded
characters, even for strings longer than its storage capacity. -/
theorem remembered_node_tag (characters : List Nat) (buffer : Nat → Nat) :
    let name := characters.foldl DecodedNative.remember ⟨0, buffer⟩
    (decide (2 ≤ name.length) && decide (name.buffer 1 = 87 ∧ name.buffer 2 = 95)) = JSON.nodeTag characters := by
  let name := characters.foldl DecodedNative.remember ⟨0, buffer⟩
  have observed := remembered_observation characters buffer
  have length : name.length = min characters.length 22 := congrArg NameState.length observed
  change (decide (2 ≤ name.length) && decide (name.buffer 1 = 87 ∧ name.buffer 2 = 95)) = _
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.and_eq_true, decide_eq_true_eq, JSON.nodeTag, beq_iff_eq]
  by_cases long : 2 ≤ characters.length
  · have longName : 2 ≤ name.length := by omega
    have same := congrArg (fun value : NameState => value.characters.take 2) observed
    change name.observe.characters.take 2 = (nameObservation characters).characters.take 2 at same
    rw [raw_prefix_two name longName] at same
    simp only [nameObservation, ← List.map_take, List.take_take] at same
    change [name.buffer 1, name.buffer 2] = (characters.take 2).map nameByte at same
    have exactName := map_names_exact (characters.take 2) [87, 95] (by decide +kernel)
    rw [← exactName, ← same]
    simp [longName]
  · have shortName : ¬ 2 ≤ name.length := by omega
    have shortTag : characters.take 2 ≠ [87, 95] := by
      intro eq
      have size := congrArg List.length eq
      simp only [List.length_take, List.length_cons, List.length_nil] at size
      omega
    simp [shortName, shortTag]

/-- Complete string contents modify only the decoded-name observation and the
canonical matcher stream; lexical bookkeeping is handled by Consume. -/
theorem stringEffects_state (tables : Native.Tables) (state : Core.State) (characters : List Nat) :
    characters.foldl (stringEffect tables) state =
      {state with
        name := characters.foldl DecodedNative.remember state.name
        matcher := (characters.flatMap DecodedNative.normalizedCode).foldl (Core.matcher tables) state.matcher} := by
  induction characters generalizing state with
  | nil => rfl
  | cons code rest ih =>
      simp only [List.foldl_cons, ih, stringEffect, List.flatMap_cons, List.foldl_append]

/-- Exact post-quote observations. Unicode scratch registers are intentionally
kept separate because distinct equivalent JSON spellings can leave different
values there. All semantically relevant name, tag and matcher observations are
computed from the complete decoded contents. -/
def quotedResult (tables : Native.Tables) (state : Core.State) (characters : List Nat)
    (byteLength unicodeLeft unicodeValue : Nat) : Core.State :=
  let context := quoteContext state
  let name := characters.foldl DecodedNative.remember ⟨0, fun _ => 32⟩
  {context with
    failed := if context.isKey then if characters = StringNative.Name.key.bytes then state.failed else true
      else if context.isTheoryTag && decide (characters ≠ StringNative.Name.theoryTag.bytes) then true else state.failed
    matcher := (JSON.stringBytes characters).foldl (Core.matcher tables) state.matcher
    name := name
    mode := .between
    phase := if context.isKey && decide (characters = StringNative.Name.key.bytes) then .rootColon else state.phase
    theory := if !context.isKey && !context.isTheoryTag && context.isName then
        if characters = StringNative.Name.integer.bytes then some .integer
        else if characters = StringNative.Name.string.bytes then some .string
        else if characters = StringNative.Name.image.bytes then some .image
        else state.theory
      else state.theory
    nodeIdPending := state.previousArrayStart && JSON.nodeTag characters
    previousArrayStart := false
    bytes := state.bytes + byteLength
    unicodeLeft := unicodeLeft
    unicodeValue := unicodeValue}

theorem quoted_string_result (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.StringContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey))
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      ([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state =
        quotedResult tables state characters (input.length + 2) unicodeLeft unicodeValue := by
  obtain ⟨left, value, result⟩ := quoted_string_effect tables state characters input encoding good mode notId allowed room
  refine ⟨left, value, result.trans ?_⟩
  rw [stringEffects_state]
  have named (name : StringNative.Name) := SourceBridge.interpreted_static_name Core.nameCall
    ⟨fun _ _ => rfl⟩ characters (fun _ => 32) name
  have tag := remembered_node_tag characters (fun _ => 32)
  dsimp only at tag
  dsimp only [Core.modelHelpers, Core.State.setString, Core.State.stringView, StringNative.model,
    opened, quoteContext, counted, StringNative.classification, StringNative.pending, quotedResult]
  simp only [JSON.stringBytes, List.foldl_append, List.foldl_cons, List.foldl_nil, named, Bool.and_assoc]
  rw [tag]
  simp only [decide_eq_true_eq, decide_not, Nat.add_assoc]

end Silver.ImageModel.ScannerNative
