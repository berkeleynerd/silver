# Final maximal-expression regression — 2026-11-22

Managed run `20261122T105525-650db3ffe211` passed at 12:09:08.210708 UTC.
`test_samples.SupportedSampleTests.test_maximum_dynamic_expression` passed in
4,420.116 test seconds; total managed duration was 4,421.903831695 seconds
(73m41.9s). The retained native log reports one test, OK.

The run used six managed workers, actual thread/descendant affinity on guest
CPUs 2–7, and a 16 MiB invoking stack. Its application proof/build commands
retained `-j1` and the unchanged solver policy. All 146 monitor observations
found no affinity or input-hash exceptions. Final inspection at 12:10:05 UTC
found no survivors among the observed process identities, sessions or 93 groups.
These are sampled resource observations and a final cleanup check, not a claim
of continuous tracing.

The exact test file SHA-256 is
`df8939c8470e50730597866e9c0d2364a37e644495a3f5e09531a3c60f6d7e56`.
The managed input map in `events.jsonl.gz` preserves the binary, manifest and
other input identities. The [independent applicability review](../../../../reviews/review-pr412-repair-applicability-20261122.md)
identified this as the only remaining identity. Its success completes the
reviewed composition: **783 retained passes + 4 fresh passes = 787 identities**.
No new complete suite or native/Lean proof run is claimed.

The [final independent evidence check](closeout-check.md), selected GPT-6.1 Sol
Extra High, rehashed all 1,400 prepared run inputs with zero mismatches, verified
the archived logs against their originals, and independently recomputed the
787-identity partition. It ran no new tests or proof commands.
