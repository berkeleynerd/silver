# Pre-publication review incorporation audit

Inputs: frozen PR95 target ec82b4e5f2; GitHub issue87-94 API captures; owner-supplied evidence branch frozen0cd253d05b2cb650cc8fca81255e9a711765e16a, extracted /tmp/review-ec82-original-evidence/tmp/unbounded-programs-scope-review/. The review JSON contains59 findings: accuracy22, process17, technical20. It has no accepted/rejected/disposition fields. Therefore this audit tests whether proposed corrections landed; it cannot independently recover which were consciously accepted. The README claims accepted fixes incorporated but supplies no acceptance list.

Every retained issue draft A-H matches its corresponding current GitHub body exactly after substituting created.json placeholders and stripping outer whitespace: A87,B88,D89,E90,C91,F92,G93,H94. Saved comparison /tmp/review-ec82-planning/draft-vs-live.json. The notes files are terse working summaries of the structured findings; they add no separate material disposition. notes-process/A-H are earlier originals, whereas issue-drafts/A-H are final publication drafts.

## Material exceptions

1. **Process1: before-main claiming correction did not land.** The exact proposed fix ends '#{A} moves to Ready/In progress only once the entry is on main'. Published #87 drops that requirement and instead says the entry reaches main with its own completing PR. Its actual claim precedes merge by13m26s. Fixes/handoff portions landed, but the explicit timing repair did not. This supports the already identified process deviation and makes the broad claim 'their corrections are incorporated' (scope400-402, PR95 body and #87 review-publication comment) inaccurate unless accompanied by an explicit rejected disposition. No disposition is retained.

2. **Technical10: defect condition was damaged while incorporating the fix.** Proposed: 'Any check whose attempts all ended without Valid, where at least one ended in Unknown or Invalid or in a crash not attributable to resources'. Published scope139/#88 instead says 'Some check had no proving attempt and at least one attempt ended ...'. This is not equivalent: zero attempts cannot include an Unknown attempt. Defect precedence and resource/crash distinction did land. Parent assurance review owns remaining audit-policy implementability questions.

3. **Technical11: proposed fix landed but inherited its own inconsistency.** The review itself recommended application Storage_Error continues to exit1 in scope, while requiring #93 to map observable Storage_Error to4. Those instructions both landed. This does not count as an omitted fix, but the published contract remains internally inconsistent and needs reconciliation.

4. **Technical12: OOM recommendation landed, not independent assurance.** Both scope and #88 gained oom_score_adj1000 and host-risk text. The review recommendation overstates 'kernel selects them first'; incorporation is established, correctness is a separate present review question.

The other entries below mostly landed or were superseded by a broader repair. Landed here means the stated planning correction appears, not that implementation exists or that the reviewer recommendation is correct.

## Findings ledger

| Finding | Incorporation | Frozen publication evidence |
| --- | --- | --- |
| accuracy1 | Landed text; substantive sufficiency independently disputed | Scope17-24,39-69; owner wording, full stops, future proceed confirmation |
| accuracy2 | Landed | JSON71-74:17/16/1 and smoke deduplication; scope309 |
| accuracy3 | Landed | Scope309 and JSON312 distinguish losing High failures, lack diagnosis |
| accuracy4 | Landed/superseded | Scope242-247 explicit reachable producer counter; confirmation-only outcome |
| accuracy5 | Superseded by broader repair | Scope191,248-252 and #89 remove Natural reader cap, investigate producer writer |
| accuracy6 | Landed | Scope303-304 separate checked lifting and manual classification; conditional dependants |
| accuracy7 | Landed/superseded | Scope227-236:tables not probed, per-construct derivation, no host-independent premise |
| accuracy8 | Landed mechanisms | Scope115-133 and #88/#93 explicitly E2BIG4, observations and ambiguous failures |
| accuracy9 | Landed | Scope192 and #89 file read/write/ghost capacities and status2 prohibition |
| accuracy10 | Landed | Scope198-203 multiple constants |
| accuracy11 | Landed | #90 separates roles and lists domain-coupling exception |
| accuracy12 | Landed | Scope306-308 distinguishes observed tool checks and source-derived behavior |
| accuracy13 | Landed | Scope224 and JSON44-46 largest accepted size tested |
| accuracy14 | Landed | Scope214 and JSON39 every tested base2/10/16 |
| accuracy15 | Landed | Scope164-166 and #88 finite wrap description |
| accuracy16 | Landed | Scope154-157 small probe exception and #88 real-program confirmation |
| accuracy17 | Landed | Scope310,373 and JSON313 two-point fit/concurrent load |
| accuracy18 | Landed | JSON27 total tab-padded line bytes |
| accuracy19 | Landed | JSON317:16,352KiB about16.0MiB |
| accuracy20 | Landed | Scope189,194 and #92 catalogue fields/dual exponent roles |
| accuracy21 | Landed | Roadmap24-26, #87/#88 distinguish defect/inconclusive |
| accuracy22 | Landed | #87 completion evidence classes includes derived |
| process1 | **Partial; timing omitted and actual rule violated** | #87 Fixes/handoffs exist; main-before-claim clause absent |
| process2 | Landed inventory, inaccurate OS derivation remains | Scope191,238-263 lists retained capacities; root command-cap finding applies |
| process3 | Landed mechanisms | Scope115-133; #88/#93 E2BIG resource outcome |
| process4 | Landed | Scope44-69 full-stops section; roadmap63-66 |
| process5 | Landed | Scope277-282 producer/Image premises; #88 Records |
| process6 | Landed | Scope334-337 and #89/#90/#91 explicit native/Lean ownership |
| process7 | Landed | JSON27 tab-byte correction |
| process8 | Landed | JSON362 verbatim-verdict supersession note |
| process9 | Landed | Every #88-94 opening specifies dated entry on main |
| process10 | Landed/reordered | #89/#90 depend88; #91 derivationsafter87/nativeafter89/Leanafter90 |
| process11 | Landed | #87 docs/planning labels; #88 language label |
| process12 | Landed | Session-memory25-28 distinguishes gate wording from AGENTS clarification |
| process13 | Landed | #93 IntegerLast numeric pinned-target meaning |
| process14 | Landed | #89 'Once authorized' takes up deferred redesign |
| process15 | Landed | Scope91-94 bootstrap embeds, doesnotprove; confirmation keeps proving |
| process16 | Landed | Scope309 production command-j8/two variations; JSON358-360 frontend costs |
| process17 | Landed | Scope347-350 and #90/#94 explicit limits/side conditions |
| technical1 | Landed | Scope79,91-94 and #88 six library source/four unit reports |
| technical2 | Landed design correction | Scope84-87/#88 confirm WORKSPACE + identity rechecks, not SOURCE |
| technical3 | Landed mechanisms; sufficiency separately reviewed | Scope115-133 and #88 explicit imports/wait/errno/spawn/own death handling |
| technical4 | Landed | Scope360-365/#94 distinguish build vs confirmation-only resource failures |
| technical5 | Landed alternative removal | Scope227-236/#91 derive table bound; premise escape removed |
| technical6 | Landed | Scope81-89 run skipsconfirmation, compile defaultsconfirmation, interruption retainedbuild |
| technical7 | Landed/superseded | Scope191 and238-252 reader capremoved/producer caps disclosed |
| technical8 | Landed | Scope192/#89 source reads writes snapshot re-reads and ghost arrays |
| technical9 | Landed | Scope220-236/#91 dependency/source alignment derivation; #93 rederive |
| technical10 | **Partial; final wording loses noValid condition** | Scope139/#88 says no proving attempt yet at least one Unknown attempt |
| technical11 | Landed but inconsistent | Scope106 vs #93 observable StorageError4 policy |
| technical12 | Landed recommendation; not proven isolation | Scope174-176,384-386/#88 oom_score_adj1000 |
| technical13 | Landed | Scope63-65/#92 owner-decided full stop before adopting restriction |
| technical14 | Landed | Scope323-337 and #89-93 order/dependency clarification |
| technical15 | Landed | Scope158-163 per-check racing and stalled-slot risk |
| technical16 | Landed | Scope145-152/#88 retainedswitches/test_samples/why3session/doc commands |
| technical17 | Landed | #88 build-only pipeline while keeping automatic_pipeline/admitted_assurance |
| technical18 | Landed | Scope167-170/#88 reexecstack, #89 heapworkstacks alternative |
| technical19 | Landed | Scope105-109 includes check/catalogue; #88 no source admission status change |
| technical20 | Landed | Scope177-179/#88 retained workspace paths/sizes |

## Cost and side effects

Read JSON/Markdown/drafts and target documents; ran Python-only text comparisons. No code/proof/build/test execution or external mutations. Created only /tmp/review-ec82-planning/draft-{A..H}.txt, draft-vs-live.json and this audit. Token usage unavailable. Approximately8minutes additional review time; no expensive validation.
