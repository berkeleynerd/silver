# Fixed startup formula evidence

Source analysis for #119, 2026-10-18. No native compiler, Why3, solver or Lean
process ran. The [argument](../../research/retained-producer-startup-vcs.md)
owns source correspondence for the six fixed constructions.

`identity.json` pins selected complete files inside four existing source
archives. `check.py` checks those archive/file identities, the relevant source
branches and fixed contracts, then calculates the retained kode and lexical
formula envelopes from explicit small skeletons. It does not execute Why3 or
formally verify its implementation. It also checks the import result's six-VC
frontier and noncloning of the three invariant-bearing modules.

```sh
python3 docs/evidence/retained-producer-startup-vcs-20261018/check.py
```

`result.json` distinguishes retained shape, direct program-variable births,
the two zero counter components, and the still-open lifetime allocation work.
