# Source-literal repair — #290

Complete Lean run `20261029T205735-bb72d0625415` finished failed at
2026-10-30 02:01:47 UTC: 18,240.247 s build time and 18,249.514 s managed
duration. Seven false source-correspondence propositions in four modules
prevented completion; the whole-project audit did not run. The
[original events and log](../runs/20261029T205735-bb72d0625415/retained.json)
retain that outcome and all 653 captured inputs match its target `6020416906`.

The independent [terminal/source review](../../../reviews/review-named-integer-subtypes-terminal-evidence-20261030.md)
confirmed completion-assurance blocker [#290](https://github.com/berkeleynerd/silver/issues/290).
The scalar spec pin and declaration expectation still used `/ 12` instead of
the implemented and modeled `/ 7`. Predicate basic, loop and adapter literals
still represented the preceding visibility, component-bound and environment
forms. Their typed trees and semantics already matched the new Ada source.

Reviewed repair `d4e2be67b5de7fcc2919cf9eac6efb217e5ca672` changes seven literal
lines in five proof files. It changes no Ada, generated certificate, semantic
tree, endpoint, proof domain, prover option, script or test. The
[input delta](input-delta.json), [token deltas](token-deltas.txt) and
[implementation note](implementation-note.md) identify the exact changes.
Independent review compared authoritative tokens with both the literals and
their existing typed render/evaluation/model definitions; a pin match alone
was not accepted as correspondence.

The read-only diagnostic is retained as [diagnose.py](diagnose.py), with only its
repository-root path adjusted from the original scratch location. From the
repository root, `python3 docs/evidence/named-integer-subtypes-20261029/source-literal-repair/diagnose.py`
confirms ten exact token lists and 56 adjacent literal header pins. It is an
untrusted diagnostic, not a replacement for Lean's kernel checks or final
authoritative-source bridge.

The failed run completed `OutputBodyCertificate` (9,606 s),
`ComposeSourceCandidate` (5,694 s), `PredicateScalarBodyCandidate` (426 s) and
other independent modules. None of the five repairs is in those three modules'
import closures. Their successful objects remain in the same Lake workspace
for ordinary dependency-checked reuse. `PredicateSourceCandidate` depends on
the repaired Predicate literals and still requires validation. There was no
cache transfer or clean rebuild for this repair.

All 28 affected regressions passed on exact repaired inputs: the
[literal-regression packet](../literal-repair-regression/README.md) preserves
their logs, prior history and the applicable 18 earlier repair results plus
509 original results, covering all 555 identities. Native assurance and the
compiler build remain applicable because every native input is unchanged.

Focused run `20261030T020329-280326d88dbd` is checking the four formerly failing
source modules and their fresh import-closure audit. Complete repaired
Lean/source/module/axiom validation and the final Rosetta refresh remain pending.

Implementation selected GPT-6.1 Sol / Extra High; independent review selected
GPT-6 Astra / Extra High. Runtime settings and token/cost measurements are not
independently exposed. No additional native proof, clean build or kernel replay
was launched for this proof-only repair.
