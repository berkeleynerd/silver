# Narrow original-layout constructor repair: signed MAX continuation

The provider follow-on audit found a reachable construction omitted from
`concat-layout` author `302b32d15c293c9f8cf352f80ee9b7b4b068eee0`, subsequently
accepted by `793a9738ed8f02e5d84e54a9a687894195f36f94`. Both exact records stay
historical and unchanged. This addendum supersedes the original conditional
entry row and its derived layout totals; it does not silently rely on unused
slack elsewhere in that table. Independent review of this repair is pending.

The original nullable lower-one/empty-tail case is already in that packet's
source domain. For example a dynamic Integer Image followed by an empty String
can leave original A=1, B=G after IF(G=0,0,G) contracts. G is still a fresh
readonly base-Integer aggregate declaration, not the Image position's subtype.
The original allocation's Cannot_Be_Superflat is false. Its size construction
has `GT_s32(G,0) ? U(G) : 0_u64` after comparison canonicalization.

`fold_ternary_loc` calls `fold_cond_expr_with_comparison` when
operand_equal_for_comparison_p recognizes G beneath U's outer widening
(`fold-const.cc:12999–13042,4372–4409`). The other equality compares the two
zeros. `operand_compare::operand_equal_p` checks two INTEGER_CST values
**before** its signedness/precision rejection (:3250–3258), so signed32 zero
and unsigned64 zero compare equal. The helper builds signed MAX(G,0) and
fold-converts it to unsigned64 (:6170–6254). That conversion cannot disappear:
it widens a nonconstant signed32 MAX to unsigned64. The result has one new
binary MAX and one new unary conversion, with no retained outer conditional.
Later subtraction/add-one and bit conversion operate on that result.

The old gigi-conditional entry C0/U0/B1/T1 therefore fails its per-entry U=0
assertion. The final graph is smaller, but that fact does not pay the missing
constructor. Replace just that entry by **C2/U2/B2/T2** to conservatively
cover the MAX, conversion and existing conditional alternatives. Other entry
multiplicities and envelopes remain unchanged. The corrected original-layout
cumulative table is

```
C184/U126/B138/T112
layout raw bytes = 22288 Ka
expression operand slots = 738 Ka
annotation raw bytes = 167328 Ka (unchanged)
layout + annotation raw bytes = 189616 Ka.
```

The old annotation H<=9/O<=59/Q<=63 bounds remain valid: the new depth-zero
MAX alternative has at most H5/O8/Q8, including the conservative same-width
Image view; pure G is smaller. MAX is an ordinary binary annotation opcode.
Round-up still sees the final constant factor 8 first. No new retry path,
selector recursion, SAVE cut or repeated-capture unshare arises.

The old maximum-query pair is unchanged. The original high is G (or a debug
cut of it), and the caller queries its immediate scalar aggregate initializer;
that query stops at declaration leaves and does not follow the operand Length
initializer. A debug cut has initializer G. The MAX is created later in size
layout, not stored as an original signed index bound. Generated first assignment slices and nested-provider Length initializers
remain outside this narrow repair; their separate provider/query attachment
is not an input or premise here.

Earlier literal-prefix allocations have Result_May_Be_Null=false and take
the non-superflat shortcut, so this specific MAX route does not change their
constructor certificate. Their returned dynamic slices were expressly outside
that packet. Earlier input bounds are two distinct full-base declarations,
not lower-one; their corresponding conditional arm is U(L)-1 rather than
constant zero, so the second equality fails. Image's earlier specialized
non-superflat argument retains its subtype-bound source justification. This
repair does not reopen those unrelated source cases.

The focused new-unit audit checks the corrected arithmetic and a source-gate
model of the cross-precision constant equality, while retaining all original
source hashes. It does not execute the old checker or compiler. There is no
Oracle, admission, tool, physical-resource or per-process allowance change.

Selected repair author: GPT-6 Astra / Extra High; runtime model/effort
confirmation and token/cost data are unavailable. The broader round began at
07:52:13 UTC; the narrow repair phase first recorded its clock at 08:23:22 UTC. The separate
repair receipt records actual completion and focused-check elapsed time.
No successful predecessor checker is replayed. Broader provider work remains
uncommitted and is not part of this repair freeze.
