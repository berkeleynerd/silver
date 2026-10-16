module

public import Silver.ImageModelStructuralNesting

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def decimalFold (initial : Nat) (digits : List Nat) : Nat :=
  digits.foldl (fun value digit => value * 10 + (digit - 48)) initial

def decimalWord (digits : List Nat) : Prop := ∀ digit ∈ digits, 48 ≤ digit ∧ digit ≤ 57

theorem decimalFold_monotone (initial : Nat) (digits : List Nat) : initial ≤ decimalFold initial digits := by
  induction digits generalizing initial with
  | nil => exact Nat.le_refl _
  | cons digit digits ih =>
      have tail := ih (initial * 10 + (digit - 48))
      change initial ≤ decimalFold (initial * 10 + (digit - 48)) digits
      omega

/-- Every prefix of a bounded decimal ID satisfies the actual guarded update;
there is no assumption that a selected native run happens to prove. -/
theorem decimal_prefix_guard (initial digit : Nat) (digits : List Nat)
    (bounded : decimalFold initial (digit :: digits) ≤ originalIdMaximum) :
    initial ≤ (originalIdMaximum - (digit - 48)) / 10 := by
  have monotone := decimalFold_monotone (initial * 10 + (digit - 48)) digits
  change decimalFold (initial * 10 + (digit - 48)) digits ≤ originalIdMaximum at bounded
  omega

/-- A complete suffix of a W-node ID leaves the matcher unchanged, records its
exact numeric value, and counts each original byte. -/
theorem consume_id_run (helpers : Core.Helpers) (state : Core.State) (digits : List Nat)
    (word : decimalWord digits) (good : state.failed = false)
    (mode : state.mode = .number) (nodeId : state.numberIsId = true)
    (started : state.numberDigits = true)
    (room : state.bytes + digits.length ≤ 9223372036854775807)
    (bounded : decimalFold state.numberValue digits ≤ originalIdMaximum) :
    digits.foldl (consume helpers) state = {state with
      bytes := state.bytes + digits.length
      numberValue := decimalFold state.numberValue digits
      numberDigits := true} := by
  induction digits generalizing state with
  | nil =>
      cases state
      simp_all [decimalFold]
  | cons digit digits ih =>
      have ascii := word digit (by simp)
      have tailWord : decimalWord digits := fun byte member => word byte (by simp [member])
      have guard := decimal_prefix_guard state.numberValue digit digits bounded
      have first := consume_id_digit helpers state digit good (by simp only [List.length_cons] at room; omega) mode nodeId ascii guard
      let next := {counted state with
        numberValue := state.numberValue * 10 + (digit - 48)
        numberDigits := true}
      have restRoom : next.bytes + digits.length ≤ 9223372036854775807 := by
        simpa only [next, counted, List.length_cons, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using room
      have restBound : decimalFold next.numberValue digits ≤ originalIdMaximum := bounded
      have tail := ih next tailWord good mode nodeId rfl restRoom restBound
      simp only [List.foldl_cons, first]
      rw [tail]
      simp only [next, counted, decimalFold, List.foldl_cons, List.length_cons]
      congr 1 <;> omega

end Silver.ImageModel.ScannerNative
