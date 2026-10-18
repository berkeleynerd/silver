# Parser/scanner component review evidence

Frozen target: `b391e324ff`. See the
[report](../../reviews/review-parser-scanner-b391e324ff.md).

From the repository root, regenerate with Python 3:

```sh
python3 docs/evidence/review-parser-scanner-b391e324ff/check.py \
  /path/to/pinned/gcc/ada /tmp/parser-scanner-review.json
cmp docs/evidence/review-parser-scanner-b391e324ff/result.json \
  /tmp/parser-scanner-review.json
```

The source inventory checks hashes against the retained complete source
manifest. Its lexical sites support manual review; they are not a resolved
call graph or a proof of the recorded formulas.

The submitted table/value generators were also run using the commands in
their respective evidence READMEs. Both outputs reproduced byte-for-byte;
the review records their hashes. This evidence contains no native compiler,
prover, Lean, stress or tool-rebuild execution.
