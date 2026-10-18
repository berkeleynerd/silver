# Literal Main ALI interface replay

Source argument: [retained-literal-ali.md](../../research/retained-literal-ali.md).
This packet scans actual literal-output source, checks the retained serializer
inputs and selected switch projection, and reuses the established ALI formulas.
It launches no native tool and is not an admission rule or complete binder result.

```sh
python3 docs/evidence/retained-literal-ali-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output /tmp/literal-ali-checks.json
```

`compose.py` takes the same Ada root, `--source FILE`, `--path-bytes N`, and
`--output FILE`. Defaults select Hello World and P=512. `result.json` and
`check-results.json` retain the offline outputs; `inputs.json` pins the reused
packets. The underlying model verifies its existing complete-source manifest.
Absolute retained fixed-capture paths and their checked content remain local
replay requirements. No new compiler, binder or GPR witness is claimed.
