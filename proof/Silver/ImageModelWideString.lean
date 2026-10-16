module

public import Silver.ImageModelStringResult

@[expose] public section
namespace Silver.ImageModel.JSON

/-- Byte-oriented JSON string decoding at the native Character boundary.
Raw UTF-8 bytes above ASCII and Unicode escapes above ASCII remain represented
here so their rejection by selected template matchers can be proved. No claim
equates raw UTF-8 bytes with Unicode scalar values. -/
inductive CodeUnitEncoding : Nat → List Nat → Prop
  | plain (code : Nat) (printable : 32 ≤ code) (byte : code ≤ 255)
      (quote : code ≠ 34) (escape : code ≠ 92) : CodeUnitEncoding code [code]
  | short (item code : Nat) (meaning : ScannerNative.shortEscape item = some code) :
      CodeUnitEncoding code [92, item]
  | unicode (a b c d : Nat) (ha : Core.hexadecimal a < 16) (hb : Core.hexadecimal b < 16)
      (hc : Core.hexadecimal c < 16) (hd : Core.hexadecimal d < 16) :
      CodeUnitEncoding (unicodeValue a b c d) [92, 117, a, b, c, d]

inductive CodeUnitContent : List Nat → List Nat → Prop
  | nil : CodeUnitContent [] []
  | cons (code : Nat) (characters spelling rest : List Nat)
      (character : CodeUnitEncoding code spelling) (tail : CodeUnitContent characters rest) :
      CodeUnitContent (code :: characters) (spelling ++ rest)

theorem CodeUnitEncoding.to_ascii {code : Nat} {bytes : List Nat}
    (encoding : CodeUnitEncoding code bytes) (ascii : code < 127) : CharacterEncoding code bytes := by
  cases encoding with
  | plain code printable byte quote escape => exact .plain code printable ascii quote escape
  | short item code meaning => exact .short item code meaning
  | unicode a b c d ha hb hc hd => exact .unicode a b c d ha hb hc hd ascii

theorem CodeUnitContent.to_ascii {characters input : List Nat}
    (encoding : CodeUnitContent characters input) (ascii : ∀ code ∈ characters, code < 127) :
    StringContent characters input := by
  induction encoding with
  | nil => exact .nil
  | cons code characters spelling rest character tail ih =>
      exact .cons code characters spelling rest (character.to_ascii (ascii code (by simp)))
        (ih (fun item member => ascii item (by simp [member])))

end Silver.ImageModel.JSON

namespace Silver.ImageModel.ScannerNative

/-- The complete Decoded effect, including deliberate death of all selected
template candidates on a non-ASCII code unit. -/
def wideEffect (tables : Native.Tables) (state : Core.State) (code : Nat) : Core.State :=
  {state with
    name := DecodedNative.remember state.name code
    matcher := if 127 ≤ code then {state.matcher with cells := fun kind => {state.matcher.cells kind with live := false}}
      else (DecodedNative.normalizedCode code).foldl (Core.matcher tables) state.matcher}

theorem decoded_wide (tables : Native.Tables) (state : Core.State) (code : Nat) :
    (Core.modelHelpers tables).decoded state code = wideEffect tables state code := by
  by_cases ascii : 127 ≤ code <;>
    simp [Core.modelHelpers, DecodedNative.output, DecodedNative.Action.eval, wideEffect, ascii]

theorem wide_encoding_effect (tables : Native.Tables) (state : Core.State) (code : Nat) (input : List Nat)
    (encoding : JSON.CodeUnitEncoding code input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      input.foldl (consume (Core.modelHelpers tables)) state =
        {wideEffect tables state code with
          bytes := state.bytes + input.length
          unicodeLeft := unicodeLeft
          unicodeValue := unicodeValue} := by
  cases encoding with
  | plain code printable byte quote escape =>
      refine ⟨state.unicodeLeft, state.unicodeValue, ?_⟩
      simp only [List.foldl_cons, List.foldl_nil, List.length_cons, List.length_nil, Nat.zero_add] at room ⊢
      rw [consume_plain _ state code good (by omega) mode quote escape printable, decoded_wide]
      rfl
  | short item code meaning =>
      refine ⟨state.unicodeLeft, state.unicodeValue, ?_⟩
      rw [consume_escape_pair _ state item code good (by simpa using room) mode meaning, decoded_wide]
      rfl
  | unicode a b c d ha hb hc hd =>
      refine ⟨0, JSON.unicodeValue a b c d, ?_⟩
      rw [consume_unicode_escape _ state a b c d good (by simpa using room) mode ha hb hc hd, decoded_wide]
      by_cases nonAscii : 127 ≤ JSON.unicodeValue a b c d <;> cases state <;>
        simp_all [wideEffect, unicodeCode, JSON.unicodeValue, Core.modelHelpers]
      rfl

theorem wideEffects_scratch (tables : Native.Tables) (state : Core.State) (codes : List Nat) (count left value : Nat) :
    codes.foldl (wideEffect tables) {state with bytes := count, unicodeLeft := left, unicodeValue := value} =
      {codes.foldl (wideEffect tables) state with bytes := count, unicodeLeft := left, unicodeValue := value} := by
  induction codes generalizing state with
  | nil => rfl
  | cons code codes ih =>
      change codes.foldl (wideEffect tables)
        {wideEffect tables state code with bytes := count, unicodeLeft := left, unicodeValue := value} = _
      exact ih _

theorem wide_content_effect (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      input.foldl (consume (Core.modelHelpers tables)) state =
        {characters.foldl (wideEffect tables) state with
          bytes := state.bytes + input.length
          unicodeLeft := unicodeLeft
          unicodeValue := unicodeValue} := by
  induction encoding generalizing state with
  | nil => exact ⟨state.unicodeLeft, state.unicodeValue, by simp⟩
  | cons code characters spelling rest character tail ih =>
      have prefixRoom : state.bytes + spelling.length ≤ 9223372036854775807 := by
        simp only [List.length_append] at room
        omega
      obtain ⟨left, value, first⟩ := wide_encoding_effect tables state code spelling character good mode prefixRoom
      let next := {wideEffect tables state code with
        bytes := state.bytes + spelling.length
        unicodeLeft := left
        unicodeValue := value}
      have nextGood : next.failed = false := good
      have nextMode : next.mode = .string := mode
      have nextRoom : next.bytes + rest.length ≤ 9223372036854775807 := by
        simpa only [next, List.length_append, Nat.add_assoc] using room
      obtain ⟨lastLeft, lastValue, restEffect⟩ := ih next nextGood nextMode nextRoom
      refine ⟨lastLeft, lastValue, ?_⟩
      simp only [List.foldl_append, first]
      rw [restEffect]
      simp only [next, wideEffects_scratch, List.foldl_cons, List.length_append, Nat.add_assoc]

theorem matcher_dead (tables : Native.Tables) (state : Native.Matcher) (byte : Nat) (kind : Native.Theory)
    (dead : (state.cells kind).live = false) : ((Core.matcher tables state byte).cells kind).live = false := by
  simp only [Core.matcher, Native.match_cells]
  split
  · simp [matchByte, dead]
  · exact dead

theorem matcher_fold_dead (tables : Native.Tables) (state : Native.Matcher) (bytes : List Nat) (kind : Native.Theory)
    (dead : (state.cells kind).live = false) : ((bytes.foldl (Core.matcher tables) state).cells kind).live = false := by
  induction bytes generalizing state with
  | nil => exact dead
  | cons byte rest ih => exact ih _ (matcher_dead tables state byte kind dead)

theorem wide_effect_dead (tables : Native.Tables) (state : Core.State) (code : Nat) (kind : Native.Theory)
    (dead : (state.matcher.cells kind).live = false) : ((wideEffect tables state code).matcher.cells kind).live = false := by
  simp only [wideEffect]
  split
  · rfl
  · exact matcher_fold_dead tables state.matcher _ kind dead

theorem wide_effects_dead (tables : Native.Tables) (state : Core.State) (codes : List Nat) (kind : Native.Theory)
    (dead : (state.matcher.cells kind).live = false) : ((codes.foldl (wideEffect tables) state).matcher.cells kind).live = false := by
  induction codes generalizing state with
  | nil => exact dead
  | cons code rest ih => exact ih _ (wide_effect_dead tables state code kind dead)

/-- This derives the ASCII precondition used by complete normalized-string
proofs. It is not assumed for strings capable of keeping a candidate alive. -/
theorem wide_effects_live_ascii (tables : Native.Tables) (state : Core.State) (codes : List Nat) (kind : Native.Theory)
    (live : ((codes.foldl (wideEffect tables) state).matcher.cells kind).live = true) :
    ∀ code ∈ codes, code < 127 := by
  induction codes generalizing state with
  | nil => simp
  | cons code rest ih =>
      have ascii : code < 127 := by
        by_cases nonAscii : code < 127
        · exact nonAscii
        have dead : ((wideEffect tables state code).matcher.cells kind).live = false := by
          simp [wideEffect, show 127 ≤ code by omega]
        have remains := wide_effects_dead tables _ rest kind dead
        simp only [List.foldl_cons] at live
        rw [remains] at live
        contradiction
      have tail := ih (wideEffect tables state code) live
      intro item member
      rcases List.mem_cons.mp member with equal | member
      · simpa only [equal] using ascii
      · exact tail item member

theorem live_content_ascii (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.CodeUnitContent characters input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807)
    (kind : Native.Theory)
    (live : ((input.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true) :
    JSON.StringContent characters input := by
  obtain ⟨left, value, effect⟩ := wide_content_effect tables state characters input encoding good mode room
  rw [effect] at live
  exact encoding.to_ascii (wide_effects_live_ascii tables state characters kind live)

end Silver.ImageModel.ScannerNative
