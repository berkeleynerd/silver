# Main semantic bridge evidence

The [derivation](../../research/retained-main-semantics.md) retains a bound on
Main's node identities and distinguishes remaining numeric/table obligations.
Reproduce source identity and the aggregate equation with:

```sh
python3 docs/evidence/retained-main-semantics-20261018/derive.py \
  --source /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada
```

The script checks 23 cited GCC files against the retained complete source
manifest for commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, checks cited
line ranges exist, and expands the node formula using exact integers. Its
retained result is [result.json](result.json). Source bytes already remain in
the existing pinned archive; this directory does not duplicate excerpts.

These are source/arithmetic checks, not a compiler experiment, automated
reachability proof, complete resource bound or installed-binary verification.
Numeric and auxiliary-table bounds remain unfinished. No compiler, prover, Lean, rebuild or
full-suite run was performed.
