# Five fresh save-state applications

The [research note](../../research/retained-why-save-state-join.md) states the
result and remaining obligations. This packet contains the five successful
`*-correspondence.json` files, five successful `*-replay.json` files,
`join.py` and its deterministic `result.json`. Raw captures are retained in the
[capture packet](../retained-why-save-state-capture-20261020/README.md).

Put_Line's successful correspondence was run by the collector author while
repairing the detected custom-operations relocation mismatch; the root retained
that success without repeating it. Root ran the other four comparisons and all
five extension replays. No successful binder, alpha or old observer analysis
was rerun. The frozen collector and comparison implementation live in
[the missing-state packet](../retained-why-save-missing-state-20261020/README.md).

`join.py` checks projection hashes against both the saved correspondence and
byte-identical replay; joins the old process/graph/certificate identities to the
accepted shape transfer; checks new captured attempt/forest/argument/script
counts against the source growth inputs; then computes conditional arithmetic.
The decoded snapshot never becomes a bound on all later entries by itself.
Missing serializer/native inputs remain null and complete-save/pipeline flags
remain false. Native prefix-table premises are separately visible even when
the numerical guard passes.

To repeat only this inexpensive numeric join with local captures:

```sh
python3 -B docs/evidence/retained-why-save-state-join-20261020/join.py
```

For a portable check, first use the capture packet's safe extraction into a
new directory, then supply its two roots:

```sh
python3 -B docs/evidence/retained-why-save-state-join-20261020/join.py \
  --registration /path/to/extracted/registration \
  --inline /path/to/extracted/inline
```

The default command compares its result to retained evidence; `--write` is
reserved for an absent first result and refuses to overwrite one. Repeating
graph comparisons or extension replays is unnecessary for this arithmetic
check. Its bounds are conditional research results, not an admission predicate.
