# Actual-source register completion packet

This packet supports [the source/composition note](../../research/retained-literal-register-completion.md)
for #145/#119 and the four-event correction #146. It contains the current
408-condition adapter, 28 exact predecessor/review pins, a retained actual
Hello result and focused source/failure/collector-boundary checks.

`compose.py` uses the accepted recognition evaluator on the supplied complete
source descriptor. It computes outer IRA and LRA arithmetic from those actual
counts, adds the disjoint cold probe row and recomputes collector capacities.
`predecessor_result` is historical evidence; its 50-row GGC completeness claim
and total are superseded by the current result. The correction changes no
finalizer, pseudo, instruction UID or chain owner.

Canonical reproduction, from this checkout:

```sh
mkdir -p tmp/register-completion
TMPDIR="$PWD/tmp/register-completion" python3 \
  docs/evidence/retained-literal-register-completion-20261019/compose.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --plugin-include /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include \
  --gcc-match /tmp/silver-backend-compose-20261018/folding-sources/match.pd \
  --output tmp/register-completion/result.json
```

Use `check.py` with the same four source arguments and an output path to run
the 55 focused checks. `compose.py` also accepts `--source` and `--descriptor`.
The retained successful checks need not be replayed merely to read this packet.
No source capacity verdict is a complete native or whole-pipeline verdict.
Production source correspondence/verification and admission remain separate.
