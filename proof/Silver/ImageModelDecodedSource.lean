module

public import Silver.ImageModelMatcherSource
public import Silver.ImageModelDecodedNative

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.ImageModel.SourceBridge

/-- Each native Decoded command is covered, including bounded name storage,
non-ASCII match rejection, short JSON escapes and four-digit Unicode escapes. -/
theorem decoded_block : block "procedure" "decoded" Source.imageModelBodyTokens =
    some DecodedNative.render := by
  simp only [DecodedNative.render, DecodedNative.commands, DecodedNative.rememberCommands,
    DecodedNative.byteCommands, DecodedNative.Command.render, DecodedNative.Command.renderElse,
    DecodedNative.Command.list, List.foldr_cons, List.foldr_nil, DecodedNative.emitChar, DecodedNative.emit,
    DecodedNative.Action.render, DecodedNative.Test.render, DecodedNative.ByteExpression.render]
  decide +kernel

structure InterpretedDecoded (matchCall : DecodedNative.MatchCall)
    (run : DecodedNative.Frame → DecodedNative.Frame) : Prop where
  commands : ∀ frame, run frame = DecodedNative.commands.eval matchCall frame

theorem interpreted_decoded (matchCall : DecodedNative.MatchCall)
    (run : DecodedNative.Frame → DecodedNative.Frame) (source : InterpretedDecoded matchCall run)
    (frame : DecodedNative.Frame) :
    run frame = DecodedNative.output matchCall
      {frame with name := DecodedNative.remember frame.name frame.code} := by
  rw [source.commands, DecodedNative.decoded_eval]

theorem interpreted_fold (tables : Native.Tables) (run : DecodedNative.MatchCall)
    (source : InterpretedMatcher tables run) (input : List Nat) (state : Native.Matcher)
    (active : state.inTheory = true) (kind : Native.Theory) :
    (input.foldl run state).cells kind =
      input.foldl (matchByte (tables.byte kind) (tables.length kind)) (state.cells kind) := by
  induction input generalizing state with
  | nil => rfl
  | cons byte tail ih =>
      simp only [List.foldl_cons]
      have live : (run state byte).inTheory = true := by rw [interpreted_active tables run source, active]
      rw [ih (run state byte) live, interpreted_cell tables run source, active]
      rfl

/-- This transfers the entire emitted canonical character fragment into the
proved table matcher. It neither assumes a scanner/schema equality nor changes
any input byte. Schema interpretation remains a separate proof obligation. -/
theorem decoded_matches (tables : Native.Tables) (matchCall : DecodedNative.MatchCall)
    (matcherSource : InterpretedMatcher tables matchCall)
    (run : DecodedNative.Frame → DecodedNative.Frame) (source : InterpretedDecoded matchCall run)
    (frame : DecodedNative.Frame) (ascii : frame.code < 127) (active : frame.matcher.inTheory = true)
    (kind : Native.Theory) :
    ((run frame).matcher.cells kind) =
      (DecodedNative.normalizedCode frame.code).foldl
        (matchByte (tables.byte kind) (tables.length kind)) (frame.matcher.cells kind) := by
  rw [interpreted_decoded matchCall run source]
  simp only [DecodedNative.output, show ¬127 ≤ frame.code by omega, ↓reduceIte]
  exact interpreted_fold tables matchCall matcherSource _ frame.matcher active kind

theorem decoded_observes_name (matchCall : DecodedNative.MatchCall)
    (run : DecodedNative.Frame → DecodedNative.Frame) (source : InterpretedDecoded matchCall run)
    (frame : DecodedNative.Frame) :
    (run frame).name.observe = rememberName frame.name.observe frame.code := by
  rw [interpreted_decoded matchCall run source]
  unfold DecodedNative.output
  split <;> exact DecodedNative.remember_observe frame.name frame.code

end Silver.ImageModel.SourceBridge
