# Selected literal MEM/SSA attachment evidence

Offline research #119, 2026-10-19, Linux x86-64. The
[source note](../../research/retained-literal-mem-ssa-attachment.md) records exact
accepted inputs, actual-source interface adaptation, guards, ownership and
remaining capacity obligations. Independent review of this attachment is pending.

- `compose.py`: new `Context`, `evaluate` and checked SSA source adapter around
  the accepted 149-guard lifetime wrapper. Actual core/query results feed the
  accepted MEM callable; the entire actual initial SSA owner is recomputed and
  checked before the reviewed zero-increment lifetime extension is attached.
- `inputs.json`: 25 complete accepted packet/note/review records. Nested source,
  configuration and ABI identities remain checked; MEM has 56/19 compiler/repo
  records and SSA has 24/8 plus 26 exact excerpts. Sets overlap.
- `check.py` / `check-results.json`: 269 new focused checks, five actual sources
  and nine count-only cases. All 149 inherited and 29 new false predicates are
  exercised. The retained-Hello SSA checker and predecessor suites never run.
- `result.json`: Hello generated once in the final affected check run, with
  all 178 guards and explicit partial scopes. No native observation is added.
- `round.json`: selected settings, exact implementation identities, measured
  evidence, checker-only rework and unavailable runtime/token/cost data.

With the retained source and selected ABI inputs:

```sh
python3 docs/evidence/retained-literal-mem-ssa-attachment-20261019/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --plugin-include /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include \
  --gcc-match /tmp/silver-backend-compose-20261018/folding-sources/match.pd \
  --output /path/to/new-check-results.json
```

The checker writes this new packet's Hello result; replay in an isolated
worktree to preserve frozen evidence. To evaluate another actual source,
use `compose.py` with the same four input flags and `--source FILE --output FILE`.
Its descriptor defaults to the accepted pipeline `selected-route.json`.

MEM5C, fixed437 and SSA6C+10+L retain their existing owners. Only
q(99+5C)-q(98+3C) register pointer backings are newly attached GGC events;
matching alignment requests and DF pools are ordinary storage. Hello retains
17 SSA events and DF60 blocks per generation/120 lifetime requests. Shared768,
partial2312 and location13 remain separate. Global GGC/imported totals remain
null; collector/native/proof/parent/full-current-grammar capacity remains open.
Oracle, tools/pins and production admission are unchanged. No native, build,
prover, solver, capture, large corpus or predecessor-suite run occurred.
