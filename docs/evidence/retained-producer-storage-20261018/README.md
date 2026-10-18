# Producer vector/list storage evidence

Local source and arithmetic checks for the
[storage derivation](../../research/retained-producer-storage.md), #119.
No native compiler, prover, near-limit allocation or proof assistant runs.

```sh
python3 docs/evidence/retained-producer-storage-20261018/check.py \
  --ada /path/to/pinned/gcc/ada --output /path/to/new-scratch
```

The checker verifies complete runtime files against the earlier pinned GCC
inventory and emits LF-numbered excerpts plus boundary arithmetic. The
installed layout evidence is retained separately with the
[fixed producer measurement](../retained-producer-fixed-20261018/README.md).
The checker does not establish source caller coverage or a whole-program bound.
