# Null Main across the whole-unit IPA passes

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies a **shape-preservation transfer**, not a complete allocation
bound, between the null body's [initial SSA](retained-backend-gigi.md#the-same-null-body-through-cf-eh-cfg-and-initial-ssa)
and later per-function passes. It inventories every top-level IPA registration
in the selected GCC pass schedule. It does not infer that O0 skips IPA.

## Incoming unit and configuration

The local transfer assumes the completed gigi/cgraph input contains one
ordinary, public, defined, nonvirtual function Main, with no parameters,
calls, symbol references, aliases, thunks, nested functions, constructors,
destructors or target/SIMD/strub attributes. Its executable body is the null
path with at most two labels and a void return; its sole SSA use is the
default virtual memory name. It also includes the dummy global described
below. No other function body or variable initializer is pending.

The [null gigi symbol join](retained-native-expansion.md#null-mains-incoming-ipa-symbol-graph)
now establishes that complete incoming unit, including builtin/runtime
declaration registration, discarded empty elaboration, generated-size-function
exclusion and the two symbol-analysis sweeps. Its separately reviewed
configuration and null-body premises remain required. This transfer must not
be applied to literal output, which has a call, or to general Main.

Use the recorded native O0, non-LTO, no-plugin configuration, without
profiling, coverage, OpenMP/OpenACC, transactions, analyzer, strub, SIMD-clone
or per-function optimization overrides. The standard O0 option table leaves
IPA profile/pure-const/reference/modref/ICF and vectorization disabled
(`opts.cc:584–693`, `common.opt:2179–2217`). The absence of an explicit option
initializer means zero under the already pinned option-generator rule;
Ada's initializer does not enable these fields. `flag_strub` starts at -3;
the strub-mode gate converts it to zero when no enabling attribute was seen
(`common.opt:3110–3136`, `ipa-strub.cc:1740–1762`).
The SIMD-clone setting starts at `OMP_TARGET_SIMD_CLONE_NONE`
(`common.opt:2505–2507`). These are effective-configuration premises, not
claims that ambient launch configuration has already been constrained.

## The null unit has a global symbol

`gigi` unconditionally initializes `first_global_object_name` from the
compilation unit's defining entity (`gcc-interface/trans.cc:367–370`).
Consequently `gnat_write_global_declarations` creates a dummy VAR_DECL of
void type, its private identifier, and a varpool node. It sets HARD_REGISTER,
STATIC, definition and force_output, with no initializer
(`gcc-interface/utils.cc:6460–6490`). This happens even without debug output.
The declaration-free source therefore does **not** imply an empty varpool.

For the stated input, retain one function node and one variable node. The
dummy is not Main's `.MEM` declaration and is not a source variable. Its
force_output flag makes `all_refs_explicit_p` false (`cgraph.h:3526–3533`),
so single-use propagation places it at BOTTOM without a map insertion.
Its name/DECL_UID and the global-declaration tables remain gigi/setup costs.
The referenced gigi symbol join excludes every other symbol ingress for this
null configuration; the body's emptiness alone would not establish that fact.

## Complete top-level schedule partition

`passes.def:49–195` contains 39 top-level registrations in the small,
regular and late IPA lists. Repeated target-clone and free-summary instances
count separately. The offline checker inventories that exact order and every
parent group; it does not treat registered-but-skipped pass objects as absent.

| Registrations | Selected behavior |
| --- | --- |
| Auto-profile offline/normal; tree-profile | Gates false without profile/coverage inputs. |
| strub-mode; strub | Mode converts the unused default to zero; both executions excluded. |
| build-SSA; local-optimization groups | Run their per-function subpasses; use the separate null-body derivation. |
| OpenACC parent | O0 gate false; nested PTA/kernel transformations are not entered. |
| Increase-alignment; TM | Vectorization/section-anchor or transaction gate false. |
| Lower-emutls | Selected x86 native TLS support closes the gate. |
| asm-lgen; asm-wpa; ODR; locality-cloning | LTO/WPA gates false. |
| Analyzer | `flag_analyzer=0` closes the gate. |
| IPA profile; ICF; devirtualization; CP; SRA; pure-const; reference; late PTA | Their selected option/O0/non-LTO gates are false. |
| Free-language-data | Executes its non-LTO early-return branch; retains constructor and inheritance-cache cleanup work. |
| Early/late target-clone; late SIMD-clone | Execute or test their target gates, but absent attributes exclude cloning; no call redirection at O0. |
| Early/whole-program visibility | Execute; update symbol properties without adding nodes, references or body statements on this input. |
| Remove-symbols and reachability TODOs | Execute; retain the two required symbols, with no outgoing dependency traversal. |
| Function-summary; early/late free-summary | Allocate/register or release summary infrastructure; no analyzed optimized body or new function. |
| IPA inline | Executes sorting, cache and worklist setup; creates no inline candidate or body copy. |
| IPA modref | Summary callback visits Main but returns at disabled `flag_ipa_modref`; execution returns with no summaries. |
| Ctor/dtor merge | Either target gate skips it, or both empty lists exclude generated constructors. |
| Single-use; COMDAT | Run their small symbol analyses; no executable change or new symbol. |

The disabled rows are pinned by the complete sources in the
[evidence bundle](../evidence/retained-backend-ipa-20261018/README.md).
Their pass object construction/registration is fixed manager work. Ordinary
option-setting, target and source correspondence still apply.

## Active paths and retained work

**Language data.** `free_lang_data` constructs its local `free_lang_data_d`
before testing the non-LTO condition. That object's two vectors reserve 100
tree pointers each and its visited hash retains its ordinary initial
allocation (`ipa-free-lang-data.cc:53–73,1119–1135`). The early return excludes
the large declaration/type traversal and simplified-type maps; it does not
exclude those constructors. `rebuild_type_inheritance_graph` only clears
existing inheritance/cache state (`ipa-devirt.cc:2852–2861`). Later reachability
may construct a fresh empty ODR hash with request 23. Main and the dummy are
not virtual, so its scan inserts no ODR types (`:2352–2408`).

**Visibility and reachability.** Visibility creates a noninterposable alias
only for a recursive call edge; none exists. Other alias/COMDAT/TLS branches
have no selected input (`ipa-visibility.cc:625–924`). The whole-program variant
skips variable-flag discovery at O0 (`:949–955`). Reachability retains Main
as an externally needed definition and the forced dummy. Its three hash sets
are still constructed; only `reachable` receives entries, at most two. The
aux-linked worklist visits at most those two nodes. There are no outgoing
references, call edges, abstract origins, versions, clones or COMDAT partners
to enqueue (`ipa.cc:310–536`). The removal traversal creates no body or symbol.
The same bounds apply to each reachability invocation, not just the final one.

**Target cloning.** At the early/late entries, absence of `target_clones`
returns before clone parsing/construction (`multiple_target.cc:259–269`).
The target-version alternative also has no enabled function version. At O0,
`redirect_to_specific_clone` returns before inspecting calls (`:431–434`).
The dispatch vector stays empty (`:550–611`). SIMD clone expansion finds no
`omp declare simd` attribute; the default NONE setting excludes implicit
creation, and it returns before constructing a clone (`omp-simd-clone.cc:1956–1993`).
Target-clone's `TODO_update_ssa` is still dispatched. With no registered
replacement/name changes, the ordinary SSA updater's no-work branch applies;
the per-function composition must retain its manager/setup costs.

**Summaries and inline execution.** `ipa_fn_summary_generate` sets the
versionable property and allocates its three summary managers plus IPA
parameter/call hook infrastructure. Its final analysis guard is false for
Main (`ipa-fnsummary.cc:754–760,4698–4717`, `ipa-prop.cc:5211–5220`). Thus
empty summaries do not mean no allocation.

`ipa_inline` allocates a one-pointer order array and calls reverse postorder;
the absence of flatten attributes excludes its removal-hook/flatten path
(`ipa-inline.cc:2823–2918`). `inline_small_functions` still constructs an
edge heap, bitmap, an eight-pointer indirect-edge vector, removal hook,
second one-pointer order array and reduced postorder (`:2098–2162`). The
heap receives no candidate at O0 (`:2175–2187`); the body-copy loop is never
entered. Growth caches are nevertheless created, then released
(`ipa-inline-analysis.cc:127–146`). The two called-once sweeps likewise skip
Main (`ipa-inline.cc:2946–2960`). No call, inline clone, copied statement or
new function results from this IPA execution. Its later transform is still
queued and must be included below.

The postorder helpers retain their own source-derived small containers:
reverse postorder requests one stack record; reduced postorder requests one
pointer slot, one DFS-info record, a splay-tree header and at most one splay
node (`ipa-utils.cc:172–224,286–360`). Their scalar traversal indices stay
within this one-function input. Summary constructor backing, allocator
rounding, hooks and manager lifetimes still need the complete setup ledger;
these observations do not provide its missing all-phase byte/counter sum.

**The queued inline transform still runs.** The pass manager appends each
active IPA pass's nonnull `function_transform` to every noninlined GIMPLE
body, independently of whether its execute method selected any inlining
(`passes.cc:2723–2729`). IPA inline registers `inline_transform`
(`ipa-inline.cc:3423–3437`). Thus Main's pending-transform vector receives
one entry. The other selected active IPA passes have null transform hooks;
disabled passes do not reach this scheduling branch. `cgraph_node::expand`
executes the queue before its ordinary per-function passes
(`cgraphunit.cc:1865–1876`, `passes.cc:2311–2342,2362–2401`).

The transform's clone and callee loops are empty. `preserve_function_body_p`
checks only the clone list, so it does not save/copy Main's body. Existing
references are cleared, optional profile scaling changes only counters, and
the no-callee guard skips `optimize_inline_calls`. It sets `after_inlining`,
runs CFG fixup, and requests at least `TODO_update_ssa_only_virtuals`
(`ipa-inline-transform.cc:757–884`). The already derived null fixup changes
no statement/edge and requests no renaming; `update_ssa` therefore returns
before allocation (`tree-into-ssa.cc:3146–3151,3369–3385`). The extra queue,
transform invocation, fixup worklist header and manager/GC work remain paid;
its body contribution is zero. An independent source review caught and
corrected the draft's mistaken omission of this queued phase before delivery.

**Modref, constructors and coverage.** Modref's gate is unconditionally true,
so use its actual early returns, not a purported disabled pass. The summary
visitor calls `analyze_function`, which returns before creating summaries
when `flag_ipa_modref=0`; the later pass returns when both summary pointers
are null (`ipa-modref.cc:3122–3135,3390–3403,5577–5581`). The ctor/dtor pass
has two automatic 20-pointer vectors, but empty lists skip both helper
builders regardless of its target gate (`ipa.cc:1256–1326`). No profile or
coverage counters were generated, so `coverage_obj_init` returns at
`prg_ctr_mask=0`, before coverage objects or constructors are built
(`coverage.cc:92,1147–1159,1384–1407`).

**Single-use and COMDAT.** Single-use constructs a map but makes no insertion
for the forced dummy (`ipa.cc:1464–1553`). COMDAT constructs two maps with
request 251, inserts at most the two required symbols into its first map,
then returns at `!comdat_group_seen`; there is no group string, dataflow
propagation, section reassignment or body rewrite (`ipa-comdats.cc:235–297`).
Calling this path a skipped pass would miss the map allocations.

## What the join establishes

Under the incoming unit/configuration and per-function subpass premises,
these whole-unit IPA paths introduce **zero** functions, executable statements,
call edges, ordinary SSA names or variable initializers. They preserve the
null function's shape for the later per-function lowering argument. The
source-derived dummy variable remains separately charged. Neither native
diagnostics suppression proposal is needed for this IPA result.

This is not full backend capacity. The incoming symbol graph is joined, while
fixed/imported declaration and type allocation, complete manager/setup/container
lifetimes, generic verification/GC bookkeeping,
RTL and linker closure explicit. No compiler/prover/Lean execution is used
for this derivation. The offline check verifies source identity, schedule
coverage and the stated small cardinalities; it is not a compiler simulation
or a machine-checked proof of the handwritten path argument.

Independent source review found no further material shape issue after
identifying the queued-inline-transform correction above. It checked the
active visibility/reachability, inline execution, summary gates, dummy-global
single-use, COMDAT and no-clone branches under the stated premises. It did
not establish complete allocation lifetimes. The later incoming-unit integration
also checked declaration-versus-symbol registration, external-variable guards,
empty elaboration and no-call/EH dependency paths against the pinned sources.
The offline check covers 43 complete source files and 39 IPA registrations,
and binds its input cardinalities to the separate 39-file symbol-join result.
