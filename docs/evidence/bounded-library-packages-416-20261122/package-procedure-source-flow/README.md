# Original-source procedure call flow

The focused `Silver.ApplicationPackageProcedureFlow` target and fresh axiom audit
passed on Linux x86-64 with 30,965 declarations. [index.json](index.json) identifies
the run and retained inputs; all captured source hashes matched before retention.
Two workers, two Lean threads per process and 8192 MiB were allocated. Dependencies
were cached; no independent kernel replay or whole-feature checkpoint is claimed.

The accepted original call now supplies its actual source list, semantic arguments,
formal-order binding, readable expressions and complete semantic argument/copy-out/
alias check together with its exact final flow. This flow first applies explicit
output targets, then the actual native visible-global slot reset. The completion
prefix is the call's original prefix; named and empty actual lists are included.
The callee safety certificate is not assumed. Final cursor and effect-union
bookkeeping are proved to preserve that precise flow.

The first draft failed on an eliminated equality witness and explicit native
context projection normalization; the repaired focused check passed without
changing the native source, domains or trust assumptions. Original layout/global
membership and subtype-range correspondence remain separate inputs to compose,
followed by the Basic/recursive statement and initializer/routine/Main endpoints.
External automatic completion is still separate. Selected GPT-6 Astra Max;
runtime model/effort and token/cost data were not independently exposed. The
retained evidence contains build and fresh-audit timings.
