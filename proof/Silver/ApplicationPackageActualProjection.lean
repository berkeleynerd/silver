module

public import Silver.ApplicationPackageActualLibraries

@[expose] public section

namespace Silver.ApplicationPackageActual
open Compose Compose.Expressions Predicate

/-- A projected context keeps an original valid native witness. The witness
is not a semantic safety certificate or an extra parser precondition. -/
def ContextDomain (text : Source) (context : ParseContext) : Prop :=
  ∃ native : Predicate.Native.Context, native.model = context ∧ Predicate.Native.ValidContext text native

noncomputable def representative (text : Source) (context : ParseContext)
    (legal : ContextDomain text context) : Predicate.Native.Context := Classical.choose legal

theorem representative_model (text : Source) (context : ParseContext)
    (legal : ContextDomain text context) : (representative text context legal).model = context :=
  (Classical.choose_spec legal).1

theorem representative_valid (text : Source) (context : ParseContext)
    (legal : ContextDomain text context) : Predicate.Native.ValidContext text (representative text context legal) :=
  (Classical.choose_spec legal).2

theorem flow_transport {first second : Predicate.Native.Context} (same : first.model = second.model)
    {facts : ActiveFlow} (valid : Predicate.Native.ValidFlow first facts) :
    Predicate.Native.ValidFlow second facts := by
  change facts.path.Bounded ∧ ScalarMetadata.FlowReady first.model.scalarNames first.model.declarationCount facts at valid
  change facts.path.Bounded ∧ ScalarMetadata.FlowReady second.model.scalarNames second.model.declarationCount facts
  rwa [same] at valid

theorem scan_transport {text : Source} {first second : Predicate.Native.Context}
    (same : first.model = second.model) {scan : BodyScan}
    (valid : FunctionDeclarationNative.BodyScanInput text first scan) :
    FunctionDeclarationNative.BodyScanInput text second scan := by
  refine ⟨valid.1, ?_, flow_transport same valid.2.2⟩
  have names : first.names = second.names := congrArg ParseContext.names same
  exact ⟨names ▸ valid.2.1.1, valid.2.1.2⟩

namespace Library

/-- Formal projection of the native call onto ApplicationNative's context
type. The arbitrary zero outside the original context domain is never used by
the closure theorem. No runtime test or new implementation is introduced. -/
noncomputable def projected (library : Library) (text : Source) (context : ParseContext)
    (position : Nat) (facts : ActiveFlow) (formal : FunctionBindings.Formal) : Nat := by
  classical
  exact if legal : ContextDomain text context then
    library.calls.actual text (representative text context legal) position facts formal else 0

theorem projected_meaning (library : Library) (text : Source) (native : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : FunctionBindings.Formal)
    (legal : FunctionCallNative.ActualDomain text native position facts formal) :
    library.projected text native.model position facts formal =
      Predicate.actualAfter text native.model position facts formal := by
  classical
  have domain : ContextDomain text native.model := ⟨native, rfl, legal.1.1.2.1⟩
  rw [projected, dite_eq_left domain]
  have same := representative_model text native.model domain
  have chosen : FunctionCallNative.ActualDomain text (representative text native.model domain)
      position facts formal :=
    ⟨⟨⟨legal.1.1.1, representative_valid text native.model domain, legal.1.1.2.2⟩,
      flow_transport same.symm legal.1.2⟩, legal.2⟩
  rw [library.actual text _ position facts formal chosen, same]

/-- Every original valid native witness agrees with the projection. Thus the
choice made for the erased dynamic-name positions cannot affect execution. -/
theorem projected_native (library : Library) (text : Source) (native : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : FunctionBindings.Formal)
    (legal : FunctionCallNative.ActualDomain text native position facts formal) :
    library.projected text native.model position facts formal =
      library.calls.actual text native position facts formal :=
  (library.projected_meaning text native position facts formal legal).trans
    (library.actual text native position facts formal legal).symm

end Library

namespace ReturnLibrary

noncomputable def projected (library : ReturnLibrary) (text : Source) (context : ParseContext)
    (scan : BodyScan) (resultType : FunctionTypeResult) : Nat := by
  classical
  exact if legal : ContextDomain text context then
    library.calls .returnAfter text (representative text context legal) scan resultType else 0

theorem projected_meaning (library : ReturnLibrary) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (scan : BodyScan) (resultType : FunctionTypeResult)
    (legal : FunctionDeclarationNative.ReturnInput text native scan resultType) :
    library.projected text native.model scan resultType =
      functionReturnAfter text native.model scan resultType := by
  classical
  have domain : ContextDomain text native.model := ⟨native, rfl, legal.context⟩
  rw [projected, dite_eq_left domain]
  have same := representative_model text native.model domain
  have chosen : FunctionDeclarationNative.ReturnInput text (representative text native.model domain) scan resultType :=
    ⟨representative_valid text native.model domain, scan_transport same.symm legal.scan, legal.resultType⟩
  rw [library.return_after text valid _ scan resultType chosen, same]

theorem projected_native (library : ReturnLibrary) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (scan : BodyScan) (resultType : FunctionTypeResult)
    (legal : FunctionDeclarationNative.ReturnInput text native scan resultType) :
    library.projected text native.model scan resultType =
      library.calls .returnAfter text native scan resultType :=
  (library.projected_meaning text valid native scan resultType legal).trans
    (library.return_after text valid native scan resultType legal).symm

end ReturnLibrary
end Silver.ApplicationPackageActual
