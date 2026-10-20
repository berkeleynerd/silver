# Review: selected Why3 publication capacity, Round 35

2026-10-20 UTC, owner-authorized #119 / #155, with results intended for #153.
**Accept the scoped publication bound and writer scalar-size guard under the
documented premises.** The corrected result supplies #155's numerical dependency;
it does not complete #153, #119 or the full writer/save capacity argument.
No unresolved objection remains within that scope.

The semantic target is `1a217c1412962fd0ca599b66988bf3bbf1d61b8e`, with
identity reconciliation `1f52f2281674718298e167d34437173feb7fcae9`.
Reviewer owns only this report in the isolated worktree
`tmp/review-why-publications-round35-20261020`, based on published
`6cf8d322090303cbb47528fb151aa51615884d6e`.

Selected reviewer: GPT-6 Astra / Extra High, as assigned by the parent.
Reviewer agent: `/root/save_round31_review_20261020`.
Runtime settings and token/cost telemetry are unavailable. Review began at
12:52:40 UTC. AGENTS.md and relevant Oracle/external-boundary requirements were
reread. The child live goal is null; the parent owns the active full objective.
No subdelegation, GitHub write, native execution/capture/disassembly, source
fetch, solver/proof run or predecessor replay is authorized or performed.

## Initial identifier registration argument: early challenge

The initial proposed no-GC argument is insufficient. The retained native
`Ident.fun_6183` at 0x56d4e0 increments the private counter, reserves 40 minor
heap bytes (four payload words and header), then returns the identifier.
Its slow branch enters `caml_call_gc`. That name does not imply a collection:
`caml_garbage_collection` enters `caml_alloc_small_dispatch`, whose source
`minor_gc.c:508–543` first undoes the allocation, then processes pending actions
before conditionally entering the guarded collector. `signals.c:260–281`
permits a signal, Memprof or finalizer exception without a GC dispatch.

Thus the observed absence of protected GC/request guard hits alone cannot
charge five words to every increment or rule out an interrupted registration.
The reviewer and parent independently identified this gap before publication.
The root first considered the existing source-prefix client closure and at
most two signal-origin abandoned registrations. The native slow stub additionally
probes stack space after subtracting 4096 bytes before the pending dispatcher,
so native stack-fault abandonment must also be delimited
instead of silently charged to the two signal exceptions.

The inspected source has one `ts_name` constructor in `Ty.mk_ts`, calling
`Ident.id_register`; `tysymbol` is private in `ty.mli`. The private identifier
counter is initialized in `Ident.entry` after the protected Exn_printer entry.
The native call body matches the stated counter increment and five-word object.
The five retained process counters are 136844/121505/77806/59035/60496, but
no-wrap and their exact interpretation require the repaired argument.

The retained captures have no protected collection/request hits or new worker,
unchanged heap interval and collection statistics after the protected start,
and endpoint minor usage below 2^28 words. Earlier startup collection hits
remain in their logs; they precede Ident initialization and are not erased.
The retained GDB invocation is `-nx -q -batch`, disables auto-load, has one
post-starti continue and no signal-policy overrides. These observations were
reported during review as a possible signal/fault exclusion route; the parent
then authored the concrete query and narrowed derivation described below.

The root's final initial-registration packet is
`66ba7f63647e72f0b1e683c39f4017803fc78149`. It narrows the theorem to these
actual debugger-controlled prefixes. A single target-free query of the exact
capture-pinned debugger establishes stopping defaults for SIGINT/SIGSEGV/SIGBUS;
the actual one-continue scripts completed their endpoints without such a stop.
The source-prefix closure handles the remaining one-worker preemption client
and excludes the finalizer/Memprof clients. The native five-word allocation
charge then bounds every completed pre-cut registration and rules out the first
counter wrap. It is not a later-continuation no-signal or no-wrap premise.

The new focused checker passed once in 1.296572642 seconds: five captures,
31 exact retained members and five source excerpts. It did not query the
debugger again. Source/native excerpts, script control, initialization order
and captured arithmetic were read separately; this checker only binds evidence
and recomputes arithmetic. No outstanding objection to the narrowed argument
was identified. **Independence limit:** this reviewer suggested considering
debugger default policy before the parent authored the query and derivation;
this report does not present that remedy as wholly independent acceptance.
The separate [initial-registration review](review-initial-registration-bound-20261020.md),
author commit `3825efb3e7`, integrated at
`c664923c30d9af2ea59908a3e36de24d34ff81e5`, supplies that acceptance. Its
reviewer did not author or suggest the remedy and disclosed the distinct
tuple-preparation authorship. The combined reviewer read that report and
retained its controlled-prefix scope.

## Tuple-family review

The argument uses the global initially retained Hsdecl data-head family, not only
raw selected tasks, and establishes T_prepared=63/63/61/58/59. The source hashcons
equality for Ddata compares physical heads; the Task insertion check uses the
persistent known map and suppresses or rejects a repeated identifier. This
supports separating head-set containment from per-input multiplicity, including
numeric tag aliases and memo hits.

The main closure challenge was whether later selected library parsing
could populate a shared transformation/VC helper cache with new Ddata heads.
Literal initialization extracting only symbols does not alone exclude work
inside parsing. The author also refined the selected encoding branches and
excluded encoding_sort from the actual driver closure.

The frozen tuple packet is now `f29fe06a2228e9fe518c2b1f85e979f86e34bb90`.
Its new checker passed once in 9.573287599 seconds (five cases, 36 source
members). The author closed the parser-cache challenge with the nonempty
library-path test in `Typing.add_decl`, which disables ordinary program VCs,
and the explicit remaining `add_types ~vc:true` case: exact fixed files have
no type invariant/witness, so `Vc.vc` returns from `PDtype` without forcing
its lazy VC environment. The reviewer inspected these bodies and the exact
four-file lexical attachment. Encoding choices now cover guards_full/tags_full;
the unselected encoding_sort route is explicitly excluded. No remaining
tuple-family objection remains.

## Library memo-loss challenge

The first library draft proposed `C_lib = 3,404,511 + 8 I`, assuming strong
tuple memoization limits completed constructions to one per integer key and
charging four extra publications per escaping signal. That argument is not
valid for the retained implementation. `Hashtbl.resize` publishes the new
empty `h.data` before `insert_all_buckets` allocates its tail array. An
exception there can discard many existing completed tuple-cache bindings.
The reviewer identified this source-level counterexample and reported it to
both the author and parent before a frozen checker run or acceptance.

The root initially selected a repair retaining the conservative four-per-source-byte
head transfer: a per-read base charge plus a separate global charge for up
to two whole-cache losses/spurious misses. The root originated that composition;
the library author owns its source/failure classification. No persistence
premise excluding the observed resize mutation order is accepted.

A further challenge concerned later resizing of interrupted, overlapping
bucket chains. The library author proposed charging **every** replacement
`h.data` assignment as complete cache loss, including successful resizes.
Each private array only doubles; a conservative 64 assignments for each of
the two publishing memo tables gives at most 128 global boundaries. Between
boundaries, integer lookup is read-only and insertion prepends a fresh cell;
old malformed tails can cause nontermination but cannot erase a subsequently
cached head. No writer reenters during resize. This avoids a new assertion
that an interrupted rehash recovers its former entries. The author originated
this remedy. Positive lengths are signed 63-bit values, at most 2^62−1;
doubling either stays positive and increases the length or becomes negative,
so it cannot wrap to a publishable zero/smaller array. The parent asked about
this boundary and the reviewer supplied this explicit ABI interpretation.

Final library freeze `2103329044d527685bb94f74b5bca0cfac205819` passed its
new focused checker once (0.235736335 seconds tool wall time): 69 module rows,
72 source slices from 15 Why3/OCaml members, and 11/60 complete-file parse
allowances for int/real. The final source-identity join explicitly compares
each fixed file with its inventory row. The exact interface is
`C_base = 3404503 + 8 I`, `K = 2 I + 38679`, and
`W <= E*(3*T_prepared + 2*C_base) + 4*128*K + 4*e*(K+1)` with one global
`e <= 2`. `C_base` alone is explicitly not a standalone `C_lib` bound.
No outstanding semantic objection remains to this scoped interface. The
parent's final numerical and identity joins passed as recorded below.

## Other substantive checks

The reviewer inspected the actual `Theory.add_decl` head visits, temporary
logic/inductive typing environments, `Pdecl.create_type_decl` and
`create_let_decl`, ordinary `Pmodule.clone_export'` unit traversal, clone type
filtering, `clone_cty`/`clone_cexp`, `Env.read_library`, and `Pmodule.add_use`.
The four-per-byte allowance is a semantic transfer for the selected fixed
declaration forms, not an AST-node theorem inferred from byte counts. The
named-file DAG and complete-file read recurrence include cache misses and
abandoned prefixes; use exports do not copy declaration heads and the separate
namespace-clone route is absent.

The arity domain uses initial registry values and all initial type-symbol
arities, each bounded in cardinality by I, plus 0 through 38678. It is not a
maximum-arity inference from the captured raw contexts. Inspected application,
mask, formula-contract and clone paths preserve lexical argument lists or
type-symbol arity; source-local fresh type symbols and selected algebraic
tests stay within the stated domain. Foreign restoration-body hits remain
allowed. The implicit module's temporary Theory close is a fourth publication,
separate from the direct tuple-theory three-publication charge.

## Final composition and evidence

The final [composition](../research/retained-why-publication-composition.md)
uses the accepted E and T values, the separately reviewed initial I attachment,
the common real-root base charge, and both global replay allowances exactly
once per process. It does not multiply the resize or signal budget by reads,
episodes or saves. Input_Is_Valid's intersecting episode remains conservatively
included. An independent arithmetic calculation matched all five final values.

| Case | E | T_prepared | I | W upper | Margin below retained scalar threshold |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 194 | 63 | 136844 | 1908178454 | 239301723 |
| Put | 161 | 63 | 121505 | 1555755563 | 591724614 |
| First_Or_Default | 98 | 61 | 77806 | 890331658 | 1257148539 |
| Is_Message | 11 | 58 | 59035 | 166800628 | 1980679628 |
| Input_Is_Valid | 5 | 59 | 60496 | 121914523 | 2025565715 |

These are conservative bounds, not measured publications. The new composition
checker binds the exact component results, joins cases/process IDs and episode
counts, evaluates the unchanged Round 34 writer transfer, and checks the
retained threshold and threshold+1 boundary. Importing its pure transfer
functions does not rerun the predecessor checker. The separate initial cell
and scalar-size fields are retained even though their five captured values
agree; the scalar interval is checked against [-2^62, 2^62−1].

The [integration reconciliation](../evidence/retained-why-save-round35-20261020/README.md)
compares 30 author files with their exact freezes, confirms all 94 existing
native input pins unchanged, parses four new Python sources and resolves
18 local document links. There are no clarification overrides. It establishes
byte identity and syntax/link consistency, not source semantics or new native
validation. All author source arguments were reviewed separately above.

| New focused check | Exact freeze | Reviewer execution |
| --- | --- | --- |
| Tuple projection | `f29fe06a2228e9fe518c2b1f85e979f86e34bb90` | Pass once; 9.573287599 s checker elapsed |
| Initial registration | `66ba7f63647e72f0b1e683c39f4017803fc78149` | Pass once; 1.296572642 s checker elapsed |
| Library recurrence/source witnesses | `2103329044d527685bb94f74b5bca0cfac205819` | Pass once; 0.235736335 s tool wall time |
| Numerical composition | `1a217c1412962fd0ca599b66988bf3bbf1d61b8e` | Pass once; 0.005841442 s checker elapsed |
| Author/native-pin reconciliation | `1f52f2281674718298e167d34437173feb7fcae9` | Pass once; 0.164944997 s tool wall time |

Each new checker ran once for this review. No predecessor checker, collector,
capture or expensive validation was replayed. There was no reviewer debugger
query, native target execution,
disassembly, source fetch, solver/proof run or GitHub write. The parent's one
retained target-free debugger-policy query is identified separately; it is
not a native target run. Actual evidence platform is Linux x86_64; this review
adds no macOS evidence. The report itself received a whitespace check.

Substantive review ran 12:52:40–13:19:08 UTC, 1,588 seconds elapsed, including
coordination and author-repair waits. Final report bookkeeping followed.
No token/cost telemetry is available. The child live harness goal was rechecked
at the endpoint and is null; no goal status was changed.

## Limits and handoff

The final result keeps complete writer, restore-table, save and whole-pipeline
capacity false. Recursive own-frame and cumulative Cons-request envelopes
are not resident-memory or full-call-stack guarantees. Remaining structural
allocation/layout, caller/callee/pending stack, exposed counters, channel and
refcount/service/error/exit composition stay open, including positive-write
progress. The wider #119 driver/printer/solver/server/report, grammar and
whole-rule assurance obligations are not closed by this result. Production
#88–#94 remains unstarted and draft PR #121 is not merged.

Review identified and resolved three material prepublication issues: the
no-GC-only registration charge, parser access to shared transform caches,
and tuple-memo resize loss. Root and component authors supplied the corrected
arguments; independent acceptance of the debugger remedy is separately
recorded because this reviewer suggested that route. The later all-resize
epoch remedy was authored by the library agent, not this reviewer.

The parent owns publication, issues, durable memory and the live full goal.
This report's commit is review bookkeeping, distinct from the semantic target,
implementation/evidence commits and proposed next work. No broader completion
or publication action is performed by this reviewer.
