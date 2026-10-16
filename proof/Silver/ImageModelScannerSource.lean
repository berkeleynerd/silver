module

import all Init.Data.Repr
import all Init.Data.Char.Basic
public import Silver.ImageModelConsumeNative

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 20000000
namespace Silver.ImageModel.SourceBridge
open ScannerNative

theorem structural_block : block "procedure" "structural" Source.imageModelBodyTokens =
    some structuralRender := by
  simp only [structuralRender, structuralCommands, structuralCases, structuralOpenObject,
    structuralCloseObject, structuralOpenArray, structuralCloseArray, structuralOffset,
    structuralColon, structuralComma, structuralQuote, structuralNumber, structuralLiteral,
    fail, matchItem, decimal, number, flag, equal, increase, decrease,
    Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse,
    Action.render, Test.render, Number.render, NumberField.render, NumberField.name,
    Flag.name, CharacterValue.render, choicesRender, modeName, phaseName,
    Comparison.render]
  decide +kernel

theorem consume_block : block "procedure" "consume" Source.imageModelBodyTokens =
    some consumeRender := by
  simp only [consumeRender, consumeCommands, consumeCases, consumeString, consumeEscape,
    consumeEscapes, consumeUnicode, consumeNumber, consumeNumberClose, consumeIdDigit,
    delimiters, fail, matchItem, decimal, number, flag, equal, increase, decrease,
    Command.list, List.foldr_cons, List.foldr_nil, Command.render, Command.renderElse,
    Action.render, Test.render, Number.render, NumberField.render, NumberField.name,
    Flag.name, CharacterValue.render, choicesRender, modeName,
    Comparison.render]
  decide +kernel

/-- A native function is meaningful on its represented type domain. This
mathematical extension supplies the checked body elsewhere; no equation for an
out-of-domain native call is assumed. -/
noncomputable def totalizedStructural (helpers : Core.Helpers)
    (run : Core.State → Nat → Core.State) (state : Core.State) (item : Nat) : Core.State := by
  classical
  exact if state.Typed ∧ item ≤ 255 then run state item else ScannerNative.structural helpers state item

theorem totalized_structural_native (helpers : Core.Helpers) (run : Core.State → Nat → Core.State)
    (state : Core.State) (item : Nat) (typed : state.Typed) (byte : item ≤ 255) :
    totalizedStructural helpers run state item = run state item := by
  simp only [totalizedStructural, typed, byte, and_self, ↓reduceIte]

/-- Native calls are interpreted on the declared State and Character domains.
The statements here are primitive source-body interpretation obligations, not
assumptions of JSON correspondence or scanner acceptance. -/
structure InterpretedScanner (helpers : Core.Helpers)
    (runStructural runConsume : Core.State → Nat → Core.State) : Prop where
  structural : ∀ state item, state.Typed → item ≤ 255 → runStructural state item =
    (structuralCommands.eval helpers (fun state _ => state) ⟨state, item, 0⟩).frame.state
  consume : ∀ state item, state.Typed → item ≤ 255 → runConsume state item =
    (consumeCommands.eval helpers (totalizedStructural helpers runStructural) ⟨state, item, 0⟩).frame.state

theorem totalized_structural_model (helpers : Core.Helpers) (runStructural runConsume : Core.State → Nat → Core.State)
    (source : InterpretedScanner helpers runStructural runConsume) :
    totalizedStructural helpers runStructural = ScannerNative.structural helpers := by
  funext state item
  classical
  by_cases native : state.Typed ∧ item ≤ 255
  · rw [totalized_structural_native helpers runStructural state item native.1 native.2]
    exact source.structural state item native.1 native.2
  · simp only [totalizedStructural, native, ↓reduceIte]

theorem actual_structural (helpers : Core.Helpers) (runStructural runConsume : Core.State → Nat → Core.State)
    (source : InterpretedScanner helpers runStructural runConsume) (state : Core.State) (item : Nat)
    (typed : state.Typed) (byte : item ≤ 255) : runStructural state item = ScannerNative.structural helpers state item :=
  source.structural state item typed byte

theorem actual_consume (helpers : Core.Helpers) (runStructural runConsume : Core.State → Nat → Core.State)
    (source : InterpretedScanner helpers runStructural runConsume) (state : Core.State) (item : Nat)
    (typed : state.Typed) (byte : item ≤ 255) : runConsume state item = ScannerNative.consume helpers state item := by
  rw [source.consume state item typed byte, totalized_structural_model helpers runStructural runConsume source]
  rfl

end Silver.ImageModel.SourceBridge
