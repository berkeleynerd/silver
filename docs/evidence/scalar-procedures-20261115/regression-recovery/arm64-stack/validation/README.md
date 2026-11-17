# Unchanged scalar-guard suite with child soft stack — passed

Native Linux ARM64 (`silver-m4pro`) managed run
`20261115T223501-c0b18e3fdea3` passed **all 23 tests in the complete unchanged
`tests/test_scalar_guards.py` file**, with no failures, errors or skips. Original
launcher session **58002** returned **0**, matching its monitored child. The
managed outcome is success, with its recorded overall returncode null.
Unittest reports `Ran 23 tests in 16.359s` / `OK`.

The original full-suite run `20261115T220916-99f1eaeea331` remains failed at its
original environment. This focused success uses the independently reviewed
16 MiB child-soft-stack environment; it does not claim a production parser fix
or an 8 MiB pass. The separate stack diagnosis and review remain separate
records. No full regression suite, native proof, whole-project Lean checkpoint
or compiler build was repeated.

## Exact environment and boundary cases

The retained [launch-child.sh](launch-child.sh) runs `ulimit -S -s 16384`, then
records `resource.getrlimit(RLIMIT_STACK)` in a child probe before executing the
managed test command through shell `exec`. The probe records **soft 16,777,216
bytes / unlimited hard**. Its shell PID **466480** is the original monitor's
child PID and the managed runner PID; `exec` preserves that process and its
limits. See [actual-child-stack.json](actual-child-stack.json).

The original parent environment and terminal parent environment both retain
**soft 8,388,608 bytes / unlimited hard**, with `/proc/self/limits` snapshots
retained in [original-parent-stack.json](original-parent-stack.json) and
[terminal-parent-stack.json](terminal-parent-stack.json). The hard limit was
not lowered, and no persistent environment, production, test or harness file
was changed.

The separate attempted live `/proc/<runner>/limits` inspection did not produce
a retained record before the short run ended. Its assertion failed before
writing; the subsequent process inventory found the original launcher terminal.
[postlaunch-proc-observation.json](postlaunch-proc-observation.json) preserves
this limitation. The direct child limit record and exact `exec` script above
remain available. No successful check was repeated to fill that gap.

The unchanged exact-source-limit test passed. Its original method iterates
scalar counts **0, 1 and 32**, with depths **2001, 1993 and 1765**. Each subtest
asserts a **4096-byte** source is admitted and its **4097-byte** neighbor is
rejected with status 2. Thus all three boundary admissions and all three
oversize rejections necessarily executed successfully; no subtest was skipped
or failed. The entire 23-ID file, including its native composition tests, ran.

## Identities, execution and retention

Launch and terminal verification HEAD are both
`d2739f6a010b1a5491ee7d6468f71bf84767def0`. All **1,316 regression inputs and
2,606 native inputs** match their launch snapshots. Native inputs also match
the accepted complete native-audit manifest; all 80 report hashes remain valid.
Native/Lean tool identities and both built compiler binaries match launch.
Compared with the original full-suite snapshot, the only input difference is
the independently repaired `tests/test_lean_modules.py`; the scalar-guard test
and every other input remain unchanged. Full hashes are in
[full-suite-input-delta.json](full-suite-input-delta.json) and retained snapshots.

The runner automatically reserved **12 workers**. The existing **1.5 GiB host
headroom guard and no process-tree cap** stayed in effect; application policy
was unchanged. No restart, duplicate, interruption, guard or attachment occurred.
Five resource samples had a maximum interval of 5.0126 seconds; peak sampled
tree/process RSS was 539,744 / 71,136 KiB and minimum host available memory was
15,206,848 KiB. Managed elapsed time was 16.723 seconds; wrapper elapsed time was
20.027 seconds.

[verification.json](verification.json) and [test-results.json](test-results.json)
record exact scope and all IDs. `run-packet.tar.gz` retains 34 preparation,
limit, launch, monitor/resource, terminal, input/tool/binary, result, collector
and managed-log members. Every member's size and SHA-256 were read back from
the archive and checked against [retained-files.json](retained-files.json);
[retention-verification.json](retention-verification.json) records that check.

Selected monitoring/evidence role: GPT-6.1 Sol, High. Runtime telemetry and
token/cost measurements are unavailable. The validation owner edited only
scratch/artifact and bounded evidence files.
