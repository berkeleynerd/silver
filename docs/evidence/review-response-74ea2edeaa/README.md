# Review response evidence — 2026-11-09

Implementation and final validation are in progress under #355. The
[response record](../../external-review-response-74ea2edeaa.md) separates the
original review, corrections and current dispositions. This packet does not yet
claim complete delivery.

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

The final successful focused targets were `Silver.FunctionDeclarationNative`,
`Silver.PredicateFunctionCallEquations`, `Silver.FunctionVisibilitySource`,
`Silver.PredicateBooleanBodyNative`, `Silver.ComposeStringNative` and
`Silver.BooleanBindingsSourceBridge`. Their closures cover every changed guard
helper and control and the native-domain caller/witness. The complete native audit also passed in `20261109T142006-5f058d0b96be`:
actual driver exit 0, 77 units, 1,165 entities, 1,605 flow checks and 16,920 proof
checks (18,525 total). It was a forced full-scope run with eight workers and the
recorded warm cache seed, not a cold run. The 80 report/provenance files and actual
runner output are retained under that run. Complete Lean/source/module/axiom
validation and final regressions remain pending.

[review-corrections.json](review-corrections.json) retains the six admission-only
C1 original/control programs and the lane-A ledger recount. It does not claim
native execution for the admission-only controls. The
[inherited-interface map](inherited-interfaces/contract-map.md) and
[exact inventory](inherited-interfaces/interface-inventory.json) support the
separate critical source review; they are not new machine-checked theorems.
