# Complete guarded Routine_Frame interpretation, 2026-11-27

The 488-token candidate includes both frame-validity loop invariants and the
quantified validated-name prefix in the native function at the source SHA in
the [index](index.json). The typed evaluator computes the raw routine frame
for every incoming local store and every result of its explicit callees. The
proof covers the inactive-routine guard, mutable Boolean forgetting, malformed
formal ranges, both full formal passes, returning failures, and final validity.

Linux run 20261127T120934-5d76fb58e7bd checked the two focused targets and
freshly audited 20,980 declarations using the standard Lean foundations. The
managed allocation was two workers and two threads on the shared eight-CPU
host. Runs 20261127T120720-8dc7640a1ab4 and 20261127T120821-f84f50aef416
retain the intermediate guard and match-normalization failures. Authoritative
whole-source reconstruction, concrete native callee correspondence, complete
application assurance and independent review remain open.
