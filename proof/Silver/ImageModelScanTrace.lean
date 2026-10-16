module

public import Silver.ImageModelScannerSource

@[expose] public section
namespace Silver.ImageModel.SourceBridge

/-- Observations of actual Consume calls, in read order. Each constructor is one
successful byte read followed by exactly one native Consume call. The domain
premises are the native State/Character type bounds, not scanner correctness. -/
inductive NativeScan (runConsume : Core.State → Nat → Core.State) : Core.State → List Nat → Core.State → Prop
  | nil (state : Core.State) : NativeScan runConsume state [] state
  | cons (state : Core.State) (byte : Nat) (rest : List Nat) (result : Core.State)
      (typed : state.Typed) (character : byte ≤ 255)
      (tail : NativeScan runConsume (runConsume state byte) rest result) :
      NativeScan runConsume state (byte :: rest) result

/-- The operational read/Consume trace agrees with the mathematical fold of the
actual scanner body. In particular, comparing two final Plans cannot replace
this sequence-to-state relation. -/
theorem native_scan_fold (helpers : Core.Helpers) (runStructural runConsume : Core.State → Nat → Core.State)
    (source : InterpretedScanner helpers runStructural runConsume) (initial result : Core.State) (input : List Nat)
    (trace : NativeScan runConsume initial input result) :
    result = input.foldl (ScannerNative.consume helpers) initial := by
  induction trace with
  | nil state => rfl
  | cons state byte rest result typed character tail ih =>
      simp only [List.foldl_cons]
      rw [← actual_consume helpers runStructural runConsume source state byte typed character]
      exact ih

/-- The I/O wrapper can append a successful read to its accumulated observation
without assuming any property about the JSON represented by those bytes. -/
theorem NativeScan.append (runConsume : Core.State → Nat → Core.State)
    (initial middle result : Core.State) (left right : List Nat)
    (first : NativeScan runConsume initial left middle)
    (second : NativeScan runConsume middle right result) :
    NativeScan runConsume initial (left ++ right) result := by
  induction first with
  | nil state => exact second
  | cons state byte rest middle typed character tail ih =>
      exact .cons state byte (rest ++ right) result typed character (ih second)

theorem NativeScan.deterministic (runConsume : Core.State → Nat → Core.State)
    (initial first second : Core.State) (input : List Nat)
    (left : NativeScan runConsume initial input first)
    (right : NativeScan runConsume initial input second) : first = second := by
  induction left with
  | nil state => cases right; rfl
  | cons state byte rest result typed character tail ih =>
      cases right with
      | cons _ _ _ _ _ _ other => exact ih other

end Silver.ImageModel.SourceBridge
