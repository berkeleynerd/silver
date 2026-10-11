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
validation were not rerun. That retained native audit belongs to its original
snapshot: its provenance includes all Python scripts, so the changed Lean runner
means its full manifest does not validate this later tree. macOS work remains
out of scope.

## Remaining cost

A selected source bridge can still depend on all certificates, though unchanged
ones remain cached. The changed output-body certificate still needs its measured
roughly 64-minute rebuild at a complete checkpoint. Focused mode synchronizes
all protected inputs and regenerates the cheap candidate files; a malformed
unrelated Ada candidate can therefore stop setup. This change selects which
proofs are built and audited; it introduces no new certificate framework.

## External review of `d375aec`

On 2026-10-11 the owner supplied the final review summary for `fe539a5` and
`d375aec`. The [full report](reviews/review-d375aec.md) and the earlier final
reports for [`44fd8ea`](reviews/review-44fd8ea.md) and
[`1ed039e`](reviews/review-1ed039e.md) then arrived in `26737d9`. All three have
been assessed. Their native macOS results remain optional external evidence,
distinct from the Linux checks below. Earlier records preserve the interim
information actually available then; final carry-over dispositions now appear
in the [assignment](string-assignment.md#external-review-disposition) and
[branching](input-branching.md#external-review-of-1ed039e) records.

| Finding | Independent assessment and disposition |
| --- | --- |
| M1: module-local kernel bypass | Confirmed on Linux: the false theorem builds and passes the real axiom audit; replay rejects it. Fixed with a source policy before building and after candidate generation, covering module, package and library settings and direct unchecked-declaration APIs. |
| M1: unsafe weak arguments after reversion | Confirmed: the cached object's Lake trace retains its original unsafe compiler command. The runner now rejects those traces before reuse and between phases, without deleting caches or making replay mandatory. |
| L1: missing final reports and carryovers | Full reports now retained unchanged and dispositioned. Assignment body/specification header conjuncts were added and validated; there is no Ada or certificate change. Documentation corrections and explicit deferrals are recorded in the capability records above. |
| L2: default-mode failure tests | Confirmed test gap, not a missing production input check. Added default-mode shared/workspace/tool drift and incomplete-audit regressions, including generated-candidate byte drift after build/audit and interrupted-child kill/reap. |
| L3: removed 136-name theorem list | Leave removed. The reported theorems still existed, and a name registry does not establish assurance completeness. Retain complete module/axiom auditing and ordinary semantic proof review. |
| L4: real axiom-audit regression | Added a small native scratch regression for allowed foundations and rejection of unused/private/imported axioms, unfinished proofs and native evaluation. |
| L5: replay/object-hash wording | Clarified current assurance and platform documentation. Object-hash checks apply to replay/provenance. The dormant CI template's older name remains historical; Actions is disabled and the available publication credential cannot edit workflows. |
| L6: native provenance after runner edits | Confirmed exact-manifest mismatch. Rehashing all 2,391 retained inputs found only the Lean runner changed; all Ada and native configuration inputs matched. Preserve the original record and describe its scope accurately, without rerunning unchanged native proofs. |
| L7: source-embedding placement | Added an invariant requiring the twelve literal `include_str` uses to remain in their intended per-file binding modules. |
| I1: edit/revert during binding build | Existing exact-byte certificates fail closed; no new mechanism needed. |
| I2–I3: historical evidence and capture errors | Keep input-bound evidence semantics. A prior record can survive an early capture error but remains tied to its old inputs, not a claim of current success. No additional evidence lifecycle is needed here. |
| I4: lexical helper headers | Keep reviewed shape pins; defer extra explicit header conjuncts until that source/bridge is next changed. The assignment header omission is repaired separately. |
| I5–I6: helper visibility and probe expectation | No implementation action: visibility was withdrawn as a finding, and the actual native-evaluation axiom is already rejected by the real audit. |

The source guard reserves direct bypass names even in comments/strings, with
one exact exception for the audit's read-only check. It also rejects the direct
unchecked-declaration APIs. This prevents the demonstrated accidental bypasses
under the existing trusted tool/cache assumptions; it does not authenticate
forged traces or constrain arbitrary hostile metaprograms. The Linux experiments
also showed that `lean -t0` does not fix the module-local bypass.

The follow-up's evidence, including preserved prior canonical records, is under
`.silver/linux-x86_64/review-d375aec-2026-10-11/`. Native scratch probes are retained
under `tmp/review-m1-native/` and `tmp/assignment-header-review-20261011T130637Z/`.
The source/trace guard rejected both actual bypass reproductions and accepted the
current project sources and 98 retained build traces. The strengthened assignment
module compiled and passed a fresh axiom audit in isolation. All 70 initial affected
runner/platform/source tests passed. The final generated-candidate drift,
interrupted-child and source-embedding regressions also passed after the full
reports arrived. The complete cached Linux build and fresh
audit passed in 116.640 seconds, covering 98 modules and 23,516 declarations with
standard axioms only; all twelve certificate objects retained their exact bytes,
sizes and timestamps. Independent final review found no material issue. These
times include the strengthened header theorem and its dependents, not a cold
certificate build or production kernel replay. No macOS scratch was deleted
and no new language capability was started.
