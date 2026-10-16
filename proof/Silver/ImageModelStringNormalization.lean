module

public import Silver.ImageModelStringScan

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- A two-byte escape and its unescaped meaning reach the same Decoded call.
Only the raw-byte count differs from a one-byte input character. -/
theorem consume_escape_pair (helpers : Core.Helpers) (state : Core.State) (item code : Nat)
    (good : state.failed = false) (room : state.bytes + 2 ≤ 9223372036854775807)
    (mode : state.mode = .string) (escaped : shortEscape item = some code) :
    [92, item].foldl (consume helpers) state =
      helpers.decoded {state with bytes := state.bytes + 2} code := by
  simp only [List.foldl_cons, List.foldl_nil]
  rw [consume_escape_start helpers state good (by omega) mode]
  rw [consume_short_escape helpers _ item code (by exact good) (by simp only [counted]; omega) rfl escaped]
  congr 1
  cases state
  simp_all [counted, Nat.add_assoc]

def unicodeCode (helpers : Core.Helpers) (a b c d : Nat) : Nat :=
  ((helpers.hex a * 16 + helpers.hex b) * 16 + helpers.hex c) * 16 + helpers.hex d

/-- The source's four guarded hexadecimal steps denote exactly JSON's four-digit
Unicode escape. This proof covers every spelling and every 16-bit result. -/
theorem consume_unicode_escape (helpers : Core.Helpers) (state : Core.State) (a b c d : Nat)
    (good : state.failed = false) (room : state.bytes + 6 ≤ 9223372036854775807)
    (mode : state.mode = .string) (ha : helpers.hex a < 16) (hb : helpers.hex b < 16)
    (hc : helpers.hex c < 16) (hd : helpers.hex d < 16) :
    [92, 117, a, b, c, d].foldl (consume helpers) state =
      {helpers.decoded {state with
          bytes := state.bytes + 6
          mode := .unicode
          unicodeLeft := 0
          unicodeValue := unicodeCode helpers a b c d} (unicodeCode helpers a b c d) with mode := .string} := by
  let s0 := {state with bytes := state.bytes + 1, mode := StringNative.Mode.escape}
  let s1 := {state with
    bytes := state.bytes + 2
    mode := StringNative.Mode.unicode
    unicodeLeft := 4
    unicodeValue := 0}
  let s2 := {s1 with bytes := state.bytes + 3, unicodeLeft := 3, unicodeValue := helpers.hex a}
  let s3 := {s1 with
    bytes := state.bytes + 4
    unicodeLeft := 2
    unicodeValue := helpers.hex a * 16 + helpers.hex b}
  let s4 := {s1 with
    bytes := state.bytes + 5
    unicodeLeft := 1
    unicodeValue := (helpers.hex a * 16 + helpers.hex b) * 16 + helpers.hex c}
  have e0 : consume helpers state 92 = s0 := consume_escape_start helpers state good (by omega) mode
  have e1 : consume helpers s0 117 = s1 := by
    rw [consume_unicode_start helpers s0 good (by dsimp [s0]; omega) rfl]
    simp only [s0, s1, counted, Nat.add_assoc]
  have e2 : consume helpers s1 a = s2 := by
    rw [consume_unicode_digit helpers s1 a good (by dsimp [s1]; omega) rfl ha (by dsimp [s1]; omega) (by dsimp [s1]; omega)]
    simp [s1, s2, counted, Nat.add_assoc]
  have e3 : consume helpers s2 b = s3 := by
    rw [consume_unicode_digit helpers s2 b good (by dsimp [s2]; omega) rfl hb (by dsimp [s2]; omega) (by dsimp [s2]; omega)]
    simp [s1, s2, s3, counted, Nat.add_assoc]
  have e4 : consume helpers s3 c = s4 := by
    rw [consume_unicode_digit helpers s3 c good (by dsimp [s3]; omega) rfl hc (by dsimp [s3]; omega) (by dsimp [s3]; omega)]
    simp [s1, s3, s4, counted, Nat.add_assoc]
  simp only [List.foldl_cons, List.foldl_nil, e0, e1, e2, e3, e4]
  rw [consume_unicode_digit helpers s4 d good (by dsimp [s4]; omega) rfl hd (by dsimp [s4]; omega) (by dsimp [s4]; omega)]
  simp [s1, s4, counted, unicodeCode, Nat.add_assoc]

/-- Interpreted Decoded emits the entire canonical fragment into every live
selected-theory matcher, for every ASCII input character. -/
theorem model_decoded_matches (tables : Native.Tables) (state : Core.State) (code : Nat)
    (ascii : code < 127) (active : state.matcher.inTheory = true) (kind : Native.Theory) :
    ((Core.modelHelpers tables).decoded state code).matcher.cells kind =
      (DecodedNative.normalizedCode code).foldl
        (matchByte (tables.byte kind) (tables.length kind)) (state.matcher.cells kind) := by
  simp only [Core.modelHelpers, DecodedNative.output, show ¬127 ≤ code by omega, ↓reduceIte]
  exact SourceBridge.interpreted_fold tables (Core.matcher tables) ⟨fun _ _ => rfl⟩ _ state.matcher active kind

/-- A source byte and the canonical output fragment denote the same character;
this joins the scanner step proof to the independent JSON fragment decoder. -/
theorem plain_matches_meaning (tables : Native.Tables) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .string) (quote : item ≠ 34) (escape : item ≠ 92)
    (printable : 32 ≤ item) (ascii : item < 127) (active : state.matcher.inTheory = true)
    (kind : Native.Theory) :
    (consume (Core.modelHelpers tables) state item).matcher.cells kind =
      (DecodedNative.normalizedCode item).foldl
        (matchByte (tables.byte kind) (tables.length kind)) (state.matcher.cells kind) ∧
    decodeFragment (DecodedNative.normalizedCode item) = some item := by
  constructor
  · rw [consume_plain _ state item good room mode quote escape printable]
    exact model_decoded_matches tables (counted state) item ascii active kind
  · exact fragment_roundtrip ⟨item, ascii⟩

end Silver.ImageModel.ScannerNative
