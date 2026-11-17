# Boolean token theorem relocation — focused success

The reviewed repair was accepted as
`c45fe22dc8d9834eac0688976279b79255af849c`. The retained workspace was detached
at that commit, with only unrelated `tmp/` initially untracked. The native full
audit had released its reservation. All 1,116 captured repository inputs were
verified against this commit's Git blobs before launch; see
[preflight.json](preflight.json). This run performed no proof/source edit.

The exact single-target command and rationale are retained in
[run-focused.py](run-focused.py) and [launcher.json](launcher.json):

```sh
python3 scripts/check_lean.py \
  --target Silver.ComposeBooleanDeclarationDomain \
  --workers 2 --memory-mb 8192 --provenance --task '#391' \
  --reason 'Focused Boolean token theorem relocation on c45fe22dc8d9834eac0688976279b79255af849c. Native module restored exactly; unchanged theorem moved into the existing domain module with no added imports, QName changes or warning suppression. Complete prior attempt measured 11.225 GiB aggregate RSS at 12 workers on this 16 GiB host; select two workers and automatic threads for the full focused Domain closure, covering Native and Meaning. Native may use the remaining ten managed workers. Retained 8192 MiB periodic per-process threshold and 10 GiB RSS-tree/1.5 GiB host MemAvailable guards; no clean/replay.'
```

Managed run **`20261116T231040-cddd7187b7b8` passed**. The restored native module,
the previously failing meaning module and the relocated theorem's domain module
all built. Its fresh axiom/module audit checked **141 actual imported modules
and 15,713 declarations**, using only `[propext, Classical.choice, Quot.sound]`.
The native and meaning source files are both byte-identical to their
`877c382f6d` baseline; the new theorem remains at its original fully qualified
name. No warning was suppressed. The target's complete closure, including
`ComposeStateBounds`, was covered; this was not a line-selected proof.

Validation ran locally on Linux ARM64, Lean 4.34.1, with **two Lake workers,
automatic 12 threads per Lean process and the retained 8192 MiB periodic
per-process memory threshold**. The two-worker reduction responds to the
measured 12-worker aggregate RSS guard in the first complete attempt. The
10 GiB tree/1.5 GiB host guards remained active, sampled every two seconds.
They are monitoring limits, not hard OS caps; aggregate RSS can count shared
pages more than once. Native work was allowed the remaining ten managed
workers. Peak sampled tree RSS was **2.634491 GiB**; minimum sampled host
`MemAvailable` was **14.483414 GiB**. Neither guard fired.

Build time was 19.107 seconds and fresh audit time was 1.667 seconds. The managed
evidence's elapsed time was 27.845 seconds; the supervised original terminal
elapsed time was 28.058 seconds. Tool session **`93277`** retained the original
child through terminal exit **0**. Runner PID/PGID, times, command and guard
state are retained in the launcher metadata. The worker reservation was then
released. No complete Lean check was started.

[verification-summary.json](verification-summary.json) records successful byte
verification of all **1,116 repository inputs, 1,011 workspace inputs, 6,013
compiled artifacts and two Lean/Lake tools**, plus the retained log hash.
The input digest is
`07381390554ed7262abe999a9c106f3221c7ed514efd018da7284b06b8f36904`.
Exact inventories, commands, tool identities and actual module coverage are
in [lean-focused-evidence.json](lean-focused-evidence.json). All 996 pre-run
primary-object paths remain; three rebuilt objects changed as recorded, and
the two missing focused prerequisites were rebuilt, leaving 998 primary objects.
No clean build, source/object-restoration guess or independent replay occurred.

This inherited monitoring subthread's model/effort and runtime identity are not
independently exposed; no setting is invented. The import repair was reviewed
by the parent-assigned Astra Max reviewer and the lead before this run. Native
phase/launcher timing is retained above; whole-subthread time/token/cost
measurements are unavailable. The earlier failed attempt remains failed.

This focused success discharges the relocation gate. The native report-policy
repair is being finalized in a separate worktree, so this manifest describes
the exact accepted `c45fe22dc` inputs, including that commit's report bytes.
The complete cached Lean checkpoint must capture the final integrated native
repair bytes. Unchanged applicable Domain/token proofs and cached objects can
be reused; no duplicate successful focused run is required solely because
the separately captured auditor implementation changes. The full refresh
remains held for the lead's final frozen head and resource release.
