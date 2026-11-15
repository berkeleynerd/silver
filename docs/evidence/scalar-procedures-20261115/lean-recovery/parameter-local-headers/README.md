# Parameter/local header normalization — 2026-11-15

This bounded systematic repair follows a measured recurrence in the inherited
function-source leaves. It is necessary recovery inside #370, not a new
language increment or a change to any application or proof domain.

## Diagnosis and selection

The first `FunctionSourceCandidate` caller attempt built the two smaller
FunctionTypeAt headers and several semantic dependencies, then
`DeclarationHeaderParameterStepSpec` failed the 8 GiB kernel threshold after
56 seconds. The monitor observed the explicit diagnostic and sent SIGINT only
to the source process group, stopping the newly started ParameterStepImpl before
it completed. Thus the module failed and the caller attempt was then
controlled-interrupted; no assembler audit passed. Peak sampled source-tree RSS
was 8,945,840 KiB; host available memory stayed above 5,355,040 KiB. Neither
host OOM nor a host-headroom guard caused this stop. Completed objects remain
available and failed/unfinished modules are not represented as successful.

The exact failure inputs are the committed proof/source snapshot `a84039320`
(and identical proof/src/scripts integration `1684b88fa`), with the unchanged
source/tool inventories already retained by the preceding two-header success.
The caller log, monitored command/status and resource records are retained here.

The previous 834/839-character headers and this 695-character header establish
a recurring expected-string decoding cost. The authorized next class comprises
only the remaining declaration-spec headers at least as long as this measured
case. The five other entries are selected by the shared representation and
length, **not** falsely recorded as individually observed failures:

| Header | Expected characters | Complete tokens |
| --- | ---: | ---: |
| ParameterStepSpec (observed failure) | 695 | 147 |
| ParametersModelSpec | 742 | 153 |
| ParametersAtSpec | 722 | 150 |
| FunctionLocalAtSpec | 713 | 134 |
| FunctionLocalsSpec | 794 | 153 |
| ParameterFrameSpec | 697 | 142 |

## Hypothesis, scope and next gate

The already established checked character normalization removes literal UTF-8
decoding before the unchanged alphabet/fuel/lexer calculation. A separate
`FunctionParameterLocalHeaderTokens` module preserves the previously successful
loop and two-header helpers and their object caches. Each of these six leaves
rewrites its exact expected-token theorem, then checks the original complete-
source equality with an explicit `kernel_exact` witness. No public statement,
source extractor, source byte, specification terminator, duplicate check,
contract, domain or obligation changes. No shorter/successful leaf or different
source-proof family is rewritten.

The next gate is one focused batch containing all six leaves and the entire new
helper contract. The managed start reason records this hypothesis and scope.
It uses one Lake worker, automatic 12 Lean threads, the original 8,192 MiB
threshold, a 10 GiB source-tree guard and 1.5 GiB host-headroom guard, coordinated
with native two-worker validation and the certificate's bounded line buckets.
The input source/scripts remain frozen at `8a03ab122`. A complete caller retry
follows only after focused success and independent review.

The reused wrong-character and omitted-token controls exercise the unchanged
kernel_exact/String.toList_ofList/lexer mechanism. Independent review separately
compares each exact string, both character lists, token lists and full-source
unique-header extraction. Earlier ordinary-body fixtures are not relabeled as
header-extractor tests. The completed batch outcome is recorded below.


## Focused success and retained identity

Managed run `20261115T180831-555601b89ece` completed on Linux aarch64 using
Lean 4.34.1. All six changed leaves and the new helper passed, followed by a
fresh imported-module axiom audit of **112 modules / 15,639 declarations**.
Only `propext`, `Classical.choice` and `Quot.sound` occur. The focused build
elapsed 318.152 s, its audit 2.301 s and the managed run 326.604 s. Successful
unchanged dependencies were reused; this is neither a clean build nor an
independent kernel replay or a complete source checkpoint.

The process peak was 3,861,312 KiB RSS and the process-tree peak 4,909,936 KiB;
minimum sampled host availability was 10,257,968 KiB. The existing 8,192 MiB
per-process threshold, one Lake worker and automatic 12 Lean threads were
retained. Neither the 10 GiB tree guard nor the 1.5 GiB host guard fired; the
monitor recorded normal exit 0 and no interruption.

`focused-success-evidence.json.gz` retains every input, workspace, tool and
artifact digest. `focused-success-runner.log.gz` decompresses to the exact
managed log named by its `log_sha256`:
`d11bb66ebb03d7c4796ceb142907bc3313f5b7f1275d804f218da8e8092f5e5b`.
The outer launcher log, resource samples and monitor summary are separately
retained. `input-review.json` verifies all recorded input hashes against the
frozen final files, the six byte-identical public theorem statements and the
unchanged native source/scripts. Independent review separately checked the
exact character/token copies and unique header matches across all 72,713
reviewed source tokens; its final evidence review is recorded separately.

The successful seven-file production delta is frozen for the next focused
`Silver.FunctionSourceCandidate` caller gate. The caller retains the original
full source and every contract/uniqueness check, the same resource allocation
and controlled stop on its first new explicit kernel-memory failure. Full
native, source/facade, module/axiom, provenance and regression assurance remain
outstanding and are not inferred from this focused result.
