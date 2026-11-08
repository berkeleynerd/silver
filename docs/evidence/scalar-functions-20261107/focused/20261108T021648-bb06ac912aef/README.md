# Expanded focused source check — failed outcome retained

Run `20261108T021648-bb06ac912aef` checked the repaired Predicate equations,
outer candidate, Boolean initializer libraries and the named body source
candidate on `c437a41d30`, with 8 workers and 22 process threads. It finished
with failure at 2026-11-08 02:20:29 UTC. The retained log phase start matches
the managed events. No successful axiom audit or complete assurance is claimed.

All five previously repaired proof modules compiled, including the outer
assignment equation and Boolean context adapters. Adding the body-source target
exposed stale `PredicateBasicSourceCandidate` and `PredicateLoopCandidate`
rendering comparisons. `ComposeBooleanDeclarationLibraries` also introduced
its local `let p := booleanDeclarationParts ...` as if it were the nonzero
hypothesis, leaving the real hypothesis unintroduced.

The next correction changes only those three proof files. The basic candidate
is extracted from current native Basic_Body and now carries its existing
purity guards, call-assignment branches and pure-context fallback; these are
already in BasicNative's evaluator/rendering. The loop candidate adds the
existing Catalog actual to Read_Body, already in LoopNative's evaluator/rendering.
The theorem statements and named authoritative-source extraction remain intact.
The Boolean proof reduces its local let before introducing the existing nonzero
hypothesis. Native source, domains, contracts and semantic models are unchanged.

`candidate-token-diff.json` identifies the exact native and old/new candidate
hashes and token changes. This cheap extraction is diagnosis, not kernel
acceptance. The next focused run must prove the rendering equalities and
actual named-body correspondence, followed by the complete project audit.
