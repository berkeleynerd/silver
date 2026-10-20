# Selected solver task language

This packet supports the scoped [source inclusion argument](../../research/retained-solver-task-language.md).
It reuses the accepted five-input/driver/helper relation and retains no newly
generated SMT task or runtime observation.

`driver-census.json` contains all 14 driver identities, ordered expanded syntax
and prelude records, symbolic holes and nesting depths. Two Float80 templates
have a positive nesting surplus; the packet does not repair them or assert
solver acceptance. `input-census.json` checks all decoded JSON strings, library
meta names and selected path joins. `source-witnesses.json` supplies exact
source identities/excerpts and supplementary reference inventories. `result.json`
exports the source argument's scoped command envelope, keeping all q/O fields
null. These exports are not mechanically proved by the checker.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-solver-task-language-20261020/check.py
```

The checker verifies pinned repository inputs and exact retained archive members,
lexes fixed driver strings/comments, checks import edges and command/template
structure, joins the already attached five cases, and runs narrow negative
controls for its lexer/structure checks. It executes no native target, solver,
proof suite or predecessor checker and fetches no source. `--write` regenerates
only this packet's deterministic products. The source induction and its selected
reachability assumptions require review; lexical counts alone do not prove them.

`round.json` records selected author settings and actual elapsed time separately
from unavailable runtime model/effort confirmation and token/cost telemetry.
`check-results.json` retains the focused final check. The independent review
comes after the author freeze and is not fabricated here.
