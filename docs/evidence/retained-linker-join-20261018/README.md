# Selected null linker numerical join

Supports [the composition record](../../research/retained-linker-join.md)
for #119. `inputs.json` pins18 earlier source-derived component results and
input inventories. `binder-object.json` retains the immutable projection
from commit98fe62e588 with its originating full-record digest. Parent review
checked the projection equal after commit450230c95c added Gprbind runtime
buffer metadata. `binder-object.elf` is the previously retained13432-byte
object, whose SHA256 equals that projection. Parsing its EH entries establishes
one CIE and five FDEs; the accepted object-shape transfer supplies the family
argument. No generated object is executed or freshly produced by this join.

```sh
python3 docs/evidence/retained-linker-join-20261018/check.py --output /tmp/retained-linker-join-replay.json
```

The replay computes the count, name, payload and conditional layout arithmetic;
`result.json` records its output. It executes no native tool and does not prove
the source control-flow arguments. The effective4096-byte alignment and EH
alignment8 remain incoming premises, while mapping convergence, relocation
operands and auxiliary allocations are explicitly unfinished.
