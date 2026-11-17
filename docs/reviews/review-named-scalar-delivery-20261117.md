# Named scalar arguments #392 — final integration review

Review opened 2026-11-17 on Linux aarch64. Selected reviewer setting: GPT-6
Astra, Max, as requested by the lead and project policy. Independent runtime
model/effort, elapsed review time, token usage and cost are unavailable. The live
harness goal returned `null`. CLI memory was not updated.

## Current disposition

**Accepted for validated PR publication; no unresolved integration or evidence
finding.** The tested implementation is
`20e055be873f04a05d520b4e50f0e066515b7d4f`. Complete native/build assurance,
complete Lean/actual-source/module/axiom assurance and the fresh complete suite
are accepted on the exact inputs recorded below. The replacement suite has
**715 exact outcomes: 713 actual passes and two expected platform skips**.
All **eight** native Lean probe methods executed successfully. The original
suite remains failed history; its nine-file generated-certificate defect was
repaired exactly, passed all 17 affected-file methods, then passed the fresh
full suite. No test result or proof obligation was waived.

The final documentation and evidence snapshot is independently accepted and
bound by the closeout hashes below. It contains no additional implementation
change. The earlier checkpoint sections retain their historical pending states;
the final suite and closeout sections supersede those states. Publishing the
reviewed branch/PR and reconciling the issues remain lead workflow. **Merge is
not authorized.**

The owner-authorized scope is named/reordered/mixed calls for existing scalar
functions **and** procedures, with exactly one actual per formal and case-
insensitive matching. Full declared domains, same incoming state, conservative
alias/copy-back rules, exact author source, source/operator budgets and current
diagnostic/report policy remain required. No defaults, new effects/types,
Oracle change, CI, mandatory replay or proof-budget increase is selected.
Publication means a validated reviewable PR; merge is not authorized. #373
recovery and PR #385 remain deferred/held.

Only this scratch report is owned and written by this review. No compiler,
prover, test, rendering/generator or managed validation run was started. No
process or other workspace was signalled or mutated. Inspection used retained
reports, source, Git blobs, cheap independent byte/hash comparisons and the
existing read-only provenance/coverage auditors on completed native artifacts.

## Initial reviewed snapshot and coverage — historical checkpoint

Integration HEAD at entry:
`1d39b7f238c83c0e64c961b5cfbc4dc48c2cd2a9`.
The combined implementation/proof snapshot is
`c7388ab5d038ccbce9635ffaeec7df9189369366`; all tracked changes between that
snapshot and entry HEAD are documents/evidence. The dirty Rosetta draft is
unfinished delivery work and has not been accepted as a final render.

Read `AGENTS.md`, `oracle.md`, the root handoff, the named capability record,
relevant assurance/trusted-boundary/planning and validation/review guidance,
and the retained semantic, native, source, Rosetta and documentation reviews.
Those reviews explicitly distinguish focused success from the pending complete
checkpoint. The source review's failed-candidate and two-script repair addendum
preserves the original failure and does not substitute a pin for correspondence.

All **59** changed Lean files relative to `bf285bc57` are accounted for by the
existing independent review scopes, with no uncovered integration-only file:

| Slice | Final-byte applicability independently checked |
| --- | --- |
| 18 semantic files | All match reviewed semantic commit `3983a1c9312237d8f2bd2c115bfc387d3c0a8395`. |
| 16 source-support files | All match reviewed core `d3399feb4468750f77e8dcdcd0f3e54259cfbc85` after `a5e7c3fd7`. |
| 25 final source-certificate/pin files | Every current hash matches retained `source/final-owned-files.json`, itself SHA256 `09787536ba1d1a12a9ee04c2ddafec263adc4d91e2856d9d85999e7db55b9b01`. |

The semantic review's additional draft `PredicateProcedureCallFields.lean`
retains its reviewed hash
`f999111c4a3cec1072ad36dcd0b6e1f60bcb1812c92e4851b742bd2301f76ed7`.
All **1,183 tracked files** under `src/`, `scripts/` and `proof/` match the
source validation worktree byte for byte. This count includes every tracked
file in those trees, rather than only the earlier 1,182 relevant-file selection.
All **145 native-relevant tracked files** selected from `src/`, `scripts/` and
`proof/silver_proof_containers.gpr` match the native worktree. Complete
provenance comparisons must additionally cover generated configuration, project
metadata, tools and actual reports when their final manifests exist.

| Final artifact | Independently checked SHA256 |
| --- | --- |
| `src/silver_output_profile.adb` | `de017ca035a5ffd358d5fa98646d017dfe4ef54bd822fafc40743a9a8ae66f53` |
| `src/silver_catalogue.adb` | `2e46a16831e048dd64299a7bb31e554e9e478e7daa1a1eb79922be2bc34ccfab` |
| `proof/Silver/ReviewedOutputShape.lean` | `7d034eaaa79d6f3175ebd957eda8a493b6e2290d1904e654bac8469cd1616383` |

`oracle.md`, `scripts/`, `tests/test_evidence.py`, the Lean toolchain pin and
Lake configuration have no diff from the baseline through the combined snapshot.
The withdrawn native hiding experiment therefore has no surviving source-policy
allowance. The focused native review establishes full contracts and applicable
dependencies for 26 scopes/506 checks; this final review does not reclassify
those selected successes as a full native audit.

The combined behavioral additions preserve full-route positives and include
binding-observable subtraction, reordered/mixed case-folded associations, mixed
Integer/Boolean signatures, Boolean results and in-out calls, caller/selector
collisions, writable aliases, payload reads, both in-out containment checks,
same-incoming-state controls, unreachable calls, earlier subprogram bodies,
branches/loops and the 4096/4097-byte boundary. The prior positional-rejection
fixtures removed exactly their newly admitted named-call cases. Their other
negative cases remain. The report-capacity test change is explanatory only.

## Suite plan and collector review

Reviewed `tmp/final-suite-plan-392.md` and `tmp/final-suite-392/collect.py`
statically; neither collector mode was executed by this reviewer.
Collector SHA256:
`d75c1563500eb786327517eafa12069c9bdee68bc3bae1d7fb6bd100d2c0445d`.
The plan appendix contains exactly **715 distinct IDs**, including **nine**
`tests.`-prefixed entries and **16** named-scalar methods. Its ordered inventory
SHA256 is
`f426c20826f611bce1df451b1ebd3a7af9d04238db21b9fe71e53531b0e09af8`.
This is independent inspection of the recorded inventory, not a new discovery
or execution result.

The collector mirrors `dev.py`'s selected test-input hash construction, retains
the original `.id()` strings, and does not strip or merge module prefixes.
Collection requires exact set coverage, rejects unknown/duplicate/unresolved
IDs, and expects **713 actual `ok` results plus exactly the two existing ARM64
platform skips**. Those two Linux x86-64 regressions remain required when that
platform is validated; their skipped execution is not represented as a pass.
The 86 sample programs/149 execution cases belong to the manifest test and are
separate from unittest-method totals.

Freeze requires committed suite/review inputs, no active managed lease,
successful native/build/complete-Lean prerequisite records, actual compiler and
adapter binaries, the precise named support entry and matching native inputs.
Collection requires the real unfiltered all-tests command/cwd/interpreter,
matching captured inputs, successful phase and terminal events, unchanged
compiler/adapter/native-manifest bytes, and verified retained archive members.
The extra Rosetta hashes include rendered task pages, assessment/progression,
assessor and listing. The existing #391 prefix-normalization bug is absent.

No collector correctness blocker was found. Its prerequisite ledger checks
supplement independent native/Lean manifest review; they do not establish that
assurance by themselves. Freeze records the actual invoking process stack;
the lead must also retain the same-shell suite launch/terminal evidence because
the managed test journal does not itself record the inherited stack limit.
Final collection still needs the real suite evidence and final input mapping.

## Complete native/build addendum — 2026-11-17

**Accepted for the combined implementation; no unresolved native/build finding.**
Reviewed integration commit `0033ab19e290cfbf7818be46b1f1053e0aaabeb6` and its
retained `complete-native/` packet against the unchanged native validation tree
at `f4ed7cd513047df7c8a24c04b3fd107ee704db1c`. No implementation, proof, test,
catalogue, sample, Oracle or project-input change occurred after the reviewed
combined implementation through this integration commit. The preceding
`6329492a6` inactive-checkout relocation changes only setup evidence; it does not
invalidate this native applicability.

Independently checked the following rather than relying on the packet's asserted
verification counts:

- All **20 packet files**, including all **19 entries** in `SHA256SUMS.json` and
  the checksum manifest itself; no missing or unlisted file. Manifest SHA256:
  `30e926623928eb79af9386310bdef609dc0ec600bc9f6f17d3f57dac83ec3561`.
- All **2,622** live native input hashes, with exact selected-input inventory
  equality, including generated runtime/Image bindings and tool configuration.
  The complete manifest's initial fields equal `proof-inputs.json` exactly.
- All **12** tool binary hashes and recorded version-string hashes. The
  existing read-only provenance auditor also checked native containment,
  reviewed project configuration, Image/vendor routing, canonical effective
  command and its SARIF counterpart. No tool was invoked to redo proof work.
- All **147** tracked native input hashes against both the frozen native Git
  blobs and current integration bytes. The prior 145-file comparison omitted
  only `silver.gpr` and `alire.toml`; both are included here.
- All **80** archive member names/hashes (78 unit reports, SARIF and text
  summary), with equality to the live reports and manifest. No stale/missing
  report or unexpected unit remains. Proof manifest SHA256:
  `52bdffd61861b9c9a30e0a10b06bc02d329532416570a7c9408787042aacd957`.
  Report archive SHA256:
  `ca284df81a99fd0607b73b4eca65101822ab4c06e856e38423d5ec333ac4af77`.
- Decompressed original proof/build journals and logs against the retained
  shared managed records, plus each original prepared input/tool map and
  successful native-tool phase/final terminal events. Both prepared maps agree
  with the same complete native manifest.
- Both live executable hashes against the post-build verification:
  `silver` is `c8564820c277d6b5128df7b1eba4e5b69f5c97177242f6854f263c6e8203b860`;
  `silver_image_adapter` is
  `33160ab0c15f675a5c2dd6001731f5a1e33770525f84268bcb66aa0677818f70`.

Re-executing only the unchanged **read-only evidence auditors**, without a
compiler/prover/build/test run, reproduced **78 units, 1,252 entities, 1,751
flow checks and 17,975 proof checks: 19,726 required checks in total**. Complete
source-unit/entity coverage, obligation results, assumption references,
SPARK/SARIF/text-summary consistency, no skipped proof/flow and no `pragma
Assume` pass under the existing policy. Accepted note counts reproduce exactly:
357 limitation notes, 18 imported entities, 6,268 trusted-math notes, 62 vendor
spec entities, six array-initialization and 27 operator-reassociation advisories.
These remain the documented trusted boundary, not new policy exceptions.

The actual full proof run is `20261117T034048-8c22c1e6a33d`, from
03:40:48.788078 to 05:53:49.792386 UTC, **7,981.004189556 seconds**. Its real
command forces all-unit analysis with canonical all/all, level 2,
CVC5/Z3/Alt-Ergo and 30-second settings. Four workers and the 16 MiB invoking
stack were recorded for the concurrent memory allocation. Native-tool exit 0,
subsequent successful audit phase and final managed success are present. The
original lead-local exec `87037` exit 0 is retained as the lead's observation;
this reviewer did not have access to that private tool session.

The post-audit build `20261117T055412-08a00820e2ef` completed successfully in
**1.217194459 seconds**, with **11 automatically allocated workers** while the
one Lean worker reservation remained live. Its original collector-local exec
`53113` exit 0 and 16 MiB stack are recorded by the collector. The original
build log says both executables are **up to date**. This is an incremental
build result, with matching source/tool/binary identity and a still-valid native
manifest, not a claim of a fresh recompilation.

The proof started without inherited reports or Why3 sessions and with the
private cache overlay seeded from 179,821 existing files. It generated fresh
reports and a complete audit while permitting solver-cache reuse. No actual
cache-hit count was observed; no cold-run or uncached performance claim is made.
Failed solver attempts inside a proved obligation are not outstanding failures.
Earlier failed development attempts retain their separate historical disposition.

At this native-review checkpoint the complete Lean result was still pending.
Its eventual failure, focused recovery and separate successful complete run are
reviewed below. Native completion does not substitute for actual-source
assurance or the final suite. The native/build slice needs no repeat on unchanged
inputs.

## Complete Lean/source addendum — 2026-11-17

**Accepted for the exact combined implementation; no unresolved finding.**
Reviewed the retained `complete-lean/` packet supplied while integration HEAD
was `2e3c337a5add97ecb034c75b598cd18cb6913ceb`. All source/proof/script/test/
catalogue/sample/Oracle/project bytes still match implementation
`c7388ab5d038ccbce9635ffaeec7df9189369366`. No proof, statement, domain, axiom,
source pin, heartbeat/recursion setting or memory budget changed during recovery.

The successful complete run is **`20261117T064945-d458c99ae977`**, distinct
from the earlier failed complete run and the successful focused check. Its
original terminal `32282` exit zero is the source owner's recorded observation;
this reviewer independently verified the original managed journal, retained
launcher summary, successful build/audit phases and fresh audit log.

Independent read-only checks established:

- All **55 packet files** agree with the complete inventory: 54 listed member
  hashes plus `packet-manifest.json`, SHA256
  `fe6cb4dfa83476a3ec554a821f6e5da5928a75c0ce9030de36f752350fa5155f`.
- All **1,142 repository inputs** match both current integration and source
  validation bytes; the canonical input-map digest is correct. All **1,037
  workspace inputs**, both live Lean/Lake binary hashes, and all **6,202 live
  compiled artifact hashes** match final provenance.
- Both successful runs' repository/workspace archives contain exactly their
  declared members and every content hash matches. The focused and complete
  repository and workspace input maps are identical. Both original compressed
  managed journals agree byte for byte with the shared registry; their captured
  source/tool maps and resource settings agree with provenance.
- Final audit output lists **exactly 1,035 distinct modules**, equal to both
  the final provenance inventory and the full actual workspace module set.
  Every one of the 59 changed proof files is in that audited set. The actual
  source and integration routes include `Source`, `SourceCertificates`,
  `OutputBodyCertificate`, `PredicateSourceChecks`, `PredicateSourceBridge`,
  `PredicateCorrespondence`, all three changed call-certificate aggregates and
  `ComposeModelHelperEquations`. The authoritative source link resolves to the
  captured source validation tree's `src/` directory.
- The fresh audit reports **166,332 declarations**, with exactly
  `[propext, Classical.choice, Quot.sound]`. The unchanged read-only cached
  kernel-policy check passed against retained build traces. No independent
  kernel replay was performed or inferred from this audit.

Final provenance SHA256 is
`045f9af86cd23578231928213257a0116648e3499b653cb516716ddc69948ce3`;
final proof-log SHA256 is
`2675cbff93b446c073f00b8407851af6636869fa4363a46296adb9a7d7333013`.
These checks establish applicability of the checked semantic/native/source
chain to this exact combined source under the documented frontend, toolchain
and local-cache premises. They do not infer source correctness from a pin alone.

The final command used one Lake worker, one process thread and the unchanged
8192 MiB per-process threshold, with no `--clean` or replay. It rebuilt the
remaining integration consumers, retained matching cached successes and ran
the full fresh audit. Build and audit times are **12.533 s** and **2.199 s**;
runner elapsed time is **20.473 s**, wrapper elapsed time **25.027 s**. The
observed final peak process/tree RSS is **2,628,960 / 3,722,736 KiB**; minimum
host availability is **14,830,656 KiB**. Those five-second observations are not
exact instantaneous maxima or a universal memory bound.

### Failed run and focused recovery disposition

Read the independent Astra Max diagnosis at
`tmp/named-memory-diagnosis-392.md`. Its proposed proof factoring was not used.
The retained original run **`20261117T040626-c2b89a81f8a6`** failed with exit one
at the sole required target `Silver.ComposeModelHelperEquations`; no full audit
ran. Its original failure remains failed. I independently compared all 1,142
archived repository inputs and both tools to the final successful run, and all
1,036 archived workspace Lean inputs to the identical final entries. The extra
final workspace entry is `lean-toolchain`, omitted by that earlier `.lean`-only
snapshot, not a source change.

The original command used one Lake worker and twelve process threads with the
same 8192 MiB threshold. Its log contains kernel excessive-memory diagnostics
and the cascading `function expected` site. The enclosing run's earlier
SIGSTOP/SIGCONT scheduling interval was **3,776.511141343 s**, on the same
PGID/session; it was not a restart, a proof success, a budget increase, or an
explanation that excuses the later required-module failure. Both scheduling
events and the failed original terminal are retained.

The complete **unchanged** target then passed in focused run
**`20261117T064503-a6b27d1c4b6a`**, with one worker, **one process thread** and
the same memory threshold and external guards. Its fresh actual-import audit
covers **142 modules and 15,893 declarations**, with the same foundations.
The independent diagnosis accepted that focused recovery before the separate
complete retry. This is evidence that lower concurrency sufficed for these exact
inputs; it does not uniquely identify an allocator or establish a general memory
relationship. No repeated full attempt or speculative proof repair was needed.

The failed, focused and successful full summaries all record no external guard
interruption. The final full run reused the retained successful objects and
rebuilt outstanding consumers, rather than claiming that all objects remained
unchanged across the three invocations. Both complete proof slices now need no
repeat on unchanged inputs.

## Pre-suite tool setup, Rosetta and documents — 2026-11-17

The static discovery inventory alone did not establish that eight native Lean
probe methods would execute: six guard sites call `skipTest` at runtime if tools
are absent. The root found this setup gap before freezing and installed the
existing pinned donor through a read-only bind. No test result was inferred from
that setup. The collector still requires 713 actual `ok` results and exactly
the two known architecture skips, so any missing-tool skip would fail collection.
The initial setup inventory called these six methods; the final outcome review
corrected that count because `LeanModuleTests.setUp` guards three methods.

Independently verified `setup/native-suite-lean-tools.json`, SHA256
`aca9ff9bbfee81da88353de506a0e10fe2c7e93184a71b087c8d8466575ff7c7`, against the
actual native test tree: its distribution archive matches both the recorded
SHA256 `b4bcf1d79f1b5859c04625058d3707701d87a65815f7f0686a1f14df821954c5`
and the existing Linux ARM64 pin. Lean, Lake and leanchecker all match their
recorded donor/target hashes, and `findmnt` confirms the exact target is mounted
read-only. Lean/Lake hashes also equal the tools in the complete proof provenance.
The recorded bootstrap validation identifies Lean 4.34.1; the reviewer did not
rerun bootstrap, proof, probe tests or replay. Actual execution of all eight
probe methods remained part of the final suite at this checkpoint.

**The final prepared Rosetta state has no finding.** Against entry HEAD it
changes exactly **26 tracked Rosetta files / 21 task pages**, plus the new
assessment record. Only `Named parameters` changes its task assessment; only
`named-scalar-arguments` is added to `supported`. Schema/policy and all other
task assessments are unchanged. Broad functions, procedures, integers,
ranged-subtypes and scalar-image remain unsupported. The original October 15
revision, rubric, model and effort attribution is preserved separately from the
dated new review. The sample remains a binding-observable function and defaults
remain optional task features outside this increment.

The generated progression has **44 consecutive stages**, **1,576 consecutive
candidate ranks**, and **85 Stage-1 mappings**. Named parameters is Stage 1,
rank 66; Law of cosines remains Stage 2, rank 86. All other 20 changed task pages
change only their `Position` line. The broad #11/#12 scopes and narrow #393
mapping remain as previously reviewed; no project-field access/update is inferred.
The 1,496-file interim draft is absent from this final diff. No render or
generator was executed by this reviewer; the frozen full suite must still check
the generated state.

**The nine-document pre-suite patch has no substantive finding.** Reviewed
`tmp/final-docs-392.patch`, SHA256
`754928e3c61bbb108c251fdb676f6f11a9f3b1d93f3b0a8ea02fcb10c31cb935`.
Normal `git apply --check --whitespace=error` passed without applying it.
The README, roadmap, language, assurance, trusted boundary, named capability,
original function/procedure records and capacity record accurately distinguish
the completed proof checkpoints from the pending complete suite/final review.
They preserve full domains, aliases, exact source, unchanged capacity/policy,
failure history, cache/replay limits and the no-merge authorization. The new
capability heading supplies their common delivery link. The patch and precise
render may be committed and frozen for the one remaining suite; actual final
applied bytes and closeout wording remain to be reconciled with its result.

## Frozen suite applicability — 2026-11-17

**No freeze or applicability finding. Suite outcome remains pending.** Both
integration and native validation trees reached committed snapshot
**`dd0c9faad108f9bab2448db2ce1b692d72d0ea3c`**. The native tracked tree was clean
at review; source, proofs, scripts, tests, catalogue, samples, Oracle and project
inputs are unchanged from the reviewed combined implementation. The reviewed
nine-document patch is applied: its reverse applicability check passed without
writing files. Session memory accurately records accepted proof slices and keeps
the full suite, final closeout and publication pending.

The frozen record at `tmp/final-suite-392/frozen-inputs.json` has SHA256
`a6d1ba38a4d9a470e211050b51cffb6136c381827e66950e66955002bbff869c`.
It retains the correct successful native/build/final-Lean prerequisite runs,
the accepted binary and native-manifest hashes, **715 exact IDs** with ordered
inventory hash `f426c20826f611bce1df451b1ebd3a7af9d04238db21b9fe71e53531b0e09af8`,
the expected two architecture skips and 86 manifest samples/149 execution cases.
All **1,344 runner inputs**, **1,786 additional Rosetta review inputs**, **2,622
native inputs**, the native manifest, both binaries and the unchanged collector
were independently rehashed against this freeze.

The active suite is **`20261117T070433-0b21916222cf`**, task `#392-suite`, in the
native validation tree with **12 automatically reserved workers**. Its original
prepared input map equals the freeze exactly. The single captured command is
`/usr/bin/python3 -m unittest discover -s tests -v`, with no filters; that
interpreter resolves to the frozen `/usr/bin/python3.14`. Standard unittest
still executes the methods sequentially.

At **2026-11-17 07:07:16.219582 UTC**, independent read-only `/proc` observations
confirmed both the actual driver PID **505788** and its unittest child PID
**505790** had **16,777,216-byte soft / unlimited hard stack limits**. Their
command lines matched the original managed invocation and unfiltered suite.
This observes the actual suite processes, supplementing the freeze process's
same 16 MiB setting. No signal or process change was made. No finished event was
present then, so neither this observation nor the matching freeze certifies a
suite pass. Original root terminal `52841` and completed collection remain
required before final acceptance.

## First-suite finding and candidate-only repair applicability

While original suite `20261117T070433-0b21916222cf` continued, its real output
reported failures in two methods:

- `test_lean_source.CompilerSourcePolicyTests.test_checked_in_certificates_equal_regeneration`
- `test_lean_source.CompilerSourcePolicyTests.test_output_body_split_preserves_every_line_proof_and_ordered_reconstruction`

**This is a real repository-delivery defect.** The tracked
`proof/Silver/OutputBodyCertificate.lean` and **all eight**
`OutputBodyLines0.lean` through `OutputBodyLines7.lean` were still the older
generated candidates. The first test's output-body subtest and subsequent
chunk comparison fail; the second method separately checks complete line
coverage and ordered reconstruction. Final terminal/failure counts were not
yet available at this diagnostic checkpoint. Do not reinterpret the original
run as successful or waive either method. The earlier pre-run freeze comparison
established input stability, not the unexecuted parity tests' correctness.

The successful complete source proof remains applicable for a precise reason:
`scripts/check_lean.py` explicitly omits `CANDIDATES` from its shared repository
input map, regenerates the output aggregator and eight chunks together from the
captured actual source and captured generator, then records/checks **all**
workspace input bytes around build and audit. This is the existing runner
design, not a newly added exception. Its workspace candidates were current;
only their checked-in convenience copies were stale.

I independently verified that all nine live validation-workspace candidate
hashes equal the final complete run's retained `workspace-inputs.tar.gz` bytes
and `workspace_inputs_sha256`. All nine modules are in the exact 1,035-module
audit, and all **54 associated recorded compiled artifact files** still match
the complete provenance. The tracked output aggregator's old SHA256 is
`4b3b71d41c870fba990135e97aef879843ffd151c8ace41ebbfa9abe39338b33`;
the already-proved replacement is
`0cee230d88dad8c4ee4bc5ada64926c740f66ee67b3033d4c1c81bba12dab406`.

The source owner regenerated the proposed nine-file bundle in isolated scratch,
without editing frozen inputs. I independently checked every proposed file in
`tmp/named-output-sync-diagnosis-392/regenerated/proof/Silver/` against the
accepted complete workspace hashes. Every file matches exactly. The complete
old/new inventory is `tmp/named-output-sync-diagnosis-392/comparison.json`,
Final SHA256 `6c53ccd46365658662582ef138424cf83a5331c7db54c31dfcb1ed93e7bc0d92`.
Its finalization only clarified that the recorded elapsed time included both
generation and comparison; the nine proposed hashes are unchanged. The
accompanying diagnosis README hashes to
`208c18a7dce133ca72fe66447063e88f1886b223a58941774c7f800b9a272a55`.
The actual source still hashes to `de017ca0…`, and generator SHA256
`a938697c3b361dc4fa3165f84571c8e751248594e172f3a4c3137dd4e5fbbd79`
matches the accepted complete provenance. This reviewer did not run a generator.

**Repair applicability decision:** synchronizing exactly those nine proposed
files is accepted. It changes neither any of the **1,142 selected Lean
repository inputs**, the **1,037 audited workspace inputs**, the checked
compiled artifacts, nor any native proof input. There is no native source,
handwritten theorem/model, generator, source pin, domain, obligation or budget
change. Consequently neither complete native proof nor complete Lean/source
proof needs repeating for this exact synchronization. A different proposed byte
or additional proof/source change would require a fresh applicability decision.

The suite input map **does** include the tracked candidate files, so the old
freeze no longer covers the repaired delivery. Preserve the first original run
and its frozen snapshot unchanged until its actual terminal is collected, then
retain the failure. After synchronization, establish focused success for the
two failed methods (the complete `test_lean_source.py` scope is also suitable),
commit/freeze the repaired inputs, and perform the lead-selected **fresh complete
repository suite**. No test result is waived or represented as a fresh pass by
this reuse of unchanged proof evidence.
The lead selected the entire **17-method** `test_lean_source.py` scope,
including its native certificate probe, before that fresh full suite.

### Repair and focused validation confirmed

The original root terminal `52841` was collected with exit **1**. Its retained
packet at `certificate-sync/failed-full-suite/` agrees with the original shared
managed journal and both native/terminal logs. Independent parsing confirms
**715 tests in 1160.365 s**, **three failure records across the two methods**, and
**two expected platform skips**. The failed native log SHA256 is
`0eaead24b3f4b2c44d9466621b36aa9de4d0ca65751a6c3b006b0a3695269a29`;
its preserved frozen record retains SHA256 `a6d1ba38…`. Monitoring's partial
progress count is explicitly non-authoritative. The original run is recorded
as failed, with no test-result reuse claimed for the selected fresh suite.

Repair commit **`20e055be873f04a05d520b4e50f0e066515b7d4f`** changes exactly the
nine reviewed generated proof files plus documents/evidence. Independently
compared every replacement in the commit, integration tree and native tree to
the accepted audited workspace hashes: all match. Recomputed the runner's
complete selected Lean map: all **1,142 effective repository inputs remain
identical**. All **2,622 native inputs** and both executable hashes are unchanged.
Relative to the first frozen suite, exactly the nine intended runner-input
hashes differ; all other runner inputs and all 1,786 Rosetta review inputs match.
This confirms the prospective no-proof-rerun applicability decision on actual
committed repair bytes.

The complete affected-file check **`20261117T072514-b9c195a48c9c`** passed on
that commit. Its original terminal `78512` was collected with exit zero. The
retained focused journal/log match the original managed records; independent
exact-ID parsing finds all **17 expected methods actually `ok`**, **no skips**,
and **20.469 s**. This includes both formerly failing parity/split methods and
the real native certificate/kernel probe. Focused log SHA256:
`53de99b7927017f48b78f3409c3d918a2335adddce9db47fb1dd4cd661f52887`.
The repository-parity finding is fixed and focused validation is complete.

The replacement freeze at `tmp/final-suite-392/repaired/frozen-inputs.json`
has SHA256
`9563914b9e6800a2d2d79a74d4a36e7b23e2b5bdd35b3893f4d9b6181aa94363`.
It binds `20e055be873f04a05d520b4e50f0e066515b7d4f`, the same **715 exact IDs**
and ordered inventory hash, unchanged native/Lean prerequisites, collector,
manifest and executable hashes. I rehashed all frozen runner/review/binary
inputs. Relative to the old freeze its runner inventory changes exactly the
nine candidates; no other input-map difference exists.

The fresh complete invocation is **`20261117T072619-37479dd61ba9`**, original
root terminal **`77655`**, with **12 workers** and the same unfiltered unittest
discovery command. Its real prepared input map equals the repaired freeze.
At **2026-11-17 07:27:31.661415 UTC**, independent `/proc` observations confirmed
driver PID **699206** and unittest PID **699208** both had **16,777,216-byte soft /
unlimited hard stack limits**. No terminal event was present then. No tests,
proofs or builds were started by this reviewer. Final acceptance awaits this
original run's actual terminal and completed collection.

## Fresh complete suite accepted — 2026-11-17

**Accepted.** Replacement managed run **`20261117T072619-37479dd61ba9`**
completed the full unfiltered suite on frozen head
**`20e055be873f04a05d520b4e50f0e066515b7d4f`**. Original root terminal **77655**
was collected with exit **0**. That terminal collection is the lead's recorded
observation; this reviewer independently checked the original managed journal,
native and external logs, exact outcomes and the successful phase/final events.
The run reports **715 tests in 1,160.908 seconds: 713 actual `ok` outcomes and
exactly two expected platform skips**, with no failures or errors.

Independent checks established:

- All eight retained archive members have exactly the recorded names and
  hashes: `collect.py`, `events.jsonl`, `exact-outcomes.json`,
  `external-terminal.log`, `frozen-inputs.json`,
  `native-proof-provenance.json`, `native.log` and `originals.json`. Archived
  original logs/journals agree with the live completed records.
- All **1,344 runner inputs**, **1,786 additional Rosetta review inputs**,
  **2,622 native inputs**, the native proof manifest and both actual executable
  hashes match the repaired freeze. The original journal records the single
  unfiltered command, exact prepared map, successful test phase and successful
  final event. No earlier successful test subset substitutes for this run.
- Independent log segmentation found exactly **715 unique original test IDs**,
  each with one outcome, matching the retained exact-outcome table and frozen
  ordered inventory. All nine imported `tests.` prefixes remain distinct.
  All **16 named-scalar methods**, **12 Rosetta methods**, the sample-manifest
  method and maximal dynamic-expression control actually passed. The manifest
  represents **86 sample programs / 149 execution cases**, separate from the
  unittest-method count.
- All **eight** native Lean probes passed: the four
  `test_lean_evidence.LeanNative*` methods, all three
  `test_lean_modules.LeanModuleTests.*` methods, and
  `test_lean_source.NativeCertificateTests.test_generated_certificates_and_witnesses_remain_kernel_checked`.
  All three native Lean tool hashes still match the verified setup. The initial
  count of six was a setup-inventory error: six runtime skip sites guard eight
  methods because `LeanModuleTests.setUp` guards three. Current setup, delivery
  and suite documentation now distinguish these counts; the raw historical
  setup JSON is retained unchanged with its error explicitly documented.

The only skipped methods and their exact reported reasons are:

| Exact test ID | Reported reason |
| --- | --- |
| `test_counted_bound_review.CountedBoundReviewTests.test_maximal_nested_loops_keep_filter_scratch_out_of_frames` | `8 MiB stack evidence is native Linux x86-64` |
| `test_output_integrity.OutputIntegrityTests.test_large_argument_vector_with_eight_mib_stack` | `the retained 8 MiB / 190,000-argument regression is Linux x86-64` |

These are the two frozen platform skips, not unexecuted tool probes. Their
Linux x86-64 obligations remain distinct from this native Linux aarch64 result.

| Final suite artifact | Independently checked SHA256 |
| --- | --- |
| `suite-evidence.tar.gz` | `52312bb6e4ee1acff38a5741cf6ff9d64af47d5b27c3cb8f055cde65bba3cde4` |
| `exact-outcomes.json` | `f319bacd25fe6e3c18e619be78e56d75f32072528625165e9b6d1a0aa23b7f7c` |
| Original native log | `f22469e34fb5c2a0bfd0d4546c52646c42f205916f40f92809afffcd9ee19706` |
| Original managed events | `5baaf241f461682ba02160959df5c167585b9c80f66c21791202df5baf7a4c65` |
| Repaired frozen inputs | `9563914b9e6800a2d2d79a74d4a36e7b23e2b5bdd35b3893f4d9b6181aa94363` |
| Ordered 715-ID inventory | `f426c20826f611bce1df451b1ebd3a7af9d04238db21b9fe71e53531b0e09af8` |
| Unchanged collector | `d75c1563500eb786327517eafa12069c9bdee68bc3bae1d7fb6bd100d2c0445d` |

The run used the actual **12-worker automatic reservation** and sequential
unittest methods. The independently observed live driver/test stack limits are
recorded in the preceding checkpoint. This is fresh full test execution with
retained validated compiler/tool binaries, not a cold-cache compiler/prover
claim. Complete native assurance remains fresh at the report level; complete
Lean assurance remains the specifically recorded cached build plus fresh full
audit. The exact candidate synchronization does not change either proof input
map, so repeating those successful expensive checkpoints is unnecessary.

All **33** compressed monitoring samples independently reproduce the retained
summary: 07:27:01.590132 through 07:45:41.870610 UTC; maximum sampled process-tree
RSS sum **2,524,272 KiB**; minimum available RAM **14,667,184 KiB**; minimum free
disk **1,599,913,984 bytes** on the native artifact volume and **4,060,405,760
bytes** on `/tmp`. Monitoring started after launch and sums may double-count
shared pages. These remain sampled observations, not exact resource maxima.
The monitor's progress parser is not used for final exact-outcome counts.
No resource guard or signal interrupted the run.

The final summary's interval from recorded issue opening at 01:55:25 UTC to
successful validation at 07:45:41.273649 UTC is **21,016.273649 seconds**
(5 hours 50 minutes 16 seconds when rounded to seconds). This arithmetic agrees
with the retained timestamps; it includes overlap, failed attempts and the
separate scheduling pause. It is neither CPU time nor model cost.

## Final documentation and evidence snapshot accepted — 2026-11-17

**Accepted with no remaining delivery finding.** Integration HEAD and the
clean tracked native validation tree are both still
`20e055be873f04a05d520b4e50f0e066515b7d4f`. The final tracked diff changes only
**12 Markdown documents**. Its exact binary Git diff from that HEAD, limited
to `README.md`, `language.md`, `roadmap.md` and `docs/`, has SHA256
**`6d3141c6ffc5f9bc0021765a3a58d283d65dde0865e6d5eaf81a158c979c74da`**.
`git diff --check` passes. The final generated Rosetta state and all tested
implementation inputs remain unchanged.

The new complete-suite packet manifest covers exactly **eight files** and
hashes to
**`92a5477688cb82fcc5f6703b385746fdbb59a37a58a5f41f8afd6f15b90989c6`**.
The certificate-sync packet manifest covers exactly **15 files**, including
the separately preserved failed suite and successful focused run, and hashes to
**`90757801a3865c13301ef3222609028e58dfea284585d9e9a85aeda7dc38f447`**.
Every listed hash was independently recomputed; both inventories have no
missing or extra file other than their own manifest. No underlying raw evidence
changed when these manifests were added.

The final README, language, roadmap, assurance, trusted-boundary, capability,
original function/procedure and capacity accounts accurately promote only the
authorized named-scalar capability. They preserve full domains, same incoming
state, aliases/copy-back, exact source correspondence, budgets and diagnostic
policy. They distinguish the original deliveries, initial failed attempts,
focused repairs, retained native and cached Lean assurance, and the fresh final
suite. The narrow Rosetta promotion is **84 to 85 task mappings**; broad
functions/procedures/arrays remain separate. No defaults, new effects/types,
Oracle amendment, CI or independent kernel replay is claimed.

The capability record's current SHA256 is
`e1d341d5336f8f1c01e7e8ac30dbbf49a535bd3b0b101665f2ead6827c50b85a`;
the corrected setup README is
`413f58dc0e42a6739f231fb105ffb5646cf1ddd7b1444dc863bbe881289d45f9`.
The suite README's `df2d4a7773ea02f102f6a6b4f315d59d3f2a7afddacb803e3f438869c80fa569`
and certificate-sync README's
`3ededf2420268e581edbf05b428d13120ce1cb8ff4b6789674abca0296540408`
are also bound by their packet manifests. The final links to
`docs/reviews/review-named-scalar-delivery-20261117.md` designate the lead's
planned exact copy of this completed report.

Session memory retains owner authorization to publish a validated reviewable
PR and stop without merge, #373 recovery, the PR #385 hold, unrelated caches/
worktrees and the lack of project-board `read:project` access. It grants no next
capability authorization. The live harness goal was re-read at closeout and is
`null`; no goal status was changed. CLI memory was not updated.

There is no remaining validation or review prerequisite for publication of this
exact accepted snapshot. The lead may copy this report, commit the reviewed
documentation/evidence, and publish/reconcile #392 and its precise stage #393
under the recorded authorization. Later source/proof/test changes require the
existing applicability and validation rules; a documents/evidence-only closing
commit does not itself require repeating accepted native, Lean or suite work.
This review does not certify publication already occurred or authorize merge.
