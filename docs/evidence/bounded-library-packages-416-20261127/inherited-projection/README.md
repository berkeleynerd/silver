# Original inherited body projections — 2026-11-27

Run `20261127T231407-0d43916d14ec` passed both targets and a fresh audit of
76,968 declarations across 512 modules. All 1,688 captured inputs match the
checking worktree. The only differences against integration commit
`36f9fc1562` were these two new modules. The preceding projection-only run also
passed; the second batch added the assignment-result helper.

The projected inherited Basic, scalar/Boolean target, body-token and condition
calls retain a valid original native context witness. Their meanings follow
from the existing source libraries over the full caller domains. The assignment
result retains its weaker native component-subtype domain, with no added
Valid_Context or source-validity requirement. Every permitted original witness
agrees with the chosen projection. These formal projections add no runtime test
or language restriction. Whole recursive caller composition remains required.

Linux x86_64, Lean 4.34.1, two workers/two threads, 8192 MiB per process,
guest CPUs 6–7 borrowed from the idle initializer stream and returned afterward.
Incremental focused builds and fresh audits within the host's eight-CPU
allocation; no copied cache, kernel replay or complete feature-assurance claim.
Proof work follows the Astra Max category; live runtime settings are not
independently exposed.
