# Complete native audit — 2026-11-15

Run `20261115T174959-94ae5c6fdf63` completed successfully on Linux aarch64
(`silver-m4pro`) at 21:19:31 UTC. The native-tool phase explicitly exited **0**;
the managed outcome is **success**, with no failure keys, and its audit phase
completed. The managed overall returncode is `null`. The original launcher's
exit status was not observed and is not claimed as zero.

The fresh terminal coverage/provenance checks passed: **19,444 required checks**,
covering 78 units and 1,232 entities, comprising 1,715 flow checks and 17,729 proof
checks. All 2,606 prepared, manifest and terminal native inputs match, all
80 manifest report hashes match, and all 12 native tool identities match.
The accepted boundary notes/advisories are enumerated in `verification.json`.

The frozen native source commit is `8a03ab12265d7753f6ea603817561c83f84ea596`;
`silver_output_profile.adb` SHA-256 is
`9ede490b6cf72b352a39072cd37f4ef39774409c6024135487cf076567b59b9c`.
Later integration commits changed Lean/evidence only. The run used canonical
full-project options, including `-U`, all flow/proof checks, warnings/checks as
errors, level 2, CVC5/Z3/Alt-Ergo, the unchanged 30-second timeout, forced analysis
and two workers. This was a full audit using an existing native result cache;
there were no initial sessions. It was not a cold run. Managed elapsed time was
12,572.65 seconds; native-tool execution was 12,567.81 seconds.

The retained full-run output-profile report also proves the repaired complete
`Array_Declaration_At` helper: 56 proof and two flow records, including the
original assertion and complete postcondition. Its `Declaration_At` caller has
11 proof and two flow records. Both have all SPARK coverage and no helper
warning/error records. Their ordinary contract-dependency claims comprise two
records each: 126 dependency entries for `Array_Declaration_At` and 52 for
`Declaration_At`. The complete boundary audit accepted those dependencies, and
`pragma_assume` is empty. [The inventory erratum](helper-dependency-erratum.json)
corrects the historical manual filter, which used scalar `entity` instead of
nested `claim.arg` and falsely counted zero dependency records. The original
archive and report snapshot remain unchanged; current `verification.json` adds
only the explicit erratum annotation to its archived original.

The original wrapper disappeared without an observed exit. Its last resource
sample was 18:39:22 UTC; the owner-authorized replacement attached at 18:43:06 UTC
after checking the native PID, command, start ticks and process group. The
approximately 224-second sampling gap remains unobserved. Both monitors used
five-second sampling and the same 1.5 GiB host-availability SIGINT guard; neither
recorded a guard trigger. Across the observed samples, maximum native tree RSS
was 7.68 GiB and minimum host available memory was 3.40 GiB. These are sampled
extrema, including concurrent Lean work in host availability, not bounds over
the gap or between samples. The native computation was never restarted.

`run-packet.tar.gz` retains exact original/attachment resource logs and commands,
managed events/native log, all reports and manifests, final input/tool snapshots,
helper inspection and CPU/session-write progress snapshots. Every archive member
was checked against `retained-files.json`; `SHA256SUMS` covers the outer packet.
`retention-verification.json` records that check. Original and managed exit
observations remain explicitly distinct in `verification.json`.

Selected monitoring setting: GPT-6.1 Sol High. Live model/effort telemetry,
and token/cost measurements are unavailable. CLI memory was not updated. This evidence
establishes the complete native checkpoint; it makes no complete Lean,
source-correspondence, regression-test, clean-build or publication claim.
