module

public import Silver.ApplicationPackageUnitDomains
public import Silver.ApplicationPackageCompletionNativeImports

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Library
open Compose Compose.Expressions ApplicationNative ApplicationPackageBodies ApplicationPackageDeclarations

set_option backward.dsimp.instances true

/-- A total expression for the original Completion procedure's output. The
fallback is unreachable on its complete native call domain, proved below. -/
noncomputable def completionCall (library : Library) (reader : BooleanElaboration.Native.Reader)
    (text : Source) (globals : ParserState) (info : PackageBindings.Metadata) : CompletionResult :=
  let locals := ((library.prior.set .source "text" text).set .state "globals" globals).set .metadata "info" info
  ((Native.body.eval (Native.modelFunctions (library.calls reader))
    (Native.modelProcedures (library.calls reader)) (text.length + 2) locals).map Native.observed).getD ⟨globals, info⟩

theorem completion_call (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (framed : ReaderFrame text globals)
    (info : PackageBindings.Metadata) (typed : info.Typed) :
    library.completionCall reader text globals info =
      readCompletion reader (LeafLibraries.model (library.calls reader)) text globals info := by
  let locals := ((library.prior.set .source "text" text).set .state "globals" globals).set .metadata "info" info
  have original := library.completion_native reader locals valid framed typed
  change (Native.body.eval _ _ (text.length + 2) locals).map Native.observed = some _ at original
  change ((Native.body.eval _ _ (text.length + 2) locals).map Native.observed).getD _ = _
  rw [original]
  rfl

noncomputable def unitCalls (library : Library) (reader : BooleanElaboration.Native.Reader) : UnitCalls :=
  library.objects.unit reader library.prior
    {bodyReaders reader (LeafLibraries.model (library.calls reader)) with completionAt := library.completionCall reader}

theorem unit_start (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (exports : ParserState) (info : PackageBindings.Metadata)
    (start : ValidCursor text (info.units .packageBody).first) :
    startUnit (library.unitCalls reader) text exports info =
      startUnit (bodyReaders reader (LeafLibraries.model (library.calls reader))) text exports info := by
  let other : UnitCalls := {bodyReaders reader (LeafLibraries.model (library.calls reader)) with
    completionAt := library.completionCall reader}
  change startUnit (library.objects.unit reader library.prior other) text exports info = _
  rw [library.objects.unit_start reader library.prior other valid exports info start]
  dsimp +instances only [startUnit, ObjectLibraries.unitModel, bodyReaders, unitReaders, other]

theorem unit_step (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (state : UnitState) (domain : UnitDomain text state) :
    unitStep (library.unitCalls reader) text state =
      unitStep (bodyReaders reader (LeafLibraries.model (library.calls reader))) text state := by
  let other : UnitCalls := {bodyReaders reader (LeafLibraries.model (library.calls reader)) with
    completionAt := library.completionCall reader}
  change unitStep (library.objects.unit reader library.prior other) text state = _
  rw [library.objects.unit_step reader library.prior other valid state domain.frame]
  cases phase : state.phase <;>
    dsimp +instances only [unitStep, ObjectLibraries.unitModel, unitReaders, bodyReaders, other] <;>
    simp only [phase]
  rw [library.completion_call reader valid state.globals domain.frame state.info domain.metadata]

/-- All iterations transport their primitive imports on the domains derived
by the original earlier iteration. Both rejected and accepted outcomes agree. -/
theorem unit_fuel (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (fuel : Nat) (state : UnitState)
    (domain : UnitDomain text state) :
    unitFuel (unitStep (library.unitCalls reader) text) fuel state =
      unitFuel (unitStep (bodyReaders reader (LeafLibraries.model (library.calls reader))) text) fuel state := by
  induction fuel generalizing state with
  | zero => rfl
  | succ fuel ih =>
    simp only [unitFuel, library.unit_step reader valid state domain]
    split
    · rfl
    · rename_i next advanced
      exact ih next (unit_step_domain library reader valid domain advanced)

theorem package_body_fuel (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (exports : ParserState) (framed : ReaderFrame text exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (start : ValidCursor text (info.units .packageBody).first) (fuel : Nat) :
    packageBodyFuel (library.unitCalls reader) fuel text exports info =
      packageBodyFuel (bodyReaders reader (LeafLibraries.model (library.calls reader))) fuel text exports info := by
  simp only [packageBodyFuel, library.unit_start reader valid exports info start]
  split
  · rfl
  · rename_i state entered
    exact library.unit_fuel reader valid fuel state (unit_start_domain reader _ valid exports framed info typed entered)

theorem package_body_read (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (exports : ParserState) (framed : ReaderFrame text exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (start : ValidCursor text (info.units .packageBody).first) :
    packageBodyFuel (library.unitCalls reader) (3 * (text.length + 1) + 3) text exports info =
      some (readBody reader (LeafLibraries.model (library.calls reader)) text exports info) := by
  rw [library.package_body_fuel reader valid exports framed info typed start]
  exact readBody_eq reader _ text exports info

end Silver.ApplicationPackageCompletion.Library
