# Independent result and tracking review

Frozen target: `2b47dd8e27f10251d57df35385161acfcc1a41a9`, Linux integration worktree `tmp/unbounded-feasibility-linux`.
Reviewer: planning lane, 2026-10-17.

## Verdict

No blocker or remaining material defect in the research conclusion. Publishable as a precise research stop after completing the already-pending review/publication bookkeeping. The low evidence-wording item below was corrected and its disposition verified. It is not a supported-capability or implementation acceptance.

## Finding L1 — low: six retained runtime files are not six compiled units

In `docs/research/unbounded-feasibility-result.md`, the first bullet of “What #108 establishes” says the specimen “and six current runtime source files compile, bind and link”. The backend continuation correctly distinguishes the six copied inputs from the actually compiled units. Both retained link `stderr.txt` files list compilation of `main.adb`, `silver_io.adb` and `silver_output_libc.ads`, then `gnatbind` and `gnatlink`; no argument-runtime compilation is recorded.

Suggested correction: say the unchanged specimen compiles, binds and links using the unchanged runtime snapshot, and separately say six runtime source files were retained. This does not affect the link outcome or frontend obstruction.

Evidence: `docs/evidence/unbounded-programs/static-data-continuation-20261017/probes/ada-1mib-link-{medium,large}/stderr.txt`; `docs/research/unbounded-static-data-continuation.md`, “Three discriminating Linux probes”.

## Reviewed conclusions

- The synthesis and source-capacity record label the two-chain result as source-derived, conditional on inspected source/binary correspondence, and explicitly exclude a giant native failure run. They retain tail-sharing counterevidence and separate unchecked growth arithmetic from the structural character-pool limit.
- The concrete specimen is an example for the intended enlarged fragment, not today's admitted Silver. The result does not infer that enough RAM or a backend code model repairs the frontend representation.
- The zero-mantissa exponent claim is attributed to the new frontend lifetime audit and exact arithmetic, not a native repeated-literal threshold or RSS measurement.
- Source-position arithmetic, recorded trace observations and the missing full expansion/allocation argument remain separate. The qualitative candidate comparison does not claim an optimality theorem or prove source-sensitive rules impossible.
- Native evidence attribution is otherwise consistent: two complete small Ada links, one assembly-only mutable probe, retained C zero-fill proxies, no application execution or proof run, unchanged 4096 runtime contracts, and distinct continuation Linux/earlier Linux/macOS identities.
- Both research issue bodies explicitly allow completion by a precise full stop with alternatives and independent review. The result leaves unfinished soundness obligations on parent #91, keeps #93 and #88–#94 unstarted, and does not adopt a cap, tool pin, new guarantee premise or Oracle amendment. Further wider/lazy feasibility work is a recommendation requiring owner disposition.
- Live #107/#108 comments at review time show this session's continuation claim; issues remain open. Final research closure must follow accepted review, publication and parent/decision handoffs, not close the implementation milestone.

## Actual review scope and limits

Read the frozen root synthesis and source-capacity record, frontend lifetime and backend continuation records, exact arithmetic/tree-verification summaries, backend probe summary/identity/commands/results and compiler diagnostics, the two-chain source, and live #107/#108 completion criteria and comments. Reviewed source/observation attribution and authority/closure consistency. The backend and frontend lanes separately review each other's detailed mechanisms.

Excluded this reviewer's own `RESUME.md`, session memory, roadmap, scope edits and source-position reconciliation evidence from any independent-review claim. Did not independently rerun the full pinned-tree inventory or reproduce the entire lifetime call graph. No compiler/prover/test/application invocation, new probe, implementation edit, GitHub write or integration-worktree edit was performed for this review. Root owns the comprehensive manifest/link/whitespace/unchanged-input checks.

## Follow-up disposition verified

After the frozen review, root corrected L1 in the integration worktree: the specimen is now the subject of compile/bind/link, with six retained runtime files explicitly distinguished from imported units actually compiled. The independent frontend review also qualified the witness as using proposed constructs/value bounds subject to the still-unselected source-capacity rule. I re-read both exact changes; they resolve the wording concern and preserve the research conclusion. No remaining finding from this review.
