# Metadata contract source check — 2026-11-27

Managed Linux x86-64 run `20261127T193812-e3012a80deea` passed the complete
`Silver.PackageBindingsSourceBridge` target and a fresh 22,065-declaration axiom
audit. The 302.281-second build regenerated the affected small source certificates;
the audit took 3.219 seconds. It used two workers and two threads per process,
8,192 MiB per-process memory, and guest CPUs 2–3 within the host’s eight-CPU allocation.

The native `Valid_Metadata` postcondition now exports the package-name validity
and Main start bound already guaranteed by its unchanged body. The authoritative
specification token witness, exact header check and kernel-proved semantic
projections cover that change together. Neither the native nor Lean input domain
was narrowed. The native whole-unit result is retained in `../native-continuation/`.

The index records the captured-input comparison before integration. This is a
focused source/contract check with Lake reuse, not complete feature assurance or
independent kernel replay. Final application source composition remains open.
