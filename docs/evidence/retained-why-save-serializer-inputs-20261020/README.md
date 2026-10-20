# Raw serializer string input extraction

The [research note](../../research/retained-why-save-serializer-inputs.md)
defines U, the conditional candidates and the exact unresolved restored-path
premise. `result.json` retains five per-object/occurrence inventories, exact
selected-prover configuration mappings, input lineage and source excerpts.
Unknown whole-continuation U and scalar/formatter/native bounds remain null.

Run the bounded offline check from the repository root:

```sh
python3 -B docs/evidence/retained-why-save-serializer-inputs-20261020/extract.py
python3 -B -m unittest discover -s docs/evidence/retained-why-save-serializer-inputs-20261020 -p 'test_*.py' -v
```

No historical local capture directory is required. The extractor reads selected
members from the accepted capture archives, verifies their manifest identities,
and joins the accepted repaired state-join and growth results. It checks saved
comparison/replay raw-input identities without redoing either computation.
Source excerpts come only from the retained helper-source archive and are
checked against its source-identities manifest. No native target, solver,
capture, observer replay, binder/alpha computation, proof or network request is
started. `--write` creates an absent first result and refuses to overwrite one.

`test_extract.py` checks meaningful boundaries: a repeated goal edge contributes
another output occurrence; qualified components gain dots; absent restored
bindings remain null with no future-bound claim; and changed archive-member
identities are rejected. `round.json` records selected settings and measured
verification evidence. Independent review is pending lead integration.
