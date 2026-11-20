# PR #403: fresh external suite applicability, 2026-11-20

**Accepted as the final regression checkpoint.** The external review's complete
Linux x86-64 suite supplies fresh successful coverage of every final test on the
reviewed inputs, with its invoking stack recorded and enforced. Current regression
coverage therefore no longer depends on the earlier composition of 722 retained
ARM passes and two fresh x86 passes. The historical ARM stack setting remains
unknown; accepting this new complete result neither reconstructs that setting nor
waives its historical recording requirement. No additional ARM run or owner waiver
is needed for the current regression checkpoint.

The reviewed head is `9cf913a3a4a69cb40fe99ea39f21d0e237647fe1`, tree
`9079ea5a6a2628b8093110733e5097366b0e1cf1`. The external checkout remains clean
at this head. This bounded assessment did not change the head or run tests,
builds, native proofs or Lean checks.

The external review root is
`/home/agent/silver-review/runs/pr403-9cf913a3a4`.
Its job is `20261120T130632-078198218-exec-07856a`; the underlying managed test
run is `20261120T130632-15ab84282224`, under
`checkout/.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs/20261120T130632-15ab84282224`.

Independent checks completed during this assessment establish:

- All **1,348 captured inputs** match their current bytes. The **1,340 repository
  inputs** also match their exact Git blobs at the reviewed head. The **eight
  support inputs** match: the reviewer-built compiler, three generated Ada files,
  three Alire context files and Python.
- The raw managed native log contains **724 distinct test IDs, all passing, with
  zero skips**. Their set exactly matches the committed final test inventory.
  The external job's stdout equals that native log after its launcher banner.
- The command was `python3 scripts/dev.py test`, whose child used unittest
  discovery over the full test suite. The test phase and external wrapper both
  exited zero; the managed outcome is success. The managed final event's null
  return code is the runner's normal successful context-manager behavior, not
  a missing test-phase result. No timeout, watchdog interruption or stray-process
  cleanup occurred.
- The host was **Linux x86-64**, machine `silver`, with **22 available CPUs and
  22 managed workers**. The invoking stack was **16,384 KiB**. This was enforced:
  `kit/tools/runner.py` passes the recorded `stack_kib` through `heavy_command`
  to `run_guarded`; `kit/tools/svlib.py:182-185,212-222` applies
  `resource.setrlimit(RLIMIT_STACK, (stack_kib * 1024, hard))` in the subprocess
  pre-execution hook. Failure there would prevent successful execution. Some
  tests intentionally set smaller limits for their own children; those do not
  change the recorded invoking limit. The kit is under `/home/agent/silver-review`.

The managed run began at `2026-11-20T13:06:32.658938+00:00` and finished at
`2026-11-20T13:45:23.375938+00:00`. Unittest reported **2329.820 seconds**;
managed duration was **2330.666837034 seconds**, and external wrapper duration
was **2330.956 seconds**. These are separate observed timings.

The retained source records are `artifacts/exec-summary.md`,
`artifacts/exec-results.json`, `artifacts/ledger/ledger.jsonl`,
`spool/results/20261120T130632-078198218-exec-07856a.json`, the corresponding
`artifacts/probes/jobs/20261120T130632-078198218-exec-07856a/command.stdout`,
and the managed run's native log and events. Job stderr is empty. Verified
SHA-256 identities are:

| Record | SHA-256 |
| --- | --- |
| Managed native log | `1893d4362f30dc6e97ef346f66970b9a330a609f1dd7d5afb09ffedeb45f991b` |
| Managed events | `7c40da4e77a2253777115b495815e9b7b07e866803442d1df3033e2a762fcd8b` |
| External job result JSON | `af150484b3a94f14c31cd6357b9166beb6d5286de15f42d0cb7e2e00c93a5f87` |
| Reviewer-built compiler | `841d4f40406132d769aee76d9cfa86687ae96192e3e16fb7ba87a7ce2697befa` |

Under `development.md:283-320`, a successful complete suite on stable delivery
inputs directly satisfies the regression/sample requirement. Linux is the
primary platform; this samples-only delivery has no requirement for a fresh
suite on every native architecture. The new complete Linux result makes the
earlier ARM regression composition historical supporting evidence. Repeating
the suite now would add no identified missing regression evidence.

The external Claude Fable 5.2 draft reports no blocker or medium finding, one low
historical stack-record gap, and six informational observations. Its question
about an owner waiver relies on the earlier regression composition continuing
to be the delivery's final coverage basis. This disposition accepts the complete
fresh run instead. Preserve the external draft and its historical observation;
record this disposition without silently rewriting the reviewer report or
claiming that the old ARM recording obligation was fulfilled retroactively.

**Native and Lean assurance remain separate.** The new regression suite is not
a new complete compiler proof, Lean import audit or kernel replay. The separately
accepted retained ARM native/Lean assurance and its applicability/recovery reviews
continue to supply those claims. This assessment does not reopen or expand them,
and does not claim fresh ARM or macOS execution. Within this bounded question,
no missing current regression evidence was found; ordinary retention and finding
disposition remain for the coordinator.

Selected review configuration: **GPT-6 Astra / Max**; runtime model/effort and
token/cost telemetry were not independently exposed. The live harness goal was
null at handoff. CLI recall was not updated. Only this scratch report was written;
no tracked source, evidence packet, GitHub record, branch or commit was changed.
