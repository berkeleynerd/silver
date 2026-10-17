# Ordinary producer object/theory evidence

Companion to [the derivation](../../research/retained-producer-objects.md).
The script compares nine complete source files with the retained SPARK archive,
records reviewed LF-numbered ranges, and checks local count/serialization
arithmetic. These checks do not execute GNAT, GNATprove, Lean or Silver and do
not establish source-to-helper invocation coverage.

```sh
python3 docs/evidence/retained-producer-objects-20261017/derive.py \
  --source-root /path/to/spark-source --output /tmp/producer-objects.json
cmp docs/evidence/retained-producer-objects-20261017/components.json \
  /tmp/producer-objects.json
```

The expected source revision is `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`;
its exact identity as the installed GNATprove archive's source remains a
separate premise. Theory imports and auxiliary representations remain separate
aggregate costs. No whole-program capacity threshold is claimed.
