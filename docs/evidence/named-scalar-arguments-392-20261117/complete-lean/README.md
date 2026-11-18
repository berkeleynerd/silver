# Named scalar arguments complete Lean checkpoint

The complete cached Lean check **passed** for owner-authorized #392 on native
Linux ARM64, against combined implementation
`c7388ab5d038ccbce9635ffaeec7df9189369366`. Final managed run
`20261117T064945-d458c99ae977` freshly audited **1,035 project modules and
166,332 declarations**, with only `propext`, `Classical.choice` and `Quot.sound`.
The independently compared actual audit imports exactly cover the workspace's
1,035 project modules. Original terminal `32282` was collected with exit zero.

[Final provenance](final-run/evidence.json), the [verification packet](final-run/verification.json)
and the [input/coverage comparison](final-input-and-coverage-comparison.json)
record the exact scope. All 1,142 repository inputs match both current files and
the implementation's Git blobs. The final and focused repository inventories
are identical. Independently rehashed successful provenance includes 1,037
workspace inputs, both tool executables and 6,202 compiled artifact files.
Exact repository and workspace input archives were rehashed after creation;
compiled objects remain in the preserved proof workspace with their recorded
hashes. The runner also checked unchanged inputs and artifacts around its fresh
audit. This is cached complete validation, without a clean rebuild or independent
kernel replay. Native proof and regression evidence are separately owned by the
lead; this packet does not claim their results.

The final invocation was:

```sh
python3 scripts/check_lean.py \
  --workers 1 --threads 1 --memory-mb 8192 --provenance \
  --task '#392-complete-lean' --reason 'Recorded concurrency diagnosis and cached integration'
```

The exact, longer recorded rationale and commands are in the provenance and
managed events. The unchanged external monitor imposed a ten-GiB process-tree
guard and a 1.5-GiB minimum host-available-memory guard, sampling attributed
process RSS, host memory and disk space every five seconds. Its original source
and samples are retained. None of these runs was interrupted by those guards.
Twelve CPUs were available; the reduced concurrency follows the observed memory
diagnosis below and is not a new default for other work.

| Run | Scope and outcome | Build / fresh audit | Sampled peak process / tree RSS |
| --- | --- | --- | --- |
| `20261117T040626-c2b89a81f8a6` | Original complete build failed at one module; no full audit | 9,204.338 s build wall, including 3,776.511141343 s scheduling pause / none | 8,855,264 / 9,457,536 KiB |
| `20261117T064503-a6b27d1c4b6a` | Complete unchanged `ComposeModelHelperEquations` and import-scope audit passed | 96.563 / 2.068 s | 6,834,992 / 7,928,192 KiB |
| `20261117T064945-d458c99ae977` | Complete cached project check and fresh full audit passed | 12.533 / 2.199 s | 2,628,960 / 3,722,736 KiB |

The final runner reports 20.473 seconds elapsed; its external sampling wrapper
reports 25.027 seconds, including polling overhead. The focused runner reports
104.845 seconds and its wrapper 105.146 seconds. These are elapsed wall times,
not process CPU measurements. Final minimum host availability was 14,830,656 KiB
and minimum proof-filesystem free space 2,031,857,664 bytes. Focused minimum host
availability was 8,843,184 KiB. Sampling does not establish an exact instantaneous
peak between samples.

## Failure, bounded diagnosis and retained successes

The original complete run used one Lake worker, twelve Lean threads and the same
8,192-MiB per-process threshold. Dense source candidates were serialized to avoid overlapping measured dense
peaks on this 16-GiB host; the complete native run was then using four workers
in its separate workspace. All source-candidate
chains and independent downstream successes completed and remain retained.
`Silver.ComposeModelHelperEquations` was the sole failed target. The build ended
at `2026-11-17T06:39:54.223394+00:00`; original terminal `41779` was collected with
exit one. This run remains failed history, with no completed whole-project audit.
The [failure packet](failed-full-run/verification.json) preserves its original
logs, events and resources, 1,142 inputs rehashed against the managed start, both
tools, and an independently rehashed snapshot of 1,036 workspace Lean files.
That failed-run snapshot is not a successful provenance record.

The failing module was byte-identical to its retained donor, SHA256
`e94160a583b41764b3667edd3c6ad1f276c879f5bfdb79777bdcef4794938a88`.
Four changed or new admission dependencies reached it. The donor's successful
trace used `-j12 -M8192`, but no isolated donor RSS measurement is available.
The current 60-second compile reported kernel memory errors across private
witnesses, followed by a `function expected` diagnostic. Source-ordered errors
do not identify which proof caused the memory peak. Host availability during
that module remained at least 6,903,232 KiB; the internal per-process threshold,
not an external guard interruption, caused the failure.

Independent Astra Max diagnosis recommended a bounded concurrency discriminator
before considering any proof repair. With lead authorization, the complete
unchanged module was checked with one Lake worker, one Lean thread and the same
8,192-MiB limit. It passed, including the formerly cascading diagnostic site,
and freshly audited **142 actual imported modules and 15,893 declarations** with
the same three foundations. Original terminal `17411` was collected with exit
zero. The [focused packet](model-helper-serial/verification.json) includes exact
provenance, logs, resources and archives. Its full 6,202-artifact inventory was
independently rehashed before the subsequent complete build; later changes to
out-of-scope importers do not alter that historical observation.

This establishes a successful concurrency setting for these exact inputs; it
does not prove a general memory bound or uniquely establish the allocation
mechanism. No source, theorem, statement, domain, axiom, heartbeat, recursion or
memory budget changed. Existing `weakLeanArgs` retained successful objects across
the scheduling change. After this focused success and retained evidence, the
lead authorized the final complete cached check, which rebuilt the outstanding
integration consumers and passed its fresh full audit. No further proof run is
needed for this packet.

## Original scheduling and preserved workspace

At `2026-11-17T04:52:29.541244+00:00`, the lead directed a resource-scheduling
pause of the original Lean child group while native proof work remained
productive. All eight generated output chunks, `OutputBodyCertificate`,
`SourceCertificates` and `Source` had passed; `ComposeContractSourceCandidate`
was in progress. A projected dense Lean peak alongside native allocation would
have left less than the existing host-memory guard. After identity verification,
only PGID/SID `401235` received `SIGSTOP`; runner `401235`, Lake `401345` and Lean
`434054` stopped while external monitor `401232` remained alive. Pre-stop tree
RSS was 2,562,320 KiB and host availability 7,548,592 KiB.

After native proof/build completion and explicit lead authorization, the same
group received `SIGCONT` at `2026-11-17T05:55:26.052388+00:00`. Every original
process identity, zero pending signals and all 1,142 input hashes were verified
first. The exact pause was **3,776.511141343 seconds**. The computation, objects,
original terminal and resource settings were preserved. Thus the failed build's
9,204.338-second wall time is 5,427.826858657 seconds after subtracting that pause;
neither figure measures CPU time. Full commands, states, memory and UTC/monotonic
timestamps are in the [scheduling record](scheduling-events.jsonl).

During the pause, a lead-requested read-only
[disk estimate](disk-assessment/README.md) allowed about 0.5 GiB for remaining
affected output and serial temporaries. The lead separately verified and relocated
inactive source checkouts to the large host mount, preserving their original
paths through binds. This stream moved nothing. Its active nativefs overlay,
source, readonly tool binds, artifacts, donors and caches remain preserved.

The source branch remains `feat/named-arguments-source-392-20261117` at `a07ace6f0`.
Borrowed pre-integration dependencies remain solely on local recovery branch
`checkpoint/named-source-inputs-392-20261117` at `69e42f548`; that checkpoint must
not be integrated. The validation branch is
`validation/named-arguments-complete-392-20261117`. The initial comparison checked
1,142 provenance inputs and all 1,182 relevant files under `src/`, `proof/` and
`scripts/` against the combined head. Only this evidence directory and scratch
changed during complete validation. The lead owns integration and publication.

The source proof/integration owner was assigned Astra Max, and the independent
memory reviewer was assigned Astra Max. The separate native evidence monitor
was assigned Sol High. These are selected assignments; live model/effort telemetry
and agent token/cost measurements are unavailable here. Native execution wall
times are recorded above, separately from the recorded scheduling pause.
No live harness goal exists, and CLI memory was not updated.
