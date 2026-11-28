module

public import Silver.ApplicationPackageActualProjection
public import Silver.ApplicationPackageCallLexicalImports
public import Silver.PredicateProcedureCallLibraries
public import Silver.PredicateProcedureCallReadings

@[expose] public section

namespace Silver.ApplicationPackageCalls.PayloadImports
open Compose Compose.Expressions Predicate

set_option backward.dsimp.instances true

/-- Original writable-actual source definitions and inherited links. The
complete procedure helper meaning is derived rather than stored here. -/
structure Library where
  actual : ApplicationPackageActual.Library
  effects : ApplicationPackageEffects.Imports
  procedures : ProcedureCallNative.Calls
  links : ProcedureCallNative.ImportsLinks procedures actual.composed actual.predicate
  definitions : ProcedureCallNative.DefinitionEquations procedures

namespace Library

theorem target (library : Library) (text : Source) (native : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : ProcedureBindings.Formal)
    (legal : ProcedureCallNative.ActualDomain text native position facts formal) :
    library.procedures .target text native position facts formal =
      procedureTargetActual text native.model position facts formal := by
  classical
  have meaning := ProcedureCallNative.imports_meaning library.actual.inherited
    library.actual.predicate_meaning library.actual.predicateDefinitions
    library.actual.predicateContracts library.links
  have interpreted := congrArg (fun fn => fn text native position facts formal)
    (ProcedureCallNative.normalized_target meaning library.definitions)
  simpa only [ProcedureCallNative.totalizeCalls, ProcedureCallNative.modelCalls,
    legal, ↓reduceIte] using interpreted

def nativeTarget (library : Library) (text : Source) (native : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : ProcedureBindings.Formal) : ProcedureActualResult :=
  library.procedures .target text native position facts formal

noncomputable def projectedTarget (library : Library) (text : Source) (context : ParseContext)
    (position : Nat) (facts : ActiveFlow) (formal : ProcedureBindings.Formal) : ProcedureActualResult := by
  classical
  exact if legal : ApplicationPackageActual.ContextDomain text context then
    library.nativeTarget text (ApplicationPackageActual.representative text context legal)
      position facts formal else {}

/-- The erased context fields are retained by an original native witness;
all such legal witnesses yield the same writable-actual result. -/
theorem projected_target (library : Library) (text : Source) (native : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : ProcedureBindings.Formal)
    (legal : ProcedureCallNative.ActualDomain text native position facts formal) :
    library.projectedTarget text native.model position facts formal =
      procedureTargetActual text native.model position facts formal := by
  classical
  have domain : ApplicationPackageActual.ContextDomain text native.model :=
    ⟨native, rfl, legal.1.1.2.1⟩
  rw [projectedTarget, dite_eq_left domain]
  have same := ApplicationPackageActual.representative_model text native.model domain
  have chosen : ProcedureCallNative.ActualDomain text
      (ApplicationPackageActual.representative text native.model domain) position facts formal :=
    ⟨⟨⟨legal.1.1.1, ApplicationPackageActual.representative_valid text native.model domain,
      legal.1.1.2.2⟩, ApplicationPackageActual.flow_transport same.symm legal.1.2⟩, legal.2⟩
  exact (library.target text _ position facts formal chosen).trans (by rw [same])

theorem projected_native (library : Library) (text : Source) (native : Predicate.Native.Context)
    (position : Nat) (facts : ActiveFlow) (formal : ProcedureBindings.Formal)
    (legal : ProcedureCallNative.ActualDomain text native position facts formal) :
    library.projectedTarget text native.model position facts formal =
      library.procedures .target text native position facts formal :=
  (library.projected_target text native position facts formal legal).trans
    (library.target text native position facts formal legal).symm

noncomputable def calls (library : Library) (other : Calls) : Calls :=
  {LexicalImports.calls library.effects other with
    actualAfter := library.actual.projected
    targetActual := library.projectedTarget
    stateTarget := ApplicationPackageEffects.stateTarget (ApplicationPackageEffects.importedCalls library.effects)
    stateReads := ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls library.effects)
    actualNameFree := library.effects.nameScan
    visibleState := ApplicationPackageEffects.visibleState (ApplicationPackageEffects.importedCalls library.effects)}

/-- Both payload branches preserve the exact incoming flow and original formal.
Only native field subtypes and the imported helpers' full preconditions occur
here; no accepted-call, valid metadata or semantic-check premise is needed. -/
theorem payload (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationPackages.ApplicationScan) (flow : Predicate.Native.ValidFlow native input.scan.facts)
    (parameter : PackageBindings.Formal) (typed : parameter.Typed)
    (info : PackageBindings.Metadata) (cursor : Nat) (bounded : ValidCursor text cursor)
    (original : ApplicationPackages.PackageActual) :
    actualPayload (library.calls other) text native.model input parameter info cursor original =
      actualPayload modelCalls text native.model input parameter info cursor original := by
  have inputType : FunctionBindings.Native.FormalType (inputFormal parameter) :=
    ⟨typed.1.1, typed.1.2, typed.2.2.2.2.1, Nat.zero_le _⟩
  have outputType : ProcedureBindings.Native.FormalType (outputFormal parameter) :=
    ⟨typed.1.1, typed.1.2, typed.2.2.2.2.1, Nat.zero_le _⟩
  unfold actualPayload
  split
  · change (library.actual.projected text native.model cursor input.scan.facts
      (inputFormal parameter), original) = _
    rw [library.actual.projected_meaning text native cursor input.scan.facts
      (inputFormal parameter) ⟨⟨⟨valid, contextValid, bounded⟩, flow⟩, inputType⟩]
    rfl
  · change (let target := library.projectedTarget text native.model cursor input.scan.facts (outputFormal parameter);
      (target.after, {original with target := target, writtenState :=
        (ApplicationPackageEffects.stateTarget (ApplicationPackageEffects.importedCalls library.effects)
          text native.model info cursor)})) = _
    rw [library.projected_target text native cursor input.scan.facts
      (outputFormal parameter) ⟨⟨⟨valid, contextValid, bounded⟩, flow⟩, outputType⟩,
      ApplicationPackageEffects.imported_target library.effects text valid native.model
        (ApplicationPackageEffects.LookupDomain.of_native contextValid) info cursor bounded]
    rfl

theorem payload_bound (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationPackages.ApplicationScan) (flow : Predicate.Native.ValidFlow native input.scan.facts)
    (parameter : PackageBindings.Formal) (typed : parameter.Typed)
    (info : PackageBindings.Metadata) (cursor : Nat) (bounded : ValidCursor text cursor)
    (original : ApplicationPackages.PackageActual) :
    (actualPayload (library.calls other) text native.model input parameter info cursor original).1 ≤
      text.length + 1 := by
  rw [library.payload other text valid native contextValid input flow parameter typed info cursor bounded original]
  unfold actualPayload
  split
  · exact ApplicationPackageActual.actual_model_bound text native cursor input.scan.facts
      (inputFormal parameter) valid contextValid bounded
  · exact procedureTargetActual_after_bound text native.model cursor input.scan.facts (outputFormal parameter)

end Library
end Silver.ApplicationPackageCalls.PayloadImports
