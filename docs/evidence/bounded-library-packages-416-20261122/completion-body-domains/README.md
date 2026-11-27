# Completion output and body domains

Authorized #416 imported Completion closure, 2026-11-27. Selected proof role
Astra Max; live model/effort and token/cost measurements unavailable.

`CompletionOutputDomains` preserves native `StateType`, capacities and the
complete Valid_State import domain across every successful output append.
It deliberately does not assume a valid frame between appends: arbitrary
native-typed metadata may contain empty intervals. Only the original final
Valid_State guard reestablishes ReaderFrame.

`CompletionBodyDomains` derives the recursive tail input domain with its
original native context witness, the original zero declaration count and empty
function/procedure catalogues. The existing recursive source equations derive
the complete output scan domain. The Function_Return_After domain then follows
from that scan and the original routine interval component subtype.

`CompletionLibraries` joins concrete imported declaration, routine-frame,
object, flow, effect, actual and return dictionaries. Signature uses its raw
original execution relation, with a theorem for the corresponding typed body;
the whole-reader model equality is derived. Recursive source equations remain
explicit; no recursive result contract or semantic metadata validity is added.
This module supplies the individual leaf equalities. Full Completion transport
through all stages is still outstanding.

Focused target `Silver.ApplicationPackageCompletionLibraries` passed with
82,106 declarations in the fresh axiom audit. See the retained manifest for the
run identifier and exact captured inputs. Linux x86-64 / Lean 4.34.1, explicit
affinity 4–5, two workers, two threads/process and 8192 MiB/process. Prerequisites
were cached; all captured local hashes match. The inherited caller/source
repairs have their own evidence. Two preliminary focused checks needed a
record-projection simplification and the exact native token-reader spelling
form; neither changed native domains or increased proof budgets. This is
focused helper evidence, not complete Completion or repository assurance.
