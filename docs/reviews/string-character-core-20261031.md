# Independent String and Character core review — 2026-10-31

Result: one new P1 assurance gap, plus the previously tracked source-closure
blocker. No runtime defect was confirmed. This report does not certify delivery.

## Inputs and method

Reviewed `a351b3191d` against authorization baseline `1500b902a9`, plus checked
increments `7d0ac82cda` and `48a52e7809`. The reviewed native specification and
body bytes were verified against `79b350912a`. The final model assembly draft
`2c369aaded` is explicitly unvalidated. Live uncommitted changes were excluded.

The reviewer was independently selected as GPT-6 Astra / Extra High. Runtime
model and effort were not independently confirmed. Review ran from 20:04:47 to
20:09:25 UTC, 278 seconds, followed by report preparation. Token and cost
measurements are unavailable. This was read-only: no native or Lean validation,
repository edits, or CLI memory update was performed. The lead transcribed the
reviewer's report here without treating the pending integration as reviewed.

## L1 — Connect actual concatenation bounds to automatic discharge

**P1; open; [#304](https://github.com/berkeleynerd/silver/issues/304); blocks completion of #296.** The lead acknowledged the gap and is
developing the connected proof under the existing feature authorization.

`ComposeStringBoundSafety.lean:94–169` proves actual-bound and grouped-intermediate
safety, but its only external consumer in the reviewed tree is declaration
metadata construction. `PredicateObligations.lean:17–49` represents String range
safety through lengths; `PredicateChecks.lean:69–74` assembles those checks;
`Current.lean:216–220` requires generated obligations to refine that assembly.
None connects concatenation's actual endpoint requirement to the discharged
schemas. `StringExecution.lean:38–48` likewise checks byte length without actual
concatenation bounds.

Integrate a source-derived bound schema or an explicit proved refinement covering
initializers, assignments, outputs, String predicates and grouped intermediates.
Derive metadata from source and preserve it through composition. The standalone
theorem and passing specimens cannot close this connection. Update the assurance
paragraph that still claims the range bound fits `32767`; the new argument uses
the pinned 32-bit limit and a declaration-count-scaled endpoint ceiling.

This is a proof-integration finding, not a confirmed runtime counterexample.

## L2 — Finish authoritative native-source closure

**P1; existing, explicitly pending completion obligation in #296.**

`ComposeSourceCandidate.lean:892–914` already contains the separate seven-helper
body/header draft checks. The reviewed `ComposeSourceChecks` and
`ComposeSourceBridge.CheckedSource` do not yet transport and include them in
authoritative source closure. The lead identified the pending token-excerpt
repairs, refreshed certificates and pins, Character condition and assignment
checks, and scanner/callee links. Review that final delta and complete the
whole-project checkpoint before claiming correspondence. The gap concerns the
authoritative connection and validation, not an absence of draft helper checks.

## Reviewed core observations

- Bounds remain distinct from length; null bounds are retained, concatenation
  selects the correct lower bound, and whole assignment slides onto unchanged
  target bounds.
- Character/String kind checks and scalar-shadowing checks prevent interchange
  through shared byte storage. Element replacement reads its index and RHS from
  the incoming store.
- Raw arithmetic and index obligations survive initializer specialization, null
  slices, Character predicates and replacement normalization.
- `NativeState`, `NativeNames`, `NativeValue`, `NativeResult` and `NativeScan`
  retain native metadata/type domains. No hidden runtime-store or declaration-
  history premise was found in those helper contracts. `LegacyHelperMeaning`
  remains separate from the current actual-source interpretation.

The [capacity review](string-character-capacity-20261031.md) remains applicable
to the unchanged native inputs; no changed premise requiring repetition was
identified.

Full native proof, final regression/sample coverage, complete Lean/source/module/
fresh-axiom validation, documentation consistency and final integration review
remain pending. The closing review must identify exact later inputs and the
disposition of L1 and L2; this initial report remains historical evidence.

## Bounded endpoint-refinement review — 2026-10-31

Inputs: `3ea0067760`, `5c2238abf6`, and checked worker commit `abdcd62d3c`.
Live drafts, including `StringBoundsHeaderBridge.draft.lean`, were excluded.
The same independent reviewer selected GPT-6 Astra / Extra High; runtime
settings were not independently confirmed. Review interval: 20:53:25–20:56:34
UTC, 189 seconds. Token/cost measurements are unavailable. The reviewer changed
no files and launched no checks. This review does not close #304 or certify
delivery.

**P1 correspondence obligation within L1: transfer canonical dynamic bounds to
actual null bounds.** `ComposeStringRuntimeBounds.named_objectBounds` models
dynamic references using `Bounds.canonical input.length`. An admitted sequence
after the ordinary `Input` argument binding is:

```ada
S : constant String := "x";
H : constant String := S (2147483647 .. 2147483646);
D : String := Input & H;
```

When `Input` is empty, `D` captures `H`'s null bounds. Its modeled reference has
bounds `1 .. 0`. The lead confirmed admission using retained native `79b350912a`
with an input-validity guard and explicit rejection arm; the reviewer read the
exact source and admission output. No runtime failure is claimed. The repair
must relate equal nonnull bounds and differing valid null bounds, proving equal
lengths/nullness, concatenation safety transfer, grouped preservation,
declaration capture and assignment sliding.

No additional mathematical flaw was found in the checked foundations.
`EndpointBound` states the required arithmetic; downward-closed `Covers` covers
shorter grouped intermediates; validity, discharge and refinement retain
substantive conclusions. Origins preserve selected object identity, kind and
captured bases through freezing. Reached execution covers sequencing, chosen
branches, eager/short-circuit conditions and successive loop iterations.

Final closure still requires source-derived metadata/origins including the null
transfer; each occurrence's exact length schema and coverage with
`names.length ≤ certificate.bindingCount ≤ maxBindings`; consumption in the
final check inventory and `Current` generation/discharge interface; combined
endpoint, Character/index and arithmetic safety preserving raw obligations;
complete validation and independent review of the integrated result.

## Final #304 semantic review — 2026-10-31

**L1/#304 is closed at semantic-review scope on
`06263487c2acb07807c55b943c34fcaad57a7eb8`. No new blocking finding.** This does
not close L2 or certify full #296. The lead still must integrate the reviewed
commits and complete the feature's validation.

The final chain connects the endpoint argument to exact retained source checks
and both public `Current` assurances:

- Mixed declaration-order traces cover raw String, Character and Boolean
  initializers. Witnesses retain source readings, freezing identities, exact
  schema membership, refinement and certificate validity.
- Body proofs consume certificates for their expressions and flow contexts,
  including both loop forms and every reached iteration.
- Actual initialization derives bounds compatibility from source declarations.
  It handles the dynamic-null witness without assuming canonical bounds for
  every null String.
- Valid-null equivalence transfers all grouping intermediates. Both
  `Current.admitted_assurance` and `Current.every_meaning_assured` expose the
  completed bounds guarantee and retain prior discharge/outcome conclusions.
- The final delta changes only Lean proofs. It does not narrow admission, change
  native helpers or budgets, or remove Character, index or arithmetic obligations.

The relation also suffices for indexed operations and slices alongside retained
runtime safety, store fit and source origins. A valid index or nonnull slice
forces a nonempty prefix, making actual and modeled bounds equal. Null slices
are empty independently of the prefix base and need no containment check.

Keeping one initialized bounds store throughout body execution matches the
documented Ada assignment interpretation: checked assignments preserve target
length and slide bytes onto retained target bounds. `slide_bounds` and
`slide_nullEquivalent` express that rule. The new `ActualBoundsSafe` predicates
cover concatenation bounds; they do not introduce a separate actual checked
evaluator for every primitive. The reviewer found no additional compatibility
assumption or necessary pack/slide repair for #304.

Inputs were the exact committed files at `06263487c2`, including integrated
`b20b1b2996` source/certificate work and `49d5627689` equivalence work, retaining
the earlier reviewed foundations. The reported focused evidence—198 jobs and a
fresh audit of 21,053 declarations—was considered without rerunning it.
Authoritative source closure, native validation and complete regression evidence
remain separate outstanding work.

Selected reviewer: GPT-6 Astra / Extra High; runtime setting independently
unconfirmed. Review interval: 21:15:32–21:19:19 UTC, 227 seconds. Token/cost
measurements are unavailable. No writes or validation jobs were performed;
checkout status remained `?? tmp/`.

## Bounded L2 source-wiring review — 2026-10-31

**The main wiring is present, with one source-check inventory omission,
[#306](https://github.com/berkeleynerd/silver/issues/306).** No other missing
callee connection was found in this bounded inspection. L2 remains open pending
the repair and successful source validation.

`ComposeStringNative.lean:363–374` checks precedence and scope for four ordinary
bodies but omits `fixedBoundsBody`, `characterLiteralBody` and
`concatenatedFirstBody`. All three expressions are token-matched by the helper
candidate; neither the String nor global Compose inventories check their
precedence/scopes. No actual syntax defect was identified. The lead confirmed
and assigned the bounded inventory repair.

The remaining chain follows the existing interpretation route:

- `ComposeSourceChecks.actual_string_helpers` transports the seven-helper
  candidate through authoritative complete-shape equality; the Compose bridge
  includes it in `CheckedSource`.
- Native-domain typed equations in `ComposeContracts` feed the String primitive
  and helper equations, then declaration and expression interpretation.
- Character predicate body/header checks enter `NativeSourceChecks.Checked` and
  `PredicateSourceCandidate.native_checked`. The Character meaning consumes the
  body equation and inherited Character-reader meaning.
- `PredicateBasicLibraries.HelperMeaning.of_inherited` derives Character and
  indexed-reader meanings through explicit callee links. The xor source bridge
  derives its literal primitive through the inherited helper equation.
- `PredicateEquations` carries these meanings through basic statements,
  conditions, recursive bodies and outer correspondence. Predicate actual-source
  checking includes the authoritative helper and predicate checks.

This retains existing frontend-interpretation and native-call-legality premises;
it does not substitute a model witness or assume whole-scanner equality.

The exact target was lead HEAD `5c2238abf63f01f02f4e52a448217831ba60e6b7`, helper
commits through `fefe1b7e78`, assembly `d2001b08a3`, and the dirty inputs below.
All sixteen hashes were unchanged at review end. Paths are relative to
`proof/Silver/`; hashes are SHA-256.

```text
ComposeSourceBridge.lean                 88b212a9e48fa8653d7762c80eeb61442492617eb7e977922ebe51c9c1caa5be
ComposeSourceChecks.lean                 1f304ed016f92e6b3d3c465a1b8ffb9ef44c18b38695e475813f39ef8183988d
PredicateNativeSourceBridge.lean         3ce2e1aa38ceee65b88a3c4fe5b7934a32602ddb50eceefa3ebf21770d8da1f8
PredicateNativeSourceChecks.lean         d12d6a622ceb84741d7dc5708cc6ec5221589b3c37668c1c7352c0dbb11abfa8
PredicateSourceCandidate.lean            0c15686fa500e63c757d094c9873c8509acd28c9722a65329915e82fa3ce8453
PredicateSourceRequirements.lean         e9c97f941354ef4590c528af7a8dd39bc81ad7d198c763ff9762a2f0a8ea8978
PredicateCharacterSourceCandidate.lean   f9b403a7a65cadcb7ff25fb338a66a7ec10e6511b8ba60b4526e2d3cee079e46
ComposeCatalogueSourceCandidate.lean     a5223e18a8a01fdcc6597acc574bc26c9cfd567b603d73ab591e0ead65cb7ada
ComposeContractSourceCandidate.lean      aba4842ddbae7ac91975aa1bc410e406ceafd16ac1316c2cb57ec5fe453b9080
ComposeDeclarationSourceCandidate.lean   1b3d32b51dca251b2e5fae830d79f344c6f9cb5f2122da75e8547a2b4f6ab568
ComposeExpressionSourceCandidate.lean    f54e5ed511f2cba8bbd5e7869c0bdfbb4eb342c4e2f6cfb2c9ca4d9e4c48768b
ComposeHelperSourceCandidate.lean        e4183cd2487dceadbcfd4bd4ba695b5ec329db142a0d4d911ab7031c489d6608
ComposeSourceCandidate.lean              11f748d7446b9053a03972167573850aba907135300788669154183d02d99ce9
ComposeModelEquations.lean               93abccb9f79e131b54d1c1233a47887bf564a107cfd8546c9ad8a6a2c60d4f63
ComposeBooleanDeclarationLibraries.lean  c7141eb2f68cfe2779500a8f22641b4611b693637ad2eba012dc7892dcfeff44
PredicateXorSourceBridge.lean            48b4056ae17d3be38e182bdbb42b3de42cfd6b793851f395d4686fe778666fda
```

Authoritative output-profile bytes independently matched `79b350912a`:

```text
src/silver_output_profile.ads  799959ca7d49229dbe8bd748fc11c109839b3e77d95fdf3210ea422365754d6d
src/silver_output_profile.adb  bcd6d9b3ebb814d13cbf9e9651bf10f5e25102030c9d42d879b022411415ed1b
ReviewedOutputShape.lean      9825f52863180fa72c6e6d5ecc3daeb64beeddf32ddbc542299613234d7d2aa7
OutputSpecCertificate.lean    4d09bc7f61640bfc89203c6ecf18c32b11a8d07a5de3493485f6812ba0485939
OutputBodyCertificate.lean    aacf9fed44b0bf51b0c8587cb6db2ffdd1c5d35445c720326c8b67022a87e86f
```

Inspection only: no writes, builds or validation jobs. Scratch normalizations and
conversion probes do not establish closure. Memory, rendering and partition
failures remain validation obligations. This review and the earlier #304 review
do not certify full #296.

Selected reviewer: GPT-6 Astra / Extra High; runtime settings independently
unconfirmed. Review interval: 2026-10-31 21:44:47–21:47:24 UTC, 157 seconds.
Token/cost measurements unavailable. The lead transcribed this report without
changing its disposition.

## Queued source-repair and #306 review — 2026-10-31

No new finding. Commit `22cbb9a13dde38d03ff11f8ecff78a3824b7c855` closes the exact
inventory omission identified above. Full candidate validation and integrated L2
closure remain pending.

The reviewer independently applied `tmp/string-source-repairs/repairs.patch`
entirely in memory and reproduced all four recorded after files. All 144 token
substitutions (100 Contract, 44 Helper) match the mapping. An independent
tokenizer agrees with all 63 original expected-text literals, which appear
literally in the generator's `Evaluate.lean`; expected tokens were not extracted
from actual source. Nonreplacement bytes remain unchanged from the prepared
drafts. Both Helper propositions and all three public theorem statements remain
intact modulo those token substitutions.

The four ordinary-body proofs retain exact source equality: renderer
normalization followed by `rfl` is a valid kernel-checked approach. The catalogue
change only corrects expected `Spelling` branch order; enumeration and
classification remain unchanged. The accessor repair uses the existing
`NativeState.nativeNames` theorem without changing its domain or premises.
The #306 commit adds precisely the three missing precedence and scope entries
to already-consumed String inventories, with no other file change.

The retained `call_after` probe records success in 19.649 seconds, 2,446,492 KiB
peak RSS and a fresh audit. It supports the bounded representation repair; it
does not validate the full candidates or establish kernel transport from every
former `expectedTokens` expression.

Exact inputs at lead HEAD `5c2238abf63f01f02f4e52a448217831ba60e6b7`:

```text
repairs.patch               13850f8bbea00aceb8f5a976fa5ff830ea9da62fcf21440e67a30962f9b8f13f
inputs.json                 95303b545ff7c60afd8475536357512a172e7267d0f9d3e27d7ae6f825ed4721
mapping.json                cf4933cd1b673b05e8c080d5c11108c74748c5490290f1b9f6db2624afa0b06b
#306 ComposeStringNative    0d2e80513f48e393dfc4696a3a96323d796c3c6d203a1e67b3f6f0710ac9fa97
```

The first two files are under the lead's `tmp/string-source-repairs/`;
`mapping.json` is under the native/source lane's
`tmp/ExpectedHeaderTokenCandidates/`. The four before/after identities remained
unchanged at review end. Native ADS/ADB bytes match the supplied hashes above
and `79b350912a`. No writes, builds or native tools were run.

Selected reviewer: GPT-6 Astra / Extra High; runtime settings independently
unconfirmed. Review interval: 2026-10-31 22:54:12–22:56:07 UTC, 115 seconds.
Token/cost measurements unavailable. Final delivery and evidence review remain
pending successful required checkpoints. The lead transcribed this report
without changing its disposition.
