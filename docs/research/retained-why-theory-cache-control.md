# Selected theory-cache control through the first resize

2026-10-20 UTC, Linux x86_64, research #119 / #153, Round 30; exact base
`0937ca4a44d012893c7c95517e990f019d1489e6`.

**The selected callback control excludes a later file-status repair traversal
after an abandoned first theory-cache resize.** The protected `InternalFailure`
case needs the fresh leaf statuses and serial scheduling ownership, not merely
the fact that its GNAT callback schedules nothing. Under the existing selected
source/native, representation and continued-signal premises, this attaches the
[first-resize theorem](retained-why-theory-cache-resize.md) to all five captured
continuations. It does not establish successful saving, runtime/service capacity
or complete #119/#153 assurance.

The [packet](../evidence/retained-why-theory-cache-control-20261020/README.md)
contains exact retained source excerpts, the fresh status attachment, a finite
challenge model and the round record. No native execution, capture, source
fetch, disassembly, solver/proof or old checker replay was performed. The
Round 29 generic shared-tail countermodels remain valid; their hypothetical
later repair pass is excluded here by this selected control argument.

## Exact entry and governing conditions

The fresh [status packet](../evidence/retained-why-status-entry-20261020/README.md),
frozen at `11f37947321d59d870039ce7b6743621245b2eb7`, decodes the actual retained
blocks and separately records observed cache bindings, source defaults, attempt
results and recomputed statuses. Our checker consumes that exact result. It
does not infer observed bindings from a successful default lookup.

All cases have root goal 0, one nondetached transformation 0, and nondetached
leaves numbered consecutively from 1. The root has no proof attempt. Each leaf
has no child transformation and has an actual raw task. The theory has only
root 0; other theories are empty. There is one nondetached file. Theory/file
caches are empty; transformation 0 is cached false; root status defaults false.

| Case | Leaves | Initially true leaves, all Trivial | Other initial selected attempts |
| --- | ---: | ---: | --- |
| Put_Line | 64 | 14 | none |
| Put | 53 | 12 | none |
| First_Or_Default | 32 | 10 | none |
| Is_Message | 3 | 1 | none |
| Input_Is_Valid | 4 | 3 | cvc5 attempt 3 on leaf 3, result None |

Every initially true leaf has a nonobsolete `Some Valid` Trivial attempt and
true cached status. Every other leaf's cache/default is false and its attempt
truth is false. The first four cuts are after registration and before scheduling;
the retained scheduling/preparation guards have zero hits. The fifth cut is
the first cvc5 preparation, after its graft and Scheduled callback; its retained
driver-input task is exactly leaf 3's raw task. These are phase and entry facts,
not a full queue or GNAT check-map decode. Those maps are unobserved. The
candidate ownership argument below is source-derived from fresh registration
and the accepted selected route, rather than asserted as a raw observation.

Retain the accepted [driver route](retained-producer-driver-envelope.md): fresh
automatic serial Per_Check, CE off, no replay/manual/editor/reload/merge or
debug-save path, fixed initial split and selected prover keys. The registered
domain is a subset of the initial leaves; no later split/clone adds candidates.
Retain the [counter/control audit](retained-why-attempt-counter-continuation.md),
the accepted no-resize contracts for the other relevant session caches and
attempt tables, valid immutable IDs/tags/booleans, faithful source/native
behavior, one worker, and no unmodeled mutation. The source revision is Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`; the previous OCaml/native resize
witnesses retain their original scope and are not rerun here.

There is **one global budget `e<=2` of escaping signal-save exceptions** from
the selected cut through ordinary ending. A local catch that turns such an
exception into a default still consumes it. Neither a callback nor a save
renews this budget. Ordinary `Sys_error`, observer `Exit`, allocation failure,
or another nonsignal exception is not charged to `e`.

## Candidate and pending ownership

Call a leaf *pending* while its selected scheduling request is queued, being
built, or represented by an unfinished call. A failed build may also receive
the bounded repeated failure notification described below. Pending is a control
owner; it does not mean that every constructor or call completed successfully.

1. Main invokes the selected registration branch once, before scheduling
   (`gnat_main.ml:335–353`). `iter_subps` builds its list from `iter_main_goals`;
   the one file/one nonempty theory/one root projection gives root 0 once
   (`gnat_checks.ml:664–688,749–766`). `normal_handle_one_subp` calls
   `iter_leaf_goals` once after initial splitting (`gnat_main.ml:292–296`).
   The one transformation's distinct ordered subtasks are visited by one
   `List.iter`; its Not_found handler returns unit and drops the remainder,
   without retrying any leaf (`gnat_checks.ml:490–505`). Other escapes terminate
   registration rather than restart it. Thus a registered leaf has at most
   one `register_goal`/`add_to_check` call and one owning check, including a
   partially interrupted registration. `add_to_check` assigns it
   to that check's set (`gnat_main.ml:50–73`, `gnat_checks.ml:201–226`). Sets do
   not contain two occurrences of a leaf. The accepted route excludes later
   clone/CE/replay/registration insertion.
2. `next` chooses a candidate and removes it **before** returning it for
   scheduling (`gnat_checks.ml:272–281`). Its `Not_found` handler returns an
   empty list. An exception before/after the persistent-set reference write
   can drop a candidate or abort; it cannot both retain that candidate and
   return it for scheduling. No callback is run by these set operations.
3. Serial scheduling creates one selected request for the returned goal;
   `parallel>1` and manual branches are excluded (`:1038–1084`). Graft and queue
   insertion precede Scheduled, which precedes synchronous idle processing
   (`controller_itp.ml:641–652`, `gnat_scheduler.ml:9–11`). A partial constructor
   cannot restart scheduling after an unpublished increment, by the accepted
   constructor receiving-catch audit. A partial metadata lookup can change the
   chosen fallback/limits but cannot return two scheduling requests.
4. Timeout processing removes a finished call before invoking Done. A later
   duplicate result finds no call and is dropped; its `exception Not_found`
   arm covers only the lookup (`controller_itp.ml:450–490`). An exception in
   removal or Done's body cannot return through that arm. Selected blocking
   mode drops Running notifications as already established by the caller audit.
5. Only `register_result`'s **nonvalid** branch puts that same goal back into
   `to_be_scheduled` (`gnat_checks.ml:598–662`). A valid result never does so.
   `InternalFailure`, Interrupted and other non-Done GNAT notifications do not
   invoke this requeue path (`gnat_main.ml:94–120`). The nonvalid branch's Exit
   handler clears its scheduling set; it cannot create a duplicate owner.

Consequently a nontrivial leaf has at most one selected pending owner at a time.
A valid Done is the end of that leaf's selected scheduling, even when a caught
signal has made its cached Boolean false. Such a false cache does not itself
insert the leaf into the candidate set. Spurious `has_been_tried_by=false` can
retry a previously completed **nonvalid** pair; it cannot undo this removal of
a valid goal. This is the needed stronger fact beyond the old normal pair-count
envelope. It permits repeated nonvalid attempts and failed/abandoned prefixes.

Trivial is a distinct immutable prover key. Selected graft/reset never changes
its valid result (`gnat_checks.ml:237–261`, `session_itp.ml:645–675`). A registered
Trivial leaf is normally consumed by `schedule_goal`'s already-proved branch.
Before its **first** selected request, its cache is still true: no selected
callback for that leaf has yet run, and saving does not write this cache.
Thus a selected request for a Trivial leaf requires at least one prior or
current signal-origin `Not_found` in the `pn_proved` eligibility query
(`gnat_main.ml:131–152`). This exception is the first relevant budget charge.

## Leaf invariant and the two-escape barrier

Let `A_i` be actual leaf truth: whether any reachable attempt is nonobsolete
Valid. Let `P_i` be its stored status/default, `T` the transformation cache,
and `R` the root cache. Actual task/detachment data remain fixed.

The ownership argument gives these source invariants before any first file
traversal:

- For a nontrivial leaf, `A_i` starts false and can become true only through
  its terminal valid Done. Earlier selected attempts were nonvalid/None;
  that valid result is never reset by a later graft or overwritten by a
  second pending result. Hence `A_i` is monotone on this selected route.
- For a Trivial leaf, `A_i` is always true regardless of selected results.
- `P_i <= A_i`. `update_goal_node` on a leaf computes a disjunction of
  `not goal_is_detached parent && pa_ok attempt`. A signal-origin Not_found
  in `goal_is_detached` returns **true**, potentially suppressing a valid
  attempt; it cannot manufacture one. A false `pn_proved` comparison can
  trigger a redundant replacement, but the stored value is still that
  computed disjunction. Structural lookup failures otherwise abort; they do
  not produce a fabricated valid attempt (`session_itp.ml:300–375,788–859`).

This handles the subtle catch omitted by a false-lookup-only abstraction:
`goal_is_detached` can also make a parent `List.for_all` skip a false child.
The argument below counts where the exception was consumed; it does not assume
unconditional cache consistency or monotone cached booleans.

Every protected InternalFailure target is either a nontrivial pending/failing
leaf with `A_i=P_i=false`, or a Trivial leaf. The first case cannot cross its
leaf status comparison: both ordinary evaluation and any suppressed evaluation
are false, as is the real/default comparison. Failures may abort/repeat it but
do not create a parent update.

For a Trivial target, at least one escape was already consumed to schedule it.
With at most that one escape spent, its cache is still true and its leaf update
does not propagate. To propagate requires **another** escape, either:

- a false comparison that causes a redundant true replacement; or
- a suppressed true computation that stores false, followed by a later repair
  to true (possibly by idle's repeated failure callback).

No receiving service/resource exception substitutes for these Boolean defaults:
the catches return defaults only for Not_found; with valid represented session
lookups, nonsignal failures either abort that prefix or deliver another failure
notification. The selected notifier is `fun _ -> ()` (`gnat_checks.ml:990`).
Signals that escape a structural getter may be converted to BadID/assertion or
reach the idle catch; that also consumes an escape and creates no extra truth.

At most two escapes exist. After the leaf crosses this barrier, all remaining
parent reads in a continuing update are therefore faithful, or abort without
substituting a Boolean. A first file traversal cannot follow a false transition:
before any file traversal the theory cache is absent/default false or contains
the nonempty theory's default false. A true theory commit is needed. The
faithful propagation chain then requires

```
all P_i = true,  T = true,  R = true,  nonempty theory = true,
all A_i = true,  e = 2.
```

All `A_i=true` follows from `P_i<=A_i`. A previous abandoned theory commit
before calling the file does not invalidate this argument: it already required
the same faithful all-true chain and exhausted budget; a later leaf callback
cannot restart that chain. A source-generated observer Exit or Sys_error can
cause repeated InternalFailure without consuming a signal; the unchanged leaf
comparison still enforces the barrier.

The word **first** matters. Suppose the first escape schedules a Trivial leaf
and a second escape later suppresses its true attempt during InternalFailure.
If all other leaves became true before that suppression, the last nontrivial
Done already propagated the still-true Trivial cache and made the first file
traversal. A later false downgrade is possible, but the first resize either
completed with key preservation or escaped through that earlier Done's terminal
owner. If suppression precedes the last nontrivial completion, the Trivial
false cache prevents a first file traversal until its faithful repair. No
particular inter-goal completion order is assumed.

## Stable suffix and exceptional resize owners

At such a protected first file traversal, all nontrivial leaves have received
their valid Done and have no pending owner or candidate. Remaining Trivial
requests, if any, retain an immutable valid Trivial attempt. With no signal
escapes left, every later leaf update computes true and compares against true;
none reaches the transformation, root, theory, or file. Candidates for Trivial
leaves are consumed by the true eligibility branch. Other nonsignal exceptions
can abort or repeat these unchanged updates, not make their Boolean defaults
false. **No later `update_file_node` repair pass exists.**

This suffix remains stable if the first resize raises Out_of_memory after
publishing its new array. That exception is not counted as a third signal:
idle may receive it, but the all-true status barrier prevents another file
traversal. Resource/service failure is allowed to stop saving or prevent its
success; this theorem makes no success or resource-availability claim.

The other owners of first file growth are Scheduled or Done outside the
protected build/idle region. Their escaping exceptions reach terminal main or
Exit-to-ending without restarting scheduling, by the accepted counter/control
audit. `th_proved`'s fallback add is outside its own find catch. The theory-parent
Not_found handler invokes `Loc.errorm`, which **raises** Message/Located; it is
not a continuing handler (`session_itp.ml:752–757,813–828`, `loc.ml:302–306,338–341`).
An exception from the resize therefore cannot restart an empty-theory query
through that catch. Locally caught exceptions *before* a rehash may continue
the current query; their distinct/exceptional additions are already charged.

Saving itself queries only the sole nonempty theory. Before a first publication
that key is present once file growth has started, because theory replacement
precedes file propagation. A nested save cannot normally resize through a
missing empty theory. Any exceptional duplicate query is charged to the same
global budget; if the first resize occurs inside that save, its escaping
operation cannot resume the discarded resize frame. A protected file-growth
ancestor would already have spent both escapes and cannot receive that nested
signal. An unprotected ancestor has the terminal receiving control just stated.
Ordinary ending has no return to scheduling.

Thus if the first published resize completes, key preservation gives the
existing `Th+2<64` bound. If it is abandoned, its receiving continuation has
only save queries that can add to `th_state`; there is no later empty-theory
repair traversal. The accepted first-resize argument bounds its chains by
`2*N`, where `N<=Th+2` at first publication. At most `r<=3` reached saves add
one fresh head each, so size is at most `N+3` and visits at most `2*N+3`.
This excludes a second publication and the Round 29 shared-input cycle lane.

| Case | Capacity upper | Scalar size upper | Binding visits upper |
| --- | ---: | ---: | ---: |
| Put_Line | 32 | 51 | 99 |
| Put | 32 | 51 | 99 |
| First_Or_Default | 32 | 46 | 89 |
| Is_Message | 16 | 14 | 14 |
| Input_Is_Valid | 16 | 23 | 23 |

These are conservative whole-continuation theory-table bounds, conditional on
the named premises. They are not new physical allocation guarantees, output
byte bounds, evidence that a solver finishes, or successful serialization claims.

## Focused verification and limitations

The checker attaches all five exact status results and source excerpts, then
exhausts seven small abstractions (one to three leaves with varying Trivial
subsets, including an existing nontrivial pending call). It checks 938 reachable
states. All seven protected first-file states have exhausted the global budget
and all true leaf/parent statuses. Every subsequent cache update is stable.
The model admits repeated failure callbacks, nonvalid retries, true detachment
defaults, false lookup defaults, and protected prefix aborts from **nonsignal**
exceptions without increasing `e`. Its two-escape count is global.

A negative probe permits a completed Valid nontrivial goal to remain pending;
then a first protected file traversal is possible after only one escape. This
shows why candidate/pending ownership is an essential source obligation rather
than an optional model restriction. The model assumes that ownership rule; the
source audit above supplies it. Small finite enumeration does not prove the
unbounded-leaf source argument, native correspondence, or fresh queue/map data
that was not captured. Combined independent review remains lead-owned.
