# Producer delta review evidence

For [the frozen `5d4fd26cbb` review](../../reviews/review-retained-producer-5d4fd26cbb.md)
and the separate L1 repair `b6061a8458`, Linux x86_64, 2026-10-18.

`verify.py` reproduces the six producer outputs and the frozen table output,
independently scans the complete Ada tree for parenthesis and Itype-reference
sites, reconstructs fixed loop occurrence overhead, reproduces the exact L1
repair script/output from its Git object, and rechecks the retained source-identity
metadata. `review-results.json` records its deterministic result.

```sh
python3 docs/evidence/review-retained-producer-5d4fd26cbb/verify.py \
  --frontend /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --spark /tmp/silver-frontend-representation-20261017/availability/spark-source \
  --installation /home/canto/src/github.com/berkeleynerd/silver \
  --output /tmp/review-retained-producer-5d4fd26cbb-recheck
```

Run from the frozen review checkout or a checkout retaining the same component
inputs and the repair commit. The component scripts rewrite their own evidence
deterministically; this verifier asserts that the resulting bytes remain
identical. Compare its `review-results.json` with the file retained here.
The other subprocesses are Python evidence checkers and read-only `git show`
commands. No compiler, prover, network request or large allocation is run.

The lexical scans and arithmetic corroborate the manual source/caller review;
they do not prove universal frontend reachability or a complete capacity rule.
`MANIFEST.json` records this directory's raw-byte sizes and SHA-256 hashes,
excluding only itself.
