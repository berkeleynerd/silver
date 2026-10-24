# R81: conditional producer report capacity complete

2026-10-24 UTC, #119/#193. The independently reviewed per-unit report functions
and selected fixed-process terminal attachment are integrated. **#193 is
technically complete at that conditional scope and In review pending delivery.**
The result does not complete the whole-invocation predicate or #119.

The [report derivation](../../research/retained-producer-report-capacity.md)
at final author `df1972ae38` covers full report construction, actual projection,
third-pool lifetime, holders/aliases, private diagnostics, Uint workspace/cache
and standard output state. The [terminal attachment](../../research/retained-producer-error-payload.md)
at `3be4ca682e` supplies the selected five-process error operand. The
[independent review](../../reviews/review-producer-report-capacity-20261024.md)
at `d568c0a38a` accepts their combined conditional boundary. Exact final and
historical inputs are retained in [inputs.json](inputs.json) and the review's
frozen audit and correction records.

## Repaired findings

| Issue | Accepted repair |
| --- | --- |
| #195 | Uint local normalization workspace uses q+2; returned descriptors use q+1. |
| #196 | Cold Uint cache initialization retains one process-wide descriptor and q+1 digits. |
| #197 | Provenance dependency pins an immutable audit instead of an evolving review note. |
| #198 | Silver retains whitespace: actual projected bytes use projected.pretty+1. |
| #199 | Statistics include three configured provers plus Trivial and Checker, agreeing with S<=5R. |
| #200 | Raw Dynlink fallback can select the quoted callback independently; both callback orders are bounded. |

All six are repaired and independently reviewed, In review pending delivery.
The original author branches and review branch are published alongside the
integration branch so historical `git:<commit>:<path>` inputs remain fetchable.
Cherry-picking by itself would not retain those original commit identities on
the remote.

## Useful terminal attachment and residual scope

For the selected fixed processes, let L=max(4096,4P+3072), Q=L+3P+5552 and
Qearly=L+1536. The pre-normal bound is max(2Q+7689,3Qearly+7177); the separately
derived post-cut alternative fits beneath it in the useful displayed region
180<=P<=558. The ceiling is 30,761 bytes at P=416, 32,749 at P=558, and fails
the sufficient Compiler_Abort spare-space guard at P=559. These are conditional
applications, not measured configuration or a new language path cap.
An interrupted-normal error value has its own 5,067-byte suffix bound. The
whole mixed normal file is **not** bounded by that suffix or pre-normal bound.
The larger file/private allocation bounds remain required.

Generic Main may conservatively use #186's response-byte bound for an error
operand. That alone does not show a useful native diagnostic guard. Tightened
arbitrary-Main failure/storage lifetimes now belong to [#202](https://github.com/berkeleynerd/silver/issues/202).
Actual pathname, clock/duration, configuration and source-behavior refinements
remain explicit parent/#88/#89 obligations. Prospective brief output retains
report-all; no production invocation changed.

[#194](https://github.com/berkeleynerd/silver/issues/194) is In progress with
independent review of required GNATprove collectors, unconditional SARIF and
Silver readers. [#201](https://github.com/berkeleynerd/silver/issues/201) extends
native compilation beyond #145's literal family; #202 supplies ordinary Main
Why representation lifetimes. After these, #119 still requires checked
whole-rule composition, relevant source correspondence, useful-domain
comparison and final independent review. The prior approximately 85% estimate
remains low-confidence; this round establishes no new percentage or ETA.

## Validation and working settings

The new [identity-only integration](integration-result.json) reconciles the
34 frozen component files, 32 historical review pins, 48 provider dependencies
and 94 unchanged native source pins. It passed in 0.515814 seconds. The
[record check](links.json) also verified 753 local file links. An initial
integration assertion expected the literal status `pass` from a report whose
actual status was `focused checks passed; source attachments remain open`;
the reader was corrected to preserve the exact recorded scope. No component
checker or native/compiler/prover/Lean/predecessor check was replayed.

The reviewer ran one report audit (6.051087 seconds invocation time) and one
terminal audit (7.615937 seconds). Later narrow repairs received source/delta
review and retained changed-input author checks. Model/effort selections for
both authors and the independent reviewer were GPT-6 Astra / Extra High.
Runtime confirmation, whole-team elapsed time and isolated token/cost telemetry
are unavailable; the lead setting cannot be confirmed through this interface.
Six material accounting/record gaps were repaired and a required component
was accepted. That is observed progress, not a causal comparison of models.

Oracle, tools/pins, admission, physical-resource premises and one process-wide
e<=2/two-callback/three-save allowance are unchanged. Production #88–#94 stays
unstarted pending the complete prerequisite. PR #121 remains draft/unmerged;
merging is unauthorized. The harness display remains paused while the owner's
continuation authorizes project work. CLI memory is unavailable.
