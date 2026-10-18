# Configured import-context evidence

Source analysis for research #119, 2026-10-18, Linux. No native compiler,
Why3, solver or Lean process ran. The source argument and limits are in
[retained-producer-import-context.md](../../research/retained-producer-import-context.md).

`sources.tar.gz` retains 67 complete files: the installed configuration,
26 driver files, 21 library files, the pinned native configuration writer,
and Why3 source for loading, caching, typing, cloning and warnings.
`identity.json` hashes every file and the already retained five native JSON
inputs. Installed bytes and candidate upstream source are behavior premises;
no binary/source attestation is claimed.

Run the offline checker:

```sh
python3 docs/evidence/retained-producer-import-context-20261018/check.py
```

It computes the import closure from all nine configured driver roots, checks
native roots/clones, checks the exact fixed syntax frontier, and calculates
source clone-dependency coefficients and clone-warning counts. Nested comments,
quoted paths, attributes and comma-separated uses are handled; all current
modules use the asserted column-zero header/end convention. `result.json`
retains the full graph so additions cannot silently remain outside the cost
account. Lexical pieces are the checker's source decomposition, **not** Why3
tokens, typed nodes, allocation counts or a proof execution.

The report's source argument still owns cache sharing, warning-call
multiplicity and the six startup VC constructions. Fragment assertions guard
drift and do not formally verify Why3. Full typed-term/identifier costs,
runtime transformation dependencies, solver representation/output, lifetime
counters and complete native reports remain separate joins.
