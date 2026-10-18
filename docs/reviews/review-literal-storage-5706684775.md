# Independent review: literal synthetic storage and collector callbacks

2026-10-18. Owner-authorized research
[#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance of both source packets and their aggregate
attachment; no material finding.** The synthetic packet supports its 167
direct GGC events and eight ordinary request ceilings. The literal collector
extension supports zero additional GGC events from callbacks and the retained
104-byte ordinary request per value-expression marker invocation. Their
attachment preserves the unresolved construction, shared-container, counter
and complete-collector obligations. It does not complete #119.

## Exact inputs and review scope

The independently assessed source targets are:

- Synthetic storage: `57066847755f29d677736966bed8d897e715ca99`, based on
  `a409ff9db1e7a290bc12dd415d0d9518c93e4652`. Inputs are the
  [source argument](../research/retained-literal-synthetic-function-storage.md)
  and its [evidence directory](../evidence/retained-literal-synthetic-function-storage-20261018/README.md):
  `README.md`, `derive.py`, `interface.json`, `check.py`, `check-results.json`,
  `source-manifest.json` and `matcher-flat-patterns.json`.
- Collector extension: `15f41d0d1ad54947a7bacb403c7727223407efae`, based on
  `28697404fa1971ed310d19a7ab434e593ca2b075`. Inputs are the
  [source argument](../research/retained-literal-collector-callbacks.md)
  and its [evidence directory](../evidence/retained-literal-collector-callbacks-20261018/README.md):
  `README.md`, `derive.py`, `result.json`, `check.py`, `check-results.json`
  and `inputs.json`.

The parent subsequently supplied attachment
`51e289378c7bb0f57b4e91359f70d8e9f8b7cba1`, against
`81b717df9e41690cc11cd25114196e53d45b3255`. I reviewed its seven-file diff:
the aggregate `compose.py`, `check.py`, `inputs.json`, `result.json`,
`check-results.json`, [README](../evidence/retained-literal-pipeline-20261018/README.md)
and [pipeline note](../research/retained-literal-pipeline.md).

The initially clean isolated branch is `review/literal-storage-5706684775`,
based at `81b717df9e`; only this report is edited. Attachment inputs were
read directly from the frozen Git objects. The 15 new aggregate pins were
compared with their exact source-target bytes and their byte-length/SHA256
entries. All matched. This distinguishes the inspected attachment from
uncommitted or later integration work.

I read the applicable AGENTS and Oracle, review bookkeeping, and relevant
assurance/trusted-boundary excerpts. I reused the accepted two-helper shape,
generated-body frontier, Main lowering and generic collector census at their
documented scope. The selected source family and O0 Linux x86-64/LP64,
ordinary SysV target, no-debug/no-instrumentation and disabled
checking/statistics premises remain necessary. GCC source is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; source roots are those in the
packet READMEs/manifests. Relevant installed behavior matching that source
remains an inherited premise, not a new observation from this review.

## A. Synthetic function storage

**Accepted within its stated interval.** Three `allocate_struct_function`
calls cover the empty elaboration function and both helpers. Only the two
helpers enter initial gimplification. Original declaration/type/body
construction, their earlier private copies and folding, and the two cgraph
nodes remain outside this numerical slice. Removal before ordinary lowering
does not erase allocations, registrations or persistent counters.

I followed function/EH/machine construction, target switching and alignment
parsing. The default options and SysV register state exclude target-global
creation, register reinitialization and nondefault optabs setup. At the
selected O0 defaults the four alignment strings remain null, so `parse_N_M`
does not even construct its local static cache. Scalar parameter/result
relayout does not create variable-size metadata. Parameter scanning uses its
two-element ordinary vector, without hidden result, callee-copy, alloca or
cleanup construction.

The imported scalar bodies retain two bound conversions and two extent
operations, with one extra conversion and multiplication in the bit helper.
Reassociation and arm inversion preserve the charged arities and do not
duplicate a bound occurrence. The 3W whole-body transfer therefore supplies
54 copies for W=18. I checked the scalar materialization, nonvoid return,
conditional assignment distribution and outer-BIND routes in `gimplify.cc`.
The destination return variable is reused across the arms. Its conditional
context is popped before the enclosing return, excluding an early-return
predictor tuple. The 28-tuple allowance includes all arm assignments, labels,
gotos, conditions, returns and binds. The Ada gimplification hook adds no
special transformation for these scalar helper operations.

The zero-request folding claim needs more than the extracted pattern list.
I inspected `fold_stmt`, `gimple_extract`, `gimple_resimplify1/2`, the matcher
definition callback, relevant `match.pd` operator lists and predicates, and
the legacy assignment folder. `no_follow_ssa_edges` returns null, and
`get_def` honors that veto. Mandatory nested arithmetic/conversion patterns
cannot recover the new SSA definitions. The remaining flat and optional
conversion patterns either have an unrelated root or fail the selected
constant/type/identity predicate. In particular:

- The widenings are not useless conversions. Addition/subtraction has no
  zero identity, repeated operand or visible negation to rewrite; constant
  subtraction was already normalized by the predecessor.
- Multiplication is by eight, excluding zero/one/minus-one and Boolean
  product rules. The operand has no applicable bit-mask information.
- The comparison uses distinct signed-32 parameters; pointer, floating,
  constant-bound, repeated-operand and Boolean cases do not apply.
- A possible `1-x` reassociation reaches the Boolean-range predicate, but
  its fresh nondefault SSA name has no range information. The existing
  global query supplies varying range, and its fixed `int_range<2>` and
  `int_range<1>` storage does not allocate. The all-bits fallback also
  allocates nothing. Fixed-width wide integers fit inline storage.

These failures precede replacement construction. There is no speculative
tree or tuple from them. Successful operand canonicalization preserves
arity and mutates existing tuples; `maybe_build_generic_op`'s constructing
cases are absent. Scalar copies do not acquire a constant initializer from
the mutable unnamed return temporary. I therefore accept zero extra folding
requests, rather than treating failed or discarded folding as free by
assumption. The 138-pattern inventory is an audit aid, not the semantic proof.

The initial SSA hash stays empty and its capacity is 31. On release,
`delete_tree_ssa` and vector disposal allocate nothing; the hash-empty shrink
guard requires capacity greater than 32. The two GGC hash controls register
two singleton finalizers; raw nodes/tuples and selected vector elements add
none. Reclamation timing is not used to subtract lifetime allocation events.

The independent arithmetic projection agrees: 167 GGC requests, 13,336
caller bytes, 17,216 bytes after separately rounding each object, and eight
ordinary requests totaling 584 caller bytes. These are ceilings, not a
peak-RAM or page total. The longest covered private-name format needs 16
bytes including NUL. Ten possible identifier insertions, incoming temporary
serial room, eight new DECL_UIDs, three function-definition increments,
condition IDs and the two singleton registrations remain explicit interface
demands. The depth-one context pool and cfun stack are shared extension
allowances and must be deduplicated by ownership in a later total.

## B. Literal collector callback extension

**Accepted for the selected literal Main process.** I checked the new graph
against the existing setter inventory and callback/destructor families,
without transferring the null process's event count or backing capacities.

Main has no parameters and returns void; its fat descriptors have constant
size. Imported Put/Put_Line profiles have IN parameters and no translated
bodies here. String construction supplies types/fields, not a variable-sized
local object. The empty elaboration does not gimplify. Both size helpers have
fixed scalar parameters/results, avoid the Ada named-result transform and
never reach RTL. These facts exclude debug renaming/Out-parameter setters,
VLA and callee-copy setters, result-address/static-chain setters, and the
unselected OpenMP/other-frontend transformations. Tree/body copying only
preserves an already present value expression, so it preserves emptiness.

`value_expr_for_decl` is initialized even when empty. In `gt_value_expr_mark`,
the local non-lazy hash therefore still allocates 13 pointer slots: 104
ordinary bytes. Empty traversal prevents recursive tree walking, insertions
and growth of the 16-element inline vector. Its backing is freed on return.
No actual collection count or cumulative ordinary-allocation bound is
inferred from this per-call fact.

The extra selected tree, gigi, function/EH/machine, SSA and graph objects fall
within the previously inspected marker/destructor families. I found no new
selected owning destructor or custom marker with allocation effects. Hash
removal and scalar map values, including `nowarn_spec_t`, retain their
allocation-free destruction; loop-exit removal only unlinks/frees existing
objects. Generated/custom marker traversal and weak-cache clearing do not
construct replacements. The default target and no-plugin/PCH/LTO/debug
selection excludes the separate families with different behavior. This
accepts zero additional GGC callback events, while leaving finalizer counts,
page backing, counter bounds and complete collector lifetime open.

## C. Aggregate attachment

**Accepted without broadening either leaf claim.** The context pins both
packets and their source manifests, and the collector's frontier/layout
objects must equal the aggregate's objects. The callable synthetic result
must equal the complete frozen export. Additional checks join its three
structures, two gimplifications and three function-definition increments to
the accepted generated-body frontier. The 167 events do not include the
two cgraph nodes already charged elsewhere.

The collector receives the actual source bytes, and its identity/counts and
complete marker interface are checked. Total events, finalizer population
and backing remain null; complete collector lifetime stays false. The new
local predicates check individual requests only. No shared-context/cfun
allocation is added to a process total, and counter no-wrap remains false.

I compared the retained aggregate result recursively against its base. The
new fields preserve the previous substantive results and all five unresolved
predicates: native varpool/shared tree pool, graph/summary lifetime, Main
assembler/object interface, GAS/BFD storage and linker representation. The
separate conservative 5,000-call relocation failure remains. The aggregate
does not borrow 40,098 null events, invent a full allocation sum, introduce
a RAM admission gate or change production admission.

## Evidence and round record

The retained successful checks were reused, not rerun: synthetic 36 checks
over 44 sources and 26 historical inputs (0.214 seconds); collector 17 cases
over 45 inputs (0.022742063 seconds); attachment 109 cases (4.907963480
seconds), including fourteen new negative interface cases, and default
generation (3.880576852 seconds). Its 128 repository pins, 293 direct source
identities and 45 nested collector inputs overlap and are not additive.
The accepted 4,929-file census was reused; this review did not repeat it.

New execution was limited to Git/source inspection and one focused static
comparison/arithmetic check over the frozen records. The latter verified the
15 new pins, both attached leaf outputs, request sums/rounding, maximum name
length, null collector totals, false no-wrap and unchanged five unknowns;
it passed in 0.208634 seconds on Linux x86-64. Initial inspection snippets
used incorrect JSON container/key assumptions in their reporting code; those
were corrected before retaining this result. They did not identify a packet
failure or cause a broad rerun. No native compiler, proof, build or test ran.

Selected reviewer: GPT-6 Astra / Extra High, as assigned by the parent.
Runtime-confirmed model/effort, token counts and cost are unavailable.
Review began at 20:51:48 UTC; source and attachment assessment was complete
by 20:55:33 UTC (3 minutes 45 seconds), followed by report preparation.
The intended outcome was independent assessment of the two bounded source
arguments and their frozen attachment; all three are accepted in scope.
No implementation rework was required. No GitHub, publication, CLI memory,
Oracle, language, toolchain or production source state was changed. The
global #119 objective remains unfinished; the parent owns integration and
the remaining construction/lifetime/collector work.
