# Review: Integer division delivery records

2026-10-26. Independent bounded review; selected GPT-6 Astra at Extra High.
Runtime model/effort were not independently exposed. Inspection and report
interval: 03:30:51–03:37:12 UTC (6 minutes 21 seconds). Token and cost measurements
are unavailable.

Exact review target: `384cb43a24eca7c58d8cc61d18d5c996ff5f59ca`.
Implementation/certificate target: `b7dfcbcdb0`, compared with prior implementation
`e24af71ce6`. Scope: the six changed narrative documents (`README.md`,
`docs/assurance.md`, `docs/integer-division.md`, `docs/session-memory.md`,
`roadmap.md`, and `rosetta/assessment-division-20261025.md`), the retained
[validation index](../evidence/integer-division/validation.json) and its eighteen
compressed artifacts, and the three refreshed generated certificates.

Supporting read-only inputs were the managed runner, provenance and Lean audit
implementations; the parity and manifest-sample tests; the final manifest and
sample sources; and the checked-in Rosetta catalogue and generated progression.
The earlier [core](review-integer-division-core-16d0f0cfaa.md),
[integration](review-integer-division-integration-14b9302a97.md), and
[repair](review-integer-division-repairs-559ef643e3.md) reviews are reused within
their stated scopes. This review does not repeat the mathematical or native
implementation arguments.

## Verdict

**No correctness, source-correspondence or evidence findings in this scope.**
The records accurately distinguish the failed full suite from the successful
focused certificate repair, and support reuse of the unchanged native and
complete Lean inputs. One presentation-only correction is recommended:
`docs/integer-division.md` has a blank line before the final “Certificate parity
repair” row of its round-settings table. Removing that blank line will keep the
row in the rendered table; the record's content is already correct.

## Evidence correspondence

Both compressed and decompressed SHA-256 values agree with the index for all
eighteen artifacts. Each of the six exported input-capture and finish-event
objects agrees with its retained event stream. Independently hashing exact Git
blobs at `b7dfcbcdb0` gives these results:

| Retained run | Tracked captured inputs | Difference from final implementation |
| --- | ---: | --- |
| Native full proof | 141 | None |
| Native build | 141 | None |
| Full suite | 707 | Exactly the three refreshed certificates |
| Intervening whole-file parity attempt | 707 | The same three certificates |
| Successful focused parity method | 707 | None |
| Complete Lean/source audit | 582 | None |

The saved pre-workspace-reuse Lean comparison also matches all 582 final inputs.
All 52 source/certificate hashes recorded for successful parity match the final
implementation. Absolute suite capture paths were normalized against their
recorded worktree; the Lean input map is its captured `sources` map.

The native completed provenance has the same complete input map as the captured
native record and records `complete: true`, `mode: full`, and `linux-x86_64`.
Its 77 report hashes all match the validation index. The index additionally
hashes `proof-inputs.json` and `proof-provenance.json`; these are intentionally
outside `proof_provenance.py`'s report set, which consists of the 75 `.spark`
reports, `gnatprove.out` and `gnatprove.sarif`. The retained decompressed
provenance bytes match the index's provenance-file hash. This difference in map
size is not a report mismatch.

## Outcomes and repair claims

- Native run `20261026T002857-50fd2281b177` records success for all **15,224
  checks**, followed by the complete coverage/provenance audit: **75 units,
  1,007 entities, 1,303 flow checks and 13,921 proof checks**. It used the stated
  unchanged level-2 regime, cvc5/z3/altergo, 30-second timeout and four workers,
  with cache reuse and forced full invocation. Managed elapsed time is
  5,801.391525588 seconds. The tool phase records exit zero; the audit phase ends
  and the managed finish is successful. The index accurately discloses that
  the audit event has no separate child-status field.
- Complete Lean run `20261026T005331-e0e3d7a0bf00` records a cached/incremental
  build in **39.714 seconds** and a fresh axiom audit in **8.867 seconds**:
  **467 modules and 90,288 declarations**, with only `propext`,
  `Classical.choice`, and `Quot.sound`. The 467 unique module names in the fresh
  transcript match the complete result. Four workers and two Lean threads are
  recorded. The documents correctly make no independent kernel-replay claim.
- Full suite `20261026T020550-192982f3d06e` ran **485 tests in 4,361.623
  seconds** (managed duration 4,363.515314874 seconds). Its only failures are
  three subcases of one parity method, for `silver_output_profile.adb`,
  `silver_scalar_expressions.adb`, and `silver_scalars.ads`; no other failures,
  errors or skips appear. The manifest method and symlinked-TMPDIR tests pass.
- Intervening whole-file run `20261026T032123-6332a6dd9ca2` ran eleven tests
  in 121.005 seconds, with the same three parity subcase failures and ten other
  passing methods. It is correctly preserved as failed.
- Repair run `20261026T032402-770b4c60bac2` used
  `python3 -m unittest discover -s tests -v -p test_lean_source.py -k checked_in_certificates_equal_regeneration`.
  It passed the complete parity method in **4.216 seconds** (managed duration
  5.803056769 seconds). That method iterates all **26 certificates**.

Between `e24af71ce6` and `b7dfcbcdb0`, only `OutputBodyCertificate.lean`,
`ScalarExpressionBodyCertificate.lean` and `ScalarsSpecCertificate.lean` change.
The authoritative sources, generator and tooling are unchanged.
`scripts/check_lean.py` excludes checked-in candidate modules from shared proof
input capture, independently regenerates every candidate in its isolated
workspace, then verifies the handwritten inputs and module set. Its captured
generator hash matches the final implementation. The checked-in refresh
therefore does not invalidate the successful complete Lean audit. The documents
preserve the failed full suite and use the repaired method plus the successful
unaffected tests; they do not claim a clean whole-suite rerun.

## Samples and documentation

The manifest contains **47 samples and 103 execution cases**. Its counts and
every exported sample hash match the reviewed sources. The successful
`test_manifest_samples` method checks admission, native compile/proof policy and
report auditing, byte-identical authored-source snapshots, and direct executable
status/stdout/stderr against each manifest case. Those retained results and
unchanged inputs support the stated sample checkpoint.

The six narratives consistently describe the narrow interval-checked `/`, `mod`
and `rem` fragment and its successful Linux assurance, without claiming guard
refinement, `abs`, broad assessed division approaches, new macOS validation or
hosted-CI results. Their local Markdown links resolve. Rosetta supports only the
new narrow `interval-integer-division` identifier; broad `integer-division`
remains unsupported. The generated records agree on 1,782 tasks, 1,576 candidates
in 44 stages, 46 stage-one candidates, two unlikely, 203 excluded and one
design-pending assessment; stage two retains the #11 construct group, arrays
remain stage three and broad division remains stage six. The seven migrated
approaches and two retained broad mappings are described consistently.

No native, Lean, build, test or render runner was invoked by this reviewer, and
no tool installation, source, GitHub state or unrelated file was changed.
This is retained-evidence review, not an independent rerun. Live PR merge and
board status were outside the authorized scope and were not checked. Only this
review report was added; integration and publication remain the lead's work.
