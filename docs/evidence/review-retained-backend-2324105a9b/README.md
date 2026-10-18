# Backend component review evidence

For the [review of frozen `2324105a9b`](../../reviews/review-retained-backend-2324105a9b.md),
2026-10-18, Linux x86_64.

`verify.py` reruns the reviewed component's source checker, compares its two
outputs byte-for-byte, checks the 22 additional source identities in
`config-source-manifest.json`, and independently recomputes local line-map and
String arithmetic. `config-sources.tar.gz` retains those complete additional
sources at the same immutable GCC revision. The configuration check searches
for the target optimization hook and merge-constants overrides; the report
supplies the manual caller/configuration argument.

The local type-width check records the ordinary Linux LP64 premise; it does not
measure `tree_string` in the installed compiler. No compiler, upstream script,
prover, source stress test or near-limit allocation is executed by the verifier.
Its subprocess is the reviewed Python evidence checker only.

```sh
python3 docs/evidence/review-retained-backend-2324105a9b/verify.py \
  --ada /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output /tmp/review-retained-backend-2324105a9b-recheck
```

Compare the resulting `review-checks.json` with the retained file here. The
upstream source files are read from the existing pinned tree and evidence
archives; no network request is made by the verifier. `MANIFEST.json` inventories
this evidence directory by raw-byte size and SHA-256, excluding itself.
