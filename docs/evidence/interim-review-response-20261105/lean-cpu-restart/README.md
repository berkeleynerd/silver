# Owner-requested Lean concurrency restart — 2026-11-05

The owner requested stopping the one-worker/one-thread run and restarting with
unrestricted CPU allocation while monitoring CPU and RAM. Run
`20261105T112731-2036c05ea810` ended **interrupted**, by SIGINT to its verified
process group, at 13:35:32 UTC after 7,677.315 seconds. It did not complete its
audit. The [interruption record](interruption.json) identifies the retained raw
events and log; 252 existing `.olean` files remained in place. No clean build
or cache deletion was requested.

The feature worktree fast-forwarded to `83e8b69983` before restarting. Complete
run `20261105T133612-ecc276b25c57` started at 13:36:16 UTC with automatic CPU
settings: eight Lake workers and twelve threads per Lean process on twelve
available CPUs. The concurrent native proof retains its four-worker reservation.
The existing 24 GiB per-process memory threshold remains in effect. The command
omits both `--workers` and `--threads`; its reason records the owner's request.

A scratch monitor samples the Lean process group and host every five seconds.
It records sampled CPU cores, summed process RSS and host `MemAvailable`;
summed RSS includes shared pages and is not unique physical memory consumption.
It pauses only the Lean process group if available host RAM falls below 4 GiB,
for a resource adjustment. The host has 31.424 GiB RAM and no swap. Initial
samples through 13:39:37 UTC observed up to 8.2 CPU cores used by Lean, 8.295 GiB
summed RSS and at least 25.017 GiB host memory available. No pause occurred.
These are short sampled observations, not whole-run maxima or a speedup claim.

The build reported a compiler heartbeat limit in
`Silver.ReviewedOutputShape.outputImplementation` (200,000 heartbeat units, LCNF compiler).
Independent jobs continued with captured sources frozen while a bounded
diagnosis prepared a declaration-local budget adjustment.

Monitoring selected GPT-6.1 Sol / High; bounded budget diagnosis selected
GPT-6.1 Sol / Extra High. Runtime model/effort and token/cost measurements were
not independently exposed.

## Terminal result and next check

The replacement run ended **failed** at 16:41:00 UTC after 11,084.185 managed
seconds (11,076.023 seconds in its build phase). `OutputBodyCertificate` passed
in 11,061 seconds; its successful objects remain cached. The only module
failure was `ReviewedOutputShape` at its existing 200,000-heartbeat compiler
limit. The fresh whole-project axiom/module audit did not run.

The [terminal summary](terminal-summary.json) and
[artifact index](terminal-artifacts.json) retain the failed build log, ledger
events and sampled resources. Peak sampled CPU usage was 9.214 cores, peak
summed process RSS was 24.301 GiB, and minimum host available memory was
4.657 GiB. No pressure pause occurred. Sampling began after tool launch;
these are sampled observations, not exact maxima or a controlled speedup
comparison. The final single-module phase used roughly one core.

The prepared repair gives only `outputImplementation` a finite ten-million
heartbeat budget, matching the existing source-certificate ceiling. This is
a proposed sufficient ceiling, not a measured minimum. It leaves the token
literal, semantic statements and proof obligations unchanged. Focused validation
of that module and a complete cached build with a fresh audit remain required;
the failed replacement run is not relabelled successful.

## Later final checkpoint

The declaration-local budget repair and subsequent four-entry helper simp
cleanup are now validated by a complete cached build and separate fresh
whole-project audit. See the [final Lean checkpoint](../lean-final/README.md)
for the exact implemented input identity and retained focused/failed/final
runs. The interrupted and failed outcomes recorded above remain unchanged;
the final Lean success does not complete the independently active native proof
or overall delivery.
