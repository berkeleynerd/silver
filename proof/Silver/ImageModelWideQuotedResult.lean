module

public import Silver.ImageModelJsonFields

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

/-- The actual matcher effect of one decoded code unit. Non-ASCII content
kills candidates rather than pretending to emit canonical ASCII bytes. -/
def wideMatcher (tables : Native.Tables) (matcher : Native.Matcher) (code : Nat) : Native.Matcher :=
  if 127 ≤ code then {matcher with cells := fun kind => {matcher.cells kind with live := false}}
  else (DecodedNative.normalizedCode code).foldl (Core.matcher tables) matcher

theorem wideEffects_state (tables : Native.Tables) (state : Core.State) (characters : List Nat) :
    characters.foldl (wideEffect tables) state =
      {state with
        name := characters.foldl DecodedNative.remember state.name
        matcher := characters.foldl (wideMatcher tables) state.matcher} := by
  induction characters generalizing state with
  | nil => rfl
  | cons code rest ih =>
      simp only [List.foldl_cons, ih, wideEffect, wideMatcher]

theorem wideMatcher_active (tables : Native.Tables) (matcher : Native.Matcher) (code : Nat) :
    (wideMatcher tables matcher code).inTheory = matcher.inTheory := by
  unfold wideMatcher
  split
  · rfl
  · exact matcher_fold_active tables matcher _

theorem wideMatchers_active (tables : Native.Tables) (matcher : Native.Matcher) (characters : List Nat) :
    (characters.foldl (wideMatcher tables) matcher).inTheory = matcher.inTheory := by
  induction characters generalizing matcher with
  | nil => rfl
  | cons code rest ih => exact (ih _).trans (wideMatcher_active tables matcher code)

theorem wide_quoted_string_effect (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey))
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      ([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state =
        (Core.modelHelpers tables).endString
          {characters.foldl (wideEffect tables) (opened tables state) with
            bytes := state.bytes + input.length + 2
            unicodeLeft := unicodeLeft
            unicodeValue := unicodeValue} := by
  have first := consume_open_quote tables state good (by omega) mode notId allowed
  have startGood : (opened tables state).failed = false := good
  have startMode : (opened tables state).mode = .string := rfl
  have startRoom : (opened tables state).bytes + input.length ≤ 9223372036854775807 := by
    change state.bytes + 1 + input.length ≤ _
    omega
  obtain ⟨left, value, content⟩ := wide_content_effect tables (opened tables state) characters input encoding startGood startMode startRoom
  let next := {characters.foldl (wideEffect tables) (opened tables state) with
    bytes := (opened tables state).bytes + input.length
    unicodeLeft := left
    unicodeValue := value}
  have nextGood : next.failed = false := by simp only [next, wideEffects_state]; exact good
  have nextMode : next.mode = .string := by simp only [next, wideEffects_state]; rfl
  have nextRoom : next.bytes ≠ 9223372036854775807 := by
    change state.bytes + 1 + input.length ≠ _
    omega
  refine ⟨left, value, ?_⟩
  simp only [List.foldl_append, List.foldl_cons, List.foldl_nil, first, content]
  rw [consume_quote _ next nextGood nextRoom nextMode]
  congr 1
  simp only [next, counted, opened, Core.modelHelpers, quoteContext]
  congr 1 <;> omega

/-- Wide decoding has the same name, tag and scope observations as the ASCII
result. Its matcher is the real wide fold, including candidate invalidation. -/
def wideQuotedResult (tables : Native.Tables) (state : Core.State) (characters : List Nat)
    (byteLength unicodeLeft unicodeValue : Nat) : Core.State :=
  {quotedResult tables state characters byteLength unicodeLeft unicodeValue with
    matcher := Core.matcher tables
      (characters.foldl (wideMatcher tables) (Core.matcher tables state.matcher 34)) 34}

theorem wide_quoted_string_result (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey))
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      ([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state =
        wideQuotedResult tables state characters (input.length + 2) unicodeLeft unicodeValue := by
  obtain ⟨left, value, result⟩ := wide_quoted_string_effect tables state characters input encoding good mode notId allowed room
  refine ⟨left, value, result.trans ?_⟩
  rw [wideEffects_state]
  have named (name : StringNative.Name) := SourceBridge.interpreted_static_name Core.nameCall
    ⟨fun _ _ => rfl⟩ characters (fun _ => 32) name
  have tag := remembered_node_tag characters (fun _ => 32)
  dsimp only at tag
  dsimp only [Core.modelHelpers, Core.State.setString, Core.State.stringView, StringNative.model,
    opened, quoteContext, counted, StringNative.classification, StringNative.pending, wideQuotedResult, quotedResult]
  simp only [named, Bool.and_assoc]
  rw [tag]
  simp only [decide_eq_true_eq, decide_not, Nat.add_assoc]

theorem wide_quoted_active (tables : Native.Tables) (state : Core.State) (characters : List Nat)
    (count left value : Nat) :
    (wideQuotedResult tables state characters count left value).matcher.inTheory = state.matcher.inTheory := by
  change (Core.matcher tables (characters.foldl (wideMatcher tables) (Core.matcher tables state.matcher 34)) 34).inTheory = _
  rw [show ∀ matcher byte, (Core.matcher tables matcher byte).inTheory = matcher.inTheory from
    fun matcher byte => Native.match_inTheory tables matcher byte .integer]
  rw [wideMatchers_active]
  exact Native.match_inTheory tables state.matcher 34 .integer

/-- A surviving candidate after the closing quote establishes ASCII for every
decoded code unit; the premise concerns the actual Consume result. -/
theorem wide_quoted_live_ascii (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey))
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) (kind : Native.Theory)
    (live : ((([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true) :
    JSON.StringContent characters input := by
  obtain ⟨left, value, result⟩ := wide_quoted_string_result tables state characters input encoding good mode notId allowed room
  rw [result] at live
  have middleLive : ((characters.foldl (wideMatcher tables) (Core.matcher tables state.matcher 34)).cells kind).live = true := by
    cases middle : ((characters.foldl (wideMatcher tables) (Core.matcher tables state.matcher 34)).cells kind).live with
    | true => rfl
    | false =>
        have dead := matcher_dead tables _ 34 kind middle
        change ((Core.matcher tables _ 34).cells kind).live = true at live
        rw [dead] at live
        contradiction
  apply encoding.to_ascii
  apply wide_effects_live_ascii tables (opened tables state) characters kind
  rw [wideEffects_state]
  exact middleLive

/-- Canonical emissions are needed only while a candidate survives. On that
branch ASCII is derived above and the existing exact ASCII theorem applies. -/
theorem wide_quoted_emits (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true)
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    Emits tables state (([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state)
      (JSON.stringBytes characters) := by
  intro kind initial invariant live
  have ascii := wide_quoted_live_ascii tables state characters input encoding good mode notId (.inl active) room kind live
  obtain ⟨left, value, result⟩ := quoted_string_result tables state characters input ascii good mode notId (.inl active) room
  rw [result] at live ⊢
  exact quoted_result_emits tables state characters _ left value active kind initial invariant live

theorem wide_local_string (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    LocalResult tables state (([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state)
      ([34] ++ input ++ [34]) (JSON.stringBytes characters) (state.previousArrayStart && JSON.nodeTag characters) ∧
    ∀ kind, ((([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
      JSON.StringContent characters input := by
  refine ⟨?_, wide_quoted_live_ascii tables state characters input encoding good mode notId (.inl active) room⟩
  have emits := wide_quoted_emits tables state characters input encoding good mode notId active room
  obtain ⟨left, value, result⟩ := wide_quoted_string_result tables state characters input encoding good mode notId (.inl active) room
  rw [result] at emits ⊢
  have context := nested_string_scope tables state characters (input.length + 2) left value depth
  refine ⟨context.2.trans good, (wide_quoted_active tables state characters _ left value).trans active,
    context.1, ?_, .inl rfl, rfl, rfl, emits⟩
  change state.bytes + (input.length + 2) = _
  simp only [List.length_append, List.length_cons, List.length_nil]
  omega

theorem wide_field_string (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (legal : FieldLegal state.field (.string characters))
    (good : state.failed = false) (mode : state.mode = .between) (notId : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3)
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807) :
    FieldResult tables state (([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state)
      (.string characters) ([34] ++ input ++ [34]) (JSON.stringBytes characters) (state.previousArrayStart && JSON.nodeTag characters) ∧
    ∀ kind, ((([34] ++ input ++ [34]).foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
      JSON.StringContent characters input := by
  refine ⟨?_, wide_quoted_live_ascii tables state characters input encoding good mode notId (.inl active) room⟩
  have emits := wide_quoted_emits tables state characters input encoding good mode notId active room
  obtain ⟨left, value, result⟩ := wide_quoted_string_result tables state characters input encoding good mode notId (.inl active) room
  rw [result] at emits ⊢
  have context := field_string_scope tables state characters (input.length + 2) left value depth legal
  refine ⟨context.2.trans good, (wide_quoted_active tables state characters _ left value).trans active,
    ?_, ?_, .inl rfl, rfl, rfl, emits⟩
  · exact context.1
  · change state.bytes + (input.length + 2) = _
    simp only [List.length_append, List.length_cons, List.length_nil]
    omega

end Silver.ImageModel.ScannerNative
