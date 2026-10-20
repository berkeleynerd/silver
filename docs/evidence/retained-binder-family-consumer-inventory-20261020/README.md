# Retained binder-family consumer inventory

Research #119 / #150 L4, 2026-10-20. Read the
[source argument](../../research/retained-binder-family-consumer-inventory.md).
Independent review is pending. Historical packets and pins are unchanged.

The packet retains writer/reader/serializer ranges for P, restrictions, SS and
U fields, plus relevant fixed auxiliary inputs. Source casing and Main RV lines
need not be byte-identical: the argument identifies inactive consumers and
fixed closure merges. The exported binder interface is a retained-family
transfer, not a measurement of a binder generated from evaluated source.

- `inputs.json`, `source-inputs.json`, `sources.tar.gz`: exact predecessor and
  complete selected source identities, including full pinned `bindgen.adb`.
- `consumer-inventory.json`, `bindgen-occurrences.json`, `source-excerpts.json`:
  inspected semantic rows, full-file consumer-token census and literal ranges.
- `fixed-ali-projection.json`, `restriction-partition.json`: all 82 fixed ALIs'
  relevant fields and the complete restriction enum partition.
- `build_inventory.py`, `check.py`, `result.json`: deterministic retention and
  focused source/census checks. The checker executes no native/evaluator or
  predecessor checker. It does not machine-prove source semantics.
- `round.json`: scope, selected model/effort, elapsed time and rework.

From the repository root:

```sh
python3 -B docs/evidence/retained-binder-family-consumer-inventory-20261020/check.py
```

No existing capacity formula is revised or replayed. The new source capsule
copies already retained source bytes; `restrict.adb` was copied from the local
pinned checkout and checked against the accepted frontend source digest.
