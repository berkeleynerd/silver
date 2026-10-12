# Selective Lean proof tuning

The final bounded [Lean Critical Path](../roadmap.md#lean-critical-path) work is
complete. One proof-body change is adopted: check the twelve fields of
`Compose.SourceBridge.Declarations` separately with `decide +kernel`, then
assemble the unchanged conjunction. In the matched warm-dependency rebuild,
runner time fell from 171.569 to 158.564 seconds and the largest child's peak
RSS fell from 11.466 to 4.323 GiB. Memory is the main benefit; this is a modest
additional time saving after the larger reconstruction and module improvements.

The theorem statement, every computational definition, source bytes, source pins
and accepted axioms are unchanged. No language feature, new proof framework,
toolchain setting or assurance exception is introduced.

## Selection and method

The frozen input is `15ca622139`. Isolated snapshots exclude the unfinished
`ComposeAdmission.lean` language edit. Both start with independent copies of the
fully migrated warm cache from the [module migration](lean-modules.md), including
Lake metadata and all public/private/server object sidecars. Canonical tools,
caches, prior evidence and scratch are preserved.

The actual Linux x86-64 sandbox exposes 12 CPUs, about 31 GiB RAM and no swap.
The owner's 96 GB physical capacity is separate from that allocation. Runs use
Lean 4.34.1, 12 Lake workers, 12 threads per process and a 16,384 MiB per-process
threshold. Neither host allocation nor project defaults changed. A one-second
memory monitor retains samples and stops below 3 GiB available host memory;
this is not a hard aggregate cap. No cutoff triggered or competing heavy Lean
experiment ran during the comparisons.

The retained migration logs identified `ComposeSourceBridge` as a remaining
hotspot. A local text profile confirmed expensive kernel work and only 54 ms of
tactic execution. Its declaration-proof scope reported 102 seconds. These
asynchronous scopes overlap: the cumulative 383 seconds of type-checking scopes
must not be added to the 137-second build phase or treated as exclusive CPU time.
Profiling was removed before comparisons.

The matched cases force only `ArgumentsSourceBridge` and `ComposeSourceBridge`
to rebuild, preserving removed artifact copies and retaining every dependency.
Each uses the same command and fresh focused audit:

```sh
python3 scripts/check_lean.py --workers 12 --threads 12 --memory-mb 16384 \
  --target Silver.ArgumentsSourceBridge --target Silver.ComposeSourceBridge
```

| Case | Runner | Build | Fresh audit | Largest child RSS |
| --- | ---: | ---: | ---: | ---: |
| Original proofs | 171.569 s | 166.410 s | 3.621 s | 11.466 GiB |
| Both trial changes | 152.512 s | 148.252 s | 2.877 s | 4.322 GiB |
| Adopted declaration split only | 158.564 s | 154.196 s | 2.837 s | 4.323 GiB |

The adopted-only observation reduces runner time by 7.58% and peak child RSS by
62.30%. Lake's rounded `ComposeSourceBridge` time changes from 134 to 122 seconds;
the unchanged Arguments bridge takes 29 seconds in both matched cases. Summed
process-tree RSS falls from 12.341 to 5.202 GiB, but double-counts shared pages.
These are single sequential observations of two-file recompilation with warm
dependencies, not a cold build, a statistical estimate or a whole-feature
speedup. Do not multiply this result by gains from earlier workloads.

All 317 non-target compiled objects retain bytes, sizes and nanosecond timestamps
within the comparisons and match across their initial caches. This includes all
twelve certificate families and their 36 public/private/server objects. Tool
hashes, settings, target scopes and independently reconstructed input digests
match the recorded claims.

## Dispositions

- **Adopt declaration splitting.** It adds two proof lines, retains all twelve
  required facts and substantially reduces measured peak memory. The eight
  scans of the output-body token list remain; splitting does not eliminate
  those computations. No new public helper or proof interface is needed.
- **Reject lexical-equation reuse for now.** The Arguments bridge can reuse
  seven facts from the named bridge, but the single observed file saving was
  only 29 to 27 seconds. Unpacking another theorem's fourteen positional fields
  adds coupling without a material demonstrated benefit. The trial passed and
  is preserved; its source is restored before the final checkpoint.
- **Defer example and tactic rewrites.** The expensive composed examples check
  different recognizer cases and already reuse their positive admission witness.
  More detailed parser-state certificates would add complexity without a
  measured gain. `ComposeExecution` already restricts its main simplification;
  further tightening needs a separate demonstrated hotspot.
- **Defer persistent proof-state infrastructure.** These measurements concern
  already-written proofs. There is no measured AI/editor restart bottleneck to
  justify a REPL or orchestration change. Broad `SymM`/`vcgen`, opacity and
  trust-changing computation remain outside this work.

## Complete checkpoint and handoff

After choosing the final source, the complete cached check and fresh
whole-project audit passed in **8.264 seconds**: 109 modules, 33,044 declarations,
only `propext`, `Classical.choice` and `Quot.sound`. Eleven additional checked
auxiliary declarations replace the original single conjunctive decision proof;
the public theorem is unchanged. Optional independent kernel replay was not run.
The nine source-policy tests passed. Independent source and measurement reviews
found no outstanding defect; the final proof body exactly matches the checked
snapshot. The module migration's source-invalidation and private-axiom controls
retain their original evidence scope; this change leaves their machinery intact.
Compiler/SPARK inputs are unchanged, so no native compiler audit or test suite
was repeated. Their earlier evidence keeps its original attribution.

Evidence is under `.silver/linux-x86_64/proof-authoring-20261012T163327Z/`:
frozen snapshots, profiling and comparison runs, artifact inventories, memory
samples, the rejected trial, complete evidence and independent reviews.
`tmp/proof-authoring-active.json` and the local `checkpoint.md` record recovery
and publication state. All 982 canonical proof/cache files and all 1,847 migrated
seed files retain bytes, sizes and timestamps. The unfinished proof edit remains
unstaged and byte-identical. Ignored evidence cannot be recovered from a clone.

For the latest warm cache, copy `candidate/.silver/linux-x86_64/proof/` from this
evidence directory with all sidecars and Lake metadata; let the normal runner
synchronize and validate inputs. Preserve the canonical workspace and older
evidence. Never run two writers against one workspace.

The implementation/review target is the commit introducing this record, based
on `15ca622139`. This closes performance roadmap items 4 and 5. The next proposed
work is the existing-feature restriction/capacity audit and shared binding and
expression foundations; it has not begun. No new harness goal was requested;
Compose String Results remains complete. Linux validation remains primary,
Actions stays disabled, and macOS proof work remains out of scope. Checked-in
memory is updated; no CLI recall tool or conventional recall directory is
available, so no CLI memory entry was written.
