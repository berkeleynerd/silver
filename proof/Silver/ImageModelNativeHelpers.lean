module

public import Silver.ImageModelScanTrace

@[expose] public section
namespace Silver.ImageModel.SourceBridge

/-- The already checked helper bodies, interpreted only where native State,
Character, and Decoded's explicit precondition permit calls. Imported helper
calls use their mathematical extensions; those extensions agree on every legal
native call by the theorems below. No scanner acceptance property is a premise. -/
structure NativeHelperBodies (tables : Native.Tables) (run : Core.Helpers) : Prop where
  matchByte : ∀ state byte, state.Typed → byte ≤ 255 → run.matchByte state byte =
    {state with matcher := Native.matchCommands.eval tables byte state.matcher .integer}
  decoded : ∀ state code, state.Typed → code ≤ 65535 → run.decoded state code =
    let result := DecodedNative.commands.eval (Core.matcher tables) ⟨state.name, state.matcher, code⟩
    {state with name := result.name, matcher := result.matcher}
  endString : ∀ state, state.Typed → run.endString state =
    state.setString (StringNative.commands.eval (Core.matcher tables) Core.nameCall state.stringView)
  endTheory : ∀ state, state.Typed → run.endTheory state =
    state.setTheory (TheoryNative.commands.eval tables (Core.matcher tables) state.theoryView)
  hex : ∀ byte, byte ≤ 255 → run.hex byte = HexNative.expression.eval byte

noncomputable def totalizedHelpers (tables : Native.Tables) (run : Core.Helpers) : Core.Helpers := by
  classical
  exact {
    matchByte := fun state byte => if state.Typed ∧ byte ≤ 255 then run.matchByte state byte else (Core.modelHelpers tables).matchByte state byte
    decoded := fun state code => if state.Typed ∧ code ≤ 65535 then run.decoded state code else (Core.modelHelpers tables).decoded state code
    endString := fun state => if state.Typed then run.endString state else (Core.modelHelpers tables).endString state
    endTheory := fun state => if state.Typed then run.endTheory state else (Core.modelHelpers tables).endTheory state
    hex := fun byte => if byte ≤ 255 then run.hex byte else Core.hexadecimal byte }

/-- The extension is observationally identical to each actual native helper on
its legal domain. Arbitrary calls outside those domains are never required. -/
theorem totalized_helpers_native (tables : Native.Tables) (run : Core.Helpers)
    (state : Core.State) (byte code : Nat) (typed : state.Typed)
    (character : byte ≤ 255) (unicode : code ≤ 65535) :
    (totalizedHelpers tables run).matchByte state byte = run.matchByte state byte ∧
    (totalizedHelpers tables run).decoded state code = run.decoded state code ∧
    (totalizedHelpers tables run).endString state = run.endString state ∧
    (totalizedHelpers tables run).endTheory state = run.endTheory state ∧
    (totalizedHelpers tables run).hex byte = run.hex byte := by
  simp only [totalizedHelpers, typed, character, unicode, and_self, ↓reduceIte]

/-- Source helper interpretations determine the complete mathematical helpers,
without extending claims about actual executable calls beyond native types. -/
theorem totalized_helpers_model (tables : Native.Tables) (run : Core.Helpers)
    (source : NativeHelperBodies tables run) : totalizedHelpers tables run = Core.modelHelpers tables := by
  apply Core.interpreted_helpers tables
  have model := Core.helper_definitions_model tables
  constructor
  · intro state byte
    simp only [totalizedHelpers]
    split
    · rename_i legal
      exact source.matchByte state byte legal.1 legal.2
    · exact model.matchByte state byte
  · intro state code
    simp only [totalizedHelpers]
    split
    · rename_i legal
      exact source.decoded state code legal.1 legal.2
    · exact model.decoded state code
  · intro state
    simp only [totalizedHelpers]
    split
    · rename_i legal
      exact source.endString state legal
    · exact model.endString state
  · intro state
    simp only [totalizedHelpers]
    split
    · rename_i legal
      exact source.endTheory state legal
    · exact model.endTheory state
  · funext byte
    simp only [totalizedHelpers]
    split
    · rename_i legal
      exact (source.hex byte legal).trans (HexNative.eval_model byte)
    · rfl

/-- All actual bytes and state transitions from the I/O trace use the checked
scanner and helper body models. JSON/schema interpretation remains a separate
invariant of this concrete fold. -/
theorem native_scan_model (tables : Native.Tables) (nativeHelpers : Core.Helpers)
    (helperSource : NativeHelperBodies tables nativeHelpers)
    (runStructural runConsume : Core.State → Nat → Core.State)
    (scannerSource : InterpretedScanner (totalizedHelpers tables nativeHelpers) runStructural runConsume)
    (initial result : Core.State) (input : List Nat)
    (trace : NativeScan runConsume initial input result) :
    result = input.foldl (ScannerNative.consume (Core.modelHelpers tables)) initial := by
  have fold := native_scan_fold (totalizedHelpers tables nativeHelpers) runStructural runConsume scannerSource initial result input trace
  rw [totalized_helpers_model tables nativeHelpers helperSource] at fold
  exact fold

end Silver.ImageModel.SourceBridge
