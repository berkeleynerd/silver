# Native constant helper, annotation and descriptor review

2026-10-24 UTC. Independent critical review for #201 and #209 under #119.
Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model confirmation,
token usage and monetary cost are unavailable.

Reviewed author freeze: `99734327fd77d426fead054d7ba0e12999b00d8a`.
**Accepted at the claimed scope.** The #209 omission is independently
confirmed and its mandatory correction is accepted. No new material finding
or required author repair was identified. The classified constant-helper,
annotation and direct bounds-template exports do not close full F local
storage, dynamic F/Q, imported-entry construction or whole native capacity.

The [review packet](../evidence/review-native-helper-joins-20261024/README.md)
binds exact inputs and the independent audit. Review covered the updated
[research note](../research/retained-general-native-capacity.md), the complete
[helper argument](../evidence/retained-general-native-capacity-20261024/helper-joins/README.md),
its current export/checker and pinned source. The GCC revision remains
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, at the selected Linux x86_64 O0
configuration with checking/statistics disabled and the inherited
source-to-installed-tool correspondence.

## #209 correction and classified helper paths

The first kernel omitted the allocating suffix of
`range_cannot_be_superflat`, reached at `decl.cc:2771–2772`. Its Boolean
return does not make the call allocation-free. After endpoint walks find
literal bounds, it requests two supplied-type `UI_To_gnu` conversions and
the low-minus-one `size_binop`. The accepted endpoint-type dependency order
decreases on each walk; fixed Integer terminates it, and Positive/Natural
have literal endpoints. Thus at most `2Ta(Ts+1)` pointer-following iterations
are needed. A failed terminal classification returns before those allocations.

The selected terminal magnitudes fit three base-32768 digits. Supplied
signed 128-bit bitsizetype excludes the type-widening retry. Each conversion uses
at most thirteen constant requests, including temporary arithmetic results;
the final constant subtraction uses one. The mandatory correction is
`27Ta`, giving general coefficients **9/83/42/12**. It creates no Uint entry.
This repairs a missing accounting term without claiming an observed aggregate
bound violation. The original 9/56/42/12 output remains historical.

The Ss/Sa/Sl classification is a source-tree rule, with its earlier-type
dependencies. A source name with a known value or a known runtime String
length does not qualify automatically. Literal endpoints translate through
the supplied-type Uint path; static elaboration returns constants without
creating debugging variables or SAVE nodes. Source translation adds `26Ss+13Sl`.
The null-literal branch constructs 1..0 directly; nonnull literal bounds use
the selected literal-low and length paths. The legal String extent premise
keeps their final upper bound and size representable.

On the classified paths, array-bound conversions, range construction,
superflat selection and layout preserve INTEGER_CST operands. Native null/
superflat normalization is separate from #207's raw frontend layout
arithmetic. `max_value`'s declaration case is absent, `multiple_of_p` uses its
constant wide-integer predicate, and constant sizes avoid `variable_size`.
The existing residual entry counts therefore contribute `43Sa+33Sl` constant
requests, closing their tree-constructor component.

Constant binary/unary folding returns before the generated matcher, with a
possible final result conversion included. The scalar gigi binary helper's
five requests cover both input conversions, the two-request fold and the
result conversion. The constant conditional is handled separately: its two
arm conversions are charged, and the matching constant-condition rule returns
an existing arm. Earlier conditional patterns requiring an expression-shaped
test cannot match this constant test. There is no new COND_EXPR, SAVE-prefix
COMPOUND_EXPR or repeated-capture copy on this path. These facts do not
establish a general bound for recursive `generic_simplify`.

## Annotation and descriptor joins

The classified unpadded arrays have nonnegative constant TYPE_SIZE=8L and
the same rm_size, with L<=Integer'Last. At most two common-finisher callbacks
give `Qc<=2(Sa+Sl)`. Their maximum value 17,179,869,176 is below 2^35 and
signed 64-bit. `annotate_value` returns directly through `UI_From_gnu`; it does
not traverse a symbolic expression, retry a failed child, allocate a Rep_Table
node or cache record, or increment the dynamic-variable serial.

The signed 32-bit fast path or fixed five-digit conversion bounds each callback
by one Uint entry, five digits and 31 GCC constant requests. The conservative
T alignment callbacks remain. Incoming table state, append/index checks and
geometric backing are preserved, together with the separate #207 frontend
overlay. They are not supplied by the new logical callback counts. Including
annotation gives classified coefficients **35/188/150/12**, or a mixed
addition `26Ss+105Sa+108Sl` to the corrected general C. These terms replace the
matching symbolic tree charges; they are not a second disjoint allocation.

For the selected completed Standard.String XUB, the two Positive fields of precision 32
have offsets 0/4 bytes and size 32 each. `build_template` converts two constant
bounds; substitution is identity because the resulting leaves have no actual
placeholder. Constant validation returns an existing marker, and the fields
are not bitfields. The two-element sort invokes its comparator once. Computing
the two bit positions costs at most six constants; positions 0 and 32 exclude
the DECL_UID subtraction tie-breaker. Along with the two bound conversions,
the total is eight constant requests.

The final CONSTRUCTOR is 24 bytes and its element vector is 72 caller bytes.
The latter claim survives `va_gc::reserve`'s capacity normalization: the
retained GGC max-alignment struct has alignment 8 on this host, and its extra
order 9*8 supplies an exact 72-byte class. Reserve recovers four slots and its
actual `ggc_realloc` request remains 72. This is stronger than the earlier
coarse 512 rounding bound and was checked from retained `ggc-page.cc` source.
The resulting direct export is **416 caller bytes** and at most **5120
separately rounded bytes** per selected template call. Constant-cache vectors,
shared hashes, GGC page metadata and wide-integer workspace stay separate.
The two 16-byte element temporaries and 256-byte sort scratch are logical local
objects, not a complete native-frame or local-storage proof.

The six template call sites do not justify a whole-compiler multiplicity.
This unit uses only classified direct String input-adaptation occurrences Pc
from `Call_to_gnu`, with the inherited at-most-eight conversion roots per
actual traversal. Each selected conversion reaches the ordinary template
branch at most once; wrapper peeling decreases the existing spine, and the
P_ARRAY field conversion is an ordinary pointer conversion. Thus Dc<=8Pc,
with Pc<=V_Main retaining traversal multiplicity. Extended accesses, template
records and fat/thin allocators are separate branches; the enclosing fat
pointer, address folds and other executable roots are not priced here.

The stable completed XUB endpoint is compatible with either cold construction
or completion of an earlier dummy graph. The latter preserves existing fat
fields and can process incoming incomplete/deferred queues. Their allocation,
copies and fixups remain open costs; the old cold empty-queue premise is not
transferred. Null fat-pointer construction with a dummy bounds type is also
outside this two-field helper.

## Evidence and disposition

One focused independent audit passed: **18 complete sources, 59 LF witnesses,
10 pinned inputs, 16,875 subset assignments and 400 signed endpoint pairs**.
The full export matched the author result except timestamp and elapsed time.
The first-kernel and #207 files were compared with their accepted commits;
their export bytes are unchanged. No predecessor checker was executed.
The additional GGC source member and reviewed spans are bound in the receipt.
These checks corroborate identities and arithmetic, not universal branch
coverage or a machine-checked semantic proof.

The first recorded review clock was 04:01:40 UTC. The audit completed at
04:07:56.602434 UTC, 376.602434 seconds later. The checker took 0.350095 seconds,
its invocation 0.351605 seconds and the wrapper 0.535185 seconds. Report/commit
preparation is outside the review-through-audit interval. Actual audit host
was Linux x86_64; no macOS result is claimed. No native target, compiler,
prover, Lean, solver, capture or disassembler ran. This round accepted the
author's existing #209 repair with no further rework.

Full F local storage, dynamic matcher termination/candidate costs and Q's
post-fold shape remain unresolved. The documented dynamic minus rewrite,
conditional arm candidates and possible unsharing explain why the Ada
endpoint-node count or a SAVE wrapper cannot close them. Fixed dummy-entry
costs, remaining object/executable families, enclosing fat-pointer adaptation
and downstream native phases remain open. #201/#119 therefore remain open.
Oracle, admission, tools and production are unchanged. One process-wide e<=2,
two save-entering callbacks and three saves remains unchanged. Root owns issue
disposition, integration, publication and durable memory; this reviewer made
no CLI memory write.
