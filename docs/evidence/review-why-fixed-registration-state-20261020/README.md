# Fixed-registration suffix replay: independent review evidence

Review target: `e6e063c800d38620050960f2b7cae97dbc02305b`, directly above
`b1c0d89f7b652a1c12e957caa986887be890786e`. See the
[review report](../../reviews/review-why-fixed-registration-state-20261020.md).

[check.py](check.py) verifies the six exact target files and five pinned
dependencies, reconciles the four accepted analysis-prefix counts with archived
metadata and author outputs, and streams the complete logs for identity, line
count and the first suffix-read boundary. It checks the saved auxiliary values
with the existing decoder and tests one valid Reader sequence plus eight
rejection cases. It does not execute the archived observers or replay their
complete suffixes, rebuild binder certificates, or run predecessor checkers.

[result.json](result.json) records exact input identities, selected archived
source bodies, four joins and the rejection results. The single fresh check
passed in 5.2273553200002425 seconds. [round.json](round.json) records selected
review settings, elapsed time and the evidence scope. There were no native,
compiler, proof, solver, capture or public-evaluator runs and no GitHub writes.

Intentional reproduction:

```sh
python3 -B docs/evidence/review-why-fixed-registration-state-20261020/check.py
```

The checker refreshes this directory's result record. Snapshot binding is not
freshness, pre-endpoint no-wrap history or a continuing-capacity theorem.
