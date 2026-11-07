# Complete Lean retry: interrupted with retained proof failure

Run `20261107T014623-e873505c3c30` ended **interrupted** on native Linux
x86_64 at `2026-11-07T03:27:27.613719+00:00`. It had already reported a
`Silver.ComposeSourceBridge` proof-assembly failure. The coordinator then chose
a native source change and explicitly interrupted this old-source checkpoint.
The interruption does not erase the earlier proof failure.

The run requested the complete project with **one Lake worker**, automatic
**twelve threads per Lean process**, and **24,576 MiB per process**. It reused
ordinary incremental objects; there was no clean build, provenance mode or
independent kernel replay. Managed elapsed time was **6,058.890480035 s**.
The managed build-interruption event records **6,050.082 s**.

The fresh whole-project module/axiom audit **never started**. There is no
successful complete-check manifest, audited declaration count or audited axiom
set for this retry. The actual project inventory is **655 modules**.

The complete retained log contains one failed module, `ComposeSourceBridge`,
with six diagnostics at `149:37`, `149:53`, `150:67`, `152:27`, `152:43` and
`155:42`. A branch-order mismatch supplied a natural-number initializer
argument to a Boolean declaration proof and left the other branch with the
wrong binders. There are no other error or warning lines in the terminal log.
The managed interruption's empty `failure_keys` array is not evidence that the
earlier proof failure disappeared.

Eight successful builds remain in the ordinary workspace cache:

| Module | Lake elapsed |
| --- | --- |
| `Silver.OutputBodyCertificate` | 2,817 s |
| `Silver.SourceCertificates` | 3.3 s |
| `Silver.Source` | 3.1 s |
| `Silver.OutputSourceBridge` | 194 s |
| `Silver.ComposeSourceChecks` | 3.4 s |
| `Silver.NamedSourceBridge` | 36 s |
| `Silver.ArgumentsSourceBridge` | 107 s |
| `Silver.LexicalSourceBridge` | 85 s |

`PredicateNativeShapeCandidate` **did not finish**. Its explicitly authorized
pause began at `03:17:12.623668 UTC`, with 956,536 KiB RSS and
27,030,368 KiB available RAM. The coordinator requested predictable memory for
a separate bounded native focus. The child was resumed at
`03:27:27.033592 UTC`, then the verified isolated runner/Lake/Shape process
group received `SIGINT` at `03:27:27.035708 UTC`. The runner recorded
`KeyboardInterrupt` and released its lease. All three owned PIDs disappeared;
no owned session process or paused child remained. The exact actions and
identity checks are retained in [resource events](resource-events.jsonl.gz)
and [cleanup verification](terminal-cleanup.json). No resource failure is
claimed for this retry.

The 1,188 five-second resource samples span `01:48:19.974880` through
`03:27:30.313862 UTC`. The highest sampled child RSS was **24,429,620 KiB**
(23.30 GiB), for `OutputBodyCertificate`; the lowest sampled available RAM
was **3,816,596 KiB** (3.64 GiB), in the same sample at `02:22:14.346935 UTC`.
No sample crossed the coordinator's 3 GiB urgent threshold. These are sampled
observations, not continuous maxima or an isolated memory benchmark.

The captured proof/source/tooling inputs were committed at
`ba23d2167c89ceb00c9493ff8eccbb3ea68b5fa4`. Before releasing the source freeze,
the terminal snapshot at `03:27:42.598970 UTC` verified that all **762** captured
inputs and both tool hashes still matched the filesystem. All captured inputs
also matched Git bytes at terminal HEAD
`1b4ab33131afb1b7035a8489f6e699e1e63264cc`. There were no input additions or
removals. All **657** workspace input hashes matched the independently retained
active-run inventory from `01:47:49.828428 UTC`, with identical shared/workspace
module sets and the authoritative `src` link. The non-provenance runner did not
separately persist its internal pre-build workspace inventory; the comparison
is precisely between the independently retained active-run and terminal
inventories. Later source repairs are separate inputs.

Retained records:

- [Result](result.json.gz), [full log](lean-proof.log.gz),
  [managed events](run-events.jsonl.gz), and [diagnostics](diagnostics.jsonl.gz).
- [Initial input correspondence](initial-input-correspondence.json.gz),
  [terminal input correspondence](terminal-input-correspondence.json.gz), and
  [terminal workspace inventory](terminal-workspace-inputs.json.gz).
- [Initial workspace inventory](initial-workspace-inputs.json.gz),
  [resource samples](resource-samples.jsonl.gz),
  [monitor policy](monitor-policy.json), and [monitor](resource-monitor.py).
- Earlier successful focused Flags/Selectors checks, their actual audited
  module closures, and [input applicability](focused-flags/applicability.json).
  Flags audited 192 modules; its only later changed input was Selectors,
  outside that closure. Selectors audited 193 modules with exactly the retry's
  captured inputs. These remain partial checks.

The original failed [packet](../final-lean/README.md) is unchanged. This retry
introduced no cache transfer or trace rewrite and retained earlier successful
objects subject to normal dependency checking. Existing cache attribution and
trusted-boundary limits remain in the parent [inventory](../README.md).
No new expensive check was started by the monitoring subthread. Its selected
settings were **GPT-6.1 Sol / High**, as assigned by the coordinator; runtime
model/effort confirmation and token/cost measurements were unavailable.
