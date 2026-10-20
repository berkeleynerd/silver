# R57 review: returned context storage and shared-server owners

2026-10-20 UTC; independent bounded #119 / #153 review on Linux x86_64.
Selected reviewer model/effort: **GPT-6 Astra / Extra High**; runtime confirmation
and isolated token/cost telemetry unavailable. No subagents were used.
Retained review interval: 23:14:59–23:34:06 UTC, 1,147.234 seconds including
coordination, context resumption and waiting for freezes, not isolated model
time. Packet validation and commit preparation follow that source-review cut.

Base: published R56 integration `f306912c98e2449015a0514e0be5c11b99de5be1`.
The reviewer owns only this report and its
[evidence packet](../evidence/retained-returned-server-storage-review-20261020/README.md)
in the isolated `review/returned-server-storage-20261020` worktree. Accepted
R55/R56 evidence is reused without replay. No native target, capture, compiler,
solver or proof execution is part of this review.

All three components are accepted at their stated conditional interfaces.

| Component | Exact first-check author freeze | First focused reviewer check |
| --- | --- | --- |
| Remaining stock-server owners | `73fe83500c16672716d0045d4b7aab1fda4f4ef1` | pass, 1.377 s |
| Shared-server successful-prefix transfer | `a1257eb2a3107d227bf09153813f5c057ad77c73` | pass, 0.345 s |
| Returned original-context storage/types | `5feafce8f3363e2463da099bda2a115d19dd8050` | pass, 1.464 s |

Final accepted server freeze is `d82165ee7b874e65f64be8181de21763d83bda7e`;
final accepted prefix freeze is `ab453599af8bf338ed0de15b2d4ad52b6a22ecf7`.
These successors change resource-scope prose and, for the server note, its
identity pin. Exact diff/identity review accepts them without replaying the
unchanged numerical/source/native checks above. Returned storage's final freeze
is its first-check freeze. The packet retains the separate tested and accepted
identities, including the lead-found scope correction.

Times are subprocess wall times, not native target timings. Retained checker
records include full commands, outputs, internal timings and unchanged
before/after author-packet identities. Successful checks were not replayed.

## Remaining stock-server owners

Accepted at its direct requested-object storage interface. Review covered the
complete selected C translation units, 28 allocation sites, 56 caller sites,
the 535-member ML/MLI setter/caller census, all 22 source witnesses, the complete
18-body installed disassembly, ten native allocation/layout operands and ELF
symbol inventory. The focused checker verified 638 instruction rows / 2,484
bytes and the source/projection attachments in 1.327 s internal time.

The prospective topology is one shared J12 server with five fresh backend
connections and no reconnects, replacement connections, unrelated clients or
control producers. The five historical R53 server PIDs/pathnames are separate
captures; they do not establish this shared topology. Their `--single-client`
option controls exit after the last disconnect, not the allocation formula.
The shared backend omits that option. No selected gnatwhy3 caller sends
`parallel;...`, and `connect_external` sends no handshake. J therefore remains
12 under the stated interface. Native C server logging stays disabled; Why's
`--logging` switch is a distinct facility.

The two list controls/backings, J+2 poll entries, persistent queue and at most
one temporary queue control contribute 496 bytes. Five clients contribute 104
bytes each, yielding 1,016 fixed shared controls. Client/poll occupancy remains
bounded by the five accepted connections even with poll tombstones. Both
dispatch sites keep process occupancy at most J; synchronous reap/free occurs
before replacement dispatch. The temporary request queue is nonrecursive:
its callback allocates responses without recursively disconnecting clients.
At most one temporary queue is live, with at most N+c cumulative constructions.

R55 ring backing is charged once using
`16*(2*sum_s Q(100,N_s)+sum_d Q(12,2N_d))`: 41,536 shared bytes. The alternative
five-singleton topology gives 38,336 ring bytes and 3,000 fixed control bytes;
these alternatives must not be added. Each run reaches process creation at
most once. Its 24-byte process record and C+12-byte raw pathname are charged
cumulatively. The parsed ID pointer transfers into the process record without
a second string allocation. Cumulative process records total 11,016 bytes;
the tighter shared live bound of 288 bytes is not substituted into the
cumulative combined formula.

S/F response buffers transfer to current/queued write data; partial writes add
no copies. `S=d+4`, `F=P_b+d+31` and `P_b=C+11` give `459C+23628` response
bytes. Cancellation/disconnect leaks are already covered by cumulative parser
charges; their frees are never subtracted. Combining parser, parent exec argv,
receive backing, ring backing, responses, controls, process records and raw
pathnames exactly once gives the conservative m_d=14 interface:

```
B_direct = sum_d N_d*L_d + sum_d 2R(M_d) + 918C + 250578.
```

The note separately exposes the libc-owned `getcwd(NULL,0)` and two `strdup`
allocation envelopes. Known payload lengths C+1 and 2(S+1) alone do not prove
their allocation capacities. Allocator metadata, libc workspaces, executable,
runtime and stack baselines, kernel owners, child/fork/COW/exec memory, proxy
and Why owners are outside this direct requested-object formula. This exclusion
does not make allocator internals, fragmentation or aggregate physical RAM new
#119 proof gates: the existing
[capacity design](../research/retained-tool-capacity.md#comparison-and-next-derivation)
and [trusted boundary](../trusted-boundary.md#trusted-computing-base)
supply ordinary allocator/OS behavior and sufficient physical stack/memory/disk.
Finite indices, request-size arithmetic, correctness-relevant counters,
caller/representation/source correspondence and the actual proxy interface
remain required. Intact streams, preserved containers,
successful native services and the inherited overlapping-memcpy bridge are
essential conditions. There is no outstanding material finding on this
conditional component.

## Shared-server successful-prefix transfer

Accepted for the exact fixed-prefix successful peer substitution. Review covered
the note, all twelve source slices, endpoint projections, setter census and
five complete installed native function witnesses / 1,600 instruction bytes.
The focused checker passed in 0.299 s internal time.

The interface preserves each exact R53 client-facing socket pathname, cwd,
argv/input/environment role, together with the accepted R56 quiet/timeless and
logging edits. It substitutes only the successful peer behind each endpoint:
five proxy frontend listeners lead to five connections to one shared backend.
The five client path lengths are 50/89/56/96/56; every basename is the same
eleven-byte `server.sock`. This is not an arbitrary relocation or an
equal-length-path substitution theorem. Attaching the literal historical
spellings to a production workspace remains separate.

`Gnat_checks.init_cont` establishes the session/controller/drivers/source before
the external connect; logging follows and the fresh branch returns that
controller. `connect_external` checks disconnection, clears an existing receive
buffer and calls `client_connect` with fail=true, without protocol reads or
writes. On the selected Linux path, `client_connect` performs getcwd,
dirname/basename, Unix socket creation, chdir/connect, cwd restoration and
returns Some fd. It does not query the peer's identity or data. Installed
`unix_socket` returns an immediate descriptor; successful Unix connect returns
unit using the unchanged basename address. A different valid opaque descriptor
does not change this managed allocation shape.

`gnat_main` registers roots before scheduling or the main loop. Trivial proofs
are session entries, not solver launches. Stock server accept is silent, so
the proxy must send no unsolicited bytes and must stay open through
registration. Under those conditions the peer substitution has zero delta in
Why managed allocation requests, logical registrations and application protocol
bytes through registration, relative to R56. The existing connection cost
remains charged. This does not assert identical descriptors, kernel state,
elapsed time or whole heaps. Blocking service boundaries can run pending
actions, so inherited noasync/profiling/externalheap/nonunwinding conditions
remain required. The five native ranges provide local correspondence evidence,
not a new whole-program proof.

The same 118-root / 47-check map and process-wide allowance apply. Backend
cwd/environment/solver routing, actual proxy/backend/kernel allocations,
launcher setup, failure/cleanup outcomes and later scheduling remain separate.
There is no outstanding material finding on this conditional component.

## Returned original-context maps, types and validator support

Accepted after the evidence-extraction repair described below. The first
reviewer check on the final freeze passed 86 pins, ten context routes, 98 feature
occurrences, 22 source files / 46 excerpts and six controls in 0.868 s internal
time. The author's preliminary import-resolution and lexical-projection
diagnostics are recorded separately in its round record; its final successful
check was 0.862 s. These are distinct author/reviewer checks, not a claim that
the first author attempt already had the final inputs.

The reviewed interface concerns 1,238 original context declaration keys: 561
Dlogic, two Dind and 675 Paxiom. It does not include arbitrary old collision
comparands or freshly headed later declarations. Goals use `Hsdecl.unique`;
their larger R56 candidate envelopes and nonleaf saved images are separate.
Those existing candidate/kernel/goal charges must remain in any composition.

The context-only projection follows stored bodies, triggers, patterns and all
saved images. It includes the types of bound/free/cache/key/image variables,
including dead keys, and referenced symbol signatures. Every initial saved
image is an actual variable node, K0<=6, opened bound/formal support P<=8 and
first-inline reconstructed formula mass M<=99. Type masses are at most five
for Put/Put_Line and three elsewhere; signature arity is at most seven. The
projection checks context rows against the accepted R56 rows without replaying
its goal calculation or checker.

I checked the actual substitution rule: `bv_subst_unsafe` restricts the incoming
map to the binding's valid semantic free-variable cache, composes every old
image, including unused entries, and joins the restricted map. Variable-only
composition preserves variable images; copied variables preserve types.
Closing resets the current map to empty, while an unchanged callback retains
the complete old binding. Thus neither strict equality nor a close shortcut
silently discards hidden storage from the argument.

The selected producers preserve this stronger invariant. Eligible inline
bodies are binder-free, so their substitution creates no saved image even when
an argument contains bindings. All six context cases have nullary patterns,
leaf scrutinees and binder-free branches, excluding the algebraic case's
nonleaf substitution into surviving binders. Put's four epsilon/wf axioms are
removed before epsilon processing. First's sole remaining epsilon has a closed,
binder-free two-node witness and three-node residual property; its substitution
cannot install a hidden image. Let substitution acts on a binder-free body,
or the sole nested leaf-valued inner let simplifies first wherever formula
simplification performs that substitution. The corresponding value traversal
that only maps a let is also harmless. Literal rewriting replaces nodes through
safe maps, without substituting a nonleaf replacement under a retained binder.

Definition/inductive elimination retains original records or changes the kind
or physical head. Fresh auxiliary heads cannot rejoin original keys. Premise
splitting keeps the old prsymbol only for a singleton result; each selected
result uses each source subtree at most once. The by/so-disabled axiom path
and absence of original axiom cases matter here. Introduction's separate
hashcons equality is weaker on physical proposition identity, so merely citing
fresh heads would be insufficient. The complete original-head attribute census
and empty introduced-prsymbol metadata exclude that route independently.
The declared-name census also excludes the pre-created `identity_def` canonical
epsilon axiom. Other canonical-cache heads are fresh after the guarded prefix,
so unique-goal processing cannot import a pre-existing original context head
through that separate cache.

CVC5's encoding branch is excluded by a chronological argument. The exact
shared driver directives are resolved in the same environment and applied
through the same Use/Clone histories as R54. This transfers the needed ignore
and wf-removal metas by source inclusion, without pretending CVC5 metadata was
captured. R54's complete component dependency census, ground initial
propositions and the new leaf-image/type invariant then establish detection
before a possible encoding pass. Consequently both conditional encoding passes
are identities. Alt-Ergo's unconditional algebraic path remains included.

During review, the initial driver comment-removal regex mistook a quoted SMT
multiplication string for an OCaml comment opener and omitted the active `ite`
directive. The author replaced it with a string-aware nested-comment scan,
including the source lexer's `(*)` exception, and explicitly asserted all four
required ignore directives. I checked the repair against `driver_lexer.mll`
and `lexlib.mll`. The actual directive was present in the source throughout;
the issue was evidence extraction. The author also clarified that the 32-unit
validator allowance applies to first inline, not every later stage.

Every new substitution can add at most P keys to a binding because its valid
semantic free-variable cache has at most P keys. A retained lineage encounters
at most P productive enclosing opens per traversal. The selected stage union
charges sixteen productive traversals per preparation, including conservative
extra entry, epsilon, simplification and split work. A successful memo return
selects an older covered representation rather than adding a new lineage
edge. Each original key is constructed at most once per selected pass; the
same global E<=3N+e, e<=2 budget includes permitted failed prefixes. Hence
`K=6+16EP²` bounds each returned saved map. Only after this producer argument
does strict equality attach the first-inline M bound, giving `R=M(1+K)` stored
occurrences. The largest process bounds are K=158,726 and R=15,713,973.

Temporary validator openings use `K_open=K+2P²` and
`U=M+(P+1)M(1+K_open)`. The reviewed actual calls include definition opening
and both callback operands, constructor free/type scans, termination and
used-symbol folds, environment opening, task match checking, inductive
prefix/positivity scans, declaration hashing and proposition checks. The
twenty traversal units are overcharged by 32 per context key per first-inline
invocation. Dtype/Ddata checks do not read these returned term binder maps.
Retaining the independent R56 candidate charges is conservative.

The resulting additional source categories total 498,048,222,633,984
term/opening entries, 49,306,774,040,764,416 free-variable scan entries and
108,700,861,096,599,552 type-node entries. All are below 2^62; they are overlapping
operation categories, not disjoint runtime costs or physical memory bounds.
Map/table primitives and representability, string/arbitrary-precision operations,
allocation/collection/caller-stack interfaces, unsuccessful collision
comparands, initial shared counters plus later demand, and later-stage/printer
total work remain open where needed by the selected finite rule. Physical
resource sufficiency remains the existing external premise.
The unused-map counterexample still disproves any bound from strict equality
alone; the new result depends on the selected producer history and guarded,
immutable state with valid caches and unique identities.
There is no outstanding material finding on this conditional component.

## Composition and remaining obligations

Substitution of the accepted quiet request maxima contributes
`125823 = 351*273 + 96*278 + 12*276`. Thus the direct shared-server interface
can be written as

```
B_direct_quiet = 459A + sum_d N_d*tau_d + sum_d 2R(M_d)
                 + 918C + 376401.
```

This includes process records and raw pathname owners. The excluded process
memory is the native/child/fork/COW/exec and runtime memory described above;
saying that all process storage is excluded would hide the charges already in
this formula. Actual A, C, tau_d and M_d must still satisfy the valid-stream,
native arithmetic, pathname and deployment premises.
N in the returned-storage formula counts registered roots per Why process;
N_d in the server formulas counts backend run requests. They are distinct
operands, even though both are attached to the same fixed family.

All components share the same per-process two save-entering callbacks, three
saves and e<=2 allowance. No stage, prover or component receives a reset.
The complete #119 finite capacity/q rule, actual launcher/proxy and
configuration, failure paths and full obligation discharge remain open. An
aggregate RAM admission gate and proofs of ordinary allocator/OS internals are
outside this task's existing trusted boundary. During integration the lead
identified residual wording that incorrectly promoted those excluded physical
owners into required proof obligations; this review records the corrected scope
without changing the arithmetic or weakening required finite/source checks.
Oracle, tools and admission are unchanged; #88–94 are unstarted and PR #121
remains draft/unmerged. No component closes #119 or #153.
