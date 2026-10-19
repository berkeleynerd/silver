# Retained Why native closure and composition review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept `7b84ac0176fb5ae243cc905eb3c5c64f1f176b16`; no material findings.**
The native source/interface argument establishes **`N_native = 0`** additional
identifier registrations and the required protected-state preservation under
the named relevant-source behavior relation. It composes with accepted
save/exit source `6dd2732dd083ba6e29c7e2bd026d5668a0283b5e`, reviewed at
`3956aa7fb78c5ada4c9ceda2ba26ce76766b389e`, to give
**`counter_end <= 89,493 < 2^62 - 1`** for the specified retained interval.
No further native capture or investigation is required for this scoped result.

## Exact inputs and review record

The target is the [source argument](../research/retained-why-native-effect-completeness.md)
and all 18 files in its
[20261019 packet](../evidence/retained-why-native-effect-completeness-20261019/README.md):
the README, checker, input and excerpt plans, 53 source witnesses with 90 ranges,
source-family projection, ELF lifecycle and weak-provider projections, retained
launch plan, interface and configuration certificates, native result,
composition, three frozen companion inputs, result and round record. I inspected
the source excerpts, all 11 root rows, seven component contracts, 17 selector
rows, 153 source-file mappings and the projected selector/lifetime uses. I read
the accepted companion source and review to assess the interface join; its
already accepted reporting derivation was reused rather than independently
repeated in full.

The witness is PID **97103**, capture
`20261019T000304-fcb988ec2c03`, executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Source revisions are OCaml `8eb41f72ded84df884c3671734c947f612091f84`,
Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`, and Zarith
`667d742948914aa1f80d5ad5abb98bc412335e51`. The seven image identities, prior
capture/source correspondence checks, accepted registration/ownership results,
representation domains and blocked-SIGINT protocol retain their existing scopes.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime model/effort confirmation, token usage and monetary cost are unavailable.
The inspection interval was **13:30:41–13:35:22 UTC**, **281 seconds** at
one-second resolution, excluding report preparation and commit. Actual host:
Linux 7.0.14 x86_64. The author separately selected Astra / Max for the named
native completeness problem; that recorded selection is not runtime confirmation.
The review worktree is `tmp/review-why-native-composition-7b84ac0176`; this report
is its only owned change. The live subthread goal was null. CLI memory, GitHub
and integration records were not changed. The lead owns integration, publication
and the owner-requested pause.

## Source selection and initial configuration

The packet uses the existing
[external behavior boundary](../research/retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
in a sufficiently concrete way. It names the OCaml native runtime,
Unix/systhreads, Zarith, generated startup and ordinary CRT/loader families and
the initialization, interface and lifetime behavior imported from them.
The source side includes 233 C/header/assembly members plus Zarith, rather than
only bodies chosen after observing particular hook addresses. The duplicate
`signals.c` basename keeps both its runtime and Unix sources; `amd64.o` maps to
the assembly source. Generated OCaml entry calls the selected unit entries and
updates the initialized-global count. It supplies no extra lifetime registrar.

ELF file labels are corroboration of this relation, not a complete provenance
proof. The target expressly rejects inferring absence of stripped contributions
or arbitrary aliases from those labels. The three application images' retained
init/fini entries and their imports agree with the classified CRT families.
The seven-image weak-provider projection supplies no definition for the
profiling/TM hooks. These facts combine with the accepted fixed-loading result;
they do not justify the same result with an arbitrary preload. No stronger
binary attestation or compiler-refinement premise is needed by the existing
boundary, and none is established by this review.

The initial selector derivation is substantive. Static source initialization
gives null timing, major-GC, root and fatal hooks, null channel hooks, standard
blocking/Memprof defaults and cleanup zero. Thread entry runs its initializer;
reaching the later retained fold requires that sequential initialization to
have returned. The selected native family contains no earlier alternate root
installer, so Thread saves a null predecessor before installing its scanner.
The `curr_thread != NULL` guard prevents a successful repeat from extending
that chain. The remaining Thread assignments select the stated blocking,
channel and Memprof owners, and POSIX initialization selects `pthread_sigmask`.

The exact environment has `OCAMLRUNPARAM=s=256M,h=16M,M=1000`. The source parser
therefore does not take the `CAMLRUNPARAM` fallback and encounters no `c` option.
Its only selected cleanup writer leaves the source-initialized zero unchanged.
This excludes the extra `caml_shutdown` named callbacks from `caml_do_exit` on
this invocation without assuming successful output, successful saves or a live
flag observation.

The use projection, enclosing source bodies and accepted reflection restriction
also supply preservation. A focused check of compatibility spellings found
their declarations only, not a concealed alternate writer. None of the
classified interfaces exports these selector cells as ordinary mutable OCaml
values or supplies their addresses as libc/GMP output buffers. The derived
17-value configuration is therefore an initial-state and frame result under
the stated source relation; the absent seven live readings are not a remaining
requirement for this argument.

## Native effects, exceptional paths and lifetime

The source decomposition exposes the relevant application dispatch. Collector
timing/major hooks and Thread's root predecessor have their derived null values.
The selected root actions preserve logical roots under the existing collector
contract. Empty finalizer registration history excludes OCaml finalizers and
their timing hooks. Never-started Memprof excludes tracker callbacks, but does
not exclude `entry_arrays_iter`'s native context-hook call. The packet correctly
retains that edge: Thread's `memprof_ctx_iter` only enumerates thread contexts
and invokes the supplied collector action. It neither fabricates a tracker
closure nor accesses Shape. Empty entry arrays supply the corresponding
user-data-loop result.

Thread's enter/leave blocking bodies save/release and acquire/restore runtime
state. The one-worker/no-added-worker result prevents those operations from
scheduling another OCaml application. Its channel owners change mutex/TLS and
channel-owned state. I additionally read the save/restore and enter body at
`st_stubs.c:175–233`, which precedes the retained excerpt, and the Memprof
leave/enter bodies at `memprof.c:1126–1136`. The POSIX TLS keys use
`pthread_key_create(res, NULL)`; TLS teardown does not introduce an omitted
destructor callback.

Allocation, collection, pending processing, I/O and raising can call one
another. Their cycles are adequately covered by a preserved effect invariant:
owned writes remain owned, and every application entry returns to a listed
root. A finite bound on internal retries or collections is unnecessary for
this zero-additional-registration/frame statement. In particular `io.c` unlocks
around pending processing and relocks, while `fail_nat.c` unlocks, roots the
exception and processes pending actions before unwinding. Neither mechanism
replays an arbitrary interrupted Why body. A newly delivered save exception
can replace the original exception and unwind through the companion's receiving
traps; it is not treated as a successful save or as an impossible outcome.

Focused source inspection of native `caml_callback*` clients found the named
thread-entry, signal, finalizer, Memprof, dynamic-loader, shutdown and uncaught
routes already classified by these components. The standard named exception
paths retain ordinary payloads: bounds failure uses Stdlib's preallocated
`Invalid_argument`, and Unix constructs its ordinary error/string tuple. The
covered roots supply no arbitrary logical exception payload or named-registry
replacement. Native raising therefore joins the companion's primitive failure
domain and its separately reviewed receiving translations. The uncaught wrapper
and its final suppression retain the companion's finite reporting topology.

The value-domain joins are also appropriate. First-fold constants enter
`ml_z_compare` as immediates; the enabled source fast path has no allocation,
GMP or callback edge. Candidate hashing and primitive session keys do not select
custom compare/hash operations. Saved decimal formatting uses the separate
five-atom domain and its bounded buffers; nonzero values still use ordinary GMP.
The accepted destructor classification is not substituted for these other
custom-operation slots. XML/shape saving does not select Marshal, and the
NoDef tuple-symbol construction reached by diagnostics does not introduce
Number's range/real printers or another native family.

Native lifetime coverage is explicit. Eventlog teardown owns its C buffer/file;
optional Zarith teardown prints scalar counters; Windows debugger cleanup is
excluded by the Linux native target. The absence of application atexit imports
is not used to avoid analyzing the optional source owners. Ordinary CRT
destructor dispatch and libc/libm/GMP/loader cleanup remain within their named
contracts. Stack statistics, fork and Thread.exit are excluded by the selected
roots, while their initialization interfaces are still classified. None of
these conclusions assumes all callbacks harmless or all failures impossible.

## Composition and noncircular no-wrap result

The accepted companion supplies the same private fold/Shape/formatter and
retained representation invariants used by the native frame statement. Its
`D = 25,920` includes tuple-type memo misses and failed printing prefixes.
Those OCaml registrations are not erased by `N_native = 0`. The native theorem
states zero **additional, unaccounted** registrations and preserves the source
arguments to which the companion applies.

The copied companion effect ledger, report-site graph and review are byte-for-byte
equal to their files at the supplied source/review commits. A focused check of
those joins, PID/run/executable fields and arithmetic passed in **0.013489
seconds**. The composition is

```text
60,496 + 1,145 + 2 * 966 + 25,920 + 0 = 89,493
total interval registrations <= 28,997
89,493 < 4,611,686,018,427,387,903.
```

The native selector/effect proof does not use this endpoint to select its owners
or obtain its frame result. Starting with the components' cut invariants, every
prefix before a possible first wrap has at most the same 28,997 registrations.
Its counter therefore remains below the limit, excluding that first wrap and
supporting the inductive continuation of those invariants. This is an
interval-local argument. The positive captured counter and this arithmetic do
not prove global freshness, valid caches or no wrap in the earlier process
history; the components' existing cut/well-formedness premises remain explicit.

The endpoint stops at the companion's stated first-invocation return/failure
continuation or terminal boundary. It does not cover a later scheduled
invocation, ordinary ending-save/SIGINT interference, other resource capacities,
the full transform, the current grammar or the whole pipeline. These are the
target's established scope limits, not new native obligations or a successor
research request.

## Validation disposition

I reused the author's successful **3.0089937540033134-second** checker result
for frozen hashes, excerpt correspondence, bounded ELF metadata, source-use
projections and the retained Thread entry witness. I inspected the checker:
its semantic claims are correctly marked as source-reviewed rather than
machine-proved. Additional review checks were limited to the focused pinned
source reads/searches and companion/arithmetic reconciliation described above.
No target executable, new capture, disassembler, old graph/capture checker,
compiler, prover, Lean build or suite replay ran. Report links and whitespace
were checked. All target files remain unchanged. The accepted native and
combined result is ready for integration and the requested pause.
