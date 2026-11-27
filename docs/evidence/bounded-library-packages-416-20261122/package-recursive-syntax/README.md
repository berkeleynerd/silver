# Original recursive package/Main syntax — 2026-11-27

Managed focused run `20261127T220943-04350faef562` passed
`Silver.ApplicationPackageRecursiveSyntax` and freshly audited 37,535 imported
declarations on Linux x86-64. Actual resources: two Lake workers, two Lean
threads, 8192 MiB per process, guest CPUs 0–1 under the shared eight-CPU ceiling.
Selected role Astra Max; live runtime model/effort and token/cost unavailable.

The mutually recursive StatementCodeAt, ArmsCodeAt, ElseCodeAt and TailCodeAt
relations preserve the original native call/branch histories, ConditionAt and
LoopBoundsAt readings, inherited Basic source, and exact package-call identity.
Their statement lists retain all branches and loop bodies, including unreachable
ones; ELSIF lowers to nested choices and Tail concatenates in source order.
No semantic checker, valid-program, safety, effect-coverage or discharge premise
is stored in this source representation. StatementCodeAt.original erases syntax
back to the original recursive native tree without deleting a node.

This establishes the representation and original-tree correspondence, not the
pending complete recursive semantic extraction/checker/effect theorem. Canonical
reader binding to original imported source, declaration and routine inventories,
library/Main aggregation and complete assurance remain required. No full audit,
feature completion or merge is claimed. All captured local inputs were hashed
and checked before retention. The primary input comparison distinguishes the
new private module from pre-existing shared files.
