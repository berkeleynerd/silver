# Literal/fixed-output ALI consumer evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119).
Read the [source argument](../../research/retained-literal-binder-ali.md)
for the conditional local-consumer claim and explicit name-pool, graph,
driver and launch gaps. Independent review is pending.

From the repository root:

```sh
python3 docs/evidence/retained-literal-binder-ali-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output /tmp/literal-binder-ali-checks.json
cmp docs/evidence/retained-literal-binder-ali-20261018/check-results.json \
  /tmp/literal-binder-ali-checks.json
```

- `compose.py`: callable `Context(ada_root)` and
  `evaluate(source_bytes, context, path_bytes=512)`. Reuses the accepted
  complete source recognizer/writer interface and derives the fixed closure
  census from hashed archive bytes. Its CLI also accepts `--source FILE`,
  `--path-bytes N` and required `--output FILE`.
- `inputs.json`: exact predecessor identities, including the consumer source
  archive, output closure archive, accepted ALI callable and its review.
  Existing complete source/member hashes are checked; no native inventory
  or successful expensive run is repeated.
- `result.json`: complete Hello result, P=512.
- `check.py`, `check-results.json`: fourteen offline cases, including the
  8,192-byte literal and 5,000-call inputs and the inherited path boundary.
- `round.json`: selected settings, implementation elapsed time and handoff.

All required examples pass `selected_ALI_consumer_local_interfaces_fit`.
This boolean covers local table/buffer/payload checks and exported additive
contracts, not complete shared name pools or the binder. Whole-binder and
whole-pipeline fields remain false. Native parent GPRbuild's D/W reader is a
distinct open join; `Gprbind_Main_reader` covers only Gprbind's A/U read.
The separate 5,000-call linker sufficient
bound remains failing; this packet neither reruns nor overrides it.

The accepted ALI adapter's Ada source root and content-checked fixed-capture
paths remain local replay prerequisites. All new validation is offline Python
on Linux x86-64. No compiler, binder, GPR, prover or other native tool ran.
No aggregate RAM gate, production rule or new successful native witness is
claimed.
