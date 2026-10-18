# Literal-output RTL evidence

Offline source/identity/arithmetic evidence for
[#119](https://github.com/berkeleynerd/silver/issues/119). The
[companion source argument](../../research/retained-output-rtl.md) derives
the effect of the stock `-fsplit-wide-types` option, caller-register allocation,
the selected LRA exit, frame/CFI shape and instruction text counts. It preserves
the independent lifetime-allocation, option-storage, assembler/linker and
producer obligations. No current admission limit changes.

Replay from any checkout containing this packet:

```sh
python3 docs/evidence/retained-output-rtl-20261018/check.py \
  --output /tmp/retained-output-rtl.json
cmp docs/evidence/retained-output-rtl-20261018/result.json \
  /tmp/retained-output-rtl.json
```

- `inputs.json`, `native-entry.json`, `native-source-inputs.json`: immutable
  bytes from the native lane's `e0cffc2baa` interface, with original Git paths.
- `manifest.json`, `sources.tar.gz`: 69 complete source files from the retained
  GCC source revision, including the complete local x86 MD file set; exact
  source hashes are reconciled with the overlapping predecessor pins.
- `check.py`, `result.json`: identity and arithmetic replay, selected source
  landmarks, conservative availability across all four-pseudo allocation orders
  and hard-argument conflict subsets, composition and local signed boundaries.

The Python checker does not execute or model the entire compiler. Source path
interpretation and the generic target's cost/constraint/liveness arguments
are manual claims in the companion document. A matching archive or a successful
arithmetic check alone does not establish those claims. No new compiler,
assembler, linker, GNATprove, solver or Lean execution belongs to this packet.
An exact selected-option witness has not been run. Earlier default-option
results are not silently reclassified as split-option executions.
