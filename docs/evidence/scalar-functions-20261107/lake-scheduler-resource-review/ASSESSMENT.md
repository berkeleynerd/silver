# Lake-only scheduling hold: bounded assessment

Disposition: a single-process Lake stop is supported as a reversible, monitored
way to defer further Lake launches. Reject the stronger premise that existing
children necessarily finish while Lake is stopped, or that this releases memory.
It is not an alternative to the agreed urgent-pressure response. No intervention
is recommended from the observed 25.43 GiB headroom, and none was performed.
There is no tested scheduler-hold implementation or new control experiment here.

## Exact scope and observed settings

Run 20261108T094147-fb5330310904 is the complete required Lean build/audit on
f630/parser036a, in ../scalar-functions-source-integration-298; its inspected
checkpoint is in context.json. Python driver PID 691106 has start_ticks 6220611;
Lake PID 691697 has start_ticks 6223303, parent 691106, SID/PGID 691005.
65188 is the coordinator's unified-tool session ID, not a live OS PID.

The pinned toolchain is Lean/Lake v4.34.1. Current lake and lean executable hashes
match the managed preflight. The runner reserves two workers, sets the actual
Lake environment LEAN_NUM_THREADS=2, passes silverThreads=2, and active Lean
children use -j2. memory_mb is null; this is no aggregate memory bound. Observed
thread counts (Lake 10, certificate 8, helper 40) also show these settings are not
OS-thread caps. Native run 094547 remains another owner's twelve-worker run and
is outside any proposed signal target.

At 13:45:57 UTC, MemAvailable was 25.43 GiB, with 62.87 GiB total RAM and no swap.
OutputBodyCertificate PID 834812 used 26.34 GiB, and ComposeHelperSourceCandidate
PID 881336 used 1.47 GiB. Both had a running compute thread in the snapshot.
The earlier ComposeBooleanArraySourceCandidate had completed: the retained log
records success in 351 s. Thus a stale sibling PID/label is unsafe. The previous
15.418 GiB observation is not a cap for this certificate or future siblings;
its remaining growth and completion time remain unknown. At 13:50:39 UTC,
MemAvailable was 26.31 GiB, certificate RSS had fallen to 24.19 GiB and helper RSS
was 1.52 GiB. Both snapshots remain above the existing low-memory triggers. These
changes also rule out treating the earlier short-term slope as monotonic growth.

## Why the mechanism has limits

- Lake's Build/Job/Monad.lean:169–173 creates build jobs as tasks in the Lake
  process. Once all threads of that process are stopped, those tasks cannot
  launch more subprocesses. A child may have been spawned just before the stop
  takes effect; the post-stop census must check that race. This does not constrain
  native work or subprocesses independently spawned by a child.
- Build/Actions.lean:59 calls rawProc; Util/Proc.lean:34 calls IO.Process.output.
  Init/System/IO.lean:1544–1557 spawns Lean with piped stdout/stderr and null stdin,
  reads stdout in a dedicated Lake task, reads stderr in the job task, then waits
  for exit. Actual /proc fd links independently show these pipes terminate in
  Lake; four Lake threads were in anon_pipe_read. The Python driver drains only
  Lake's outward pipe. It cannot keep the child pipes drained while Lake stops.
- SIGSTOP to only Lake stops those readers too. Existing Lean children continue
  computing/writing their own files unless they independently block. Their
  output buffers are finite; a diagnostic or other output can fill a pipe and
  block a child. No output-volume bound or pipe-capacity observation establishes
  that the current children will finish silently. No pipes were opened or drained
  by this reviewer, and no debugger/ptrace intervention was used.
- A quiet child can exit while Lake remains stopped; its address space is then
  released even if the process remains an unreaped zombie. That is not yet a
  successful Lake module. Build/Module.lean:981–993 runs the compiler, then clears
  output hashes and computes artifact metadata. Build/Common.lean:307–330 writes
  the successful trace only after that action returns. Those steps and dependency
  scheduling wait for Lake to resume. Direct .olean appearance or child exit is
  not complete evidence, and killing Lake while bookkeeping is pending can lose
  reusable completion metadata. Do not move/delete artifacts or release leases.
- check_lean.py:362–387 blocks on Lake's output and exit with no phase timeout.
  Stopping Lake alone does not make this driver finish or report failure. Driver,
  Lake and observed children all retain the actual managed lease descriptor.
  Reservations/workspace exclusion therefore remain active, as they should.
  A pause's elapsed time remains part of the eventual run duration.
- SIGCONT resumes all Lake tasks: pipe draining, completion processing and new
  launches together. The inspected pinned paths provide no control that resumes
  only readers while leaving launches disabled. Short resume/stop pulses cannot
  guarantee exclusion of a new sibling. These are source/process observations,
  not a live pause/resume experiment or a universal scheduler proof.

## Minimal contingent procedure, for the coordinator only

1. Continue the existing host/process monitoring at healthy headroom. Keep the
   agreed decision triggers: 15 s observations during an excursion below 12 GiB;
   two successive low/falling samples, or a sustained decline projecting 8 GiB
   within 60 s, require reassessment. At or below 8 GiB use the existing prompt
   evidence-preservation and targeted interruption procedure for the verified
   current dominant owned Lean child, never native. A Lake-only hold does not
   satisfy that urgent response and must not delay it.
2. At a nonurgent reassessment, a coordinator may choose a preventive Lake hold
   if deferring replacement jobs is useful and the already-running children can
   still be monitored. This is a scheduling decision, not a claim of freed RSS.
   Before any signal, record UTC, MemAvailable/trend, run/lease, exact executable,
   command/CWD, PID, start identity, parent/group and all current children. Recheck
   identity immediately before acting; abort on mismatch or completed run. Use
   only the verified positive Lake PID, never a process-group/session signal or
   a stale child/driver/tool-session ID. No signal command was executed here.
3. Verify the stop actually covers every Lake thread before relying on it to
   prevent launches; rescan descendants to catch a just-started child. Preserve
   the Python driver, live lease, native processes and current child work. Every
   15 s inspect host memory, each child's RSS and aggregate thread CPU/state, and
   available per-thread wait channels. A sleeping main thread alone is normal
   and cannot diagnose a stalled Lean process. No decrease in RSS is promised.
4. A child exit/memory release can justify reassessing resumption. Pipe-write
   waits, apparent child stalls needing Lake, further falling headroom, or an
   external cancellation also require prompt reassessment: do not wait blindly
   for all children to disappear. Resume only the same verified Lake process when
   ordinary two-worker scheduling is acceptable again. Its next ready job may
   start immediately. There is no defensible universal resume-RAM threshold from
   the 15.418 GiB sample, and merely crossing back above 12 GiB does not establish
   capacity for another dense job. Keep observing after continuation.
5. If safe continuation and progress cannot both be maintained, the proposed
   hold has reached its limitation. Use the already-agreed targeted child-
   interruption policy as resource conditions require; do not improvise external
   pipe readers, signal-group cleanup, altered options or live scheduler edits.
   A genuinely independent scheduling gate with output drainage would require
   separate implementation/validation and is not proposed for this frozen run.
   Any interrupted required module remains failed/incomplete until it later
   succeeds. Stopping/continuing Lake alone should not be relabeled a proof pass
   or failure: retain actual exit, module records, input checks and fresh audit.

This conditional hold can preserve useful computation while postponing launches,
but it does not establish a memory ceiling, child-completion guarantee or an
assurance checkpoint. Keep every required module, source check, axiom audit,
domain and prover option intact. It is not necessary at current healthy headroom.

Selected reviewer: GPT-6 Astra / Extra High; runtime model/effort telemetry and
token/cost data are unavailable. Direct inspection occurred from approximately
13:39 UTC; capture timestamps identify actual resource observations. No signals,
process-control experiment, proof/test run, source/tool/config edit, lease/cache
change, publication or merge was performed. Live goal was null; CLI memory was
not updated. Owned files are this scratch directory and the existing review.
