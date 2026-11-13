# Qualified validity alias finding and checkpoint stops — 2026-11-13

Independent integration review found a permitted procedure call rejected because
`Actual_Name_Step` treats the selector in `Silver_Arguments.Input_Is_Valid` as
a read of a same-spelled writable local object. This is tracked as
[#390](https://github.com/berkeleynerd/silver/issues/390), a delivery blocker
inside #370 / PR #371. It is not deferred to the next work package.

The [review](../../../reviews/review-scalar-procedures-integration-4553fd6a11.md)
inspected implementation `4553fd6a11` with documentation at `1705ede8c9`.
It traced the declaration/prefix/body/call/source/endpoint composition and
reported no second material defect in its inspected scope. Selected reviewer:
GPT-6 Astra / Max. Runtime settings and token/cost telemetry were not exposed.
Its recorded window was 11:18:45–11:31:33 UTC; it ran no proof or test jobs.

## Confirmed behavior and regression controls

The lead ran the exact reviewer fixtures using only read-only `silver check`
at 11:27:55 UTC. The compiler was built at 09:53:54 UTC from native parser
`0bd0f4f21ae9faef7b3a4ab3bf64388b43cd1d7bf2780a40a4b353fc33b49a08`;
its binary SHA-256 was
`7b6a9a719020022df8e7b0d2a19216fc491f76ea614c7eeb3f61e76d8ee4ced5`.

| Input | Actual result | Required result |
| --- | --- | --- |
| Qualified validity query beside writable `Input_Is_Valid` | Rejected, exit 2 | Accepted: the query does not read the local object. |
| Same program with only the writable binding renamed | Accepted, exit 0 | Accepted. |
| Bare local variable read beside the same writable target | Rejected, exit 2 | Rejected: a genuine read/write alias. |

The new regression matrix covers both scalar kinds, `out`/`in out`, either
actual order, Boolean nesting and case/trivia, alongside real-alias negatives.
The existing compiled array/argument fixture now includes a qualified query and
a writable `Input_Is_Valid`; its expected observable output is unchanged. The
updated tests await the repaired compiler and final execution.

Review of the candidate identified a necessary sibling: a String slice such as
`S(1..Input_Is_Valid)` really reads the upper-bound variable. Both range and
copy-back checks are valid when its subtype is `1 .. 1`. Lead probes on the old
compiler confirmed rejection when that variable is also the writable target,
and acceptance with a distinct writable `Other`. Both controls are retained
in the alias regression. Separate procedure-name/type-hiding controls were also
checked: a procedure named `Boolean` alone accepts, while later Boolean objects
and Boolean locals reject. These are admission observations, not application
proof or complete regression results.

The initial repair design would have skipped the whole qualified query. Before
any validation run, source analysis found that it would bypass the qualifier's
ordinary identifier step and invalidate generic trace arguments. The chosen
bounded candidate instead recognizes the dot and exact validity selector,
preserving identifier traversal and explicitly excluding the second dot of
`..`. Other selected-name actuals remain excluded by the unchanged expression
grammar. Full native helper domains and matching source semantics still require
verification. Two Astra Max streams own native and Lean repairs; routine final
monitors have released their stopped workspaces. No new Oracle or language
restriction is proposed.

## Progress retained before the finding

Source chunk run `20261113T101154-12217347fb26` passed with actual exit 0:
2,961.870 s build and 26.928 s fresh audit, 22,958 declarations in 14 actual
imported modules. Seven changed chunks rebuilt; unchanged chunk 7 was reused.
It used eight Lake workers and default 22 threads while native held 14.
The 1,103 captured inputs, 996-module inventory, workspace, tools and artifacts
matched primary `1705ede8c9`. All 128 retained compiled artifacts, totalling
119,524,600 bytes, were rehashed unchanged after the later stop. Their subsequent
applicability depends on the repaired source and Lake's dependency checks.
This success is narrower than complete source assurance.

After confirmation, the lead stopped the two now-outdated final attempts:

- Native `20261113T095455-092807e929f7` was interrupted at 11:29:26 UTC after
  5,669.290 managed seconds. The owned wrapper recorded SIGINT exit `-2`;
  its outer launcher normalized this to 254. Its settings remained full/all,
  level 2, 30-second requested timeout, CVC5/Z3/Alt-Ergo, 14 workers and normal
  sessions/cache reuse. All owned descendants stopped and leases were released.
  Its 2,595 captured input copies matched launch. Only 76 unit reports were
  emitted; the two largest units and complete provenance were missing. Both
  strict audits correctly reject the incomplete attempt. The previously repaired
  `Procedure_Updates` still had only old per-entity files, so no current full-run
  discharge was claimed.
- Source aggregate `20261113T110403-d1a4bd5fcaf3` was interrupted by the targeted
  SIGINT at 11:29:42 UTC, actual exec exit 130, after 1,481.655 build seconds.
  `OutputProfileBodySource` completed, but the aggregate and fresh audit did not.
  All owned processes stopped and its eight-worker lease was released. Exact
  input/generated bytes, logs, inventory and 5,807 artifact hashes were retained.

These deliberate stops are interruptions, not successful checkpoints or new
prover failures. The earlier unexplained chunk interruption `095546` remains
separately recorded in the [resumption packet](../resume-repair-20261113/README.md).
No cache or session was deleted. Complete native and source/Lean validation,
final regressions, independent acceptance and Rosetta promotion remain pending.

## Packet contents and local artifacts

- `finding-review.tar.gz`: original independent review, inspected-input identities,
  timing, exact reproducer/control sources and static trace, plus attributed
  lead admission observations and the range/type-hiding baselines.
- `native-interruption.tar.gz`: stopped-run commands, logs, actual exit/status,
  input copies, available reports, strict audit failures, cache identity,
  diagnostic inventories and handoff. It excludes the large session archive below.
- `source-progress-and-stop.tar.gz`: successful chunk evidence/logs/events and
  artifact manifests, the exact aggregate interruption packet and handoff.
  Compiled chunk objects remain in the original source workspace; this archive
  does not contain those object files.
- `retained-files.json`: archive/report sizes and SHA-256 values.

The native work's 966 newly written generated/session files are also preserved
locally in primary `tmp/final-native-20261113/current-entity-artifacts.tar.gz`:
359,327,245 compressed bytes, 2,431,369,790 uncompressed bytes, SHA-256
`5faeb391e3fb7c688c59848d0cfc5d54ff88c8979ac1d746513c1da72407337d`.
Their exact inventory and byte-verification result are in the published native
packet, but this large diagnostic archive is not committed. It is not required
as evidence of a successful checkpoint: none is claimed for the interrupted run.
Timestamps alone do not establish a complete entity proof. Normal sessions/cache,
accepted chunk objects and all previous failed records remain at their original
local paths for reuse and diagnosis.
