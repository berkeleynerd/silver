# Retained inlining comparator capacity

2026-10-18, Linux x86_64, research #119. The
[source argument](../../research/retained-why-inline-comparand-capacity.md)
attaches bounded source work for successful and unsuccessful declaration
comparison, definition closing, shallow term similarity and strict hashing to
the reviewed retained representative state. Earlier packets remain unchanged.

```sh
python3 -B docs/evidence/retained-why-inline-comparand-capacity-20261018/check.py
```

This is an offline check. It starts no native target, debugger or prover.

- `profile.py` classifies all 6,704 initial objects with the comparator's actual
  kind/first-symbol preconditions. It inspects every stored term, unused saved
  value, map, attribute, location and constant in the 145 possible old formula
  comparands and all 143 input formulas. Its separate frame walker includes
  triggers and repeated edges.
- `capacity.py` supplies pure strict-comparison, strict-hash and no-resize
  transfers. Numeric arguments alone never certify retained-state coverage.
- `compose.py` joins that projection and those transfers to the accepted local
  representative envelope and demand vector. `result.json` and `details.json`
  freeze the compact result and per-comparand calculations.
- `inputs.json` pins reused state/model/source inputs. `sources.tar.gz` retains
  complete cited files and licenses, including the constant/location/map/list
  implementations. The complete prior capture is reused from its frozen path.
- `check.py` tests prefix-before-length behavior, an omitted object, an unused
  custom saved value, frame consumption, numeric propagation and the first
  resize threshold. `round.json` records the selected worker, elapsed time,
  diagnostics, check timing and independent-review scope.

Strict table comparison has at most 145 calls and 2,032 term-pair entries;
81 definition-close checks add 418 entries. Strict candidate hashing has at
most 1,911 term entries. The retained table cannot resize in these 142 merges;
its outer length stays 5,003 and bucket length is at most 226.

These are conservative source-operation and representation bounds, not native
time, total allocation or RAM measurements. Other shared tables/counters,
runtime primitive lowering/allocation/GC, other entries and downstream capacity
remain open. No complete transformation or whole-pipeline verdict is asserted.
