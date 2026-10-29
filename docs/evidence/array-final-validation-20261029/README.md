# Final combined array validation — 2026-10-29

The owner authorized driving #266/#283 and blocker #284 through validation and
merge, recorded on main by PR #285 (`09afa12fa2`). This checkpoint uses combined
snapshot `b87f215bb9af13c85caca7e2cf36658de6120df9`. Response head `559f6311d1`
has the identical tree and only aligns merge history. Later documentation-only
updates do not replace these actual source identities.

All required validation and the final evidence confirmation have passed.
The final external iteration/combined-tree report was not supplied.
The [implementation integration review](../../reviews/review-array-final-integration-20261029.md)
found no unresolved implementation or evidence finding. This is distinct from
external approval.

## Completed evidence

| Run | Scope | Outcome |
| --- | --- | --- |
| `20261029T084357-2ecc23128d69` | Complete native proof, coverage and provenance audit | Passed: 16,711 checks, 76 units, 1,068 entities, 435.871 s, four workers |
| `20261029T085149-9d3548857dfc` | Final native build | Passed; both binaries up to date |
| `20261029T084327-720db926b71b` | Complete Lean/source/module/axiom checkpoint | Passed: 532 modules / 112,807 declarations; build 10,850.527 s, fresh audit 10.492 s |
| `20261029T085226-e6730f154f28` | Fresh complete regression suite | Passed: 545 executions in 4,363.203 s unittest time; managed duration 4,365.773 s |
| `20261029T100555-f5c87f40820d` | 143-level counted-loop stack observation | Check, compile and execution passed under 8 MiB; 31.498 s managed duration |
| `20261029T100655-bb6b5cba328f` | 159-level constant-array foreach stack observation | Check, compile and execution passed under 8 MiB; 34.934 s managed duration |

Native totals are 1,418 flow and 15,293 proof records. This is forced full-scope
validation with retained sessions and solver cache, covering the changed driver;
it is not a cold run. All 143 tracked native inputs match the
combined target. The 2,561-input manifest also captures local generated bindings,
toolchain and settings files; their workspace-dependent bytes are retained
separately, not claimed byte-identical across workspaces. The unrelated local
`PredicateLoopCandidate.lean` edit in the native workspace was preserved and is
outside the native input set. Regression and Lean workspaces use the clean
combined proof tree.

`runs/` retains original events, logs and completed native proof evidence,
compressed without changing the decompressed bytes. Each `retained.json`
identifies the source directory, original finished event and file hashes. The
native provenance binds all 78 report digests. The earlier failed single-unit
audit remains failed in the [focused repair packet](../scalar-guard-frontend-20261029/README.md);
the completed native checkpoint now includes its missing owned dependencies.

## Complete Lean scope and input correspondence

The complete run used pinned Lean 4.34.1, one Lake worker, one thread per process
and a 24,576 MiB per-process threshold. Both build and fresh audit exited zero;
the audit reports exactly `[propext, Classical.choice, Quot.sound]` across all
532 expected modules and 112,807 declarations. The log reports 98 rebuilt
modules; the other 434 used matching Lake objects. This is complete-scope
incremental validation, with `clean_build: false` and `kernel_recheck: null`.
Lake reports 4,679 s for `ComposeSourceCandidate` and 3,558 s for
`PredicateSourceCandidate`; these shared-host observations are not isolated
performance benchmarks. Native/regression work overlapped the earlier part of
the run. The checker reports 10,877.394 s overall and the managed lease
10,874.419 s; their timing scopes start at different points.

The [input comparison](input-applicability.json) confirms all 143 tracked native,
647 captured Lean and 783 tracked regression inputs against the combined target,
including a final comparison after Lean's terminal success. Generated source
certificates are regenerated rather than included in the Lean input map; their
parity tests passed in the fresh full suite. The recorded Lean input digest is
`693237264e661dc3e28edc0edb9fccd1a8c81b4638d02e84729a65857bfc64d9`.
Subsequent edits change delivery records only. They do not change captured test
inputs or the test dependencies inspected for those records.

## Regression and stack scope

The [discovery inventory](test-inventory.json) accounts for all 545 logged test
identities, with no missing or extra identity. This includes the nine previously
disclosed shared-binding methods executed through two module imports: 536
executions remain after excluding those duplicates. The suite passed as a whole,
including the sample manifest, certificate parity, Rosetta rendering and the
three new frontend regressions. No earlier test result is substituted for this
fresh run. All 783 tracked inputs in its 791-entry capture match the combined
snapshot; the other eight capture the binary, generated bindings, local toolchain
configuration and Python.

The suite reserved four workers. The agent-authored
[affinity record](regression-affinity.jsonl) records confining unittest and its
descendants to CPUs 8–11 while the runner retained the host's full affinity.
Production application `-j0` was unchanged and could enumerate more workers than
the CPU affinity. This is resource scheduling, not a production option change.

The [stack summary](stack/summary.json) and [retention manifest](stack/retained.json)
identify exact commands, sources, binary and copied application reports. They
reuse the existing [fixtures and harness](../array-review-response-20261028/README.md#stack-observations).
Each check, compile and execution process had an 8,192 KiB stack limit; each
managed observation reserved two workers and used CPUs 8,9. Compilation took
25.227 s for the counted fixture and 29.056 s for foreach. Captured Main bytes
equal the fixtures, retained native ALIs include `-gnatdM`, and generated projects
omit it. These are successful observations of two concrete shapes, not a
universal stack or runtime bound. The summaries and observation metadata are
agent-authored; command outputs and copied artifacts retain their exact bytes.
Paths in those records denote the original host locations or decompressed
filenames; `.gz` files retain the corresponding bytes.

## Delivery

The completed checkpoint supports the authorized merge of
[PR #266](https://github.com/berkeleynerd/silver/pull/266), followed by
[PR #283](https://github.com/berkeleynerd/silver/pull/283). The completing records
change no governed implementation or test input. No required validation remains.

No clean Lean rebuild, independent kernel replay, macOS or hosted CI claim is
made. Existing failed and interrupted runs retain their original status.

## Work and review rounds

| Round | Selected settings | Result and measurement scope |
| --- | --- | --- |
| Native, build, full regressions and stack refresh | GPT-6.1 Sol / High | All owned runs passed; exact run durations and resource settings are above. |
| Issue inventory and completion-record drafting | GPT-6.1 Sol / Extra High | Checked the 18 completing issues, preserved optional deferrals and prepared bounded documentation/comment updates. No validation runs or GitHub mutations in this subthread. |
| Integration and completed-evidence review | GPT-6 Astra / Extra High | Initial implementation review: 3m31s; native/regression/stack confirmation: 3m47s; final Lean/input/documentation confirmation: 1m30s. No unresolved finding. The stale status phrase was corrected in the reviewed completing records. |

Lead model/effort selection and runtime settings were not exposed in the retained
handoff. Subthread selections above are not independently confirmed runtime
settings. Token/cost measurements are unavailable. No proof or test success was
repeated solely for documentation or bookkeeping.
