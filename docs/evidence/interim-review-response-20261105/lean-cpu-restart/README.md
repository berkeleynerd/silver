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
`Silver.ReviewedOutputShape.outputImplementation` (200,000 steps, LCNF compiler).
Independent jobs continue, preserving useful results. The captured sources stay
frozen while a bounded diagnosis examines a declaration-local budget adjustment.
The complete build and fresh audit remain pending; this record claims no
successful replacement checkpoint.

Monitoring selected GPT-6.1 Sol / High; bounded budget diagnosis selected
GPT-6.1 Sol / Extra High. Runtime model/effort and token/cost measurements were
not independently exposed. Logs and live resource samples remain under the
feature worktree's `tmp/` and will be retained with the terminal result.
