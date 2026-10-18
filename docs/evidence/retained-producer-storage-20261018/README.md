# Producer storage and output arithmetic evidence

Local source and arithmetic checks for the
[storage derivation](../../research/retained-producer-storage.md), #119.
No native compiler, prover, near-limit allocation or proof assistant runs.

```sh
python3 docs/evidence/retained-producer-storage-20261018/check.py \
  --ada /path/to/pinned/gcc/ada --output /path/to/new-scratch
```

The checker verifies twelve complete runtime files against the earlier pinned
GCC inventory and reads five complete SPARK candidate files from the retained
source archive. It emits LF-numbered excerpts, 174 vector boundary transitions,
hash-table rounding and JSON quote-buffer/column arithmetic. These last two
conditions still require source-derived actual-string and per-file character
weights; they do not follow from node counts alone. The
installed layout evidence is retained separately with the
[fixed producer measurement](../retained-producer-fixed-20261018/README.md).
The checker does not establish source caller coverage or a whole-program bound.
