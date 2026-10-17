# Retained-value capacity component evidence

Research for #119 on 2026-10-17. See the
[derivation and limits](../../../research/retained-value-capacity.md).

`derive.py` verifies 34 selected source files against the previous complete
GCC Ada-tree manifest for commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
It then produces component allocation arithmetic, String discriminators and
textual parser-rescan/String-allocation inventories in `components.json`.
The output contains source hashes and exact upstream URLs. Line numbers count
LF; form feeds do not add source lines. The textual inventories include comments
and are explicitly not an exhaustive, resolved call graph.

Reproduce from the repository root, with the pinned GCC Ada subtree extracted
outside the checkout:

```sh
python3 docs/evidence/unbounded-programs/retained-value-capacity-20261017/derive.py \
  /path/to/gcc/ada --output /tmp/retained-value-components.json
cmp docs/evidence/unbounded-programs/retained-value-capacity-20261017/components.json \
  /tmp/retained-value-components.json
```

The generator checks 3,885 bounded base/exponent discriminators against exact
integer arithmetic. Its bound algorithm uses saturated powers and small exponent
counters, not materialized large values. The separate arithmetic cross-check
does construct powers through the proposed exponent maximum; these are at most
3,199,997 mathematical bits each and are checked serially. Python representation
and allocator overhead are additional.
This is an arithmetic probe, not a compile/build/proof or near-limit allocation
experiment. No installed tool or canonical proof workspace is modified.

The charges cover specified allocation events and one successful integer-token
scan under the stated premises. The record also derives at most two literal
scans per successful Main parse under the unchanged grammar; independent source
review covered its caller paths and disjointness. Dependency scans and semantic
events remain separate. These are not a complete whole-program capacity
rule, a new admission threshold, or measured native consumption. The current
language and all production/proof source remain unchanged.

The subsequent native scalar component gives local node/list/entity event
charges for already resolved nonstatic Integer operators under its explicit
expansion preconditions. It does not price semantic folding or generated helper
contexts. Its constants are a source derivation, not a measured multiplier.

The scalar range-inference component separately bounds temporary endpoint
magnitudes and local Uint work. Arithmetic discriminators cover normal/reversed
endpoint pairs, negation, addition, subtraction and multiplication, including
disjoint computed bounds larger than Integer. These mathematical checks do not
establish the number or caller coverage of frontend range queries.
