# Serialized predicate trace: primary-stream attribution recovered

The proof build and fresh focused audit **passed**. The queue stopped only because the postprocessor required exactly one trace stream. The actual trace has one declaration/checking stream and two tiny unnamed reporting streams. No additional Lean run is needed: the unchanged interval verifier passes on an explicitly retained projection containing the original main stream, with every frame, stack, timestamp and sample unchanged.

Selected reviewer: GPT-6 Astra, Extra High; runtime confirmation and token/cost measurements unavailable. Inspection began 2026-10-27 03:49:29 UTC; extraction and verification finished 03:51:54 UTC (145 seconds). This was offline analysis only. The original raw trace, original `ranked.json`, verifier and production/source files remain unchanged.

## Exact inputs and extra streams

- Run: `20261027T025633-70e1215e4e28`, baseline commit `e94c8b4343f429c434900cc2a23e29e870f577bf`; the predicate source is unchanged by C1.
- Raw `../predicate-serialized-profile.json`: SHA-256 `e219c85bbb745e35358f61ef81872d8c979c78a4e19eb19d8952da2b977a0dac`.
- Original `ranked.json`: SHA-256 `31f23a02a3069994c87b84e9ebdd11d5fb34e53004cc3b74a91915158e573ef4`.
- Unchanged `../verify_serialized_profile.py`: SHA-256 `b129aebe642d7dc1d56797e57e4f5c141a748e503219a11c9e0f1ec98f12557a`.

Actual process samples contain the module command with `-DElab.async=false`, `-j2` and `-M16384`. Trace streams `886064` and `886477` each have only the label `Elab.async: Lean.Meta.realizeConst`, no declaration or Kernel frames, and respectively **0.010612 ms** and **0.017887 ms** of positive weight. Their long timestamp ranges are gaps between callbacks, not active intervals.

Pinned `Lean/Meta/Basic.lean:2745–2752` creates an exception-reporting snapshot callback and schedules it with `BaseIO.mapTask` independently of the `Elab.async` theorem-elaboration option. That explains why the option need not produce exactly one trace stream. The tiny callbacks do not recreate the overlapping theorem/kernel waits in the original normal-async profile.

## Preserved projection and exact conservation

`primary-stream-profile.json` retains the original profile metadata and exactly its single `isMainThread` stream. The two excluded streams remain fully available in the raw trace. The original analyzer was rerun offline on this projection to produce `ranked-primary-stream.json`; the original interval verifier was then run unchanged against that projection and ranking.

The checks establish:

- Frontend span and union of positive slices: **3,081.945176682 seconds**.
- Positive slices have maximum overlap **1** and cover the entire frontend interval.
- All **356 Kernel scopes** have maximum overlap **1**; kernel union **3,066.037617692 seconds**.
- Named exclusive elapsed time **3,079.540727514 seconds**, plus unassigned **2.404449168 seconds**, equals the frontend span within the verifier's **0.001 ms** tolerance.
- Every named declaration entry is exactly identical between original and corrected rankings. Only **0.028499 ms** of unassigned reporting time was removed from aggregate accounting.

`interval-validation.json` explicitly records the original three streams, the one-stream verification scope, excluded callback details and hashes. `ranking-status.json` marks the original ranking superseded for frontend-conservation accounting; its named ordering was not wrong. This differs from the original normal-async profile, whose per-declaration service attribution remains inconclusive.

## Useful serialized-diagnostic ranking

| Declaration | Named exclusive traced elapsed |
| --- | ---: |
| `native_flow_checked` | 284.762 s |
| `native_workers_checked` | 284.024 s |
| `native_scalarHelpers_checked` | 275.157 s |
| `native_readers_checked` | 164.331 s |
| `native_condition_tail_spec_header` | 142.816 s |
| `native_condition_model_spec_header` | 115.906 s |
| `native_relation_model_spec_header` | 114.265 s |
| `native_primary_model_spec_header` | 105.236 s |
| `candidate_adapterWrappers` | 100.456 s |
| `candidate_valid_context_body` | 80.673 s |

The first four declarations account for **32.74% of named traced elapsed time**. This is a usable localization of the serialized diagnostic's checking cost, not a production optimization or a claim about normal-async per-declaration CPU. OS scheduling, garbage collection and other untraced waiting may remain inside elapsed scopes.

The actual build phase was **3,093.775 s**, fresh focused audit **8.183 s**, and launcher wall **3,116.599 s**. Do not label launcher wall as build time. The focused audit covers 152 modules and 24,842 declarations with the standard allowed foundations; it remains distinct from the complete C1 audit. The launcher recorded largest-child RSS 12,052,068 KiB; sampled process HWM was 12,053,076 KiB. These are separate observations, not declaration allocations.

`summary.json` now records corrected attribution, actual command samples, module observations, hashes and limits. The requested deterministic archive `../predicate-serialized-profile.json.gz` was created with empty gzip filename and `mtime=0`, then decompressed and compared exactly with the raw input; archive SHA-256 is `6e22fffd0a99a57cd73d7e7ca4a719aa0ba4b4f21a5f3988c2c5c775e4774ece`. The original queue failure remains historical evidence of the overly strict postprocessing assumption. No production setting change, further profile or proof rerun is proposed.
