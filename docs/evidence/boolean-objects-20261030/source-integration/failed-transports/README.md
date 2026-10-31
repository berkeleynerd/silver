# Complete Lean checkpoint on the reader-repair snapshot

Run `20261030T214845-59a80335a9ac` finished **failed** at 05:26:23 UTC on
2026-10-31. Its implementation/proof input was `87dd912436`; later commits
through `3a83e48be1` added records only. Before any repair, all 687 captured
source hashes and two tool hashes matched. `retained.json`, the original
events, the runner log and the proof log retain the exact result. The stale
convenience success manifest is deliberately not included.

The build took 27,441.814 s and the managed run 27,455.259 s, including the
previously recorded 5,644.958 s memory-scheduling suspension. The completed
output-body certificate, Compose source candidate and bridges, predicate
adapter candidate, and scalar-body candidate remain in the Lake cache. They
are completed modules inside a failed run, not complete assurance.

Two modules failed. `PredicateSourceCandidate` reports four unused `simp`
arguments in three Boolean body checks under the existing warnings-as-errors
policy. `PredicateEquations` still supplied the newly generalized native
condition reader directly where the body helper takes four arguments, omitting
the array-initializer argument and its validity proof. The following repair
must preserve the actual body call's default empty initializer storage and
the full native condition-reader domain. Neither failure warrants changed
compiler behavior, a weaker theorem, warning suppression or a kernel bypass.

No whole-project module/axiom audit ran. The independently reviewed Body_Tail
Ada repair is absent from this old snapshot; final source correspondence must
use the source that passes complete native verification. Reuse the completed
objects, integrate the exact source/pin/certificate refresh and the proof-only
repairs, and perform a complete Lean check on the stable final inputs.
