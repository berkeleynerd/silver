# Dynamic annotation height transfer and the remaining fold lemma

This is a source-only continuation of #201 under #119, at author input
99734327fd77d426fead054d7ba0e12999b00d8a. The first kernel, #207 frontend
overlay and independently accepted #209/helper export remain unchanged.
There is no Oracle, language, production or pinned-tool change, no native
success premise, and no new admission test. **Dynamic F and whole #201 remain
open.** This packet closes an annotation transfer conditional on an explicit
native operand-height input; it does not claim that the current frontend
already supplies that input.

The useful reduction is that a complete description of every final folded
size expression is unnecessary for Q. A certified finite acyclic operand
graph and its height suffice. The open producer obligation is now stated
precisely below, including cumulative discarded construction. This does not
replace that obligation by an observed graph, a successful run or a fixed
compiler multiplier.

## Annotation graph and scope

Use GCC 6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea, the retained Linux x86_64
layout, regular gigi mode, `List_Representation_Info < 3` and
`type_annotate_only=false`. Use the established integral precision <=128
frontier for the constant-storage projection. The complete retained files
are reused through the source manifest, not refetched or regenerated.

For an incoming expression e, form its **annotation operand graph** by following
only these original operand edges (`decl.cc:9322–9501`):

- CASE_CONVERT and NON_LVALUE: operand zero.
- The handled unary, binary and COND codes in the switch: their ordinary
  operands, even when an earlier failure would skip later operands.
- INTEGER_CST, VAR/PARM declarations, COMPONENT_REF, regular-mode CALL and
  every unsupported code: no annotation edge. In particular SAVE_EXPR is a
  cut, although the presence of a `save_expr` call does not prove its result
  has that code. A declaration's initializer and type bounds are not edges.

The converted-inner PLUS/MULT shortcut's extra child is already a strict
descendant in this graph: root -> conversion -> same-code operation -> left
child. Its retry is additional **work**, not another graph vertex. Constants
and the NEGATE synthesized by annotation are not original vertices.

Require the reachable original graph to be finite and acyclic. Let h(e) be
its maximum number of operand edges on a path; a cut has height zero. Sharing
does not reduce repeated work. Types, caches, declaration metadata and SSA
use lists can be cyclic without being edges in this graph. This definition
does not prove that every producer satisfies the acyclicity requirement.

A COMPONENT_REF can separately follow its parent-field spine if its field is
a discriminant (`:9361–9372`). That scan allocates no annotation node and makes
no recursive annotation call. The current local String bounds have no
discriminant fields. A more general use owes the finite parent-spine traversal
bound separately. Hash probes, numerical workspaces, native frame sizes and
shared allocator/table backing retain their existing owners.

## Closed charge, termination and active depth

Use the accepted conservative charge Q, which ignores cache hits and includes
failed-child retries. Every annotation invocation, including a synthesized
constant or NEGATE invocation, contributes one. Ordinary children are charged
even when an early failure would skip them. The exact additional charges are:

| Source arm | Charge beyond root and ordinary children |
| --- | --- |
| PLUS with sign-bit-set constant right operand | 1 synthesized constant |
| Other PLUS/MULT with converted same-code inner operation and constant right operands | Q(inner left) + 1 synthesized constant |
| BIT_AND with constant right operand | 2, for synthesized NEGATE and constant |

The source shortcut can annotate inner-left unsuccessfully, then revisit it
through the original left operand; the original right operand must remain in
the allowance too. The BIT_AND synthetic annotation can likewise fail, causing
the original right constant to be visited. These are not unique-node counts.

Define

```
B(0) = 1
B(h+1) = 3 B(h) + 2
B(h) = 2 * 3^h - 1.
```

Then **Q(e) <= B(h(e))**. The following induction covers the entire selected
annotation switch, including codes a future folder might introduce:

1. Cuts have Q=1. A negative INTEGER_CST builds an opposite constant but calls
   UI_From_gnu directly; it does not recursively annotate that constant.
2. A plain handled node has at most three children of smaller height, so its
   charge is at most `1+3B(h-1) <= B(h)` for h>=1.
3. The converted-inner shortcut has at most two ordinary children and one
   extra strict descendant, plus the synthetic constant. Its charge is at
   most `2+3B(h-1) = B(h)`.
4. The sign-bit PLUS has a constant right child of charge one, so its charge
   is at most `3+B(h-1) <= B(h)`.
5. BIT_AND likewise has a constant right child; its charge is at most
   `4+B(h-1) <= 2+3B(h-1) = B(h)`, using B(h-1)>=1. Merely using three arbitrary
   ordinary children plus two new ones would be a needlessly larger bound.

For termination, rank an original invocation by `(h,2)`; its original recursive
calls strictly decrease h. Rank the synthesized NEGATE by `(0,1)` and its
constant child, or any directly synthesized constant, by `(0,0)`. Only a
nonleaf original node synthesizes recursive calls. This lexicographic rank
decreases on every annotation recursion edge. Cache hits and failures only
remove work. The rank says nothing about recursion inside the folder.

The maximum simultaneous `annotate_value` activation count is at most h+2
(and exactly at most one when h=0). An ordinary path uses at most h+1 frames;
a BIT_AND at height one can add its NEGATE and constant frames, giving the
one extra frame. Converted-inner early calls jump to an original descendant;
their later retries are sequential. This is a recursion-depth bound, not a
native frame-byte or whole-stack bound.

For a graph with n distinct original annotation vertices, acyclicity also
gives h<=n-1 and `Q(e)<=2*3^(n-1)-1`. This is a mathematical transfer from a
certified native vertex bound; the sixteen-Ada-node endpoint bound does not
supply n. A graph may share a child in every position: its height stays small
relative to its unfolded occurrence count, and the B bound still charges
every occurrence and retry.

## Current-family attachment and allocation export

Retain the accepted classified subsets Ss, Sa and Sl. Put
`Da=Ta-Sa`, `Dl=Tl-Sl`, `Qc=2(Sa+Sl)` and `Rd=2(Da+Dl)`. Rd counts the dynamic
annotation-root allowance, including both TYPE_SIZE and rm_size and possible
failed-call retries; it is not the count of distinct final roots. If the
producer supplies certified heights h_i for those root occurrences, use

```
Qd <= sum_i B(h_i) <= Rd * B(H),  where all h_i <= H.
```

The second form deliberately permits charging nonexistent roots. H is still
an open producer input. This attaches the new transfer to the already proved
Main root multiset without equating a runtime value with a source-tree literal.

The accepted callback transfer then gives the following mixed export. The
constant-subset rows are reused from helper-joins; Qd replaces only the open
dynamic annotation charge, and must not be added twice to the old Q interface.

| Cumulative demand | Bound |
| --- | --- |
| GCC scalar constant requests | 31Qc + 32Qd |
| GCC unary requests and operand slots | Qd each |
| GCC annotation-map records | Qd, 16 bytes each |
| GCC direct caller bytes for these three rows | 1240Qc + 1328Qd |
| Rep_Table additions | Qd |
| Uint entries | Qc + 3Qd + T |
| Uint digit words | 5Qc + 11Qd + 3T |
| UI_From_Int cache-wrapper calls | Qc + 3Qd + T |
| Dynamic annotation serial increments | Qd |

The byte coefficients use at most40 bytes per scalar constant,32 bytes for
the raw unary `tree_exp`, and16 bytes for `tree_int_map`: `31*40=1240` and
`32*40+32+16=1328`. `build1` allocates the32-byte unary node directly; it does
not call a symbolic folder (`tree.cc:5194–5214`). The 31-constant UI_From_gnu
allowance covers the retained fixed five-iteration conversion, including
failed numerical conversion paths, as established by the predecessor.

Constant cache vectors additionally require at most
`2040*min(31Qc+32Qd, participating_type_instances)` caller bytes. Native type
copies contribute to the second argument. Hash/table capacity, GGC rounding,
collection, pages and physical residency are separate. The16-byte map records
are cumulative requests, not the final live-cache cardinality.

Using the accepted8/4-byte Uint entry/digit components and conservative32-byte
Rep_Table component, the **logical appended payload** is bounded by
`28Qc+100Qd+20T` bytes. This is not cumulative allocator backing: apply the
existing geometric table transfer to incoming state plus the entry/digit
demand. Incoming frontend #207 values, Rep_Table's fixed demand and the
annotation serial are never reset by this calculation. Check all existing
index, negative-index, byte-product and serial guards; no new memory-membership
policy is introduced here.

## Computable arithmetic without materializing the exponential

`check.py` contains `charge_capped(h, cap)`, returning exactly
`min(B(h), cap+1)` by capped exponentiation by squaring. Each multiplication
uses operands at most cap+1, with an intermediate at most `(cap+1)^2`.
It uses O(log(h+1)) iterations and O(log(cap+2)) bits per arithmetic value,
apart from reading h itself. A family sum can be capped after each product
and addition. Thus a supplied height can be compared with native headroom
without constructing the enormous exact B(h).

The script checks the source-pinned arithmetic lemma, sharing/retry examples,
mixed coefficients and saturation against exact small exponentials. Its
huge-height check has a257-bit height and a31-bit cap; this is an arithmetic
stress check, not a native compiler run or evidence that such a height occurs.
An exhausted conservative allowance means **this bound does not establish
the guard**, not that a Silver program is nonmember or that actual GCC demand
exceeds the native field. No observation of successful native compilation is
used by the evaluator.

## Exact missing producer lemma: dynamic FoldEnvelope

The next obligation is to prove, for the current normalized Main endpoint and
type dependency grammar and the selected configuration, a total computable
transfer `FoldEnvelope(source, incoming completed type graph)` which supplies:

1. Cumulative fresh constructor requests, operand slots and local workspace
   for the dynamic residual type-helper multiset, including recursively made
   and discarded candidates, unsharing and any type creation. Completed
   dependency graphs must carry their source-derived bounds, rather than be
   counted as one source name.
2. Finite acyclic original annotation operand graphs at each finishing root,
   the integral precision frontier used above, and either their h_i bounds
   or a bound on their distinct reachable native vertices. An ordered DAG
   construction certificate or a source-derived count of all reachable
   existing and fresh vertices would suffice; an exact final grammar is
   no longer required for the Q transfer.
3. A well-founded rank and cumulative candidate bound for every recursive
   generated fold edge reachable in that grammar. No finite syntactic
   matcher-rule count, sampled successful run or unproved maximum runtime
   supplies this requirement. The fixed imported entry state is a parameter,
   not a presumed cold empty graph.

The retained sources identify a concrete unresolved call chain. Dynamic
`gnu_min-1` at `decl.cc:2801–2813` enters `size_binop`, then the symbolic binary
folder. `match.pd:2199–2203` changes MINUS into PLUS with a folded negation of
the constant. The resulting symbolic recursive call has the **same operand
height and node count** as the original request, so a strict rank consisting
only of those quantities fails on this actual rule. The constant subcall is
closed; the symbolic PLUS continuation is not. This is a counterexample to
that proposed rank, not a claim of nontermination.

The current candidate rank must also distinguish conditional distribution's
pending continuation: `fold-const.cc:7076–7103` constructs both arm results
before testing whether either is worth retaining, then may call fold_build3.
The caller can try the other conditional operand after the first attempt
returns null (`:11122–11138`). Counting the retained result omits those attempts.
Conversions can move into both conditional arms and then be pulled out with
**plain** build1/build3 followed by return (`:9264–9308`); treating that final
plain construction as another fold call would invent an edge, while dropping
its allocations would undercount. Repeated GENERIC captures invoke
`unshare_expr` before later success is known (`genmatch.cc:3590–3602`).

Consequently this round does not claim dynamic F closure, a source/config-only
H, or a complete current-language capacity rule. The next decisive work is
the ranked reachable rewrite transfer for these inputs, not another global
source inventory or another annotation-shape census. If that transfer needs
a richer abstract state, it must preserve signedness, widths, overflow flags,
conversion barriers, shared operand dependencies and pending candidates.
The named unresolved problem is precisely the decreasing fold rank together
with its construction envelope; this packet leaves it visible for separate
review and subsequent work.

## Evidence and round record

`source-manifest.json` pins the reused complete source archive and every
member, plus the retained tree.def member in `extra-sources.tar.gz`;
`source-witnesses.json` pins the selected LF spans. `inputs.json` pins
the accepted exports and prerequisite argument. `packet-manifest.json` pins
this README, the checker and the updated research note. `current.json`
records the one focused check, its host and elapsed time. The checker does
not execute predecessor checks, GCC, a pattern generator, Lean, GNATprove,
a solver or a native target. Source identity and arithmetic checking are
distinct from a machine-checked source-semantic proof.

Selected author: GPT-6 Astra / Extra High; runtime confirmation, total author
elapsed time, tokens and cost unavailable. Intended result: close a source-
attached dynamic F/Q unit or freeze a genuine missing lemma. Achieved result:
the annotation height/termination/storage transfer and capped evaluator;
dynamic FoldEnvelope remains open. Significant finding: original operand
height/node count alone cannot rank the actual MINUS-to-PLUS fold edge.
The first recorded packet-preparation clock was 2026-10-24 04:19:30 UTC;
it is not the start of the earlier source analysis. Native execution time
is zero. Independent review and root integration are pending. No issue,
harness goal, CLI memory or publication change was made by this subthread.
