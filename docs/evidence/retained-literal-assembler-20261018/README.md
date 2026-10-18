# Literal Main assembler/object interface

The [source argument](../../research/retained-literal-assembler.md) extends the
reviewed null GAS/ELF interface using the literal-output source counters. It
reuses pinned complete Binutils sources in the earlier assembler packet and
the reviewed native final-RTL and constant-data interfaces. `inputs.json`
binds those dependencies. No native tool is run by this packet.

Replay from the repository root:

```sh
python3 docs/evidence/retained-literal-assembler-20261018/check.py --output /tmp/literal-assembler.json
```

`result.json` retains source examples and local arithmetic/field checks. The
32,767/32,768-call pair exercises the derived sufficient alignment-region bound;
it is not a measured assembler maximum. The entire assembler allocation
lifetime, invocation and final-link joins remain open. Passing this local
interface does not admit a program to Silver or establish whole-tool capacity.

Author: lead session; no lead model/effort switch claimed. Token/cost totals and
isolated authoring elapsed time unavailable. Independent review is recorded
separately against its exact commit. Native executions: zero.

The subsequent [storage composition](../../research/retained-literal-assembler-storage.md)
uses `storage.py` and `storage-inputs.json` to join variable GAS hashes/notes
and output-BFD/string-table storage. Replay its retained `storage-result.json`
with `check-storage.py --output /tmp/literal-assembler-storage.json`. This
extension preserves the reviewed stream/object packet and its review target.
Production invocation and the other whole-pipeline joins remain separate.
