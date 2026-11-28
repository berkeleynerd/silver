# Object initializer cursor domains

Authorized #416 Completion caller-domain closure, 2026-11-27. Selected proof
role: Astra Max; live model/effort is not independently exposed. Only a new
proof module and evidence were changed.

`objectStep_initializer_bounds` proves that both initializer cursors of every
successful Object result lie at or before the original text end plus one. It
covers both local modes, arbitrary frame/metadata and the existing Boolean
reader, without assuming a valid input frame or accepted initializer. The
original assignment-token/skip construction bounds Init_First; the original
successful final semicolon bounds Init_After. All rejected paths retain their
zero result. Completion can therefore call State_Reads on the returned RHS
spans without introducing a runtime guard or stronger input premise.

Focused target `Silver.ApplicationPackageDeclarationsObjectInitializerBounds`
passed managed run `20261127T220552-b68117d81297` on its first run: 209 jobs and a fresh
axiom audit of 24,705 declarations. Linux x86-64 / Lean 4.34.1, explicit affinity
4–5, two managed workers, two threads per process and 8192 MiB/process, with
cached prerequisites. All captured hashes match locally and every shared input
matches primary; see `input-recheck.json`. This helper result is not a complete
repository or native assurance claim.
