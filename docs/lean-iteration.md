# Focused Lean checks and simpler validation

The owner authorized this follow-up on 2026-10-11, based on `fe539a5`, and
requested a harness goal. It implements the selected runner optimizations after
the completed [source partition](lean-compartmentalization.md). The language,
Oracle, Ada implementation and certificate representation are unchanged.

## Current workflow

```sh
# Synchronize sources, build the requested module and imports, then audit them.
python3 scripts/check_lean.py --target Silver.BranchingMain

# Complete cached build, source correspondence and fresh axiom/coverage audit.
python3 scripts/check_lean.py

# Optional investigations: independent replay and detailed provenance.
python3 scripts/check_lean.py --replay --provenance
```

Targets are repeatable. Lake receives explicit module targets, avoiding a
collision with a same-named library. Focused evidence records the actual imported
modules and remains separate from complete evidence; it is partial validation.
An old complete record retains its original input fingerprint and is not made
current by a focused success. The shared `#silver_audit` command checks every
declaration originating in the selected Silver modules, including private and
generated declarations, against the same three standard Lean foundations.
The complete mode still requires the entire project in the actual import closure.

Routine checkpoints use the complete cached check. `--replay` explicitly adds
the standalone whole-project kernel recheck; `--full` is an alias. This is
incompatible with focused targets. `--clean` removes the host workspace but no
longer implies replay. GitHub Actions remains disabled repository-wide; its
unused workflow template is unchanged.

Routine results keep scope, input digest, tool identities, modules, phase timings
and logs. `--provenance` adds the large input/workspace/object inventories.
Input and tool stability, protected workspace equality, source dependencies and
cache invalidation remain checked. Replay or provenance also checks object hashes
between phases; ordinary imports rely on the pinned local toolchain and cache.
Removing the checker from the build-tool cache identity preserves existing
objects when switching replay modes or migrating the previous marker.

## Linux validation

On the existing Linux x86-64 host, with 12 workers, 12 threads per process and
the existing 12,288 MiB process threshold:

| Check | Result |
| --- | --- |
| Final focused `Silver.BranchingMain` check | 5.470 s; 14 modules; fresh axiom audit passed |
| Complete cached build and audit | 7.687 s; 98 modules; 23,516 declarations; standard axioms only |
| Certificate reuse | All twelve `.olean` files retained identical bytes, sizes and timestamps |
| Concise complete result | 4,337 bytes, compared with the preserved 53,976-byte prior record |

The complete check rebuilt only the changed audit module; the initial focused
check built the new helper. Lake refreshed hash-sidecar timestamps during
rehashing, without rebuilding certificate objects. These are warm-workspace
observations, not a controlled speedup benchmark. The earlier whole-project
standalone replay took 22.24 minutes; it was not repeated for this runner change.

Runner, platform and source-policy regressions passed. Native scratch checks
exercise fresh scoped/full auditing, prohibited and private/imported axioms,
unfinished proofs, native-evaluation axioms and disabled kernel checking. A tiny
real runner fixture confirms that an unrelated broken Lean module does not block
a focused check, source edits synchronize, and authoritative-byte changes with
preserved timestamps refuse stale results. Independent runner review found the
module/library ambiguity; explicit module targets and a regression fix it.
The tiny fixture also passed explicit fresh replay and optional provenance;
those checks did not replay production source certificates.

Evidence and preserved previous results are under
`.silver/linux-x86_64/lean-iteration-2026-10-11/`; additional isolated probes are
linked by its local validation record. No production caches were discarded.
The native SPARK implementation did not change, so its prior proof and behavior
validation were not rerun. macOS work remains out of scope.

## Remaining cost

A selected source bridge can still depend on all certificates, though unchanged
ones remain cached. The changed output-body certificate still needs its measured
roughly 64-minute rebuild at a complete checkpoint. Focused mode synchronizes
all protected inputs and regenerates the cheap candidate files; a malformed
unrelated Ada candidate can therefore stop setup. This change selects which
proofs are built and audited; it introduces no new certificate framework.
