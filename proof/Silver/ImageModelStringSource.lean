module

public import Silver.ImageModelStringNative

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.ImageModel.SourceBridge

theorem end_string_block : block "procedure" "end_string" Source.imageModelBodyTokens =
    some StringNative.render := by
  simp only [StringNative.render, StringNative.commands, StringNative.classifyCommands,
    StringNative.selectCommands, StringNative.Command.render, StringNative.Command.renderElse,
    StringNative.Command.list, List.foldr_cons, List.foldr_nil, StringNative.Action.render,
    StringNative.Test.render, StringNative.Name.render, StringNative.theoryName, StringNative.Name.text]
  decide +kernel

structure InterpretedString (matchCall : DecodedNative.MatchCall) (namedCall : StringNative.NameCall)
    (run : StringNative.Frame → StringNative.Frame) : Prop where
  commands : ∀ frame, run frame = StringNative.commands.eval matchCall namedCall frame

theorem interpreted_endString (matchCall : DecodedNative.MatchCall) (namedCall : StringNative.NameCall)
    (run : StringNative.Frame → StringNative.Frame) (source : InterpretedString matchCall namedCall run)
    (frame : StringNative.Frame) : run frame = StringNative.model matchCall namedCall frame := by
  rw [source.commands, StringNative.eval_model]

theorem interpreted_static_name (namedCall : StringNative.NameCall) (source : InterpretedName namedCall)
    (input : List Nat) (buffer : Nat → Nat) (name : StringNative.Name) :
    namedCall (input.foldl DecodedNative.remember ⟨0, buffer⟩) name.bytes = decide (input = name.bytes) := by
  apply Bool.eq_iff_iff.mpr
  rw [actual_name_exact namedCall source input name.bytes buffer (StringNative.names_legal name).1
    (StringNative.names_legal name).2, decide_eq_true_eq]

def recognizedTheory (input : List Nat) : Option Native.Theory :=
  if input = StringNative.Name.integer.bytes then some .integer
  else if input = StringNative.Name.string.bytes then some .string
  else if input = StringNative.Name.image.bytes then some .image
  else none

/-- At the native theory-name field, the source helper identifies the exact
complete decoded name even after a table candidate already ceased to match. -/
theorem actual_theory_name (matchCall : DecodedNative.MatchCall) (namedCall : StringNative.NameCall)
    (nameSource : InterpretedName namedCall)
    (run : StringNative.Frame → StringNative.Frame) (source : InterpretedString matchCall namedCall run)
    (frame : StringNative.Frame) (input : List Nat) (buffer : Nat → Nat)
    (stored : frame.name = input.foldl DecodedNative.remember ⟨0, buffer⟩)
    (notKey : frame.isKey = false) (notTag : frame.isTheoryTag = false)
    (nameField : frame.isName = true) (unselected : frame.theory = none) :
    (run frame).theory = recognizedTheory input := by
  rw [interpreted_endString matchCall namedCall run source]
  simp only [StringNative.model, notKey, notTag, nameField, Bool.not_false, Bool.true_and, ↓reduceIte]
  simp only [StringNative.classification, stored, unselected,
    interpreted_static_name namedCall nameSource, decide_eq_true_eq, recognizedTheory]

end Silver.ImageModel.SourceBridge
