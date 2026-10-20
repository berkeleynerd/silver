# Parallel preparation state: origins, interruption windows and launch guard

2026-10-20 UTC, R55, #119 / #153.

The remaining mutable-state premise in [R54](retained-why-parallel-symbol-exclusion.md)
cannot be derived for the default signal route merely from valid initial tables,
live raw keys and a finite number of callbacks. The installed weak hashcons code
can publish a candidate before advancing its tag counter, then reach an allocation
safe point. The installed ephemeron resize publishes an empty replacement table
before copying its entries. An exception escaping either interval can reach the
preparation handler and leave mutated state behind.

This packet attaches the cache owners, initial-family transfer and ordinary
successful-operation induction. It identifies the exact failure in an
unconditional interruption induction, and supplies a sufficient guarded
continuation interface. It does **not** establish that the current intended
launch satisfies that interface, exhibit a corrupt fixed-domain execution, or
close #119. A proposed Why-only inherited SIGINT mask has a source-level
preservation argument below; it has not been implemented or selected.

The [evidence packet](../evidence/retained-why-parallel-state-attachment-20261020/README.md)
contains a new projection of retained R53 bytes, 44 source excerpts and six
installed native bodies. No target, solver, old capture reader or predecessor
checker ran. Two target-free GDB queries inspected the pinned ELF as data.

## State owners after registration

The imported registration interface is the fixed fresh Per_Check, CE-off,
non-replay session, selected three drivers, external server, one OCaml worker,
and immutable raw task forest. J counts external prover capacity; it does not
make the OCaml preparation functions concurrently execute. Arbitrary selected
owner order and failed preparations remain allowed. A warning driver outside
that three-driver family requires its own attachment.

| State | Creation, keys and permitted writers | Fact usable by the induction |
| --- | --- | --- |
| `Driver.update_task` | Private `Hint` maps `drv_tag` to a `Trans.store` closure. A missing driver entry creates that closure; its Wtask memo keys the pre-goal context. | Each actual driver owns its update function. R54's empty `drv_thuse` and derived metadata preserve logical declarations. Valid tag/key behavior is required; a hit is not justified by a matching driver name. |
| CE declaration memo | Module-level `Introduction.remove_unused_from_context = Trans.decl remove_unused_in_decl None`; `Trans.store_decl` creates one `Wdecl.memoize 63`. `Weakhtbl.memoize` is its only table writer. | All CVC5/Alt-Ergo CE calls share this closure. A mapped non-goal result is installed after the mapper returns. Goals bypass this memo. No typed caller obtains the table, clears it or removes a binding. |
| CE fold memo | The same `Trans.decl` creates one `Trans.fold` Wtask table. It records each non-goal input task head's complete output prefix after `fn` returns. | Its values are a second source of strong roots for CE declaration results. This root cannot be omitted when evaluating loss of the per-declaration memo. |
| Transformation stores and metadata/environment memos | `Trans.store`, `on_meta_tds`, `on_theory_tds`, and environment registration create private tables whose keys are the respective tagged immutable objects. | A valid hit returns a previous completed producer result; it is covered by that producer's invariant. The registry and live owner closures keep selected transformation closures reachable. |
| `Decl.Hsdecl`, `Theory`/task/type hashcons and attribute interning | Module-local weak tables and counters; successful hashcons operations publish/return matching representatives. Goal declarations use `Hsdecl.unique`. | Strict equality preserves R54's visible-symbol predicate. Unique tags, correct hashes and intact weak-table state must be established separately from logical equality. |
| Epsilon canonical caches | Private Hls/Hty tables; missing entries construct fresh closure symbols and axioms. A polymorphic identity entry is also created at module initialization. | Initialization is not assumed empty. All values originate at the displayed fresh constructors, not a lookup of an arbitrary residual marker. Valid keying and identifier freshness preserve that origin. |
| Introduction's separate Hsdecl and Wdecl queues | The separate name/attribute/location/formula equality and its corresponding queues. | R54's `{introduced}` versus empty/`{useraxiom}` distinction excludes residual heads, including older queue values. No new whole-table capture is required for that exclusion. |

`Trans.register_transform` stores the function; it does not apply it. The
selected registration transform is `split_goal_wp_conj`, not CE. The other
textual application of `remove_unused_from_context` is the reflection route,
outside the selected program. The direct registry name is also unselected.
Thus the CE declaration and fold memos start empty on this source route. This
is an origin argument, **not an observed empty native cache**. The imported
startup/dispatch interface must exclude additional transform applications.

`Weakhtbl.Make` deliberately compares **tags**, not physical keys. Consequently
immutability or raw-graph isomorphism alone cannot prove cache validity. Distinct
tags, compatible key/hash construction and preserved table mutations are part
of the state relation. `Ident.id_register` increments before constructing its
result; an abandoned allocation can waste an identifier but does not reuse that
increment. `Hashcons.hashcons` has the different order examined below. A final
no-wrap proof must apply this continuation argument only up to the first invalid
counter state, then discharge the relevant counter bounds. This packet does not
assume that final arithmetic theorem is already complete.

## Initial representative family without equating cuts

R53 joins complete immutable raw graphs and metadata, but deliberately does not
capture the complete new Hsdecl table. The companion R55 logging-prefix work
supplies the stronger relation needed here: the same pre-registration Why3
constructor trace, modulo the source path/address renaming, for the old and
actual J12 prefixes. It checks actual input/configuration roles and the absence
of protected collection/escaping interruption; raw-graph equality alone is not
substituted for that trace relation.

This matters because `split_goal_wp_conj` calls
`Gnat_rewrite.elim_to_of_array`, whose mapper reconstructs every Dprop under its
existing prsymbol. The registration table cannot simply be declared to contain
only the final raw declarations because splitting operates on goals elsewhere.
The source trace must include this context rewrite and all earlier constructors.

For Put_Line, Put, First and Is_Message the old complete R51 table projection
was at registration. Under the companion trace relation, its same-key family
transfers, including any existing representatives, tags and equality decisions.
The four projections contain only each context's raw object under each axiom
key. This transfers the **projected family**, not all unobserved mutable tables.

Input's old projection was after its first CE call. The correct relation is a
subset. Throughout that old protected interval there was no collection or
escaping signal/stack fault, and the selected operations completed normally.
`Hashcons.Make` exposes no removal/clear operation; its weak bucket growth,
shrink and resize preserve each occupied entry under these conditions.
Without collection, a previously occupied weak slot cannot become empty merely
because its object ceased to have another strong root. Thus every same-key
object selectable at the old registration prefix is among the **complete later
projection**: 61 raw objects plus three compatible additional objects. The
accepted R51 family already retains those stored representatives and their
formula graphs. This overapproximation does not need to assert when each of
the three objects was created. Transferring the pre-registration trace to R53
therefore transports a finite initial envelope without calling the later table
the registration table, subtracting an already-completed CE call from a fresh
run, or inventing an address map for uncaptured mutable tables.

This subset lemma is conditional on the companion trace relation and the old
successful no-collection interval. A general unobserved startup with different
callbacks, collection history, files or transforms is not covered.

## Successful-operation induction and its exact boundary

Assume the initial family above, valid keys/counters, the fixed producer/driver
owners, and successful table-mutation semantics for every prefix that continues.
For any raw axiom key before its first successful CE installation:

1. R52's 660 live raw representatives stay rooted by the immutable raw session
   tasks. Two additional keys have the one-term `Ttrue` stored envelope.
2. For the thirteen residual keys, R54 excludes every Z3 candidate by a visible
   physical marker. CVC5/Alt-Ergo cannot reach their downstream transforms until
   the complete CE prefix has returned; earlier partial CE calls produce only
   the modeled raw-key family. Fixed library resolution creates fresh heads
   or reuses already covered declarations. Driver metadata update creates no
   same-key logical formula.
3. Completed CE declaration memo entries remain reachable through their live
   raw key and live closure; completed fold prefixes provide additional roots.
   A false `Not_found` from an allowed lookup can initiate recomputation, but
   leaves the old binding in place until replacement. Successful recomputation
   therefore selects the live family representative or the same candidate.
4. Every completed non-CE memo entry has the corresponding earlier producer
   result as its value. Every strict-equal weak return preserves the producer
   predicate. These observations cover constructor insertions before a later
   validation, task addition, printing or preparation failure.

This induction needs no CVC5-first schedule and grants no separate escape budget
to a stage. Its boundary is **mutation**, not simply whether a whole preparation
succeeds. The following installed windows show why an arbitrary escaping save
cannot be included merely by adding two callback charges.

## Two installed interruption windows

### Published hashcons object before counter advancement

`Hashcons.hashcons` first assigns `next_tag`, then calls `WH.merge`, and advances
the counter only when that call returns its candidate. The retained installed
body calls the tag function at `0x553e0e`, calls merge at `0x553e2b`, and performs
the tagged increment at `0x553e42`. There is no rollback handler.

In `Weak.add_aux`, growing a full bucket publishes its new weak bucket and hash
array at `weak.ml:250–251`. If the growth crosses `t.limit`, it then runs bucket
shrink tests; it may subsequently resize the whole table. The installed
`Weak.loop_770` publishes those two arrays through `caml_modify` at `0x985af9`
and `0x985b36`. Later paths include allocating weak buckets, `Array.sub` at
`0x985df6`, and `caml_call_gc` slow paths. These are actual instructions after
publication and before merge returns. The source predicate for entering the
shrink path is a full bucket with `sz <= t.limit < newsz`; the later whole-table
resize has its own oversize predicate.

The selected three-test loop also has a loop-back pending-action poll at
`0x985ebc–0x985ec5`, with its slow call at `0x985f7b`. Once the growth predicate
enters that loop, this window does not require an actual bucket shrink or the
generic float-array branches present elsewhere in the compiled function.

If one of those operations unwinds after publication, the inserted object can
remain selectable with tag n while `next_tag` is still n. An ordinary later
strict-equal hit can return that older object without incrementing the counter;
a different successful insertion can then also receive n. Both objects can be
live, and tag-only Wdecl key equality would conflate them. This is a concrete
source/native **failure schema**. It requires the growth predicate, a continuing
exception and recovery before weak collection removes the abandoned object.
This packet does not establish that a selected fixed preparation necessarily
reaches all those conditions or report an observed duplicate tag. Conversely,
valid initial tags and a small callback count do not exclude them.

### Ephemeron publication before copying

`Ephemeron.resize` sets `h.data <- ndata` while ndata is empty, then constructs
its recursive copier and copies the old buckets (`ephemeron.ml:195–211`). The
installed body publishes at `0x99fa12` and immediately attempts a six-word
closure allocation at `0x99fa17`, whose slow edge calls `caml_call_gc` at
`0x99fadd`. Further `Cons` allocations occur while copying. An exception at
the first slow edge leaves an empty current array and the old size; later
edges can leave a partial array. The unwound local old array is not a permanent
table root. A raw key remaining live does not make its removed binding live.

This resize is relevant to the fixed inputs. The new projection reads only
R53's retained task chains, metadata and graph blocks and verifies:

| Domain | Distinct non-goal raw declarations / d_tags | First full-walk Wdecl resize |
| --- | ---: | ---: |
| Put_Line | 573 | insertion 129 |
| Put | 573 | insertion 129 |
| First | 301 | insertion 129 |
| Is_Message | 205 | insertion 129 |
| Input | 243 | insertion 129 |

`Wdecl.memoize 63` creates 64 buckets and grows after size exceeds 128.
Starting empty, each raw context declaration is visited and memoized even if
its output is unchanged or dropped. Raw keys remain live. Therefore a first
uninterrupted full CE walk reaches that resize in every domain, under the valid
tag/table relation. Earlier failures can prevent reaching it; the table does
not claim a successful full walk was newly run.

Loss of this one memo is **not a whole-family counterexample**. Trans.fold's
completed Wtask values can retain the previous declaration results, and its
active accumulator can do so until unwinding. Conversely, those roots need
their own interruption argument; that Wtask table uses the same ephemeron
implementation. A combined proof could exploit their redundancy, but cannot
replace both obligations by the incorrect claim that either table always keeps
all live-key entries. This packet leaves combined unmasked failure recovery open.

Both windows also admit ordinary allocation/stack/capacity exceptions.
`controller_itp.ml:528–534` catches preparation failures and reports
InternalFailure; the queued parallel owners can still be processed. SIGINT
masking alone does not exclude those ordinary failures. An exception inside
weak equality **before** insertion is different: it aborts that merge without
publishing the new candidate. Nor does a completed merge have a hypothetical
arbitrary OCaml callback inserted between its return and the displayed
straight-line counter increment.

## Sufficient continuation guard and the Why-only mask alternative

A sufficient guard for the successful-operation induction is:

- The fixed typed/source/capability boundary and one OCaml worker continue;
  keys, hashes, identifier/other tag counters and container-size arithmetic
  remain valid up to the first invalid-state proof cut.
- Allocation, stack and array/weak-bucket capacity services succeed throughout
  mutations that can leave published state. A terminal process failure is not
  resumed as a preparation. Ordinary semantic failures outside those mutation
  intervals remain allowed.
- No asynchronous callback can unwind a published mutation. The existing
  pending-client ownership excludes application finalizers, alarms, Memprof,
  arbitrary native hooks and other OCaml workers. SIGVTALRM's one-worker yield
  returns without another application callback. The remaining save callback
  can be excluded by the specific inherited-mask configuration below, or must
  receive a separate successful-save/terminal-outcome proof.

These are explicit sufficient conditions, not new verified properties of the
current launch. Resource success and size/counter arithmetic cannot be inferred
from blocking SIGINT or from a source hash.

The previously documented [launch alternative](retained-why-callback-launch.md#decidable-launch-alternative-and-its-integration-boundary)
uses `POSIX_SPAWN_SETSIGMASK` **before exec of gnatwhy3 only**, with SIGINT in an
explicit mask M and SIGTERM outside M. The launcher must enumerate every other
required bit; blindly inheriting an unknown mask is insufficient. It must also
establish the default SIGTERM disposition, for example with
`POSIX_SPAWN_SETSIGDEF` for SIGTERM: an unblocked signal with inherited `SIG_IGN`
would not provide termination. Selected Linux Why code changes SIGTERM to ignore
only in the excluded SIGINT handler; Thread's preemption signal is SIGVTALRM.
Spawn-attribute and spawn failures must reject the launch. These are prospective
configuration requirements, not observations of the current process. The
source-level mask closure is now:

| Selected mask-related operation | Why SIGINT stays blocked |
| --- | --- |
| `caml_set_signal_action` on Linux | Uses `sigaction`, not an unmasking operation. GNAT installing its handler does not undo the inherited mask. |
| Pending signal dispatch | Reads the current mask and skips blocked signals even if their OCaml pending bit is already set. A dispatched other signal adds its own blocked bit and restores the old mask containing SIGINT. |
| Thread initialization/tick | The mask hook becomes `pthread_sigmask`; the tick worker blocks all signals and records SIGVTALRM. It does not clear SIGINT in the OCaml worker's mask. |
| One-worker SIGVTALRM handler | `preempt` calls `yield`; with no waiting worker, the installed source returns unit at its first guard. It cannot run another Why producer or clear the mask. |
| Explicit Unix/Thread mask APIs | `Unix.sigprocmask`, `Unix.sigsuspend` and `Thread.sigmask` could clear the bit, but have no selected Why client under the inherited fixed-code/capability boundary. Merely linking their entry points does not invoke them. |
| Platform trap code | The visible `SIG_UNBLOCK` in `signals_nat.c` is the non-Linux-x86_64 Power/s390 Rhapsody SIGTRAP branch, not a selected SIGINT writer. |

This composes the inspected source with the accepted native hook/callback owner
closure; it is not a full new foreign-code census. OS mask-service success and
absence of a newly introduced mask-changing client remain explicit. Under
this guard no SIGINT save callback begins. This is a zero subcase of the same
**one process-wide two-callback / three-save / e <= 2** accounting rule, not a
fresh allowance or a reason to reset any earlier budget. Ordinary ending save
and exit hooks still run on normal completion.

Cancellation must remain supervisor-visible and non-successful. A supervisor
must request Why termination through default/unblocked SIGTERM, with an
unconditional SIGKILL fallback and reaping policy. It must separately own the
external server and clean up its separate solver process groups. The existing
single-client disconnect/shutdown paths attempt group-directed SIGKILL; one
client's EOF must not be assumed to shut down a shared server. There is also a
specific creation race: `create_process` returns the forked PID in the parent
before the child is guaranteed to execute `setpgid(0,0)`
(`server-unix.c:335–355`), while `os_kill` calls `kill(-pid,SIGKILL)` without
checking its return (`proc.c:23–30`). Cancellation before group creation can
therefore miss that child. A complete supervisor must establish process and
group ownership, a fallback that covers this interval, and reaping; the stock
disconnect/group-kill path alone is insufficient evidence. No graceful
session-save outcome is promised for forced termination. Masking an
internal-server parent would be a different design. No current launch mask or
disposition is observed or changed by this packet.

## Result and next obligation

The initial-family argument can now use the companion constructor-prefix
transfer, including Input's later-table overapproximation. The cache/producer
induction covers arbitrary first-fill order and insertion prefixes of failed
calls **under the stated mutation guard**. The default unmasked continuation
does not yet discharge that guard. The next decision is concrete: complete the
unchanged-tool supervisor/mask/resource interface, or prove combined table/tag
recovery for the displayed continuing-failure windows. A further ordinary
registration snapshot would not settle those continuation windows.

No new Ident charge is introduced by this state analysis. R52's prospective
309,197 direct prefix charge and R54's 675-key family remain conditional on
their applicable interfaces; neither becomes a whole-process capacity result.
Source correspondence, complete resource/counter bounds and production admission
remain separate obligations. Selected author settings: GPT-6 Astra / Extra High;
runtime confirmation and token/cost telemetry were unavailable.
