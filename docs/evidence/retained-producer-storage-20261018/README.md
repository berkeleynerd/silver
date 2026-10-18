# Producer storage and output arithmetic evidence

Local source and arithmetic checks for the
[storage derivation](../../research/retained-producer-storage.md), #119.
No native compiler, prover, near-limit allocation or proof assistant runs.

```sh
python3 docs/evidence/retained-producer-storage-20261018/check.py \
  --ada /path/to/pinned/gcc/ada --output /path/to/new-scratch
python3 docs/evidence/retained-producer-storage-20261018/serialization.py \
  --output /path/to/new-scratch
```

The storage checker verifies fourteen complete GCC files against the earlier pinned
GCC inventory and reads five complete SPARK candidate files from the retained
source archive. It emits LF-numbered excerpts, 174 vector boundary transitions,
hash-table rounding, JSON quote-buffer/column arithmetic and the `d=40`
decimal-conversion peak (41 Uint entries, 369 digit words). It inventories all
protected-minimum assignments and checks radix/direct-range boundaries;
source caller/lifetime reasoning establishes exact pool restoration. The
quote-buffer/column conditions still require source-derived actual-string and
per-file character weights; they do not follow from node counts alone. The
serializer checker reads eight archived SPARK files, accounts for all 63 usable
node kinds and 177 variant fields, and records each local weight's coefficients.
It also reconstructs all five retained library proof-input files byte for byte,
including whitespace and final newline, and verifies their weighted bounds.
`serialization.json` retains the schema, coefficients and finite comparisons;
its general transfer still requires source-derived primitive lengths and
occurrence counts. It does not run the installed producer. The
installed layout evidence is retained separately with the
[fixed producer measurement](../retained-producer-fixed-20261018/README.md).
The checker does not establish source caller coverage or a whole-program bound.
