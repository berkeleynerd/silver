# Scalar-guard frontend repair evidence

[Blocker #284](https://github.com/berkeleynerd/silver/issues/284) is repaired on an
isolated branch above the unchanged #283 review target `88c127b631`. The selected
implementation is `039daa30341e6a2e042c9e930568ef16eff97bf3`: only native application
compilation adds `-cargs:Ada -gnatdM`; the generated project and proof options
remain unchanged. This packet is a focused repair checkpoint, not complete
project assurance or permission to merge. See the [repair argument](../../scalar-guard-frontend-repair.md)
and [independent review](../../reviews/review-guard-frontend-repair-20261029.md).

## Evidence scopes

- `original-reproduction/` retains the exact 167-byte admitted/proved/rejected
  source, passing control and original managed evidence. Its successful
  experiment observed the expected contrast; the counterexample's compilation
  remains failed.
- `frontend-matrix/` retains the harness, 30 exact inputs and command/results
  table. Seventeen of 27 admitted inputs failed baseline native compilation;
  all 27 passed with the native-only flag. Three rejected controls retain their
  actual outcomes. This check did not prove, link or execute the programs.
- `candidate-controls/` retains two invalid-source controls, commands, runtime
  logs and Main proof records. Both still raise `Constraint_Error` and retain
  the expected unproved range/overflow obligation. They used the initially
  proposed shared-project flag, including in proof, and are diagnostic evidence.
  The final patch narrows the flag to native compilation after review; it does
  not rely on changing GNATprove's frontend options.
- `native-source-audit.tar.gz` contains the exact source-analysis record,
  pinned relevant source files, Alire origin/release recipe, scan results and
  input identities. Extract under `native-source-audit/` to follow its relative
  links. The scan covered 474 top-level Ada `.adb`/`.ads` files. The original
  complete SHA-256 list was not persisted; the retained inventory uses pinned
  Git blob IDs, and the retained source subset has independently checked hashes.
  No full-GCC scan, proof-frontend audit or binary attestation is claimed.
- `runs/` holds original managed events/logs compressed without changing their
  decompressed bytes. `retained.json` records their hashes and finished event.
  Failed runs stay failed, and diagnostic expected failures are distinguished
  from successful compilation or verification.

## Managed results

| Run | Scope | Outcome |
| --- | --- | --- |
| `20261028T222332-125b175a567b` | Original failure/control contrast | Expected contrast observed; counterexample build failed |
| `20261029T075208-6adf393e2b65` | Native-only frontend matrix | 30 cases completed, 57.635 s |
| `20261029T075930-4fd40342a996` | First dynamic-control launch | Failed before experiment: relative harness path resolved under Alire context |
| `20261029T080007-5833f73fad3f` | Candidate shared-project dynamic controls | Both runtime errors and unproved checks retained, 292.099 s |
| `20261029T080547-ef8b6001fc87` | Intermediate shared-project driver build | Passed; superseded by native-only implementation |
| `20261029T080837-11b8a871e914` | Final native-only driver build | Passed, 8.516 s |
| `20261029T080947-da66ebf18023` | Complete scalar-guard test module on final driver | 23 passed, 80.912 s in unittest; five native compile/prove/execute tests |
| `20261029T081206-84390bb82d97` | Focused changed-driver SPARK proof | All 133 checks proved, 362.070 s, four workers, fresh solver work |
| `20261029T081909-3d2bc739e22c` | Attempted complete audit of single-unit packet | Failed: owned dependency reports lie outside the focused scope |

The original-source regression verifies byte identity and checks that the
project omits M while native Main's ALI includes it. The other new tests cover
grouped/normalized and false-flow guards, a nonstatic threshold snapshot, live
updates, arguments, arrays, counted loops and reverse element iteration. The
existing guarded arithmetic and complete 100-doors tests also pass. Shared
helpers audit Main and all selected-library reports before executing outputs
and valid/invalid argument cases.

The focused driver reports retain 29 flow and 104 proof records, all info with
no justified/suppressed check, ten covered entities, no skipped proof and no
pragma Assume. Seven vendor/limitation notes remain in the raw warning list.
`driver-proof/` retains those reports and the attempted audit harness. The complete
auditor rejects this single-unit packet at the omitted owned dependency
`Silver_Libraries.Capture_And_Snapshot`; no rule was relaxed to manufacture a
passing audit. Complete native proof/dependency/provenance auditing and
Lean/source/module/axiom assurance, with final regression coverage, remain
deferred until applicable external
feedback is batched, as the owner instructed. The native option affects every
application build, so prior compiler-dependent regressions are not automatically
covered by unchanged parser sources. No macOS, hosted CI, clean Lean rebuild or
kernel replay is claimed.
