# Review response evidence — 2026-11-09

Implementation and complete Linux validation have passed under #355. The
[response record](../../external-review-response-74ea2edeaa.md) separates the
original review, corrections and completed dispositions. The
[independent integration review](../../reviews/review-response-integration-74ea2edeaa.md)
accepted the final evidence at `b58c89d481`, with no remaining gap within its
documented scope. Subsequent closeout edits change records only.

The integration worktree is `tmp/review-response-74ea2edeaa`, Linux x86_64,
22 available CPUs and about 62 GiB RAM without swap. The external review used a
different observed memory allocation; its 91 GiB figure is not reused here.
[cache-seed.json](cache-seed.json) names the idle native and Lean workspaces
copied into independent destinations, including all Lake private/server objects
and trace metadata. They are cached inputs, not proof of the new target.
Bootstrap was rerun for the new installation, using pinned GNAT/GNATprove 16.1.0,
GPRbuild package 26.0.1 and Lean 4.34.1; compressed setup logs are retained.

Each run directory contains compressed actual runner records and console output;
its index records original uncompressed hashes/lengths. Failed runs stay failed.

| Run | Scope and actual result |
| --- | --- |
| `20261109T140145-c3bb2a623948` | Initial response compiler rebuild passed; two workers alongside independent focused Lean. Superseded catalogue wording required the later rebuild. |
| `20261109T140146-6fb9495fc152` | Boolean native-domain model/helper focused check passed; fresh audit of 12,824 declarations, three approved foundations; 20 available workers. |
| `20261109T140637-2b771f6e73ae` | Focused guard batch failed in newly added control theorem visibility/numeral-equality proof scripts; 54.942s build. No integrated source run had started. |
| `20261109T141018-5deae03fe6f2` | Focused repair failed only at the String command-render collision proof; 15.514s build. Prior successful modules retained. Diagnostic checkpoint retained. |
| `20261109T141453-c6e68a2d1bb6` | Final catalogue-wording compiler rebuild passed. |
| `20261109T141506-cd8588ccad8b` | Focused String wrapper proof failed when simplifying the large dependent expression renderer; 14.605s build. Diagnostic retained; guards/proposition remained unchanged. |
| `20261109T141833-cb10648fbacb` | Smallest String check passed after using reflexive condition-token equality with only concrete command-render equations; fresh audit of 13,357 declarations, three foundations. |
| `20261109T142008-886cdd5994b7` | All six focused guard/domain/source-bridge targets passed; fresh audit of 22,643 declarations, three foundations. 14 workers available alongside eight-worker native audit. |
| `20261109T142839-1befe0666f22` | All 80 function-source leaf targets passed: 184 build jobs and a fresh 16,910-declaration audit, driver exit 0. Six Lake workers / automatic 22 process threads; 965.765 s managed duration. |
| `20261109T144532-5e2dbc4f965b` | Complete cached Lean build and fresh audit passed: 857 build jobs, exactly 820 modules and 145,589 declarations under the three approved foundations; actual driver exit 0. Build 14,038.369 s; fresh audit 10.660 s; managed duration 14,069.219 s. |

The final successful focused targets were `Silver.FunctionDeclarationNative`,
`Silver.PredicateFunctionCallEquations`, `Silver.FunctionVisibilitySource`,
`Silver.PredicateBooleanBodyNative`, `Silver.ComposeStringNative` and
`Silver.BooleanBindingsSourceBridge`. Their closures cover every changed guard
helper and control and the native-domain caller/witness. The complete native audit also passed in `20261109T142006-5f058d0b96be`:
actual driver exit 0, 77 units, 1,165 entities, 1,605 flow checks and 16,920 proof
checks (18,525 total). It was a forced full-scope run with eight workers and the
recorded warm cache seed, not a cold run. The 81 report/provenance files and actual
runner output are retained under that run. Complete Lean/source/module/axiom
validation also passed. The [complete regression packet](regression/README.md)
records all 648 successful executions, covering 634 method definitions, all nine
response regressions and all 84 manifest samples, with actual driver exit 0.

Independent evidence review identified the missing archived `gnatprove.sarif`
file after the initial packet was committed. It is now retained with its exact
hash from the successful native provenance manifest; this required no proof rerun.

The ordinary complete Lean checkpoint `20261109T144532-5e2dbc4f965b`
started after the successful leaf batch, with one Lake worker and automatic
22-thread processes. This serializes dense source candidates on this actual
62.87 GiB, no-swap host; it is not a persistent one-worker default. The independent
regression installation then started full unfiltered run
`20261109T144553-8abe96c6e3ad` with the remaining 21-worker reservation, unchanged
deadlines and no exclusions. The suite passed in 4,495.139 seconds (4,498.508 seconds
managed duration), with no failures, errors or skips. Complete Lean finished
successfully at 18:40 UTC with actual driver exit 0.
Regression source inputs match the canonical installation; generated installation
prefixes and the resulting executable hashes are recorded separately. The test
binary remained unchanged during the suite; byte-equality between the two
installation-specific binaries is not claimed.

The final [live catalogue comparison](catalogue-parity.json), performed after
the #367 wording rebuild, is byte-identical to `catalogue/silver.json`.
The leaf batch's sampled RSS reached 12.84 GiB for
`DeclarationHeaderFunctionBodyAtSpec`; this is an observation, not a measured
peak or a universal leaf bound. Earlier 4.317 GiB leaf and 38.31 GiB monolithic
function-candidate observations describe their historical inputs. Resource
samples for this response are retained with the final checkpoint.

The [complete Lean packet](runs/20261109T144532-5e2dbc4f965b/index.json)
retains the actual runner events, build/audit log, driver output and evidence.
Its [final input comparison](runs/20261109T144532-5e2dbc4f965b/final-input-parity.json)
rehashes all 927 captured inputs and both Lean tools and confirms exact coverage
of the 820-module tree. Generated certificates are regenerated by the runner,
rather than included in the captured-input count. The governed snapshot remains
`6365003968`; later commits change documentation/evidence only. This was an
ordinary cached complete check, without a clean build or independent kernel replay.

The agent-authored observations include two leaf-batch samples and 931
complete-run samples at roughly 15-second intervals. Its [resource summary](runs/20261109T144532-5e2dbc4f965b/resource-observations.json)
filters canonical-worktree Lean processes from regression fixture processes:
the largest sampled canonical process RSS was 16.115 GiB, and sampled host
available memory never fell below 30.111 GiB. These are observations, not proven
peaks. The sampler stopped after the complete driver exited. No successful
expensive check was repeated for this documentation-only closeout.

[review-corrections.json](review-corrections.json) retains the six admission-only
C1 original/control programs and the lane-A ledger recount. It does not claim
native execution for the admission-only controls. The
[inherited-interface map](inherited-interfaces/contract-map.md) and
[exact inventory](inherited-interfaces/interface-inventory.json) support the
separate critical source review; they are not new machine-checked theorems.
