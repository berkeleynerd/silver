# Session memory

## 2026-10-08 — Pre-1.0 direction and completed workflow changes

The owner chose **one evolving language before 1.0**. Git records its history;
we do not maintain separately selectable language versions or impose historical
compatibility obligations. Intentional changes to admission rules or examples
must be explicit and consistent across specification, catalogue, implementation,
proofs and samples. Every currently admitted program still receives the complete
Oracle guarantee. Failed proofs cannot be hidden by suppressing obligations or
weakening declared guarantees.

Prioritize foundations needed for the authorized capability. Defer independently
addable release/deployment hardening, including binary attestations, full
per-program dependency provenance, additional adversarial-environment defenses,
and compatibility machinery, until the intended use requires it. Keep existing
checks and source correspondence. The policy lives in
[development.md](../development.md) and the [Oracle](../oracle.md).

The owner subsequently requested the modest review adjustments and local
commits, superseding the earlier staging-only instruction. The completed scope
adds optional cold GNATprove validation and a guard against accidentally sharing
exploratory proof state, and clarifies the evidence and documentation. The
previously approved Oracle amendment is recorded in commit `ddd8249`, with the
owner's approval cited in its message. No further Oracle amendment or approval
ceremony is needed. Publication remains outside this instruction.
[proof-workflow.md](proof-workflow.md) records exact results and limitations
instead of duplicating them here.

Everyday `dev.py prove` and `check_lean.py` reuse native caches; their `--full`
modes perform the additional validation described in `development.md`. GNATprove
defaults to all detected cores. Lean's per-process thread count is configurable;
its conservative default is not a measured optimum, and cold source-certificate
checking remains expensive. The transient GNATprove failure recurred in a warm
full run after a successful cold run. Subsequent manual serial and all-core
audits passed, with no automatic retry added. The cause remains unexplained.
The JSON parser reached end-of-input before a value; the failed input and root
cause are unidentified. A parallel race is a hypothesis, and `--jobs 1` is a
diagnostic comparison rather than a demonstrated workaround.

`prove --cold` is an optional full audit in fresh output/session/cache
directories for toolchain or proof-workflow changes and cache investigations.
Routine capability validation may reuse native proof results. Keep exploratory
GNATprove output under the reserved `explore` subdirectory and use a separate
cache. The direct-command guard prevents accidental mixing; it does not police
arbitrary shell wrappers or direct tool invocations.

Final Linux cold and warm full audits, the complete suite under symlinked
temporary paths, and the fresh Lean audit passed. The final Lean check reused
the exact proof objects, tools and workspace inputs of the earlier independent
kernel recheck; only the two GNATprove development scripts changed among its
captured inputs. The
independent kernel check was not repeated for this follow-up. See the workflow
record for the retained failure, subsequent successful diagnostics and final
current-input evidence. This work does not start a roadmap language capability.

No language expansion is authorized by this workflow task:

- The admitted language remains null-only. `silver-null-0` is the existing
  compiler/catalogue label, not an ongoing version-management requirement.
- `null.adb` remains in the repository root, unchanged.
- Moving it to `samples/`, creating a manifest and adding sample-driven tests
  remain proposed work.
- Hello World, context clauses, runtime calls and string-literal arguments
  remain proposed. No output API, trusted output binding, encoding/newline rule,
  or failure policy has been selected.
- The intended growth model is a small coherent capability with a motivating
  sample, exact rules and universal assurance. Samples exercise the language;
  they do not define membership or prove the language-wide guarantee.

The owner requested `roadmap.md`, `development.md` and `language.md` at the root
for review. Session guidance uses the conventional `AGENTS.md` spelling, with no
case-only alias. A roadmap entry does not authorize implementation.

## Earlier decisions and evidence

The earlier approved Oracle proposal clarified narrow library admission,
verified Silver-owned libraries, specified external effects/failures, and source
correspondence. Those requirements remain. Its versioned-specification, absolute
historical-preservation and per-program dependency-identity requirements are
superseded by the newer pre-1.0 direction above. The earlier Markdown-only task
restriction is also superseded by the authorized proof-workflow work.

Commit `8b8619f` (`Close assurance gaps and harden native proof workflow`) is the
implementation baseline before the current changes.
[review-repairs.md](review-repairs.md) records its Linux compiler verification,
integration tests, clean Lean replay and independent kernel recheck. These are
historical results. Consult the current workflow record for validation of the
present changes.

A later independent macOS review reported verification and Lean replay of that
baseline, with three test-fixture errors under a symlinked temporary directory.
A subsequent review validated the staged incremental workflows on macOS ARM64:
the compiler audit, tests and all four Lean modes passed. Linux-side read-only
checks corroborated the retained compiler and final clean Lean evidence against
the then-current source/script hashes. That run preceded the new cold option
and exploratory guard; it does not validate those additions natively on macOS.
See the workflow record for results, hashes and attribution. Remote CI has not run.

Read [assurance.md](assurance.md) for proved claims and limits, and
[trusted-boundary.md](trusted-boundary.md) for assumptions. In particular, the
Ada-to-Lean interpretation relies on documented frontend semantics; it is not a
verified general Ada parser. Current user programs have empty obligation sets.
Output needs specified effects and failure behavior, correspondence to actual
wrapper implementations, and complete handling of whatever obligations the
selected API generates.

The older [implementation checkpoint](implementation-checkpoint.md) predates
the review repairs. Its totals, paths and pending items are historical, not the
current task list. Do not reopen completed repairs from that checkpoint.

## Platform and repository decisions

- Linux is primary; macOS is secondary and validated independently. Determine
  the actual execution host rather than inferring it from the checkout path.
- Preserve native host isolation under `.tools/<host>/` and `.silver/<host>/`;
  see [platform-coexistence.md](platform-coexistence.md).
- The owner named `github.com/berkeleynerd/silver` as the intended remote, then
  requested local work because it did not yet exist. Do not create or publish
  a remote without a subsequent instruction. Check current Git configuration
  before later authorized remote work.
- No remote CI run is recorded. Distinguish a configured workflow from a run,
  and retained native artifacts from fresh validation of changed inputs.
- Preserve `tmp/` review and scratch material; keep it outside staged project
  changes unless specifically requested.

Update this handoff when scope or decisions change. Link detailed evidence
instead of duplicating counts, hashes or machine-specific paths.
