# Resumed procedure repairs — 2026-11-13

These are successful focused checks after the owner's resumption of #370.
The [previous complete attempts](../final-attempts-20261111/README.md) remain
failed. Complete native/source/Lean assurance, final regressions and independent
delivery acceptance are still pending; this packet does not promote support.

The integrated implementation is `4553fd6a11`: native author commit
`71ce4bfc23` became `4553fd6a11`, and source author commit `9247bbaf73` became
`3958b2c66d`. The exact advisory-origin repair is `faa9f17415`.

| Focused run | Actual result | Scope and settings |
| --- | --- | --- |
| `20261113T092238-18c9ef927da9` | Five auditor methods passed, 0.212 s | Two exact procedure-spec advisory origins; retained with the earlier [advisory packet](../final-attempts-20261111/README.md), without broadening a warning class. |
| `20261113T092540-3c74bc914df8` | Exit 0; 190 proof and 33 flow checks across 17 complete entities | Native equality helper, its complete dependencies, update/model/step and direct caller; eight workers alongside the focused Lean run. Wrapper elapsed 1,429.381 s; managed elapsed 1,425.235 s. |
| `20261113T092831-5df3503cfe1a` | Exit 0; fresh audit of 62,261 declarations in 518 actual imported modules | Handwritten model/render repairs and SequenceModel, 516-module static project closure; 14 Lake workers, 22 threads per process; 1,116.696 s. |
| `20261113T094850-73622441b21c` | Exit 0; fresh audit of 15,726 declarations in 106 actual imported modules | Corrected raw-native body-equality model and contract, including the dormant-bound counterexample; 105-module static project closure; 14 Lake workers, 22 threads per process; 52.215 s. |

The actual host is Linux x86_64 with 22 available CPUs. Both Lean checks reused
matching Lake objects, checked their input/workspace/tool/artifact identities and
freshly audited their selected imported scope. Neither was a clean build or an
independent kernel replay. Only `propext`, `Classical.choice` and `Quot.sound`
were admitted foundations. The first check captured 1,101 inputs and a
994-module project inventory before the two new ghost-source modules; its
summary names the nine then-unintegrated primary proof differences. The second
captured 1,103 inputs and a 996-module inventory, all matching integrated
`4553fd6a11`. Inventory size is distinct from each focused audit's scope.

## Native repair and complete-domain correspondence

`Same_Body` compares every native body discriminant/component. The Static
`Lemma_Body_Equality` derives logical equality from raw equality and retains raw
equality. Its only new caller passes the two model values already equated by
the unchanged `Procedure_Updates` loop invariant. Runtime statements, contracts,
variants and full input domains are unchanged. All prior 180 proof and 30 flow
identities remain in the focused gate; the 94 mapped warnings are unchanged.

The repaired postcondition's first branch records CVC5 Valid at 32.8704 s and
Alt-Ergo Valid at 32.9147 s, with Z3 Timeout at 30 s, under the unchanged requested
`--timeout=30` policy. No timeout increase was requested. This focused result
does not predict the final full run's outcome or establish a unique failure cause.
The native author's run captured the older auditor; the final primary audit
uses the separately reviewed advisory repair.

The first scratch Lean model compared projected paths and lost native Lower and
Upper when `Valid_Reachable=False`. Independent review found a Count=0 pair with
equal projections but unequal native records. The corrected model retains the
raw native path and complete constrained values, proves raw equality over the
full domain, and derives only forward projection preservation. Its exact
counterexample theorem passed in `094850`. The rejected proposal was never
tracked or captured by a managed proof run. This is recorded draft rework inside
#370, not a defect deferred to a successor.

The nine handwritten integration repairs restore actual procedure branches,
metadata preservation and all `out` token mappings, and supply an existing
metadata bound to an arithmetic proof. They do not narrow a theorem domain.
#375 remains open until the complete authoritative source checks succeed.

Final native parser SHA-256:
`0bd0f4f21ae9faef7b3a4ab3bf64388b43cd1d7bf2780a40a4b353fc33b49a08`.
Final auditor SHA-256:
`cd93c5abc3fccad81a46a497b54e256f7e75ee7adefa396b890f426d3eef5f71`.
Corrected ghost-source SHA-256:
`bb86b7757a1ab3081dd4ad7a78c089f571de97335786083440f6b4ad9b627fcd`.

## Retention and review

- `native-focused.tar.gz` retains the complete focused identity trial: commands,
  logs, events, 2,595 input bytesets, 64 report/session/generated-context files,
  check census, exact repair and diagnostic/handoff records. The scratch
  collector's initial null-summary/zero-exit comparison error is retained;
  correcting it required no proof retry.
- `lean-focused.tar.gz` retains both focused logs, managed events and records,
  evidence/input/artifact manifests, summaries and static comparison records.
  Compiled objects remain in the source workspace and are not embedded here.
- `review-artifacts.tar.gz` retains the complete bounded review directory,
  including exact inspected sources, both ghost proposals, the counterexample,
  patches, input identities and the original reports. Snapshot paths in reports
  are relative to that directory; absolute source paths identify the original
  local worktrees.
- `source-interruption.tar.gz` retains the interrupted chunk run's logs, events,
  status, 1,103 shared input copies, 40 generated candidates, 996-module
  inventory and hashes of 5,792 existing compiled artifacts. Compiled objects
  remain in place for dependency-checked reuse.
- `retained-files.json` binds these archives and the three copied reports by
  size and SHA-256.

Independent reports: [native equality](../../../reviews/review-scalar-procedures-native-equality-candidate-review-20261113.md),
[handwritten integration](../../../reviews/review-scalar-procedures-lean-handwritten-review-20261113.md)
and [ghost correspondence](../../../reviews/review-scalar-procedures-ghost-correspondence-review-20261113.md).
The reports preserve their original static-review conclusions and pending-check
wording; the successful focused results above are subsequent evidence, not edits
to those independent conclusions. Author and critical-review selections were
GPT-6 Astra / Max. Routine final monitors use GPT-6.1 Sol / High. Live runtime
settings, agent token/cost totals and total reasoning time are not independently
exposed; native tool elapsed time is not total team cost.

At the 10:05 UTC handoff, final native run `20261113T095455-092807e929f7`
held 14 workers and source chunk run `20261113T095546-ad54c0344e3e` held the
remaining eight; Lean process threads defaulted to 22. Both were active, with
no final outcome claimed. The remaining source sequence is chunks, aggregate,
affected source/helper/caller checks, then the complete facade/module/axiom audit
and exact generated-candidate parity. Inputs and productive caches stay frozen.

At 10:09 UTC the chunk runner, Lake and its remaining Lean children disappeared
without a phase exit, completion event or proof diagnostic. Its last productive
sample was 10:08:33 UTC, with about 56.74 GiB available. The original exec handle
was no longer known, the workspace lease was released and kernel messages had
no contemporaneous OOM. The cause is unconfirmed; agent-lifecycle cleanup is a
hypothesis, not an established cause. After preserving the interrupted run and
checking all inputs and surviving artifacts, the continuing source monitor
started one same-input resumption, `20261113T101154-12217347fb26`, with the same
automatic eight workers / 22 threads. No cache, source or proof setting changed.
Native `095455` continued uninterrupted. Both complete outcomes remain pending.
