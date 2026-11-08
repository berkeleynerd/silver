# Parameter_Frame invalid-entry guard — focused native success

The single authorized focused native run
`20261108T084757-1036cb8a0958` passed all 29 selected checks on Linux x86-64.
The managed run finished successfully at `2026-11-08T08:49:20.762418Z` after
82.341 seconds; its execution session was polled for actual exit code 0.
This proves the selected subprogram's native obligations under its unchanged
contracts. It is not a complete compiler/provenance audit, Lean/source check,
sample/regression result or language delivery.

## Exact authorized change

Source-only commit `b8365c0606e0d2e185e89a73264b10cf72530e06` adds only:

```ada
if Frame.Position = 0 then return Invalid_State; end if;
```

The guard is at line 5714 of `src/silver_output_profile.adb`, immediately
before Parameter_Frame's loop. Declarations, preconditions, postconditions,
models, input domain and every nonzero-position case remain unchanged.
The exact reviewed patch SHA-256 is
`3d5c30f933b62ae9ce485de9ce9aebed6e591d1de8ee0c2aa753c56800d432ba`.
Parser body SHA-256 changes from
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f` to
`e23559aa4b480bb4f69df99fb9c28c590ef9320388dc48c44e2604dd5226918c`.
Before/after source and exact patch bytes are retained and indexed.

The reviewer and coordinator supplied an allowed witness: `Text = "x"` and
`Frame = (Invalid_State with delta First_Parameter => 1)`. The unchanged
preconditions admit that zero-position frame. With no parameters, the old
loop executes zero times and returns the noncanonical Frame, while
Parameter_Frame_Model returns Invalid_State. The guard returns the canonical
state before that path. No precondition or model is weakened to hide the
mismatch.

## Complete selected obligation coverage

The command selects the entire Parameter_Frame implementation using
`--limit-subp=silver_output_profile.adb:5710`, without a line/check limit.
It retains `--mode=all --report=all --warnings=error --checks-as-errors=on`,
level 2, CVC5/Z3/Alt-Ergo and the original 30-second prover timeout, with four
managed workers. No timeout increase, proof suppression, automatic retry or
second validation run was used. Exact invocation, tools and captured inputs
are in `run/events.jsonl.gz`.

`obligation-inventory.json` records one selected subprogram and one SPARK
report, with 27 proof and two flow records, all severity `info`. The 27 proof
records contain 82 proof-tree branches, all discharged. The combined runtime
and static postcondition record has 14 branches, all discharged, covering the
early invalid return and remaining loop/return paths in the complete selected
body. Runtime checks, precondition calls, loop invariant initialization and
preservation, and loop variant checks are all included. No skipped proof/flow,
pragma Assume, warning or unresolved record remains. The saved Why3 session's
single root is proved; the exact session, shapes and generated task input are
retained separately from the report inventory. All 100 saved session goal
nodes are marked proved.

## Isolation and retained evidence

Outputs use `compiler/obj/explore/parameter-frame-entry-guard/gnatprove` and a
separate scratch solver cache. The standard reviewed project, its declarations
and native compiler sources remain the selected proof inputs. All writable
workspace/cache paths are declared to the managed runner. Before launch, the
shared pool had 22 CPUs and one reserved worker; this run reserved four.

The canonical failed full-run reports, saved sessions and solver cache were
preserved. `canonical-preservation.json` records identical path, size and
mtime metadata before/after for 114,530 files totaling 2,895,997,324 bytes.
This preservation check compares metadata; it is not a fresh byte-hash audit
of those canonical directories. The full baseline inventory is retained in
`reviewed-inputs/canonical-before.json.gz`.

`index.json` identifies every retained gzip artifact by uncompressed SHA-256
and size: managed log/events, SPARK/SARIF/text summary, solver config, complete
selected session/shapes/generated task, exact reviewed patch and source,
native/generated source and project/toolchain inputs, and pre-run resource
readout. `artifact-verification.json` records checksum/size and exhaustive
index verification for all 155 gzip artifacts, plus matching hashes for retained
native inputs against the managed preflight snapshot. No scratch cache or
canonical artifact was deleted.

The [earlier full audit](../warning-cleanup/README.md) remains failed and its
four unresolved obligations remain historical. This focused result addresses
Parameter_Frame only. The other three parser postconditions, complete native
build/obligation/coverage/provenance audit and applicable Lean/source assurance
remain outstanding. No additional source repair, push, integration or merge is
part of this evidence commit.
