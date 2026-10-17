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
not a whole-program capacity rule. No compiler, GNATprove, Lean, full suite,
macOS or CI execution occurred. Successful reproduction does not justify
expanding admission or complete #119.

A subsequent independent review checked the demand-only capacity envelope,
including release/save/restore, stale `Max` on the first growth iteration and
zero-length release. Its two requested clarifications are incorporated: the
low bound may be negative, and the backing sentinel must fit the actual index
subtype as well as signed Int. The bound is proved by the operation induction
in the record; finite arithmetic discriminators are corroboration.
