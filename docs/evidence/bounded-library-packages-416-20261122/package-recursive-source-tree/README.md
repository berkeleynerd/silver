# Original recursive reader tree

The focused Linux x86-64 run checks the typed Basic/Statement/Tail equations,
their exact raw readings and cursor progress, and the mutually recursive source
tree retaining all arms, optional ELSE, loop bodies and sequential statements.
Reading projections use the generated mutual induction principles.

Run `20261127T205831-0e37decb6ce6` passed with 23,860 declarations and a fresh
axiom audit, using two Lake workers, two Lean threads and 8192 MiB per process
on the assigned CPU 0–1 share. Captured input hashes were checked when retaining
this evidence. No identical successful run was repeated.

The first two focused attempts exposed a mutual-inductive parameter mismatch
and the need for explicit mutual recursors. The checked representation now
uses one shared reader parameter; every original input remains an index.
No admitted-language restriction, native contract or Oracle guarantee changed.

The tree is a source-only representation, not a semantic safety certificate.
Extraction from actual native-domain executions, whole recursive semantic
decoding, complete initializer obligations and the application/tool endpoint
remain outstanding. This is partial validation, not complete assurance.

Selected proof setting: GPT-6 Astra Max. Live model/effort and token/cost
measurements were unavailable. Native source bytes were unchanged.
