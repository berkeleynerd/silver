# Retained exit timing-growth review

2026-10-20 UTC; #119 / #153. **Accepted under the stated selected-input,
source/native, ownership and service premises** at author freeze
`21c9034cbe5175b49aedb9484f2d5e48676e4cbb`, based on `14ba1434a8`.
No material defect or required repair was identified. This accepts the
timing-update, key/counter, table-preservation and traversal-input bounds;
it does not establish complete timing runtime capacity, exit capacity,
save capacity or physical adequacy.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 15:20:42 UTC; semantic review
completed at 15:23:56 UTC, an elapsed 194 seconds. The reviewer used a separate
Linux x86_64 worktree and owns only this report. The lead retains integration,
issues, durable memory and publication. The reviewer did not author the packet.

Exact review inputs are the [research argument](../research/retained-why-exit-timing-growth.md)
and all nine files in its [evidence packet](../evidence/retained-why-exit-timing-growth-20261020/README.md),
including the checker, pinned imports, 528-file lexical census, source/native
witnesses, manifest and five-case results. The review inspected the relevant
Debug, Driver, GNAT scheduler/main/report/config/check, Session, RAC, Fun and
Hashtbl source paths and retained native control. The accepted initial timing
values, source-prefix/pending-client attachment, driver envelope, interrupted
episode bound and ordinary-ending control were reused without replaying their
checkers. The format-only acceptance at report commit `06be10644bbf88e5842c33bc26dea8cf0744b995`
is a separately reviewed interface; its successful check was not repeated.

The source identities remain Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. The installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
the retained disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
Oracle 7–9, 13, 21 and 25, complete selected owner/callback closure and the
source/native/service distinction govern this review.

The following critical challenges were resolved:

- **Writer census and exposed alias.** The census includes bare Stats
  references as well as the timing API names. The actual clients are Debug,
  Driver, GNAT main/report, Session and RAC, plus the public signature.
  Privacy is not assumed: get_timings exposes the mutable table. Its sole
  external client folds bindings into a newly allocated list; the source and
  native callback construct pairs/list cells without mutating table bindings
  or retaining the table in the returned structure. Hashtbl.fold changes the
  traversal-sign field, so this client is correctly distinguished from a
  literally mutation-free operation. Selected immutable strings, fixed code,
  no reflection/foreign writes and the accepted pending-client family remain
  necessary premises.

- **Selected Session/RAC exclusions.** Initial splitting and its timing
  cleanup have finished before registration returns. The only GNAT
  transformation-scheduling routes are initial splitting, further splitting
  and counterexample creation. The accepted Per_Check full-split state and
  CE-off branch exclude the latter two; initialization reload is before the
  cut, and interactive strategy/edit/replay routes are not selected successors.
  Driver's transformation loop does not invoke the Session timer separately.
  The RAC root is guarded by giant_step_rac, whose default and retained argv
  leave it false; the CE-off state independently excludes a CE reporting
  attempt. This excludes rac_prover and its additional driver work using
  source control, without assuming a solver cannot return a model.

- **Cut attachment and pending timing cleanup.** The four early cuts precede
  driver timing. Input_Is_Valid stops at Driver.apply's entry for
  inline_trivial; the previous counterexamples_dependent_intros cleanup has
  returned. Counting the entire intersecting preparation episode already
  covers that later cut. schedule_vcs is active at all five cuts, including
  the synchronous idle path to Input_Is_Valid. init/register_vcs cleanup is
  complete; it is not another suspended update. The add_timing/replace/resize
  bodies cannot synchronously call either cut entry, and the accepted runtime,
  signal and exit clients cannot reach them while preserving a resumable
  timing mutation. A source-path attachment is used here, not an invented
  captured native stack.

- **One finalizer attempt and the global budget.** Fun.protect's work trap
  ends at native `0x97eeee`, before its success-finalizer call at `0x97ef4a`.
  The failure-finalizer call at `0x97ef20` is already in the handler. The
  finalizer wrapper catches to wrap/reraise a finalizer exception; a failure
  while acquiring/restoring the backtrace escapes rather than retrying.
  Neither path restarts work or the finalizer. add_timing's Not_found
  trap ends at `0x55a37e` before pair construction and replacement. A consumed
  signal-origin Not_found can choose the zero default and one replacement;
  a replacement exception cannot repeat the insertion through that catch.
  The fixed driver lists have no repeated name within a list. Therefore D
  directive entries supply at most D updates, with at most three additional
  outer scopes: schedule_vcs, run_vcs and save_session. Signal saves call the
  untimed save helper. E already counts signal-enabled repeated-pair episodes;
  the single `e<=2` / `r<=3` budgets never renew at a timer, catch or exit.

- **Actual cells, publication order and no resize.** The imported initial
  attachment checks scalar size equal to actual cells, finite disjoint
  chains, unique keys, valid pairs, seed zero and a 64-slot array. Only
  replacement writes timing bindings; no client clears/removes/resets the
  table. Starting at Hashtbl.create 42, a published resize could only increase
  capacity, so the observed 64 slots exclude an earlier published rehash.
  No unfinished rehash is suspended at the cut. For the suffix, the found
  arm stores an equal-valued key and a valid pair without touching next.
  On a miss, native allocation at `0x983ec8` completely initializes the new
  cell before the head publication at `0x983f1a`; size increments afterward
  at `0x983f1f`. An interruption can expose the old or new valid chain and
  can leave size below actual cells, but cannot make it exceed them. No
  timing-writing callback can return between the miss and publication.
  An escaping signal unwinds that insertion before an outer timing cleanup
  can run, so no stale saved head is later resumed. Unique immutable keys
  imply at most one publication per new key, hence at most 26 actual cells
  and size at most 26. The resize test against 128 is unreachable. This
  closes the induction without assuming a partially completed rehash is valid.

- **Counters and key extents.** The 20 configured transformation names,
  three initial-only names and three outer names give exactly 26 possible
  key values, maximum length 59 and total distinct length 1,051. A fresh
  equal-valued string remains the same hash-table key. Every initial count
  is one; a driver key gets at most E additional updates and each outer
  key at most one. A default/reset or lost update can decrease accounting
  accuracy, but cannot exceed the E+1 bound. The maxima are far below the
  tagged-integer limit, so neither counter increments nor table-size/threshold
  arithmetic wrap. The initial Input_Is_Valid driver count is conservatively
  included as well as its entire active episode. No sign, finiteness or
  elapsed-time bound is inferred for the stored binary64 values.

- **Iteration entered during interruption.** Iter/fold retain the fixed
  array and save next before calling their callback; native bucket recursion
  uses backedges. Cleanup flips the sign or reraises without replaying a
  callback. An abandoned traversal flag remains in {64,-64} and cannot
  corrupt chains or trigger the impossible resize. A nested signal save is
  untimed; suspended outer Fun.protect cleanup cannot execute and then
  resume an iteration that exception transfer already discarded. The accepted
  Debug gate is cleared before its callback, so nested exits cannot start
  this hook again. Thus each traversal visits at most 26 distinct cells,
  and at most 26 timing-template callbacks start over the whole suffix.
  The hook can run before later outer cleanup, so this does not promise a
  complete final timing report or successful flush.

- **Named local allocation only.** The inspected combined native reservations
  match the listed work/finalizer closures, boxed duration, sum-plus-pair,
  insertion cell and Finally_raised wrapper. Concatenation uses the fixed
  prefix and configured name domain, at most a 72-byte string block for
  59 payload bytes. The largest listed individual request is therefore 72;
  the existing 64-slot array is not reallocated. This is not a complete call
  allocation bound. Backtraces, clocks, hash/compare, barriers, allocation/GC,
  pending services, timed work, formatter work and ambient stack stay outside it.

The accepted five-case values are:

| Case | E | D | Updates, D+3 | Uniform per-key count |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 194 | 2,590 | 2,593 | 195 |
| Put | 161 | 2,150 | 2,153 | 162 |
| First_Or_Default | 98 | 1,310 | 1,313 | 99 |
| Is_Message | 11 | 150 | 153 | 12 |
| Input_Is_Valid | 5 | 70 | 73 | 6 |

The proposed direct format-interface use is valid under that interface's
normal numeric/locale service premises. Its per-row data allowance is
`name_bytes+348`; the growth result gives at most 26 distinct visited keys
whose lengths sum to at most 1,051. Therefore the timing templates supply
at most **`1051 + 26*348 = 10099` data bytes**, with at most **26 explicit
newline requests**. This deliberately retains the earlier conservative
20-byte integer allowance. It excludes formatter-generated indentation,
prequeued output, output-wrapper/callback work and actual newline emission
unless the corresponding default-callback premise is supplied. It is neither
total output nor a complete exit-capacity theorem. No format check was rerun
to establish this arithmetic composition.

The focused growth checker ran **once**, in read-only comparison mode:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-exit-timing-growth-20261020/check.py
```

It passed the pinned inputs/census, exact output/manifest comparison,
34 native bodies / 6,942 instruction bytes, source controls and five-case
arithmetic. It reported 2.10445316500045 seconds. Git status remained clean
afterward. The script binds witnesses and arithmetic; writer completeness,
trap attachment and mutation/traversal induction remain inspected reasoning
under the behavior premises, not machine-proved native or OCaml refinement.

Complete timing-runtime, exit and save capacity remain false. Oracle,
admission, production code and tools are unchanged. No native target execution,
new capture, disassembly, source fetch, solver/Lean run, predecessor replay or
duplicate successful check occurred. No GitHub or CLI memory write was made.
The child harness goal was null; no goal status changed.
