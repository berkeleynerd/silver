# Round 33 save-resource component integration

This packet reconciles three separately reviewed components at the exact
aggregate and author freezes in `inputs.json`:

- [Direct restored-path lookup](../../research/retained-why-path-lookup-capacity.md):
  finite acyclic lookup chains, safe array/index arithmetic and no per-node
  native-stack growth. The useful writer count W remains unknown; the loose
  representation ceiling does not establish allocator or writer capacity.
- [Format accumulator construction](../../research/retained-why-save-format-accumulator.md):
  bounded static format chains, attempted construction and annotation subtotals,
  with an own-frame output_acc subtotal. Whole-stack and aggregate allocation
  remain open.
- [File/channel extents](../../research/retained-why-save-file-capacity.md):
  bounded names, channel records and conditional file-offset/buffer arithmetic.
  Actual attachment of positive-count write progress remains unestablished;
  normal fresh-file lseek must return zero. Neither contract is silently added
  to completed assurance.

```sh
python3 docs/evidence/retained-why-save-round33-20261020/check.py
```

`check.py` compares author-file identities, all 94 retained native pins, new
Python syntax and local document links. Its first result is retained in
`integration-result.json`. It reuses the reconciliation procedure from Round 32
without replaying that round's checks. Component source checks and arithmetic
results remain in their original packets; no component checker, native tool,
capture, disassembler, source fetch, solver, proof or full suite is replayed.
Hashes and syntax checks do not prove semantic claims; the combined independent
review is required for the scoped arguments.

This is an input-identity aggregation, not a new combined resource envelope.
All component subtotals retain their distinct scopes and named external
premises, including the single global budget of at most three saves across the
selected post-cut interval. Missing premises withhold usable bounds. Complete
restore-table, formatter/save and pipeline capacity remain unestablished.
The [round record](../retained-tool-rounds.md#round-33--lookup-formatter-construction-and-conditional-file-capacity)
retains the results, review, cost interval and next obligations.

#119 and #153 remain active; Oracle, admission and installed tools/pins remain
unchanged. Production #88–#94 is unstarted and PR #121 remains draft/unmerged.
