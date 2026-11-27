# PR #424 — independent source-correspondence review

Frozen target: `3c0dde8f0d816493024198bf65488bfa86147c94`, compared with main `1fac6fa1331fe6e778e6b2ae46b867ab44f362c6`, inspected in `tmp/named-array-parameters-410`. The worktree HEAD matched the requested target. Existing unrelated root changes were preserved.

Selected review settings: GPT-6 Astra, Max, as assigned under the repository's critical-proof review policy. Actual runtime model/effort and token/cost accounting are not independently exposed. Observed source-review interval: 2026-11-27 16:51:47–16:59:54 UTC; lead reproduction evidence reviewed at 17:02:44 UTC, Linux. This subthread performed static source/evidence inspection only: no build, test, proof, certificate generation, Git mutation, GitHub message, or subagent run. The separately attributed lead runs below supply the executable reproduction.

## Readiness and concrete finding

**Not ready for source-correspondence approval or merge.** The lead's frozen-source reproduction confirms two distinct admission failures: a bare runtime operation incorrectly survives an imported package homograph, and illegal `True`/`False` library package names are accepted. The native reviewer identified the first; this review independently corroborated its formal source path and proposed the second case for reproduction. These are blockers to merging this draft, not claims of a defect in current main, and are distinct from its already disclosed unfinished integration. I found no additional definite source/model mismatch in the other representative chains inspected. This is a scoped review, not an exhaustive audit of all changed handwritten modules.

### P1 — Include the imported package identity in Ada name hiding

The directly visible application package is absent from the hiding rules used to resolve a bare runtime operation. A package named `Put_Line` is allowed by `proof/Silver/ApplicationPackageNames.lean:34`. In Main, `importedFrameRaw` preserves its source span but clears hiding and creates subtype metadata with default visibility flags (`proof/Silver/ApplicationPackageFrames.lean:188`, especially lines 192–199). `Compose.callAfter` checks object, scalar, array, array-type, Boolean and subtype names, but never the application package identity (`proof/Silver/ComposeAtomAdmission.lean:177`, especially lines 184–187). `Names.operationAfter` uses the package span for context parsing and then accepts a bare runtime operation whenever `used && !hidden` (`proof/Silver/Names.lean:235`, especially line 244).

The corresponding typed source tree repeats this omission (`proof/Silver/ComposeExpressions.lean:1726`). It matches the current Ada `Call_After` at `src/silver_output_profile.adb:685` and `Imported_Frame` at `src/silver_output_profile.adb:9422`. Consequently, the source-equality checks can pass while both the native recognizer and its model resolve a name contrary to Ada visibility. This is not a pin mismatch or a failed Lean inference; the modeled language meaning needs correction.

The native review's representative source is:

```ada
-- put_line.ads
package Put_Line is
   pragma SPARK_Mode (On);
   procedure Noop;
end Put_Line;

-- put_line.adb
package body Put_Line is
   pragma SPARK_Mode (On);
   procedure Noop is begin null; end Noop;
end Put_Line;

-- main.adb
with Put_Line, Silver_IO;
use Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Put_Line ("x");
end Main;
```

The bare `Put_Line` denotes the directly visible package, which hides the use-visible operation; it cannot be treated as `Silver_IO.Put_Line`. The lead's managed reproduction confirms that the frozen analyzer returns `TRUE`, while GNAT rejects the call with `procedure or entry name expected`. Changing the call to `Silver_IO.Put_Line` keeps analyzer acceptance and passes the frontend. I reviewed the retained results but did not execute either case.

**Minimal repair and integration:** account for the package identity at the shared runtime name-resolution boundary, preserving the qualified `Silver_IO.Put_Line` branch. `Names.Operation_After` is a useful common repair point: some inherited readers call it directly and bypass `Call_After`, including the argument initializer represented at `proof/Silver/ComposeExpressions.lean:1752`. A `Call_After`-only patch leaves those paths open. Update the corresponding `Names.operationAfter`, typed `operationBody`, source equations and certified source checks together; establish a focused rejection property for bare package homographs and retain the qualified-operation control. This uses the existing name/source mechanisms and needs no new assurance framework.

### P1 — Reject illegal Standard collisions in library package declarations

`packageNameAllowed` excludes Integer/Boolean/Character and the inherited forbidden list excludes String, but it permits `True` and `False` (`proof/Silver/ApplicationPackageNames.lean:34`). The lead's managed reproduction confirms that the analyzer returns `TRUE` for both complete applications, while GNAT rejects `true.ads:1:09` and `false.ads:1:09` because each name `conflicts with declaration in package Standard`.

This corrects the earlier provisional diagnosis: the demonstrated failure occurs at the package specification declaration, before Main's Boolean literal resolution. Seeding literal-hiding flags cannot make an illegal library package declaration valid. Extend the native package-name legality check and its corresponding Lean name/body/equation/source checks to reject these collisions, with focused negative controls. Keep this repair distinct from the legal package `Put_Line` case, whose qualified runtime operation must remain usable.

### Executable evidence supplied by the lead

The exact-source admission harness was built from `3c0dde8f0d816493024198bf65488bfa86147c94` in managed run `20261127T170048-cc9610a8bc18`. Managed run `20261127T170125-bf3cfba89910` then exercised four cases. I inspected [results.json](pr424-visibility/outputs/results.json), which records the analyzer output, frontend commands, exit status and diagnostics. The run records affinity to CPU 0 and frontend `-j1`; no compute job was launched by this reviewer.

| Case | Frozen analyzer | GNAT frontend |
| --- | --- | --- |
| Imported package `Put_Line`, bare `Put_Line ("x")` | `TRUE` | Rejected: `procedure or entry name expected` |
| Imported package `Put_Line`, `Silver_IO.Put_Line ("x")` | `TRUE` | Success |
| Library package `True` | `TRUE` | Specification rejected: conflicts with Standard declaration |
| Library package `False` | `TRUE` | Specification rejected: conflicts with Standard declaration |

These targeted analyzer/frontend results establish the admission mismatch. They are not a native proof audit, completed source proof, or full regression checkpoint.

## Representative chains examined

- **Authoritative bytes to typed trees:** the four new source bindings use `include_str` on the original Ada files; the generated certificates reconstruct those bytes and prove lexer equality. The certificate-generator change registers the files and scales the recursion budget for the flattened token declaration. I found no changed axiom, native-evaluation substitution or kernel bypass in that change. `functionHeader`, `expressionDeclaration` and `ordinaryFunction` require unique extraction; the new support/call/import modules compare extracted fragments against the full certified Output Profile token stream, not just copied candidates. Their pending validation is discussed below.
- **ApplicationUnits storage:** traced `Fits`, `Valid`, `Pack`, `Unit_Source` and `Prefix` through `ApplicationUnitsExpressions`, `ApplicationUnitsEquations`, `ApplicationUnitsSourceChecks` and `ApplicationUnitsSourceBridge`, against the Ada units. `SourceValue` retains lower bounds; slice assignment uses the original bytes. The fitting-domain proof covers all three positive lengths under the common bound, guards natural subtraction, and proves all three slice extents. The source bridge explicitly separates native representability from `Layout` and retains arbitrary input string lower bounds.
- **PackageBindings:** traced identifier/name validation, metadata validation and the three executable lookup refinements through expressions, equations, source checks and source bridge. The metadata-name equality primitive is used only after both names are validated. `Lookup_Routine` retains `Completed <= Routine_Count` in both the Ada contract and Lean equations; the lookup model does not silently assume fully valid metadata. `Package_Callee` checks that condition before calling it (`ApplicationPackageCalleeNative.lean`, `ApplicationPackageCallsModel.lean`, Ada lines 8725–8735).
- **Shared package expression/control machinery:** inspected expression render/eval cases, positional and named association guards, arithmetic association, logical-chain categories, scope shadowing, record updates, field/index projections, declarations and loop control in `ApplicationNativeCore`, `ApplicationNativeGuards`, `ApplicationNativeCommands`, `ApplicationNativeInitialization` and `ApplicationPackageImportControl`. The inspected arithmetic renderer requires a primary right operand; logical chains reject ungrouped mixed categories; named calls check formal association order. The native initialization map preserves arbitrary uninitialized scalar storage rather than replacing Parser_State with a successful initial state. Active-prefix count setters are explicitly limited to reductions; that limitation is not evidence for declaration growth.
- **Imported_Package:** followed the nested-loop control, local restoration, source-derived fuel and imported lexical/package meanings through `ApplicationPackageImportNative`, `ApplicationPackageImportControl`, `ApplicationPackageImportImports` and `ApplicationPackageImportSourceChecks`. `execute_imports` covers arbitrary scratch locals, rejected source and successful termination; fuel exhaustion is not equated to native rejection. The scanner's source witness and its specification are separate from package admission.
- **Package call body:** inspected Callee source requirements and typed execution, the complete call denotation's phase composition and parameter capacity, and selected actual/formal mappings. The body equation is parameterized by imported callees; it does not claim that arbitrary imported callees have already acquired actual source meaning. The explicit metadata guard avoids introducing a successful-metadata premise into the raw callee's declared domain.
- **Static Boolean readers:** inspected Primary/Factor typed bodies, relation and chain semantics, source requirements, `TailExec` existence/uniqueness and `runCondition_execution`. The declared domain in `StaticBooleanSourceChecks.lean:27` includes cursor zero and valid failure states. `TailExec` distinguishes a returned invalid result from a progressing iteration; the implementation's loop bounds and the recursive reader's postcondition are separate premises. The frozen files do not provide the completed mutually recursive real-callee closure.
- **Inherited binding changes:** traced the new qualified reference grammar and source bridge, zero/failure cursor preservation, the package-aware Names context/operation interpretation, selected Compose call trees and Predicate Boolean/source-reading changes. Qualified identity includes the qualifier; a bare binding cannot silently satisfy a qualified lookup. The package-name hiding omission above is where this selected pass found a semantic gap.

## Already disclosed completion work

These are not new findings against a claimed finished implementation:

1. The original package source-to-semantic endpoint remains unfinished. `ApplicationAssurance.lean:7` explicitly requires original-source integration to construct the schema, syntax, representation and Main-library facts; its theorem takes those facts as premises. The Main and application wrapper files define checked-source requirements and conditional interpretations, not a completed original-Bundle theorem (`ApplicationPackageMainSourceShape.lean:7`, `ApplicationAdmissionSourceShape.lean:7`). Complete the Names/Object/Signature/Specification/Completion/body/Main chains and derive the semantic endpoint's premises from the actual source, including callee domains and full declared package-state/formal domains.
2. `ApplicationPackageSupportSourceChecks`, `ApplicationPackageCallSourceChecks` and `ApplicationPackageImportSourceChecks` are proposed full-source witnesses. The fresh shared run `20261127T151426-5b6f06cce28c` was interrupted; completion of two OutputBody source chunks is not validation of the three target modules or their aggregate audit. The source review does not promote that partial run to success.
3. The StaticBoolean source candidate and local body/loop proofs still need their mutual source-domain/recursive-callee closure. The later private Object and StaticBoolean work identified in the briefing is outside the frozen target and is not credited here.
4. Canonical remaining native helper/caller checks, complete native and Lean audits, applicable regressions, actual-source endpoint validation and Rosetta delivery remain required under the existing workflow. The lead/native reviewers own the specific native failures and the lead owns `check_lean.py`/`check_evidence.py` coverage.

## Meaningful limits of this review

I did not independently replay retained proof artifacts or validate the interrupted targets. I did not exhaustively inspect every new declaration-storage/history simulation, every actual-alias/read-effect lemma, all completion and statement-arm cases, all new semantic package lowering/capture proofs, report acceptance/provenance, or every inherited Compose/Predicate consumer. The semantic and native reviewers own those adjacent scopes; this report must not be read as approval of every changed module. Source/layout/callee assumptions still need review when the final decoder is assembled, even where individual local theorems have passed focused audits.

Report: `tmp/open-pr-reviews-20261127/pr424-source.md`.
