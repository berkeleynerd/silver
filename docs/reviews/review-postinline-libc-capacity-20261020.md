# R58 review: post-inline preparation and server libc storage

Independent bounded #119 / #153 review on Linux x86_64, begun 2026-10-20 UTC.
Selected reviewer model/effort: **GPT-6 Astra / Extra High**; runtime setting
confirmation and isolated token/cost telemetry unavailable. No subagents.
Retained source-review interval: 23:36:49–23:50:55 UTC, 846.071 seconds,
including coordination and waiting for freezes, not isolated model time.
Packet validation and commit preparation follow that cut.
The reviewer owns only this report and its
[evidence packet](../evidence/retained-postinline-libc-capacity-review-20261020/README.md)
in the isolated `review/postinline-libc-capacity-20261020` worktree, based on
R57 reviewer integration `4fae42dc7a`. Parent owns integration and publication.
Accepted R57 evidence is reused without replay. No native target, capture,
compiler, solver or proof execution is part of this review.

Both components are accepted at their stated conditional interfaces.

| Component | Accepted first-check author freeze | First reviewer check |
| --- | --- | --- |
| Server libc requested storage | `6bb90bc43cc178f9d867aaf91d013323941e5af1` | pass, 2.583 s |
| Three post-inline stages | `19ad160ab7aa33d1e14a34680cd2b205f56d99ac` | pass, 3.332 s |

Times are subprocess wall times. The full commands, stdout/stderr, internal
timings, exact Git identities and unchanged before/after packet hashes are
retained. Each focused checker ran once in this review. No successful or
predecessor checker was replayed. The libc initial freeze was reviewed but
never checker-run by the reviewer; its repaired successor is the first-check
freeze. Source-review elapsed time and final packet validation are recorded
separately in `round.json`.

## Stock-server getcwd and two strdup calls

The requested-object argument is sound at its named successful-service,
noninterposed selected-libc and caller interface. Review covered the source
allocation paths and helpers, selected string IFUNC/template call structure,
all eleven retained native bodies, the actual request operands and server
PLT/GOT/versioned-symbol chains. The exact installed libc matches the retained
Ubuntu binary package; the matching source-package metadata and patch audit
identify the source candidate. This is local source/native correspondence
evidence, without a reproducible-build or signature-authentication claim.
The historical server's loaded library and resolved GOT were not captured.

Let C be the successful returned cwd byte length, S the socketname length,
P the initial signed-native page-size allocation, B=max(4096,2C), and
D=1,048,624. The reviewed bounds are:

```
G_peak(C,P)       = max(P+C+1, 2B+D)
G_cumulative(C,P) = P+2B+C+1+floor(C/2)D
G_return(C,P)     = max(P,B)
two_strdup(S)    = 2(S+1)
```

The signed 32-bit max followed by sign extension establishes
4096<=P<=INT_MAX. P=4096 remains a conditional tighter substitution; no
historical page-size observation is asserted. The kernel route may retain
its original P-byte allocation after a failed shrink. Fallback frees that
allocation before constructing its initial 4096-byte generic buffer, so
those two buffers do not overlap.

In the generic path, each completed ancestor iteration appends n>=1 component
bytes and a slash. With used suffix u and capacity a, growth occurs when
a-u<=n and requests a+max(a,n). At growth a<=u+n<=C and n<=C, giving a new
capacity at most 2C. Growth is at least doubling; the initial and growth
requests sum to at most 2B. The component guard n<=4095 also proves room for
the slash: n<a, hence the new allocation is 2a and u+n+1<=2a. The unguarded
case a=u=n=4096 would need 8193 bytes after requesting 8192. This retained
arithmetic counterexample is not a native corruption observation.

Each completed iteration adds at least two pathname bytes, so h<=floor(C/2);
root has C=1 and h=0. The DIR constructor clamps its buffer to at most
1,048,576 and adds the native 48-byte header. Each iteration constructs one
DIR; the preceding DIR is freed before the next allocation. Readdir reuses
the buffer and rewinddir resets it. Directory-entry scan count therefore
does not enlarge this requested-storage term. The final DIR closes before
the optional final path shrink. Peak requests allow two path allocations
during realloc plus one DIR, while the cumulative term counts all requests,
including optional failed shrinking and the earlier freed kernel buffer.

Each strdup performs one malloc of S+1. The fortified copy receives identical
length and destination size, so the checked-copy failure route is excluded
under valid live ranges. Both consecutive copies may coexist with getcwd's
retained result. The tighter startup peak is
max(G_peak,G_return+2(S+1)); adding G_peak+2(S+1) to R57's direct envelope is
also safe. The known C+1 and two S+1 payloads must not be charged again.

Required premises include 1<=C<=INT_MAX-45, selected ancestor components
1<=n<=4095, a valid NUL-terminated socketname, S+1<=PTRDIFF_MAX, ordinary
successful services, and representable object arithmetic and pointer
differences. Formula sums are mathematical integers with a separate
representation check at their consumer. The component guard is a caller/
filesystem requirement; the historical unobserved cwd does not establish it.

Review found an incomplete patch exclusion audit: its original regex read
only new endpoints with a/ or b/ prefixes, omitting other top directories
and old endpoints of deletions. An independent scan of both endpoints,
normalizing the first path component and excluding /dev/null, still found
no selected-source hits. The repaired successor includes both endpoints and
conservative Index candidates under the actual default -p1, with explicit
strip-option and unsupported-form controls. Its 256 header pairs and 16
Index candidates repair 14 candidate path sets: the twelve endpoint omissions
plus two Index expansions. All 103 selected-source exclusions still hold.
The first focused reviewer check passed in 2.528 s internally: 47 source
members, eleven native bodies / 3,635 bytes / 823 instruction rows, fifteen
operand witnesses and 1,562 growth/shrink models. These finite examples
exercise the argument's boundaries; they do not prove universal C semantics.
The author's earlier finite-model failure exposed the missing component
guard; its corrected check and the reviewer check remain separate events.

## Post-inline preparation

Accepted through builtin elimination and unused removal for Z3/CVC5/Alt-Ergo,
and polymorphism detection for Z3/CVC5. Review covered the complete three
transformation paths, constructor/task validation and stored/opened term/type
folds, pattern compilation, driver update/clone/meta transfer, per-stage
arithmetic, and the new structural projection. The first reviewer check passed
in 3.157 s internally: 75 input pins, five inventories, 561 singleton
nonrecursive bodies, seventeen source files / 34 excerpts and four controls.

The raw context has 1,238 formula keys: 561 singleton Dlogic, two singleton
one-clause Dind, and 675 axioms. The new recursion inventory correctly excludes
the definition equation's head, while retaining body occurrences, triggers and
saved values. Outer saved images are variable leaves. Earlier valid declarations
cannot mention the later physical head, so optional inlining preserves absence
of self calls. Termination validation still opens/scans each body but cannot
expand a recursive call component.

Builtin elimination drops, abstracts or reconstructs each singleton, without
generating a new formula body or symbol. An older successful Dlogic/Dind
hashcons return is covered first by R57's producer-derived hidden-map/type
envelope; only then is its unchanged semantic M attached through equality.
Ddata and generated Dparam returns use fixed physical heads/signatures.
Goals remain their original unique declarations. Theory/task equality uses
that declaration pointer and cannot import an older goal's stored fields.

Known-map addition scans used symbols and repeats match, positivity and
inhabitedness checks. Both task rebuilds are charged. I specifically checked
the environment-dependent Ddata calls at decl.ml750–835: the retained full
ground-data descendant forests cover repeated type-symbol and constructor
descent, including the positivity helper. Their F_type/F_constructor counts
are 52/29, 52/29, 50/28, 36/21 and 38/22. Those datatype heads have no parameters;
constructor argument applications are nullary ground types. The additional
16[C(A+1)T+F_type+F_constructor] type allowance per stage covers this work
separately from term traversal. The fixed nullary context cases supply their
scrutinees and have no pattern variables or constructor arguments, so the
pattern validator creates no fresh Ident there.

Unused removal's symbol fold traverses saved values even when unused by an
opened body; its retained tdecls undergo another task insertion. Closure
propagation consumes existing records, but an earlier declaration can later
reinsert the same key. The reviewed C(S+D) insertion bound therefore pays for
all such records; C+C(S+D) entered batches and S times that number bound the
identifier callbacks. This yields 226,069,984 record writes and
239,222,605,204 identifier-fold entries. They are source counts, with primitive
map/set costs still separate.

Detection scans signatures/heads and stored proposition types, then adds its
empty monomorphic meta and reinserts the unchanged goal. Common expanding
remove-all directives are compared by exact theory/rule, not filename. Common
type-meta source files, the same environment and clone histories, and the
nonexclusive meta declarations transfer R54's two one-node MAty arguments.
No forced theory use or additional dependency meta is introduced. The loose
H0(1+B)+Z+1 task-node bound counts every other rule/history pair. Disabled
debug printers remain excluded, while 375,492 eagerly evaluated cardinal
calls are explicitly retained. Native costs of those cardinal operations are
not assigned a unit value.

The context traversal allowances are independently 16/8/2 for builtin,
unused and detection; each stage gives the unique goal four units with its
own R56 M/P/K/V. Context V=1 is never imposed on a goal. Temporary validators
restart from immutable input; K_open=K+2P² covers their opening maps. The source
site census includes termination, inductive prefix/positivity/type checks,
declaration hash and successful comparison operands, used-symbol folds and
match walks. Direct Ident bounds are respectively
3A_f+2B_l+3B_i+B_a+B_g, 3A_f+B_l+B_i+B_a+B_g, and B_g, matching the actual
fresh-opening sites. These are additional charges beyond first inline.

| Additional source category | Combined bound |
| --- | ---: |
| Direct Ident registrations | 753,327 |
| Term/opening entries | 409,000,945,003,072 |
| Free-variable scan entries | 62,890,282,384,734,680 |
| Type-node entries | 89,202,111,545,305,784 |

All are below 2^62. The first two stages use raw+CE+CE; detection uses raw+CE
because Alt-Ergo has no detection stage. Per-stage maxima overcharge the same
global e<=2, without creating new interruptions. The 59,781 Hsdecl, 186,092
tdecl and 7,367 type-application counts are constructor requests, not successful
tag increments or failed-comparison bounds. These stages preserve the returned
formula/type interfaces for the next transformation; initial shared counters,
unsuccessful comparands, primitive costs and later transformation/printer
demands remain separate. No material finding remains on this bounded component.

The author round records two preliminary structural diagnostics and a focused
check repeat after adding type-meta origins and source slices. Its final
2.974 s author result is distinct from this first reviewer check; unavailable
earlier timings are not reconstructed. The datatype check was an explicit
review question, confirmed covered in the freeze rather than an omitted charge.

## Composition boundary

All stages share the existing per-process two save-entering callbacks,
three saves and e<=2. No component receives a reset allowance. Existing R56
candidate/kernel/goal charges and R57 returned-context charges remain.
These source-operation and requested-object categories are neither disjoint
runtime costs nor a physical-memory bound.

For the one prospective shared backend server, the direct R57 formula composes
with the new libc term exactly once:

```
B_with_libc = 459A + sum_d N_d*tau_d + sum_d 2R(M_d) + 918C + 376401
            + max(INT_MAX+C+1, 2*max(4096,2C)+1048624) + 2(S+1).
```

Here C is that backend's cwd length and S its actual socketname argument
length. The five fixed frontend basenames do not establish S=11 for a new
backend. P=INT_MAX is the conservative substitution, requiring no captured
page size. R57 already charges process records, raw pathnames and response
payloads; this substitution adds only the separately named libc objects, with
no second C+1 or strdup payload charge. All libc caller/component, arithmetic,
successful-service and noninterposed-binding premises still apply.

The existing [capacity design](../research/retained-tool-capacity.md#comparison-and-next-derivation)
and [trusted boundary](../trusted-boundary.md#trusted-computing-base) supply
ordinary allocator/OS behavior and sufficient physical stack, memory and
disk. Excluded physical owners create no aggregate RAM admission gate or
allocator-internals proof obligation. Relevant finite indices,
representations, request arithmetic, correctness counters, caller/source
correspondence and stack assumptions remain required. Full q and #119/#153
remain incomplete; #88–#94 are unstarted and PR #121 remains draft/unmerged.
No Oracle, installed-tool, admission or production configuration changed.
