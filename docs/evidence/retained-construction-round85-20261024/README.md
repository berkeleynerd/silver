# R85: reviewed Main mapping and native annotation transfers

2026-10-24 UTC, #119/#201/#202/#211. Two bounded transfers are independently
accepted. #211 is repaired and In review pending delivery. #201/#202/#119
remain In progress; neither transfer completes the missing source callers.

| Component | Exact author freeze | Exact final review |
| --- | --- | --- |
| Main stored contract mapping | `3f4f6143c206518bf257d3d9b63cee2a08d14bcd` | `536c35cd2c36ac43dee39e1d6d8a8321d60fc070` |
| Native annotation transfer | `26bd01de61242d49f4680d609b38d09e3a51925f` | `4d23e53e9c78a991815e2e4b9b205ff75676bff2` |

The [Main argument](../../research/retained-main-construction-demand.md)
establishes saved-image support, capture-aware type instantiation, stored-node
and freshening recurrences, per-root type memoization, Hsty request counts and
the actual cty pre/post/xpost dispatch. It preserves stored images and their
outer variable interpretation rather than counting only the opened formula.
The [review](../../reviews/review-main-construction-demand-20261024.md)
found that injective type-compatible mapping alone can capture a free variable.
For `forall v. R(x,v)`, mapping x to v produces the counterexample.

The #211 repair supplies sufficient root coverage, injection and fresh-target
conditions, with an induction over saved-key/binder extensions. The native
`t_subst_types` entry constructs these conditions. The negative case remains
reproducible in the raw mapper and is rejected by the proof interface; native
Why3 is unchanged. Actual clone callers still need the complete inherited
`sm.sm_vs` / `cl.pv_table` history argument. Fresh formals/oldies alone do not
establish it. Source caller counts, native storage and kode/SPWP construction
remain explicit #202 obligations. Earlier author `5d9ed9375c` and provisional
review `62dee51822` are retained as the finding/repair history.

The [native transfer](../retained-general-native-capacity-20261024/dynamic-helpers/README.md)
bounds annotation work by `Q <= 2*3^h-1` for a certified finite acyclic native
annotation operand graph of height h. It includes failed shortcut retries,
synthesized constants/NEGATE and a recursion-depth bound h+2. Mixed allocation
and callback coefficients reuse the accepted constant and frontend overlays.
An exact capped evaluator avoids materializing the exponential. The
[review](../../reviews/review-native-dynamic-helpers-20261024.md) accepted this
conditional transfer without a material finding.

One arithmetic wording clarification applies to the frozen author note:
exponentiation-loop products are at most `(cap+1)^2`; the final doubling is
at most `2*(cap+1)`. At cap=0 its intermediate is 2 and the returned minimum is
still correct. This clarifies the intermediate bound without changing the
algorithm, exports or asymptotic space result; no repeated audit was needed.

The source-generated height, cumulative dynamic folding candidates and
decreasing rewrite rank are still missing. The next native work specializes
actual current-grammar dynamic roots, beginning with the generated Image
slice, rather than assuming arbitrary GCC folding terminates within a guessed
multiplier. Full imports, objects/executables and downstream phases remain.

The Main final audit checked 1,446 assertions and 120 constructive diagrams in
0.763001 seconds; its measured repair-review-through-audit interval was 178
seconds. Native review checked 19 sources, 20 author witnesses and three extra
spans, 832 branch traces, 3,049 capped comparisons, 18 large-height boundaries,
1,000 family sums and 125 coefficient cases in 0.402497 seconds; its measured
review-through-audit interval was 246.591155 seconds. Report/commit preparation
is outside those intervals. Each final audit ran once, with no author or
predecessor checker replay or native target/prover/Lean run.

[Integration](integration-result.json) reconciled exact frozen files, source
archives, four Main providers, eight native dependencies, the two review input
sets and 94 unchanged native pins in 0.255960 seconds. It did not replay a
component check. These source and finite arithmetic checks are not a
machine-checked universal proof of the whole compiler or of #119.

Authors and reviewers selected GPT-6 Astra / Extra High. Runtime confirmation
and isolated token/cost measurements are unavailable; the lead model setting
is not confirmed through this interface. Review produced one substantive
premise repair and one wording clarification. No causal model-performance
comparison is inferred. Continued author work owns the native source envelope
and Main clone-caller history in their existing separate worktrees.

R84's accepted #206 provider and #208–#210 repairs remain accepted. Complete
#201/#202, actual parent/provider and fixed-source joins, checked whole-rule
composition/correspondence, useful-domain comparison and final review remain
#119 work. Approximately 85% remains a low-confidence estimate, not an ETA.
Oracle, tools/pins, admission, resource premises and the one global
e<=2/two-callback/three-save allowance are unchanged. Production #88–#94 remains
unstarted; PR #121 remains draft/unmerged without merge authorization. CLI
memory is unavailable; the harness still displays paused under recorded owner
continuation.
