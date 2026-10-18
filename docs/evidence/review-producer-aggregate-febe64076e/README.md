# Ordinary producer aggregate review evidence

Frozen target: `febe64076e`; technical commit `1eeeb5a581`. See the
[report](../../reviews/review-producer-aggregate-febe64076e.md).

Run from the repository root with the already retained SPARK source snapshot:

```sh
python3 docs/evidence/review-producer-aggregate-febe64076e/check.py \
  /path/to/spark-source /tmp/producer-aggregate-review.json
cmp docs/evidence/review-producer-aggregate-febe64076e/result.json \
  /tmp/producer-aggregate-review.json
```

The checker copies the submitted evidence into a new preserved temporary
directory, reruns its source/archive/arithmetic capture there, and compares
four outputs byte-for-byte. It independently sums the uniform expression
and list vectors. It launches no compiler/prover and does not establish the
manual visit/multiplicity argument or complete capacity closure.
