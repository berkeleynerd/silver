# Final named-array regression and delivery checkpoint — 2026-11-21

Full run `20261121T211830-07948902a0f6` passed all **785** distinct unittest
identities on frozen `4373508bf6`: zero failures, errors or skips, 7,832.123
unittest seconds. Its managed success was recorded at 23:29:05.910685 UTC after
7,834.324 seconds. It used two managed workers, guest CPUs 0–1, a 16 MiB invoking
stack and the primary worktree's installed compiler. The full sample manifest
and maximal 64-operand expression both passed; the latter is a completed
compile/proof/audit/execution regression, distinct from the earlier retained
proof-only measurement and failed deadline attempts.

`full-suite-ids.txt` contains all 785 identities, including separately discovered
imported/inherited tests. Its SHA-256 is
`11777474d4a60c05987b2839070f4a4e5539cc84602ebffc5d6ab00c4b22e1ec`.
Wrapped descriptions and interleaved subprocess output can place a test's
passing disposition on a later line. The original log contains 785
test headers and 785 passing dispositions, followed by the 785-test/OK summary.

The retained compiler build `20261121T190603-f8f3c039687c` passed in 4.324 managed
seconds on the primary installation with two workers and CPUs 0–1. All 148
captured production/configuration inputs match this delivery tree. Its original
generated paths/tool identities retain their primary-installation scope; the
full suite captures the installed compiler binary. No installation was moved,
bootstrapped or rebuilt during final documentation closeout.

## Final input applicability

The final implementation/proof endpoint is `7f449246ce`; `562207798f` adds the
retained evidence/review index. Of the full suite's 1,401 captured inputs, 1,387
closeout files matched before metadata promotion, six proof files differ, seven
entries describe the original primary installation and one external Python
executable is unchanged. `full-suite-summary.json` records exact proof hashes
and installation scope. `input-applicability.json` records the final metadata
change and complete test composition.

The [independent coverage review](../../../reviews/review-named-array-audit-coverage-20261121.md)
and linked consumer/metadata reviews identify exactly **15** affected readers
for the final six proof-file changes, including deletion of the duplicate
module. Run `20261121T215753-de0dae34a5b9` passed all 15 on `7f449246ce` in
174.128 test seconds, using the separate proof worktree and six automatically
allocated workers alongside the two-worker suite. `proof-rerun-ids.txt` retains
those selectors. Production Ada, scripts, tests, catalogue and samples are
byte-identical to the full-suite inputs. No native/proof change is introduced
by final support metadata or documentation.

Final promotion changes only the precise supported identifier and two affected
task assessments, plus the assessor's current-language account and generated
positions. Its twelve `test_rosetta.py` identities are disjoint from the fifteen
proof readers. Thus all 785 final identities are accounted for: 758 applicable
full-suite passes, 15 passing proof-reader reruns and 12 passing Rosetta rechecks.
The completed full suite itself passed every baseline identity; this composition
distinguishes fresh affected coverage from reuse. The earlier
[applicability review](../regression-applicability/REVIEW.md) required a fresh full
suite at its then-784-test snapshot. This completed 785-test run and the accepted
final-reader analysis supersede that pending recommendation; its historical
failures, interruptions and qualifications remain unchanged.

## Final Rosetta checks

Managed render `20261121T233151-52b966341665` passed in 3.367 seconds. It used the
existing primary native tool installation, with explicit input files and the
separate closeout output workspace declared to the runner. Managed test run
`20261121T233202-07a8576e778c` passed all **12** Rosetta tests in 4.424 unittest
seconds (6.211 managed seconds), directly in the closeout worktree. Both reserved
the automatic eight workers with OS affinity to guest CPUs 0–7. The test suite
checks deterministic rendering across two hash seeds against the final promoted
coverage and unchanged manifest/renderer. `rosetta-test-ids.txt` retains exact
identities.

The render has 1,576 candidates in 44 stages. Dot product is Stage 1/rank 53 and
Horner Stage 1/rank 88. Seven later construct stages shift down one; only existing
stage issue #415 needs a Stage field value change (38 to 1). Other existing stage
issues retain their values and Closed/Done status. The lead completed the
stage/issue bookkeeping and marked PR #412 ready on November 22 after the
[independent delivery confirmation](../../../reviews/review-named-array-delivery-20261122.md).
The delivery issues remain open/In review until an authorized merge.

The first final-render attempt `20261121T233118-8e63bc6baccb` remains failed. It
stopped before command execution because the selected proof worktree had no
native Alire installation. Its 1.037-second failed record is retained; the retry
used the already installed primary toolchain rather than moving or recreating an
installation. This failure changes no source/proof/test result.

`runs/` retains compressed original runner events and logs, including the original
full-suite wrapper log. `sha256.json` records original and stored hashes; no
lead-written summary replaces runner output. Complete native and Lean/source
assurance and scoped independent reviews remain separately linked in the
[delivery record](../../../named-array-parameters.md#delivery-assurance-and-validation).
No clean rebuild, independent kernel replay, macOS run or merge is claimed.
