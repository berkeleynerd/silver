# Fresh selected Format core evidence

Read the [source argument](../../research/retained-why-save-formatter-core.md)
for the induction and its exact premises. This packet supports core integer
arithmetic, queue/stack length and offered XML byte bounds, not complete
formatter/save capacity. All actual premise flags remain false.

`source-witnesses.json` contains exact ranges from retained pinned archives;
`native-bodies.json` contains selected installed bodies from the already retained
disassembly. `check.py` rechecks excerpts against archives, instructions against
ELF load segments, exact arithmetic boundaries, missing-premise rejection and
the five candidate applications. Native bytes corroborate the selected route
under the recorded external behavior relation; no full binary refinement is
claimed. `inputs.json` pins these files and imported evidence.

Run from any directory:

```sh
python3 docs/evidence/retained-why-save-formatter-core-20261020/check.py
```

The command reads the installed Linux executable; it does not execute it.
No source fetch, target/capture/disassembler/proof/solver or broad prior-checker
replay occurred. Native address and executable identity are in
`native-witnesses.json`. Lead live model/effort and individual token/cost
measurements are unavailable. Independent review belongs to the aggregate
Round 30 checkpoint, whose acceptance is not assumed here.
