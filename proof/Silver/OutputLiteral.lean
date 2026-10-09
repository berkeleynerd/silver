import Silver.Admission

/-! Printable-ASCII predicate shared by literal admission and runtime bounds.
The authoritative independent literal derivation is `Output.LiteralAt` in
OutputAdmission, with its scanner soundness and completeness theorems. -/

namespace Silver.Output

def printable (byte : Nat) : Bool := decide (32 ≤ byte ∧ byte ≤ 126)

end Silver.Output
