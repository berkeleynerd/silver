# Original Standard.String size-helper construction storage

2026-10-18, Linux x86-64/LP64, authorized research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The two cold Standard.String `self_referential_size` invocations together
request at most **94 direct GGC objects**, with caller-byte sum
**6,832 + 2P**, and **two ordinary allocations totaling 80 caller bytes**.
P bounds the cleaned filename/global-object component of either helper's
identifier. The separately rounded GGC-slot sum is at most
**7,912 + 2 rho(P+33)**, where rho(x) is the least power of two >= x.
These are lifetime allocation-request sums, including private copies and
discarded candidates, not a collector, RSS, stack or complete frontend bound.

The [evidence packet](../evidence/retained-literal-original-string-storage-20261018/README.md)
exports the arithmetic, source identities, folding case audit and offline
checks. Independent review is pending. This interval is entirely before
the [synthetic function interval](retained-literal-synthetic-function-storage.md),
whose corrected 173-event subtotal starts with existing declarations,
types and bodies. It does not include either helper's cgraph node or
registration, the original empty-elaboration declaration/body, Main's
original gigi trees, or the rest of Standard.String conversion.

## Inputs and ownership

Retain the [layout decision](retained-literal-string-layout.md): exactly one
`with Silver_IO;`, the Main/SPARK shell, C >= 1 qualified direct literal
Put/Put_Line calls, N >= 0 nulls, no declarations/use clauses and literal
lengths <= INT_MAX. Retain its selected non-LTO, O0, no-debug, no-instrumentation,
no-sanitizer/offload/OpenMP invocation, checking/statistics-disabled build,
default Linux x86-64 SysV target and installed/source relevant-behavior
premise. This packet introduces no binary-identity claim; the historical
SPARK exact-identity limitation remains as previously recorded.

The original complete Standard.String entity is cached after its first
conversion (`ada/gcc-interface/decl.cc:400–445`). It is not an incomplete,
private or cloned-record-subtype exception. Consequently the two invocations
are charged once, independent of C, N and which I/O procedure occurs first.
Subsequent references incur zero **additional helper-construction** requests;
their other frontend work is outside this statement. `size_functions` is
initially empty on the retained actual frontier. No other size helper enters
before or between these two invocations.

The interval begins at each call of `self_referential_size`, after its size
expression, Positive index type, bound fields and placeholder reference chains
already exist, and ends at its returned CALL_EXPR. It includes discovery,
private copying, both parameter substitutions, type/declaration/body/name
construction, vector insertion and the returned call. It excludes the caller's
original size-expression folding and subsequent installation/conversion work.
The retained input expressions, constants and type caches belong to those
predecessor intervals. `finalize_size_functions` and its gimplification are
owned by the corrected synthetic interval, not repeated here.

## Private copying and all four substitution traversals

Let l,u be the distinct readonly signed-32 LB0/UB0 references, L=(u64)l,
U=(u64)u, and Q=(u >= l). The layout source constructs these extents:

```text
bytes: Q ? ((U-L)+1) : 0
bits:  Q ? (u128((U-L)+1)*8) : 0
```

In particular, `layout_type` constructs `1+(H-L)` with H's true arm U.
Distribution builds U-L; adding one normalizes the constant to the right
(`stor-layout.cc:2660–2716`, `fold-const.cc:7019–7103,11000–11140`). Neither
size conversion nor multiplication by eight changes that inner association.
The earlier layout note allowed reassociation without fixing one rendering.
For a conservative constructor audit, admit the three normalized extent
forms `(U-L)+1`, `(U+1)-L`, `U+(1-L)`, plus commutative operand ordering,
comparison reversal, and conditional inversion/arm swapping. This finite
family contains the source-constructed input and is closed under the folds
below. It does not assert that arbitrary algebraically equivalent expressions
have the same allocation cost. In particular, a new `U-(L-1)` input would
require its own negation/constant-normalization accounting.

The private walker stops at types, declarations, constants, and each outer
self-referential COMPONENT_REF (`stor-layout.cc:109–148`). There is no
SAVE_EXPR or statement list. With no visited-set argument, `walk_tree`
adds no hash backing; it copies incoming expression occurrences. The byte
expression has 2 unary, 3 binary and 1 ternary occurrences, the bit expression
3,4,1: **14 requests**, with respective totals 5*32 + 7*40 + 2*48 = 536 bytes.
Finding references deduplicates the two fields and stops at their enclosing
COMPONENT_REF (`tree.cc:4490–4556`). Thus each helper has exactly two
parameters and invokes `substitute_in_expr` twice.

For each substitution, the matching outer reference returns the parameter
immediately. A nonmatching reference chain has no changed child, so returns
unchanged without constructing a replacement COMPONENT_REF. Constants and
declarations are reused. Every changed arithmetic/condition ancestor calls
`fold_build1/2/3` (`tree.cc:4564–4750`); counting only the final saved tree
would not discharge these calls. The following is the complete local fold
case partition, including partially substituted trees (one bound field and
one fresh parameter):

| Entry | Requests beyond its ordinary replacement node |
| --- | --- |
| 32->64 or 64->128 widening | Zero. The operand is a bound leaf or unsigned-64 arithmetic, not a conditional, compound, pointer, comparison, assignment, bitwise operation, nested conversion or narrowing multiply. |
| Signed-32 comparison | Zero. Both operands are distinct, nonconstant bound/parameter leaves. Order reversal recurses before building a node and does not repeat once normalized. |
| Inner extent plus/minus | Zero. Two leaves include at most one constant; a subtraction RHS is a widened bound, which is not easily negatable. |
| Outer extent plus/minus | At most one extra binary request. The reassociation proof below counts both reconstructed nodes. |
| Unsigned-128 multiply by 8 | Zero. `extract_muldiv_1` rejects passing through the widening of wrapping unsigned-64 arithmetic before converting its constant or recursing (`fold-const.cc:6647–6675`). Neither multiplicand is a nested multiply; its association split has only two pieces. |
| COND with extent and zero arms | At most one extra comparison. Inverting/swapping arms uses one plain inverted comparison and then one ternary node; there is no original ternary candidate before the recursive call. |

For outer association, `split_tree` (`fold-const.cc:901–1000`) does **not**
decompose U-L: both children are nonconstant. Thus `(U-L)+1` has only two
pieces and fails the more-than-two gate, with no speculative reconstruction.
For `(U+1)-L` or `U+(1-L)`, the pieces are U, negative L and one. All
null-part calls of `associate_trees` return an existing operand. Combining
U and negative L makes one U-L node; combining that result and one uses
one plain PLUS node because an input is already PLUS/MINUS
(`:1011–1063,11441–11664`). The variable's origin mask is three, so the
cross-operand gate succeeds. No constant pair, negated literal, type
conversion or repeated capture is constructed. This both bounds candidates
and gives the normalized `(U-L)+1` result. The other fold entry points see
only the finite input/output family, so no unrestricted rewrite iteration
or expression-size multiplier is being assumed.

For the conditional, neither arm equals a comparison operand; the extent
is not truth-valued, a sign bit, a min/max/absolute-value pattern, or a nested
conditional. `fold_ternary_loc:12899–13240` therefore either falls back or
swaps a simpler zero arm once. The reversed order fails the swap predicate.
`fold_invert_truthvalue -> fold_truth_not_expr` uses `build2_loc` on an
integer comparison (`:4625–4652,4767–4774,9568–9576`), then same-type
`fold_convert_loc` returns it unchanged. The
[existing truth-not inventory](retained-backend-capacity.md#boolean-inversion-has-a-linear-local-skeleton-transfer)
establishes no GENERIC truth-not replacement root. No unary truth-not node,
constant, capture copy or recursively folded comparison is added.

The generated matcher is a separate part of this argument. Its constructor
can recursively fold and copy captures (`genmatch.cc:3259–3485,3575–3605`);
neither is free in general. For this input family, every candidate fails
before a replacement is constructed. The retained `fold-audit.json`
records the source groups: arithmetic identity/negation, two-constant
association, repeated operand contraction, widening/narrowing, boolean
product, comparison, conditional, and the excluded pointer/floating/vector/
bitwise/GIMPLE-only cases. In particular, 64<=32 fails at `match.pd:4534`,
the outer u128 widening fails the narrowing/type-compatibility guards at
9687 before `unsigned_type_for`, the single constant cannot match 4407/4448/
4467's two constants, and eight fails the zero/one product predicate at
2496. Bound-reference and parameter leaves are distinct at every partial
stage. No mandatory nested definition, address or SSA operand is introduced.
The predicates inspect fixed-width scalar types/values; wide integers fit
inline storage. There is no heap-backed range oracle or matcher scratch.

Location/warning bookkeeping adds zero requests here. Substitution's
`fold_build*` macros pass UNKNOWN_LOCATION (`fold-const.h:72–82`), and each
rebuilt comparison therefore has that reserved location. Its optional
inversion copies warning bits but cannot insert a map entry at a reserved
destination (`warning-control.cc:191–222`). No selected rule returns a
location-adjusted captured expression. Checking-only checksum tables and
statistics paths are disabled by the retained build premise.

Conservatively charge **every** original ancestor on **both** substitutions,
even unchanged widenings: 2*(5 unary + 7 binary + 2 ternary). Add four possible
outer-association binaries and four possible inversion binaries. The complete
four-traversal envelope is therefore **10 unary + 22 binary + 4 ternary = 36
requests**, or **1,392 caller bytes**. There are zero fold-created scalar
constants, types, declarations, calls, SAVE_EXPRs, finalizers or ordinary
allocations. Returned trees retain the predecessor's 6/8 expression shape;
the later synthetic gimplification bound remains applicable.

## Remaining constructor requests and cache boundary

`self_referential_size:155–265` constructs four PARM_DECLs, two RESULT_DECLs,
two FUNCTION_DECLs, six TREE_LISTs, two BLOCKs, two MODIFY_EXPRs and two
RETURN_EXPRs. It makes two FUNCTION_TYPE candidates, at most two POINTER_TYPEs
and at most two 16-byte type-hash records. A hash hit may free the function
type candidate and roll back its UID; this bound takes no refund.

There is no canonical-type recursion. Positive's representation is a fresh
signed-32 `make_signed_type` (`decl.cc:1901–1984`, `stor-layout.cc:2838`),
whose `make_node` initializes TYPE_CANONICAL to itself. Its ordinary subtype
completion neither constructs a qualified variant nor changes that canonical
identity. The bound fields use that index type (`decl.cc:7293–7341`). The
result sizetype/bitsizetype and void terminator are self-canonical startup
types. Hence `maybe_canonicalize_argtypes` returns the supplied list, and
`build_function_type` does not recurse (`tree.cc:7671–7788`). The function
type remains self-canonical, so its non-aliasing pointer construction adds
at most one pointer without canonical recursion (`:7198–7264`). Hash-table
backing is a shared integration input, not charged as two private tables.

Function layout requests `(bitsizetype,8)` and `(sizetype,1)`; pointer layout
requests `(bitsizetype,64)` and `(sizetype,8)` (`stor-layout.cc:2640–2661`,
`i386.h:821`). Their sizes are already aligned, so `round_up_loc` returns
them without a constant request, and neither variable-size nor missing-byte
division branch runs. The two calls request `(sizetype,5)` as their implicit
operand lengths. Thus there are at most ten scalar lookups and only **three
possible new INTEGER_CSTs**, each 32 bytes. Both unsigned size-type caches
already exist: `initialize_sizetypes:2950–2980` inserts the 64/8 pointer-size
pair and initializes their bounds. All new values 8,1,5 fit the default
251-entry small-value cache (`params.opt:248`); its existing vector is reused,
without int-constant hash insertion or new cache-vector allocation.

The returned call uses one ADDR_EXPR of the helper FUNCTION_DECL and a
five-operand CALL_EXPR per helper (`tree.cc:11020–11151`). The fresh
declaration is not builtin, so `fold_builtin_call_array:11095–11127` returns
null before any builtin transform. `process_call_operands` and its flag
queries inspect the arguments/declaration/type without constructing objects.
The call is outside the helper's saved body. This path has no address of an
aggregate CONSTRUCTOR, `make_decl_rtl`, `tree_output_constant_def` or
`output_constant_def`; it adds no constant-pool entry or symbol registration.

## Names, vectors and finite arithmetic

The four `get_identifier` parameter lookups use only p0 and p1. The two
`get_file_function_name` lookups create at most two further identifiers.
Thus six insertion-capable lookups contribute at most four 40-byte identifier
nodes, two 3-byte parameter strings and two helper strings of at most P+33
bytes including NUL. No duplicate-lookup allocation is charged twice.
`libcpp/symtab.cc:152–184` invokes stringpool's GGC atomic callback directly
for `len+1`; these bytes do not pass through the ordinary string obstack.
The shared identifier-table growth must receive the four-entry demand.

`FILE_FUNCTION_FORMAT` is `_GLOBAL__%s_%s` (`tree.cc:9012`). The first format
argument is SZ followed by at most 20 unsigned-64 decimal digits; the second
is the cleaned component p (`:9114–9175`). Cleaning preserves its length.
Take P >= max(G,F+28), where G bounds an available first-global-object name
and F bounds the selected input filename. If no global name exists, the
CRC/random suffix uses a fixed 29-byte buffer including NUL. Two identifiers
therefore have caller size <= P+33. Formatting uses fixed/alloca stack buffers;
`get_random_seed` uses open/read/close or existing scalars (`toplev.cc:273–288`),
not an explicit allocator call in this source interval. Stack/system-library
implementation costs are not inferred to be zero from that observation.

Require `0 <= P <= INT_MAX-33`, incoming helper-name fnno + 2 <= UINT64_MAX,
incoming next_decl_uid + 8 <= INT_MAX, and incoming next_type_uid + 4 <=
UINT32_MAX. These conservative local guards keep filename/suffix arithmetic,
identifier lengths, counter increments and per-request byte counts finite;
they are composition conditions, not newly admitted source limits. The full
retained frontier starts fnno at zero, but the interface keeps the incoming
counter condition explicit. No function-definition number, SSA name, pseudo,
label or symbol-order number is consumed in this constructor interval.

Each ordinary `self_refs` vector reaches length two, with initial capacity
four: one 8+4*8=40-byte request per helper, released before function-type
construction. Each GGC args vector is bounded by one 64-byte request; the
initial size-functions vector by one 64-byte request for its two entries.
These sizes include vec's pre-allocation GGC rounding. The args vectors are
not explicitly freed here; size-functions is explicitly freed after later
finalization. Private copies and replaced ancestors remain allocation events
even when unreachable. No object in this interval registers a finalizer.

## Allocation projection and integration

| Family | Events | Caller-byte ceiling each |
| --- | ---: | ---: |
| Private unary / binary / ternary copies | 5 / 7 / 2 | 32 / 40 / 48 |
| Substitution unary / binary / ternary | 10 / 22 / 4 | 32 / 40 / 48 |
| PARM_DECL / RESULT_DECL | 4 / 2 | 256 / 256 |
| FUNCTION_DECL | 2 | 512 |
| TREE_LIST | 6 | 40 |
| FUNCTION_TYPE / POINTER_TYPE | 2 / 2 | 256 / 256 |
| Type-hash record | 2 | 16 |
| BLOCK | 2 | 96 |
| MODIFY_EXPR / RETURN_EXPR | 2 / 2 | 40 / 32 |
| Args vectors / size-functions vector | 2 / 1 | 64 / 64 |
| ADDR_EXPR / CALL_EXPR | 2 / 2 | 32 / 64 |
| Identifier nodes | 4 | 40 |
| Parameter / helper characters | 2 / 2 | 3 / P+33 |
| Cached INTEGER_CST misses | 3 | 32 |

Tree layouts reuse the retained structural LP64 bounds in
[native expansion](retained-native-expansion.md) (the null-gigi tree section)
and [type storage](retained-backend-capacity.md#type-identities-cache-records-and-fixed-size-allocation).
Each expression has a 24-byte prefix plus its operand pointers; CALL_EXPR
therefore needs 24+5*8=64 bytes. DECL bounds deliberately overestimate
bitfield packing. rho bounds each request separately; it is not applied to
the aggregate caller-byte sum. Freed candidates receive no negative charge.

Export eight DECL UIDs, at most four type UIDs, two helper-name suffixes,
six identifier insertion-capable lookups/four new entries, two type-hash
insertion-capable lookups/two records, existing small-constant cache writes
<=3, zero constant-pool entries and zero finalizers. Existing shared table
and collector components consume those demands once. Add the 94-event
request row to the corrected 173-event synthetic row only at their disjoint
boundaries; their sum alone does not close the original Standard.String,
Main, collector or whole-pipeline capacity residual.

Selected worker: GPT-6 Astra / Extra High. Runtime-setting confirmation and
token/cost measurements are unavailable. This round began 2026-10-18
20:58:57 UTC, first completed the separately committed return-ABI correction,
then closed the four constructor substitutions. Only source reads, three raw
upstream byte comparisons and offline evidence checks were performed; native
compiler/build/prover runs: zero. The packet records check time and outcome.
No production, Oracle, admission, tool, proof-provenance, aggregate, GitHub
or CLI-memory change is part of this interval.
