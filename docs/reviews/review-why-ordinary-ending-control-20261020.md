# Independent review: ordinary-ending save control

2026-10-20 UTC, owner-authorized #119 / #153 research.

**Accept the conditional source/control transfer at
`f4425cc0b0ae2cf81596354efec38d7ecb8f8385`. No material defect found.**
This accepts one ordinary-save entry, preservation of the selected raw logical
forest, the qualified interrupted-save reasoning, and the nullable B/J/G/L
products. Numerical composition remains blocked on the explicit caller
obligations below. This is not completion of #153, complete saving, artifact
correctness, identifier-counter safety or proof-pipeline capacity.

## Exact inputs and review scope

The target is the ten-file addition against base
`1f510363e40a7c18558743bef0c28f41d06f83db`: the
[research argument](../research/retained-why-ordinary-ending-control.md)
and all nine files in its
[packet](../evidence/retained-why-ordinary-ending-control-20261020/README.md).
The isolated review checkout is `tmp/review-why-ordinary-ending-control-20261020`,
branch `review/why-ordinary-ending-control-20261020`, created directly at the
frozen target. All ten files were compared byte-for-byte with that commit.
The separate all-five session packaging is not an input to this review.

Selected independent reviewer: **GPT-6 Astra / Extra High**, as assigned by
the lead; serving-runtime model/effort confirmation is unavailable. The
reviewer authored neither the implementation nor its source argument. No
subdelegation occurred. The lead supplies the owner's active resumption and
bounded authorization; this child has no separate live harness goal.
Applicable AGENTS, Oracle and review-bookkeeping requirements are retained
from the preceding bounded review. No Oracle, tools, current admission or
production change is assessed or authorized by this acceptance.

Source inspection used the pinned retained Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84` archives. Existing selected
scheduler, callback-protocol, native-owner and save/exit reviews are reused
at their stated scopes. Their old process-specific numbers are not inputs.
The source-to-relevant-behavior relation remains the documented premise;
this review does not create installed-binary correspondence evidence.

## Control and logical state

`gnat_scheduler.ml:18–26` calls `ending` in the `Exit` handler, outside the
protected scheduler loop. `gnat_main.ml:271–275` contains one ordinary save
after cleanup; `Debug.Stats.record_timing` and `Fun.protect` execute work once.
The outer GNAT catch either reraises or reports/aborts. A failure in a handler
body is not recaught by that same handler. None of these continuations returns
to ordinary ending. Zero or one ordinary-save entry is therefore correct,
including cleanup failure and timing-finally failure.

The accepted fresh Per_Check/CE-off/non-replay envelope excludes later splits,
CE grafts and interactive client mutations. Driver preparation takes a
persistent task value and does not replace `session_raw_tasks`.
`session_itp.ml:645–735` separates attempt writes from proof-node and
transformation creation. Cleanup's `APa` arm removes attempt bindings;
inspection through `session_itp.ml:737–957` also confirmed that its upward
status propagation writes status tables and notifications, not raw tasks or
forest links. Partial attempt-table changes need not be rolled back to
preserve the logical projection.

Direct saving resets shape state and reads F through `fold_all_session`.
`goal_expl_task`, shape construction and the opening functions create
transient values; they do not install substituted terms into F. The source
terms/patterns and task constructors are persistent. Under the caller's
well-formedness, opening/freshness and native frame premises, the APn occurrence
domain and represented formulas remain fixed. Roots, uninteresting tasks,
repeated occurrences, delayed substitutions, triggers and pattern variables
cannot be dropped from the caller's certificate. Attempt visits may change;
they do not introduce another binder walk in this save traversal.

## Catches, reentrancy and signals

The receiving-catch ledger supports the claimed no-retry property. In
particular, `Task.local_decls` protects a recursive suffix selection and may
recompute that suffix after `Not_found`; it performs no binder opening and
returns an ordered selection before shape traversal begins. Explanation
`Exit` ends its search. Shape `ShapeTooLong` abandons the current proposition.
Name/cache misses take local fallback branches, while shape/prover-map
fallbacks can retain interference. Pattern arity translation does not rerun
the completed variable-cloning operation. Container exception cleanup
reraises without replaying its user callback. These distinctions justify
bounding an interrupted save's binder work by the full conservative walk.
They do not bound arbitrary diagnostic printing as zero.

`save_session_and_exit` catches `Invalid_argument` only around signal setters;
save and `exit` lie outside that catch. Successful exit is terminal; a save or
exit-hook exception propagates through `caml_callback_exn` to the interrupted
operation. The retained complete Buffer and Format implementations have no
receiving catch that converts that exception into a normal Buffer return.
Under the stated native interfaces, the interrupted resize/append cannot
later publish its stale saved position. A higher ordinary-save catch may
continue, reading the then-current state. The argument correctly avoids
transactional or serialization-consistency claims.

The two-callback bound is freshly justified for the stated ordinary-ending
interval. Under successful POSIX mask/ignore, a single eligible worker, no
unmasking/reinstallation and the continued native-owner effects, the runtime
clears the pending bit and blocks SIGINT before calling the handler. Ignore
commits before save. A stale bit recorded between clear and block permits one
later dispatch after exception/mask restoration; no producer can refill it
after ignore. Thus at most two callbacks enter save, and the first handler's
save stack has unwound before a second can enter. Arbitrarily many external
pre-ignore deliveries do not imply an unbounded queue.

This result must not be imported merely because the earlier first-inline
interval had the same number. It requires the later entry's continuing
configuration. Pre-save failed service attempts, earlier signal saves, other
callbacks and successful later reporting are not globally bounded here.
Selecting a remaining budget below two requires its own justification.

## Quantitative interpretation and unresolved joins

Given valid bounds for the actual preserved F, `1+k` traversals yield the
stated B/J/G products. L must bound full untruncated shape-output bytes,
including all allowed constant/name/alpha/suffix outcomes. It cannot be
replaced by 1,024, graph size or an observed output. Clears reduce position;
charged successful appends account for increases. With stale append resumption
excluded, `(1+k)*L` bounds position **after the first save-owned clear**.
It does not bound entry position or retained backing capacity.

The transfer uses exact-True source premises, rejects malformed natural
inputs, leaves missing quantities null, and exposes mathematical products
separately from tagged-integer/String guards. It never asserts that supplied
bounds have been derived from an actual forest, nor promotes a passing
product guard into complete save/counter/pipeline capacity.

The following are blocking dependencies for numerical or broader composition,
not new defects in this conditional transfer:

| Missing join | Required consequence before stronger composition |
| --- | --- |
| Actual controller/session F and B/J/G/L certificates | Bind every relevant APn occurrence and complete opened/atom domain, including root and uninteresting tasks. No old PID 97103 constant substitutes for this join. |
| Opening/freshness, starting counter and other identifier owners | Establish the entry invariant and charge scheduling/preparation, diagnostics and every remaining owner; B alone cannot establish no wrap or freshness. |
| Later-entry signal/native/representation configuration | Establish that the named installed handler, worker/mask/ignore/no-reinstallation and frame/effect contracts still hold with the actual later domains. The earlier scoped native acceptance is not this certificate. |
| Buffer entry/backing and save representations | Supply all required allocation, lookup, map/scalar/prover-ID, formatter, channel/path and serialization bounds; the post-clear byte product alone does not cover them. |
| Saved-artifact consistency where assurance requires it | Either restore the needed shape/dictionary/prover-ID invariant or prove the relevant dependency does not need it. Raw-forest preservation does not establish inverse-map consistency or a faithfully readable artifact after partial nested mutation. |

The frozen packet explicitly retains these boundaries. Its source/control
result can be integrated while those #153/#119 obligations remain open.

## Checks and measurements

The retained [review checker](../evidence/review-why-ordinary-ending-control-20261020/check.py)
and [result](../evidence/review-why-ordinary-ending-control-20261020/result.json)
record one focused author-check replay and independent boundary/premise checks.
The replay passed: 14 input identities, 25 source members, 47 exact excerpts,
20 receiving families, 33 anchors, the full Buffer/Format no-catch projection,
the 24-state protocol model and 37 transfer checks. It took **0.609624080 s**.

The reviewer added 66 checks of product boundaries, unknown inputs, strict
premise handling and malformed natural inputs. An independent abstract
protocol reaches at most two saves with ignore; removing that premise admits
a third. A deliberately forbidden stale-Buffer-resumption witness shows why
the no-return result is needed before discarding entry position. These are
conditional abstraction checks, not native executions or machine-checked
source refinements. Total review-check time was **0.766421711 s**.

Source inspection began at 07:28:05 UTC; the source/evidence checkpoint ended
at 07:32:52 UTC: **287 seconds**, excluding final report authoring and commit.
Actual host is Linux x86_64, kernel 7.0.14, glibc 2.43, confirmed with
`scripts/dev.py paths` and Python platform data. Runtime selection confirmation,
token and monetary measurements are unavailable. No native capture/target,
debugger, compiler, public evaluator, proof, Lean or broad predecessor suite
ran. No GitHub or CLI-memory write occurred. Required rework: none within the
reviewed conditional scope.
