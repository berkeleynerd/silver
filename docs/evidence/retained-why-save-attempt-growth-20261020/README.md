# Later proof-attempt and metadata growth packet

2026-10-20, #119 / #153. Read the
[source argument](../../research/retained-why-save-attempt-growth.md).

The packet derives later A_stats/A_xml bounds 208/173/108/12/9 from the five
captured starts, selected-pair key domain and two possible exceptional
insertions. A spurious caught Not_found can invalidate the normal scheduler's
once-per-pair entry argument; this packet does not extend that entry theorem or
infer attempt-ID counter headroom from binding growth. It also preserves
T=1, Args=0 and empty proof scripts, and derives persistent prover/status-cache
growth. It identifies the theory-status resize that can defeat a size0=0,
capacity0=16 no-resize application for the first three forests. Native table
representation and the continued signal contract remain
explicit application conditions. Combined independent review is lead-owned.

The application conditions are the accepted fixed source/layout and selected
route; preserved logical forest and no unmodeled metadata mutator; no covered
mutator suspended at the chosen cut; valid actual entry chains/keys with the
native commit/no-resize (or other proved resize) contract; and the same
single-worker signal/native-effect condition continuing across the entire
post-cut interval. `signal_contract=True` in the retained applications assumes
that last condition for arithmetic. `table_contract` stays false and entry
table words stay unknown. Closure presence does not prove no earlier signal
save. The generic transfer exposes both flags separately and defaults both to
false; no successful Python check turns either into native evidence.

- `inputs.json` pins the accepted captures' derived inputs, scheduler result,
  source archive and relevant arguments/reviews.
- `source-excerpts.json` retains full-member identities and literal source
  ranges; `source-census.json` retains the reproducible reference/mutation
  census of the named modules. Neither is a machine-proved call graph.
- `transfer.py` keeps source growth, actual starting table state and native
  application flags separate. It never substitutes zero for absent table words.
- `applications.json` joins each captured process/input to its scheduler row
  and computes its conditional source envelope without rerunning the capture,
  binder interpreter, alpha opener or accepted predecessor checkers.
- `check.py` verifies identities, source projections, the concrete joins and
  focused repeated-visit, duplicate-key, unknown-state and no-resize boundaries.
- `result.json` and `round.json` retain the new check and round measurements.

From the repository root:

```sh
python3 -B docs/evidence/retained-why-save-attempt-growth-20261020/check.py \
  --output /path/to/new/result.json
```

Authoring uses `build_packet.py`, then `check.py --write-applications --output
...`; ordinary checking does not rewrite inputs/applications. All source bytes
come from an existing retained archive. No native target, compiler, prover,
solver, debugger, source-fetch or network command is launched. The checker
verifies projections and arithmetic; source-semantic and native refinement
remain the named reviewed premises, not a claim made by successful Python.
