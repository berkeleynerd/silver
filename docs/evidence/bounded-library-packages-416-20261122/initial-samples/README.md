# Initial package sample execution — 2026-11-22

Managed Linux run `20261122T145120-239737bbbf95` passed all three original-unit
samples through the integrated compiler: admission, proof, native build,
independent Python report audit, exact source snapshots and expected execution.
It reserved two workers within the host's eight-CPU allocation. Application
proofs retain their existing one-worker policy and `--no-inlining`; this is
distinct from the compiler's own native proof allocation.

| Sample | Expected stdout | Audited checks |
| --- | --- | --- |
| Include a file | ` 8` and LF | 20 flow + 47 proof |
| Private counter | ` 9` and LF | 20 flow + 48 proof |
| Queue/Definition | Initial empty, full push, FIFO values 11/22/33, empty pop, final empty | 23 flow + 47 proof |

Each audit covered six selected units. The queue's three `out` formals have
successful initialization checks and its getter has a termination check.
`results.json` retains the exact output, counts, original-unit hashes and local
workspace paths. The harness, original source copies, compressed native reports,
compiler logs and managed input/event record are retained alongside it.
The samples demonstrate their stated behavior; they do not establish universal
language assurance or complete #416. The later explicit `GNAT` package-name
exclusion is outside these three package identities.
