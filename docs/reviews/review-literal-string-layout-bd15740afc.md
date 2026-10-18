# Independent review: cold Standard.String size helpers

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119)
and [#131](https://github.com/berkeleynerd/silver/issues/131).

**Disposition: accept the bounded exported results; one narrow source
description finding was corrected and confirmed.** One cold ordinary Standard.String
conversion creates exactly two size helpers. They are initially gimplified,
remain registered through Main's initial lowering, and are discarded before
ordinary helper lowering, IPA body processing, RTL or emission. The frozen
XVE paragraph described the wrong field-size route; the actual route still
adds zero helpers. The separately reviewed correction changes no exported count.

## Exact inputs and scope

The frozen target is `bd15740afc3453be73f176887724bfbe78da60df`, reviewed
in the clean isolated branch `review/literal-string-layout-bd15740afc`.
Inputs are the [research note](../research/retained-literal-string-layout.md)
and its [evidence packet](../evidence/retained-literal-string-layout-20261018/README.md):
`README.md`, `interface.json`, `source-manifest.json`, `check.py` and
`check-results.json`.

The parent integrated the leaf as `4f640ec4f8` and supplied the single
documentation hunk in `696a8a995d3841980c63e11d40a3869b23ff1eb3` for focused
confirmation. That correction was reviewed separately against the source
branches below. This does not expand the frozen target to later numerical
integration or other parent changes.

The review followed the applicable AGENTS, Oracle, owner-authorized #119
research scope and review bookkeeping. It reused the accepted Main ingress,
literal frontend and warning-map results and the #131 correction that global
scope does not exclude self-referential size helpers. The source basis remains
GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, selected Linux x86-64/LP64
behavior, and the retained invocation. Installed behavior correspondence is
an existing premise; this review supplies no new binary attestation.

I inspected the actual folder, layout, Ada constructor, graph and counter
branches. The focused replay verified all 21 complete source identities and
nine historical Silver inputs at
`6b6e6bea3edc819434893bf496242dd2728830b9`. I additionally checked
`gcc/ada/gcc-interface/utils2.cc` against that revision's retained native-ingress
manifest while inspecting `build_unary_op`'s ordinary indirect-reference path:
122,255 bytes, SHA-256
`c8292ebae64848cb3005523afe82d1dabd1c25422c96fb4421c3b27da6b429af`, Git blob
`3604d4df761cb702c326366f3ba6349fb37f4fc6`, all matching the retained pin.

## Source assessment

The complete ordinary entity cache returns the same converted String on
subsequent profile/type references (`decl.cc:400–445`). String does not take
the incomplete/private or cloned-record exceptions. This gives one cold
conversion per selected compilation independently of C, N, repeated calls,
literal payloads and which output procedure occurs first. It does not count
every other imported constructor. Separate compiler invocations start their
own process state; the claim does not identify counters across processes.

Fresh Standard entities have zeroed flags, and Positive's setup does not set
the fixed-lower-bound flag. Positive retains its signed Integer base Esize,
so both bound fields are signed 32-bit despite its positive RM bounds.
The readonly bound references through the ordinary P_BOUNDS indirection
introduce neither side effects nor SAVE_EXPR.

For L=(u64)l, U=(u64)u and the signed comparison Q=(u>=l), subtraction
distributes over Q?U:L-1 under the actual no-side-effect and nonconstant-arm
guards. The false arm contracts to -1, then adding one yields zero.
The 32-to-64-bit width check prevents pulling the two-bound subtraction into
the narrow type. The conversion to unsigned 128 bits distributes, with a
constant false arm preventing its extraction again; multiplication by eight
preserves the conditional. I checked the relevant GENERIC conditional cases,
including comparison-arm, equal-arm, truth-value, constant-comparison,
min/max, nested-conditional and sign patterns. None collapses this expression
to a single bound. The more general GIMPLE-only rules do not apply here.
`multiple_of_p` checks both conditional arms, allowing bit alignment eight
to preserve the shape (`fold-const.cc:14230–14350,16378–16437`).

Both extents exist before the independent bit-then-byte `variable_size`
calls. Each stops at the conditional in `skip_simple_constant_arithmetic`
and takes the helper constructor. The placeholder walker stops at the outer
LB0/UB0 component references; `push_without_duplicates` uses
`simple_cst_equal`, so repeated occurrences do not add parameters
(`tree.cc:4469–4556`). Each helper has two signed 32-bit parameters;
the bit and byte return types have precisions 128 and 64 respectively.
Neither body calls the other.

The actual Character component remains self-canonical: its unsigned debug
copy does not replace it, matching component size/alignment does not produce
a replacement, and the nonshared index range returns before canonicalization.
The recursive canonical-array condition is therefore false. Subsequent
layout sees the existing TYPE_SIZE and returns. This excludes a second XUA
layout, rather than assuming that an array constructor never recurses.

XUT uses rep_level zero and advances its final variable ARRAY field through
the byte-size call B. With bit position zero, its raw sizes are 8+B bytes and
8*u128(8+B) bits. Rounding and conversion leave constant-sided chains to B,
which satisfy the helper CALL_EXPR cutpoint. The rep_level-one extra
`variable_size` route is absent, and TYPE_CONTAINS_TEMPLATE excludes the
subsequent Ada-size installation. The final UNCONSTRAINED_ARRAY_TYPE has no
TYPE_SIZE, excluding the common global-size continuation.

### Correction: XVE uses the pointer field's constant size

The frozen note says XVE copies the old variable field's bit-size call and
derives its byte size by constant division/conversion. The call does pass
`DECL_SIZE(old_field)` (`utils.cc:2655–2657`), but passing that argument does
not install it in the new declaration.

The variable field becomes a copied pointer type (`utils.cc:2619–2623`).
In `create_field_decl`, the only assignment of the supplied `size` to
`DECL_SIZE` requires `TREE_CODE(size)==INTEGER_CST`
(`utils.cc:3263–3274`), which is false for this old helper call. The explicit
gap position invokes `layout_decl` (`utils.cc:3323–3345`); its unset-size
branch copies the pointer type's constant 64-bit and eight-byte sizes
(`stor-layout.cc:693–696`). It does not take the byte-size division branch.
XVE's record sizes are also assigned directly and its record finisher is
not invoked. Thus XVE adds zero helpers for a stronger, simpler reason.

This is a nonblocking correction to the rationale, independently confirmed
from the pinned source. The parent corrected it in
`696a8a995d3841980c63e11d40a3869b23ff1eb3`; I confirmed the revised argument
and its unchanged interface. The finding is fixed. No broad rerun or new
native observation was needed. The offline landmarks do not detect this
mistaken explanation, which is why their success alone is insufficient.

### Registration, removal and counters

`finalize_size_functions` allocates each function structure, gimplifies it
and finalizes its graph node before initial analysis. `gimplify_function_tree`
reuses the allocated structure (`gimplify.cc:21967–21978`). Ada's ordinary
subprogram finalizer registers Main without first gimplifying it
(`utils.cc:3875–3892`). Both helper gimplifications therefore precede Main's.

The selected argv does not enable keep-inline-functions, instrumentation,
sanitizers, OpenMP/offload or debug output. The private declared-inline
helpers avoid the O0 static-function force-output arm. Their constructor
does not set preserve/used attributes, aliases, nesting or asm references;
attribute processing does not make them needed. They are finalized through
`finalize_function`, not the reachable `add_new_function` queue.

The accepted Main body and constant bounds-pool initializers create no call
or address reference to either helper. The graph walks actual GIMPLE
calls/references and stops initializer traversal at types/declarations.
Type-size metadata alone does not enqueue them. Consequently neither helper
is analyzed or receives `all_lowering_passes`; both remain registered until
the initial unused-symbol removal loop, after Main's lowering, where their
null aux and absent referrers/asm references permit removal.

The two registrations consume +2 symbol UIDs and +2 symbol orders; the two
function structures consume +2 function-definition numbers; construction
consumes +2 private SZ sequence values. Node removal unlinks/releases nodes
without rewinding these counters (`cgraph.h:3138–3196`,
`function.cc:4812–4867`, `stor-layout.cc:155–265`). Live helper nodes after
removal are zero. That does not establish zero earlier summary-hook work or
zero contribution to maxima, allocation, declaration IDs or label consumers.

## Remaining joins and evidence

R, helper warning-map puts, allocation-event totals and allocation bytes
remain null. Initial helper gimplification and two live graph nodes must be
joined to incoming shared-pool state; persistent counters must be carried to
their graph, name and CFI consumers. Other imported declarations and any
summary hooks before removal remain obligations. The five aggregate
conditions remain unknown. No complete capacity/admission result follows
from this review, and no gate should be restored from helper non-emission
alone.

One focused offline replay passed all 26 checks in 0.098968 seconds:

```sh
python3 -B docs/evidence/retained-literal-string-layout-20261018/check.py \
  --output /tmp/review-literal-string-layout-bd15740afc-check-results.json
```

The scratch result completed at 20:19:16 UTC on Linux 7.0.14 x86-64,
glibc 2.43. Its `round_start_utc` and `round_elapsed_seconds` remain stamped
with the implementation worker's start, so they are not reviewer elapsed
measurements. The retained worker result reports 787 seconds; no prior
successful native run was repeated. This replay checks identities, landmarks
and the explicit open interface; it does not execute GCC or prove its C++
semantics. Native compiler/prover/debugger runs: zero.

Reviewer settings selected by parent: GPT-6 Astra / Extra High. Runtime
confirmation, token usage and cost are unavailable. Review began at
20:15:50 UTC; assessment, correction confirmation and initial report preparation
completed at 20:21:39 UTC, 349 seconds later. Intended
outcome: challenge the exact cold helper count, repeated-call composition,
discard boundary and persistent counters. Achieved: bounded acceptance plus
the XVE source-description correction. Only this report was edited; parent
owns integration, numerical work, issues and durable memory. CLI memory was
not updated. The child harness goal query returned null at start and handoff;
the parent reports #119 active. No goal state was changed here.
