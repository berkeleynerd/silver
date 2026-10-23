# Main construction interface and restricted array conversion

Linux x86_64, 2026-10-23, [#178](https://github.com/berkeleynerd/silver/issues/178)
under #119. The [derivation](../../research/retained-main-construction-profile.md)
imports immutable fixed-contract author `3040c6736d3a004239256b2ba50f25144e68bec8`
and its independent review `00a37442cc2912a4a456717d33ee852facd1f2fc`.
This packet supplies a constructor-preserving interface and restricted conversion
row. **The full Main source/typed-profile join remains open.**

- `algebra.py` preserves native identities, pending-temporary ownership, complete
  bound-expression trees, E/T context and lexical binders. Program applications
  retain actual occurrences and separate formal contracts. Supplied-child
  handles reference complete profiles and binding contexts, not just sizes.
- `profiles.json.gz` contains 43 module-specific signature/contract profiles,
  84 branch cases with complete normalized native and resolved-program/logical
  diagrams, input shape/bound trees and pending-map states, and a symbolic
  supplied-child interface example. Gzip uses a fixed timestamp.
- `sources.tar.gz` retains fourteen complete source files. `identity.json` pins
  their existing providers, copied-member identities and the immutable fixed
  tranche. These are retained source premises, not new binary attestations.
- `check.py` verifies those identities/source copies, recomputes the profiles,
  checks branch and binder ownership, and compares affine lexical calculations
  with direct environment evaluation at positive weights. It exercises a fixed
  source control partition; it is not universal assurance by candidate samples.
- `result.json` records the focused check. `round.json` records selected model
  settings, timing and significant pre-freeze findings. Independent review is a
  separate packet owned by the reviewer.

Run offline from any directory:

```sh
python3 docs/evidence/retained-main-construction-profile-20261023/check.py
```

No compiler, prover, target or Lean process is executed. Source sizes stay
symbolic. The symbolic size projection does not discharge supplied children's
contracts/effects/scoping obligations, construct all Main wrappers, or provide a
completed U/H bound. Those are the next integration obligations under #178.
