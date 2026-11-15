# Procedure-name loop source recovery — 2026-11-15

## Isolated complete-run failure

Complete run `20261115T214116-f50ce45f47c2` on accepted production `810d1a8e3`
(integration `a6c8c8afc`) passed the combined predicate source candidate and
several procedure-name source parts before an explicit 8,192-MiB kernel-memory
failure at `ProcedureNameSourceParts/Loop.lean:20:2`. The public `Parts.loop`
statement compares the complete `ordinaryFunction "actual_name_free"` extraction
from the unchanged whole output implementation with `SourceChecks.loopBody`.
The expected body is one exact **677-character / 134-token** literal. This
individual equality already isolates the failure; no additional probe is needed.

Original session `3798` returned outer exit 254, monitored child -2. The existing
first-memory-diagnostic source guard sent SIGINT and interrupted the subsequent
`ProcedureActualAfter` check. Monitored elapsed was 120.211 s and build elapsed
110.709 s. Peak process RSS was 8,392,464 KiB, peak tree RSS 9,435,488 KiB, and
minimum host availability 7,555,632 KiB. Neither resource guard triggered.
No complete audit occurred. The exact managed log SHA-256 is
`6b27cac327536ab0d1db932758269998141fd2d9a927671169f30abd70c75644`.

Original source, exact managed and outer logs, resources, summary and events are
retained. All 1,115 prior input, 1,010 workspace-input, 3,974 artifact and two
tool hashes still match. All prior 663 objects remain unchanged; newly completed
modules bring the retained inventory to **678** ordinary objects and 4,064
variant/hash files. Object presence does not establish a complete audit.

## Authorized bounded repair and gate

Only the proof body/imports in `ProcedureNameSourceParts/Loop.lean` and the new
`ProcedureNameSourceParts/LoopExpectedTokens.lean` change. The helper checks the
original literal's characters with the established `String.toList_ofList` /
`kernel_exact` mechanism, then its token list through the unchanged alphabet,
lexer and fuel checks. The complete original source equality remains kernel
checked. No imperative statement, invariant, variant, return or closing token
changes. The public `loop` statement, original `SourceChecks.loopBody`, other
parts, typed models, `Checked`, `checked_scanner`, native source and domains are
unchanged.

The focused target is the complete `Silver.ProcedureNameSourceCandidate`,
covering all six headers, the record, step, model, loop, structural guards and
new helper contract. Preserve matching completed objects. One worker, automatic
twelve threads and 8,192 MiB remain justified by dense single-module process
trees approaching 9 GiB on the 15.8-GiB host; native audit and build have finished.
Keep the 10-GiB tree / 1.5-GiB host / first-memory-diagnostic source-only guards.
Focused success and independent critical acceptance precede another complete
cached continuation. No clean build, replay, duplicate successful gate or other
speculative normalization is part of this repair.

| Work | Model / effort | Current result | Available cost evidence |
| --- | --- | --- | --- |
| Exact procedure-name loop source normalization | Selected Astra Max; live lead setting not independently exposed | Complete focused candidate passed; independent acceptance and whole-project continuation pending | Complete failure 120.211 s and focused success 15.018 s monitored elapsed; token and whole-team costs unavailable |

Complete source/facade/module/axiom/provenance assurance remains outstanding.

## Complete focused success and preserved objects

Run `20261115T214559-235d06a3549a` passed on production `32c6fbca5`.
Original execution session `80078` returned exit 0 with no interruption or guard.
The expected-token helper built in 448 ms, the original complete loop equality
in 3.5 s, and `ProcedureNameSourceCandidate` in 155 ms. Managed build elapsed
was 5.643 s; the fresh audit elapsed was 0.817 s and covered **116 imported
project modules / 14,774 declarations**, with only `propext`, `Classical.choice`
and `Quot.sound` as foundations. The six original headers, record, step, model,
loop and structural guards therefore pass together with the new helper.

The original loop literal, imperative statements, invariants, variant, returns,
closing tokens, complete source selector and public theorem statement remain
unchanged. Passing the same complete equality after only checked normalization
supports the established literal-decoding memory diagnosis. This remains
focused partial validation, with prior dependencies preserved rather than rebuilt.

The run used one worker, automatic twelve threads and 8,192 MiB. Monitored
elapsed was 15.018 s. Five-second resource sampling recorded peak process RSS
951,440 KiB, tree RSS 1,385,184 KiB, and minimum host availability 15,390,160 KiB;
these samples are not a precise maximum or a general resource bound.

All **1,116 input, 1,011 workspace-input, 4,082 artifact and two tool hashes**
were reverified after original terminal collection. All **678** previous ordinary
objects and 4,064 variant/hash files remain byte-identical. Exact managed and
outer logs, evidence, resource samples, summary, events and hash verification are
retained here. Exact managed log SHA-256 is
`d24a707f0efeea9ecb7240fc3022d44905eab772195939886b2b9508104ec98f`.

The textual `Silver.Audit` closure reaches all **1,009** current project modules,
with no missing project import or unreachable module. There are 681 ordinary
objects present and 328 modules without an object. This is preflight and object
presence, not a complete audit. Independent critical acceptance of the patch
and this terminal evidence, plus resource coordination, precede the next full
cached continuation. No clean build or kernel replay was performed; the passed
focused gate should be retained without repetition.
