# Independent native component review evidence

Frozen target: `cbcd679320`. See the
[review report](../../reviews/review-retained-native-cbcd679320.md).

Run from the repository root with Python 3:

```sh
python3 docs/evidence/review-retained-native-cbcd679320/check.py \
  /path/to/pinned/gcc/ada /tmp/native-review-result.json
cmp docs/evidence/review-retained-native-cbcd679320/result.json \
  /tmp/native-review-result.json
```

The check verifies twelve relevant source files against the complete retained
manifest, inventories fourteen direct generated constructor sites, and
independently sums the source-reviewed local formulas. It does not infer
reachability or prove its manual multiplicities. No compiler/prover runs are
part of this check.

The submitted component checker was also run on the same source directory:

```sh
python3 docs/evidence/unbounded-programs/retained-native-expansion-20261017/derive.py \
  /path/to/pinned/gcc/ada /tmp/native-component-result.json
cmp docs/evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json \
  /tmp/native-component-result.json
```

It verified 49 files and returned 144 lexical call sites; its output matched
the retained target byte-for-byte, SHA256
`9b6eee8113a74c5d0581b1810d76fb00f7a00407a723f77016bb38282779d4a5`.
The earlier target evidence is reused by link rather than copied.
