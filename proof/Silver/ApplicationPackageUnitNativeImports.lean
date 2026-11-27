module

public import Silver.ApplicationPackageUnitNativeTotal

@[expose] public section

namespace Silver.ApplicationPackageCompletion.Library
open Compose Compose.Expressions ApplicationNative ApplicationPackageBodies ApplicationPackageDeclarations

/-- Original Unit execution transports every visited step through its derived
native domains. Partial failure metadata is retained as part of the result. -/
theorem unit_execution (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) {state : UnitState} {result : ApplicationAdmission.BodyResult}
    (domain : UnitDomain text state)
    (execution : UnitExecution (unitStep (library.unitCalls reader) text) state result) :
    UnitExecution (unitStep (bodyReaders reader (LeafLibraries.model (library.calls reader))) text) state result := by
  induction execution with
  | returned selected =>
    exact .returned ((library.unit_step reader valid _ domain).symm.trans selected)
  | continued selected rest ih =>
    have original := (library.unit_step reader valid _ domain).symm.trans selected
    exact .continued original (ih (unit_step_domain library reader valid domain original))

theorem body_native_meaning (library : Library) (reader : BooleanElaboration.Native.Reader)
    (locals after : ApplicationNative.Locals) (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "exports"))
    (typed : (locals .metadata "info").Typed)
    (cursor : ValidCursor (locals .source "text") ((locals .metadata "info").units .packageBody).first)
    (fuel : Nat)
    (computed : ApplicationPackageUnit.Native.body.eval
      (ApplicationPackageUnit.Native.modelFunctions (library.unitCalls reader))
      (ApplicationPackageUnit.Native.modelProcedures (library.unitCalls reader)) fuel locals = some after) :
    ApplicationPackageUnit.Native.observed after =
      readBody reader (LeafLibraries.model (library.calls reader))
        (locals .source "text") (locals .state "exports") (locals .metadata "info") := by
  have original := ApplicationPackageUnit.Native.body_simulation computed
  unfold ApplicationPackageUnit.Native.UnitMeaning at original
  rw [library.unit_start reader valid _ _ cursor] at original
  have modeled := readBody_eq reader (LeafLibraries.model (library.calls reader))
    (locals .source "text") (locals .state "exports") (locals .metadata "info")
  unfold packageBodyFuel at modeled
  cases entered : startUnit (bodyReaders reader (LeafLibraries.model (library.calls reader)))
      (locals .source "text") (locals .state "exports") (locals .metadata "info") with
  | returned result =>
    rw [entered] at original modeled
    exact original.trans (Option.some.inj modeled)
  | continued state =>
    rw [entered] at original modeled
    have domain := unit_start_domain reader _ valid _ framed _ typed entered
    exact (library.unit_execution reader valid domain original).unique (unitFuel_sound modeled)

/-- Complete typed Package_Body execution on the whole original precondition,
including rejected source, arbitrary scratch locals and partial metadata. -/
theorem body_native (library : Library) (reader : BooleanElaboration.Native.Reader)
    (locals : ApplicationNative.Locals) (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "exports"))
    (typed : (locals .metadata "info").Typed)
    (cursor : ValidCursor (locals .source "text") ((locals .metadata "info").units .packageBody).first) :
    (ApplicationPackageUnit.Native.body.eval
      (ApplicationPackageUnit.Native.modelFunctions (library.unitCalls reader))
      (ApplicationPackageUnit.Native.modelProcedures (library.unitCalls reader))
      ((locals .source "text").length + 2) locals).map ApplicationPackageUnit.Native.observed =
      some (readBody reader (LeafLibraries.model (library.calls reader))
        (locals .source "text") (locals .state "exports") (locals .metadata "info")) := by
  obtain ⟨after, computed⟩ := ApplicationPackageUnit.Native.body_imports_total library reader locals valid framed typed cursor
  rw [computed, Option.map_some, library.body_native_meaning reader locals after valid framed typed cursor _ computed]

end Silver.ApplicationPackageCompletion.Library
