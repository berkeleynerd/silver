# PR #424 — independent native and behavior review

Reviewed published head `3c0dde8f0d816493024198bf65488bfa86147c94` against main
`1fac6fa1331fe6e778e6b2ae46b867ab44f362c6`, for the owner-authorized #416 package
increment and upfront #421 feasibility scope. The reviewed Output_Profile SHA-256
is `95c0f3b33e522adb0bec348520b196a51d8d700ef5bae754056f247fa83c9b09`.
Selected reviewer setting: GPT-6 Astra / Max. Independent runtime model/effort
confirmation, token usage and cost are unavailable. Native host observed: Linux.
Review began at 2026-11-27 16:50:59 UTC; completion time is recorded below.

Recommendation: keep draft. Two new native admission defects are identified below;
the separately documented complete assurance and delivery work is also unfinished.
Both defects concern the new draft package route; the main baseline is unaffected.
This subthread ran no build, test or proof and made no tracked changes. The lead
independently reproduced the findings in an isolated exact-source harness.

## New finding N1 — blocker: the imported package name does not hide a use-visible runtime call

Frozen locations: `src/silver_names.adb:220`,
`src/silver_output_profile.adb:685` and `src/silver_output_profile.adb:9422`.
The newly admitted application package identity participates in context parsing,
but not in the `Hidden` test for an unqualified runtime operation.
`Package_Name_Allowed` (`src/silver_output_profile.adb:7922`) permits `Put_Line`.
`Imported_Frame` clears inherited hiding and imports only qualified exported
value/type bindings. `Call_After` tests those bindings and local names, then
`Operation_After` accepts the unqualified name whenever `use Silver_IO` is active.
It does not check whether that name denotes the selected application package.

Minimal original units, all far below the shared source/operator budgets:

```ada
-- put_line.ads
package Put_Line is pragma SPARK_Mode(On);
procedure Noop;
end Put_Line;
```

```ada
-- put_line.adb
package body Put_Line is pragma SPARK_Mode(On);
procedure Noop is begin null;end Noop;
end Put_Line;
```

```ada
-- main.adb
with Put_Line,Silver_IO;use Silver_IO;
procedure Main is pragma SPARK_Mode(On);
begin Put_Line("x");end Main;
```

Static acceptance path: discovery selects `Put_Line`; the package's single
zero-formal completion passes; Main's imported value/type tables are empty;
`Application_Basic` falls through to `Basic_Body`, which finds an unhidden
`Output_Call` and accepts the literal argument. The package declaration instead
hides the use-visible procedure in Ada, so this cannot compile as the source the
checker interpreted. The pinned references establish the mismatch: Ada RM
8.3(8) defines homographs when one declaration is nonoverloadable; 8.4(10) removes
use visibility inside the immediate scope of a homograph; 10.1.2(7,23) supplies
library-unit visibility from the `with` clause. This violates the Oracle's
subtractive-Ada and admitted-source compilation guarantees, independently of the
already known unfinished proof endpoint.

Minimal repair: include the selected package identity in unqualified runtime-name
resolution, including the direct `Operation_After` path used by argument
initialization. Preserve qualified `Silver_IO.Put_Line("x")` as the positive
control. Add focused admission/frontend regressions for the colliding runtime
operation names and update their source/semantic correspondence. Do not simply
weaken the report audit or suppress the frontend failure.

Independent confirmation: the lead built an admission harness against the exact
target `src` in managed run `20261127T170048-cc9610a8bc18`, then ran it and the
pinned frontend in `20261127T170125-bf3cfba89910`. `Analyze(Bundle).Accepted` was
`TRUE` for both the unqualified and qualified fixtures. The frontend rejected the
unqualified fixture at `main.adb:1:85` with `procedure or entry name expected`
(exit 4); the qualified control succeeded (exit 0). I read the harness, project,
verification script, fixture bytes and [results](pr424-visibility/outputs/results.json).
This is native admission/frontend evidence, not a complete application proof run.

## New finding N2 — blocker: package identities conflicting with Standard are admitted

Frozen location: `src/silver_output_profile.adb:7922`, especially the exclusion
list ending at lines 7934–7936. `Package_Name_Allowed` rejects selected predefined
type/unit names but permits `True` and `False`. These are not reserved words, yet
the pinned Ada frontend rejects them as library package identities. The current
package-name rule in `language.md:740` and `catalogue/silver.json:18` has the same
omission.

The lead's separate `true_literal` fixture uses these exact bytes:

```text
true.ads: package True is pragma SPARK_Mode(On);procedure Noop;end True;
true.adb: package body True is pragma SPARK_Mode(On);procedure Noop is begin null;end Noop;end True;
main.adb: with True;procedure Main is pragma SPARK_Mode(On);B:Boolean:=True;begin null;end Main;
```

The corresponding `False` fixture replaces `True` with `False` throughout.
Both return `TRUE` from exact-source `Analyze`. The pinned frontend rejects
`true.ads:1:09` / `false.ads:1:09` with `"True" conflicts with declaration in
package Standard` / the equivalent `False` error, both exit 4. The failure is at
the package declaration, before Main's literal resolution; this is an identity
admission defect, not merely a Boolean-expression hiding defect. The same managed
runs and [results](pr424-visibility/outputs/results.json) above retain the evidence.
Ada RM 8.3(26/2) supplies the relevant same-region homograph/context legality rule.

Minimal repair: derive a complete package-identity policy from the pinned Ada
environment, reject the conflicting identities consistently in native admission,
language/catalogue and correspondence, and add targeted negative controls.
`Natural`, `Positive` and other Standard declarations are untested same-class
extensions here; fixing only the two observed names is not evidence that the
identity policy is complete. Legal operation-name packages such as `Put_Line`
still require N1's visibility repair and qualified-call positive control.

## Reviewed scope and positive observations

All 19 changed native units were inventoried. Detailed execution-path review
covered the driver, Application_Units spec/body, Package_Bindings spec/body,
Application_Report_Metadata spec/body, Names spec/body, Scalar_Expressions
spec/body and the new Output_Profile parser plus affected qualified-name,
context and callable-frame paths. Library_Reports spec/body and
Report_Projection_Audit spec/body were reviewed for package identity, owned/imported
entity separation, exact coverage, output-initialization and termination witnesses,
allowed diagnostics, safety-record treatment and context transport. Catalogue
emission and Platform's new capacity complete the native inventory.

The original-unit route is concrete: separate byte slices are written into a
fresh project, original package/Main mappings use explicit `at 1` indices, proof
selects all units with `-U --no-inlining`, and snapshots are compared before/after
proof and build. The driver requires the package audit before reusing the shared
report buffer for Main. I found no hidden flattened or annotated application
replacement on this route.

Routine frames widen private state to complete declared domains before local
initialization. Signature/body matching retains kind, formal names, modes and
subtype identities. Every completion is checked, including unused ones; earlier
completion lookup excludes forward/recursive calls. The reviewed call paths check
actuals against the same incoming facts, reject explicit/implicit writable aliases,
transport transitive state effects, and invalidate possibly written state facts.
Dead arms and empty loops retain syntactic effects. These are reviewed mechanisms,
not a claim that the universal/source endpoint or all contracts are complete.

Package report ownership is derived from admitted source metadata. Main may omit
producer-eliminated imported routine entities, while the separate package report
requires every owned routine and outer entity with `all` coverage. Required
function termination and procedure `out` initialization remain independent of
advisory allowances. The report still checks every retained safety record and
rejects skipped/assumed/suppressed evidence under the existing trusted producer
premise. No additional adversarial-artifact requirement is inferred here.

The per-report capacity ledger derives 254,557,666 bytes within the reused
268,435,456-byte library-level buffer, without increasing the 4,096-byte source
or 63-operator budgets. Runtime/null limits remain independent. The source-charge
argument and arithmetic/schema tests were inspected; this review did not execute
them or independently audit every pinned producer implementation path. That
ledger is not a process-peak or stack bound. No final-source package stack
measurement was established by this review.

## Regression evidence, limitations and known WIP

All nine changed test/probe files were inventoried, including all 26 methods in
`tests/test_library_packages.py`, original-source sample handling, the parser-derived
package audit probe, capacity boundary updates and the remaining assertion changes.
The new namespace collisions are absent from those regression cases.

The retained initial-integration record reports all 26 package methods passing
in `20261122T150042-fa61acf6b4e2`; the initial-samples packet reports the counter,
Include a file and Queue/Definition passing admission, proof, original-source
comparison, report audit, build and expected output. The report-policy packet
retains eleven native positive/negative controls, including missing coverage,
termination, output initialization, wrong initialization file/case, hidden write
effects and forbidden postcondition claims. Its hand-constructed-metadata smoke
does not by itself cover the parser-derived route. These are retained November 22
results on their recorded inputs, not fresh validation of the published head.

No other concrete defect was established in this bounded review. This is not an
exhaustive correctness result. The independent Lean/source and assurance reviewers
own the universal endpoint and correspondence assessment; the lead owns the
Python `scripts/check_evidence.py` audit changes. I did not run the available
older compiler as evidence for this exact head, replay proofs, or treat private
queued native/proof commits as published fixes. The #421 runtime-feasibility
packet and final Rosetta task/delivery assessment were not independently rechecked
in this native subthread.

Complete final native/Lean/source checkpoints, final applicable regressions and
samples, Rosetta promotion and closing delivery review remain required work
already acknowledged by the draft language qualification and capability record.
The lead's newer 15:59 handoff reports no active runs and remaining Main/Analyze
and public-wrapper native gates; it is diagnostic context, not proof of this
published target. Those expected WIP blockers are separate from N1/N2.

Completed at 2026-11-27 17:03:43 UTC; observed elapsed review interval 12 minutes
44 seconds, including evidence reads and waiting for the lead's independent
reproduction. This is not native execution time or a whole-team cost measure.
