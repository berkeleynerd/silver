# Disposition of review-a3af180047

2026-10-19. The [unaltered independent review](reviews/review-a3af180047.md)
examined research completion `a3af180047`, with native implementation freeze
`4f29a3bf85`. It found **no blocker**: the 475-condition selected native rule is
sound in the rejecting direction under its recorded premises. This maintenance
changes records and tracking, not that rule. #119 remains paused in Backlog;
#145 stays In review in draft PR #121. The approximate 80% is subjective, with
substantial whole-rule integration uncertainty, not a measured completion rate
or remaining-time forecast.

## Production adoption obligation — M1

The research covers Main compilation, direct binder generation, binder
compilation and linking as four jobs. It adds `-gnatx`, `-fsplit-wide-types` and
`-Wno-free-nonheap-object` to the selected `-gnat2022 -gnata -gnato` route,
uses direct `gnatbind -x`, parent-generated configuration/mapping files and a
fixed two-unit Silver source/object/ALI bundle. It has no GPRbuild/Gprbind or
implicit dependency regeneration. Production `src/silver.adb` still launches
`gprbuild -P program.gpr` over a seven-unit project using the original switches;
that production invocation is outside the researched result.

[#89](https://github.com/berkeleynerd/silver/issues/89) must adopt the exact
researched invocation, option propagation, materialization, environment and
fixed-input contracts, coordinated with #88's process interface, with complete
Bronze/Silver evidence and Lean source correspondence. Alternatively, capacity
must be rederived for the selected different graph/options, including every
new process or regeneration path. No compiler implementation is authorized
during this pause. [M1 #148](https://github.com/berkeleynerd/silver/issues/148)
tracks this missing record obligation; closing it does not complete #89.

## Precise remaining scope

Before #119 can justify production adoption or expanded membership:

1. Finish required literal-output producer/Why3 paths beyond the closed
   first-inlining interval: ordinary-ending saves, remaining task/driver pairs,
   representations, fixed dependencies and actual-input joins (Round 23).
2. Complete fixed-library proof coverage and relevant installed-tool/source
   correspondence; preserve explicit source-identity premises.
3. Reconcile #131's imported-constructor/body frontier with exact discharging
   packets, reviews and current guards. Its historical repair does not itself
   close the remaining parent derivation. #146 is separately repaired and
   accepted, pending merge.
4. Apply #88's dependency test to Image/report-writer limits: distinguish
   proof-essential representations from independently justified observation-only
   limits. Optional confirmation cannot waive automatic discharge.
5. Generalize coverage to every currently supported Silver construct and
   permitted composition under the proposed relaxation, with decidable inputs,
   checked accounting and sound whole-rule composition/correspondence.
6. Compare the structure-sensitive rule with a justified conservative envelope,
   state useful accepted regions and check losses against currently admitted
   shapes. A conservative sufficient boundary is not the tool's exact maximum.
7. Specify #93 runtime/library and toolchain rederivation triggers, disposition
   the relevant [deferred items #150](https://github.com/berkeleynerd/silver/issues/150),
   and obtain independent final review of the complete rule.

Subsequent production #88–#94 remains unstarted. The #89 invocation obligation
above is a later dependency, not an additional research implementation task.
A reviewed research-stop outcome remains possible under #119's contract; none
is selected here and it would not unlock expansion. Frozen result metadata's
three broad residual phrases are historical summaries, supplemented by this list.

## Accepted region and transfer premises

The research family is a declaration-free Main/SPARK shell, one `with Silver_IO`,
C>=1 qualified literal Put/Put_Line calls and N>=0 null statements, recognized
from all source bytes. Its alphabet is printable ASCII plus HT/LF/VT/FF/CR;
current Silver excludes VT/FF. Acceptance additionally requires the selected
configuration, input identities and every capacity predicate. It is not acceptance
of every syntactically matching family member or new production admission.

The retained [relocation boundary](https://github.com/berkeleynerd/silver/blob/a3af18004743d36328a499760699305357389fb8/docs/evidence/retained-literal-relocation-refinement-20261018/result.json)
shows that one-byte-literal, zero-null programs pass the refined assembler/linker
component at **30,653 calls** and fail its signed-reach check at **30,654**.
This is retained component evidence, not a newly run aggregate boundary test or
a universal call cap. The separate GAS rule `max(10, 2*C+1) <= 65535` fails at
32,768; the page-index guard lies much later for this shape. The complete
475-condition conjunction remains necessary, and useful-domain comparison is
still unfinished.

Transfer premises include the exact selected per-job environments, cwd length
109 bytes, TMPDIR length 48 bytes, 4096-byte host pages, and the separately
checked 512-byte child path envelope including NUL. Main has `LANG=C`; binder
has no LANG; common-shell checks require `LC_ALL=C` and no
`GLIBCXX_TUNABLES`. The retained link inputs pin 15 host glibc/crt files as well
as the Silver bundle. Another host or installation needs the same relevant
inputs/geometry or a new route argument. Parent argv/environment/path arenas
(2048/1024/512 bytes, 17/7 slots) are chosen design parameters, not Ada limits;
#89 must satisfy or replace them with justified accounting. Tool traversal-depth
coverage beyond the named Ada arguments remains a clarification under #150;
no new constant-depth theorem for every tool is claimed.

Recheck or rederive affected evidence after changing runtime bytes/timestamps
(including bootstrap outputs), tools, options, environments, paths, host link
inputs, source corpora or selected ABI. The aggregate also checks 94 repository
pins, including seven research documents; editing one breaks that frozen input
identity even if the edit is only prose. A pin mismatch requires reconciliation,
not blindly changing its digest or rerunning all validation. Changes outside
those inputs do not automatically invalidate the result; assess semantic scope.
This maintenance preserves all 94 pinned files and the evaluator/results.

Corpus provenance is transitive through the retained manifests: GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and its Ada tree, binutils 2.46.1
revision `5e56594815`. This does not establish the unknown exact historical
SPARK revision in the installed GNATprove archive. Existing worker `/tmp` paths
are historical examples, not portable installation instructions.

## Other dispositions

| Findings | Disposition and timing |
| --- | --- |
| L1 | Carry branch-only owner decisions and this pause/maintenance scope to main; reconcile PR #121's two documentation conflicts. [#149](https://github.com/berkeleynerd/silver/issues/149) tracks completion. Do not merge the research PR as part of this maintenance. |
| L2, L5 | Scope and accepted region are stated above. Focused late-component failure/key-collision coverage remains #150; no new tests during the pause. |
| L3 | Twelve stage entries summarize prerequisite-gated source arguments and conjunctions, not twelve independently computed closures. Some flags are constants behind guards/requirements. Computation/schema clarification is deferred in #150. |
| L4 | The binder interface comparison checks retained constants under a fixed-family invariance argument, not a newly generated binder. Preserve the full P/R/RV/SS/U consumer inventory in #150. The external review corroborated invariance; no new theorem is claimed here. |
| L6, L9 | #131 discharge reconciliation and recursion-depth clarification remain explicit above and in #150. |
| L7, L8, L10 | Host/design premises and invalidation triggers are stated above; later construction or alternative rederivation belongs to #89. |
| L11 | 5,242,880 bytes is a conservative **lower bound** on the first-collection threshold, not its exact value. The source minimum is approximately 4 MiB × 1.30 = 5,452,595; the smaller value remains sound. Frozen field names are unchanged. |
| L12 | At most 24 optimization-vector pushes reach capacity 24, requesting 2,312 bytes. The retained 4,808-byte bound is conservative; 50 pushes would reach capacity 54 and need 5,192 bytes, so that is not its justification. |
| L13 | Prior “independent” reviews mean separately assigned nonauthor review of the accepted scope, not statistical or vendor independence. The aggregate reviewer authored the binder component and relied on the separate Ada/binder lane for that source argument. Same Git identity is disclosed; the supplied external review adds a cross-vendor check. |
| L14 | Available original scripts/results are [preserved without execution](evidence/review-a3af180047-retention-20261019/README.md). Missing harness and external scratch remain explicitly report-described, not retained executable evidence. |
| L15, L17 | Corpus provenance is stated above. Retaining the two missing hash-pinned GCC files is deferred in #150; no source fetch or new research during the pause. |
| L16 | Frozen `pending` literals are historical metadata, not consumed guards. Current review acceptance is in the linked reports; no evidence regeneration for wording alone. |
| L18, L19 | Cosmetic issue titles and whitespace are deferred. Captured tool output retains original bytes. |
| I1–I4 | Retain collection-count scope, conservative envelopes and offline census limits; alphabet clarified above. |
| I5–I7 | Estimate uncertainty and review-setting limits are explicit. Host-keyed ledger absence on a different host proves no absence of worker runs. |
| I8 | Binder-assembler author checks took 0.011399536 s; 0.011062663 s was reviewer replay. Historical raw outputs are preserved. |
| I9 | Closed-form GGC publication is deferred unless needed for the complete computable rule/comparison; no fresh derivation here. |

## Evidence and work scope

Original component review/implementation identities remain in the
[Round 24 record](https://github.com/berkeleynerd/silver/blob/a3af18004743d36328a499760699305357389fb8/docs/evidence/retained-tool-rounds.md#reviewed-native-completion-and-assessment-pause).
The supplied external report identifies Claude Fable 5.1; it is preserved
unaltered. Prior source/review lanes selected Astra Extra High. This maintenance
used one bounded Sol High read-only triage subthread; live lead settings and
runtime confirmation of selections are unavailable. Token/monetary measurements
are unavailable. No successful evaluator, native tool, proof or broad review
was replayed to repair these records. Lightweight validation checks file identity,
archive hashes, syntax/links, scoped whitespace and publication state only.
