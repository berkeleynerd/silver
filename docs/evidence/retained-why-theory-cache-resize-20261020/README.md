# Bounded theory-cache resize evidence

This offline packet supports the
[research note](../../research/retained-why-theory-cache-resize.md). It proves a
conditional first-published-resize bound and preserves an explicit selected
continuation residual. It does **not** close #119, #153 or save capacity.

- `inputs.json` binds the retained source archives, capture manifest, accepted
  dependency notes/review and already checked native body/result files.
- `capture-projection.json` binds and projects the five exact capture archive
  members: initial empty table, ordered theory tags, sole nonempty theory and
  conditional numeric bounds. Archive and member hashes are both rechecked.
- `source-excerpts.json` retains exact source member identities and line ranges.
- `model-result.json` preserves 198 first-resize states' aggregate checks and
  three actual-hash countermodels, with complete relevant cell/link states and
  query logs. Each later repair pass is hypothetical; selected-control
  reachability and complete capacity are marked unproved.
- `check-result.json` records the focused reproduction check and its measured
  elapsed time. Python compilation, JSON parsing and authored-link checks also
  passed; they do not establish the theorem independently.
- `round.json` records selected settings, scope, timing and unavailable metrics.

Run from the repository root:

```sh
python3 docs/evidence/retained-why-theory-cache-resize-20261020/check.py
```

The checker regenerates projections in memory and compares them byte-for-byte
with the retained files. `--write` is the authoring mode. It is a small semantic
model and integrity check, not a source interpreter or machine-code verifier.
No native target, disassembler, capture, source fetch, solver, old observer,
binder, alpha, or predecessor checker runs. The prior 20-body native-byte check
is reused at its recorded scope; it is not reported as a new run.

The first-resize proof applies to any correctly indexed disjoint finite input
at first publication; the model uses the three captured cases' ordinary
size-33 trigger for concrete examples. Prepublication failures can cause a
later publication at a larger scalar, so the theorem uses `N<=Th+2` rather
than assuming 33 universally. Terminal save-only suffix bounds require their
explicit control premise. The protected `InternalFailure` continuation remains
the unresolved source question.
