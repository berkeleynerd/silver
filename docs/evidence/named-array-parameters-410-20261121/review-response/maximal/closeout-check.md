# PR #412 final regression evidence check — 2026-11-22

Read-only outcome, identity and input comparison on Linux x86_64, completed at
12:12 UTC. Source HEAD was `d7b702cfae09c5ab8f9911353d8ec7f2557b6215`;
original reviewed production/proof target remains
`5a4b0ad8ac05ed431d2f0c8baee2c2cc75686267`. Selected GPT-6.1 Sol / Extra High, as recorded by the lead in the explicit
subthread launch. This selection is lead-supplied metadata.
Runtime model/effort confirmation and elapsed/token/cost measurements were
unavailable. No tests, validators or proof jobs were run. No repository or
GitHub mutations were made; only this permitted scratch report was written.

**No outstanding regression identity or input-applicability blocker was found.**

- Managed run `20261122T105525-650db3ffe211` finished **success** at
  `2026-11-22T12:09:08.210708+00:00`, with no failure keys or identities.
  Its test phase returned zero. The native log records the exact outstanding
  `test_samples.SupportedSampleTests.test_maximum_dynamic_expression` identity
  as `ok`, one test, `OK`: 4,420.116 unittest seconds and 4,421.903832 managed
  seconds. Allocation was six workers, guest CPUs 2–7, on the eight-CPU host.
- Independently rehashed **all 1,400 prepared input-map entries** against current
  files: zero mismatches. `tests/test_samples.py` matches the reviewed
  `df8939c8470e50730597866e9c0d2364a37e644495a3f5e09531a3c60f6d7e56`.
  Expanded stack-test, manifest and installed compiler hashes also match the
  independent applicability record. The current tracked difference from the
  original review has no unaccounted production/proof/configuration inputs;
  pending lead edits were documentation/evidence only.
- Recomputed the archived identity partition: **756** unchanged full-suite
  results + **15** proof-reader results + **12** Rosetta results = **783 retained**.
  The two changed old methods and two added controls supply **four fresh**
  successful identities, closing **787/787**. The archived 785 baseline identities
  are unique; proof-reader and Rosetta sets are disjoint, and neither intersects
  the two replaced identities. An AST comparison confirms precisely those two
  old test-body changes and two added controls, with no removed test methods.
  The reconstructed sorted final inventory SHA-256 matches the independent
  discovery record:
  `ecd2f159f8ad4708b4248883464b38d071203bf7954ec8f8d38119c04c49ad65`.
- Inspected the retained expanded-stack and corrected two-control run outcomes
  and logs: each succeeded on the identities assigned to it. Retained maximal
  `events.jsonl.gz` and `native.log.gz` decompress byte-for-byte to the live
  originals, whose SHA-256 values are respectively
  `38d5186d0d4999201297ab93fea0c90f08274be594d3d14761c55a9f6df1d32f`
  and `b59bfdf0dc5eb21cb711dd5ca466c590f4cb39323b2cfddefd903d4c1786c780`.

This closes the sole pending result identified by the independent repair and
regression applicability review under development.md's reviewed test-reuse
provision. The earlier complete native/Lean audits retain their original scope;
this check adds no proof or semantic judgment. The focused review wrapper's
recorded failure remains a failure with its separate reconciliation. No merge
was performed or authorized by this check.
