module

public import Silver.ApplicationAdmissionChargeSourceShape
public import Silver.ApplicationAdmissionNative

@[expose] public section

namespace Silver.ApplicationAdmission.Charge
open Compose Compose.Expressions

/-- A Charge library contains only the existing imported helper interpretations
and the exact native source check. Its complete result is derived below, never
assumed as an independent chargeUnit equality. -/
structure Library where
  calls : Expressions.Calls
  domain : StateDomain
  imports : RawHelperEquations calls (domain := domain)
  tokens : List String
  source : SourceChecks.Checked tokens

def Library.reader (_ : Library) : Source → Nat → ChargeResult := chargeUnit

theorem Library.executed (library : Library) (text : Source) (valid : ValidText text)
    (remaining : Nat) (prior : Locals) (result : ChargeResult) :
    body.Exec library.calls (inputLocals prior text remaining) (fun after => result = output after) ↔
      result = library.reader text remaining :=
  imported_reader_exec library.calls library.imports text valid remaining prior result

theorem Library.complete_contract (library : Library) (text : Source) (valid : ValidText text)
    (remaining : Nat) (bounded : remaining ≤ maxConcatenations) (prior : Locals) :
    body.Exec library.calls (inputLocals prior text remaining)
      (fun after => library.reader text remaining = output after) ∧
      (library.reader text remaining).remaining ≤ maxConcatenations ∧
      (library.reader text remaining).accepted = workTail text 1 remaining :=
  ⟨(library.executed text valid remaining prior _).mpr rfl,
    output_domain text valid remaining bounded, chargeUnit_accepted text remaining⟩

def Library.admission (library : Library) (other : ApplicationAdmission.Native.Callees) :
    ApplicationAdmission.Native.Callees := {other with chargeUnit := library.reader}

/-- The admission wrapper's existing in/out call receives the uniquely
determined two-output result of the complete imported procedure execution. -/
theorem Library.admission_call (library : Library) (other : ApplicationAdmission.Native.Callees)
    (text : Source) (valid : ValidText text) (remaining : Nat) (prior : Locals) (result : ChargeResult) :
    body.Exec library.calls (inputLocals prior text remaining) (fun after => result = output after) ↔
      result = (library.admission other).chargeUnit text remaining :=
  library.executed text valid remaining prior result

end Silver.ApplicationAdmission.Charge
