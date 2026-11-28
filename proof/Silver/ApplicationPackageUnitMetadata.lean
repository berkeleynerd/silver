module

public import Silver.ApplicationPackageUnitComposition

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Compose.Expressions ApplicationPackageDeclarations

/-- Only the original footer can accept a Unit; it retains its current
metadata. Early rejected paths cannot manufacture an accepted result. -/
theorem unit_step_accepted_info {calls : UnitCalls} {text : Source} {state : UnitState}
    {result : ApplicationAdmission.BodyResult}
    (returned : unitStep calls text state = .returned result) (accepted : result.accepted = true) :
    result.info = state.info := by
  cases phase : state.phase with
  | objects =>
    simp only [unitStep, phase] at returned
    split at returned
    · split at returned
      · cases returned
        cases accepted
      · split at returned
        · cases returned
          cases accepted
        · contradiction
    · contradiction
  | routines =>
    simp only [unitStep, phase] at returned
    split at returned
    · split at returned
      · cases returned
        cases accepted
      · contradiction
    · contradiction
  | footer =>
    simp only [unitStep, phase, UnitStep.returned.injEq] at returned
    exact congrArg ApplicationAdmission.BodyResult.info returned.symm

theorem unit_fuel_accepted_typed (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    {state : UnitState} (domain : UnitDomain text state) {fuel : Nat} {result : ApplicationAdmission.BodyResult}
    (read : unitFuel (unitStep (bodyReaders reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))) text)
      fuel state = some result) (accepted : result.accepted = true) : result.info.Typed := by
  induction fuel generalizing state with
  | zero => cases read
  | succ fuel ih =>
    dsimp only [unitFuel] at read
    split at read
    · rename_i output returned
      cases Option.some.inj read
      rw [unit_step_accepted_info returned accepted]
      exact domain.metadata
    · rename_i next continued
      exact ih (unit_step_domain library reader valid domain continued) read

theorem startUnit_returned_false {calls : UnitCalls} {text : Source} {exports : ParserState}
    {info : PackageBindings.Metadata} {result : ApplicationAdmission.BodyResult}
    (entered : startUnit calls text exports info = .returned result) : result.accepted = false := by
  dsimp only [startUnit] at entered
  split at entered
  · cases entered
    rfl
  · split at entered
    · cases entered
      rfl
    · contradiction

/-- The successful original body supplies the native component subtypes used
by Main's imported declarations and recursive reader. No metadata validity test
is substituted for these representation facts. -/
theorem readBody_accepted_typed (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (exports : ParserState) (framed : ReaderFrame text exports) (info : PackageBindings.Metadata) (typed : info.Typed)
    (accepted : (readBody reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)) text exports info).accepted = true) :
    (readBody reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)) text exports info).info.Typed := by
  have parsed := readBody_eq reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)) text exports info
  dsimp only [packageBodyFuel] at parsed
  cases entered : startUnit (bodyReaders reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)))
      text exports info with
  | returned result =>
    rw [entered] at parsed
    have same := Option.some.inj parsed
    rw [← same] at accepted
    rw [startUnit_returned_false entered] at accepted
    cases accepted
  | continued state =>
    rw [entered] at parsed
    exact unit_fuel_accepted_typed library reader valid
      (unit_start_domain reader _ valid exports framed info typed entered) parsed accepted

end Silver.ApplicationPackageBodies
