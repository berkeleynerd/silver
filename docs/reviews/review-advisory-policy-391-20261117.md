# Independent acceptance review: advisory repair #391

Review target: implementation `d60bd8a899fcc66e5ef40112423b7f94b2e4becc`, with
the complete suite run at documentation-only head
`e8921bd091a4b0552de45d8205277008c236ba7a`. Later documentation/evidence commits
preserve the governed implementation, proof, test and fixture bytes. Scope is
the owner's November 16 repair of PR #371; this review does not authorize merge
or implementation of #373.

Independent reviewer selected: **GPT-6 Astra / Max**; runtime identity was not
independently exposed. The integration lead records the reviewer's returned
findings and verification here. Recorded review portions total **16m53s (10m02s earlier portions, 2m45s complete-Lean/document review, 4m06s final suite review)**;
other elapsed portions and token/monetary costs are unavailable. Native proof
execution, Lean build time and review time are separate measurements.

## Implementation and finding disposition

- Both formal advisories use exact declared local owners, formal spelling and
  eligible modes, the separate exact rule/message pairings and the required
  warning/flow provenance. Main is excluded. Columns and record order do not
  identify formals. Existing acceptance branches remain additive; required
  initialization, function termination and safety checks remain.
- The native helper contracts cover their complete declared domains, including
  empty/malformed typed metadata and source bounds. No `Valid_Metadata`
  precondition or narrowed domain was introduced. The executable/ghost equality
  shares the policy, so its scope is distinguished from the mutation controls.
- Python previously had only function names and procedure output names. The
  optional trusted source-formal inventory repairs that gap independently of
  report bytes, while omission preserves the prior policy. Genuine accepted
  report verdicts and Python statistics are unchanged for all 30 retained reports.
- The capacity account correctly adds `585*1024 + 4096 = 603,136` bytes,
  separately from the inherited `UNUSED_VARIABLE` allowance. The new envelope
  is 49,279,744 bytes within the unchanged 64 MiB allocation. An unmentioned
  `in out` formal may carry both unused-variable and read-only advisories.
- All 53 token pairings are checked by the five finite case proofs. The initial
  Boolean import caused a downstream ambiguity; the unchanged theorem was moved
  into the existing Domain imports, preserving its qualified name/type/proof and
  restoring the Native module. The two requested docstring changes do not change
  an existing theorem, termination claim or combined safety predicate.
- The complete `Mixed_Report` contract initially timed out. Two caller-local
  expression-body hiding annotations reuse the proved `Mixed_Object` equality.
  Whole-subprogram focused verification and the final complete native audit pass
  without changing contracts, domains or proof budgets.
- Earlier review missed the new annotations' source-policy allowlist integration.
  That closure was withdrawn. The exact four-name extension, actual-source
  regression and malformed/wrong-file controls repair it; 79 Python tests and the
  independent complete source/report/provenance audit pass.
- The genuine-report test probe originally read only one line. Its test-only
  byte-stream repair feeds all original report bytes unchanged. The failed probe
  run remains retained; old/new native and Python corpus checks now pass.
- The 12-worker and two-worker Lean interruptions remain recorded as interrupted
  attempts. Measured dense overlap justified the one-worker continuation, which
  completed without a guard event. No clean build, cache deletion or kernel replay
  was used to replace missing validation.
- The single suite passed, but its untracked supervisor exited 1 because the
  post-run parser stripped nine meaningful `tests.` ID prefixes. The original
  launcher, incomplete result and outer exit remain retained. Independent strict
  segmentation of the original log finds all 699 distinct expected IDs with
  exactly one outcome each, including both sets of nine imported/top-level peers.
  The exact unfiltered managed test command and test phase exited 0. No test
  selection, assertion, input or invocation changed; no rerun was needed.

The README policy overview and the named language, assurance, trusted-boundary,
development, capability and capacity records agree. The Oracle and embedded
function/procedure binding packages are unchanged. The original 288
source/verdict pairs and all 88 positive fixture sources are preserved.

## Independently checked complete evidence

The [repair packet](../evidence/advisory-policy-391-20261116/README.md) retains
the exact inputs, successful runs, failures and their dispositions.

- Native run `20261116T232749-c8fb976a6d5c` and subsequent build passed. All
  2,606 input hashes, 80 report hashes, 12 tool identities and archive/live
  manifest equality were verified. Read-only `validate_provenance` and
  `audit_sources` independently pass: 19,515 checks (1,724 flow and 17,791 proof),
  zero skipped checks or `pragma_assume`. This uses retained sessions/cache.
- Lean run `20261116T233445-6dce1a7dbb80` passed with original exit zero. All
  1,116 repository inputs, 1,011 workspace inputs, 6,046 compiled artifacts,
  both tools and the full log match. Manifest, workspace and fresh audit agree
  on 1,009 unique modules, including all 40 candidates and 32 source bindings.
  The audit checks 162,274 declarations with only `propext`, `Classical.choice`
  and `Quot.sound`. This is a cached build and fresh audit, without kernel replay.
- Suite run `20261117T002818-40d684ec306c` independently accounts for all 699
  IDs: 697 passes and two existing Linux-x86-64-only skips whose source decorators
  match this ARM64 host. All 1,307 frozen files, 2,606 native inputs and both
  binaries match before/after/current. All 33 twin-covering methods passed for
  88 sources and 196 execution cases; all 85 sample-source hashes and the sample
  manifest match, covering 148 checked execution cases. All 79 Python-auditor
  and 42 native-auditor methods passed. The archive digest and all 169 member
  digests match the retained originals. These are fresh results from one complete
  invocation using retained build/prover caches, not a combination of earlier runs.

No concrete in-scope implementation or validation finding remains. The repair
is accepted for publication and the owner-required external check of the final
head. This internal acceptance does not replace that external check or authorize
merge. Later documentation-only changes require consistency, link and whitespace
checks, with governed input identity preserved; they do not require another
proof or suite run.
