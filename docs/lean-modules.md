# Lean module migration

The owner authorized a coherent migration of the ordinary proof tree on
2026-10-12, superseding the earlier [pilot's deferral](lean-module-pilot.md).
The useful target is the complete proof-only rebuild, which repeated expensive
downstream elaboration while producing twenty byte-identical objects. The
four-module pilot measured only a small portion of that work.

The migration is adopted after a complete build, fresh whole-project audit,
native regression checks and independent source/evidence review. The matched
complete proof-only check falls from 213.563 to 9.573 seconds, about **22.3×**.
This measures theorem-body iteration, not a source-changing feature checkpoint
or a cold build.

## Scope

The frozen input is `140de9abd6d9078d0bd0609f04c62ba056163300`, including the
adopted [checked reconstruction witnesses](lean-join-optimization.md). Independent
Git-archive snapshots exclude the unfinished root `ComposeAdmission.lean` edit.
Both start with copies of the optimized warm cache. No language, Ada/SPARK
implementation, bound source bytes, theorem statement or approved axiom changes.

The 107 ordinary modules use `module`, public imports preserving their existing
reexports, and public sections. Computational definitions remain exposed where
current proofs reduce them. The tactic helper uses public meta imports, as do
generated certificates importing that helper. All twelve certificates regenerate
exactly from the updated generator; only its emitted preamble changes.

Removing the module annotations and the explicit compatibility imports below
recovers the previous source exactly, with one proof-script repair: the nil case of
`SourceLexer.certified_source_supported` uses `simp [compilerSource]` instead of
`rfl`. It uses the public `String.intercalate_nil` lemma because the standard
library's implementation is hidden in module mode. The statement and definitions
are unchanged. All fourteen explicitly private declarations remain private.

The six source bridges also explicitly `import all Init.Data.Repr`. Their
existing `decide +kernel` checks render concrete numbers using `Nat.repr`, whose
body is hidden in ordinary module imports. This narrow import of the pinned
standard-library implementation follows its own `Nat.ToString` proofs. It does
not import private project proofs or change any translation proof body. The
first complete build exposed this requirement after the certificates passed;
the failed log is retained and the successful certificate cache was reused.

`Audit.lean`, `AxiomAudit.lean`, the runner and Lake configuration remain
unchanged. The complete and generated focused audit drivers deliberately remain
legacy files: they load transitive private declarations, including unused
assumptions. A module audit importing all data only from the top facade would
miss deeper private declarations. Ordinary consumers use module interfaces;
the fresh audit still inspects the complete selected environment.

This preserves the broad current computational interface. Proof-body edits to
ordinary theorems can stop at their defining module. Changes to exposed
definitions, theorem statements or proof-bearing public data can still rebuild
consumers. This is not an opacity redesign or a promise that every proof-related
edit becomes local.

## Matched measurement

The Linux x86-64 sandbox exposes twelve CPUs, approximately 31 GiB RAM and no
swap. Both comparisons use pinned Lean 4.34.1 and:

```sh
python3 scripts/check_lean.py --workers 12 --threads 12 --memory-mb 16384
```

The 16,384 MiB threshold gives more headroom than the previous 12,288 MiB
comparison. It is Lean's periodically checked per-process threshold, not an
aggregate OS memory limit. The owner-reported 96 GB physical RAM is not all
visible to this sandbox. No host allocation or default changes here.

The measurement wraps the original proof of
`Silver.Compose.Expression.left_association` in `Eq.trans` with `rfl`, preserving
its statement and every definition. It uses the current optimized inputs for
both versions. Complete checks include a fresh whole-project axiom/coverage
audit; optional independent replay is not selected. Timed cases have no
concurrent heavy Lean work. The initial migration rebuild is recorded separately
from warm no-change and proof-edit measurements.

| Complete check | Runner | Build | Fresh audit | Rebuilt modules |
| --- | ---: | ---: | ---: | ---: |
| Baseline, no change | 8.409 s | 2.642 s | 4.299 s | 0 |
| Baseline, proof edit | 213.563 s | 209.279 s | 2.883 s | 21 |
| Migrated, no change | 6.403 s | 1.980 s | 2.987 s | 0 |
| Migrated, same proof edit | 9.573 s | 5.063 s | 3.032 s | 2 |

The baseline rebuilds twenty byte-identical `.olean` consumers after changing
the provider. After migration, only `ComposeExpression` and the legacy `Audit`
rebuild. All nineteen ordinary downstream consumers, including the umbrella,
retain all three object variants' bytes and timestamps. The edited provider's
public `.olean` remains byte-identical while its server/private objects change.
All twelve certificates remain cached in both proof-edit cases. The no-change
cases rewrite no compiled objects. These are single matched observations,
supported by the exact rebuild/artifact comparison, not a statistical benchmark.

The sampled summed process-group RSS peak falls from 19.09 to 2.41 GiB in the
proof-edit comparison; the largest child's OS-reported maximum falls from
11.92 to 1.61 GiB. Summed RSS includes shared pages and is not physical memory
consumption. At least 13.80 GiB remained available during the baseline edit and
30.24 GiB during the migrated edit. No memory cutoff fired.

The initial conversion rebuild reached the source bridges after checking all
certificates; `OutputBodyCertificate` took 742 seconds. It then failed on the
hidden `Nat.repr` body. After the narrow compatibility repair, the complete retry
passed in 264.301 seconds with those certificates cached. This is not a clean
build timing or the entire migration cost. Final complete audits cover all
109 project modules and 33,033 declarations with only `propext`,
`Classical.choice` and `Quot.sound`. Restoring the original proof also passes
a complete check in 9.533 seconds and reproduces all 323 original compiled
object hashes. The retained candidate ends on the adopted unmutated sources.

## Regression checks and preservation

The affected native tests cover genuine proof-term changes, exposed-definition
changes and binary source edits with restored timestamps. Consumer artifact
checks include `.olean`, `.olean.server` and `.olean.private`; independent objects
must retain both bytes and timestamps. Each of the twelve actual handwritten
binding modules is checked with its production Lake dependency. False source
equalities must fail with the intended proof diagnostic.

Generated-certificate fixtures now compile as modules and use separate fresh
legacy audit drivers. All fourteen certificate controls pass, including invalid
witnesses, changed bytes and altered token/reconstruction candidates. Existing
cleanup and integrity tests cover the new artifact families. A native audit
fixture confirms that the actual complete audit and focused driver shape reject
an unused private non-Silver axiom behind an ordinary module import. Source-policy
tests retain exactly the two legacy audit roots and check the runner's generated
focused driver. These are regression checks of the current boundary, not a
sandbox against hostile metaprograms.

The compiler/SPARK proof inputs are unchanged, so their retained native evidence
keeps its original attribution without another compiler proof run. Linux is the
validation platform; no macOS proof or hosted CI run is added. Actions remains
disabled. The supported language remains Copy String Values.

## Evidence and handoff

Local evidence is under
`.silver/linux-x86_64/module-migration-20261012T153858Z/`: frozen inputs, isolated
snapshots, case logs and manifests, artifact hashes/timestamps, memory samples,
native-test results and source/test reviews. `tmp/module-migration-active.json`
and the evidence directory's `checkpoint.md` record recovery and publication
state. Ignored evidence is not recoverable from a clone.

All 982 canonical proof/cache files retain their hashes, sizes and timestamps.
The unrelated `ComposeAdmission.lean` patch is preserved unstaged; only its
module preamble is included in this migration's commit. Its unfinished language
changes are excluded from both the checked snapshot and the commit. Staged proof
inputs are compared directly with the successful isolated candidate.

The migrated warm cache is retained at
`candidate/.silver/linux-x86_64/proof/` within the evidence directory. Reuse a
copy with all sidecars and Lake metadata, letting the normal runner synchronize
sources and check dependencies. The canonical workspace retains its earlier
representation as preserved evidence; starting there would redo migration work.
Do not run multiple writers against a workspace.

The implementation/review target is the commit introducing this record, based
on `140de9abd6`. No new harness goal was requested; Compose String Results
remains complete. Checked-in session memory is updated; CLI recall is unavailable
and was not updated. Selective improvements at remaining measured proof hotspots
are next proposed. Language consolidation remains later roadmap work.
