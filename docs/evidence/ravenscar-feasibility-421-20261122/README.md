# #421 upfront Ravenscar feasibility — Linux x86_64, 2026-11-22

The pinned GNAT 16.1 / GNATprove 16.1 installation accepts a compiler-owned
Ravenscar configuration for unchanged, annotation-free application units. A
small package containing an initialized protected counter and one persistent
library task proves, compiles and binds. A single-caller protected-entry variant
also proves and builds. Both executables remain alive during a one-second
external observation and are explicitly stopped by the harness.

**This establishes the source/profile/tool route, not complete Ravenscar runtime
semantics on this host.** The unprivileged native process actually uses Linux
`SCHED_OTHER`; the selected runtime explicitly ignores ceiling locking without
root or `CAP_SYS_NICE`. No scheduling privilege, runtime, production source,
production proof, or Oracle change was made. These are exploratory producer
probes, not canonical Silver assurance, language admission, a Rosetta delivery,
or completion of #421's later integrated scope.

The lead authorized these bounded probes under #421 alongside #416, following
authorization commit `1fac6fa1331fe6e778e6b2ae46b867ab44f362c6` (PR #423).
The installed checkout remains at
`/home/canto/src/github.com/berkeleynerd/silver/tmp/named-array-parameters-410`,
branch `feat/bounded-packages-416`; its retained path was not moved or bootstrapped.
The probe root is
`/home/canto/src/github.com/berkeleynerd/silver/tmp/ravenscar-feasibility-421`.

## Configuration and exact producer route

Every case has a separate immutable author-source/configuration set and a
separate writable `out/` directory. Author units contain only the permitted
`pragma SPARK_Mode (On);`; there are no author contracts, loop invariants,
flow/state annotations, assumption pragmas, suppression pragmas, or source
rewrites. The configuration is exactly:

```ada
pragma Profile (Ravenscar);
pragma Partition_Elaboration_Policy (Sequential);
```

Each project selects its exact source files and Main, with these relevant
attributes:

```ada
package Builder is
   for Global_Configuration_Pragmas use "ravenscar.adc";
end Builder;
package Compiler is
   for Default_Switches ("Ada") use
     ("-gnat2022", "-gnata", "-gnato", "-g");
end Compiler;
```

The [baseline project](cases/baseline-v2/probe.gpr) and its
[configuration](cases/baseline-v2/ravenscar.adc) are retained. The application
sources are [Main](cases/baseline-v2/src/main.adb),
[package specification](cases/baseline-v2/src/bounded_probe.ads), and
[package body](cases/baseline-v2/src/bounded_probe.adb).
The protected private Integer has range `0 .. 100`, is initialized to zero, and
is incremented only under its own `Value < 100` guard. Both Main and the
persistent worker call that protected operation. No priority aspect is required
for this example. The pinned `System` specifies default task priority 48 and
ordinary priority range 0 through 97.

The actual direct prover invocation for the corrected baseline, after the
managed runner adds its allocated worker count, is:

```text
gnatprove -P /home/canto/src/github.com/berkeleynerd/silver/tmp/ravenscar-feasibility-421/baseline-v2/probe.gpr --subdirs=explore/initial --mode=all --report=all --warnings=error --level=2 --timeout=30 -U -v -j8
```

It was invoked through `python3 scripts/dev.py tool --task
421-baseline-v2-proof`, declaring `baseline-v2/out` as the writable workspace
and each of `probe.gpr`, `ravenscar.adc`, `src/main.adb`,
`src/bounded_probe.ads`, and `src/bounded_probe.adb` individually with `--input`.
All subsequent cases likewise declare their exact source/configuration files.
These are deliberately exploratory `tool` runs, with distinct `explore/`
outputs. The package-composition control additionally uses `--no-inlining` and
`--subdirs=explore/no-inlining`; it does not change a production proof policy.

The baseline build command was:

```text
gprbuild -P /home/canto/src/github.com/berkeleynerd/silver/tmp/ravenscar-feasibility-421/baseline-v2/probe.gpr --subdirs=native -p -v -j8
```

It used `dev.py tool --task 421-baseline-v2-build` with the identical declared
source/configuration inputs. [The identity comparison](source-identity-checks.json)
checks matching captured hashes for both proof/build pairs: the baseline and
entry case. The compiler and GNATprove logs both show the same `-gnatec=.../ravenscar.adc`.
The binder consumes the resulting ALI settings rather than receiving a separate
configuration-pragma argument. The retained
[binder source](cases/baseline-v2/native/b__main.adb) records:

```ada
Locking_Policy := 'C';
Task_Dispatching_Policy := 'F';
Partition_Elaboration_Policy := 'S';
Detect_Blocking := 1;
```

It invokes `Activate_All_Tasks_Sequential` after library elaboration. The
[application ALI](cases/baseline-v2/native/main.ali) records the Ravenscar
restrictions and configuration flags. Thus the profile and sequential
elaboration settings propagate through proof, native compilation and binding
without changing the author units.

The runtime is the **default full native GNAT runtime**, not a newly installed
or custom Ravenscar runtime. No `--RTS` override was used. Native linking selects
`libgnarl.a` and `libgnat.a` from the pinned GNAT tree under
`.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adalib/`,
with the native OS libraries. [Runtime inventory](host-runtime-inventory.json)
records the selected archives and relevant runtime sources by hash; each
managed event file also retains the tool binaries, versions and hashes.

## Cases and retained outcomes

| Case | Outcome and precise scope | Managed run(s) |
| --- | --- | --- |
| Initial `baseline` | Compile-stage failure: `SPARK_Mode` was incorrectly placed after Main's context clause. Preserved unchanged; corrected by putting it first in the separate `baseline-v2` source. | `20261122T123645-37d7c9eab9cd` |
| `package-state` | Normal producer policy: 4 checks proved across Main and body-private / visible-spec initialized scalar counter packages. Exported zero-formal Increment and Read need no author state/flow aspects. | `20261122T123740-b341b5db4e30` |
| `baseline-v2` | 5 checks proved; unchanged sources/configuration build and bind; controlled persistent-task observation. | Proof `20261122T123813-74ba56486128`; build `20261122T123845-d595d0502f50`; observation `20261122T123923-e7fe821098b8` |
| `package-composition` | 5 checks proved with `--no-inlining`; adds Reset and an earlier-package Step/Read wrapper over body-private state, plus Main calls and visible-state control. A different exact source set from `package-state`, not a same-input policy comparison. | `20261122T124209-9d0ed8a9434d` |
| `entry` | 5 checks proved; one Boolean-barrier protected entry, one worker caller, Main only releases it. Builds; controlled waiting-task observation. | Proof `20261122T124259-0ba597ce5be9`; build `20261122T124343-e0632f90b4db`; observation `20261122T124419-539abe48df82` |
| `clock-naive` | **Failed discharge:** 6 proved, 1 unresolved range check at repeated `Next := Next + Period`; actual managed failure retained. | `20261122T124455-325a4307f664` |
| `clock-guarded` | 8 checks proved after explicit `Next <= Time_Last - Period` guard and final-time delay branch. Proof only; no native build or clock observation performed. | `20261122T124545-2b52ecb68e97` |
| `entry-two-callers` | **Failed discharge:** high `CONCURRENT_ACCESS` when Main also calls the entry, with 1 unproved concurrency check. Producer exit and managed record are successful; this is not a proof success. No native build or execution. | `20261122T124616-9c127060e923` |

[Run summary](run-summary.json) includes exact actual argument arrays, managed
outcomes, reviewed dispositions, allocations, fingerprints and inputs. Each
`runs/<run-id>/` retains the complete `native.log` and `events.jsonl`; each case
retains its raw `.spark`, summary, SARIF and generated-global ALI records where
produced. [Report inventory](report-records.json) summarizes the actual emitted
entities and record classes. No failed experiment was overwritten or promoted
to a success.

## Package-state implications for #416

The [normal package pair](cases/package-state/src/hidden_state.ads) and
[modular wrapper](cases/package-composition/src/package_client.adb) answer the
lead's initial uncertainty positively. Body-private initialized scalar state
can be accessed by exported package routines without author `Abstract_State`,
`Refined_State`, `Global`, `Depends`, or `Initializes` aspects in the pinned
producer. The generated phase-one ALI records the private Value as an input
and/or output according to the operation and as initialized by the package.

The pinned guide `references/spark/16.1/docs/ug/en/source/how_to_write_package_contracts.rst:4–17`
documents default state abstraction and initialization generation. The probe
also confirms the actual producer behavior, including a non-inlined wrapper
call chain. This supports choosing useful body-private state in #416; it does
not establish an admission, effect, elaboration, termination or automatic
discharge theorem for all package programs.

## Report entities and checks

The protected baseline report owns separate entities for the package, protected
object, protected procedure, protected function and task. Main's report owns
Main and also lists referenced callee entities: every item in `entities` is not
necessarily an owned `spark` entity. All owned entities in successful probes
are marked `all`; the skip/proof-assumption lists are empty.

| Actual record class | Observed role |
| --- | --- |
| `VC_RANGE_CHECK` | Protected bounded increment; millisecond conversion and Time arithmetic in clock probes. |
| `VC_CEILING_PRIORITY_PROTOCOL` | Separate potential-caller checks for Main and the task, located at their declarations. |
| `VC_TASK_TERMINATION` | Message is **“nontermination of task proved”**, located at the task declaration; it does not say the service finishes. |
| `SUBPROGRAM_TERMINATION` | Flow record proving the protected or ordinary getter's implicit `Always_Terminates`. |
| `CONCURRENT_ACCESS` | High flow diagnostic at Main for two potential callers of one entry. The text says “more tasks than allowed might queue ... (restriction No_Entry_Queue active) (SPARK RM 9(11))”. |

The entry adds a separately owned entry entity. The valid one-caller case does
not emit a positive `CONCURRENT_ACCESS` record. This makes the negative control
useful for identifying the actual failing record class. The clock task's
generated globals include synchronized `Ada.Real_Time.Clock_Time` in its input
set. The inherited arithmetic checks appear as `VC_RANGE_CHECK`, not an
author-visible precondition annotation.

The native summary table classifies ceiling and task-nontermination checks under
run-time checks in these examples; its category named “Concurrency” is empty
for the successful probes. It is populated by the failing entry-flow check.
An audit must inspect the actual records and complete selected unit/entity
closure rather than infer coverage from a summary category or a Main-only
expectation.

The two-caller run was a direct `dev.py tool -- gnatprove` invocation, with no
expected-negative wrapper or diagnostic-acceptance handler. GNATprove and
`dev.py` returned zero. `dev.py:605` asks the run-history failure extractor for
unresolved obligations; `scripts/run_history.py:334` examines only `.spark`
`proof` records, and its SARIF branch at line 350 selects only `VC_` rules.
This high `flow`/`CONCURRENT_ACCESS` record is outside that extractor's scope.
Accordingly, the retained managed success denotes successful tool execution
here, while the raw producer report proves that discharge failed. This is a
limitation of interpreting exploratory status, not evidence that the canonical
Silver audit accepts it: `scripts/check_evidence.py` independently checks flow,
proof and warning/error records. No classifier or audit was changed by this
subthread.

## Runtime observations and environmental qualification

[The external observer](observe.py) launches the exact built binary, pins the
application to CPU 0, samples `/proc` thread state and affinity for one second,
then sends SIGTERM to its process group and waits for it. The executable hash
is a declared managed input. Observations are separate outputs, so executable
and source/configuration inputs stay immutable during the run.

Both [baseline](cases/baseline-v2/runtime.json) and
[entry](cases/entry/runtime.json) have two threads throughout the sampled
interval, no stdout/stderr, and remain alive at the deadline. Both are stopped
by harness SIGTERM with process result `-15`. This is never reported as normal
task completion. The baseline worker remains runnable and consumes CPU; the
entry case's two observed threads wait on futexes, consistent with environment
task waiting and the persistent worker waiting on the entry. These samples do
not inspect the private scalar value or establish an execution trace for every
synchronization point.

The shell's stack limit was set to 16 MiB for every managed native invocation;
each observer records 16,777,216 bytes. This is not a measurement or universal
bound of each Ada task's stack. The real host is Linux x86_64, eight available
CPUs with guest mask 0–7. Every managed probe automatically reserved eight
workers and inherited runner affinity 0–7; application observation deliberately
used one CPU, independently of the development worker allocation. Runs were
serialized, and this subthread has no remaining worker reservation.

All sampled native application threads have scheduling policy 0
(`SCHED_OTHER`), real-time priority 0. The host process has uid/euid 1000,
no effective capabilities, and `RLIMIT_RTPRIO = 0`. The selected
`adainclude/s-taprop.adb:220–247` enables ceiling support only when the process
is root or has `CAP_SYS_NICE`; its own comment says an unprivileged request for
Ceiling_Locking is ignored. Lines 371–378 install `PTHREAD_PRIO_PROTECT` only
when that support predicate is true. Lines 705–721 request `SCHED_FIFO` for
dispatch policy `F` but permit `EPERM` or `EINVAL` without raising an exception.

Consequently, successful startup and correct binder flags cannot establish
actual FIFO dispatch or priority-ceiling enforcement here. Existing native
mutex locking still supplies mutual exclusion under its ordinary trusted
runtime/OS assumptions; no native exception or concrete data-safety failure was
observed in these single-object probes. The missing ceiling premise is more
than a timing benchmark limitation for arbitrary future compositions: arguments
that rely on ceiling locking to prevent nested protected-action blocking or
deadlock cannot be imported unchanged into this unprivileged environment.
No such general composition is established by these probes.

For a future full Ravenscar runtime claim, document a supported environment
that actually grants and honors the selected dispatch/ceiling services, and
validate it separately. Merely naming a privilege is not a proof that the
kernel/container policy honors it. The current observations claim no fairness,
deadline, schedulability, lock-order, general deadlock, queue-capacity, stack
capacity, or hard-real-time result. The bounded package increment is independent
of these later tasking environment conditions.

## Clock scope and next work

The naive positive-period recurrence can exceed finite Time. The unresolved
range check is retained together with its diagnostic checkpoint in [notes](NOTES.md).
The tool's suggestion to add an author loop invariant was not followed. The
[guarded source](cases/clock-guarded/src/bounded_probe.adb) instead branches on
`Next <= Time_Last - Period`; all eight emitted checks discharge without
author annotations or a narrowed Clock-return domain.

The guard's else branch repeatedly delays until Time_Last. Once that instant
has passed it need not block, so this is not a selected periodic-service or
horizon-exhaustion policy. #420 still needs a specified full-domain behavior,
the corresponding admission/composition/discharge argument and the exact
approved clock environmental assumptions. The clock probe was not built or run:
the lead stopped further characterization after the bounded proof result.

#416 can proceed with initialized private package state, ordered visibility,
an exact source-unit closure and complete package/routine coverage. #417 and
later tasking work must add their complete ownership/effect/interleaving model,
priority and call-chain rules, relevant report classes, capacities and runtime
premises. The shared compiler-owned configuration is a feasible implementation
route. Complete native/Lean/source assurance, production report acceptance,
regression/sample delivery and independent review remain future work for those
increments. Nothing here admits a new Silver construct.

## Round and handoff record

Selected role/model/effort: Astra Max, confirmed by the lead's assignment;
the subthread cannot independently query the live serving model/effort.
Twelve managed runs total 67.025 seconds including preflight and bookkeeping;
completed `native-tool` phases total 44.085 seconds (the initial compile-stage
failure has no matching phase-end event and is excluded from that phase sum).
Total agent reasoning time, token count and cost are unavailable. No full
native compiler proof, Lean build or broad regression run was started.

The initial configuration-placement failure, naive time failure and two-caller
flow failure are retained honestly. All declared successful probe inputs remain
unchanged. The only subthread writes are under the assigned probe root and
managed-run output; unrelated untracked package documentation and existing
scratch in the installed checkout were preserved. There is no harness goal,
Git commit, GitHub mutation or CLI memory update by this subthread. The lead
owns issue retention and subsequent implementation planning.

`SHA256SUMS` binds the retained files. Raw mutable build workspaces remain at
the probe root for diagnosis; this retained set is suitable for the lead to
copy into the issue's evidence record. Binary identities are in
[native-artifacts.json](native-artifacts.json); the binaries remain in their
original installed-path workspaces rather than being relocated for execution.
