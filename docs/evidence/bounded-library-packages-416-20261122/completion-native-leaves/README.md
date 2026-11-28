# Completion native leaves and caller domains

Authorized #416 proof closure, 2026-11-27. Selected proof role: Astra Max;
actual live model/effort and token/cost measurements are not independently
exposed. No Ada implementation, runtime guard or proof budget changed.

`ApplicationPackageActualLibraries` derives Actual_After from the inherited
lexical, scalar, Boolean, predicate and function-call source dictionaries. Its
native equality retains the exact `Predicate.Native.Context` witness and the
whole original `ActualDomain`, including empty formal intervals, zero formal
names and rejected reads. Function_Return_After is derived from its original
typed body and these two imported readers. Both return cursor bounds.

`ApplicationPackageActualProjection` proves that each legal original native
witness gives the same projected call. The proof-only representative is chosen
from the caller's existing native context domain. Zero outside that domain is
only formal totalization; every native call agreement requires and discharges
the original domain. No native context reconstruction or runtime check is
assumed.

`ApplicationPackageCompletionLeafLibraries` derives Initial_Flow from its
finite-storage source interpreter and State_Reads from the checked effect
imports. Context_Of and Body_Of reuse Main's existing `FlowLibraries`.
`ApplicationPackageCompletionDomains` proves the original declaration-count
reset valid, proves the initial body/flow domains, and preserves ReaderFrame
through Routine_Frame, the complete local-declaration loop, and all successful
output initializer reads. Metadata semantic validity is not an input premise.

Managed run `20261127T222907-db9fa93ccbcf` passed the six retained targets with
a fresh axiom audit of 81,608 declarations. Linux x86-64 / Lean 4.34.1, affinity
4–5, two workers, two threads/process and 8192 MiB/process. Existing dependencies
were cached. All 1,587 captured source hashes match locally. The four shared
primary differences are precisely the separately authorized inherited caller
and renderer repairs, listed in `input-recheck.json`; their source checks and
repair evidence are separate.

Development failures were retained by the managed runner. An unnecessary
procedure-prefix import first exposed current-primary caller/representation
failures; those were assigned and repaired. Subsequent focused diagnostics were
local namespace, dependent-decision normalization and option/cursor proof steps.
One preflight rejected proof-inventory drift from another draft edit; it ran no
proof, and the final successful run used a stable inventory. Unchecked remaining
Completion drafts are not covered by this focused evidence. Full Completion
dictionary transport and repository/native assurance remain outstanding.
