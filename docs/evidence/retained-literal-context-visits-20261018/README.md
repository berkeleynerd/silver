# Fixed implicit context visits

The [source argument](../../research/retained-literal-context-visit-bound.md)
derives I<=114 under the existing selected unit/source premises. `derive.py`
exports the bound and composes it with the frozen original Main callable;
all storage/toolchain completion flags remain false. It adds no production
admission or frontend construction claim.

```sh
python3 docs/evidence/retained-literal-context-visits-20261018/derive.py \
  > docs/evidence/retained-literal-context-visits-20261018/result.json
python3 docs/evidence/retained-literal-context-visits-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output docs/evidence/retained-literal-context-visits-20261018/check-results.json
```

The manifest freezes the existing complete Ada source manifest, fixed closure
inputs, source arguments and original Main dependency. The checker verifies
all 2319 Ada implementation/specification files plus trans.cc at that commit,
then repeats the complete implicit-flag setter and with-constructor census.
The source note separately handles copying, context mutation, guard conditions
and unit-key ranges; a textual census alone does not prove those properties.
It also checks 300 finite arithmetic compositions, including empty and
INT_MAX decoded lengths without allocating strings of those sizes.

No compiler, prover, native capture, solver, build or network access was
needed. Selected model/effort: GPT-6 Astra / Extra High. Runtime confirmation
and token/cost evidence are unavailable. Independent source review is pending.
