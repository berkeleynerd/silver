# Independent library and callback demand review

Review evidence for #119 / #153, 2026-10-23. The
[report](../../reviews/review-library-callback-demand-20261023.md) records the
source argument, material stored-contract finding and its disposition.

- `audit.py`: independent Git/archive identity and finite arithmetic audit.
  It reads frozen blobs; it imports no author/predecessor program.
- `inputs.json`: exact reviewed revision/path identities.
- `source-identities.json`: complete archive-member identities checked
  against every retained witness and its line excerpt.
- `result.json`: the audit result, fifteen process/escape vectors, seven
  tuple call trees and the five combined-result mappings.
- `round.json`: selected reviewer settings, observed elapsed interval and
  evidence limitations.

The audit checks source correspondence and calculations. It does not prove
the source simulation or establish the whole capacity rule. No native target,
solver, proof, capture or predecessor checker is run.
