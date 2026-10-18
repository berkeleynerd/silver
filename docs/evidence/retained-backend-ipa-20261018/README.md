# Null-unit IPA source inventory

Supports the [conditional shape transfer](../../research/retained-backend-ipa.md).
The exact source files come from the already retained complete GCC extraction
at `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; their lengths and hashes were
reconciled against that extraction's full manifest before packaging.
`identity.json` and `sources.tar.gz` retain their identities and bytes.

Reproduce without a compiler or prover:

```sh
python3 docs/evidence/retained-backend-ipa-20261018/check.py \
  --output /tmp/null-ipa-check.json
```

Optional `--gcc-root` compares each archived file against a complete extraction
whose root contains `gcc/`. Compare the result with `result.json`. Source line
references use literal LF numbering; form-feed separators are not newlines.

The checker verifies full-file identity, inventories all 39 top-level IPA
registrations, and reconciles selected constructor/early-return sites. The
report supplies the configuration, reachability and shape-preservation argument;
recording its transfer in JSON does not mechanize that argument. In particular,
the complete incoming fixed gigi graph and all setup allocation lifetimes remain
open. No compiler, solver, Lean or complete validation job was run for this
derivation. The separate native-option experiment is not this evidence.
