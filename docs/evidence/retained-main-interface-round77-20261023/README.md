# R77: ordinary Main source-to-typed interface accepted

2026-10-23 UTC, Linux x86_64, #119/#178. The complete ordinary Main
[source/typed body and contract interface](../../research/retained-main-callers-profile.md)
is independently [accepted](../../reviews/review-main-callers-4a4d15cd02.md).
Code and diagrams are frozen at `ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c`,
receipt-only additions at `7ab729be0bfaf393f462f070d9a09af614c87567`, and final
review at `6031a189e04b710a2858823b9e38165838a37079`. The earlier complete
ignored-child and loop-frame source reviews are retained alongside the final
review. [inputs.json](inputs.json) identifies each exact input.

This completes #178's technical scope: the source-indexed constructor fold,
implicit clauses, actuals and selected contracts, lexical bindings/effects,
variable-domain U and outcome-key H. The review repaired three draft defects:

- [#182](https://github.com/berkeleynerd/silver/issues/182): every retained sequence creates an anonymous Unit variable, now included in the initial key union and definition/context link.
- [#183](https://github.com/berkeleynerd/silver/issues/183): arithmetic overflow and expected-type range conversion are independently selected checks, both retained when present.
- [#184](https://github.com/berkeleynerd/silver/issues/184): ordinary String inequality follows the frontend's `not (=)` rewrite, including the program conditional.

These are research-model repairs. Current production code, source membership,
the Oracle and installed tools/pins are unchanged. #178 and its repaired
findings are In review pending delivery through draft PR #121; #119 is still
In progress. No partial child result completes its parent.

The author's final focused check passed 29,358 assertions over 60 diagrams in
11.411849 seconds. The independent initial audit passed 136 checks in
6.500877 seconds; the final changed-seam audit passed 6,513 in 1.289047 seconds.
The recorded review interval is 904.755 seconds, including source review and
waiting for the repairs. Those identity/arithmetic checks support the separately
reviewed source induction; they are not a universal proof by examples.

[Integration](integration-result.json) reconciled 28 frozen files, 18 inherited
providers, 94 unchanged native source pins and the unchanged installed Why
identity in 0.364759 seconds. The first integration attempt exposed a missing
early-review checkpoint in the parent tree; its exact committed file was then
imported. No component checker, native target, compiler, solver or Lean replay
was performed. All earlier successful receipts are preserved.

The source fold consumes source-derived frontend indices under the accepted
guard correspondence. It does not parse `Ptree.Modules`; native triple/optional
signature attachment remains with the parent and must not be generalized from
the captured fixed family. No extra parser or arbitrary caller certificate is
introduced by this interface.

The next Main edge, tracked in [#185](https://github.com/berkeleynerd/silver/issues/185),
is structured typed bodies/contracts to `k_expr`/`k_fun`,
`reflow` and initial VC formulas, preserving lexical terms and outcome vectors.
Then attach reachable imported marked definitions and aliases to each VC and
apply the accepted matcher/unfolding and terminal-goal transfers. Scalar kode
totals alone do not supply this composition. Fixed failed-prefix composition
and driver repair #181 remain active independently. Full current-grammar native
coverage, required consumers, checked whole-rule composition/correspondence,
useful-domain comparison and final review remain required for #119.

Critical author and reviewers selected GPT-6 Astra / Extra High. Runtime
confirmation, live lead settings and token/cost telemetry are unavailable.
[round.json](round.json) records measured checks and integration separately;
no whole-team cost is inferred. The estimate remains approximately 85%, low
confidence and not an ETA. Existing physical-resource premises and the single
global e<=2/two-callback/three-save allowance are unchanged. Production #88–#94
remains authorized but unstarted. PR #121 remains draft/unmerged; merging it
is not authorized. CLI memory is unavailable and was not updated.
