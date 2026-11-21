# Final named-array regression checkpoint

Full run `20261121T211830-07948902a0f6` is still active on the frozen
`4373508bf6` inputs. Its inventory contains 785 distinct unittest identities.
It passed the sample-manifest test and started the maximal-expression compile
at 22:00:13 UTC on 2026-11-21. No complete-suite result is claimed yet.

Run `20261121T215753-de0dae34a5b9` passed all **15** tests affected by the final
proof repairs and orphan-module removal, on `7f449246ce`, in 174.128 test
seconds. It used the separate proof worktree and the remaining automatic
six-worker allocation while the full suite retained two workers. The
[independent applicability review](../../../reviews/review-named-array-audit-coverage-20261121.md)
identifies the exact readers and explains why the other baseline results can
apply once the full run completes. `proof-rerun-ids.txt` records those identities.

The test run's original events and log are retained compressed under `runs/`;
`sha256.json` records original and stored hashes. Rosetta promotion and its
affected test run remain pending. Final coverage must account for every failure
and for the final metadata before this packet can claim delivery completion.
