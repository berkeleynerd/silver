# Independent C1 / guidance review — #246

Verdict: **ready for Lean validation**. No blocking, high, medium or low actionable finding in this bounded static review. This is not a successful Lean checkpoint or a performance result.

## Exact scope and settings

- Reviewed target: `80d5ec3e0e5224fe36c705f6be15e429b7fa7468` on `perf/velocity-246`, in `/home/canto/src/github.com/berkeleynerd/silver/tmp/velocity-246`.
- Baseline: `e94c8b4343f429c434900cc2a23e29e870f577bf` (owner-authorized first package, PR #258).
- Exact changed inputs reviewed: `proof/Silver/ComposeSourceCandidate.lean`, `proof/Silver/ComposeSourceChecks.lean`, `tests/test_lean_source.py`, `development.md`, `docs/proof-iteration.md`, `docs/assurance.md`, and `docs/focused-source-checks.md`. Worktree status was clean at review start and after the checks.
- Governing/context inputs: `AGENTS.md`; Oracle, particularly lines 11–12 and 24–29; the qualified C1 assessment in `docs/development-velocity.md`; the current October 26 authorization and narrow regression-reuse entries in `docs/session-memory.md`. Supporting audit/source inputs: `scripts/check_lean.py`, `proof/Silver/Audit.lean`, `proof/Silver/AxiomAudit.lean`, `proof/Silver/OutputSourceBridge.lean`, and relevant transitive imports.
- Reviewer selection: GPT-6 Astra, Extra High, as assigned by the lead. Independent runtime confirmation of model/effort is unavailable; no claim of changing the lead setting. Review began 2026-10-26 18:24:55 UTC and substantive checking ended 18:26:31 UTC (96 seconds). Token and cost measurements are unavailable.

## Findings and evidence

1. **All 98 decisions migrated without a semantic edit.** A read-only normalization compared the entire baseline `ComposeSourceChecks.lean` with the new candidate, replacing only the two source-token names, five explicit predicate parameters and six theorem names. The residual diff contains the intended import/comment changes and `candidate_checked` conjunction only. The original and new files each contain 98 `by decide +kernel` calls. All original predicate clauses, token/rendering definitions, private decision statements and assembly proofs match after those explicit substitutions.

2. **Authoritative API and binding remain intact.** The five original source-dependent proposition names remain abbreviations applied to `Source.outputSpecTokens` and/or `Source.outputBodyTokens`; `actual_expressions`, `actual_catalogue`, `actual_declarations`, `actual_refinement`, `actual_adapters`, and `finite_mapping` retain their original statements modulo those explicit definitional aliases. `TokenMapping` and shared public definitions retain their names through the public candidate import. `ComposeSourceBridge.CheckedSource` and `checked_source` are unchanged. In the adapter, `actual_complete_shape.1` is the spec equality and `.2.1` is the body equality, matching both rewrites; all five conjunction projections select the intended claim. The aggregate theorem and one adapter are small direct conjunction proofs, with no generic framework.

3. **Source correspondence is preserved structurally, pending checking.** The candidate closure has 37 project modules, zero certificates, no source umbrella/binding, no `include_str`, and no PathFacts modules. The authoritative adapter closure has 67 project modules and nine certificates, including output, lexical, runtime and profile dependencies. The unchanged output bridge pairs actual-token shape equalities with the existing exact-source lexer/reconstruction certificates. The candidate proves only reviewed-token facts; the retained final bridge still requires the actual-source chain. No pin-only claim replaces an authoritative one.

4. **Full audit coverage includes the new module.** Static traversal from `Silver.Audit` reaches all 498 project Lean modules, including the candidate; no project module is omitted. The unchanged runner captures all non-generated Lean source inputs, inventories actual audited modules, and requires complete inventory coverage for a complete run. The legacy audit root and `setExporting false` traversal still inspect private/generated declarations and transitive assumptions. Actual elaborated coverage and axiom results must still come from the next fresh Lean audit.

5. **Regression and guidance are proportionate.** The new tests check transitive candidate isolation and retention of the complete authoritative closure, preserving the unrelated-source exclusion. They exercise a real dependency boundary without adding artifact-corruption machinery. Four read-only policy tests passed on Linux x86_64: candidate isolation, authoritative dependencies, legacy full-import roots, and confinement of `include_str` to source bindings (3.015 seconds). `git diff --check` passed. Checkpoint and invalidation guidance preserve byte/provenance hashes, complete native/Lean auditing, final test-inventory coverage, and the existing narrow reuse rule. It explicitly places expensive source proof inside the checkpoint, allows independent overlap with resource reservations, and introduces no approval or replay gate.

## Outstanding validation

No Lean elaboration, native proof/build, full suite, benchmark, or mutating test ran in this review; the measurement agent owns those resources. The current C1 code has no completed Lean result yet. Static source equality does not establish that the adapter elaborates, that all private/axiom audits pass, or that the schedule improves. Complete applicable Lean/source validation and the matched unprofiled comparison remain delivery obligations. The lead reported retained native-input correspondence (2,519 native inputs and 141 tracked inputs matched proof run 121322); this review did not independently re-audit that retained run.

## Bounded measurement-plan sanity check

The lead requested this extension after the C1 check. Reviewed the scratch `config.json`, `RESUME.md`, `measure.py`, `finish_profiles.py` (the current sequence script; `sequence.py` does not exist), and `concurrent-work.json` under `tmp/velocity-246-measure/`. No measurement infrastructure was changed or launched. Additional read-only checking ran from approximately 18:27 UTC through 18:28 UTC; same selected reviewer settings, token/cost evidence unavailable.

No concrete plan blocker found. Profiling is explicitly isolated at one worker/two threads/16 GiB per-process threshold and excluded from timing-baseline claims. The matched workload is a complete incremental reconstruction build plus fresh whole-project audit at two workers/two threads/the same threshold. BEFORE and AFTER use independent worktrees, the same untouched original warm seed, pinned tools, and explicit corresponding rebuild closures; the proposed commands request neither clean mode nor independent kernel replay. The monitor records both process and host observations with appropriately qualified sampling, shared-page and per-process-limit semantics. `finish_profiles.py` stops after the two focused profiles, leaving the unprofiled cases separate.

Independent static reverse-closure calculation agrees with the planned 19 baseline modules. At reviewed AFTER commit `80d5ec3e0e5224fe36c705f6be15e429b7fa7468`, the corresponding closure is those same 19 plus `Silver.ComposeSourceCandidate` (20 total). Include the new candidate explicitly in the AFTER invalidation record; do not seed AFTER from the already profiled or correctness-tested workspace. This is a concrete instantiation of the existing plan, not an added framework or approval step.

Acceptance evidence is still outstanding because neither matched case has completed: exact case commits and commands, original-seed identities and artifact invalidations, actual rebuilt-module/phase records, successful complete fresh audits, and recorded host/concurrency observations must support the final comparison. Existing launcher inventories and managed evidence are sufficient mechanisms. Keep the fixed-order one-pair result scoped to the observed workload; it is not a general scaling law. The documented 0.904-second read-only overlap affected the instrumented profile only and does not invalidate the proposed isolated unprofiled control. Focused profile audits must not be described as the complete final audit. The unchanged-native-input claim relies on the lead's retained matching evidence and does not waive the mandatory complete native assurance.

Exact scratch inputs for this sanity check (SHA-256):

```json
{
  "config.json": "2894da9ab9e12c408b6001fcdbefd916873516fb8b956994844d801501467d43",
  "RESUME.md": "989c54c0aa938220b6610fe747c1861f5232804cff82aaef748ce053ddaf2ebd",
  "measure.py": "85f84255beec47347ea83d55038fe2236cf1d73abdae679cfb4669a0094f33ab",
  "finish_profiles.py": "3fd68aee35e3db963730f9e7d8eae813855644b38b0f9072559b38d21cb17f75",
  "concurrent-work.json": "24a69d380bd0db2198a071ecf0da3d5a8d2fc91582ca8c2eea4f5118ef757a9b"
}
```
