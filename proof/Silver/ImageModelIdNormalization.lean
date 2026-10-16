module

public import Silver.ImageModelIdRun

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def idStart (tables : Native.Tables) (state : Core.State) (digit : Nat) : Core.State :=
  {(Core.modelHelpers tables).matchByte (beginNumber (counted state) digit) 48 with previousArrayStart := false}

/-- At the first decimal digit after a W-node tag, the checked source emits one
zero byte and begins recording the original node ID separately. -/
theorem consume_id_start (tables : Native.Tables) (state : Core.State) (digit : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .between) (pending : state.nodeIdPending = true)
    (active : state.matcher.inTheory = true) (ascii : 48 ≤ digit ∧ digit ≤ 57) :
    consume (Core.modelHelpers tables) state digit = idStart tables state digit := by
  rw [consume_between _ state digit good room mode,
    structural_begin_number _ (counted state) digit (by exact active) ascii]
  simp only [counted, pending, ↓reduceIte, idStart]

/-- Every bounded complete decimal W-node ID has exactly the same one-byte
normalized representation, while retaining its original numeric value and byte
length for collision checks and insertion offsets. -/
theorem consume_node_id (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = true)
    (active : state.matcher.inTheory = true) (word : decimalWord (first :: rest))
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807)
    (bounded : decimalFold 0 (first :: rest) ≤ originalIdMaximum) :
    (first :: rest).foldl (consume (Core.modelHelpers tables)) state =
      {idStart tables state first with
        bytes := state.bytes + (first :: rest).length
        numberValue := decimalFold 0 (first :: rest)
        numberDigits := true} := by
  have ascii := word first (by simp)
  have tailWord : decimalWord rest := fun byte member => word byte (by simp [member])
  have initialValue : (idStart tables state first).numberValue = first - 48 := by
    simp only [idStart, Core.modelHelpers, beginNumber, counted, pending, ↓reduceIte]
  have initialId : (idStart tables state first).numberIsId = true := pending
  have initialGood : (idStart tables state first).failed = false := good
  have initialRoom : (idStart tables state first).bytes + rest.length ≤ 9223372036854775807 := by
    change state.bytes + 1 + rest.length ≤ _
    simpa only [List.length_cons, Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using room
  have initialBound : decimalFold (idStart tables state first).numberValue rest ≤ originalIdMaximum := by
    rw [initialValue]
    simpa only [decimalFold, List.foldl_cons, Nat.zero_mul, Nat.zero_add] using bounded
  simp only [List.foldl_cons]
  rw [consume_id_start tables state first good (by simp only [List.length_cons] at room; omega) mode pending active ascii]
  rw [consume_id_run _ (idStart tables state first) rest tailWord initialGood rfl initialId rfl initialRoom initialBound]
  simp only [decimalFold, List.foldl_cons, Nat.zero_mul, Nat.zero_add,
    List.length_cons, idStart, counted, Core.modelHelpers, beginNumber, pending, ↓reduceIte]
  congr 1 <;> omega

/-- The matching trace observes the canonical zero, independently of decimal
spelling length, the original numeric ID, and previously observed node IDs. -/
theorem node_id_matcher (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = true)
    (active : state.matcher.inTheory = true) (word : decimalWord (first :: rest))
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807)
    (bounded : decimalFold 0 (first :: rest) ≤ originalIdMaximum) :
    ((first :: rest).foldl (consume (Core.modelHelpers tables)) state).matcher =
      Core.matcher tables state.matcher 48 := by
  rw [consume_node_id tables state first rest good mode pending active word room bounded]
  rfl

end Silver.ImageModel.ScannerNative
