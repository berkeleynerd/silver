# Guard proof timing observation — 2026-10-26

Captured 2026-10-26T12:37:41.111835+00:00. This packet answers the owner's performance question using retained Linux x86-64 evidence. No proof/test runs or optimization experiments were launched. Only this scratch directory was written.

The source verification rebuilds grew materially:

| Lean module | Division | Guard | Guard / division |
| --- | ---: | ---: | ---: |
| OutputBodyCertificate | 3,910 s (65m 10s) | 9,037 s (150m 37s) | 2.31× |
| PredicateSourceCandidate | 908 s (15m 08s) | 5,082 s (84m 42s) | 5.60× |
| ComposeSourceChecks | 3,454 s (57m 34s) | Pending in captured log | — |

These are actual successful module builds, with integer seconds as reported by Lake. Both runs selected **four Lake workers and two Lean threads**, without clean/replay mode or an explicit memory limit. Division run `20261025T224628-2bc4dc5ed3d3` later failed in `Silver.ScalarsNativeSourceChecks`; the compared modules passed. Guard run `20261026T094105-ac4e120bd9f9` has **no complete build/audit success at this capture**.

The retained [division log](division-lean-build.log) preserves the original baseline log: Predicate at original line 191, Output at 215, Compose at 222, and overall failed build at 227. The [guard log snapshot](guard-lean-build.observed.log) preserves successful Predicate/Output at lines 6/7. Original paths, hashes and exact run event/line references are in [comparison.json](comparison.json) and [run-metadata.json](run-metadata.json). The metadata file contains selected fields and raw event-line hashes; large source/tool inventories are omitted.

Native tool time grew from **5,776.007 s to 7,282.943 s (+26.1%)**, with **15,224 → 16,357 total checks (+7.4%)** and **four → six workers**. Division tool phase: 2026-10-26 00:29:04.109296 to 02:05:20.115978 UTC. Guard tool phase: 08:43:23.569064 to 10:44:46.512130 UTC. The guard tool returned zero and proved all checks, then its evidence audit rejected array-initialization warning records. The later cached complete native run `20261026T121322-fc9f4056f886` passed in **80.192 s total (54.616 s native tool)**. That cached result is distinct from the rebuild timing. [Summary excerpts](native-summary-excerpts.txt) retain the original line-19 check totals and original-file hashes.

The checked-in division/guard delivery representations (`a5305f1b04` / `d4d564cf35`) contain:

| Source | Division bytes / lines | Guard bytes / lines |
| --- | ---: | ---: |
| src/silver_output_profile.adb | 98,810 / 1,821 | 179,103 / 3,138 |
| proof/Silver/OutputBodyCertificate.lean | 7,757,780 / 27,364 | 14,862,127 / 47,123 |
| proof/Silver/PredicateSourceCandidate.lean | 34,488 / 605 | 39,036 / 690 |
| proof/Silver/ComposeSourceChecks.lean | 68,264 / 629 | 71,074 / 649 |

Exact SHA-256 values are in `comparison.json`. Native-source and handwritten-module hashes match the respective run-start input inventories. The generated certificate is absent from those inventories: its values describe the checked-in delivery representations, with the guard representation also matching the current timed workspace. No historical generated baseline inventory capture or regeneration is claimed.

This is **not a controlled isolated benchmark**. Guard Lean overlapped the six-worker native run for roughly an hour; division's Output certificate finished before division native proof started. Changed sources, dependencies, caches and competing workloads limit causal attribution. The nearly doubled certificate is a plausible contributor, but these observations establish neither a scaling law nor model-quality differences. The final cached division Lean build (39.714 s) is not a rebuild baseline. No optimization work is proposed or authorized by this packet.

Proposed external-review focus: confirm extraction/run identities, source correspondence, module-versus-run outcome scope, and the cache/concurrency qualifications. The root may append final guard completion evidence later.

Evidence extraction selected GPT-6.1 Sol at Extra High; runtime settings are not independently confirmed. Token/cost measurements are unavailable.
