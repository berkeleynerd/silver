# Local native type kernel and String-layout repair review

2026-10-24 UTC. Independent review for #201 and #207 under #119.
Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model confirmation,
token usage and monetary cost are unavailable.

Reviewed author commits:

- `36d478da0cb3261920fd595ba4a9bdcde54b0cb5`: local Main type-constructor kernel.
- `1604467b0f2892d3f92f4f40caaabcc05be52271`: String-layout repair and current exports.

**Accepted at this scope.** The local constructor kernel and repaired frontend
numeric transfer are consistent with the inspected source and explicit
providers. The medium-severity #207 finding is repaired. No remaining scoped
correctness blocker was found. This does not complete #201 or establish a
whole-native capacity predicate. Production, admission, Oracle and tool
configuration are unchanged.

Exact frozen inputs and the independent audit are retained in the
[review packet](../evidence/review-general-native-capacity-20261024/README.md).
The source revision is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, under
the selected Linux x86_64 native options and source/tool correspondence.
No compiler, prover, solver, native capture or predecessor checker was run.

## Layout and constructor review

The no-padding argument uses the actual fields reaching gigi. Signed Integer
subtypes retain Esize32 and alignment4; Character components have size8 and
alignment1; ordinary constrained pointers have size64 and alignment8.
Standard.String's pragma Pack is present even when its representation is not
bit-packed. A constrained static String can therefore have its exact natural
size recorded before native conversion. A literal subtype clears those size
fields in its separate early-return layout path.

For nonnegative extents, the supplied array size equals its natural size.
For superflat extents, the negative size requests are rejected before native
size conversion, and zero-unspecified requests return no size. The size and
component-alignment tests in `maybe_pad_type` consequently return before
constructing a padding record. The argument does not extend to arbitrary
imported records, over-aligned objects or the unconstrained input-pointer graph.
The latter remains a separately demanded fixed dependency, including its
possible unfinished/dummy entry states.

The disjoint Ts/Ta/Tl/Tp family counts import the established full-conversion
and endpoint-dependency arguments. Direct type-node coefficients 3/5/6/6,
declaration coefficients 3/4/3/2, RM-vector coefficients 1/0/1/0 and
lang-type coefficients 1/2/2/1 account separately for dummy/debug candidates,
canonical candidates, stubs and final declarations. Qualified copies share
their existing language payload. The artificial pointer declaration excludes
the additional nonartificial typedef-copy branch.

The constant coefficients 9/56/42/12 include typed Uint conversion and the
possible two Character-array layouts. A typed conversion does not enter the
widening retry; its at-most-three-digit loop supports the retained thirteen
constant-request allowance. Direct `int_const_binop` shifts and the enclosing
two-request constant-fold transfer are distinguished. Declaration insertion
allocates its DECL_EXPR before placement can discard it. The four possible
SAVE_EXPR nodes per array entity are counted separately from their predicate
walks. The two array alloca payloads are individual 8-byte and 1-byte requests,
with native frame coexistence still open.

The residual table tracks the actual roots of bound lowering, conversions,
size operations, overflow folds, conditionals, maximum queries and SAVE
predicates. Their argument-dependent cost is explicitly unresolved. The
annotation interface counts both possible size roots and permits failed
annotation retries; it does not replace structural Q with a root count.
The two-field template kernel bounds its direct element/vector requests while
retaining conversion, validation, comparator and caller-multiplicity work.
These qualifications are necessary to the accepted result.

## #207 finding and repair

The earlier zero-Uint subtype-freezing claim overlooked `Layout_Type`'s
independent pragma-Pack branch. The generated accessor reads the flag from
the implementation base type. Both ordinary slice and explicit String
subtypes therefore reach this branch when their bounds are static, despite
an earlier completed `Check_Compile_Time_Size`.

The local source witness with bounds `1 .. 200000000` produces three fresh
entries, each three digits: 1600000000, 1600000007 and 1600000000. General
multiplication/addition call `Vector_To_Uint` directly, so an existing
UI_From_Int cache entry cannot remove these appends. This refutes the zero
claim; it does not demonstrate that a larger historical aggregate envelope
was numerically exceeded or identify a production overflow.

The repair charges up to seven new entries, separately from the first-size
check's four. Magnitude `8*(2H+1)+7` covers negated endpoints, subtraction,
the raw extent, rounding numerator, quotient and result. Division by8 uses
the single-digit quotient path with discarded remainder. Negative raw
extents use Ada's truncation toward zero: the rounded result is `8*(d+1)`
when d<0. The final static-size adjustment cannot add another arithmetic
stage in either this case or the nonnegative case.

The numeric workspace counts five simultaneous addition owners, plus a
borrowed conversion view; multiplication and division stay within that
envelope. Normalization scans its supplied vector and does not allocate a
second result vector. The six descriptor/bounds-view allowance and dimension/
individual-object checks are logical source-helper bounds, explicitly not
a complete native frame bound.

`Freeze_Entity` checks Is_Frozen and sets it before its dependency recursion.
Its thaw paths and the other direct Layout_Type callers do not reenter these
ordinary Main String types. A copied itype whose freeze state is cleared is
a fresh entity. Thus the cumulative E_Main allowance safely bounds first
layout entries, including decorated copies. Repeated freezing remains zero;
object-only freezing remains zero after its type's corrected charge is paid.

The current overlay adds `7 E_Main` entries, `7(K+1) E_Main` digits and the
separate UI_Ints wrapper allowance once. It increases the common digit bound
to K+1. Per-site corrections and the global overlay are alternatives, avoiding
double counting. The note explicitly covers storage, suppressed/final slices,
Image, copied itypes and ordinary wrappers around literals. Unknown P.all
bounds retain their static-branch exclusion; literal subtypes retain their
early return. Current Uints/Udigits backing checks are recomputed, and no
changed-table success flag is imported from historical evidence.

## Verification and remaining work

One independent combined audit passed. It verified the original kernel's
22 complete source files, 50 LF witnesses and seven inputs at its exact
historical commit, and checked the retained coefficient/projection exports.
The original 4,096-assignment success was reused without executing its checker.
The current repair checker was invoked once: 16 source files, 29 LF witnesses,
three frozen inputs and 3,600 signed/digit-boundary pairs passed. Its export
matched the author output except elapsed time. The matching-file inventory
contains nine Layout_Type calls plus its declaration; the prior full negative
scan was not replayed. These checks verify identities and arithmetic, not
universal semantic branch coverage.

The first recorded review clock was 03:11:24 UTC. The audit finished at
03:16:15.800505 UTC, 291.800505 seconds later; report/commit preparation is
outside that interval. The combined audit took 1.202257 seconds. The focused
checker measured 0.563100 seconds internally and 0.563919 seconds at invocation.
Actual checker host: Linux x86_64. No macOS result is claimed.

Remaining #201 work includes symbolic helper weights, complete descriptor
costs, executable/object families, fixed/imported entry states, annotation
shapes and all later native phase joins. Source-to-installed-tool correspondence
and ordinary physical-resource premises remain required. The global exceptional
allowance is unchanged. The separate #206 timing candidate is outside this
review and remains unadopted. Root owns issue disposition and session memory.
