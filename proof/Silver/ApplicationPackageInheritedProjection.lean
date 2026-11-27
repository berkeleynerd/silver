module

public import Silver.ApplicationPackageInheritedBodyImports
public import Silver.ApplicationPackageActualProjection

@[expose] public section

namespace Silver.ApplicationPackageBodies.Inherited
open Compose Compose.Expressions Predicate ApplicationPackageActual

set_option backward.dsimp.instances true

/-- Erased argument-name positions retain a valid original native witness.
This is a proof representation; no runtime check or new admission rule occurs. -/
noncomputable def project {α : Type} (text : Source) (context : ParseContext)
    (fallback : α) (call : Predicate.Native.Context → α) : α := by
  classical
  exact if legal : ContextDomain text context then call (representative text context legal) else fallback

theorem project_eq {α : Type} (text : Source) (native : Predicate.Native.Context)
    (valid : Predicate.Native.ValidContext text native) (fallback result : α)
    (call : Predicate.Native.Context → α)
    (meaning : ∀ chosen, chosen.model = native.model → Predicate.Native.ValidContext text chosen →
      call chosen = result) : project text native.model fallback call = result := by
  classical
  have domain : ContextDomain text native.model := ⟨native, rfl, valid⟩
  rw [project, dite_eq_left domain]
  exact meaning _ (representative_model text native.model domain) (representative_valid text native.model domain)

theorem scan_transport {text : Source} {first second : Predicate.Native.Context}
    (same : first.model = second.model) {scan : BodyScan}
    (valid : BodyNative.ValidScan text first scan) : BodyNative.ValidScan text second scan :=
  ⟨valid.1, same ▸ valid.2.1, ApplicationPackageActual.flow_transport same valid.2.2⟩

namespace Libraries

noncomputable def projectedBasic (library : Libraries) (text : Source) (context : ParseContext)
    (scan : BodyScan) (functions : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata) : BodyScan :=
  project text context (invalidBody scan) (fun native => library.calls.basic text native scan functions procedures)

noncomputable def projectedScalarTarget (library : Libraries) (text : Source) (context : ParseContext)
    (position : Nat) : Nat :=
  project text context 0 (fun native => library.calls.basicPrimitives.scalarTarget text native position)

noncomputable def projectedBooleanTarget (library : Libraries) (text : Source) (context : ParseContext)
    (position : Nat) : Nat :=
  project text context 0 (fun native => library.calls.basicPrimitives.booleanTarget text native position)

noncomputable def projectedToken (library : Libraries) (text : Source) (context : ParseContext)
    (scan : BodyScan) (token : ShellToken) : BodyScan :=
  project text context (invalidBody scan) (fun native => library.calls.bodyWrappers.token text native scan token)

noncomputable def projectedCondition (library : Libraries) (text : Source) (context : ParseContext)
    (position : Nat) (facts : ActiveFlow) : ConditionResult :=
  project text context (invalidCondition facts)
    (fun native => library.calls.predicate.condition text native position facts [])

theorem projected_basic (library : Libraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (scan : BodyScan) (scanValid : BodyNative.ValidScan text native scan)
    (functions : FunctionBindings.Metadata) (functionsValid : FunctionBindings.ValidMetadata text functions)
    (procedures : ProcedureBindings.Metadata) (proceduresValid : ProcedureBindings.ValidMetadata text procedures) :
    library.projectedBasic text native.model scan functions procedures =
      Predicate.basicBody text native.model scan functions procedures := by
  apply project_eq text native contextValid
  intro chosen same ready
  rw [library.basic text valid chosen ready scan (scan_transport same.symm scanValid)
    functions functionsValid procedures proceduresValid, same]

theorem projected_scalar_target (library : Libraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (position : Nat) (bounded : ValidCursor text position) :
    library.projectedScalarTarget text native.model position = Predicate.scalarTarget text native.model position := by
  apply project_eq text native contextValid
  intro chosen same ready
  rw [library.scalarTarget text valid chosen ready position bounded, same]

theorem projected_boolean_target (library : Libraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (position : Nat) (bounded : ValidCursor text position) :
    library.projectedBooleanTarget text native.model position = Predicate.booleanTarget text native.model position := by
  apply project_eq text native contextValid
  intro chosen same ready
  rw [library.booleanTarget text valid chosen ready position bounded, same]

theorem projected_token (library : Libraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (scan : BodyScan) (scanValid : BodyNative.ValidScan text native scan)
    (token : ShellToken) (tokenValid : ValidToken token) (fixed : Adapter.FixedToken token) :
    library.projectedToken text native.model scan token = Predicate.bodyToken text scan token := by
  apply project_eq text native contextValid
  intro chosen same ready
  exact library.bodyToken text valid chosen ready scan (scan_transport same.symm scanValid) token tokenValid fixed

theorem projected_condition (library : Libraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (position : Nat) (bounded : ValidCursor text position) (facts : ActiveFlow)
    (flow : Predicate.Native.ValidFlow native facts) :
    library.projectedCondition text native.model position facts = Predicate.readCondition text native.model position facts := by
  apply project_eq text native contextValid
  intro chosen same ready
  rw [library.condition text valid chosen ready position bounded facts
    (ApplicationPackageActual.flow_transport same.symm flow), same]

/-- The projected body call agrees with every permitted original context,
not just the witness chosen by the formal representation. -/
theorem projected_basic_native (library : Libraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (scan : BodyScan) (scanValid : BodyNative.ValidScan text native scan)
    (functions : FunctionBindings.Metadata) (functionsValid : FunctionBindings.ValidMetadata text functions)
    (procedures : ProcedureBindings.Metadata) (proceduresValid : ProcedureBindings.ValidMetadata text procedures) :
    library.projectedBasic text native.model scan functions procedures = library.calls.basic text native scan functions procedures :=
  (library.projected_basic text valid native contextValid scan scanValid functions functionsValid procedures proceduresValid).trans
    (library.basic text valid native contextValid scan scanValid functions functionsValid procedures proceduresValid).symm

end Libraries
end Silver.ApplicationPackageBodies.Inherited
