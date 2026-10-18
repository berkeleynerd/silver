# Literal-output GPRbuild parent DW reader evidence

Offline component for [#119](https://github.com/berkeleynerd/silver/issues/119).
The [source argument](../../research/retained-literal-gpr-parent.md) identifies
the fresh three-job frontend schedule, exact DW/W policy and retained state.
The callable bounds the named reader under explicit incoming descriptor and
child-ALI interfaces; whole native parent and literal pipeline remain open.

```sh
python3 docs/evidence/retained-literal-gpr-parent-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output /tmp/literal-gpr-parent-checks.json
cmp docs/evidence/retained-literal-gpr-parent-20261018/check-results.json \
  /tmp/literal-gpr-parent-checks.json
```

`compose.py` provides `Context(ada_root)` and
`evaluate(raw, context, path_bytes=512)`. Its CLI accepts `--ada-root`,
`--source FILE`, `--path-bytes N`, and `--output FILE`; source defaults to
Hello World. It invokes the accepted literal-ALI/consumer callable, including
its complete-source checks and retained local fixed-capture requirements.
It does not launch a compiler, native GPR, prover, binder or test suite.

- `inputs.json` pins ten direct predecessor/source records; their transitive
  pins are checked by the accepted callable.
- `sources.tar.gz`/`sources.json` retain three additional complete sources with
  hashes, source revisions and original paths. The other consumer and option
  sources are reused from the pinned 151-member binder and 29-member split
  capsules. Hash anchors supplement the companion source argument.
- `result.json` and `check-results.json` contain the actual offline outputs.
- `round.json` distinguishes selected model settings from unavailable runtime
  confirmation and records elapsed time; independent review belongs to the
  later frozen-commit review.

The fixed-child raw bound replaces all retained A bytes with the selected
nine-row/129-byte envelope; retained Xref bytes remain charged even if removed
by the selected no-Xref option. The later launcher must establish that stored
switch inventory and the explicitly stated non-A regeneration interface.
The result exports persistent GPR.Names events/value bytes with an incoming
contract, not complete shared-vector storage or aggregate RAM admission.
