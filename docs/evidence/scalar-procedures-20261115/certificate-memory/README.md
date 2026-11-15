# Output certificate memory recovery — 2026-11-15

This is focused recovery evidence for #370 on Linux ARM64, Lean 4.34.1,
12 available CPUs and approximately 16 GiB RAM without swap. It does not yet
establish a successful complete output certificate or complete project assurance.
The native and whole-project failures in the
[November 13 packet](../../scalar-procedures-20261109/final-failures-20261113/README.md)
retain their outcomes.

## Exact change and guarantees

`CertificateJoinWitness.lean` adds `kernel_join`, an untrusted metaprogram that
constructs the existing `string_join_ofList` theorem application directly from
two string literals. It builds precisely typed `List Char` constructor terms,
then submits the witness to `mkAuxLemma` at the complete goal type, with async
elaboration disabled for that kernel check. This is the existing checked
auxiliary-lemma mechanism used by `kernel_exact` and `decide +kernel`.

The generator uses this compact syntax only for output-body joins. The same
balanced reconstruction, every ordered line occurrence, every line lexical
certificate, every exact joined string, all flattened tokens and all final
source/token/lexer propositions remain checked. No source byte, input domain,
token, source dependency, obligation or audit is omitted. There is no native
evaluation theorem, new axiom or trusted generator result. The original
`CertificateWitness.lean` and `SourceLexer.lean` are byte-identical to the
starting revision. The new meta module is imported only by the output aggregate,
so existing line-module and other certificate dependencies remain reusable.

The actual authoritative input has **424,747 bytes**, including its exact line
endings, with SHA-256
`619f4fb8e2b0f318dac7c6278d5f644198816ce7733959ed71ca03917546b2b8`.
For these same bytes the old generator's split aggregate is 36,329,346 bytes;
the compact aggregate is 14,404,305 bytes. This source-size comparison is not a
complete-build memory measurement. The previously checked-in aggregate used
older source bytes; its 30,561,548-byte size is not the comparison baseline.

## Focused checks

| Managed run | Scope and outcome |
| --- | --- |
| `20261115T170117-30e292534eea` | Experimental universal byte-list join helper failed on explicit newline normalization; retained as an ordinary proof-development failure. |
| `20261115T170217-19702e2e8ba5` | Repaired generic helper and direct ASCII/Unicode witnesses passed; fresh audit of 439 declarations. This helper is experimental and absent from the final proof tree. |
| `20261115T170328-e58510a0dfbc` | One actual-source-sized join using `kernel_exact (Eq.refl outputProfileBody)` failed at the 3,072 MiB kernel memory threshold. No OOM or host stop. |
| `20261115T170650-9720795a7a18` | Initial compact builder failed module compilation because its private helper needed the `meta` modifier. No expensive witness check ran. |
| `20261115T170732-b96df7dfa66d` | Exact 424,747-byte join using the compact original theorem witness passed, with fresh audit of 445 declarations. |
| `20261115T171000-56b7d9a59bdb` | Full `test_lean_source.py`: 16 methods passed, including native kernel controls; only existing `OutputSpecCertificate` regeneration parity failed. This run remains failed. |
| `20261115T171157-206b881e7b93` | Final isolated `CertificateJoinWitness` module passed its managed build and fresh audit of 434 declarations. |
| `20261115T171250-44037e89fa98` | Five final output-generator/kernel-control methods passed, including an added missing-token control on the explicit large-token-list proof path. |

The full-size compact probe took 23.073 seconds for the monitored invocation.
It used one Lake worker, the default 12 Lean threads and a 3,072 MiB per-process
resident-memory threshold. The sampled process-tree peak, including Lake and
the runner, was **4,059,185,152 bytes (3.78 GiB)**. Minimum available host memory
was 11,614,683,136 bytes. A guard would interrupt only this process group below
1.5 GiB host headroom or above 4,500 MiB process-tree RSS; neither triggered.
Lean's threshold is periodically checked and is not a hard OS allocation cap.
The direct-witness failure took 18.095 seconds and reached a sampled process-tree
peak of 4,267,278,336 bytes. It does not establish that a larger budget would
fail, and is not a controlled old-aggregate/new-aggregate comparison.

Successful native fixtures freshly compile the helper chain and freshly audit
each accepted fixture. They check empty strings, CR/LF boundaries, Unicode,
empty source, repeated blank lines and absent final newline. They reject false
join goals, changed comment bytes, truncated source, removed final LF,
normalized CRLF, changed witness bytes, truncated witnesses, shifted newline
boundaries and missing flattened tokens. Existing wrong leaf/token/witness and
unsupported-alphabet controls remain enabled. Fixtures use one native Lean
thread and a 2,048 MiB threshold; they are small correctness controls, not the
complete-source memory measurement.

`generator-scope-parity.json` compares old and new generators on all current
authoritative sources: all 31 non-output sources generate byte-identical
certificates. The unrelated stale `OutputSpecCertificate` must be refreshed by
integration before final whole-suite acceptance; no parity test was weakened.

## Retention and remaining work

`focused-runs.json` retains the managed events; logs, successful detailed input
and artifact inventories, tool-copy identities and sampled resource records
accompany it. `full-source-probe.lean.gz` and
`full-source-probe-witness.lean.gz` retain the exact experimental proof and
helper used by the successful full-size join. The recovered helper bytes were
verified against that run's captured input hash. The final helper is isolated
under a new module name to preserve existing caches.

The native tools were copied into the separate native-filesystem worktree and
checked against the original executable hashes and pinned distribution marker;
bootstrap revalidated Lean 4.34.1. The mounted checkout's tool installation and
other hosts' artifacts were preserved. The source stream uses a separate
workspace and managed worker reservation; expensive runs are coordinated with
the independent function-source and native diagnosis streams.

Independent critical review, actual aggregate validation, final-source
regeneration and complete native/Lean/source/provenance/regression checkpoints
remain outstanding. No publication, issue closeout or capability support is
claimed here. This named memory-design investigation selected Astra / Ultra;
runtime model/effort telemetry was not independently available.
