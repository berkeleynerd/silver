# Complete Lean checkpoint after native helper cuts

Terminal result recorded 2026-11-07. Managed run
`20261107T064815-9c9da56edf3d` succeeded on native Linux x86_64. The complete
incremental build and separately executed fresh module/axiom audit both exited
0. All required Lean checkpoint work is complete for the captured inputs.

The fresh audit inspected **132,101 declarations**, imported exactly the expected
**655 project modules**, and reported only `propext`, `Classical.choice` and
`Quot.sound` as foundations. The build-time audit reported the same module set,
declaration count and foundations. Lake reported **690 build jobs**; jobs are not
the project-module inventory. There is no build-versus-audit module discrepancy.

## Inputs and correspondence

The implementation is `ce97ede446aad55520e59854ea8298e2a63d56eb`. Launch HEAD was
`8d7d3033f3f65d58892dac292ed0cbf0cccdef79`; terminal HEAD was
`502bd871f97567072ac19e554de02fa2f198489f`. Later commits changed documentation;
all captured inputs are tracked and unchanged from the implementation commit.

[after-inputs.json](after-inputs.json) records independent terminal verification
of the retained run evidence against actual files and exact inventories:

- 762 shared proof, compiler and verification-script input hashes matched both
  the managed launch capture and terminal provenance, with no missing or added
  inputs in the governed inventory.
- 657 workspace proof/configuration input hashes matched, including all 655
  project modules and two configuration files.
- Both Lean/Lake tool hashes and all 3,922 `.olean*` artifact hashes matched;
  the current compiled artifact inventory exactly matched the captured inventory.
- All 36 regenerated source-certificate candidates, including the eight output
  body line modules, matched their checked-in counterparts byte for byte.
- The actual source link `.silver/linux-x86_64/src` resolved to this worktree's
  authoritative `src`, not a copied source tree.
- Exact retained log, evidence and event bytes matched the managed copies. The
  retained proof log also matched its provenance SHA-256.

The exact required module inventory is
[expected-modules.txt](expected-modules.txt), identical to the integration
review's `../final-review/expected-modules.txt`. The freshly observed imports are
[actual-audit-modules.txt](actual-audit-modules.txt).

## Build scope and timing

This was an incremental complete-project check with provenance. It retained
successful cached objects; it was not a clean build and did not use the optional
independent kernel-environment replay. The normal Lean kernel checked newly
elaborated declarations, and the whole-project axiom/module audit ran freshly.

The build log reports **35 rebuilt project modules**; the remaining **620**
project modules reused retained objects. Exact names and reported build times
are in [rebuilt-modules.json](rebuilt-modules.json); the remaining module set is
[reused-modules.txt](reused-modules.txt). In particular, this run rebuilt the full
output-body reconstruction, native-shape/body-source candidates, downstream
source bridges and correspondence, `Silver`, and `Silver.Audit`. The changed
Lines5 and refreshed full token pin had already passed the earlier focused run
`20261107T045523-be282a369adf`; those successful objects were retained here.

| Measurement | Actual duration |
| --- | ---: |
| Complete build, 06:48:28.523693–10:58:37.413727 UTC | 15,008.840 s |
| Fresh audit, 10:58:42.525676–10:58:57.465976 UTC | 14.940 s |
| Managed lifecycle, 06:48:19.907114–10:59:06.709729 UTC | 15,046.751 s |
| Check runner, including setup outside the managed lifecycle | 15,051.065 s |
| OutputBodyCertificate, as reported by Lake | 2,709 s |
| PredicateNativeShapeCandidate, as reported by Lake | 2,346 s |
| PredicateBodySourceCandidate, as reported by Lake | 2,219 s |

One Lake worker serialized the builds. `--threads 0` resolved to 12 available
CPUs per Lean process, with the unchanged 24,576 MiB process memory threshold.
There were no diagnostics, retries, suspensions, signals or limit changes.
[observation-summary.json](observation-summary.json) summarizes 296 samples:
maximum sampled Lean RSS was 23.23 GiB during output-body reconstruction;
minimum sampled available memory was 5.74 GiB at the same sample. These are
sampled host/process observations, not continuous peaks or isolated benchmarks.
The final observation contained no Lean or Lake process.

## Reproduction command and retained evidence

The command actually executed was:

```sh
python3 scripts/check_lean.py --workers 1 --threads 0 --memory-mb 24576 --provenance --task '#297 complete source checkpoint after native cuts' --reason 'Both changed native helpers passed completely; original full audit completed with only their known failures. Complete final source reconstruction, native-shape transport and whole-project audit on stable ce97 inputs; retain prior successful objects and serialize dense Lean modules after observed concurrent OOM.'
```

The terminal packet contains the exact [managed event stream](events.jsonl),
[proof log](lean-proof.log), [detailed provenance](lean-evidence.json),
[managed input capture](managed-inputs.json), terminal
[managed status](after-status.json), [candidate comparison](candidate-correspondence.json)
and [resource observations](observations.jsonl). Launch snapshots and historical
remaining-work estimates are preserved; [ACTIVE-HANDOFF.md](ACTIVE-HANDOFF.md) is
explicitly superseded by this terminal result.

Selected monitoring workload: GPT-6.1 Sol / High. Runtime model/effort confirmation
and token/cost measurements are unavailable. This round achieved complete Lean
verification and exact terminal provenance checks without source repairs or
review rework. Native proof/build/test evidence, overall capability integration,
closing review and publication remain the root's separately owned work; this
packet makes no independent claim about their current status. No files were
staged or committed by the monitoring worker.
