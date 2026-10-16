# Repairs from review-343c2f8

Authorized on 2026-10-15 by the owner's instruction to fix the selected findings
before further feature work. Baseline is `39d0ad38e6`, including the published
[review of e2c4fc2..343c2f8](reviews/review-343c2f8.md) and the later owner decisions.
The original branch was `fix/review-343c2f8`; final integration uses
`fix/review-343c2f8-delivery`. This record distinguishes
repairs to the admitted language from the unfinished loop/integer implementation.

## Scope and order

1. **Report capacity and placement:** B1/#17, L2/#19 and L4/#21. Derive capacity
   from report format and admitted source bounds, move the report buffer off
   Compile's stack, verify readers and report policies, add a format-based
   regression, and correct claims based only on measured specimens. Include a
   review of the eventual scalar/Image checks before that feature is admitted.
2. **Automatic proof policy:** L1/#18 and L3/#20. State and pass the effective
   prover memory allowance explicitly, pin actual options and effective limits,
   and retain a real 64-leaf compilation regression.
3. **Lexical regression and catalogue agreement:** L6/#23 and L7/#24. Add the
   missing rejected bracket-literal cases and admitted siblings, verify their
   native meaning, and align the catalogue producer and checked-in catalogue.
4. **Scope, planning and Rosetta:** L8/#25, L9/#26, L10/#27 and L11/#28. Apply the
   settled Integer `'Image` scope to the plan and motivating sample, correct the
   Colour bars assessment and SPARK rubric, make rendering deterministic, and
   synchronize reachable issue links and board status with authorization.

Independent repair streams may proceed together; no language-feature work
precedes completion of the repairs. Existing issue scopes supply completion
criteria. Review suggestions outside this list remain separately tracked.
No new construct is marked supported by this task.

## Validation and delivery

Implementation is complete at `4355971666`, with the final SPARK source at
`f623671ce2`. The selected eleven findings are repaired and validated on Linux
x86_64. Each stream's focused checks remain separate from the complete
checkpoint below. Captured inputs stayed unchanged during each run.
macOS validation remains independent and nonblocking; no hosted CI or independent
kernel replay is claimed.

The closing documentation commit and delivery pull request close #17–#21 and
#23–#28. The affected issues carry publication and board handoffs. The original
review target, implementation inputs and later documentation commits are distinct.

The independent streams have delivered the explicit proof-policy, lexical and
planning repairs. Their focused evidence is below and in the linked records.
The report repair adds a streaming projection because unsuccessful competing
solver attempts can carry unbounded reason strings even when every check proves.
Its retained-data envelope, storage placement and native regressions are recorded
in [report capacity](report-capacity.md). The uncapped stream-to-auditor proof
and complete integration checkpoint have passed. B1 is complete for the currently
admitted language; future scalar, loop and Image admission must re-derive the
envelope under the existing feature work packages.

The separate null-program text recognizer retains its raw reader and 262,144-byte
policy limit. A controlled report fixture with a duplicate proof section and a
300,000-byte tree confirms that projection cannot make this route bypass its
raw-size rejection. The affected Linux tool-failure/source-integrity test passed,
and the focused driver proof passed all 209 checks. This is additional focused
evidence, not the final integrated checkpoint.

### Integrated checkpoint

The final native Linux audit targets `4355971666` on
`fix/review-343c2f8-delivery`. The original review target remains
`e2c4fc2..343c2f8`; neither target includes the preserved, unfinished language
feature work in the canonical checkout. The only changes after `f623671ce2`
are the provenance path repair and its two tests described below; all Ada and
Lean proof sources and compiler-build inputs are unchanged.

| Check | Result |
| --- | --- |
| Complete compiler GNATprove audit, eight workers | Passed at `4355971666`; 61 units, 830 entities, 1,070 flow and 12,848 proof checks |
| Native build | Passed at `f623671ce2`; unchanged Ada/build inputs, 3.827 seconds |
| Complete test suite | Passed at `f623671ce2`; 348 tests in 1,949.783 seconds |
| Affected provenance tests after the path repair | Passed at `4355971666`; all 26 tests, including both new regressions |
| Complete cached Lean build and fresh whole-project audit | Passed at `4355971666`; 57,302 declarations, only `propext`, `Classical.choice`, `Quot.sound` |

The final full audit reused the native cache and completed in 30.383 seconds;
reports, source/tool hashes and the completed provenance manifest are retained
under `tmp/final-prove-20261016T034555Z/`. It classifies 268 limitation notes,
16 approved imported entities, 6,173 exact vendor mathematical notes and 30
vendor specification entities separately from owned obligations. All required
checks are proved and all Silver-owned entities retain full coverage. These
counts are an inventory, not additional unproved Silver obligations.

The complete Lean run finished in 17.173 seconds, retaining cached objects and
performing a fresh whole-project module/axiom audit. Evidence and logs are under
`tmp/final-lean-20261016T034555Z/`; independent kernel replay was not requested.
The build is retained under `tmp/final-build-20261016T024749Z/`, the full test
run under `tmp/final-test-20261016T024919Z/`, and the affected test recheck in
`tmp/provenance-symlink-after.log`. Each run's captured inputs stayed unchanged.

The first full native invocation took 4,942.972 seconds: GNATprove proved all
13,918 checks, but the final provenance check rejected the worktree's symlinked native tool
directory. Tool identities were resolved paths, while containment compared them
to the unresolved directory alias. Commit `4355971666` resolves both sides,
preserving source, report, binary and version hashes and command checks. New
filesystem regressions reproduce the rejected selected-directory alias and
also reject a tool symlink escaping that directory. Both failed before the
repair and all 26 provenance tests passed afterward. The original failed wrapper
result and successful proof reports are preserved under
`tmp/final-prove-20261016T022022Z/`; no snapshot was rewritten. The final full
audit above captured the repaired auditor afresh. The 348-test suite preceded
this Python-only fix; its affected file was rechecked rather than claiming a
second complete suite. Earlier Lean evidence remains separately retained.

The integrated `Silver_Library_Reports` unit passed all 2,752 proof and 278 flow
checks, with all 194 owned entities at full coverage. This includes the exact
flow-list call and containing policy postcondition that timed out in an earlier
isolated run. Independent review matched the completed unit to the frozen Git
and proof-input snapshots and required settings. A separately proved private
wrapper is retained in its isolated branch as a fallback; it was not needed or
integrated into the successful policy snapshot.

Independent subthreads reviewed the streaming reader/model, byte observations,
raw/bounded policy ladder, final record/list/root composition and actual reader
callers. Final reviews cover policy integration `f623671ce2`, record composition
`cd49accec5`, root composition `c5ced63b2f`, the precision fixes `915f30f312`,
the vendor-premise evidence checker integrated as `dd2e84b89b`, and the final
provenance path repair `4355971666`. No material
source issue remained in those reviews. Exact snapshots and detailed reviews
are retained in `tmp/independent-review-records/` and the originating isolated
worktrees. The completed native audit checks all required obligations and coverage.

The evidence checker identifies the exact Static ghost Character-sequence
instance and pinned vendor Big_Integer premises separately from owned proofs.
Its regression controls reject changed premises, unknown spec-only entities,
JSON/SARIF disagreement and failed obligations. The independent lane passed 73
evidence/provenance tests; the integrated evidence test file passed all 49 tests.
The [trusted boundary](trusted-boundary.md#audit-of-the-boundary) records these
premises explicitly. Owned precision warnings were repaired in source rather
than accepted by this classification.

## Proof-policy repair

L1/L3 make the existing effective 1,000 MiB per-prover memory allowance explicit
alongside the 100,000 normalized-step budget. Regression checks inspect the
effective Why3 limits and run a genuine 64-leaf dynamic expression through proof,
build and exact-output execution. [The proof-policy record](proof-policy-repairs.md)
contains the native options, limits and results. The change does not raise or
lower the previous effective budget.

## Planning and Rosetta repair

L8/L9 apply the owner's settled standard Integer `'Image` scope to the proposed
milestone and arithmetic-driven samples, and synchronize authorization records,
issue links and statuses. L10 corrects the Colour bars image-output assessment
and the SPARK exception/goto rubric. L11 sorts and deduplicates risk summaries
so rendering is deterministic across hash seeds. [The targeted Rosetta review](../rosetta/review-343c2f8.md)
records the assessment changes and full-corpus comparison. These repairs do not admit
any new construct or complete the loop/integer milestone.

## Report-capacity correction

L2 corrects the earlier inference from the Larger Expressions argument-shell
specimen. Its 2,065,005-byte report left 32,147 bytes (1.5%) in the historical
2 MiB buffer; its deterministic floor is 2,060,006 bytes and timing-dependent
credits contribute 4,999 bytes. It was produced by a separate runner using the
production options and policy, rather than by `silver compile` itself.

The review's denser static-shell construction with one output call measured
2,091,011–2,091,380 bytes across five proofs: 5,772–6,141 bytes (0.28–0.29%) of
headroom. Timing-dependent prover credits can exceed that margin. The review's
2,370,822-byte maximum concerns this construction, not all admitted programs.
Those retained inputs document the original defect; the derived retained-data
envelope is now in [report capacity](report-capacity.md). The review observed
the near-limit reports and credit growth, not an
overflowing dense execution. No new dense proof run is claimed by this correction.

## Lexical and catalogue repair evidence

L6 adds the missing elsif/final-bracket-with-escaped-quote neighbours and rejects
GNAT's encoded-character spelling `"["41"]"` in initializer, output and comparison
positions. Admitted quoted siblings retain ordinary Silver byte values. L7 now
states the exact final-decoded-character condition in the native catalogue
producer and checked-in JSON, with an assertion that pins the normative wording.

Focused Linux x86_64 validation passed: native build; three bracket regression
methods including real proof/build/exact-byte execution; and the native catalogue
comparison/assertion. Logs are in the repair worktree's `tmp/lexical-build.log`,
`tmp/bracket-tests-final.log` and `tmp/catalogue-test.log`. A first test invocation
used unsupported unittest-discover positional selectors and was corrected; its
mixed redirected log is not used as successful evidence. No admission rule or
Lean source interpretation changed. The complete integrated checkpoint above
also includes these regressions.
