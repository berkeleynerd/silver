# Relation cut: focused Lean leaf and pin check

Native Linux x86-64 managed run `20261107T045523-be282a369adf` passed on
2026-11-07. It checked the two authorized targets after the reviewed Relation
proof cut: `Silver.OutputBodyLines5` and `Silver.ReviewedOutputShape`.
The implementation source snapshot is `ce97ede446aad55520e59854ea8298e2a63d56eb`;
HEAD at launch and final input verification was documentation-only successor
`7f04fc060fc3fa48b2264e2893faf7464faec400`.

The refreshed 53,343-token pin successfully elaborated and was kernel-checked;
its `outputImplementation` definition intentionally changed with the native
assertion. This success does not independently establish preservation of semantic
contracts or endpoints; that is the separately reviewed assertion-only change.
The changed line-certificate bucket also passed kernel checking.

## Execution and result

```sh
python3 scripts/check_lean.py --target Silver.OutputBodyLines5 --target Silver.ReviewedOutputShape --workers 1 --threads 0 --memory-mb 24576 --task '#297 Relation cut certificate leaf and pin' --reason 'Focused kernel check of the reviewed changed line bucket and full token pin after both repaired native helpers pass; preserve expensive complete source checkpoint for stable native inputs; one worker for host memory headroom'
```

| Result | Evidence |
| --- | --- |
| Refreshed token pin rebuilt | `Silver.ReviewedOutputShape`: 338 s reported by Lake |
| Changed certificate bucket rebuilt | `Silver.OutputBodyLines5`: 1,069 s reported by Lake |
| Build phase | 1,417.800 s, exit 0 |
| Fresh scoped audit | 7.782 s, exit 0; 2,543 declarations |
| Permitted foundations observed | `propext`, `Classical.choice`, `Quot.sound` |
| Managed lease wall time | 1440.928 s |
| Runner elapsed time | 1446.178 s; includes pre-lease setup |

Lean 4.34.1 used one Lake worker, 12 automatic threads per process and the
unchanged 24,576 MiB process threshold. The existing native audit reserved four
workers in a separate workspace; this run used one worker for actual host memory
headroom. Minimum sampled available memory during this run was 25.09 GiB;
samples are observations, not a guaranteed peak bound. No process was suspended,
terminated or retried. No clean build or independent `leanchecker` replay ran.
Only the two target rebuilds were reported; their imported dependencies and
`Silver.AxiomAudit` reused retained objects. The audit itself executed freshly.

The audit reported exactly these eight project modules:

- `Silver.Admission`
- `Silver.AxiomAudit`
- `Silver.CertificateWitness`
- `Silver.Cursor`
- `Silver.Lexical`
- `Silver.OutputBodyLines5`
- `Silver.ReviewedOutputShape`
- `Silver.SourceLexer`

The inspected import closure and actual audited scope both exclude
`Silver.OutputBodyCertificate` reconstruction and every `NativeShapeCandidate`.
This is partial validation. The complete source-correspondence, whole-project
module/axiom checkpoint and complete native audit of final governed inputs remain
outstanding under the lead's ownership. No capability-completion claim follows.

## Input verification and retained files

Native output body SHA-256:
`7d39745bd9e2d57c573a1c398f9e0f07e486a9d482b60f1cd21fc436e48543f3`.
Generated Lines5 SHA-256:
`b0c8c4371731cb3f779f8402a2e5ccc157ece1318354bcbf628a5708eca8d7b2`.
Reviewed pin SHA-256:
`ae62bd0ba9d4e831657d53342228c0875bb24c84c7029bdd9e344bc5800c6575`.
The reconstruction source hash was captured and unchanged, but its proof was
outside this focused build.

All 762 managed captured source hashes still matched actual files at completion.
All eight regenerated line modules, reconstruction and reviewed pin matched their
checked-in counterparts after the run. `after-inputs.json` records those exact
post-run inventories, distinct from the runner's captured source inventory.

- `events.jsonl`, `lean-focused.log`, `lean-focused-evidence.json`: exact byte
  copies from the terminal managed run, including command, inputs, tools, phases,
  audit modules, foundations and success. The runner evidence digest is
  `27a98166c4ebfa3a651985e31b699349d7512d5f727638ca4ec0adcb2a0a6701`.
- `captured-inputs.json`: extracted managed input scope and full source/tool hashes.
- `before-inputs.json`, `after-inputs.json`: identity and parity verification;
  `after-inputs.json` also hashes the copied packet files.
- `focused-audit.lean`: exact generated scoped audit driver.
- `before-status.json`, `after-status.json`: managed coordination snapshots.
- `initial-meminfo.txt`, `observations.jsonl`: actual host/resource observations.

Selected execution/monitoring workload: GPT-6.1 Sol, High. Runtime model/effort
confirmation is unavailable. Native execution and Lean phase timings are recorded
above; token and monetary cost measurements are unavailable. This round closed
the two focused leaf/pin checks without source edits or rework. No commits,
publication actions or CLI-memory updates were performed by this bounded worker.
