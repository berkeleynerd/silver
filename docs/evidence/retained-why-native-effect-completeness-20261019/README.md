# Retained first-fold native effect completeness

2026-10-19 UTC, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The [source argument](../../research/retained-why-native-effect-completeness.md)
supplies `N_native = 0` additional identifier registrations and preservation
for the retained first `inline_trivial` invocation, at most two serial SIGINT
saves, and the specified exceptional-reporting routes. Its native and combined
conclusions await independent review.

The selected run is `20261019T000304-fcb988ec2c03`, PID 97103. The executable
SHA-256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Transfer from the named OCaml runtime/Unix/systhreads, Zarith, generated startup
and CRT/loader source contracts to these fixed images uses the explicit
[relevant-source behavior relation](../../research/retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary).
ELF file labels, imports, dependencies and lifecycle metadata corroborate that
relation; they do not prove an exhaustive historical source manifest, arbitrary
alias absence or compiler refinement. The 17 selector values are derived from
source initialization and preservation, not observed in live memory.

The packet contains:

- [inputs.json](inputs.json), [witness-plan.json](witness-plan.json),
  [source-witnesses.json](source-witnesses.json) and
  [retained-plan.json](retained-plan.json): 29 input identities, 53 source files
  with 90 excerpt ranges, and the exact retained launch environment.
- [source-family.json](source-family.json),
  [elf-lifecycle.json](elf-lifecycle.json) and
  [crt-weak-bindings.json](crt-weak-bindings.json): the 153 executable file-label
  join, interface-use projection across 233 OCaml C/header/assembly members plus
  Zarith, three application lifecycle projections, and seven-image weak-provider
  check. These support the inspected source argument rather than replacing it.
- [interface-summary.json](interface-summary.json),
  [configuration.json](configuration.json) and
  [native-interface.json](native-interface.json): 11 scoped roots, seven native
  contracts, the source-derived configuration, and the composable native result.
- [companion-effect-ledger.json](companion-effect-ledger.json),
  [companion-report-sites.json](companion-report-sites.json) and
  [companion-review.txt](companion-review.txt): verbatim evidence from companion
  source `6dd2732dd083ba6e29c7e2bd026d5668a0283b5e`, independently accepted at
  `3956aa7fb78c5ada4c9ceda2ba26ce76766b389e` without material findings.
- [composition.json](composition.json):
  `60,496 + 1,145 + 2*966 + 25,920 + N_native = 89,493 < 2^62 - 1`.
  This establishes no wrap from the selected counter/cut through the stated
  interval under the component invariants and behavior relation. It establishes
  neither prior global freshness nor full-resource/transform/grammar/pipeline
  capacity, later-invocation coverage or ordinary ending-save coverage.
- [check.py](check.py), [result.json](result.json) and [round.json](round.json):
  the bounded data checker, retained result, actual validation and work record.

From the repository root, with Python 3 and all pinned files available:

```sh
python3 -B docs/evidence/retained-why-native-effect-completeness-20261019/check.py
```

The installed-image paths in `inputs.json` identify the exact retained Linux
installation; this checker requires those bytes at those paths. It verifies
hashes, excerpt correspondence, source-use projections, ELF metadata, the
retained Thread entry witness, certificate references and composition arithmetic.
It imports only the pinned earlier ELF reader class, without invoking that
packet's audit. It does not execute target instructions, call a disassembler,
replay the earlier expensive checks, or machine-prove source effects and the
behavior relation. `--write-derived` updates the derived source/plan projections
and result after those checks; it does not run a new target or capture.
