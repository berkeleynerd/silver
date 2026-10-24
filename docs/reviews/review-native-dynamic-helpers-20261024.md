# Native dynamic annotation transfer review

2026-10-24 UTC. Independent critical review for #201 under #119.
Selected reviewer: **GPT-6 Astra / Extra High**. Runtime confirmation,
token usage and monetary cost are unavailable.

Reviewed author freeze: `26bd01de61242d49f4680d609b38d09e3a51925f`.
**Accepted at the claimed conditional scope.** No material finding or required
author repair was identified. One nonblocking arithmetic-description precision
note appears below. The result bounds annotation after a certified native
operand graph is supplied; it does not close source-derived dynamic F/Q,
the recursive folder or whole #201/#119.

The [review receipt](../evidence/review-native-dynamic-helpers-20261024/README.md)
binds exact inputs and the independent audit. Review covered the research-note
continuation, the full dynamic-helper argument/checker/export, its retained
source, and the prerequisite accepted callback and constant-helper arguments.
GCC remains `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, under the selected
Linux x86_64 configuration, inherited source-to-installed-tool correspondence,
regular gigi annotation mode and the integral precision frontier at most 128.
No new tool, success premise or source-membership restriction is introduced.

## Operand graph, retries and depth

The graph follows exactly the recursive original operands of the selected
`annotate_value` switch. NOP/CONVERT/NON_LVALUE pass to operand zero. The
remaining handled codes have at most three operands. INTEGER_CST, declarations,
COMPONENT_REF, regular-mode CALL and unsupported codes are cuts. SAVE_EXPR is
therefore a cut when it is actually present; a producer's call to `save_expr`
does not establish that result code. Declaration initializers, type bounds,
cache links and SSA use links are not annotation edges.

For PLUS/MULT, the converted inner operation's left child is a strict original
descendant. Its early failure leaves `ops[0]` empty, so the common loop can
visit it again through the original left operand. The combined-constant call
can also fail, leaving the original right operand to be visited. The stated
charge includes all these attempts. Sign-bit PLUS adds a synthetic constant;
BIT_AND with a constant right operand adds a synthetic NEGATE and constant,
while retaining the possible original-right visit. A negative INTEGER_CST
constructs its opposite but invokes UI_From_gnu directly, without another
annotation recursion edge.

The induction is sound. At height h>0, ordinary nodes cost at most
`1+3B(h-1)`, the converted-inner shortcut at most `2+3B(h-1)`, sign-bit PLUS
at most `3+B(h-1)`, and constant-right BIT_AND at most `4+B(h-1)`.
With `B(0)=1`, each is bounded by `B(h)=3B(h-1)+2=2*3^h-1`.
Sharing does not remove occurrence charges. Successful cache hits remove
work; failed calls are not assumed cached, and conversion returns do not
install a new cache entry.

The lexicographic rank distinguishes original invocations `(h,2)`, synthetic
NEGATE `(0,1)` and synthetic constants `(0,0)`. Original recursive edges
decrease height, and only a nonleaf original invocation creates the synthetic
calls. The active-depth bound h+2 follows: an ordinary original path occupies
at most h+1 frames, while a constant-right BIT_AND may add one extra frame.
Early descendant attempts and later retries are sequential. At h=0 there is
at most one annotation frame. These are annotation-recursion bounds, not a
complete native-stack or helper-termination theorem.

COMPONENT_REF's discriminant parent-field scan is a separate pointer walk.
The current local String families have no such discriminant fields; a broader
application owes its termination and traversal bound independently. Likewise,
cycles in unrelated type/cache metadata are not operand cycles. Actual
annotation-operand cycles violate the explicit acyclicity premise; caching
does not make the proposed rank apply to them.

## Source attachment and storage

The accepted local finisher attachment supplies at most two root occurrences
per array/literal family, preserving repeated calls even when TYPE_SIZE and
rm_size are identical. Thus `Qc=2(Sa+Sl)` is a safe classified allowance and
`Rd=2((Ta-Sa)+(Tl-Sl))` is the residual dynamic allowance. Supplying certified
heights yields `Qd<=sum B(h_i)<=Rd*B(H)`. This changes the dynamic charge
interface; it is not another allocation term to add to the old Q.

The mixed storage export correctly reuses the accepted callback transfer.
At most `31Qc+32Qd` scalar constant requests cost 40 bytes apiece under the
precision premise. Each dynamic charge additionally permits a 32-byte unary
node and a 16-byte map record, giving `1240Qc+1328Qd` direct caller bytes.
The complete plain `build1` body confirms that NEGATE construction allocates
directly and does not invoke a symbolic folder. The constant conversion loop
has five iterations; values outside signed 64 bits return before that loop.
It does not create an unbounded numerical retry path.

The Uint entry/digit allowances and the conservative 32-byte Rep_Table row
give logical appended payload `28Qc+100Qd+20T`. The T alignment callback is
separate and retained. The 2040-byte constant-cache vector allowance remains
per participating type instance, including type copies, and is bounded by
the number of constant requests. Incoming table/cache/serial state, index and
byte-product guards, shared hash backing, GGC rounding/pages/residency, wide-
integer workspace and native frames are explicitly separate. No logical
payload count is promoted to a complete allocator or process-memory bound.

The prior first-kernel, #207 and helper current exports and the helper argument
are byte-identical to the accepted predecessor. In particular the accepted
#209 correction and stronger classified constant/descriptor results are not
weakened or replaced by this conditional dynamic result.

## Capped arithmetic and the remaining producer obligation

The capped evaluator returns exactly `min(2*3^h-1, cap+1)`, including h=0,
cap=0 and equality boundaries. Capping the intermediate power at cap+1 is
safe before the final monotone doubling/subtraction. Capped family addition
also returns the exact saturated mathematical sum. An exhausted allowance
means this bound cannot establish headroom; it proves neither actual native
overflow nor nonmembership of a valid Silver source.

Nonblocking precision note: the README says each multiplication has operands
at most cap+1 and intermediate at most `(cap+1)^2`. That sentence is exact for
the exponentiation-loop multiplications. At cap=0 the final `2*result` reaches
2, exceeding the stated intermediate bound of 1, before subtraction returns
the correct result 1. Qualifying the sentence as applying to the loop would
remove this edge-case wording issue. The O(log(cap+2)) arithmetic-value space
bound and all returned results are unaffected: the final doubling is at most
`2*(cap+1)`. No additional audit is needed
to establish that elementary distinction.

The remaining FoldEnvelope premise is explicit and useful. It must provide
cumulative fresh requests, operand slots and local workspace, including
discarded candidates, unsharing and type creation; the finite acyclic native
graphs and their precision/height or vertex bounds; and a well-founded rank
with a cumulative bound for every reachable recursive generated fold edge.
A source-derived vertex count substitutes for height only **with acyclicity
already established**, giving h<=n-1. A count by itself cannot prove a graph
acyclic. The stated requirement retains this premise and requires existing
reachable vertices as well as fresh ones, with bounded completed dependencies
and the imported entry state retained as a parameter.

The actual MINUS-to-PLUS rewrite preserves operand height and node count for
the exhibited dynamic-left/constant-right request, so those quantities alone
cannot be a strictly decreasing fold rank. This refutes that rank proposal,
not compiler termination. Conditional distribution constructs arm candidates
before retention tests and can try the other conditional operand after a
failed attempt. The conversion round trip ends with plain build1/build3 and
return; counting that suffix as another fold recursion would invent an edge,
while ignoring its allocations would omit costs. Repeated GENERIC captures
can invoke unshare_expr before success. The proposed missing lemma therefore
preserves the real cumulative-construction and termination obligations.

## Evidence and disposition

One new independent audit passed: **19 complete sources, 20 author LF witnesses,
3 additional spans, 31 handled codes, 3,049 capped comparisons, 18 huge-height
cases, 1,000 family sums, 832 branch traces over 416 synthetic DAG nodes, and
125 coefficient cases**. The failed-left fixture makes 316 calls at depth 19.
These finite checks corroborate identities, arithmetic and modeled traces;
they are not a machine-checked semantic proof or native allocation measurement.
The author and predecessor checkers were not replayed.

The first recorded review clock was 04:28:19 UTC; the audit completed at
04:32:25.591155 UTC, 246.591155 seconds later. Audit execution took 0.402497
seconds. Report/commit preparation is outside that interval. Actual audit host
was Linux x86_64. No native target, compiler, prover, Lean, solver or pattern
generator ran, and no macOS result is claimed. This round accepted the argument
without material rework and retained the minor wording note above.

Source-derived dynamic F/Q, full local storage, imported-entry construction,
remaining native families and downstream phases remain open. Oracle, admission,
installed tools and production #88–94 are unchanged. The existing process-wide
e<=2, two save-entering callbacks and three saves remain unchanged. Root owns
integration, issue disposition, publication and durable memory. This reviewer
made no GitHub, harness-goal, CLI-memory or author-source edit.
