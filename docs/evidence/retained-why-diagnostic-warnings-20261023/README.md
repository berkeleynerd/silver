# Retained GNAT warning-output bound

Author lane for #119 / #153, 2026-10-23 UTC. Read the
[source argument](../../research/retained-why-diagnostic-warnings.md).

- `bounds.json`: per-process whole-interval W_o/L_o and their standard JSON
  byte/event contributions. Canonical-output rows at X=0 are partial only.
- `native-projection.json`: exact GNAT JSON identities, scalar leaves, loop
  multiplicity and source-location domain.
- `library-projection.json`: all21 initial source identities, syntax
  opportunities, later clone-target abstract witnesses and reused parse counts.
- `warning-census.json`, `source-witnesses.json`: complete reference scan and
  exact source spans. Semantic reachability and opportunity injection are in
  the note; lexical counts alone are insufficient.
- `inputs.json`: frozen providers and retained source archives.
- `check.py`, `check-result.json`: passed focused check, after the interface-only
  census correction recorded in `round.json`; no predecessor replay,
  native execution, compiler, solver, proof, capture or fetch.
- `round.json`: selected settings, timing and scope.

One e<=2 applies to the whole process, with two save-entering callbacks and
three saves. W_c/L_c, final D/H, terminal X and raw solver q are separate.
Private Loc formatter construction remains outside the output-length claim.
Ordinary physical resources retain their existing trust boundary.
