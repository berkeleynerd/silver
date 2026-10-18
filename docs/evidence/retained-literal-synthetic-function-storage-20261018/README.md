# Literal synthetic function storage evidence

Research [#119](https://github.com/berkeleynerd/silver/issues/119), 2026-10-18.
Read the [source argument](../../research/retained-literal-synthetic-function-storage.md)
for the scope, constructor partition, request derivation, folding closure,
release lifetime and integration obligations. Independent review is pending.

- [derive.py](derive.py) exports [interface.json](interface.json): 167 direct
  GGC events (13,336 caller-byte sum; 17,216 per-object rounded-slot sum),
  eight ordinary requests (584 caller bytes), identities and shared demand.
- [source-manifest.json](source-manifest.json) pins 44 GCC source files and
  26 historical Silver inputs at `a409ff9db1e7a290bc12dd415d0d9518c93e4652`.
  Two source files were additionally compared with raw upstream bytes at
  GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the manifest identifies them.
- [matcher-flat-patterns.json](matcher-flat-patterns.json) records 138 flat
  or optional-conversion-only simplify patterns. It supports the handwritten
  case audit; it does not resolve operator lists, interpret C++ predicates,
  or prove folding closure by text matching.
- [check.py](check.py) and [check-results.json](check-results.json) retain
  36 passing offline source identity, landmark, shape and arithmetic checks.

Run from the repository root:

```sh
python3 docs/evidence/retained-literal-synthetic-function-storage-20261018/check.py
```

Optional `--gcc-root`, `--ada-root` and `--matcher` arguments select the pinned
source locations. `--output PATH` records a new check result; the checker does
not fetch network inputs or execute a compiler. Native runs: **zero**.
These checks do not replace the handwritten argument or the inherited
installed-source correspondence premise.

The included interval starts with frozen declarations and bodies. Original
Standard/helper/elaboration construction, two cgraph nodes and symbol-map
backing, identifier-table growth, collector pages/finalizer backing and
ordinary allocator metadata are not included. The ten identifier insertions,
two singleton finalizers, context-pool high water and cfun-stack demand are
explicit integration inputs. Existing charges for the same shared context
or cfun-stack allocation must be deduplicated by ownership.

Selected worker: GPT-6 Astra / Extra High. Runtime setting confirmation and
token/cost data are unavailable. Round start: 2026-10-18 20:32:36 UTC; the
retained checks completed at 20:49:29 UTC (about 17 minutes later), followed
by documentation/diff inspection. Independent review remains pending; the
source case audit was performed by the implementing worker. No production,
aggregate, GitHub or CLI memory files were changed in this packet.
