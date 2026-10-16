module

public import Silver.ImageModelStringNormalization
public import Silver.ImageModelJsonSyntax

@[expose] public section
namespace Silver.ImageModel.JSON

def unicodeValue (a b c d : Nat) : Nat :=
  ((Core.hexadecimal a * 16 + Core.hexadecimal b) * 16 + Core.hexadecimal c) * 16 + Core.hexadecimal d

/-- Standard JSON spellings of ASCII characters. A selected template cannot
survive a non-ASCII Decoded call, so this is the precise accepted-string domain.
Unicode escapes permit either hexadecimal letter case and all four digits. -/
inductive CharacterEncoding : Nat → List Nat → Prop
  | plain (code : Nat) (printable : 32 ≤ code) (ascii : code < 127) (quote : code ≠ 34) (escape : code ≠ 92) :
      CharacterEncoding code [code]
  | short (item code : Nat) (meaning : ScannerNative.shortEscape item = some code) :
      CharacterEncoding code [92, item]
  | unicode (a b c d : Nat) (ha : Core.hexadecimal a < 16) (hb : Core.hexadecimal b < 16)
      (hc : Core.hexadecimal c < 16) (hd : Core.hexadecimal d < 16) (ascii : unicodeValue a b c d < 127) :
      CharacterEncoding (unicodeValue a b c d) [92, 117, a, b, c, d]

inductive StringContent : List Nat → List Nat → Prop
  | nil : StringContent [] []
  | cons (code : Nat) (characters spelling rest : List Nat)
      (character : CharacterEncoding code spelling) (tail : StringContent characters rest) :
      StringContent (code :: characters) (spelling ++ rest)

theorem CharacterEncoding.ascii {code : Nat} {bytes : List Nat} (encoding : CharacterEncoding code bytes) : code < 127 := by
  cases encoding with
  | plain _ _ ascii _ _ => exact ascii
  | unicode _ _ _ _ _ _ _ _ ascii => exact ascii
  | short item code meaning =>
      unfold ScannerNative.shortEscape at meaning
      split at meaning <;> (try contradiction)
      all_goals cases meaning; decide

end Silver.ImageModel.JSON

namespace Silver.ImageModel.ScannerNative

/-- The mathematical character effect forgets source spelling but preserves all
scanner context outside the bounded name observation and table matcher. -/
def stringEffect (tables : Native.Tables) (state : Core.State) (code : Nat) : Core.State :=
  {state with
    name := DecodedNative.remember state.name code
    matcher := (DecodedNative.normalizedCode code).foldl (Core.matcher tables) state.matcher}

theorem model_decoded_ascii (tables : Native.Tables) (state : Core.State) (code : Nat) (ascii : code < 127) :
    (Core.modelHelpers tables).decoded state code = stringEffect tables state code := by
  simp only [Core.modelHelpers, DecodedNative.output, show ¬127 ≤ code by omega, ↓reduceIte, stringEffect]

/-- For every legal spelling, the actual source scanner has exactly the same
semantic character effect. The byte count records the original spelling, and
Unicode scratch registers remain explicit rather than being assumed equal. -/
theorem character_encoding_effect (tables : Native.Tables) (state : Core.State) (code : Nat) (input : List Nat)
    (encoding : JSON.CharacterEncoding code input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      input.foldl (consume (Core.modelHelpers tables)) state =
        {stringEffect tables state code with
          bytes := state.bytes + input.length
          unicodeLeft := unicodeLeft
          unicodeValue := unicodeValue} := by
  cases encoding with
  | plain code printable ascii quote escape =>
      refine ⟨state.unicodeLeft, state.unicodeValue, ?_⟩
      simp only [List.foldl_cons, List.foldl_nil, List.length_cons, List.length_nil, Nat.zero_add] at room ⊢
      rw [consume_plain _ state code good (by omega) mode quote escape printable, model_decoded_ascii _ _ _ ascii]
      rfl
  | short item code meaning =>
      refine ⟨state.unicodeLeft, state.unicodeValue, ?_⟩
      rw [consume_escape_pair _ state item code good (by simpa using room) mode meaning,
        model_decoded_ascii _ _ _ (JSON.CharacterEncoding.ascii (.short item code meaning))]
      rfl
  | unicode a b c d ha hb hc hd ascii =>
      refine ⟨0, JSON.unicodeValue a b c d, ?_⟩
      rw [consume_unicode_escape _ state a b c d good (by simpa using room) mode ha hb hc hd]
      have code : unicodeCode (Core.modelHelpers tables) a b c d = JSON.unicodeValue a b c d := rfl
      rw [code]
      rw [model_decoded_ascii _ _ _ ascii]
      cases state
      simp_all [stringEffect]

/-- Character effects commute with byte-count and Unicode-scratch updates, the
only spelling-dependent fields. This supports arbitrary string composition. -/
theorem stringEffect_scratch (tables : Native.Tables) (state : Core.State) (code count left value : Nat) :
    stringEffect tables {state with bytes := count, unicodeLeft := left, unicodeValue := value} code =
      {stringEffect tables state code with bytes := count, unicodeLeft := left, unicodeValue := value} := rfl

theorem stringEffects_scratch (tables : Native.Tables) (state : Core.State) (codes : List Nat) (count left value : Nat) :
    codes.foldl (stringEffect tables) {state with bytes := count, unicodeLeft := left, unicodeValue := value} =
      {codes.foldl (stringEffect tables) state with bytes := count, unicodeLeft := left, unicodeValue := value} := by
  induction codes generalizing state with
  | nil => rfl
  | cons code codes ih =>
      simp only [List.foldl_cons, stringEffect_scratch, ih]

/-- Complete ASCII JSON string contents preserve decoding meaning for arbitrary
length and arbitrary mixtures of raw, short-escaped and Unicode-escaped input.
This theorem concerns original byte spellings, not only canonical examples. -/
theorem string_content_effect (tables : Native.Tables) (state : Core.State) (characters input : List Nat)
    (encoding : JSON.StringContent characters input) (good : state.failed = false)
    (mode : state.mode = .string) (room : state.bytes + input.length ≤ 9223372036854775807) :
    ∃ unicodeLeft unicodeValue,
      input.foldl (consume (Core.modelHelpers tables)) state =
        {characters.foldl (stringEffect tables) state with
          bytes := state.bytes + input.length
          unicodeLeft := unicodeLeft
          unicodeValue := unicodeValue} := by
  induction encoding generalizing state with
  | nil =>
      exact ⟨state.unicodeLeft, state.unicodeValue, by simp⟩
  | cons code characters spelling rest character tail ih =>
      have prefixRoom : state.bytes + spelling.length ≤ 9223372036854775807 := by
        simp only [List.length_append] at room
        omega
      obtain ⟨left, value, first⟩ := character_encoding_effect tables state code spelling character good mode prefixRoom
      let next := {stringEffect tables state code with
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
      simp only [next, stringEffects_scratch, List.foldl_cons, List.length_append, Nat.add_assoc]

end Silver.ImageModel.ScannerNative
