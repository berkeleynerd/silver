# Completing Signature native metadata types

Authorized #416 Completion caller-domain work, 2026-11-27. Selected role:
Astra Max; live model/effort is not independently exposed. Only three new proof
modules and evidence are advanced by this increment. Shared source-check files
were separately synchronized from primary; no native implementation changed.

`readSignature_completion_typed` proves that completing a package signature
preserves the existing `Metadata.Typed` predicate on every result, including
all partial metadata writes before rejection. Its inputs are the original valid
text and ReaderFrame, plus native metadata field subtypes. It does not assume
Valid_Metadata, Complete_Metadata, matching declarations or successful parsing.

The proof covers the initial routine's body name/position, every formal body
name/type-name update, the complete formal loop and the final routine result-name
write. Type names are bounded directly by Package_Type_At's original name guard,
including invalid returns. All retained counts, units, scalar intervals,
identities and effect-set representations remain exact. A finite table update
preserves all untouched rows and its original length.

| Scope | Managed run | Fresh audit |
| --- | --- | --- |
| Generic row/table subtypes and complete Signature start/formal steps | `20261127T220232-7aa4226e2f08` | 46,854 declarations |
| Final routine write, whole formal loop and readSignature result | `20261127T220400-d5e10a9d3127` | 46,870 declarations |

Linux x86-64 / Lean 4.34.1, explicit affinity 4–5, two managed workers, two
threads per process, 8192 MiB/process, cached prerequisites and fresh audits.
All final captured hashes match locally and all shared captured inputs match
primary. The helper run had two newer primary source-check files outside its
reachable module set; these were synchronized before the complete run. Both
applicability records are retained. This is focused helper validation, not a
complete repository or native assurance claim.

Local drafts exposed constant-branch/let reduction, an indexed updated-state
argument and a split tactic selecting a nested lexical guard. The final proof
uses the original outer guard and explicit metadata updates, without changing
the implementation, declared domain or proof budgets. The ledger retains
failed drafts and the diagnostic checkpoint.
