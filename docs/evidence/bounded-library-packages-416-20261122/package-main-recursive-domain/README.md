# Main recursive induction domain — 2026-11-27

Managed focused run `20261127T221435-f14df1c46c3f` passed MainRecursiveDomain and its syntax
properties, auditing 37,594 declarations on Linux x86-64 with two workers,
two threads,8192MiB and CPU0–1. Selected Astra Max; live model/cost unavailable.

MainScope contains original name/table/declaration-origin invariants, separate
from source-only syntax. It is preserved by original sequential scanner steps
and counted/array loop scope entry: the lexical binder's defining position is
proved after the original cursor. NativeDomain remains the full native helper
domain; no semantic validity is added. The Basic consumer derives source syntax
and exact Main checking from that domain. Tail source erasure, nonempty required
bodies, and arm/ELSE source-history composition are checked too.

All captured local input hashes were verified before retention. This focused
success does not close recursive semantic/effect extraction or complete feature
assurance. Original declaration/inventory/source binding remain required.
