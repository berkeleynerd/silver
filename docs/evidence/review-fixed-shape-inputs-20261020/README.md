# Independent fixed-input and shape-transfer checks

2026-10-20, #119 / #153. The [review](../../reviews/review-fixed-shape-inputs-20261020.md)
records the source assessment, two repaired interface findings and acceptance
limits. These checks perform no native execution, logical opening, binder/alpha
replay, proof, solver, capture or source fetch.

- `check-atoms.py` compares all 14 atom-target files with Git, runs the new
  atom packet's byte/certificate/source checker once, then independently checks
  direct stored-term edges, exact reachability, identifiers, constants,
  attribute memberships and derived summaries. This flat stored-graph check
  does not interpret opening or recount opened occurrences.
- `atoms-result.json` retains its passing result at atom target
  `0ec7f4b5082830501f51764bfd4652d157c31104`.
- `check-shape.py` compares all ten final shape-target files with Git, runs
  the new source/input checker and six interface regressions, independently
  calculates all task/visit arithmetic, and compares the original and repaired
  bound records. The sole bound-record change is the explicit true attribute
  readiness field; all five B/G/J/L values and other fields are unchanged.
- `shape-result.json` retains its passing result at repaired shape target
  `c95c01d054447b903803413b43758b72f3ce36e3`, following initial target
  `79d48aa4dfe243578d09b58ef8c5d65aa571f75f`.

From an integrated repository containing both frozen packets:

```sh
python3 -B docs/evidence/review-fixed-shape-inputs-20261020/check-atoms.py
python3 -B docs/evidence/review-fixed-shape-inputs-20261020/check-shape.py --target c95c01d054447b903803413b43758b72f3ce36e3
```

The actual review used `--shape-root` pointing to the author's clean isolated
worktree for the second command, with all input bytes compared to that exact
Git target. The review worktree itself is based on the atom target. The result
records retain each checker's SHA-256 and measured time; new runs naturally
have different timings. Successful evidence need not be rerun solely to obtain
another timing record.

These checks establish the named finite input/aggregation properties. They
do not replace the source argument or establish universal process capacity.
