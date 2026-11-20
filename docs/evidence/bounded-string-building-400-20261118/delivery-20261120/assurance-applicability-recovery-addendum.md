# PR #403 assurance recovery addendum — 2026-11-20

**C9's retained complete native and Lean/source/module/axiom assurance requirement
is satisfied for PR head `001c50dce1bcf3ad2d174b4426f684fe78cb2e64`. No remaining
proof rerun is justified by this sample-only delivery.** C8's assurance component
is likewise covered; its regression inventory and the full closing/merge review
are separate responsibilities. This is acceptance of retained Linux ARM64
assurance and exact current-source applicability, not a new native x86-64 proof
or a newly executed Lean import/axiom audit.

This addendum supersedes the original report's missing-byte observations. It
retains that report's accepted #345 sample-batch precedent: unchanged complete
proof results can be reused after applicability review without an unconditional
new Lean invocation. All required obligations and source correspondence remain
covered by the original successful runs. No hash exclusion or changed trust
boundary is introduced.

I read the supplied collector and verifier sources before examining their
results. They collect from the stopped ARM sandbox's retained filesystem images
and worktrees, construct a separate merged overlay export, and hash bytes against
the committed manifests. I did not execute those scripts. Independent receiver
checks used `verify_recovered_assurance.py` and the unchanged production trace
policy; no solver, compiler, Lean, Lake or recovered executable was run.

| Receiver-side check | Result |
| --- | --- |
| Both transferred archives | SHA-256 and length match supplied SHA256SUMS |
| Extracted records versus records archive | All 2,571 files byte-identical; 21,616,826 bytes |
| Native complete input manifest | All 2,622 entries match locally read bytes: 147 PR repository inputs plus 2,475 recovered support inputs |
| Native generated Ada files | All three recovered files match the original hashes and earlier independent reconstruction; runtime binding remains exact |
| Native tool observations | All 12 collector path/hash observations agree exactly with the committed manifest |
| Native tool bytes included in transfer | Original `/usr/bin/python3.14` rehashed locally; matches original hash and is AArch64 ELF |
| Image binding/overlay observations | All 80 recorded entries follow reviewed routing; original vendor gnatwhy3, copied gnatprove and compiled adapter hashes match recorded identities |
| Lean merged workspace inputs | Exact inventory and all 1,037 hashes match the committed successful final manifest |
| Lean compiled artifact inventory | Exact inventory and all 6,202 hashes match, including private/server objects and their hash files; 1,304,912,624 logical bytes |
| Lean retained build traces | All 1,035 merged build traces pass current production direct-kernel-bypass policy |
| Lean tool cache marker | Exact original Lean/lake path/hash map preserved; no rewrite or host substitution |
| Lean original source binding | Preserved adjacent `src` symlink spells `../../src`; collector source checkout is the recorded `c7388ab5d038ccbce9635ffaeec7df9189369366` |
| Lean original successful log/manifest | Exact bytes/hash match committed final-run evidence |

The cache archive was streamed without extraction into a live cache. The verifier
resolved archive hardlinks and checked the final merged view rather than taking
either historical overlay layer as complete. It inspected 47,648 members and
hashed 3,207,289,212 regular-file bytes. The merged proof view contains 17,587
files totaling 1,968,072,622 logical bytes. Inventory equality rules out omitted
or extra governed workspace modules/artifacts, in addition to checking each hash.
The independent pass took 8.951 seconds, including native/input and transfer-hash
checks; this is evidence inspection time, not proof execution time.

These checks supplement the earlier successful PR-specific comparison of all
147 native/1,142 Lean repository inputs, all 40 regenerated source candidates,
the retained 1,035-module/166,332-declaration axiom audit, and the fresh Python
audit of all 80 native reports covering 19,726 discharged checks. Those results
were retained rather than unnecessarily repeated.

The remaining scope limits describe what was checked; they are not outstanding
proof obligations for this PR:

- The other 11 native executable files were not transferred. Their exact hash
  comparisons are collector observations checked against the committed manifest.
  The Image copied executable, adapter and link topology are likewise collector
  observations. The record does not include executable-mode bits or an independent
  complete vendor-directory listing, so this is not a fresh local invocation of
  `validate_image_setup` or `validate_provenance`. The original successful complete
  native provenance and post-build validation remain part of the accepted result.
- Lean/lake executable bytes were not transferred or newly hashed locally. Their
  original identities were checked by the successful runner and its contemporary
  collector; the recovered cache marker and exact objects remain bound to those
  identities. No different tool loaded these objects during this review.
- The symlink text and original checkout identity were preserved, and captured
  authoritative source bytes match the PR as previously established. The absent
  original `/Volumes` installation was not remounted here; no claim of a live
  resolved original mount is made.
- Fresh Python artifact/trace/log checks are distinct from the retained fresh
  Lean environment audit. There was no new import audit, kernel replay, clean
  build, native proof, or cross-platform cache validation. The new x86 installation
  retains its separate generated configuration and validation scope.

The recovery gives no evidence of a changed source, failed obligation, incomplete
proof object, unapproved axiom or kernel-bypass trace. Repeating complete proofs
would add no missing evidence for this authorized repository change. In
particular, importing the ARM cache into the x86 runner or modifying its tool
marker would be inappropriate; the archive remains separate.

Reproducible receiver verification:

```sh
python3 tmp/pr403-delivery-20261120/verify_recovered_assurance.py
```

Detailed outputs are `recovery-native-assurance-results.json`,
`recovery-lean-assurance-results.json`,
`recovery-lean-archive-file-inventory.json`,
`recovery-records-archive-verification.json` and
`recovery-assurance-audit.log`, alongside this addendum. The records-archive
comparison independently tied the extracted records to the verified transfer
archive. The tool's outputs deliberately distinguish bytes checked here from
collector observations and previously accepted checks.

Selected review setting remains GPT-6 Astra / Max; runtime telemetry is not
independently exposed. No tracked file, original archive, recovered input,
live cache, issue or branch was modified. No commit, push or merge occurred.
