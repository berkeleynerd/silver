# Selected library call evidence

Companion to [the local derivation](../../research/retained-producer-calls.md).
The script verifies thirteen inspected SPARK source files against the retained
archive, records the five current Silver library input hashes, and checks local
constructor/serialization arithmetic. It does not execute a compiler or prover,
prove invocation coverage, or establish installed producer source identity.

```sh
python3 docs/evidence/retained-producer-calls-20261018/derive.py \
  --source-root /path/to/spark-source --output /tmp/producer-calls.json
cmp docs/evidence/retained-producer-calls-20261018/components.json \
  /tmp/producer-calls.json
```

SPARK revision: `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Fixed library
translation, symbols, theories and auxiliary representations remain separate
costs. Changes to selected library contracts invalidate the relevant branches.
