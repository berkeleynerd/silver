module

public import Silver.ImageModelHexSource

@[expose] public section
namespace Silver.ImageModel

/-- Standard JSON character meaning, restricted to the canonical ASCII fragments
emitted by Decoded. Input escaping itself is handled by Consume. -/
def decodeFragment : List Nat → Option Nat
  | [92, 34] => some 34 | [92, 92] => some 92
  | [92, 98] => some 8 | [92, 116] => some 9 | [92, 110] => some 10
  | [92, 102] => some 12 | [92, 114] => some 13
  | [92, 117, 48, 48, high, low] =>
      if Core.hexadecimal high < 16 ∧ Core.hexadecimal low < 16
      then some (16 * Core.hexadecimal high + Core.hexadecimal low) else none
  | [code] => if 32 ≤ code ∧ code < 127 ∧ code ≠ 34 ∧ code ≠ 92 then some code else none
  | _ => none

/-- Finite character cases establish a universal theorem for every ASCII input,
not a sample of programs or selected native JSON files. -/
theorem fragment_roundtrip : ∀ code : Fin 127,
    decodeFragment (DecodedNative.normalizedCode code.val) = some code.val := by decide +kernel

theorem normalized_code_injective (left right : Nat) (a : left < 127) (b : right < 127)
    (equal : DecodedNative.normalizedCode left = DecodedNative.normalizedCode right) : left = right := by
  have l := fragment_roundtrip ⟨left, a⟩
  have r := fragment_roundtrip ⟨right, b⟩
  rw [equal, r] at l
  exact Option.some.inj l.symm

end Silver.ImageModel
