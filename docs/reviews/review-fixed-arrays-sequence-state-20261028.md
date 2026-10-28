# Sequence state preservation repair review

2026-10-28. Independent reviewer selected GPT-6 Astra / Extra High;
runtime-confirmed model/effort and token/cost measurements unavailable. Target:
`997aa01c88e7f7fe41ba9f2d844e4a12800cffc0` plus the exact three-file uncommitted
patch identified below. Read-only inspection; no build, Lean, native, test or
probe execution, repository edits, subagents or GitHub writes. Only this scratch
report was written. First recorded clock sample was 02:52:47 UTC after initial
reads; report prepared 02:55:32 UTC. These times exclude initial inspection.

No remaining consequential finding in the inspected patch. The repair preserves
the full arbitrary array environment and introduces no empty-array restriction,
new axiom, changed source admission or suppressed obligation. Complete Lean
validation of the repaired snapshot remains pending.

`Sequence.Native` is a retained mathematical scanner witness. Static import
closures of `Current`, `PredicateSourceBridge`, `SourceBridge` and
`PredicateOuterModel` exclude SequenceNativeState, SequenceNativeExpressions,
SequenceBodyContext and SequenceModel. SequenceModel's only direct importer is
the umbrella `Silver`; the complete module audit still requires it. The current
native source route instead uses `Predicate.Native.Context` (metadata) and
`Predicate.Adapter.expand` with the separate full array environment, matching
the actual Ada Body_Context/Expand_Body. The repair's new comment states this
distinction accurately. No current Predicate adapter or source interpretation
was changed. The unused Sequence conversion renderer is not evidence that its
older representation matches current Ada.

The repaired split is complete: `contextOf` retains names, dynamic bounds,
scalar names and the entire `ArrayBindings.Env`; `bodyOf` retains cursor,
target, capacity and both flags; `expand` restores all eight ParserState fields
and both ScanResult flags. `expand_parts` therefore applies to arbitrary input
states, including nonempty array environments. `ValidContext` adds exactly the
array-validity clause already required by Compose.ValidState. Its final
scalar/array conjunction is carried intact by `parts_valid` and `expand_valid`;
no stronger caller premise or allocation-readiness condition is introduced.

`SameContext` now preserves full array-environment equality. Its transitivity,
empty/base cases and `context_same` projection retain both scalar and array
fields. This closes the downstream gap identified during review: the previous
SameContext predicate allowed differing arrays and could not imply the repaired
context equality. Successful ordinary body steps update only cursor/target
fields; recursive context preservation transports this equality through bodies
and alternatives. Failure paths remain canonical invalid results, and compact /
lift correspondence still requires full context equality on successful scans.

The expression progress lemma is generalized over metadata, initial values and
elaboration mode. Both comparison operands and the validity proof now pass
`state.arrayNames.names`, `.values` and `true`, precisely matching the existing
Compose.comparisonAt definition. This repairs an outdated default-empty-array
instantiation; it does not change comparison semantics. Searches found no
additional explicit Sequence Context construction requiring an empty/default
array environment. The temporary `ArrayBindings.Environment` spelling was
corrected to the existing `ArrayBindings.Env` type before the reviewed snapshot.

Regression applicability remains **73 fresh + 457 retained = 530**. Since the
previous applicability target `529df9a6c4`, committed changes are confined to
11 documentation/evidence paths. The pending delta changes only these three
proof files: native code, scripts, generator, source pins, tests, shared fixtures,
samples, configuration and imports/module inventory are unchanged. Production
Lean-reading regression tests inspect module/import/include markers or copy and
hash inputs under mocked platform routing; none evaluates these changed
Sequence definitions. Their inspected properties are unchanged, so no additional
regression rerun is needed for this delta. The complete Lean checkpoint is the
required validation of the repaired mathematical modules. The future Rosetta
metadata change still requires its existing three-test rerun, as previously
reviewed. The failed original full regression remains recorded as failed.

Observed retained outcomes are distinct:

- Native `20261027T104107-f971342569f8` has a successful terminal event at
  2026-10-27 18:34:46 UTC. Its log reports all 16,697 checks proved and complete
  audit of 76 units / 1,068 entities: 1,418 flow and 15,279 proof checks. This
  bounded review observed those records; it did not repeat the native audit.
- Complete Lean `20261027T150301-0958f36e542b` has a failed terminal event at
  18:27:35 UTC. Its retained log records successful ComposeSourceCandidate
  (4,604 s) and PredicateSourceCandidate (4,278 s), then SequenceNativeState
  constructor/proof errors. The reported `sorry` diagnostic follows failed
  elaboration; the reviewed patch adds no unfinished proof. No successful
  complete audit is inferred from this failed build.
- The lead reports a complete cached rerun started 2026-10-28 02:53:21 UTC with
  unchanged one-worker/one-thread/24-GiB settings. This review does not claim its
  eventual outcome. #262 and full feature assurance remain open until complete
  actual-source/module/axiom validation succeeds.

Exact reviewed modified input SHA-256 values:

| File | SHA-256 |
| --- | --- |
| `proof/Silver/SequenceNativeState.lean` | `a759d032a7c734b2f8abf1c6e38eb18c706123a8fe6851b5a91ed80c1d2baf6c` |
| `proof/Silver/SequenceBodyContext.lean` | `38e578add648ccf884ab873037a3b0697b84cfb7bd041679f639297591e8c232` |
| `proof/Silver/SequenceNativeProjection.lean` | `6ce145348a644e5596be1982b579deaecb6bbb96c11c7565f3b884dd0735381b` |

Supporting unchanged inputs at the stated base: ComposeAdmission,
ComposeContracts, SequenceNativeExpressions, SequenceNativeCorrespondence,
SequenceEquations, SequenceNativeModel, the relevant Sequence context proofs,
PredicateNativeState, PredicateAdapter, Current and actual Ada context/adapter
sections. The prior test-applicability reviews supplied the already-reviewed
fixture dependencies. The two managed logs/events named above supplied outcome
context. No broad semantic implementation review was repeated.
