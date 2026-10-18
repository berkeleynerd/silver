# Original Main allocation/request transfer

The [source argument](../../research/retained-literal-original-main-storage.md)
defines scope, the conditional source ledger and every remaining join. This
packet adds no production admission. `derive.evaluate(lengths,N,D,I)` takes
decoded literal lengths, source null count, distinct called procedure count
and the fixed implicit-with visit count outside the Main-only source bound.
Omitting I preserves it symbolically; no sample supplies that missing premise.

From the repository root:

```sh
python3 docs/evidence/retained-literal-original-main-storage-20261018/derive.py \
  > docs/evidence/retained-literal-original-main-storage-20261018/result.json
python3 docs/evidence/retained-literal-original-main-storage-20261018/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output docs/evidence/retained-literal-original-main-storage-20261018/check-results.json
```

`inputs.json` binds complete source files at the retained GCC revision and
the exact repository predecessor inputs. The C++ Ada bridge sources in the
separate Ada tree were checked equal to their full-source copies before
freezing; Ada implementation files use their retained complete-source manifest.
The matcher file is bound through the repository ingress predecessor manifest;
this packet reuses that selected pointer/address closure, not a new generic
matcher theorem. Arithmetic checks exercise the written transfer and its
interfaces; source reasoning remains necessary and independent review is
pending. Native compiler/prover/build/full-suite validation was neither
authorized nor performed in this research subthread.

The selected model/effort was GPT-6 Astra / Extra High. Runtime confirmation
and token/cost measurements are unavailable. The final `round.json` records
wall-clock information without inventing historical measurements.
