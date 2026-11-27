# Signature/Specification contract source witnesses — 2026-11-27

Focused run `20261127T184029-1fc47d2077bb` passed on Linux x86-64 with a fresh
23,479-declaration audit. It checked both Signature/Specification source
candidates and both complete typed-body simulation modules. The two-worker,
two-thread allocation used an 8192 MiB per-process threshold within the host's
eight-CPU allocation. Exact inputs, phase durations and results are retained.

The native change in `1013fedd26` strengthens the two postconditions and loop
invariants to retain original unit spans. The typed annotation category now
represents that exact Loop_Entry invariant with a metadata expression; its
formation/scope checks remain explicit. Updated header/body token fragments
match that contract change. Whole-body simulations still cover arbitrary local
storage and raw callee dictionaries; no executable operation or declared input
domain changed. This is more than updating literal pins alone.

The four targets check the candidate and semantics. Their binding to the full
authoritative OutputBodyCertificate and actual callee-domain closure are separate
remaining work; this packet is not a complete original-source or feature audit.

The fresh private worktree was created at `873874b781`. Before any run, the lead
copied the primary integration workspace's complete Lean toolchain and proof
cache using `cp -a --reflink=auto`, retaining private/server sidecars and traces.
No writer held the source proof workspace during the copy. Lake rehashed the
copied dependencies and rebuilt changed modules; this was an incremental check,
not a clean build or kernel replay. Native compiler inputs were left frozen in
the primary worktree while this private source-witness check ran. CLI memory
was not updated; lead runtime model/effort and token/cost totals are unavailable.
