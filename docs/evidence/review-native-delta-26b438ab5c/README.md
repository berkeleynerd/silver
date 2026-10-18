# Native delta review evidence

Frozen target: `26b438ab5c`, delta after `cbcd679320`. See the
[review](../../reviews/review-native-delta-26b438ab5c.md).

From the repository root:

```sh
python3 docs/evidence/review-native-delta-26b438ab5c/check.py \
  /path/to/pinned/gcc/ada /tmp/native-delta-review.json
cmp docs/evidence/review-native-delta-26b438ab5c/result.json \
  /tmp/native-delta-review.json
```

The independent checker verifies sixteen source files against the retained
complete GCC manifest, reconstructs six direct attribute sites and checks the
local sums. The classifications/multiplicities are source-reviewed premises,
not conclusions of the lexical scan.

The submitted native `derive.py` was also run against the same source directory
and its output compared byte-for-byte with `local-envelope.json`: 52 files,
144 lexical call sites, SHA256
`32397ecddd44e2d6e7d0a73194dbddc520bf6e873aebf8baaaec3758b72f629b`.
No compiler, prover, Lean or native stress run is part of this evidence.
