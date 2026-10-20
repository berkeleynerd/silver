# Round 36 selected save-capacity review

2026-10-20 UTC; #119 / #153. All four scoped component results and their final
integration reconciliation are accepted at the exact targets below.
Complete non-formatter allocation, channel, stack, save and pipeline capacity
are not established; #153 and the parent's broader scope remain incomplete.

## Scope, provenance and independence

Selected reviewer: GPT-6 Astra / Extra High. Runtime settings and token/cost
telemetry were not exposed. Observed review start: 13:37:34 UTC. The isolated
review worktree was created at `aeafcd179791afc238344cc305e17e8ebb91bfc8` and
fast-forwarded to the service freeze. The reviewer owns only this report;
the lead owns integration, issue state, memory and publication.

Before this round's caller review, this reviewer provided read-only advice
on the proposed trust interpretation: a positive-write behavioral premise may
be documented within the existing OS/libc/runtime boundary, but is stronger
than the previous interface and is not implied by “functioning services.”
The reviewer suggested the narrow private blocking regular-file/request-range
framing and its required caller join. That contribution is not independent
acceptance of the premise's adoption rationale. The review below independently
checks the root-authored exact source/caller attachment and truthful scope;
it does not certify installed-OS positive progress.

The governing review criteria are Oracle 7–9, 13, 21 and 25, the current
trusted-boundary separation of caller proofs from external semantics, and the
retained source/native behavior relation. All inherited qualifications remain:
selected Linux x86_64 evidence, faithful roots/lifetimes and one-worker hooks,
and the global escape bound e<=2. No per-callback or per-save reset is allowed.
This review introduces no Oracle, tool, pin, admission or production change.

## Selected write-service caller attachment

Accepted target: `3a6a004b292489be00798c8aa8c293a33abf10df`.
Exact new inputs are
[the argument](../research/retained-why-save-service-contract.md) and all files
in [its packet](../evidence/retained-why-save-service-contract-20261020/README.md).
The packet pins the inherited file-capacity/native and offset/service evidence,
both retained source archives, Oracle, trusted boundary and source-identity
document. The reviewer also inspected the retained native write/open/blocking
bodies, source `runtime/signals.c:150–195`, `runtime/sys.c:64–104`, and the prior
file packet's caller/ownership argument. Source inspection read retained bytes;
no new source or native capture was produced.

The conditional result is supported:

- Why3 selects Stdlib output for XML and the selected Compress_none alias for
  shapes. Stdlib supplies write/create/truncate/text, without append/nonblock.
  Linux has no text translation on this route. A fresh stable regular file and
  private live description remain explicit environmental/ownership premises;
  the flags alone do not prove file kind or exclusivity.
- Channel creation starts P=curr-buff at zero. The output copy consumes at most
  free space. Flush reads P after pending actions and calls write only when
  1<=P<=65536. The one-worker/no-pending-hook relation excludes an OCaml callback
  between that read, successful write and state commit. This is an inductive
  valid-request argument, not an assumption that the final store is safe.
- EINTR returns the distinguished negative marker, and flush returns to its
  pending-action check before updating offset/curr. EAGAIN/EWOULDBLOCK can narrow
  n>1 to n=1 once per caml_write_fd call; another error raises. The inspected
  caml_sys_io_error branches either raise blocked-I/O or invoke the nonreturning
  Sys_error path. Error-message/catch resource demands remain separate.
- For an assumed positive result w<=P, offset increases by w and pending bytes
  decrease by w. A full buffer becomes at most 65535 bytes before Putch stores.
  A full-buffer caml_putblock may return zero newly copied bytes after this
  positive write; that is distinct from a zero syscall result. The inherited
  O=F+delta, delta in {-1,0}, F+P<=A<=X lemma covers all ten descriptions and
  both initial cached-offset cases without requiring successful initial lseek.

The new service premise is explicitly stronger than 0<=w<=n and is not proved
by the POSIX excerpt, disabled assertion or samples. Short writes, errors,
exceptions and nonreturn remain allowed. The zero-success countermodel remains
valid under the weaker interface and is not relabelled as a handled error.
Scope excludes arbitrary stdout/stderr, pipe/socket and global-channel clients.
Unconditional file bounds remain null and complete file/save/pipeline flags
remain false. These limitations are necessary to the accepted result.

The focused checker ran once at the frozen target and passed: 9 source slices,
5 process identities, 10 descriptions and 20 initial-offset applications;
reported elapsed time 0.326059898 seconds. It checks identity, extraction,
arithmetic and exported claim flags, not service truth or a semantic proof.
The reviewer separately checked the source branches summarized above. No
predecessor checker was replayed; native executions, fetches, solver/proof and
full-suite runs were zero.

## Structural direct-allocation subtotal

Accepted author freeze: `f120b8f73721b81a245e39f62fd80981d2af979f`, integrated
as `62a85cb8b0`. Exact inputs are
[the argument](../research/retained-why-save-structural-allocation.md) and the
12-file change containing [its packet](../evidence/retained-why-save-structural-allocation-20261020/README.md).
The reviewer read the transfer, checker, source/native allocation projections,
five-case inputs/results and relevant inherited table/operational proofs.

The claimed subtotal has a coherent ownership partition. It adds shape-map
nodes, saved-shape lists and contents/backing requests, preliminary forest
traversal, statistics/frequency/occurs tables and maps, selected getter objects,
sorts and restored-path option blocks to the disjoint accepted formatter owner.
The native sizes count object headers; cumulative mathematical byte totals are
kept separate from represented individual object/array/string sizes. The very
large no-reclamation sums neither imply available physical memory nor exclude
allocation failure.

The main failure/composition challenges were checked:

- U=min(A,P+e+1) counts a final abandoned statistics constructor in addition
  to completed distinct/exceptional bindings. Its private table is not recovered
  by an outer catch. The find handler does not catch its own add, and frequency
  replacements occur outside their find/default catches. A failed private
  resize abandons that owner, so no repeated-capacity retry is hidden. Its
  first resize prefix starts from the accepted valid private representation.
- The frequency bound includes record/initial arrays, both resize arrays,
  index/insertion closures and copied-cell allowance. Per-callback replacement
  bounds do not depend on positive or distinct incoming time/step/memory values.
  Shared-table failure behavior retains the earlier, separate prefix contracts.
- Optional random initialization is charged per create, including failed lazy
  forcing. The selected seed has at most 16 entries, giving 110 digest rounds;
  the 16,384-byte allowance covers the fixed seed/state/lazy objects and all
  per-round strings. This is a direct-object charge, not a proof of entropy,
  libc, error-service or collector internals.
- Sorting charges the 168-byte factory even for zero/one-length lists and
  charges recursive result pairs separately from merge cons cells. Each split
  reduces the valid input size; at most 2n recursive nodes and the inherited
  4n(n+1) cons allowance suffice. Comparators use represented IDs/immutable
  strings and add no unclassified application callback.
- Buffer backing requests include abandoned publication and skipped capacities;
  the global r<=3 multiplies each capacity allowance under the inherited
  no-return relation. Shared-map persistent nodes retain old suspended roots.
  Path options use the reviewed Round 35 W bound rather than a fresh-table
  assumption. None of these relaxations renews e<=2 at a helper entry.

The six pruned residual roots—goal_expl_task, identifier-printer creation,
used_theories, used_symbols, local_decls and t_shape—remain explicitly bounded
in occurrence count but not in bytes. They include administrative substitutions
and unused variable-map entries that opened-formula counts alone do not bound.
The structural subtotal and its sum with formatter requests therefore do not
establish complete non-formatter allocation or save capacity. All corresponding
false/null flags, including physical capacity, remain necessary and accurate.

The focused checker ran once at the integrated freeze and passed: 25 retained
source excerpts, 88 retained native bodies / 18,744 bytes compared against the
identified ELF, four JSON comparisons and five applications; reported elapsed
time 0.472938254 seconds. Missing/false-premise, failed string-size and exact
array/Buffer threshold cases passed. Native-byte comparison is read-only
correspondence evidence, not native execution or a source-refinement theorem.
No predecessor check or new capture/disassembly was performed.

## Binder structural transfer and selected stack projection

Accepted author freeze: `a36841c24be435babc1295828c608c7a5dbd3e49`, integrated
as `f9cf2e7b80`. Exact inputs are
[the argument](../research/retained-why-save-stack-composition.md) and all files
in [its packet](../evidence/retained-why-save-stack-composition-20261020/README.md).
The reviewer inspected the retained administrative projection/checker, native
frame facts and source transfer, including term.ml:404–418,588–675,739–831 and
the selected map recursions; fold2_inter at extmap.ml:535–549 was additionally
read from the retained archive. The accepted logical/fresh task correspondence
is reused, not recaptured or reproved by these initial-input checks.

Every saved substitution image is a Tvar. Opening adds fresh variable images;
substitution at a variable returns that image without descending into it, and
attribute copy preserves its constructor. Non-variable constructors retain
their shape and list lengths. In bv_subst_unsafe, removing the replaced free
keys and adding at most one image key per removed key preserves the F0 key
bound. The deferred map preserves old keys and adds at most F0 per enclosing
opening. Immutable binder copies are not written back to the fixed session
tasks. A later proposition, sibling traversal or save therefore does not
continue the same copy's growth. At most D ancestry steps yield
N=S0+F0*D+L: 2773, 2379, 631, 266 and 281 in case order. Multiplicity-value
arithmetic, raw type graphs and task-selection containers remain separate.

The stack projection respects the distinction between sequential loops and
recursive calls. List.iter/fold_left, identifier suffix search, map find and
the path find_rec do not accumulate one frame per element. Task.filter does
retain a real recursive call and trap; its charged depth consumes a strict
task-list suffix. The named map-family own frames sum to 960 bytes. For one
covered map operation, each family can be bounded by 2n+1 active frames using
strict subtree/combined-node descent, including split/join helpers. The extra
M(A) explicitly covers attribute union inside an administrative-map callback;
variable-only images exclude nested binder descent through those callbacks.
Other callbacks and the same symbols in uncharged contexts remain in U.

The all-three-save covered projections are 33,755,808 / 28,619,952 / 7,610,256 /
2,137,968 / 2,353,296 bytes. They overcharge sequential phases and restored tail
frames, but are not total-stack bounds or observed high-water values. The
complete interface remains A_pre+r*P+U+e*Q+R, with A_pre, U, Q and R unset.
Preparation writer clean/copy frames belong to A_pre; XML output_acc does not
silently cover all shape-constant formatter work. Complete save-added stack
therefore remains null. The sibling's earlier recurrence feedback was not
treated as independent acceptance of this packet.

The focused checker ran once. Because its ordinary entry writes generated
artifacts, the reviewer redirected its output directory to temporary storage
and compared all seven generated files byte-for-byte with the frozen packet.
All comparisons passed: five cases, 65 native bodies / 18,664 retained bytes;
elapsed time 6.356866033 seconds. The output directory was removed afterward;
no author artifact changed. This is a new focused raw administrative projection
and identity/arithmetic check, not a predecessor replay, opened-term interpreter
run or source-induction proof.

## Initial managed-channel count and reference headroom

Initial author freeze: `cc2755f77d`; accepted repair:
`587a75c4b9faf3c5fc97a3309566d6677e3d83b7`. Exact inputs are
[the argument](../research/retained-why-channel-initial-bound.md) and all files
in [its packet](../evidence/retained-why-channel-initial-bound-20261020/README.md).
This component was explicitly added to the review by the lead after its freeze.
It relies on the previously reviewed controlled-prefix/no-reset result and
does not introduce a production signal exclusion.
The reused [Round 35 review](review-save-capacity-round35-20261020.md) records
this reviewer's earlier debugger-policy repair contribution and its independent
acceptance there; this round does not reclassify that contribution as a wholly
independent new review.

The native/source sequence initializes refcount to zero, increments at offset
64, and passes payload size 8/resource size 65616 to caml_alloc_custom_mem.
The selected custom path computes wosize=2 and allocates three minor words.
The reviewer inspected the generic constructor and its installed inlined input,
output and out_channels_list copies, then the custom and small-allocation
bodies. Resource tracking and Memprof follow that allocation. Close does not
decrement refcount; managed finalization does, and no such collection/finalizer
occurs in the retained prefixes.

The increment precedes the charge, so the inherited absence of a pending escape
or capture endpoint inside a suspended constructor is essential. No-collection
alone would not suffice. Post-allocation errors retain their charge; before
allocation the fixed arithmetic and classified ordinary runtime services supply
no abandoned increment. Every managed channel has entered this constructor
path; unmanaged C-only channels are explicitly outside the count.

The review required one proof clarification: the original first-overflow
paragraph charged the allocation after a potentially overflowing increment.
The reviewer proposed using only the preceding INT_MAX completed increments.
The lead independently checked and accepted that repair: before the first
unsafe increment, 3*(2^31-1)>2^28 words would already be charged, contradicting
the retained monotone prefix bound. The repaired checker tests this inequality;
no post-overflow C behavior is required. This repair contribution and the lead's
independent acceptance are disclosed rather than presented as an independent
reviewer-origin proof acceptance.

With no-wrap established, Q<=floor(B/3) bounds initial wrapper increments,
managed-channel count, its output subset and each initial refcount. The five Q
bounds are 42,646,577 / 38,887,027 / 29,312,655 / 25,925,393 / 26,397,074.
They are loose derived bounds, not a measured global-list census. Failed
post-cut increments, repeated wrapper-list calls, new channels and lifetime/
traversal behavior remain open. Complete channel/save/pipeline flags stay false.

The first and only focused channel checker run used the repaired target and
passed: seven source slices, 11 retained native bodies / 1,936 bytes and five
applications; reported elapsed time 0.377626055 seconds. No extra capture,
debugger query or predecessor check was required.

## Final integration

Semantic aggregate: `f9cf2e7b80`, with channel proof repair
`587a75c4b9faf3c5fc97a3309566d6677e3d83b7`. Accepted reconciliation:
`7adcb955d8a01c67a964b8c3957e546f5d48f463`, in
[the integration packet](../evidence/retained-why-save-round36-20261020/README.md).
Its new checker ran once and passed in 0.424162921 seconds: exact correspondence
for 40 author files with two explicitly clarified paths, 94 unchanged native
pins, six Python parses and 21 local document links. It did not rerun any
component checker. The report itself is a separate review artifact.

No unresolved blocker remains for the four scoped claims. One initial-channel
proof clarification was required and repaired before its first reviewer check;
no component check failed or was repeated. The review's semantic work and
focused checks completed at 13:56:22 UTC, 1,128 seconds after the observed start,
including waits for author freezes. No per-model token/cost or live setting
confirmation was available. Evidence was retained rather than rerun; source
arguments were reviewed separately from extraction and arithmetic checks.

Whole shape-builder allocation, omitted native/helper frames, ambient and
service stack, later channel/wrapper counts and lifetime/traversal behavior,
remaining counter arithmetic, source-owned failure continuations and complete
error/exit effects remain open. Positive write progress remains an explicit
external premise. No complete file/non-formatter/channel/stack/save/pipeline
claim follows from the accepted projections or subtotals. #153 and the parent's
end-to-end objective remain incomplete; no goal-status or owner-decision change
is made by this review.

The reviewer changed only this report. No GitHub write, native target execution,
capture, new disassembly, source fetch, solver/proof/full-suite run or predecessor
checker replay occurred. CLI memory was not updated. The child harness goal was
null; the lead retains the live full objective, durable memory and publication.
