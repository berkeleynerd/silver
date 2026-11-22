# Focused proof review of Silver PR #412 — status

**State: complete.** Final report: `report.md`. No blocker, medium or low
finding; five info-level items. No open question (`questions.md`).

- Target (verified detached HEAD at 10:47Z, 11:26Z, 11:40Z and 11:47Z; worktree clean):
  `5a4b0ad8ac05ed431d2f0c8baee2c2cc75686267`
- Base (is the merge-base of the target): `5f97477d5be1c9da974e6df95300bb8f2bb8fcfb`
- Selected model / effort: `claude-fable-5-2` / `max` (from `launch.json`)
- Observed model: the session identifies itself as Claude Fable 5.2
  (`claude-fable-5-2`); server-side effort is not observable; no fallback notice
  was seen.
- Managed run `20261122T104651-c6826d4fd799`; started 2026-11-22T10:46:54Z;
  review closed 2026-11-22T11:49Z.
- CPU affinity observed at start and end: mask `0x3` (CPUs 0–1), `nproc` = 2.
  All local computations ran serially.
- Diff size verified with Git: 10 Ada files (+771/−144); 347 Lean files
  (48 added / 299 modified), of which 8 are generated certificates; 339
  non-certificate Lean files (+18,259/−6,033).

All clock values below are from `date -u`. An early checkpoint in a previous
version of this file carried an estimated time that was wrong by about an hour;
it was replaced with measured times at 11:00Z.

## Checkpoints

| Time (UTC) | Argument examined | Result |
| --- | --- | --- |
| 10:50 | Orientation: `oracle.md`, `AGENTS.md`, feature and assurance documents, prior external and internal reviews, Git verification of the scope map | Scope map confirmed |
| 10:58 | Ada diff of all five proof-relevant units; array-binding, bindings and scalar-expression proof families | Contracts and equation domains match |
| 11:09 | Area 3 (#414 imports through Main, function and procedure paths) and Area 5 (capacity arithmetic and producer routes) | #414 repair holds on traced paths; arithmetic reproduced |
| 11:20 | Area 1/4 call, frame and composition families; typed-tree rendering; source-check pins; endpoint modules compared with base | No new endpoint premise; three info items recorded |
| 11:27 | Compose declaration dispatch, named-object header and elaboration, admission model | Dispatch order equals Ada `Declaration_At`; named path consistent |
| 11:33 | Procedure header, frame and parameter libraries; scalar-expression native model; consumers of array binding lemmas | Procedure array append is derived, not assumed; item I1 recorded |
| 11:36 | `validNameState` against its Ada body; remaining #414-named files (`ComposeSourceChecks`, `PredicateInheritedReady`, `FunctionSourceParts`) | Law equals unchanged Ada body; item I2 extended |
| 11:39 | Changed statements of 16 further families; changed definition headers of all 175 remaining small files; default-type-table hazard | Nothing beyond mechanical propagation |
| 11:46 | Capacity: remaining cited producer ranges (`gnat2why-types`, `spark_definition`, `flow-analysis` 1372–1445, `flow_utility` attributes); retained array-bindings report | Type-root and unused-formal routes corroborated; item I4 extended |
| 11:49 | Deliverables written | Complete |

## Coverage at close

Per-file record: `scratch/work/coverage-map.tsv` (339 rows).

| Class | Files | Added lines |
| --- | ---: | ---: |
| Target text read in full | 45 | 5,252 |
| Complete diff read | 68 | 3,291 |
| Partly read | 13 | 1,994 |
| Changed declaration statements only | 30 | 3,910 |
| Changed definition headers only | 175 | 2,144 |
| Not opened (generated shape tables `OutputBodyLines0–7`) | 8 | 1,668 |

The 8 generated certificates were not opened. `src/silver.adb` and
`src/silver_catalogue.adb` were not read (outside the five proof areas).

## Remaining coverage

None planned. The limits above are stated per area in `report.md` section 3 and
in section 6.
