module

public import Silver.ApplicationAdmissionChargeLoop
public import Silver.ApplicationPackageBodiesSourceShape

@[expose] public section

namespace Silver.ApplicationAdmission.Charge.SourceChecks
open Silver.SourceBridge Compose.Expressions

def header : List String := expectedTokens
  "(Text : String; Remaining : in out Concatenation_Count; Accepted : out Boolean) with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length"

structure Checked (tokens : List String) : Prop where
  tree : CheckedTree
  header : procedureHeader "charge_unit" "is" tokens = some header
  body : ApplicationPackageBodies.SourceChecks.ordinaryProcedure "charge_unit" tokens = some Charge.body.render

theorem Checked.meaning {tokens : List String} (checked : Checked tokens)
    (calls : Compose.Expressions.Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (remaining : Nat) (prior : Locals) (result : ChargeResult) :
    ApplicationPackageBodies.SourceChecks.ordinaryProcedure "charge_unit" tokens = some Charge.body.render ∧
      (Charge.body.Exec calls (inputLocals prior text remaining) (fun after => result = output after) ↔
        result = chargeUnit text remaining) :=
  ⟨checked.body, imported_reader_exec calls equations text valid remaining prior result⟩

end Silver.ApplicationAdmission.Charge.SourceChecks
