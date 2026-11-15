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
| Exact procedure-name loop source normalization | Selected Astra Max; live lead setting not independently exposed | Repair prepared; complete focused gate and independent acceptance pending | Complete failed attempt 120.211 s monitored elapsed; token and whole-team costs unavailable |

Complete source/facade/module/axiom/provenance assurance remains outstanding.
