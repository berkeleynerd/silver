module

public import Silver.ApplicationPackageBodyHistory
public import Silver.ApplicationPackageUnitDomains

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Compose.Expressions ApplicationPackageDeclarations

/-- The original private-state declaration history preserves both the native
parser frame and the full metadata component subtypes, before any routine is
completed. Each continuing edge uses the already checked complete Unit domain. -/
theorem StateObjects.domain (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    {before after : UnitState} {rows : List StateObject}
    (history : StateObjects
      (bodyReaders reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)))
      text before rows after) (domain : UnitDomain text before) : UnitDomain text after := by
  induction history with
  | finished => exact ⟨domain.frame, domain.metadata⟩
  | @added row rest final phase selected capacity parsed advanced writable history ih =>
    apply ih
    apply unit_step_domain library reader valid domain
    dsimp only [unitStep]
    rw [phase]
    dsimp only [objectSelected] at selected
    rw [ite_eq_left selected, ite_eq_right capacity, parsed]
    simp only [Nat.not_le_of_gt advanced, writable, Bool.false_eq_true, or_self, ite_false,
      StateObject.after]

/-- The intermediate routine entry is derived from the original BodyHistory,
not supplied as an extra semantic precondition of the completed application. -/
theorem BodyHistory.routines_domain (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {sources : ApplicationUnits.Bundle}
    {specification : SpecificationResult} {result : ApplicationAdmission.BodyResult}
    (history : BodyHistory reader
      (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)) sources specification result)
    (valid : ValidText (sources.prefix .packageBody))
    (framed : ReaderFrame (sources.prefix .packageBody) specification.exports)
    (typed : specification.info.Typed) :
    UnitDomain (sources.prefix .packageBody) history.routinesStart :=
  history.declarations.domain library reader valid
    (unit_start_domain reader _ valid specification.exports framed specification.info typed history.entered)

end Silver.ApplicationPackageBodies
