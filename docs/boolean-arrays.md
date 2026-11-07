# Fixed-size Boolean arrays

**Complete on Linux, 2026-11-07, through [PR #335](https://github.com/berkeleynerd/silver/pull/335).**
[Milestone 19](https://github.com/berkeleynerd/silver/milestone/19) contains the
existing [#297](https://github.com/berkeleynerd/silver/issues/297) as one cohesive
work package. The [current delivery account](#delivery-assurance-and-validation--2026-11-07)
records complete native/build and Lean/source checkpoints, reviewed regression
reuse, integrated Rosetta metadata and the accepted delivery review target.

## Implementation decisions — 2026-11-06

The initial native candidate extends the shared array metadata with a component
kind flag. Integer and Boolean arrays share the existing descriptor and cell
budgets. Boolean initialization reserves cells in the parser's existing table;
the stored placeholder integers are bookkeeping, not the Boolean execution
model. The semantic model retains the raw Boolean initializers, exact values,
incoming-state aggregate evaluation and subsequent indexed updates.

The selected grammar uses explicit positional aggregates for multiple elements
and the existing static singleton association rule for one element. There is no
`others` shorthand or Boolean element iteration. Index expressions keep the
existing scalar-only array-index grammar and nonempty contained interval rule,
including dead arms and empty loops. Reading a Boolean cell preserves incoming
flow facts for both outcomes, just as reading a stored scalar flag does.

Resolve an existing named Integer subtype before the predefined Boolean type
mark. In particular, `subtype Boolean is Integer range 0 .. 1` followed by an
array of that subtype remains an Integer array. A draft that classified the
spelling before resolving the subtype was corrected during implementation;
regression coverage must distinguish this case from a hidden predefined mark.

The prepared driver programs were a bounded sieve through 100 and elementary
cellular automata for rules 90, 30 and 122. Scratch feasibility checks fit them
within the source budget and independently calculate their expected outputs.
Sample-only commit `4c45aa0cbb` retains both programs and independent expected
outputs. Their later native execution and current Rosetta/assurance status are
recorded in the delivery account below; this preparation itself admitted nothing.

## Implementation rounds

| Round | Selected settings | Intended outcome and result |
| --- | --- | --- |
| 2026-11-06 initial implementation | Native, semantics and source subthreads: GPT-6.1 Sol / Extra High; lead runtime setting not independently confirmed | Native candidate `260add4683` builds. Review of component-name resolution found the subtype-spelling regression, repaired in `913716ec8b`. Source/model integration remains pending. |
| 2026-11-06 shared semantic foundation | GPT-6.1 Sol / Extra High | `6f0a99541c` adds typed array metadata projections and Boolean cell semantics. Focused run `20261106T174643-4d3ab3f8f38d` passes 21 audited modules / 2,349 declarations with the approved foundations (10.373 s build, 6.870 s audit). This is partial validation. |
| 2026-11-06 proof-loop adjustment | Existing implementation subthreads; coordinated CPU reservations | The uncached exploratory parser run `20261106T174113-7f175d61085a` was interrupted after spending its work on unchanged legacy helpers. Its failed predecessor and partial results remain retained. Continued native iteration uses the original `review-final` sessions/cache on the repaired source. No full native assurance is claimed by these focused/incremental runs. |
| 2026-11-06 typed integration | Existing native, semantic and source subthreads: GPT-6.1 Sol / Extra High; lead runtime setting not independently confirmed | Integrated typed Integer projections, Boolean indexed conditions, aggregate snapshots, declaration readings and raw bound checks. Focused semantic run `20261106T182220-6d9e0a5f8f8f` passes 40 modules / 5,516 declarations; focused condition run `20261106T182828-812595b7b7ce` passes 84 modules / 9,722 declarations. Declaration modules built in later partial runs; the complete source/endpoint checkpoint remains outstanding. |
| 2026-11-06 native-domain repairs | Same implementation subthreads | Native proof diagnosed the missing explicit name-cursor guard in `Boolean_Array_After`; `b4d8a331dc` adds the existing parser guard pattern without changing declared admission. The active earlier snapshot remains retained, and the repair still needs verification. Source integration also found the model omitted the native rejection of Boolean element iteration; repair is in progress. The producer account preserves the existing 31,822,336-byte report envelope by separating Boolean comparisons from Integer component-conversion reservations; independent review remains pending. |
| 2026-11-06 source and declaration traces | Existing implementation subthreads; root initially 4 workers, then root/semantic 2+2 alongside native/source 4+4 | Native condition correspondence `26c3bdb3cb` passed focused run `20261106T185405-587bfd498383` (16,158 declarations; 13.744 s build, 8.214 s audit). Raw Boolean array trace `247996f9b3` passed `20261106T185635-e94a490c92fe` (131 modules / 17,386 declarations). Region trace `3a5f8361fb` passed `20261106T190506-21a2155d83a1` (144 modules / 17,704 declarations; 12.982 s build, 14.370 s audit). Root initializer interpretation and model-helper witnesses built in a separate 620.474 s partial run that failed the array-equation target; that run is not a successful audit. |
| 2026-11-06 capacity review and helper integration | Capacity reviewer: GPT-6 Astra / Extra High; existing implementation subthreads | Independent 293 s producer/capacity review found no blocker and retained the 31,822,336-byte envelope. Native equality proof repair `25e6fe06a3` isolates existing logical-to-Ada equality in a Static lemma without changing runtime behavior. Initializer libraries and region trace built in run `20261106T190942-1022caa80b98`; that run remains failed on array-equation rewriting. Header analysis and downstream equations are still being integrated. |
| 2026-11-06 semantic review and endpoint integration | Semantic reviewer: GPT-6 Astra / Extra High; String trace repair subthread: GPT-6.1 Sol / Extra High | Independent 350.6 s draft review found no additional central snapshot/domain defect and identified outstanding header/String trace integration plus two mechanical proof migrations. The latter were repaired in `f7e224ce64`; focused run `20261106T192233-4a921a21291a` passed 23,089 audited declarations (43.088 s build / 8.786 s audit). Body/write prerequisite `92b62c772b` passed a separate 14,750-declaration audit and is integrated. Header and per-component actual String/Character trace checks remain in progress. |
| 2026-11-06 header, source and String integration | Existing implementation subthreads; documentation preparation: GPT-6.1 Sol / High | Header and retained Sequence model run `20261106T193157-2fea6bcc3959` passed 29,129 declarations (536.943 s build / 10.230 s audit). Source/library run `20261106T194029-667da8c0974e` passed 46,619 declarations. String actual-assurance run `20261106T194718-c5f570887ac0` passed 203 modules / 21,418 declarations (53.174 s build / 7.724 s audit), preserving the endpoint statements and incoming-state component traces. Source pins and helper/authoritative wiring are integrated through `d3aafa4baf`; full source checking remains pending. Documentation preparation `06a901f47a` makes no supported or rendered delivery claim. |
| 2026-11-06 integration review and structural repair | Independent reviewer: GPT-6 Astra / Extra High; lead setting not independently confirmed | Review of `d3aafa4baf` found one medium structural-guard defect, #334, and no additional inspected admission/body/domain defect. `1da1698ac2` adds explicit prefix, grouping and root categories; `4ab30d865a` corrects the new control's relation/primary mix-up. Independent re-review cleared the repair. Focused run `20261106T195837-5846f84d4aa8` passed 18,432 declarations (18.493 s build / 7.524 s audit). This checks the guard and source-record type, not final authoritative extraction. |
| 2026-11-06 native freeze and source checkpoint | Native implementation: GPT-6.1 Sol / Extra High; bounded proof-memory diagnosis: GPT-6.1 Sol / Extra High | Native aggregate-runtime run `20261106T194221-0a4c2a4941b8` passed 57 checks, following successful guard/equality/declaration/initializer repairs. Repaired build, seven admission methods, catalogue parity and four producer probes passed. Source-policy rerun `20261106T200420-7eed53372413` passed 15 methods after certificate refresh. Integrated helper run `20261106T200514-093a13a9b4dc` failed two new Boolean-array kernel decisions at its 24 GiB threshold after 2,661.426 s; the successful reviewed-source pin is retained. A narrow literal-header proof repair is being prepared, with unchanged native inputs and proof statements. Complete native run `20261106T201636-d09ed16a345c` continues separately; applications, full regressions and complete Lean assurance remain pending. |
| 2026-11-06 helper-memory repair and scoped review | Bounded proof repair: GPT-6.1 Sol / Extra High; independent reviewer: GPT-6 Astra / Extra High; evidence documentation: GPT-6.1 Sol / High (selected settings) | Named-field isolation `f060bdd562` preserved all requirements but run `20261106T205410-9ce5cebd89e1` still failed the two old-header lexer bridges at 24 GiB; its body decision also lacked representation support (1,548.251 s build). Final repair `8102cd3898` uses exact 247/289-token expected headers and restores the representation import. Focused leaf run `20261106T212312-4dc45d97ebe4` passed 12,470 declarations (237.105 s build / 11.202 s fresh audit; only the three approved foundations). The 140 s lower-bound independent review found no scoped blocker and confirmed all 762 captured inputs match the reviewed target. Combined helper/output-lines run `20261106T213048-2ad7d6083cbb` and complete native run `20261106T201636-d09ed16a345c` are active at this checkpoint; complete source/native/regression/application evidence and support/Rosetta delivery remain pending. |
| 2026-11-06 combined source checkpoint and native diagnosis | Existing native subthread: GPT-6.1 Sol / Extra High; bounded native-equation reviewer: GPT-6 Astra / Extra High; lead runtime setting not independently confirmed | Combined helper/output-line run `20261106T213048-2ad7d6083cbb` passed 94 modules / 30,296 declarations (2,856.052 s build / 8.753 s fresh audit), with all 762 captured inputs still matching. Native full run `20261106T201636-d09ed16a345c` was interrupted after a confirmed unresolved declaration-equality assertion; its completed objects and diagnostics are retained. Field splitting and a separate expansion bridge did not prove the equality; direct inlining was rejected by the pinned tool's contract rule. These experiments remain separate from the integrated source. A longer-budget focused check of the original assertion is pending; complete native/source/regression assurance remains required. |
| 2026-11-06 shared type-word repair | Native and Lean implementation: GPT-6.1 Sol / Extra High; independent review: GPT-6 Astra / Extra High | Exact solver-input analysis isolated separate arrays for identical Boolean type-name literals. One shared native constant and two substitutions preserve contracts and behavior. The original assertion passed at normal limits in `20261106T224718-9374c3fb5301` (45.328 s); corresponding model run `20261106T225112-b305e0e70621` passed 151 modules / 21,354 declarations (334.635 s build, 8.359 s fresh audit). Integrated source/pin/certificate target `1b7140d90b` passed bounded independent review; broader native and complete authoritative-source checkpoints remain pending. |
| 2026-11-07 complete-checkpoint resource recovery | Lean monitoring: GPT-6.1 Sol / High; inherited native/regression subthreads retain their recorded settings | Complete run `20261106T230229-b9a860723df5` encountered a kernel-confirmed global OOM kill of `OutputBodyCertificate` at 00:08:27 UTC (Lean exit 137 after 2,556 s). Paused processes retained memory, and transient garbage-collection lows did not establish safe concurrent peak use. The failed run retained 175 successful module builds; `PredicateNativeShapeCandidate` was deliberately terminated to recover RAM. A third failure exposed missing Boolean-array assignment flag cases. The original full suite remains failed on a stale catalogue expectation and one unchanged 120-second sample compile deadline; successful repair reruns and independent inventory review cover all 603 distinct methods. Neither original run is relabelled successful. |
| 2026-11-07 flag integration and complete retry | Independent review: GPT-6 Astra / Extra High; Lean monitoring: GPT-6.1 Sol / High; lead runtime setting not independently confirmed | `ba23d2167c` adds the omitted Boolean-array assignment cases to `PredicateFlags` and its direct consumer `PredicateSelectors`, preserving all statements and admission premises. Both focused builds/fresh audits pass (22.628/9.558 s and 11.266/8.754 s); independent review confirms the repair and retained regression applicability. A complete one-worker retry retains successful objects and automatic 12-thread processes at the unchanged 24 GiB threshold. Native inputs are unchanged. |
| 2026-11-07 final equation and native branch repairs | Independent reviews: GPT-6 Astra / Extra High; native implementation: GPT-6.1 Sol / Extra High; monitoring: GPT-6.1 Sol / High | The one-worker retry rebuilt source reconstruction in 2,817 s and eight modules total, then exposed positional field-proof ordering in `ComposeSourceBridge`. Reviewed named-field repair `8daabd327b` passes focused run `20261107T032925-b6d64f6ff906` (318 modules / 92,000 declarations; 19.871 s build, 15.088 s audit). Native run `232644` independently exposed an unresolved `Read_Primary_Into` model-equality postcondition. One reviewed Static assertion closes both its own check and the original postcondition at normal limits in `031832` and `032305`. The older Lean run was explicitly interrupted after snapshot retention because native source will change; no paused process remains. Refreshed pin/reconstruction and two affected source-policy methods pass; complete native/helper/source checkpoints remain pending. |
| 2026-11-07 Relation false-flow repair | Native implementation: GPT-6.1 Sol / Extra High; diagnosis and independent review: GPT-6 Astra / Extra High | Complete Primary helper `032921` passed all 87 checks. The original full audit exposed a second unresolved equality in Relation. One local Static assertion closes its new assertion/call precondition in `040114` and the original assertion/call precondition in `040331`, without changed semantics, contracts or proof limits. Independent review passes both focused results. Full pin, reconstruction and one line bucket are refreshed; source-policy run `040620` passes both affected methods. Complete Relation helper `040619` and the old-source full audit remain active. The next complete Lean checkpoint waits for native source repairs to settle. |
| 2026-11-07 bounded source-leaf refresh | Execution/monitoring: GPT-6.1 Sol / High | After the complete Relation helper passed 152 checks, focused Lean run `045523` checked the refreshed full token pin and changed line bucket while the original native audit continued. Both rebuilds and the fresh eight-module / 2,543-declaration audit passed (1,417.800 s build, 7.782 s audit); all 762 captured source hashes match. This preserves usable kernel-checked objects for the later complete source checkpoint. No reconstruction or native-shape build, clean build, replay or source edit occurred in this round. |
| 2026-11-07 repaired complete checkpoint | Native execution: GPT-6.1 Sol / Extra High; Lean execution/monitoring: GPT-6.1 Sol / High | Original native run `232644` finished failed after 26,270.505 s with exactly the known Primary/Relation failures and no new failure. Complete reports and failed-helper tasks are retained; all original generated tasks remain preserved locally. Final native verification/build is being prepared on the reviewed repairs in the same installation. Complete cached Lean run `064815` has started with one worker and detailed provenance, retaining the focused pin/line successes; its 655-module build and fresh full audit remain pending. |
| 2026-11-07 closing preparation | Runtime applicability review: GPT-6 Astra / Extra High; boundary documentation: GPT-6.1 Sol / High; lead runtime setting not independently confirmed | Compared all 2,586 native inputs and twelve tool binaries with the regression build: differences are the reviewed Static assertions, installation paths and an Alire index timestamp. No baseline collection gap remains; final build applicability is pending. Documentation now records the existing sample, producer and concrete 8 MiB stack observations with their original input scope. Complete run `064815` rebuilt source reconstruction in 2,709 s; later source modules and the fresh audit remain pending. Full native run `065643` is active on the repaired source. No additional validation job was started for these records. |
| 2026-11-07 complete Lean success | Execution/monitoring: GPT-6.1 Sol / High; lead runtime setting not independently confirmed | Run `064815` passed the complete build and fresh audit: all 655 project modules / 132,101 declarations, only the three approved foundations. Build 15,008.840 s; fresh audit 14.940 s; ordinary cache reuse, one Lake worker and automatic 12-thread processes. Native run `065643`, final build/runtime applicability and Rosetta/closing confirmation remain pending. |
| 2026-11-07 closing documentation | Documentation: GPT-6.1 Sol / High; independent closing reviewer: GPT-6 Astra / Extra High, selected settings; runtime confirmation unavailable | Reconciled synchronized closeout text with complete native `065643`, ordinary final build `133600`, complete Lean `064815` and integrated/tested Rosetta `110355` (root hash comparison matches). Astra Extra High confirmed native/build/runtime applicability; only the exact committed documentation/evidence target remains for closing confirmation. No proof, build, test or render job was launched by this documentation round; wall-clock duration and token/cost measurements unavailable. |
| 2026-11-07 final delivery confirmation | Independent reviewer: GPT-6 Astra / Extra High; runtime confirmation unavailable | Accepted integrated target `2227a82686` with no blocking finding after complete native/build, Lean, runtime/regression applicability and exact Rosetta integration checks. The narrow capability is complete on Linux; PR #335 remains unmerged. No proof/build/test/render rerun was required; the review records inspection times and unavailable token/cost measurements. |

Token/cost measurements and independent runtime confirmation of the selected
subthread settings are unavailable. Historical rows preserve their original
checkpoint status; the current result is recorded below.

## Complete Lean checkpoint — 2026-11-07

Run `20261107T064815-9c9da56edf3d` passed the complete Linux Lean/source build
and fresh axiom audit on the reviewed `ce97ede446` implementation. It covers
all 655 project modules and 132,101 declarations with exactly `propext`,
`Classical.choice` and `Quot.sound`. The
[terminal packet](evidence/boolean-arrays-20261106/final-lean-after-cuts/README.md)
retains the exact inputs, module inventory, detailed provenance and earlier
resource observations. Build time was 15,008.840 seconds; the separate fresh
audit took 14.940 seconds. The run used ordinary cached objects, one Lake worker,
12 automatic threads per process and the unchanged 24,576 MiB threshold.
No clean build or independent kernel replay is claimed.

This closes the outstanding complete Lean/source checkpoint, including the
Boolean-array guard repair in #334. The original failed and interrupted runs
remain recorded with their actual outcomes. Complete native run
`20261107T065643-5c23478ef04b` and the subsequent final build have their own
status in the delivery account below.
The integrated, separately tested Rosetta metadata is recorded below. Final runtime-input
applicability, closing confirmation and reviewable publication remain governed
by the delivery closeout status; no final native result is inferred from Lean
or metadata success.

The subsequent complete Relation helper run `20261107T040619-48e6ccbe10c9`
passed all 152 checks at normal limits in 2,625.834 seconds. Both known native
failures therefore have complete helper repair evidence. The
[evidence overview](evidence/boolean-arrays-20261106/README.md#complete-primary-helper-and-relation-diagnosis--2026-11-07)
retains the exact source and outcomes separately from the later complete
Lean/source result and the native closeout status.

## Delivery assurance and validation — 2026-11-07

The implemented fragment uses predefined Boolean components, explicit positional
or singleton initialization, safe scalar-only indexes and mutable component
writes. It preserves incoming-state snapshots and typed storage without storing
predicate facts. The 4,096-byte source limit, expression/storage budgets, Oracle
and trusted boundary are unchanged. Broad `arrays`/`booleans`, Boolean element
iteration, `others`, functions #298 and sample expansion #300 remain outside it.

| Closing evidence | Actual result or outstanding confirmation |
| --- | --- |
| Complete Lean/source/module/axiom checkpoint | `20261107T064815-9c9da56edf3d`: 655 project modules / 132,101 declarations, only `propext`, `Classical.choice`, `Quot.sound`; 35 project modules rebuilt and 620 reused. Build 15,008.840 s; separate fresh audit 14.940 s; ordinary cache reuse, without a clean build or independent replay. |
| Complete native Bronze/Silver and ordinary final build | Native run `20261107T065643-5c23478ef04b` passed at 13:35:16 UTC: 17,681 checks (1,513 flow + 16,168 proof), 76 units and 1,112 owned entities, 23,909.634 s, four workers. Full forced analysis retained ordinary sessions/cache; this was not a cold proof. Ordinary build `20261107T133600-c3cee7a3d07c` passed in 9.156 s on unchanged implementation `ce97ede446`. The [native packet](evidence/boolean-arrays-20261106/final-native/README.md) and [build record](evidence/boolean-arrays-20261106/final-native/build-result.json) retain exact source/configuration/tool provenance and compiler/adapter identities. |
| Rosetta metadata and rendering | Local tested candidate `0b9a355494`; managed run `20261107T110355-fc2e8678d28a` passes all three methods, no skips/failures (3.435 s unittest; 8.093 s managed). Integrated as `21a60979b89a2651f8773fbd277033c90a7e4396`; the [integration comparison](evidence/boolean-arrays-20261106/final-rosetta/integration-comparison.json) confirms all 9 critical inputs, 1,784 rendered outputs and 471 changed source/generated hashes match the tested candidate. No governed source/proof/script/test/sample/catalogue delta from `ce97ede446` was introduced. |
| Final runtime/regression applicability | The Astra Extra High closing reviewer confirmed the native/build/runtime comparison: all 2,586 native inputs and twelve tool identities match the prepared prebuild comparison; all 131 native source inputs equal integration. Retained behavioral results remain applicable, without a rerun or repair. Exact comparison scope and the tested Rosetta/board reconciliation are retained in the [closing confirmation](reviews/review-boolean-arrays-delivery-20261107.md). |
| Exact committed source/document/render/evidence target and final closing disposition | The independent closing confirmation accepts `2227a826862ec4d7d91815f9aeeb86713fceeba9` with no blocking finding. Governed implementation remains `ce97ede446`; subsequent closure text records that disposition without changing validated inputs. |

The [regression applicability review](reviews/review-boolean-arrays-regression-applicability-20261107.md)
retains the complete sample fixture: 61 sources and 117 execution cases, including
both bounded drivers. There are 38 `rosetta_` source files. The separately tested
Rosetta metadata integrated at `21a60979b8` promotes only `fixed-boolean-arrays`;
its ordinary render has 61 Stage-1 assessments and 44 total stages. Existing stage issue fields remain
#9/#10/#229/#234 at 1, #11 at 2 and broad arrays #12 at 3. A re-render does not
select another feature or close the broad arrays issue.

The final disjoint method inventory is **588 original + one catalogue + one
manifest + seven native fixtures + one retained certificate + two source-policy
methods from `20261107T040620-63bb90cecba1` + three Rosetta methods from
`20261107T110355-fc2e8678d28a` = 603**. The original 612-execution suite remains
failed; overlapping reruns are not added to this partition. Final applicability
is based on the native/build/input and final metadata comparisons above.

Earlier failed/interrupted Lean/native attempts keep their actual outcomes.
The 31,822,336-byte producer envelope and earlier concrete 8 MiB stack executions
retain their original source/binary scopes; they are not final-binary executions
or a universal 8 MiB stack bound. No independent replay, clean build, CI or macOS
result is added by this closeout. The owner subsequently
[authorized the merge](session-memory.md#2026-11-07--boolean-array-merge-authorized)
of PR #335; #297/#334 and milestone 19 close with that delivery.

## Authorization and bounded scope

The owner instructed **“Please merge it if it is ready and proceed to the next
unit of work.”** Ready PR #332 has merged; the
[dated authorization](session-memory.md#2026-11-06--structural-guards-merged-boolean-arrays-selected-next)
identifies #297 from the recorded next-feature queue. The owner did not explicitly
name its issue number. That dated record reached main through PR #333 at
`430d206684`; #297 was then claimed under the ordinary workflow. Planning
publication/merge and implementation through reviewable publication are
authorized. The later [merge instruction](session-memory.md#2026-11-07--boolean-array-merge-authorized)
now authorizes implementation merge and its routine closeout.

Extend the fixed-array foundation to initialized, statically bounded,
one-dimensional arrays of predefined Boolean, with constant/mutable objects,
indexed reads and mutable component writes. Reuse existing Boolean expressions,
Integer index expressions, declaration ordering, finite control flow and
snapshot/update behavior. Sieve of Eratosthenes and elementary cellular automata
have bounded driver mappings in the [reconciliation record](../rosetta/assessment-boolean-arrays-20261106.md).
The current [language](../language.md) remains authoritative.

Preserve the 4,096-byte complete-source limit, existing expression and
source-derived storage budgets, Oracle guarantees, native Bronze/Silver
verification and Lean actual-source correspondence. No general containers,
dynamic/multidimensional arrays, new array-wide operations, callable routines,
capacity rewrite or Oracle amendment is selected. Functions #298 and the separate
#300 sample batch retain their existing scope.

## Admission and implementation obligations

Settle these concrete questions during bounded design, rather than treating them
as new owner approval gates:

- Specify the exact Boolean-array declaration, explicit aggregate, indexed read
  and indexed write grammar. Prefer reuse of the current positional aggregate
  and singleton association rules; assess any proposed shorthand against the
  existing source-derived component bound before admitting it. Do not silently
  add `others` or Boolean element iteration.
- Resolve predefined `Boolean`, `True` and `False` by existing Ada visibility and
  name hiding. Specify shared declaration uniqueness and loop-binder shadowing,
  initialization typing and declaration order; exclude self/forward references.
- Define exact declaration-time values, immutable snapshots and body-level
  stored-flag semantics. Reading a stored Boolean cell must not revive scalar,
  String or input-validity relations from its initializer or earlier assignment.
  Writes update exactly the selected cell, preserve other cells and bounds, and
  compose with repeated loop iterations and incoming-state RHS/index evaluation.
- Retain the current nonempty static bounds, safe inferred index intervals and
  checks in dead arms and empty loops. State the exact existing index grammar
  and nested-array-read exclusion. Account for Boolean cells and index operands
  in the existing expression/storage budgets and preserve conservative Integer
  component behavior alongside Boolean storage.
- Establish correct eager and short-circuit evaluation of Boolean component
  expressions, including unsafe operand rejection, guard facts, mutation,
  constants, name hiding and loop compositions. Do not derive index safety from
  stored flag values without an existing sound rule.

Inspect the actual native producer obligations and reports before choosing
representation or report-policy changes. Extend the affected SPARK implementation
and native verification together with Lean membership, semantics, composition,
termination, universal safety, automatic-discharge and actual-source arguments.
Preserve the author's exact admitted/proved/compiled source; successful examples
or accepted reports alone do not establish these universal claims.

## Completion and evidence

1. Integrate exact decidable admission rules, implementation and universal/native/
   Lean actual-source assurance for the entire resulting language and permitted
   compositions. Preserve existing source/token/structural checks, complete
   obligation coverage and documented trusted-boundary assumptions.
2. Add focused acceptance, rejection and boundary tests for aggregates, bounds,
   typing, visibility, constants, declaration snapshots, indexed updates, eager
   versus short-circuit safety, loop persistence, dead code and interactions
   with current String/Character/Integer/Boolean features. Select faithful bounded
   driver samples with asserted outputs before claiming Rosetta gains.
3. Update language, catalogue, samples, roadmap capability status and this record
   together. Reconcile the exact delivered Rosetta fragment with broad `arrays`
   stage #12; use a precise supported identifier or refined assessments rather
   than claiming general arrays. Update assessor current-language text and review
   metadata, re-render and maintain stage bookkeeping under
   [planning](planning.md#rosetta-progression).
4. On stable integrated inputs complete required native verification/audit/build,
   Lean/source/module/axiom checks and applicable complete regressions. Use
   [managed proof iteration](proof-iteration.md), read the run summary first,
   coordinate worker/memory reservations, retain failed outcomes and reuse
   successful evidence only when exact input applicability holds. Changed native
   and proof semantics require corresponding refreshed evidence; the preceding
   proof-only package's retained native result is not Boolean-array validation.
5. Resolve independent critical review of admission, semantic/source
   correspondence and complete resulting-language assurance. Retain exact
   implementation/review/evidence identities, material findings and dispositions,
   then publish the reviewable implementation PR. A partial increment does not
   complete #297; split issues in the same planning step if separate increments
   become necessary.

## Planning round — 2026-11-06

The bounded planning subthread selected GPT-6.1 Sol / High; runtime model/effort
confirmation and token/cost measurements are unavailable. Its deliverable is
the preceding-package closeout and this modest next-feature authorization
record, issue/milestone reconciliation and planning PR. This round changes only
documentation, performs link/consistency and whitespace checks, and runs no
native proof, Lean build or application test. Exact design assessment is a
separate bounded subthread; no new language capability or assurance result is
claimed here. No CLI recall entry was updated.

## Interim review disposition — 2026-11-06

The [capacity review](reviews/review-boolean-arrays-capacity-20261106.md)
found no blocking issue under the inherited producer premises. The separate
[semantic review](reviews/review-boolean-arrays-semantics-20261106.md) inspected
the live initialization/snapshot/domain argument. Its remaining integration
items are tracked here until the final stable checkpoint:

- Combined scalar/array header analysis: integrated and focused-checked with
  the retained Sequence model in run `20261106T193157-2fea6bcc3959`.
- Per-component raw/actual String and Character initializer checks: integrated
  through the unchanged actual-assurance endpoint and focused-checked in run
  `20261106T194718-c5f570887ac0`.
- Lexical traversal and empty Boolean analysis migrations: repaired and covered
  by the focused run above.

The [integration review](reviews/review-boolean-arrays-integration-20261106.md)
then found the new body tree's missing prefix/root categories. Finding
[#334](https://github.com/berkeleynerd/silver/issues/334) is repaired at
`4ab30d865a`, independently re-reviewed and focused kernel-checked. It remains
open until delivery to main; the complete final source checkpoint has passed.
The repair does not change native renderings, evaluations, concrete trees or admitted
programs. The first repair check remains failed: its positive test mistakenly
used a relation as a primary operand of `not`; the corrected control passed.

The [helper-memory repair review](reviews/review-boolean-array-header-memory-20261106.md)
found no scoped finding at `8102cd38980ef112bbeed69d8e082d9626f96bc9`.
Independent extraction confirms the complete native headers equal the retained
247/289-token literals. All six `Checked` requirements, actual-source checks
and authoritative source transport remain intact. The successful kernel-checked
leaf and fresh import-scope audit do not cover the combined helper or final
authoritative endpoints; their active checks are recorded in the
[evidence inventory](evidence/boolean-arrays-20261106/README.md#helper-memory-repair-and-scoped-review).

These scoped reviews retain their bounded claims. The later complete Lean/source
result, applicable regressions, native/build status and final closing review are
reconciled in the current delivery account above; no scoped review alone is
complete feature approval.
