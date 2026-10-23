# Library and parallel-callback six-owner review, 2026-10-23

**Accepted with the retained premises:** library
`0ab2fcb5240bfd7551b9749518b95a956ba45041` and callbacks
`95d1464c5a27b1a574c243da04726b5adc1c211c`. The combined mapping at
`152d1d8f4540ea2fa22274127cb49348f7e0b2cf` joins both interfaces once,
without another episode multiplier. This does not establish whole-process
or whole-pipeline capacity.

This is a bounded independent source review for #119 / #153 of the selected
post-registration library constructors and `other_callbacks_and_shutdown`
interfaces. The initial library target was
`74d9b9200a50baf5292a0b308cdb4b079bb4a5f2`; its complete-stored-contract
justification required repair. The callback target is
`95d1464c5a27b1a574c243da04726b5adc1c211c`. The exact final inputs and finite
audit are in the [review packet](../evidence/retained-library-callback-demand-review-20261023/).
Selected reviewer: GPT-6 Astra / Extra High. Runtime model/effort confirmation
and token/cost telemetry are unavailable.

## Material finding and disposition

The original library ordinary-constructor table charged `cty_apply` as though
its input had at most 1,024 complete stored slots. Its accompanying argument
only bounded a callable skeleton and separately admitted 32,768 stored slots
for generated `Cany` contracts. A skeleton bound does not charge `bv_vars`,
dead `bv_subst` keys/values or the free-variable prepass. The initial argument
therefore did not establish that table row. No concrete execution exceeding
the final vector was found, and the acceptance does not rely on unused
coefficient slack to excuse the missing bridge.

The repair distinguishes the actual callable origins. Direct program bodies
use explicit source routines, recursive/local replacements, datatype
constructors and the fixed Boolean/function/tuple adapters. Generated
proposition wrappers are `RLnone`; `restore_rs`'s lsymbol association cannot
select them. Cloned wrappers remain `Cany`, and the selected cloned targets
contain no explicit program definitions. Name spelling alone is insufficient:
`Typing.lsym_or_lemma` automatically tries `tick_lemma q`
(`typing.ml:944–947`). The call-origin argument must also cover that fallback
against the actual source program applications.

The retained declaration census gives the stronger disjointness check: every
identifier spelling in an explicit program declaration is absent from the
generated proposition-wrapper base names. Use/clone namespace construction
preserves those names. Consequently an allowed save-origin failure in an
earlier lookup cannot make the suffix lookup return a generated `Cany`.
This does not assume that normal namespace lookup always succeeds, and it
does not introduce another escape charge.

For the selected original callable annotations, `Typing.type_fmla/dpost` and
`Dterm.try_term` build lexical formulas; bound/branch/quantifier closing starts
with `bnd_new` and an empty `bv_subst` (`term.ml:785–795`). The selected
two-argument mapping uses fresh epsilon/forall closes (`:1483–1497`). There
are no old-state substitutions. Generated signature posts also close fresh.
The sole implicit unannotated `RKnone` post is the short, binder-free
`real.RealInfix.(=.)` result after opening its scalar equality post.

At most four source quantifier/ensures binder records per outer program
declaration, two mapping records, one signature record and one implicit
reserve give eight records with at most sixteen `bv_vars` keys each. The
complete decomposition is
`512 + 64 + 32 + 8 + 16 + 8×16 = 760 < 1,024`, with no saved-substitution
entries. `rec_fixp` retains the `Cfun` annotation lists and adds one DECR
precondition; its replay does not accumulate DECR terms. An instantiated
`cty_apply` result is attached to an expression, not stored back into the
callee. Larger generated/cloned contracts are charged in their separate map
category. This repairs the exact premise used by the ordinary table while
leaving the process vector unchanged.

The first audit attempt subsequently found an inaccurate witness endpoint:
`pattern.ml:16–170` described a file ending at line 163. The excerpt and its
hash already matched the clipped source bytes. The author corrected the
declared range to 16–163 before the resumed audit; no source payload or
vector equation changed. This finite source-correspondence finding is
distinct from the semantic stored-contract repair above.

## Library source closure

The prefix association lemma is essential. Before the first Ident wrap,
registered identifiers distinguish the selected physical ts/ls/vs keys.
The private restore maps install associated immutable payloads. Interrupted
`set_key_data` can retain the matched old pair, leave no data, or install the
matched new pair; resize copies a whole ephemeron container. A weak miss or
lost insertion is permitted. The argument does not assume permanent physical
type canonicality after failed operations. `rs_of_ls` is private and limited
to the fixed adapters; other selected `RLls` constructors make fresh logical
symbols. `rs_dup` rejects `RLls`, so it does not replace a logical symbol's
contract with an arbitrary body.

The four retained libraries have nullary user type heads, no aliases,
mutable regions, exceptional contracts or old-state terms. The explicit
recursive groups are singletons, and no recursive body contains a recursive
group. Original callable types stay within the stated 64-node envelope;
failed `ty_match` may build its separate 4,096-node diagnostic type.
Generated `Cany` cloning renames existing binders and saved entries rather
than adding an unbounded saved-substitution layer. The general complete
stored size of a diagnostic expression is deliberately not exported.

Effect repair compares the effect and mask (`expr.ml:1238–1249`). In this
family its changing support is limited to sixteen fixed source read
variables, two source type variables, and Boolean ghost/mask components.
The formal removal and source substitutions are fixed; recursive results
have scalar masks. The read/spoil operations are monotone on that finite
support, and fixed ghost propagation is monotone. The 20-change bound and
32-pass allowance include initial construction, recursive replacement,
final conversion and the at-most-two initial notation probes. Resolved
`Capp` replay calls the selected routine without another overload search.

The other ordinary categories charge cloned-contract maps, direct typing and
reification, failed type operands, pattern/call-graph work and lower tuple
calls. Explicit source contracts have only the bounded binder origins above;
declaration `pd_syms` scans collect distinct generated identifiers rather
than multiplying by all obsolete stored occurrences. Logical call-graph
closure subsequently operates on arrays/existing identifiers. The selected
ordinary tuple keys are zero and two. Eager in-body type diagnostics remain
in these library charges: callback payload suppression does not erase a
printer already called inside a producer.

All five lower integer memos are charged on every call, including every
failed prefix. In Ident/Hsty order, the transitive `its`, `rs` and `pd` lower
costs are `(3A+2,A)`, `(5A+5,4A+2)` and `(8A+7,5A+2)`.
The two publication bodies' lower children cost `(10A+10,6A+3)` per J.
Direct publication costs then produce `(10A+12)J` Ident and `(7A+4)J Hsty.
`create_data_decl` uses type equality checks, not an additional type-match
diagnostic instantiation. No lower memo receives a separate resize budget or
another escape allowance.

Hsdecl counts prospective declaration constructor entries, including unique
goal products and failed alternatives; it does not relabel path publications
as declarations. Hstdecl includes repeated `use_export` requests, even where
no new module is ultimately used. Selected nonempty library paths, ordinary
cloning and lazy tuple-module construction use `vc:false`; `add_pdecl` cannot
reach `Vc.vc` on those paths. Theory/Pmodule construction and their persistent
sets do not write Task.Hstask or Task.Stdecl.Hcpt. The two Task zeros have
source-route support, rather than an assumption that a cache remains warm.

## Callback, save and shutdown closure

The selected idle handler protects `build_prover_call` and observer update,
including the Driver lookup/preparation/printing/send sequence. With the
accepted stack-trace flag disabled, it forwards any producer exception only
as `InternalFailure e` (`controller_itp.ml:517–536`). The session wrapper
updates status and invokes the concrete GNAT parallel callback. That callback
logs a constant `internalfailure` status and forwards only `Done`
(`gnat_checks.ml:62–111,1049–1084`). Its other statuses are discarded.
The serial `Gnat_main.interpret_result` exception-printer branch is not reached.

An update/logging failure outside the trap is a new scalar/service or save
exception. It does not carry the discarded logical payload. The inner
Sys_error callback can fail into the outer idle trap once; failure in that
outer handler can escape, with the same secondary-error classification.
Pending-signal replacement and `Fun.protect`'s finally wrapper do not restore
a discarded producer exception. This establishes payload exclusion for
failed preparation prefixes; it assumes neither successful preparation nor
the impossibility of logical producer exceptions.

Ordinary result processing is scalar; the accepted `get_model=None` control
excludes the model parser even for model-looking response text. The attached
Per_Check leaves have the final `split_goal_wp_conj` parent and no child
transforms. Forest preservation excludes further splitting; the failed
selection continuation cannot create CE goals while CE is off. Session
proof-attempt/status records are not logical Task or declaration constructors.

Save traverses the immutable raw proposition forest. Its retained shape
result excludes Tcase/patterns and gives variable-valued saved substitutions.
SV6 visits Dprop only; the separate Dlogic context does not defeat that
restriction. Bound/quantifier opening reuses types and contributes only the
already imported save-binder Ident registrations. `save_ident` reads an
existing restored path or `id_string`; it does not call Pretty. ShapeTooLong
and explanation Exit are locally consumed. Other shape/task/session
sentinels and I/O/container failures have constant, string or scalar payloads.

Ending performs the same charged save, reads status/statistics/extra-info,
and formats JSON. `proof_script=None` excludes manual command construction;
no CE goal means `session_find_ce_pa=None`, excluding giant-step RAC.
Terminal reporting reaches the scalar/error family established by these
source leaves. The earlier exception-prefix and Sexplib results are reused
for dispatch and registry preservation, not as an exhaustive reachability
proof they did not provide. A failed registered printer is suppressed and
dispatch continues on the original input, not the printer's secondary error.
No reachable input selects a logical Pretty branch.

The accepted exit family contains scalar Debug Stats, Format flushes and
channel flushes. The registered-stat callback list stays empty. The external
server route does not install the internal-server exit callback. No retained
formatter or hook contains a pending logical printer. Additional flushes or
partial hooks therefore add no six-owner constructor demand. Their other
resource and native-service obligations remain separate.

## Accepted interface and evidence limits

For each of the five attached processes let `E=3N+e`, with the one global
`e≤2`, `A=max(I,38678)`, `K=2I+38679`,
`J=2E(K+4698+1)+128K+e(K+1)`, and `X=2E×807447`.
The lookup vector is:

| Owner | Increments upper | Requests upper |
| --- | ---: | ---: |
| Ident | `2^24 X + (10A+12)J` | 0 |
| Decl.Hsdecl | `4X+J` | `4X+J` |
| Ty.Hsty | `2^24 X + (7A+4)J` | same |
| Theory.Hstdecl | `2^21 X + 2J` | same |
| Task.Hstask | 0 | 0 |
| Task.Stdecl.Hcpt | 0 | 0 |

`other_callbacks_and_shutdown` is the zero six-owner vector after removing
the separately owned lookup, preparation, request-printing and save-binder
work. Both exports are process-scoped and must be joined once. They do not
renew e, the two save-entering callbacks or the three-save upper bound.

The resumed independent audit passed in **2.483356 seconds**. It checked
109 frozen revision/path identities, all 130 source witnesses against 40
complete archive members, fifteen process/escape calculations, seven tuple
call trees, and all five combined mappings. It also independently checked
the 59-program-declaration/173-proposition-name disjointness and the four
source binder-record ceiling. These finite checks support the reviewed
source argument; they are not a name-resolution or OCaml simulation proof.

The combined candidate supplies each lookup and callback vector directly,
then sums the named residuals with the existing shared demand. All five
exported counter/backing operand predicates fit. Its independent-acceptance
flag intentionally remained false at that frozen candidate; this report
supplies the review disposition. The whole-process and whole-pipeline flags
remain false. Earlier accepted components and backing-transfer reasoning
were reused, with no predecessor checker or root composition replay.

There were two audit attempts: the first stopped on the source-range finding
above (0.667270 seconds of observed command wall time), and the resumed
audit passed after the source metadata correction. No native target, solver,
proof or capture ran. The observed review interval was 2,500 seconds,
including author-repair waits and context handoff, before final commit
preparation; it is not active compute time or a total-task measurement.

The source arguments remain reviewed reasoning, not machine-checked OCaml
simulations. The fixed-input/source-native relation, immutable typed state,
guarded mutation, native service behavior and first-counter-violation prefix
remain necessary. The root's combined demand must close that prefix across
all contributing stages. These six owners do not establish other counters,
memo/table owners, strings, stack, physical service sufficiency or universal
current-grammar coverage. Whole-process/pipeline capacity and the complete
#119 rule remain open. No Oracle, production tool, pin or admission change,
aggregate RAM gate, GitHub write, CLI-memory update or nested agent was made
by this review.
