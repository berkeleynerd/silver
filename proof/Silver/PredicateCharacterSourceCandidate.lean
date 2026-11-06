module

public import Silver.PredicateNativeSourceChecks
public import Silver.PredicateSourceShape
public import Silver.PredicateXorNative
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Predicate.CharacterSourceCandidate
open Native NativeSourceChecks Silver.SourceBridge

/-- Exact changed predicate source bodies, isolated from the downstream adapter
so their native syntax can be checked with the corresponding semantic changes.
The final source bridge checks the reviewed tokens against authoritative bytes. -/
theorem character_body : Source.expressionBody "character_condition" SourceShape.bodyTokens = some characterBody.render := by
  simp only [characterBody, Expr.render]
  decide +kernel

theorem character_spec : functionHeader "character_condition" ";" SourceShape.bodyTokens = some character_condition_spec_header := by
  decide +kernel

theorem character_impl : functionHeader "character_condition" "is" SourceShape.bodyTokens = some character_condition_impl_header := by
  decide +kernel

theorem length_body : Source.expressionBody "length_at" SourceShape.bodyTokens = some lengthBody.render := by
  simp only [lengthBody, Expr.render]
  decide +kernel

theorem relation_body : Source.expressionBody "relation_model" SourceShape.bodyTokens = some relationBody.render := by
  simp only [relationBody, Expr.render, Expr.declared]
  decide +kernel

theorem xor_body : Source.expressionBody "xor_free_model" SourceShape.bodyTokens = some XorNative.body.render := by
  decide +kernel

end Silver.Predicate.CharacterSourceCandidate
