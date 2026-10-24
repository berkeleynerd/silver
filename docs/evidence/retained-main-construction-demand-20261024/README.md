# Stored construction / type-instantiation bridge

Author evidence for the
[research note](../../research/retained-main-construction-demand.md), #202
under #119. The new result is the saved-image support invariant and generic
type-instantiation/call-contract seam. Whole source/type/kode/SPWP caller
closure remains open.

- `bridge.py` preserves native stored binder maps through generic mapping,
  models all case/pattern shapes for context, and composes case-free
  `t_ty_subst` with the accepted kernel. Its #211 proof wrapper requires map
  coverage and capture compatibility; the raw recurrence retains the native
  counterexample behavior. Actual inherited clone-map attachment is conditional.
- `check.py` verifies retained complete source/provider identities, exercises
  new constructive histories and compares type instantiation against an
  independent eager interpretation. It invokes no predecessor checker.
- `identity.json` identifies complete retained source inputs and focused
  source spans. It changes no source/tool pin.
- `result.json` records the latest new-only check. `round.json` records the
  selected author setting and unavailable runtime/token/cost measurements.
  `result-before-211.json` preserves the original freeze's successful finite
  check; independent review nevertheless found its insufficient capture premise.
- `checkpoint.md` records scope, authorization and the current handoff.

Run from the repository root:

```sh
python3 docs/evidence/retained-main-construction-demand-20261024/check.py
```

The mathematical inputs are focused diagrams, not a new arbitrary typed-tree
or caller-demand admission interface. Generic mapping's complete native byte
cost and the full Main caller count are explicitly not claimed. No native
target, capture, compiler/prover or Lean/solver was executed.

Repair #211 is based on provisional review
`62dee518226c221e3e396a76ee5693272ee01f23`; final independent review of the
repair remains pending at this author freeze.
