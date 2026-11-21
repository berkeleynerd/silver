# Retained maximal-expression serial proof — 2026-11-21

The original 64-operand test `20261121T191653-cdd01ba978f7` remains **failed**
at its 1,800-second harness deadline. Its prover continued, confined to guest
CPUs 0–1 and accounted for by observation run `20261121T194920-1da1c3dafb35`.
The original prover's exit status is unavailable after its parent exited.

The final report was written at 21:13:08 UTC, 6,972.609 seconds (116.2 minutes)
after the recorded prover start. The independent report/policy audit
`20261121T211645-73b5c53ca60a` passed: five units, 17 entities, 19 flow and
110 proof checks, with no accepted advisory or unproved record. The retained
solver sessions contain successful CVC5 and Z3 results; unsuccessful individual
solver attempts do not denote an undischarged final obligation. This is a
retained-report audit, not a passing compile/build/run test.

Commit `4373508bf6` raises only this test's harness deadline to three hours,
using that measured serial proof as its basis. Production solver limits,
admission rules and required discharge remain unchanged. The fresh full suite
`20261121T211830-07948902a0f6` must establish the complete end-to-end result.

`reports/` contains compressed original application reports and Why3 sessions;
`main.adb` is the actual generated application source. `runs/` retains the
managed records, including the failed first audit launch and the intermediate
audit whose elapsed-time field was subsequently corrected. The final result
is `assessment/result.json`. The assessment scripts and observation JSON are
agent-authored. Their original relative paths resolve from the
`tmp/named-array-parameters-410` worktree, not this delivery directory.
`sha256.json` records original and retained bytes; `.gz` files decompress to
their originals. No fresh native proof or executable result is claimed here.
