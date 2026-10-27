# Predicate profile attribution diagnosis — #246

**Finding:** the normal-async predicate profile establishes module timing/memory and successful focused checking, but its overlapping trace durations do not establish per-declaration service costs. The original declaration ranking and summed phase/category totals are unsuitable for that purpose. Retain them only as diagnostic history. A single separately labelled serialized-predicate profile is a justified way to obtain the missing declaration ranking; do not change or repeat the matched normal-async comparison for this reason.

## Inputs and actions

Selected reviewer: GPT-6 Astra, Extra High; independent runtime confirmation and token/cost measurements are unavailable. Read-only diagnosis began 2026-10-26 21:01:57 UTC; analysis and the bounded follow-up probe were complete by 21:06:46 UTC, about 289 seconds. This review used the exact retained predicate run `20261026T200740-15b816e51f3c` at baseline `e94c8b4343f429c434900cc2a23e29e870f577bf`.

Inputs under `tmp/velocity-246-measure/` include:

- `predicate-profile.json`, SHA-256 `dbe8f0c2ad4f51e887f147d5d530a7d84897ff6f1f501dd99af8cc52a9db121b`.
- `profile/proof/Silver/PredicateSourceCandidate.lean`, SHA-256 `ab16a4e477e3fc8c21a2d4439cb7f0d902969ac3fa89a8ec053b73d6c47e4edf`.
- `analyze_profile.py`, SHA-256 `9736d2f73c4c02feea1548cf8826b8d32ad3121d2657144d9cf5049328acffe5`; `finish_profiles.py`, SHA-256 `3fd68aee35e3db963730f9e7d8eae813855644b38b0f9072559b38d21cb17f75`.
- The predicate launcher result, RSS/process CPU samples, focused managed evidence, and installed pinned Lean 4.34.1 sources. Full input hashes are retained in `profile-predicate/attribution-diagnosis.json`.

Added the bounded scratch `analyze_predicate_waits.py` and its `profile-predicate/attribution-diagnosis.json`. Preserved the old summary byte-for-byte as `profile-predicate/invalid-attribution.json`, SHA-256 `0d6e601566f7eb79d2451e0d8dc5bebac8cd73d85a70f0b5ebd8b8403bf1a00b`. Replaced `profile-predicate/summary.json` with valid module observations and an explicit inconclusive-attribution status. The raw profile and `ranked.json` remain unchanged; the latter is invalid as a service-cost ranking. Neither `measure.py`, `continue_cases.py`, production files, nor any running proof inputs were changed.


## Why the old accounting is wrong for costs

The profile contains 160 trace threads and 356 positive kernel-labelled slices. Their summed elapsed duration is **332,316.920 seconds**, while the frontend spans **3,120.989 seconds**. Kernel-labelled scopes overlap up to **158** at once. Their temporal union is **3,119.462 seconds**, including dependency waits. The analyzer partitions positive elapsed slices within each traced thread and then adds them across threads. Its conservation assertions check arithmetic consistency, not whether the slices represent active execution.

Pinned-source correspondence explains the overlap:

- `Lean/Util/Profiler.lean:252–270` emits elapsed intervals for both `weight` and `threadCPUDelta`. The latter is synthesized display data, not a measured CPU counter.
- `Lean/Environment.lean:32–82` documents environment branches joining by blocking on earlier checked-environment tasks; `toKernelEnv` at line 649 forces `env.checked.get`.
- `Lean/AddDecl.lean:185–190` places the `Kernel: typechecking declarations` trace around environment addition. That trace does not distinguish waiting for an environment from executing the checker.
- `Lean/Elab/Tactic/Decide.lean:105–118` makes `decide +kernel` synchronously add its auxiliary lemma, even while the enclosing theorem is elaborated asynchronously. Many theorem tasks therefore reach a traced check and wait for earlier environment work.

For example, `candidate_valid_body_body._proof_1_1` enters its kernel scope 13.390 seconds into the frontend and leaves at 3,120.598 seconds. Its 3,107.208-second scope cannot be interpreted as exclusive checking work. The previous observed global kernel completion occurs around 3,105.982 seconds. The roughly 14.616-second completion gap is only a temporal observation: the trace does not identify the actual service start, blocking transitions or CPU allocation. Completion-order subtraction is consequently neither an exact cost reconstruction nor a generally valid cost bound.

The new diagnosis retains labelled global completion gaps to locate events in time. It does **not** turn them into a replacement ranking. Recovering normal-async per-declaration CPU/service costs from this trace alone is inconclusive.

## Valid retained observations

The launcher measured **3,152.015 seconds (52.53 minutes)**, with 2,642.233 user and 499.127 system child CPU seconds across its subprocess tree. The sampled module process gained approximately **3,110.780 CPU seconds** over a 3,120.961-second sampled interval; missing endpoints prevent an exact module CPU total. Its sampled peak RSS was **12,456,636,416 bytes (11.60 GiB)**. The focused build took 3,131.028 seconds and its fresh focused audit 6.730 seconds; both succeeded. These are instrumented normal-async module/run observations, not a complete final audit or an unprofiled baseline.

The earlier measurement-plan review did not test whether cross-thread elapsed weights were additive service costs. This actual profile supplies new contrary evidence and supersedes that implicit attribution assumption. It does not affect the independently scheduled matched normal-async BEFORE/AFTER measurements. No historical contention or scaling conclusion follows.

## Bounded serialized-profile recommendation

At the lead's follow-up request, checked the live allocation: the correctness test run reserved two workers on the 12-CPU host. Ran one tiny two-mode comparison in the separate `async-attribution-probe/` directory, using the same installed Lean binary, twelve private `decide +kernel` theorems, two threads and a 1 GiB limit. It imported only Lean's standard library and took 4.10 seconds total; no project module was rebuilt. Exact source hash, commands, logs, raw profiles and results are retained there.

| Explicit option | Wall time | Trace threads | Peak overlapping Kernel scopes | Async scopes |
| --- | ---: | ---: | ---: | --- |
| `-DElab.async=true` | 2.194 s | 13 | 11 | present |
| `-DElab.async=false` | 1.906 s | 1 | 1 | absent |

This is a behavior probe, not a performance comparison. Pinned `Lean/Elab/MutualDef.lean:1237` chooses synchronous theorem elaboration when the option is false; `Lean/AddDecl.lean:169` then checks inline. The probe confirms that the setting removes this overlapping-theorem/future-wait pattern for the tested case.

Recommend **one** separately labelled predicate diagnostic after the existing correctness and matched cases, adding `-DElab.async=false` only to the exact module's scratch `weakLeanArgs`. Keep the same predicate source, pinned tools, one Lake worker, two Lean threads, 16 GiB threshold and fresh focused audit. Invalidate that diagnostic module's artifact family so the option is actually exercised; retain its compiler command and profile. This is a justified diagnostic repeat to recover missing attribution, not another normal-async baseline or a proposed production setting.

Before interpreting its ranking, inspect the actual profile for a single synchronous execution stream/no overlapping kernel scopes and no project option overriding `Elab.async`. Use exclusive traced kernel/elaboration elapsed time, keep frontend overhead separate, and reconcile totals with the module span and process CPU observations. Such a ranking describes the **serialized diagnostic**; elapsed spans still include OS scheduling/GC effects and are not OS CPU measurements or recovered normal-async costs. No guarantee of identical scheduling, memory or total runtime is implied. No full diagnostic rerun was started by this reviewer.

## Follow-up: Output certificate attribution

At the lead's request, inspected the retained Output profile without a rerun (approximately 21:17 UTC). Its raw input is `output-body-profile.json`, SHA-256 `05125f473908a613e71831ed4ef54c0c0d1edb978a383530b24a2f34ba8ec93d`. The existing 74.7878% line-certificate and 24.6161% reconstruction-join shares use **5,972.995 seconds of named traced elapsed time** as their denominator. They assign each positive slice exclusively within its traced thread; they are not globally exclusive wall-time or CPU-cost shares.

The line/join numerators do have small asynchronous contributions: 1.004662 seconds for lines and 0.639023 seconds for joins. Their combined 5,937.390-second traced sum consists of 5,935.746 seconds on the main thread and 1.643684 seconds on two async threads. The union of line/join intervals is 5,936.495 seconds, with 0.894458 seconds of cross-thread overlap and at most two overlapping scopes. Thus the actual line/join accounting does not exhibit the predicate's large wait multiplication. The expensive synchronous line/join location remains informative; retain the reported percentages with the named-traced-elapsed denominator and the small overlap qualification. Ordinary elapsed scopes can still include scheduling, GC or dependency waits; this inspection does not turn them into measured CPU service. No Output profile repeat is justified by this finding.
