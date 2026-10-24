# #218 repair: hereditary lower one across the frontend/native boundary

2026-10-24, #218 under #201/#119. This additive repair supersedes the
frontend-literal heredity, `s=m=0`, scalar-event and high-index debug claims
at author `e363118b9343dbae72127411f9bc21cc199e2070`. Review
`8e870ce2cc2d05165db8be3ab60b074533e57073` correctly rejected those claims.
All original provider files, receipts and the accepted #217 repair remain
immutable. The effective exports below replace the affected rows; they are
not additive charges on top of those rows. Exact independent repair review
is pending.

The intended recursive source family is retained: fixed/literal and Image
seeds with lower 1, their concat compositions and ordinary initialized aliases,
including nullable events. Initial-input providers enter if their actual
completed provenance establishes lower 1; the arbitrary input-low family is
still separate. The corrected invariant is **a completed native signed lower
bound equal to integer constant 1**, not a frontend-known literal at every
generation. No source form is removed to repair the induction.

Retain the pinned GCC commit, natural Character/String layout, local Main/O0
GENERIC setting, admitted scalar types, and explicit false TREE_SIDE_EFFECTS
premise. Oracle, admission, tool pins and physical-resource premises are
unchanged. This is a raw caller-request/source attachment result, not complete
native capacity. No cumulative compiler RAM/stack gate is added. Fixed
representable compiler helper frames and finite traversal use the retained
physical-stack premise; dynamic backing, representability and generated-program
frame/encoding duties remain.

## 1. What GNAT actually retains

For a real event e use n_e for its collected operand count, r_e for
Result_May_Be_Null, s_e for selected-low IF nodes constructed by Get_Known_Bound,
and m_e for its selected-low capture. The last two are no longer set to zero:

```
0 <= s_e <= n_e-1;  m_e in {0,1};  sum_e s_e <= C;  sum_e m_e <= C.
```

The original disjoint-left-spine argument still gives E<=C and
sum(n_e-1)<=C for arbitrary finite source concat count C. Skipped operands
and early returns can only remove these translated producer occurrences.
The selected-low capture is called M here; the separate count of successful
static-max replacements is denoted M_max to avoid conflating them.

GNAT can preserve `if G=0 then 1 else 1`. Eval_If_Expression requires static
condition and arms (`sem_eval.adb:2534–2609`); Compile_Time_Known_Value has
no surviving IF case (:1812–1918). Expand_N_If_Expression folds a known
condition, then leaves a pure scalar no-actions expression to gigi
(`exp_ch4.adb:5944–5975,6629–6633`). Its declaration optimization requires
a non-copy type (:5777–5797); the base signed Integer type is a definite,
non-reference scalar. No aggregate, controlled or coverage-only action path
is introduced by these generated low expressions in the retained invocation.

Consequently a later operand may use First instead of a literal
(`exp_ch4.adb:2968–2989`). Frontend comparison can fail to prove equal lows,
so Get_Known_Bound retains up to n_e-1 IF nodes and creates one constant M
(:3163–3229). The review's `Saved`, `Inner := Saved & Saved`,
`Outer := Inner & "x"` example is retained as a counterexample to frontend
literal heredity and as a case handled by this repair.

The frontend low grammar for the current event has leaves that are literals
or First of completed earlier providers. Each selector test is W_j/=0, where
W_j is the earlier generated Length constant. If the selected tree is an IF,
it is the initializer of M; otherwise the chosen leaf is used directly.
The nullable low is a further IF(G=0,last_First,L), where L is M or that leaf.
This last IF may be copied into ranges and assignment bounds. It is not
silently treated as a frontend literal.

Relaxed Force_Evaluation does not make this frontend tree static. It also
does not add scalar captures to this pure low grammar: entity constants,
First with a completed entity prefix, scalar comparisons and scalar IFs
satisfy Side_Effect_Free (`exp_util.adb:7221–7245,12718–12724,14408–14612`).
The separately owned Image/input producers and any array-prefix stabilization
retain their existing owners. This repair does not use purity to discard
their production work.

## 2. Native constant bridge, including M and debug identities

Prove the following by earlier-provider order and then by the selected-low
spine's remaining nodes. The proof concerns compilation order, not an
assumption that a runtime equality makes an expression constant.

1. A completed earlier provider's native signed index has lower constant 1.
   Gigi First reads that completed index bound
   (`trans.cc:2247–2272`). It does not translate the old GNAT lower expression
   or recursively visit the provider's declaration initializer. Ordinary
   aliases reuse that index, or copy its completed attributes through the
   already classified subtype route. First through those aliases has the
   same native constant result.
2. `trans.cc:7605–7615` translates a selected IF's condition and both arms
   before calling build_cond_expr. By the induction hypothesis both arms are
   native constant 1 in the base signed Integer type. Ityp is the base of
   String's index and Artyp=Ityp for its 32-bit signed representation
   (`exp_ch4.adb:2562–2568,2715–2750,2816–2827`). The typed arm conversions
   preserve 1. Pure equal-arm folding returns that constant; it does not
   preserve the discarded test in COMPOUND_EXPR. This is precisely the
   accepted #214 purity-qualified rule, not a readonly-only argument.
   The test and any attempted nodes have already been constructed and are
   charged below. Induction over all s_e nodes yields M's native initializer 1.
3. The M declaration has Constant_Present=True and a real expression
   (`exp_ch4.adb:3217–3228`). Analyze_Object_Declaration marks it E_Constant
   and Is_True_Constant (`sem_ch3.adb:4415–4417`). It is a generated local,
   nonvolatile, nonimported, nonaliased scalar without address, size,
   alignment, linker or storage-model clauses. The const_flag test at
   `decl.cc:731–740` is therefore true. No later by-reference, variable-size,
   over-alignment, template or address-clause branch changes that result.
4. The saved Actions place W_j and aggregate declarations before M, and all
   those declarations before result range construction
   (`exp_ch4.adb:3036–3099,3217–3228,3297`). Object translation first computes
   the initializer, then passes it to gnat_to_gnu_entity with definition=true
   (`trans.cc:6832–6878`). If ordinary freezing delays elaboration, the saved
   initializer is retrieved at the freeze point (:9842–9856); it is not
   retranslated on each subsequent reference. Required declarations precede
   their range uses in either route.
5. The final initial-value conversion at `decl.cc:1604–1606` gives the object's
   native type; constant 1 remains an INTEGER_CST without overflow or effects.
   `convert` has an exact-type return (`utils.cc:4998–5010`), and an integral
   constant conversion folds to another constant (`fold-const.cc:2633–2673`).
   The type is compatible by the main-variant test (`utils.cc:4025–4032`).
   create_var_decl consequently has init_const=true, constant_p=true, and
   default const_decl_allowed_p=true (`gigi.h:700–707`). Its scalar result is
   CONST_DECL, TREE_CONSTANT=true, with DECL_INITIAL=1
   (`utils.cc:3033–3058,3089–3101`).
6. O0 debug information can additionally create a corresponding VAR_DECL
   (`decl.cc:1673–1694`). It does not replace the original CONST_DECL.
   The final source-entity association stores that original declaration
   (:5023–5026), and later gnat_to_gnu_entity uses return the cached identity
   (:405–445), without retranslating the initializer. Identifier_to_gnu's
   constant predicate requires TREE_CONSTANT and an initializer
   (`trans.cc:1047–1059`). If a corresponding debug variable exists,
   lvalue_required_p is consulted; it returns false in scalar range bounds,
   arithmetic, IF arms and scalar initializers, looking through conversions
   (:853–974). These uses have no address-taking or aggregate-lvalue context.
   Thus :1328–1350 returns DECL_INITIAL=1 in both debug alternatives.
7. The nullable outer low IF now has native constant 1 in both arms, whether
   L came from M, First or a literal. It contracts by the same pure rule.
   Signed-index elaboration stores this result
   (`decl.cc:1968–1976`; `ada-tree.h:289–320`). elaboration caching is keyed
   by the bound node, so fresh frontend copies are separate occurrences,
   while repeated uses of an already elaborated node are not new translations.

There is one additional debug detail. A GNAT-nonstatic low that is native
constant 1 may still create a debug-only VAR_DECL when all GNAT encodings are
enabled. elaborate_expression_1 sets expr_variable_p=false for a constant;
its optional debug allocation is returned as the bound only for nonconstant
expressions (`decl.cc:7577–7657`). The constant lower bound therefore remains
1 in either case, but the extra declaration and DECL_EXPR must be priced.
This is distinct from M's corresponding debug variable.

No value substituted at a later scalar reference contains a selected-low
spine. Native lower bounds and M references are constants even though their
GNAT syntax may remain nonstatic. Every recursion either visits an earlier
provider, a shorter current selector spine, or terminates at an already
completed entity. There is no same-entity initializer replay or folding cycle.

## 3. Restored native grammar and corrected static-max routing

With native L=1 established, high arithmetic follows the reviewed native
transfer: `1+(G-1)` becomes G, including discarded association/NON_LVALUE
work. The high is a completed leaf or one new pure selector over the last
completed provider high. Nonnullable and empty-tail contractions reset depth;
aliases preserve it; captures shorten it. Consequently t<=C by earlier-event
order. A native constant specialization only removes such structure.

The effective native layout, annotation, signed Length and maximum-query
formulas from the original provider packet are retained. Their source
attachment now follows this bridge. Signed Length still permits retained
NON_LVALUE wrappers; the first assignment high can still be W_1 and expose
that Length initializer to a maximum query. Low queries see constant 1;
they do not revisit M. The accepted #217 MAX/conversion row remains in force.

Static allocation-high replacement is decided **before** this native bridge.
It still requires all actual frontend conditions at `exp_ch4.adb:3302–3325`:
known low, nonknown high, finite maximum, and representable computed high.
A nullable unknown-test IF(1,1) fails the low-known condition even when direct
Image supplies a finite maximum. The native proof must not be fed backwards
into that gate. A positive fixed operand can clear r_e; for example
`"x" & Integer'Image(I)` has the known low and finite-max provenance needed
for a successful static replacement when the other gate checks hold.
`Saved & ""` remains the original-allocation witness for #217.

Record successful static replacements from the actual frontend branch, not
from native low=1 alone. Where a nullable condition remains unknown, there
is no replacement. A frontend-folded smaller case is allowed according to
the actual gate. On success the constant allocation and dynamic returned
slice are separate receiving identities; the original dynamic range goes
to the slice before the allocation's Cannot_Be_Superflat flag is assigned.
The returned range still satisfies the restored native lower-1 grammar.
This preserves the original direct occurrence bounds
R+M_max+A+D<=4C+D and signed-index count<=4C.

## 4. Effective request accounting

Use the accepted raw sizes C=40, U=32, B=40, T=48 and scalar declaration
envelope 256 bytes. A DECL_EXPR is one unary node. Counts are cumulative
requests, including discarded tests, conversions and fold candidates.

For the original endpoint subcall and M initializer, let J_e count directly
translated scalar terminal occurrences requiring a literal or native-one
value conversion. It includes literal sites and the low-provider First/M
uses; it excludes completed nonconstant high operands and the separately
owned Length/aggregate initializers. The bound is still

```
J_e <= 2s_e + 4 + 5r_e.
```

The selected spine has s_e zero-test terminals and s_e+1 low leaves. Outside
it, nonnullable low/high use at most three further terminals (low twice and
the high's subtract-one). Nullable roots add at most five: the two zero
tests, the additional last-low, and the trailing-empty high's possible
unreduced `1-1`. Keeping an unused selected root when m_e=0 overcounts.
Every emitted low literal is 1; the tests/arithmetic supply 0/1. Native First
and M substitution returns a completed constant, followed only by the bounded
same-base scalar conversions just proved. Thirteen constant requests per
terminal safely cover its literal/conversion route (at most four here),
including a folded constant test if one occurs. This does not assume that
the terminal is a frontend literal, or that an attribute recursively unfolds
the earlier provider.
As in the imported scalar projection, array-prefix translation and any
dereference/pointer adaptation retain their separate provider/executable
owners; J counts the scalar bound result and its scalar conversions.

The accepted scalar-operation rows then apply with the actual s_e, r_e,
m_e, except that M may own two declarations and two DECL_EXPRs:

| Request | Effective bound per original scalar event |
| --- | ---: |
| C | 13J_e+4+2r_e |
| U, including DECL_EXPR | 2+r_e+2m_e |
| B | 2s_e+4r_e+3 |
| T | s_e+2r_e |
| Scalar declarations | 2m_e |
| Raw bytes | **520J_e+128s_e+368r_e+576m_e+344** |

The high's two arithmetic entries and nullable endpoint work retain their
previous rows. A constant M initializer is attached to its declaration; it
is not emitted again as INIT_EXPR. add_decl_expr creates one DECL_EXPR for
each CONST or debug VAR, and its extra INIT_EXPR branch requires incompatible
types or an invalid static initializer (`trans.cc:9103–9172`), both absent
for compatible scalar constant 1. Name, binding and statement storage services
are exported separately below. Summing the displayed row gives
**1168 sum(s_e)+2968 sum(r_e)+576 sum(m_e)+2424E <= 7136C**.
This replaces the old `520n_e+368r_e+344` claim for this family.

Generated assignment slices need a further correction. `exp_ch4.adb:3564–3633`
copies the original Low_Bound into both Lo and Hi. If r_e=1, each copy can
still be the frontend low IF just proved native-constant. It contains no
copy of the selected spine: any such spine is behind M's cached constant
declaration. Price each additional copied low IF by
**C40/U2/B2/T2 = 1840 bytes and 12 operand slots**. Its three terminal sites
(zero and two low-one arms) need at most 39 constant requests under the
terminal rule, with one spare for a constant comparison; two comparison
requests, two conditional requests and two unary candidates dominate even
the provisional/order alternatives. Pure equal-arm completion actually
returns 1. This allowance is for construction, not the final zero-node result.

The scalar bound translation for an assignment slice from event e is therefore
**3368+3680r_e <= 7048 raw bytes**. The worst row is C153/U8/B12/T4.
It adds both copied-low translations to the previously owned bound arithmetic;
duplicating the old literal allowance is conservative. The original event
already owns its original low translation. Slice translation itself reads the
completed type's lower bound (`trans.cc:7086–7118`); it does not translate these
two source roots again. Aliases reusing the index likewise do not repeat them.

For debug declarations use **576 bytes per distinct receiving signed index**
(one low and one high VAR, each with its DECL_EXPR). This replaces the old
288-byte high-only allowance. Assignment indexes already had the 576-byte
allowance. The extra constant-low debug variable does not change any root
or query grammar. Shared-index aliases do not get another index debug charge.

The effective local exports, on disjoint receiving families H and J, are:

```
layout bytes             <= 22288 * (sum_H(t_i+1) + |J|)
annotation Q             <= sum_H(26t_i+24) + 38|J|
annotation bytes         <= 1328 * annotation Q
maximum-query bytes      <= sum_(H union J)(80u_i+320)
Length-initializer bytes <= 2720 * sum_U(t_v+1)
original scalar bytes    <= sum_e(520J_e+128s_e+368r_e+576m_e+344)
assignment scalar bytes  <= sum_j(3368+3680r_parent(j))
index debug bytes        <= 576 * I
```

Here I counts distinct concat-produced classified signed indexes, not array aliases; U counts
actual Length initializer occurrences. Assignment roots retain H<=7/O<=19/Q<=19
per finishing root and 72752 combined raw layout/annotation bytes. Signed
Length retains H<=t+3/O<=13t+8. All depths t_i,t_v,u_i are source-derived and
at most C. The three corrected scalar/debug rows alone have coarse sum at
most **23536C**, using A<=2C and I<=4C; this is not a complete native total.

Additional metadata/service attachment is explicit. Each M adds one generated
source scalar entity, one N_Object_Declaration translation/alloc_stmt_list
entry, one entity association and one annotate_object call. It makes at most
two create_var_decl/build_decl/gnat_pushdecl/add_decl_expr calls, and at most
two statement-insertion service entries. Each new low-only debug declaration
adds one of those declaration/binding/statement service calls, using its own
generated debug name, but no new GNAT scalar entity. M's primary name is
shared by its corresponding debug variable. Raw declarations and DECL_EXPRs
are already owned above; name bytes, binding/statement/table backing, scalar
annotation services and other object metadata keep their existing separate
owners. Their call multiplicities must accompany these exports at the global
join; the displayed raw-node totals do not discharge those open services.

## Verification, review target and residuals

The changed-obligation check binds the original author/review and #217 input
commits, verifies immutable source archives/spans, and checks a two-stage
frontend/native model with nullable inheritance, selector captures, debug
alternatives, copied lows, entity reuse and frontend static-max gates. It
corroborates the new request rows and arbitrary-finite-C recurrences without
executing an old checker or rerunning accepted graph checks. It is not GCC,
generated-matcher, compiler, prover or Lean execution. Source correspondence
and domination are the argument above; finite cases do not replace them.

Selected author remains GPT-6 Astra / Extra High. Runtime model/effort
confirmation, tokens and monetary cost are unavailable. First repair clock:
2026-10-24 08:52:51 UTC. The new receipt records actual host, focused-check
elapsed time and elapsed wall time since that clock. Intended outcome: repair
the stage-confused induction while completing the same recursive family.
Material corrections: actual s/m construction, constant/declaration identity
bridge, copied low IF requests, optional low debug declaration, and actual
frontend static-max routing.

General input-low nesting is still the next indispensable provider family:
its native lows need not become 1, so exposed selectors can enter high
arithmetic. Full executable/check/call and pointer adaptation, metadata/type
variants, global syntax attachment, dynamic backing/incoming states and
downstream process composition remain open. #201/#119 are not complete.
The e<=2, two save-entering callbacks and three saves remain once per Why
process. Root owns issue disposition, review, integration and publication;
this repair makes no GitHub, goal or publication writes.
