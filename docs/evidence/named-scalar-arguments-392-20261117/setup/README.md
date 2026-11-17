# Named scalar arguments: host setup and sample expectations

Actual host: `silver-m4pro`, Linux aarch64, 12 managed CPUs, approximately
16 GiB RAM, no swap. The checkout path is a host mount, not evidence of macOS
execution. This record describes setup and static expectations, not complete
feature validation.

## Isolated workspaces and tools

The four new worktrees are under the main checkout's untracked `tmp/`:
`named-arguments-392` (lead integration/tests), `named-native-392`,
`named-model-392` and `named-source-392`. Existing delivery worktrees, original
Worca records and untracked external-review material are preserved.

The native recovery volume initially had about 5.7 GiB free. The new source
worktrees were therefore placed on the larger host mount. Native artifacts use
a real bind mount from
`/home/agent/silver-workspaces/recovery-volume/named-392-native-artifacts`
at the native worktree's `.silver/linux-aarch64`. This is not a symbolic link.
Its tool installation is an independent copy of the pinned release files;
`scripts/bootstrap.py` regenerated that worktree's configuration and validated
GNAT/GNATprove 16.1.0 and Alire package gprbuild 26.0.1 (binary reports 26.0.0).
The copied Alire index updated during setup; selected tool versions are unchanged.
The first native compiler build is fresh for this new installation root.

Both new Lean installations initially used independent regular copies on the
host mount. `bootstrap_lean.py` validated Lean 4.34.1. The first focused model
attempts then failed before compiling the new model: Lake reported an unknown
namespace and the runner hit `Errno 24`, too many open files. The shell's open-file
limit was 1,048,576; the required Lake objects existed. Failed managed runs and
their logs are retained in the [model record](../model/progress.md).

The working layout now binds the retained native-filesystem Lean installation
read-only at each new worktree's `.tools/linux-aarch64/lean`. Each proof workspace
is an independent writable overlay: the retained #391 proof workspace supplies
the immutable lower layer, and private upper/work directories under
`/home/agent/silver-workspaces/recovery-volume/named-392-lean-overlays/` receive
all new writes. The old donor is
`/home/agent/silver-worktrees/procedures-lean-370`; all ordinary, server and private
Lean objects and Lake metadata remain available. These are ordinary mounted
directories at the runner's expected paths, not symbolic links. No donor is a
writer workspace for this task. Original host-mounted copies remain under
`lean-host-mount-copy` and `proof-host-mount-retained` for diagnosis.

The next managed invocation loaded Lake and reached normal model elaboration;
the shared association helpers subsequently passed a fresh audit. This supports
the workspace-layout diagnosis, not a general performance claim. An attempted
private loop-filesystem setup could not create its device node; its unused,
task-created image was removed. The successful bind/overlay layout needs no loop
device. Setup installed the standard mount/filesystem utilities; no repository
runner, policy or tool pin was changed to bypass validation.

Retained donor identities at setup:

| Input | SHA-256 |
| --- | --- |
| `.silver/linux-aarch64/proof/.silver-cache-tools.json` | `f55c3f66a737dd818fc055670cbf3e122da8094dcd6f39db9064da62458201f7` |
| Lean executable | `79fb1d26fa5a39385d59fdc48a711a14b0710ca6480271acce99b4d177cea085` |
| Lake executable | `f80f50cbab5322e35bcb0bf88937e22e9d908b5e4e336e83ddfc30eb1506aacf` |

Copied/retained objects are cache seeds. Each managed check synchronizes its
current source inputs and freshly audits actual declarations; a seed alone is
not new assurance. Concurrent native focused work uses four workers, with the
remaining automatic grant available to light Lean targets and default process
threads. This reduction is for the current concurrent workload, not a new default.
Dense integrated checkpoints remain serialized as actual headroom requires.

## Independent sample expectations

The proposed `samples/rosetta_named_parameters.adb` uses subtraction over
`Small = -100 .. 100`, returning `Difference = -200 .. 200`. Exact integer
arithmetic gives the full range `[-200, 200]`; an independent Python enumeration
confirmed this for all 40,401 input pairs. Enumeration is an expectation check,
not the universal compiler proof.

The positional call `(5, 3)`, reordered named call `(Right => 3, Left => 5)`
and mixed call `(5, Right => 3)` all bind `Left = 5`, `Right = 3`, returning `2`.
`(Right => 5, Left => 3)` returns `-2`, making an incorrect source-order mapping
observable. Standard Integer Image adds a leading space for positive `2` and
none for negative `-2`. Including source-written labels and newlines gives:

```text
Positional: 2
Named, reordered: 2
Mixed: 2
Reversed values:-2
```

The sample manifest records those exact bytes, empty stderr and exit status zero.
Full-route compilation/execution remains required before claiming the sample
validated or promoting its Rosetta mapping.

## Final native cache preparation

The matching Alire lock permits retaining the prior canonical solver cache as
an immutable overlay lower layer. A task-private writable upper/work pair is
mounted at the new native worktree's expected canonical cache path; exact paths
and the matching lock digest are in [native-cache.json](native-cache.json).
The old integration worktree and its cache are untouched. No native report or
session was copied. GNATprove determines cache matching and validity; presence
of these entries does not establish reuse or success, especially across source
paths. The complete native run must regenerate/audit current reports and record
its actual initial cache/session state. Exploratory runs continue in their
separate `explore/named-392` directory and do not use this canonical cache.

## Native-disk headroom during complete validation

At 2026-11-17 04:35:46 UTC, the inactive source-only worktree
`/home/agent/silver-workspaces/recovery-volume/regression-391` was copied to
`/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/retained-source-checkouts-392/regression-391`.
It had no `.silver` or `.tools` directory, no active managed lease, and no
role as a cache donor. All 36,701 entries, including 29,179 regular files
(593,338,882 bytes), modes and symlink targets were checked before and after
copying. The original Git HEAD and both untracked full-route inventory files
were preserved.

A bind mount keeps the original worktree path and Git registration valid.
The original backing directory was reclaimed only after verifying the mounted
copy again and confirming unchanged Git state. The
[verification records](retained-source-relocation/relocation-result.json)
and compressed complete inventory are retained here. Native-volume free space
then measured 2,549,444,608 bytes. Neither active proof workspace, the native
canonical/exploratory caches, nor any immutable Lean/cache donor was changed.
The complete native and Lean runs continued on their original inputs.

The host-volume copy is persistent; this bind mount is runtime state. If a
new sandbox has mounted the recovery volume but has not restored this binding,
restore it before using that old worktree:

```sh
sudo mount --bind \
  /Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/retained-source-checkouts-392/regression-391 \
  /home/agent/silver-workspaces/recovery-volume/regression-391
```

This was source-checkout storage relocation, not a tool installation move or
new compiler/proof validation. The preserved copy remains outside Git staging.

At 05:41:34 UTC the same procedure preserved the inactive source-only `rosetta`
checkout at the sibling host-copy path `retained-source-checkouts-392/rosetta`.
The remaining Lean-output assessment estimated about 0.5 GiB of further writes,
so this relocation provided working headroom while retaining all active caches.
The estimate is not an output-size bound or a proof result.

All 36,456 entries, including 28,955 regular files (564,807,600 bytes), modes,
owners, symlink targets, Git HEAD `549a4d3c99d9b021ce2e38e724266df08443b06c`
and six untracked Rosetta-reconciliation files matched before and after copying,
through the mounted original path, and before reclaiming the verified old
backing. Live process, managed-lease and mount-reference checks found no user
of the inactive checkout; it had no root `.silver` or `.tools`. Complete
[verification records](retained-rosetta-relocation/relocation-result.json), the
compressed inventory and the exact relocation script are retained. Native-volume
free space then measured 2,521,255,936 bytes. Active validation and all donor
caches were unchanged.

Restore this additional runtime bind after a sandbox restart, before using
the retained old Rosetta checkout:

```sh
sudo mount --bind \
  /Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/retained-source-checkouts-392/rosetta \
  /home/agent/silver-workspaces/recovery-volume/rosetta
```

## Native-suite Lean probes

Before the complete suite, inspection found that the native compiler worktree
had no Lean installation. Six existing tests would then call `skipTest` at
runtime: the actual axiom audit, module removal, Lake settings, embedded-Ada
invalidation, generated certificates and module boundaries. Static discovery
alone identifies the two ARM64 platform skips, so it did not establish that
these six tool-dependent tests could run.

The same pinned donor installation above is now bound read-only at
`tmp/named-native-392/.tools/linux-aarch64/lean`. The authenticated distribution
archive was copied to that worktree's host-mounted tools directory;
`scripts/bootstrap_lean.py` verified its published digest and Lean 4.34.1.
Lean, Lake and leanchecker binary hashes match the donor exactly. This setup
launched no tests, complete proof or kernel replay and did not modify the donor.
The six tests will build their own small isolated probes during the final suite.

[Setup evidence](native-suite-lean-tools.json) records the read-only mount,
archive/binary hashes and bootstrap output. A subsequent read-only provenance
check verified all 2,622 native inputs and 12 native tool identities; the complete
native manifest is unchanged. The final suite must still report actual execution
of these methods and only the two expected platform skips.
