# Boolean-array primary assertion: independent repair review — 2026-11-07

**The one-assertion repair is appropriate; no code correction was found.**
Both the new assertion and the original postcondition have applicable focused
native passes. This is not whole-helper, complete native or complete
source/Lean assurance. Final integration, source refresh and those complete
checks remain required.

## Exact target and review record

The candidate is the sole uncommitted native-source change on
`repair/boolean-primary-cut-20261107`, based on
`9d9c786dceac6160c6fff521ed273fddfdfa628b` in `tmp/image-case-repair`.
Integration remains based on `1b4ab33131afb1b7035a8489f6e699e1e63264cc` for this
inspection. Exact `src/silver_output_profile.adb` identities:

- Base: `1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8`.
- Candidate: `c1ce845a597605c152119bedc6b07f1aa3bccece5d2870addb86cd18077fffaa`.

The [reviewed-input record](../evidence/boolean-arrays-20261106/final-review/primary-cut-inputs.json)
identifies the native/model/worker/source-check inputs, policy references and
primary evidence inspected. The [generation comparison](../evidence/boolean-arrays-20261106/final-review/primary-cut-generation.json)
records independently reproduced source/certificate consequences.

Selected reviewer: **GPT-6 Astra / Extra High**. Independent runtime setting
confirmation and token/cost measurements are unavailable. UTC inspection:
**2026-11-07 03:26:17–03:30:03**, 226 seconds through source-generation and
evidence comparison; subsequent report preparation is separate. The reviewer
did not author the cut, edit governed files, or run proof/native/test jobs.
Generation comparisons executed the unchanged Python generator purely in
memory. No agent fan-out or GitHub action occurred.

## Native meaning and proof obligations

The exact diff adds only
`pragma Assert (Static => Result = Primary_Model (...));` after the new
Boolean-array branch's three assignments. The branch tests the same
`Boolean_Array_After` result and follows the same preceding invalid/grouping
branches as `Primary_Model`. The model's selected value is
`(Facts.Count, Boolean_Array_After (...), Facts, Facts)`. The procedure preserves
its constrained result discriminant and writes those same cursor/flow values.
The existing `Result.Count = Facts.Count` precondition supplies the remaining
component, including the allowed zero-count case.

The complete original Runtime/Static postcondition, source/context/flow/cursor
domain, `Initials` argument and termination variants are unchanged. No domain
restriction, precondition strengthening, assumption or suppressed obligation is
introduced. The assertion's call to the ghost model creates its own precondition
obligation; that obligation was proved along with the assertion. A local proved
fact supports the final equality without replacing it.

The pinned SPARK 16.1 LRM's
[assertion-policy and dynamic-semantics rules](../../references/spark/16.1/docs/lrm/source/exceptions.rst)
make Static-level assertions always Ignore and never checked at runtime. The
[user guide](../../references/spark/16.1/docs/ug/en/source/specification_features.rst)
states this cannot be overridden by compiler options or assertion policies.
Thus `silver.gpr`'s retained `-gnata`/`-gnato` flags do not execute this new
assertion or its ghost model call. Executable branches, assignments, runtime
contracts and generated runtime-library sources are unchanged. This is a
source/policy argument for runtime equivalence, not a measurement of a rebuilt
candidate binary.

## Focused evidence actually checked

Inspected each packet's archived managed events/native log and original
`silver_output_profile.spark`, and verified all ten files in each artifact
inventory. Both runs use the exact candidate hash, level 2, the ordinary
CVC5/Z3/Alt-Ergo portfolio, 30 seconds and 1000 MiB, with warnings/checks as
errors. Both managed terminal events are successful.

| Run | Actual selected proof records |
| --- | --- |
| [`20261107T031832-c8c7ca1eac6d`](../evidence/boolean-arrays-20261106/native-primary-failure/focused-assertion/record.json) | `VC_ASSERT` at 3661:35 proved; new model-call `VC_PRECONDITION` at 3661:44 proved, including all 19 generated subgoals. |
| [`20261107T032305-5aa13a4739f2`](../evidence/boolean-arrays-20261106/native-primary-failure/focused-original-postcondition/record.json) | Original `VC_POSTCONDITION` at 3570:28 proved; all four recorded subgoals have a Valid proof attempt. |

The two reports have two and one selected proof records respectively, plus two
flow records each. These overlapping scoped counts are not a full-helper total.
Reported competing solver attempts that were signaled do not leave a required
subgoal unproved: every inspected leaf has a successful attempt. The report's
`pragma_assume`, `skip_proof` and `skip_flow_proof` lists are empty.

The original unresolved full-run obligation and ordinary timeouts remain in the
separate diagnosis/failure packet. These focused results neither rewrite that
history nor establish that source semantics were defective. The original
canonical run continues to supply diagnostics on its own frozen inputs; no
successful final audit of the new bytes is claimed.

## Source correspondence

`Primary_Model` and its typed expression tree/equation remain unchanged.
`PredicateNativeSourceChecks` still checks that complete model expression and
its headers. `PredicateNativeWorkers.Checked.primarySpec` retains the exact
worker contract; its `primaryBody` field checks the implementation **header**,
not an imperative-body translation. The native-verified contract represented
by `Workers.Refinement.primary` remains the link from the ordinary procedure
to the model. Complete native verification of the changed implementation is
therefore indispensable.

The candidate/helper requirements still feed `PredicateSourceCandidate` and
`PredicateSourceChecks.actualSource`, transported through
`Output.SourceBridge.actual_complete_shape` to authoritative `include_str`
bytes. No semantic tree, domain or header requirement needs modification.
Independent in-memory regeneration confirms:

- The current reviewed pin exactly matches the base's **53,297 tokens**; the
  candidate has **53,320**, solely the added assertion's 23 tokens.
- The complete ordered `OutputBodyCertificate.lean` reconstruction changes;
  its expected generated SHA-256 is
  `71b92953d8b0bb645d03a1418f55fd5a1b7d52de4bbe837480749f647989edd1`.
- The exact line text already occurs in the source, so the unique-line set and
  **all eight** generated `OutputBodyLines` modules remain byte-identical to
  their current checked-in files.

Refresh the full source pin and reconstruction together, preserving the
unchanged buckets, then complete the actual source/module/axiom validation.
The generation comparison is not a kernel check or pin-only approval.

## Regression applicability and smallest refresh

Native source/provenance hashes have changed. The existing binary hash in the
focused packets is explicitly the **old** binary; focused proof did not rebuild
it. A final build must record its actual source, binary, toolchain and generated
configuration. Existing native/application regression passes can remain
applicable through the reviewed Static erasure, provided final integration
confirms those other runtime inputs/settings are unchanged. Do not assert
whole native input-map or binary identity merely from this repair's runtime
equivalence.

Two existing source-reading methods are affected by the new source occurrence
and reconstruction and must be rerun after the final refresh:

- `CompilerSourcePolicyTests.test_checked_in_certificates_equal_regeneration`.
- `CompilerSourcePolicyTests.test_output_body_split_preserves_every_line_proof_and_ordered_reconstruction`.

Other source-policy readers inspect unchanged import/module/alphabet properties.
The native Lean controls use unchanged synthetic inputs. In particular, the
retained native certificate control imports only `Lexical`, `Admission`,
`Cursor`, `SourceLexer`, `CertificateWitness` and `AxiomAudit`, plus its unchanged
generator. It does not consume this native body, full output pin or generated
output reconstruction; its passing result remains applicable. The broad
802-input capture includes changed files, so its old equality claim remains
historical, not a current justification.

Both affected source-policy methods were previously assigned original passes.
Once their successful replacement and the separately required three final
Rosetta passes are inspected, the disjoint coverage partition will be
**588 original + one catalogue + one manifest + seven native fixtures + one
retained certificate + two final source-policy + three final Rosetta = 603**.
Those replacements are pending. This repair does not by itself require a new
full regression suite or repeated synthetic certificate control.

Required remaining work is the exact source/pin/certificate integration,
successful complete native audit/provenance, final build, complete Lean/source
checkpoint, the two affected methods and final Rosetta/commit applicability
confirmation. A separate whole-helper rerun is unnecessary if the complete
native audit supplies its full coverage. No complete feature or merge approval
is given here.
