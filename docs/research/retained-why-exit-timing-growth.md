# Retained exit timing-table growth

2026-10-20 UTC, #119 / #153, Linux x86_64. The whole post-cut selected
continuation has at most **2,593 / 2,153 / 1,313 / 153 / 73 timing-update
attempts**, in Put_Line, Put, First_Or_Default, Is_Message, Input_Is_Valid order.
The proposed `15E+3` bound is valid; the already accepted directive counts
give these smaller bounds. Every timing table keeps its 64-slot backing array,
has at most **26 cells**, and supplies keys of at most **59 bytes**. This closes
the timing-table control, key, counter and traversal-input obligations under
the named source/native/state premises. It does not close formatter output,
runtime services, exit capacity or complete save capacity.

The [packet](../evidence/retained-why-exit-timing-growth-20261020/README.md)
binds the accepted inputs, a complete lexical census of the retained Why3
ML/interface source family, source excerpts, and selected complete native
bodies from the existing disassembly to the accepted ELF. The source control
and mutation proof below is reviewed reasoning; hashes and arithmetic are not
a compiler refinement proof. No target, capture, disassembler, source fetch or
predecessor checker is run.

## Scope and imported premises

The base is `14ba1434a8`. Reuse the five fresh PIDs
17310 / 17514 / 17631 / 17704 / 17869 and their accepted
[initial values](retained-why-exit-initial-values.md),
[source-prefix/callback attachment](retained-why-path-initial-state.md),
[interrupted episode proof](retained-why-path-writer-capacity.md),
[selected driver envelope](retained-producer-driver-envelope.md), and
[ordinary-ending control](retained-why-ordinary-ending-control.md).
The applicable behavior relation remains Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml
`8eb41f72ded84df884c3671734c947f612091f84`, and the accepted Linux executable
with SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.

The continuation retains the fresh, serial, automatic Per_Check configuration,
CE off, no replay/manual/debug-save route, fixed drivers, preserved selected
attempt metadata and the accepted immutable-value/runtime effect relation.
The source-prefix attachment excludes arbitrary reflection, additional
application workers, application GC/finalizer callbacks and foreign writes to
this table. The selected signal save either terminates or raises; it does not
return to its interrupted operation. Returning Thread/runtime clients do not
write Why timing data. Existing runtime effects are imported; this packet adds
no numerical service or physical-resource theorem.

There is **one global `e<=2` escaping signal-save budget and one global `r<=3`
save-entry budget per process**. Neither is restarted at an episode, timer,
catch, ordinary ending, hook or traversal. E already includes repeated-pair
episodes enabled by consumed signal-origin exceptions. Input_Is_Valid's E
also includes the entire preparation intersecting its later cut.

## Every post-cut timing owner

The retained source census has exactly the following timing API clients.
It also searches bare `Stats` references, so an ordinary source alias/open of
that module cannot be silently ignored. Public `Debug.Stats.get_timings`
does expose the mutable table; interface privacy is not used as a substitute
for inspecting its client.

| Owner | Selected post-cut charge or exclusion |
| --- | --- |
| `Driver.prepare_task`, `driver.ml:371–391` | Each episode folds its fixed list once. Each entered `apply` has one `record_timing`, including work that raises or never returns. Lists have 15 / 13 / 12 entries and no repeated name within a list. |
| `gnat_main.ml:346–347` | One `schedule_vcs` scope, including its pending finalizer. It is already active at all five cuts: the first four stop at its `Gnat_checks.iter`, and the later first-driver entry is reached synchronously through `Gnat_scheduler.idle`. |
| `gnat_main.ml:272–274` | At most one `run_vcs` and one `save_session` scope at ordinary ending. The scheduler's `Exit` handler invokes ending outside its protected loop; a failure cannot restart it. |
| `gnat_main.ml:332,340` | `init` and `register_vcs` have returned before the selected scheduling cuts. Their finalizers are complete. Neither is charged as a new pending scope. |
| `Session_itp.apply_trans_to_goal`, `session_itp.ml:1573–1586` | Initial `split_goal_wp_conj` and its timer have returned before registration returns. The three GNAT transformation scheduling routes are initial splitting, further splitting, and CE creation (`gnat_checks.ml:537–595,734–750`). Initial splitting is past; the accepted Per_Check full-split and CE-off result excludes the other two. Controller strategy/edit/replay and session merge/reload routes are not selected successors; initialization reload is before the cut. |
| `Rac.Why.check_term_dispatch`, `rac.ml:390–420` | Its `rac_prover` update and extra driver entries are excluded. In GNAT the RAC root is `maybe_giant_step_rac`; `giant_step_rac` defaults false and the exact retained argv does not enable it (`gnat_config.ml:43,78–80,525`). Independently, the accepted CE-off check state yields no CE attempt for the reporting caller (`gnat_main.ml:213–231`). A false source guard is used, not an assumed absence of solver models. |
| `Gnat_report.get_timings`, `gnat_report.ml:216–219` | The sole table-alias client folds keys and values into a list. Its callback constructs pairs/list cells and never changes keys, values, buckets or size. `Hashtbl.fold` itself flips the traversal flag; it is therefore not described as literally mutation-free. |

The census also includes Debug's own definition, calls and public signature.
There is no additional selected timing writer in a transformation, formatter,
exception printer or signal-save callback. In particular,
`save_session_and_exit` calls **untimed** `C.save_session c` and then `exit`
(`gnat_main.ml:298–309`): multiplying the two ordinary-ending timers by r
would charge the wrong source scopes.

At the first four cuts no driver timer is active. At the Input_Is_Valid cut,
the earlier `counterexamples_dependent_intros` scope has completed, and the
stop is the first instruction of `Driver.apply` for `inline_trivial`, before
that directive's timer. Counting all 15 entries of the intersecting episode
already covers any suspended or remaining preparation work. No initial
`Stats.add_timing`, `Hashtbl.replace`, insertion or resize frame can be below
these cuts: those bodies do not invoke preparation/scheduling callbacks, and
the accepted pending-client family cannot enter either cut from them. This
source call-path conclusion does not pretend that a native stack was captured.

## Finalizers, catches and update arithmetic

`Debug.record_timing` reads the start clock and constructs one `Fun.protect`.
Once its work is entered, either work returns and the finalizer is attempted
once, or work raises and the same finalizer is attempted once before rethrow.
Failure before work, before the finalizer or within its end-clock call may
prevent `add_timing`. Failure of the finalizer becomes `Finally_raised`; it
does not retry either work or the finalizer.

This depends on the precise trap boundary. The retained native
`Fun.protect_317` calls work at `0x97eee7`, removes its trap at `0x97eeee`, and
calls the success finalizer at `0x97ef4a`; the exception branch calls it at
`0x97ef20`, after transfer to the handler. `finally_no_exn_321` has its own
catch at `0x97efa0`, wrapping and reraising rather than returning to either
finalizer callsite. Thus a signal or allocation failure during a finalizer
does not activate a second attempt through the work-exception arm.

`Stats.add_timing` catches `Not_found` only around `Hashtbl.find`. Its native
trap is removed at `0x55a37e`, before the new pair and `Hashtbl.replace`.
A signal-origin `Not_found` consumed there can reset the old value to `(0.,0)`;
the continuation performs just one replacement. An exception in replacement
does not select that default and repeat the insertion. The controller's
receiving catch reports InternalFailure and does not retry the directive;
the accepted E proof already charges all later repeated-pair episodes.
Outer main/ending/exit paths do not restart completed timing scopes.

Let `D` be the accepted total configured-directive bound. The proof gives

```
timing-update attempts U <= D + 3 <= 15E + 3,
D <= 40G + 30, E <= 3G + 2.
```

This is a bound for every executed prefix, including abandoned operations.
An infinite poll or nonreturning service adds no timing update by itself.

| Case | E | D | Candidate `15E+3` | Exported `D+3` | Uniform per-key count upper |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 194 | 2,590 | 2,913 | 2,593 | 195 |
| Put | 161 | 2,150 | 2,418 | 2,153 | 162 |
| First_Or_Default | 98 | 1,310 | 1,473 | 1,313 | 99 |
| Is_Message | 11 | 150 | 168 | 153 | 12 |
| Input_Is_Valid | 5 | 70 | 78 | 73 | 6 |

Every configured name appears at most once per episode. Each outer key is
updated at most once; init/register/split retain count one. Therefore each
driver key's counter is at most E plus its initial count (zero or one).
The looser uniform E+1 column is safe in every case. Initially every count is
one; the only assigned value is a previous count plus one, or one after a
miss/default. Interrupted reads or lost updates can reduce accounting accuracy,
but cannot increase this bound. Counts remain positive tagged integers and
need at most 3 / 3 / 2 / 2 / 1 decimal digits. The sum of visible counts is at
most the initial cell count plus U. These are mathematical accounting bounds,
not counters added to the program.

## Key domain and interrupted table state

The three fixed driver lists have 20 distinct transformation names. Add the
three initial-only keys (`init`, `register_vcs`, `transformations.split_goal_wp_conj`)
and the three outer keys (`schedule_vcs`, `run_vcs`, `save_session`). The initial
Input_Is_Valid counterexample-introduction key is already in the driver union.
The exact 26-key set is retained in `result.json`. Its longest key is
`gnatwhy3.transformations.eliminate_definition_conditionally` (59 bytes); the
sum of all distinct key lengths is **1,051 bytes**. No source client mutates
these strings. A new physical string for an equal name is the same Hashtbl key.

The initial packet validates finite, disjoint cell chains, unique names, valid
pairs and count/float representations, with 3 / 3 / 3 / 3 / 4 cells, seed zero,
and both current and initial backing size 64. The census supplies the missing
history restriction: only replacement writes timing bindings; neither Debug
nor the exported alias client removes, clears or resets this table. Starting
from `Hashtbl.create 42`, every published resize would strictly increase its
64-slot backing and no selected writer can shrink it. Thus the observed
64-slot array excludes an earlier published rehash. No resize is suspended
at the cut as established above. Initial key placement therefore comes from
ordinary source insertion with the unchanged seed/array size, rather than
an unproved assumption that a partially rehashed table was repaired.

For the suffix, use induction on actual replacement prefixes:

1. `replace_bucket` scans a finite chain and compares immutable strings. On
   equality it writes an equal-valued key and a valid new pair. It never
   changes `next`; either the old or new data is a valid pair.
2. On a true miss, `replace` first allocates and completely initializes
   `Cons {key; data; next=l}`, then publishes it as the bucket head, then
   increments `size`. Native allocation is at `0x983ec8`, publication calls
   the accepted write barrier at `0x983f1a`, and size increments at
   `0x983f1f`. A failed allocation does not increment size. A failure after
   publication cannot make size exceed the actual cell count.
3. There is no timing-writing callback between the miss test and publication.
   Signal saves and their exit iteration only read timing bindings. An escaping
   signal abandons the interrupted replacement; no local replacement catch
   resumes an insertion with stale `l`. Returning runtime clients preserve the
   table. Thus an existing equal key is never duplicated or lost by insertion.
4. A new cell is published at most once for each new key. Hence cells and scalar
   size are at most 26. The resize condition is `size > 2*64`, which is false.
   This closes the induction without importing an in-place-rehash invariant.

Consequently the 64-slot backing, finite acyclic chains and valid key/pair data
are preserved. There are at most 23 / 23 / 23 / 23 / 22 new published cells.
Allocation attempts for unpublished cells are a different quantity: at most U,
since a failed insertion may be attempted by a later timing scope. Scalar size
lies between its initial value and 26 even if a failed prefix leaves an
undercount. All indices, the resize threshold and this size interval fit native
integers. This argument does not rely on size/cell equality after every machine
instruction or on rollback after failure.

This is the required distinction between an **interrupted mutation** and an
**iteration entered from that interruption**. In this selected table, the
interrupted operation can expose an old or new valid binding, but cannot
expose a partially copied resize or a cycle. The later at-exit traversal is
therefore bounded; its validity is not inferred merely from the at-exit gate.

## Iteration and local individual requests

`Hashtbl.iter` and `fold` retain the 64-slot array, traverse each chain once,
and save `next` before their callback (`hashtbl.ml:154–172,205–228`). Their
native bucket recursions are tail loops. Traversal flips only the sign of
`initial_size`, which remains in `{64,-64}`; its cleanup either returns or
reraises without replaying a callback. Even an abandoned negative traversal
flag cannot corrupt chains or create a resize. The only alias client's fold
callback creates a separate `(key,value)` list, not a mutable table handle.

Each traversal therefore enters at most 26 key callbacks. Under the imported
empty registered-statistics list and once-only Debug hook gate, at most 26
timing callbacks start during that hook over the whole suffix. The total key
bytes supplied by a full timing-table traversal are at most 1,051. A nested
exit may happen before suspended outer finalizers execute; the snapshot can
omit those future updates. No claim of a final complete timing report or
successful flush follows.

The following are **named local instrumentation requests**, including object
headers, under the accepted 64-bit representation. They exclude the timed
work and runtime/formatter services:

| Request family | Individual bytes |
| --- | ---: |
| Concatenated timing name | At most 59 payload bytes; 72-byte string block |
| Driver's work closure | 40 |
| `record_timing` start float and finally closure (one native reservation) | 56 |
| `Fun.protect` finalizer-wrapper closure | 32 |
| End-minus-start boxed float | 16 |
| New sum float and `(time,count)` pair (one native reservation) | 40 |
| New Hashtbl cell | 32 |
| `Finally_raised` wrapper record, if reached | 24 |

The largest listed request is **72 bytes**. The native bodies retain the
combined reservations; splitting them into smaller object sizes would not
describe the actual individual reservation. `(^)` requests exactly the
sum of the two fixed-domain string lengths, then blits into that fresh block;
no name suffix search or unbounded width is involved. The existing 64-slot
array is 520 represented bytes including its header and is never reallocated
by this suffix. These facts are not a complete timing-call allocation bound:
notably raw-backtrace acquisition on an exceptional path, clock/hash/compare,
write-barrier, allocation/GC/pending work and all timed work retain their own
owners. No bound for those services is manufactured here.

Stored time values retain binary64 representation. No bound on elapsed time,
sign, finiteness or magnitude is inferred from initial samples or these update
counts. Float conversion and output, the global Debug Buffer/Format graph,
standard Format and terminal channel hooks, caller/ambient stack and physical
sufficiency remain separate. Their complete-capacity flags remain false.

The selected author setting is GPT-6 Astra / Extra High; runtime confirmation
and token/cost telemetry are unavailable. The packet records the one focused
freeze-check duration. Independent review and integration remain parent-owned;
no GitHub or CLI-memory update is claimed by this lane.
