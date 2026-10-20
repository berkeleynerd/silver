# R58 post-inline preparation interface

The [research note](../../research/retained-why-postinline-preparation.md)
states the exact cut, source transfer, additional operation/Ident counts and
remaining scope. It covers builtin elimination and unused removal for all
three selected drivers, plus polymorphism detection for Z3/CVC5.

```sh
python3 -B docs/evidence/retained-why-postinline-preparation-20261020/check.py
```

- `inventory.py` / five `*-inventory.json` files add singleton/data/termination
  structure, new aggregates of frozen R54/R56/R57 results, and retained raw
  task-chain lengths. No first-inline/CE model or predecessor checker is run.
- `driver-inventory.json` connects exact common expanding and type-meta rules,
  and provides a deliberately loose finite bound for other driver additions.
- `compose.py` / `result.json` retain all per-root and per-stage charges. The
  allowances are separate from R57's first-inline-only 32 traversal units and
  share the original process-wide episode/e variables.
- `audit_sources.py` / `source-witnesses.json` retain exact source excerpts,
  including environment-dependent data positivity/foundness validators.
- `inputs.json`, `check-result.json` and `round.json` record inputs, finite
  verification and selected model/effort; runtime and token/cost data are not
  invented.

Returned contexts reuse R57's complete hidden-map/type envelope. Unique goals
retain their per-root R56 candidate envelope, including nonleaf saved images.
These stages introduce no new formula body; generated Dparams reuse their
physical heads, and detection adds one empty meta. Successful old returns and
both task-prefix rebuilds are covered.

Failed collision comparands, primitive costs, initial counters plus later
demands and later transformations/printing remain separate. Native runtime
resources are unpriced; there is no new aggregate RAM gate or requirement to
prove allocator internals. No production, Oracle, tooling, admission, global
session memory or publication action is part of this packet.
