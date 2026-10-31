# Complete Boolean regression coverage

Issue #291, native Linux, 2026-10-30. Final coverage consists of 565 unchanged
passing unittest IDs from the complete suite, two freshly passing corrected
branching methods, and the freshly passing maximum dynamic-expression method.
That covers all 568 unique unittest IDs and 559 distinct test methods. Nine
SharedBindings methods already execute under two module-name spellings; this
feature does not add or remove those repeated executions.

The original complete run `20261030T133820-8804240ce92e` executed 568 tests in
7,866.238 s. It remains a failed run: three subtest assertions in one branching
method used obsolete rejection expectations, and the maximum dynamic-expression
method exceeded its existing 300-second test deadline. No other test failed.
The complete manifest sample test passed, including the final Boolean samples.

The original root checkout temporarily held the exact tracked non-evidence
snapshot `927cc5e178`: 12,053 files. All 131 native source files matched the final
compiler build, whose SHA-256 is
`86617db42c93c7ecd98528e7e117210534e43305cce3ecf5241701014933f216`.
The retained discovery wrapper reproduces the ordinary 568-ID inventory and
restricts its child to CPU affinity `[0,1]`; the managed parent reserves two
workers. The producer's normal settings were unchanged. Its internal `-j12`
was observed, so the affinity restriction is not a two-process internal cap.

Because `dev.py` does not perform its successful-run postcheck after a nonzero
unittest result, a separate terminal check was required before changing any
input. `terminal-input-verification.json` records exact agreement for all 839
managed captured hashes, all 12,053 snapshot hashes, the captured wrapper,
inventory and compiler binary. The observed hash maps, original snapshot map,
events and log are retained here. No fixture was changed before that check.

The reviewed correction `29bc1d44d7` moves three now-admitted Boolean fixtures
from an existing negative method into an existing positive method. It changes
only those two methods in `tests/test_branching.py`; the helper and other tests
are unchanged. The two methods pass in run `20261030T155127-bf12fb89db9a`.
The maximum-expression method initially hit the same 300-second deadline in
that two-CPU rerun. It then passed unchanged in 150.108 s with eight reserved
CPUs in run `20261030T160408-2c742ff18bd0`. See the
[rerun record](../terminal-reruns/README.md) for both failures, allocation and
proof-policy details. The original failed outcomes are not relabelled.

[Final coverage](../terminal-reruns/final-coverage.json) compares every original
execution ID with the saved inventory and the fresh results. It distinguishes
unique unittest IDs from distinct methods and lists the nine repeated methods.
The [independent applicability review](../../../reviews/review-boolean-regression-37c0babc64.md)
confirms the 565 retained plus three fresh result composition. Source/native
complete proof and later final Rosetta metadata checks remain separate work.

After retaining the results and verifying the final 12,053-file snapshot with
only the reviewed branching override, the agent restored the original root's
355 temporary snapshot changes, all 131 original native source files, and its
original branching fixture; both owned discovery/rerun wrappers were removed.
Git status was then only the preexisting untracked `tmp/` area. Artifacts,
tools, caches and unrelated scratch remain preserved. The complete native proof
continues in its separate installed worktree and was not changed by restoration.

Selected native subthread: GPT-6 Astra / Extra High. Live runtime model
confirmation and token/cost measurements are unavailable. This round closed
regression coverage and preserved the initial fixture/deadline failures; the
allocation remedy is not a controlled performance experiment.
