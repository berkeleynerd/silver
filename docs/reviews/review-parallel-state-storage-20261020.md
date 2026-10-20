# R55 review: parallel state, logging startup and protocol storage

2026-10-20 UTC; independent bounded #119 / #153 review on Linux x86_64.
Selected reviewer model/effort: **GPT-6 Astra / Extra High**; runtime confirmation
and isolated token/cost telemetry unavailable. No subagents were used.

The review base is R54 integration
`6eedb6dea5786c5eea63d9372de89376b11e144b`. Work is isolated on
`review/parallel-state-storage-20261020`; only this report and its
[review packet](../evidence/retained-parallel-state-storage-review-20261020/README.md)
are reviewer-owned. R54 and predecessor evidence are reused without replay.

## Protocol storage: accepted within the stated interface

Reviewed author freeze `074ca7919dd3a9528b9fcd047c2e1e928585c854` and its
[research note](../research/retained-adapter-protocol-storage.md).
The focused checker passed 14 source excerpts, eight direct repository inputs
and all 1,636 selected ring-resize pointer positions. Observed subprocess time
was 0.129 s, with 0.089 s measured inside the checker. These arithmetic examples
supplement the source review; they are not a native memory-safety proof.

The accepted fresh scheduling interface bounds total owner entries, including
abandoned preparations and failed/canceled attempts, rather than only running
jobs. Its conservative G values remain in use: 64, 53, 32, 3 and 1. Thus the
five clients have at most **459 run entries**, 459 interrupt entries and
459 original request/history slots. Save callbacks create no new scheduling
owner. The per-client private request counter starts at zero and increments at
most once per run-call entry; 1..N fits the selected OCaml integer and gives
at most three decimal digits. This conclusion still needs the fresh-route and
container/owner-preservation premises; it is not an observation about every
prospective launch.

I checked the mutually exclusive queued/running lifecycle. Queue cancellation
consumes its queue element and produces one F. A dequeued request starts once,
produces one S, and is reaped once; process removal precedes its F. Interrupts
signal existing processes without manufacturing further completions. Under
valid containers, child ownership and ordinary wait/write semantics, total
responses are at most **918 S/F records**, including a current partial write.
One pending F acknowledgment does not reduce backend backlog to J. R53's one
private connection per launched adapter bounds connection/history slots by 459;
this counts connections, not all endpoint descriptors or kernel buffers.

The ID-width and compact payload formulas apply to **intact, validated original
requests**. Failed writes can concatenate header fragments and create malformed
echoed IDs; those require the inherited failure-aware interface and cannot be
assigned guessed original identities. Count exhaustion is not a physical-resource
classification. Neither these arithmetic bounds nor a syntactically in-range
record replaces duplicate detection, request ownership or the final audit seal.

The payload sums are correct under R54's conditional formatting interface and
separately derived path lengths. At J=12, the request ring reaches capacity 800;
response capacities are 384, 384, 192, 24 and 12. The removal pass allocates a
second request ring of the same capacity and cannot grow it while transferring
at most the original entries. Response allocation may occur during that pass,
so both owners must be charged together. Doubling old/new backing conservatively
gives **41,536 bytes of pointer-ring backing**. The copied tail's source and
destination ranges are disjoint and contained in the enlarged array; checked
capacity/size arithmetic remains an explicit native guard.

This does not bound whole-server memory. Queue removal frees only the request
record on one path and no request object on disconnect removal; parsed argv and
string retention therefore cannot be discounted when slots disappear. Native
structures, extra copies/paths, socket/pipe buffers, malformed evidence, logs,
allocator overhead, filesystem metadata and quarantined raw output remain
outside the payload and ring totals. The conditional 459-slot design does not
supply their representation or attach their byte bounds to the prospective run.

## Logging prefix and constructor trace: accepted conditionally

Reviewed author freeze `bb9bc85d36e5a8ea47c1fefe09ad4f71ae86d822` and its
[research note](../research/retained-parallel-logging-prefix.md). The first
focused check passed 1,054 counted checks, with additional internal graph and
input assertions: 47 source slices, 12 retained archives and 962 installed
instruction rows totaling 4,149 bytes. Observed
subprocess time was 8.553 s; internal check time was 8.140 s. Author files were
unchanged. Static ELF reads and new retained-byte projections are not native
execution or replay of predecessor checkers.

The accepted change is exactly one `--logging` immediately after argv[0] of
each fixed R53 J12 invocation. It preserves the specified environment and
pathname allocation/equality interface, with a fresh private regular log file,
successful ordinary file/resource services and no prefix-altering callback.
The ten-file GNAT scan and source order put logging initialization before SIGINT
handler installation and registration, after driver/input loading and the
external-server connection. Its successful path creates no logical identifiers,
hashcons nodes or session IDs. Parallel-dependent reads occur after registration.

The added argv occupies four managed words. Native `Arg` control flow allocates
27 words for the extra exact-match option; its once-per-parser allocation is
not a per-option charge, and its `Arg.Set` branch introduces no extra allocation.
Logging adds the pathname string and three-word channel wrapper; installed code
uses a static flags list. This yields minor envelopes 39/38/41/40/41 words and
four major words. The native channel request is 65,616 bytes, plus two pathname
allocation requests of L+1 bytes, with their separate lifetimes. These are not
allocator-overhead bounds. The extra descriptor/channel, argv launch storage,
later logging and exit ownership still require aggregate accounting.

The review required a material repair to the promotion argument. Runtime phase
0 is **mark**, not idle; idle is 3. Small endpoint totals alone would not prove
that four extra early words promote only four words if they shifted a collection
boundary. The repaired proof uses the retained startup guard/backtrace sequence
and the explicit `caml_make_vect` collection. Before it, adding four words gives
at most 3,312 allocated words, far below the minor trigger, with no added direct
major/custom-resource request. The same explicit collection therefore occurs
with the same other live roots. Its idle major slice starts the mark cycle but
does not execute `mark_slice`. The argv root set can differ; exact root-stack,
color, ephemeron-purity or future work-budget equality is not claimed.

After that collection, monotone prefix credits remain strictly below the
allocation, remembered-table and resource triggers. Together with the inherited
source/control exclusions, this supplies a first-trigger argument excluding a
new protected collection or weak clearing. The new channel's overwritten stdout
value is a custom block, so darkening cannot push scan work onto the mark stack.
Masking alone does not establish resource success or exclude every callback.

The serial-to-J12 join preserves all 81 ordered requested/resolved file opens
and contents under whole-private-root substitution, seven mapped identities,
normalized arguments and controlled environment. It does not assert equal
allocation totals for paths of different lengths. Source path roles and the
absence of preregistration parallel reads support the stronger constructor-trace
relation, modulo addresses, including `elim_to_of_array`'s intermediate Dprop
reconstruction. Equality of final raw graphs would not suffice. The four old
registration table families transfer under this relation. Input's later endpoint
is deliberately not called its registration cut.

The new 17-field session projection checks the exact generator ranges, one
parent goal/transformation and their children. It reproduces 118 registered-root
mappings across 161 raw goals and checks 6,747 binder records. The uncaptured
static transformation-name bytes are supplied by an explicit load-bias/ELF join,
not an invented target-memory observation. This attaches the existing fixed-root
map to the guarded logging registration cut. It does not cover later log writes,
failed initialization diagnostics, continuing failures or the complete bound q.

## Mutable state: guarded induction accepted; unmasked recovery remains open

Reviewed final author freeze `99e7bbde5616bb2eaa2fab40b86ff8ad0242585c`, including
its exact fourteen-file companion pin to the reviewed logging freeze. The first
focused state check passed 20 direct repository inputs, 24 source files /
44 excerpts, six native bodies / 3,082 instruction bytes and the new raw-context
and mask projections. Subprocess time was 3.948 s, internal time 3.835 s. Its
normal summary write was redirected into the reviewer packet; author files were
unchanged. The author packet's retained pre-pin check is explicitly distinguished
from this final-pin reviewer check. The archive members were also compared with
the exact companion commit bytes, without rerunning its successful checker.

The [state note](../research/retained-why-parallel-state-attachment.md) identifies
two CE memo owners: the per-declaration Wdecl cache and Wtask's complete output
prefix cache. Their closures start empty by the selected source route, not by a
new native observation. Valid completed entries originate from completed
producers. Raw immutable keys and live owner closures root their values, while
fold prefixes provide independent roots. Since Weakhtbl equality uses tags,
immutable physical objects alone do not establish valid memo keying.

The initial-family argument now joins the reviewed logging constructor trace.
For Input, the old post-first-CE complete table supplies a **subset
overapproximation** of its earlier registration table. Successful weak-table
operations preserve occupied slots in the old no-collection interval; loss of
an outside strong root alone does not clear a weak slot. The later 61 raw and
three additional compatible objects therefore cover the earlier same-key
family. No origin for the three extras, equality of cuts, or new mutable-table
address correspondence is assumed.

With valid counters/keying/container arithmetic and successful non-unwinding
published mutations, the ordinary producer induction composes R54's 675-key
family for arbitrary prover first-fill order. It includes constructor insertion
prefixes of subsequently failed preparations. This is a sufficient conditional
continuation theorem; it is not evidence that the default launch meets its
premises.

The installed hashcons body assigns a tag, calls weak merge, then increments its
counter. Growing a full weak bucket can publish the candidate and reach a
loop-back pending-action poll before merge returns; the three-test loop's poll
does not require that a shrink actually allocate. The source growth predicate,
continuing escape and recovery before weak collection are explicit premises of
the duplicate-tag failure schema. No fixed-domain corrupt execution was
observed or established. Nor is there an invented asynchronous call between the
completed merge return and its straight-line increment.

The installed ephemeron resize publishes an empty replacement array before its
six-word copier closure allocation and subsequent Cons copying. An escaping
exception can leave empty/partial data with the old size. Every full first CE
walk from the selected empty Wdecl cache reaches insertion 129 under valid
operations: the five retained raw contexts contain 573/573/301/205/243 distinct
non-goal declarations and tags. This establishes relevance of resize, not an
observed failure. Losing Wdecl alone is **not** a whole-family counterexample:
completed Wtask prefixes and the active accumulator can retain results. Their
own mutation/recovery obligations cannot be omitted. The preparation handler
can continue with another queued owner after an exception.

Ordinary allocation, stack and capacity failures also cross these windows.
SIGINT masking does not remove them. The accepted guard retains successful
services for mutations that publish state, terminal rather than resumed failure,
and a one-worker callback-owner closure. Counter and size arguments remain
obligations up to the first invalid-state cut; the conditional proof cannot be
used circularly as their discharge.

## Prospective mask selection and remaining integration

Selecting the guarded **Why-only inherited SIGINT mask** is coherent with the
source review. It is a design selection, not actual launcher attachment or a
new observation of the captured processes. `sigaction` does not clear the mask;
pending dispatch skips blocked signals; other signal handlers restore the old
mask; the selected thread hook/tick leaves the OCaml worker's SIGINT bit intact.
The one-worker preemption path returns without another application callback.
Explicit Unix/Thread mask-changing APIs have no selected Why client. I also
checked unqualified mask-API strings across the retained Why ML/C/header sources;
the lexical census alone is not the reachability proof. The visible platform
trap unmask is outside selected Linux x86_64. This composes the inherited
native-hook/callback-owner closure, rather than claiming a new whole-program
foreign-code census.

Integration must establish an explicit successful spawn mask with SIGINT in and
SIGTERM out, plus default SIGTERM disposition; an inherited ignored disposition
would defeat unblocked termination. Spawn-attribute/spawn failures reject the
launch. The supervisor must preserve a non-success cancellation result, enforce
SIGKILL fallback and reap Why, and separately own the external server and solver
groups. The Why mask must not be inherited by an internal-server launch or
assumed to govern the separate server/solvers.

Stock disconnect cleanup is insufficient: the fork parent returns before the
child is guaranteed to call `setpgid(0,0)`, while `kill(-pid,SIGKILL)` ignores its
return. Cancellation can therefore miss a child before group creation. Actual
PID/group ownership, fallback covering that interval and reaping remain #88
supervisor obligations. One EOF also does not imply shared-server shutdown.
The review does not require or claim a new supervisor implementation this round.

No SIGINT callback begins under the complete mask/ownership guard. Zero is a
subcase of the existing **two save-entering callbacks / three saves / e <= 2
per process** allowance; no component resets that allowance. Normal ending-save
and exit ownership, allocation/stack/container/counter bounds, log/raw-output
and protocol representation storage, source correspondence and complete
obligation discharge remain open where not already established. None of the
three accepted components establishes the whole-process q bound, production
admission or completion of #119/#153. No Oracle, tool, production or admission
change was made; the PR remains draft.
