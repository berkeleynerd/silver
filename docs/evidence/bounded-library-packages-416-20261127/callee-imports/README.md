# Original package callee imports — 2026-11-27

Run `20261127T221537-bbf7e892010a` passed 46,618 audited declarations across 294
imported modules. All 1628 captured inputs match the checking worktree;
every existing primary input matches. The new CalleeImports file was the sole
absent input before integration.

The original Package_Callee body now consumes the source-interpreted qualified
reference reader, scalar/Boolean lookups, name comparison and routine lookup.
The proof derives lookup cursor bounds and the completion-prefix lookup domain
from the actual input/preliminary guards, and covers invalid metadata and every
rejected path. It adds no Valid_Metadata or completed-library premise. Arbitrary
native scratch locals are retained in native_meaning. Other Package_Call_At
imports and its actual/alias loops remain required separate integration work.

The first draft failed rewrite matching through the existing readReference alias
and unreduced dependent instances. Giving that equality its exact consumer type
and reducing instances fixed elaboration, without changing any statement, domain
or budget. The failed run remains failed in the managed ledger.

Linux x86_64, Lean 4.34.1, two workers and two threads, 8192 MiB per process,
actual CPUs6–7 within the eight-CPU host allocation. Incremental focused build
and fresh axiom audit; no clean build, kernel replay or complete feature claim.
Selected proof role Astra Max; runtime settings are not independently exposed.
