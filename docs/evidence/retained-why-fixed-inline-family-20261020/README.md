# Fixed-family first-inline evidence

R56, 2026-10-20 UTC; #119 / #153. Author base:
`c4cc50fbb2756419b2d10ef91f7c05758d9c7d4d`.
See the [research note](../../research/retained-why-fixed-inline-family.md) for
the exact source claim, producer induction and remaining boundaries.

Run from the repository root:

```
python3 docs/evidence/retained-why-fixed-inline-family-20261020/check.py
```

The checker is read-only. It verifies exact input/source identities and
recalculates only this new packet's targeted type/initial-key projections,
weighted root-family model and natural-number composition. It imports the
accepted R51 byte reader and weighted Refiner as libraries; it does not call
their checkers, CE model, native captures or any solver/proof target.

- `project.py`, five `*-types.json`: normalized type/signature/data projection
  and complete initial Dlogic/Dind necessary-key projection, from accepted
  retained bytes. The new initial projection has 563 keys and only raw objects.
- `family_model.py`, five `*-family.json`, five compressed `*-details.json.gz`:
  all 118 registered roots, two raw/CE routes, exact root attribution, optional
  metadata exclusions, weighted coefficients/eligibility, shape/Ident/kernel
  and candidate-storage/operation arithmetic. CVC5 and Alt-Ergo share the CE
  route, with Alt-Ergo's separate pre-inline identity validation left outside.
- `compose.py`, `result.json`: 354 ordinary root/driver pairs plus at most two
  extra episodes per distinct process. The process allowance is not multiplied
  by the number of stages.
- `audit_sources.py`, `source-witnesses.json`: exact source slices/full-file
  identities and supporting attribute-producer census. A literal-absence scan
  is not presented as a source theorem.
- `inputs.json`, `check.py`, `check-result.json`, `round.json`: pins, focused
  check, observed author result and lightweight round record.

The result gives 792,911 direct first-inline Ident registrations across the
five processes under the named guarded source attachment. It preserves the
original Input_Is_Valid/CE checks 1,145 / kernel 235 / type requests 669 without
replaying their predecessor. It extends the constant path to fixed 64-bit
range comparisons and candidate maps to binder-free multi-free-leaf values
under checked nonleaf-key disjointness.

Returned old hidden maps/types, full stored validators, unsuccessful collision
costs, allocation/stack/caches/counter state, later stages/printers and whole
quiet capacity remain open. The packet does not turn semantic equality into a
storage bound. No production, admission, source-shape pin, Oracle or launcher
configuration changed. No native target, solver, proof or capture ran.
