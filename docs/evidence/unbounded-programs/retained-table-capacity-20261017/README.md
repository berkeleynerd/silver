# Retained-table capacity evidence

The [component derivation](../../../research/retained-table-capacity.md) explains
the arithmetic, its premises and the unresolved source-to-event bound for #119.
This is research tooling, outside production/proof inputs.

Reproduce from the checkout root with the retained pinned GCC Ada subtree:

```sh
python3 docs/evidence/unbounded-programs/retained-table-capacity-20261017/derive.py \
  /path/to/gcc/ada /tmp/retained-table-arithmetic.json
cmp docs/evidence/unbounded-programs/retained-table-capacity-20261017/arithmetic-and-inventory.json \
  /tmp/retained-table-arithmetic.json
```

The generator verifies the top-level Ada source file set and SHA-256/Git blob
hashes against the previously retained complete pinned-tree manifest. It rejects
missing, added or altered inventory inputs. Thirteen directly cited files have
hashes repeated in its output; the other top-level files contribute to the lexical
`Table.Table` inventory. LF determines source lines, including in files with form
feeds. This textual inventory includes comments and is not a resolved call graph.

Validation on Linux used source inspection, integer arithmetic, identical
regeneration and whitespace checking. An independent review found no material
issue in the component; its suggested explicit zero-slot one-past explanation
was included. The review covered allocator arithmetic and local accounting,
not a whole-program capacity rule. That checkpoint had no compiler, GNATprove,
Lean, full suite, macOS or CI execution. Successful reproduction does not justify
expanding admission or complete #119.

A subsequent independent review checked the demand-only capacity envelope,
including release/save/restore, stale `Max` on the first growth iteration and
zero-length release. Its two requested clarifications are incorporated: the
low bound may be negative, and the backing sentinel must fit the actual index
subtype as well as signed Int. The bound is proved by the operation induction
in the record; finite arithmetic discriminators are corroboration.

## Pinned node-layout generation

`generate_node_layout.py` verifies all eleven standalone `Gen_IL` source inputs,
builds that generator with the selected `gnatmake`, executes it and extracts the
generated size tables. Use a fresh writable output directory; prior runs are
never overwritten. Run through the managed `dev.py tool` interface, declaring
the script/source inputs and output workspace, as recorded in `node-layout.json`
and managed run `20261017T231847-6bca937e079b`. The standalone equivalent inside
the selected Alire tool environment is:

```sh
python3 docs/evidence/unbounded-programs/retained-table-capacity-20261017/generate_node_layout.py \
  /path/to/gcc/ada /tmp/fresh-node-layout-workspace
```

The retained JSON includes exact commands, source/output hashes and all size
entries. `build.log`, `generator.log` and `compiler-version.txt` preserve the
observed generator build and execution. This was a 7.127-second native Linux
research run with one worker, assertions and overflow checks enabled. It did
not build or replace GNAT/Silver, run GNATprove/Lean, establish installed-tool
layout identity, or derive a source-to-event bound. The report explains both
the exact 9/61 dynamic-slot maxima and the weaker 997-slot source-type envelope.
