# Retained save shape-builder direct allocation

See the [research note](../../research/retained-why-save-shape-builder-allocation.md).
This is a new follow-on packet; it preserves Round 36's structural packet.

- `transfer.py`: source-indexed event/request arithmetic and individual guards.
- `check.py`: focused imported-input, source and installed-ELF reconciliation.
- `inputs.json`: hashes of all reused evidence, including the frozen binder inputs.
- `source-witnesses.json`: exact source excerpts and complete member identities.
- `native-bodies.json`, `native-witnesses.json`: retained disassembly body subset
  and executable/disassembly identity. Some unused source arms occur within the
  witness subset; it is not a claim that every retained body/arm is reached.
- `native-allocation-sites.json`: constant native reservation sites.
- `native-symbol-references.json`: body reference inventory for integration;
  direct symbol references alone are not a complete indirect call graph.
- `result.json`, `check-result.json`: scoped bounds and check outcome.
- `round.json`: settings, authorization, findings and validation record.

After integrating the frozen stack packet, reproduce with:

```sh
python3 docs/evidence/retained-why-save-shape-builder-allocation-20261020/check.py
```

In the isolated author worktree, supply
`--stack-root /home/canto/src/github.com/berkeleynerd/silver/tmp/why-save-stack-round36`.
The checker reads the stack certificate and never reruns its extraction or
checker. Native verification reads the retained installed Linux x86-64 ELF;
it does not execute that target or create new disassembly.

The result is cumulative direct-request accounting for the six pruned families.
It does not establish physical memory sufficiency, failed-allocation behavior,
printer termination, full native stack or complete-save/pipeline assurance.
Refs #119, #153.
