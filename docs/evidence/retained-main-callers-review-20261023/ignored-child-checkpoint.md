# Main ignored children and local-function effect audit

2026-10-23 UTC. Bounded source audit requested by the Main author and root;
**not final review of the still-mutable caller implementation**. Selected
reviewer GPT-6 Astra / Extra High; runtime confirmation, active elapsed time,
token usage and cost are unavailable. No subagent, target, compiler, solver,
proof or capture was run. Author code/checkers were neither imported nor run.
The accepted construction basis remains
`767007bf43ad1a7ef82b8d629ab460b6186f694e` and its existing independent review.

The result supports **xf=lost=lemma=rlpv=0 for ordinary Main**, with the
existing Main grammar, complete frontend shape result, selected fixed-call
contracts and source/native premises attached. This does not erase warning
Cfun's normal result/k_fun work or the two local loop handlers and one Main
Return handler. It does not establish the continuation's numeric U/H result.

## Exact inventory scope

[ignored-child-sites.json](ignored-child-sites.json) scans all279 `.adb`/`.ads`
members under `spark-source/src/` in the retained complete raw archive. It
retains118 textual references in12 files, including declarations/end references;
these are not claimed to be118 reached calls. Every matched complete member
has its byte identity and each reference has a numbered context. The additional
raw `W_Abstract_Expr` inventory finds only kind/schema declarations and an
existing traversal case; no extra hand-written constructor route is hidden
behind that spelling.

This broadens the initially supplied15-file scratch to the complete retained
SPARK source. Reachability is the following source argument, not a deduction
from token counts. Source locations are relative to `spark-source/src/why/`;
Why locations use the exact members identified in
[ignored-child-inputs.json](ignored-child-inputs.json).

| Construction family | Ordinary Main reachability and child |
| --- | --- |
| `why-gen-progs.adb:199–213` New_Ignore | Constructs a discarded-value binding, unit context and True-post Abstract_expr. It does not itself suppress child raises. |
| `gnat2why-expr.adb:31187–31204,31245–31260` | Reached/optionally reached dead-code/branch and inconsistent-assume warnings ignore only the newly made Assert/Check False. The original source child remains a separate sequence member; no loop/Return is hidden inside this ignore. |
| `gnat2why-subprograms.adb:4724,5376` | Main's empty post/pre Compute_Spec results are True. Converter removes the pure discarded binding and then the True-post abstraction. Location/attribute wrappers do not change that recursive purity test. |
| `gnat2why-expr.adb:3798–3818` | Generic Check_Scalar_Range can ignore program evaluations of non-OK-static source endpoints. Current Main range endpoints are Ada-static; the accepted capacity result at1559–1597 supplies either the immediate Void route or static-declaration exclusion. Keeping a conservative scalar-expression child would still be raises-empty by the selected scalar-call induction. |
| `gnat2why-expr.adb:23131–23141` | N_Itype_Reference could ignore an arbitrary associated expression, including a String expression. It is **not inherently scalar**. The existing complete frontend caller proof in `retained-producer-capacity.md:1767–1812` establishes zero such ordinary Main translations, including generated Actions and relocated bounds. That result is reused without replay. |
| `why-gen-expr.adb:1311–1340` | Sliding to a nonstatic unconstrained target with fixed lower bound can ignore a conditional pair of scalar range-check programs. The accepted Main String shape at `retained-producer-capacity.md:653–705` and construction row at112–116 exclude this target family. Mere unconstrainedness would not suffice. |
| `gnat2why-expr.adb:30650–30663` | Literal construction can ignore a located range Assert. Accepted static literal/lower-bound/Integer-index premises discharge the selected guard. Even retaining this fallback gives an assertion-only, raises-empty child. |
| `gnat2why-expr-loops.adb:238,854,1708` | Respectively user loop variant, explicit loop invariant RTE, and iterator filter skipping. Main has none of these source features. Its implicit invariant generation does not use these ignore sites. |
| `why-gen-expr.adb:452,600,658` | Modular no-wrap checks. Main arithmetic is signed Integer; no modular type or bitvector arithmetic source family is admitted. |
| `gnat2why-expr.adb:1233,30008,30051` | Explicit/unhandled raise-message evaluation and delay statements. Neither source feature is admitted; the frontend admitted-static-expression and light-expansion results do not inject those caller families into Main. Ordinary RTE checks are contracts/assertions, not a generated exception-message evaluation. |
| `gnat2why-expr.adb:1880,3039,3159,3276,3353,3390,3482,3680,5122,5239,5343,6381,7748,11594,11765,13573` | Default initialization, memory/ownership, DIC/type invariant/Iterable, exceptional out-parameter stores, overlays and user equality invariant checks. All objects are initialized ordinary Integer/String objects; selected fixed calls/types have no relevant DIC/invariant/ownership/tag/exceptional-formal feature. |
| `gnat2why-expr.adb:14485,14493,15300` | Slice/component update and lvalue conversion/check paths. Main assignment targets are whole named objects, with no slices/components, explicit qualifications, conversions or borrow paths. |
| `gnat2why-expr.adb:16932,16965,16997,17099,17225,18879,18894,19009,21769,21770,21791,23345,23546` | Array/delta aggregates, Boolean-array logical operations and discrete-choice/update-equality branches. Main has no aggregates, array-element Boolean operations, cases or update attributes. String equality follows its separately accepted ordinary array-equality route. |
| `gnat2why-expr.adb:20600,20612,20687,22827,22840,23188,24458` | Valid/Constrained/Address attributes, Address clauses, renamings and exponentiation-zero operand evaluation. The admitted attributes are the selected Length/Image forms; these other attributes/clauses/renamings and exponentiation operators are absent. |
| `gnat2why-expr.adb:21251,21368,26659` | Dynamic termination checks and predicate/out-pointer checks. No dynamic termination condition, variant, null-pointer out formal or user predicate is present on the selected Main/public-call route. |
| `gnat2why-expr.adb:26144,26345,28104,28571,28706,29975,30128,30145` | Cutpoint/assertion pragmas, quantified-expression checks and Assert_And_Cut wrappers. Main admits only its initial SPARK_Mode pragma. In particular the whole preceding statement sequence can be hidden by30128/30145 in general Ada, but these branches are absent here. |
| Other `gnat2why-subprograms.adb` references | Contract/exit cases at2375,2512,2833,2850,3064; LSP/dispatch checks3630–3849; package/protected elaboration4019,4413; dynamic Main pre/refined-post blocks4675,5103,5107; contract-case old binding5236; absent post/exception/exit checks4764,5459,5514,6081. Current Main has no matching contracts, dispatch, package body, protected type, source handlers or program-exit specification. These guards were also traced in the earlier caller checkpoint. |
| `gnat2why-expr-aggregates.adb` seven references | Container aggregate annotations and deep delta aggregates, all excluded. |
| `gnat2why-subprograms-pointers.adb:171,490`; `why-gen-pointers.adb:1953`; `why-gen-records.adb:4856` | Access-subprogram conversion/LSP, pointer update and record-field update, all excluded. |
| `gnat2why-types.adb:1170,1202,1274,1295,1310,1374` | Separate type-VC bodies for private/default, Iterable, primitive equality, aggregate and ownership features. No ordinary Main type has these features; these are also not anonymous blocks inserted into Main's executable body. |
| `why-gen-hardcoded.adb:524,699,1017,2011` | Big_Integer conversion/validity, Big_Real validity and Real_Time.Split. They are not the selected Integer Image or approved library operations. |

`New_Abstract_Expr` itself has only the New_Ignore and New_Located_Abstract
construction sites (`why-gen-progs.adb:212,227`). All New_Located_Abstract
callers are Main precondition `subprograms:4675`, refined postcondition5107,
or Assert_And_Cut `expr:30145`; all three guards are false here. This closes
the possible wrapper-around-an-entire-loop seam. An assertion failure in Why
is an obligation, not an escaping program exception.

## Typed local binding and Cany/Cfun classification

Converter `gnat_ast_to_ptree.ml:731–758` makes Any_expr as Eany with an empty
parameter list and RKnone, then a local value binding. `:889–905` makes a
surviving Abstract_expr as Efun with an empty binder list, unit body/result,
and its normal post. Its specification has no exceptional posts. Ordinary
bindings at600–611 and reference bindings766–785 use the smart constructor
`ptree_constructors.ml:123–124`, whose kind is RKnone. Sequence lowering
`typing.ml:1126–1129` also makes an RKnone value binding.

The selected value constructors, fully applied fixed signatures, nullary
Any_expr and nullary abstract blocks have `de_dvty=([],result)`. This is
**program callable arity**, not a claim that all represented data types are
nonfunctional: an array map's logical representation does not by itself give
a local binding a nonempty program argument list. Source has no function-valued
local declaration or partial application. The earlier fixed/construction
interfaces supply actual call signatures and argument counts.

Both `dexpr.ml:1528–1530,1572–1575` therefore choose `var_defn` for local lets.
`var_defn:1719–1730` calls `Expr.let_var:721–724`, producing LDvar. It does not
silently turn a nullary Cfun or Cany into LDsym. Non-variable application-argument
proxies likewise use `mk_proxy_decl` (`dexpr:1424–1430`, `expr:859–861`), hence
LDvar. The separate `proxy` branch at `dexpr:1500–1509` needs a DA application
argument left over when a DEfun/DEany callable is processed; no selected
nullary abstract/any is subsequently applied to arguments. Imported named
functions route through c_app, with the complete selected argument vector.

There is consequently no reached body Elet LDsym/LDrec family. In addition,
`typing.ml:877–879` changes only local RKfunc/RKpred to RKlocal; native local
mk_let supplies RKnone. `Expr.create_rsymbol:112–150` creates RLpv only for
RKlocal and RLlemma only for RKlemma. Neither kind is introduced into ordinary
Main. Main's **top-level declaration** is an LDsym/RKnone and selected imported
logical/program definitions retain their separate storage/contract treatment;
that does not create a body-local LDsym or inline their definitions per call.
This distinction is required when asserting `lemma=rlpv=0` for body VC traversal.

Any_expr effects come from its explicit native Effects field; omitted effects
produce empty reads/writes/xpost. The selected range/Boolean-lifting Any_expr
helpers specify normal pre/posts only (`why-gen-progs.adb:127–162,263–269`,
`why-gen-expr.adb:404–416`). Cany is not itself a lambda body and contributes
no hidden `k_fun` traversal. Do not erase its normal result/pre/post work.

## Exception-frontier consequences

The surviving warning Cfun body contains Assert/Check False, a discarded-value
binding and unit. `Expr.e_assert:1116–1118` has reads only, with no raises.
Empty Main pre/post ignores disappear. Any conservative retained scalar/literal
check child uses the raises-empty fixed-call and expression induction. No
ignored child encloses a source loop, generated Return or escaping callee
exception. The complete-site argument above is what permits this statement;
the name New_Ignore alone would not.

`dexpr.lambda:1773–1789` types the child body first and passes its actual effect
to `Expr.c_fun`. `Expr.e_exec:755–773` deliberately preserves the full underlying
effect for nullary Cfun, apart from exceptions killed by false xposts. Thus the
raises-empty child argument is necessary. It is now supplied, without claiming
that an empty declared native Effects record generally implies an empty effect.

The selected fixed callees have no escaping exceptional contracts. Main's
generated loop Exit/Continue and final Return are caught in their own existing
Ematch scopes; those handler constructions are still counted. The top Main
Cfun therefore also has an empty escaping raise set after those catches.
`vc.complete_xpost:552–561` has no nonempty exceptional entry to complete,
and `k_fun:1010–1018` allocates no exceptional continuation/result for these
functions: **xf=0**. At a white-box Cfun's loss route (`vc:649–654`), the
underlying effect has no raises and there is no exceptional post, so its
lost map is empty: **lost=0**. No suppression-by-name or final-effect-only
shortcut is used.

`vc:786–835` reaches lemma/RLpv handling only through body-local LDsym/LDrec,
already excluded. Therefore **lemma=rlpv=0**. The ordinary abstract-Cfun
branch at `vc:746` still calls `k_fun` and obtains a fresh normal result via
`wp_of_post`; keeping these costs is essential. Each retained loop handler
still contributes its previously established `nh=unit_h=2`, with one more
of each at Main's Return handler. Nothing here changes those nonzero counts.

The current author is integrating this source classification into its caller
catalogue and body fold. Exact frozen implementation review remains pending;
this source audit must not be described as accepting its mutable Python.
