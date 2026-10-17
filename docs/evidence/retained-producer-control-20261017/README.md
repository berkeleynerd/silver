# Producer Length/control evidence

Companion to [the local derivation](../../research/retained-producer-control.md).
The script compares eight complete source files with the retained SPARK archive,
also checking their existing producer manifest where present. It records hashes
and reviewed LF-numbered source ranges, then checks the local cost sums and
branch-observation serialization graph. It does not infer caller coverage or
execute GNAT, GNATprove, Lean or generated Silver programs.

From the repository root:

```sh
python3 docs/evidence/retained-producer-control-20261017/derive.py \
  --source-root /path/to/spark-source --output /tmp/producer-control.json
cmp docs/evidence/retained-producer-control-20261017/components.json \
  /tmp/producer-control.json
```

The expected source revision is `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.
Its exact identity as the installed GNATprove archive's source remains the
separate documented premise. These checks establish no admission threshold.
