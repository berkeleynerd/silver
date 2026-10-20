# CVC5 output-capacity source packet

Research for #119 / #153 on candidate CVC5 revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`, base Silver commit
`3042c7431f3f82a4ddde9fd9df56e5729ff7258e`.

The [research note](../../research/retained-cvc5-output-capacity.md) states the
conditional component bounds and unresolved complete-output obligations.
`q_cvc5` and weighted O deliberately remain null.

- `identity.json` pins the exact fetched archive URL/hash, reused archives and
  driver/Why3 source members. `cvc5-source.tar.gz` retains the full exact
  upstream archive, including source-generation inputs. `reused-sources.tar.gz`
  retains complete selected driver/configuration and Why3-printer files.
- `check.py` checks those identities, matches the five previously retained
  CVC5 files, checks source anchors/defaults, inventories direct registration
  calls, extracts finite histogram spelling tables and checks byte arithmetic.
  It performs no native tool execution or network access.
- `registration-sites.json` is a lexical inventory, not a C++ reachability or
  dynamic registration-count proof. `result.json` records source file identities,
  derived metrics, conditional formulas and null whole-output exports.
- `round.json` records selected settings, elapsed evidence and limitations.

Run from the repository root:

```text
python3 docs/evidence/retained-cvc5-output-capacity-20261020/check.py
```

`--write` regenerates the two derived JSON files. No solvers, compilers, proof
runners, tool installs, configuration changes or GitHub writes occurred in
this subthread. Candidate source identity and the separately inventoried
binary's embedded build identity do not establish executable resolution or
binary/source semantic correspondence. No whole-solver, runtime-service or
automatic-discharge proof is claimed. Parent integration owns independent
review and any issue/session-memory update.
