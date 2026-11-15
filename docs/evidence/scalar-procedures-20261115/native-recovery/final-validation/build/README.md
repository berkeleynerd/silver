# Final compiler build — 2026-11-15

Managed run `20261115T212353-b892f44c0742` succeeded on Linux aarch64 with two
workers. The retained original wrapper observed exit **0**, without interruption;
the native-tool phase also recorded exit **0**, and the managed outcome is
**success** (its overall returncode is `null`). The wrapper ran from 21:23:53 to
21:23:58 UTC; managed elapsed time was 2.05 seconds. Launch and terminal HEAD
were `dbfcac8185700eab1392e1b2f853755c9970e673`.

The compiler was compiled/bound/linked and the Image adapter was already up to
date. This was an incremental build. Both executable identities are recorded
in `binary-identities.json`. All 2,606 native inputs match launch and the complete
native audit, all 12 tool identities match, and the native manifest's 80 report
hashes remain valid. Complete native evidence is commit `b19d2fbff`.

The original monitor used the authorized 1.5 GiB host-availability guard and
five-second sampling, with no tree cap or guard trigger. This short build fell
between resource samples, so the recorded sampled RSS maximum is not an actual
peak-memory claim. The exact command, wrapper, logs, resources, managed events,
input snapshots, tool/binary identities and terminal summaries are retained in
`run-packet.tar.gz`; all 15 members were checked against `retained-files.json`.

Selected monitoring setting was GPT-6.1 Sol High; live model/effort telemetry and
token/cost measurements are unavailable. CLI memory was not updated. No regression
tests or new proof runs were launched by this build task; the complete Lean
continuation remains a separately owned checkpoint.
