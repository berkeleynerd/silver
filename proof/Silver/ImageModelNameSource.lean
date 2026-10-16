module

public import Silver.ImageModelDecodedSource
public import Silver.ImageModelNameNative

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.ImageModel.SourceBridge

theorem named_expression : Source.expressionBody "named" Source.imageModelBodyTokens =
    some NameNative.body.render := by
  simp only [NameNative.body, NameNative.Expression.render, NameNative.Test.render]
  decide +kernel

structure InterpretedName (run : DecodedNative.RawName → List Nat → Bool) : Prop where
  expression : ∀ state name, run state name = NameNative.body.eval state name

theorem actual_name_exact (run : DecodedNative.RawName → List Nat → Bool) (source : InterpretedName run)
    (input expected : List Nat) (buffer : Nat → Nat)
    (bounded : expected.length ≤ 21) (ascii : ∀ code ∈ expected, code < 127) :
    run (input.foldl DecodedNative.remember ⟨0, buffer⟩) expected = true ↔ input = expected := by
  rw [source.expression]
  exact NameNative.remembers_exact input expected buffer bounded ascii

end Silver.ImageModel.SourceBridge
