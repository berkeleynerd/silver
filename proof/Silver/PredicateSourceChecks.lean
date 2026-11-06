module

public import Silver.ComposeSourceBridge
public import Silver.PredicateSourceCandidate
public import Silver.PredicateNativePrecedence
public import Silver.PredicateStructuralGuards

@[expose] public section

/-! Authoritative source extraction reuses the complete reviewed-shape proofs.
The inherited helper source checks and the current predicate profile must both
hold. Equations interpreting domain-bounded calls remain explicit premises of
the semantic source bridge, justified there by verified native call legality. -/
namespace Silver.Predicate.SourceChecks

structure CheckedSource : Prop where
  helpers : Compose.SourceBridge.CheckedSource
  precedence : Native.WellFormedTrees
  scalarBodyPrecedence : ScalarBodyNative.WellFormedTrees
  scalarHelperPrecedence : Native.ScalarHelpers.WellFormedTrees
  adapterPrecedence : Adapter.WellFormedTrees
  scopes : Native.WellScopedTrees
  profile : Checked Source.outputSpecTokens Source.outputBodyTokens

theorem actualSource : CheckedSource where
  helpers := Compose.SourceBridge.checked_source
  precedence := Native.checked_precedence
  scalarBodyPrecedence := ScalarBodyNative.checked_precedence
  scalarHelperPrecedence := Native.ScalarHelpers.checked_precedence
  adapterPrecedence := Adapter.checked_precedence
  scopes := Native.checked_scopes
  profile := by
    have spec : Source.outputSpecTokens = SourceShape.specTokens :=
      Output.SourceBridge.actual_complete_shape.1
    have body : Source.outputBodyTokens = SourceShape.bodyTokens :=
      Output.SourceBridge.actual_complete_shape.2.1
    rw [spec, body]
    exact candidate_checked

end Silver.Predicate.SourceChecks
