# Fixed-array Compose helper domain review

Date: 2026-10-27. Scope: the native-to-model array declaration chain for
[#260](https://github.com/berkeleynerd/silver/issues/260), based on `f2b5791d5a`.
Independent reviewer: selected GPT-6 Astra / Extra High; runtime settings and
token/cost measurements unavailable. Read-only review, 10:24:06–10:29:10 UTC
(5m04s); no Lean or native execution. This is a scoped implementation review,
not the complete feature review or validation checkpoint.

## R1 — Raw helper equations omit native scalar-state conditions

Severity: blocker for completing actual-source correspondence.

`ComposeContracts.ArrayValuesDomain` uses base `Compose.Expressions.ValidState`
for its source and accumulator. The `arrayAdd` equation uses that same base
predicate. Native `Valid_State` also requires `Valid_Mutable_Bounds` and
`Valid_Declaration_Values`, represented by `ScalarMetadata.HeaderReady` in
`PredicateOuterReadiness`. The raw equations therefore demand behavior outside
the verified native preconditions. For example, the base predicate permits an
otherwise valid scalar binding with an empty bounded interval; native declaration
validity rejects it.

Required repair: parameterize the aggregate domain by the caller's `StateDomain`
and use that domain for array-add. Preserve its scalar-specific facts through
array updates, which leave scalar names unchanged. Both existing domains support
this transport. Keep rejected aggregate results at base validity until success
is established; success preserves the scalar fields and recovers the caller's
domain. This adds no restriction on admitted source programs and assumes no
stronger array allocation readiness.

Disposition: accepted and tracked in [#262](https://github.com/berkeleynerd/silver/issues/262);
the domain repair is implemented in `123f84ec2a` (reviewer branch `c945d6afe0`).
Focused native-bound and outer-readiness checks passed in
`20261027T103514-e3ba7fe5106a` (41.406 s build, 5.291 s fresh audit, 11,919
declarations; approved foundations only). Caller integration and the final
source-correspondence checkpoint remain outstanding.

## Other conclusions and inputs

The declaration equality is derived from the typed native body and helper
equations, not assumed directly. Guard, capacity, constructor, offset and cursor
premises match the reviewed native routines. No additional issue was found in
this slice. Updated source checks, reviewed output pin and certificates remain
known pending integration work.

The review included these uncommitted inputs on the stated base:

| Input | SHA-256 |
| --- | --- |
| ComposeEquations.lean | `a0bfada6933dbc2f0b81821fa8606d8f3e46ef9ef9df388ba0ecd0183dd27914` |
| ComposeEvaluation.lean | `9ace7447b1b87a7c3892ecad5425d46a405d6bd6627c0ab3f89b65fe0a47bdef` |
| ComposeModelEquations.lean | `731fd9a09c5e558334e87e7d839e6782ff10741b8d6a173719c352c2770dd4d8` |
| native silver_output_profile.adb | `ca0975c9c2c03dd1fbdf71d79b91b086ed98285e586ffd5c4e6cc5b652697539` |

The native snapshot used `Spelling (Integer_Name)` in the two array declaration
name tests. Subsequent native compilation rejected that expression form; the
shared static `Integer_Type_Word` alternative is being checked separately.
Neither spelling changes the reviewed state-domain finding.

## Complementary snapshot and composition review

A separate GPT-6 Astra / Extra High subthread reviewed the mathematical
integration at `182f9ade2c` (source commit `8ce17b1178`) read-only from
10:30:33–10:33:21 UTC. The ten requested composition/header/trace files were
byte-equal to that commit. Runtime settings and token/cost measurements were
unavailable; no validation runs or edits were performed.

No missing link was found: scalar, String and array initializer snapshots use
their incoming declaration state; the actual parsed header supplies the final
array environment and initial store; raw initializer/index/arithmetic checks
enter program obligations. Body reads use full Integer ranges even for constant
arrays. Source-derived index bounds establish array/loop identity separation,
and loop execution captures bounds before iteration. The pending native helper,
source-check and certificate work was explicitly outside this mathematical slice.


## Caller-domain repair review for #262

An independent subthread selected GPT-6 Astra / Extra High reviewed the caller
integration on 2026-10-27, 11:20:52–11:23:35 UTC (2m43s), against the exact
uncommitted `ComposeArrayEquations.lean` snapshot below. Runtime setting
confirmation and token/cost measurements were unavailable. This review was
read-only and ran no Lean/native checks; the separately active output-certificate
run supplied no evidence for this conclusion.

No remaining caller-domain defect was found. R1's caller integration is closed
for this snapshot; the final source-correspondence checkpoint remains separate.

- `ArrayValuesDomain` carries both complete caller contexts. Aggregate entry
  supplies the original domain twice; recursive `next` preserves the source
  context and transports the accumulator's domain after `putArrayValue` using
  proved native validity and unchanged scalar names.
- `OuterReadiness.domain.transportScalar` explicitly retains `HeaderReady`,
  including nonempty declaration values and mutable declared-bound containment.
  The Predicate outer/source interfaces instantiate this domain, so the native
  scalar clauses are not lost through the generic helper interfaces.
- `model_arrayValues_valid` establishes base validity on both success and
  rejection. `interpreted_arrayDeclaration` uses the nonzero-result branch and
  `arrayValuesModel_preserves` before recovering the caller domain for
  `Add_Array_Binding`. It does not transport arbitrary caller facts across an
  invalid result.
- The raw put call derives available storage from the aggregate capacity and
  parsed-count relation, and obtains value representability from inference.
  The raw append call separately supplies the recovered domain, positive valid
  name, valid descriptor, descriptor-count room, initialized offset/length
  coverage, and the following cursor bound. Scalar reads, lookups, token calls
  and emptiness tests receive their own checked domains.
- Neither recursive aggregate interpretation nor append construction assumes
  `SourceReady`, canonical table length, ordered/nonoverlapping descriptors, or
  static scalar environments. Both current `StateDomain` transport instances
  are proved from their definitions; the repair adds no unproved native-domain
  assumption.

The primary review inputs are the first four proof files below and the final
native body. The remaining files supplied the targeted preservation, helper
contract, typed-update and outer-interface checks. The hashes identify the reviewed snapshots; the four primary proof hashes
were rechecked unchanged at the end of the review.

| Input | SHA-256 |
| --- | --- |
| proof/Silver/ComposeArrayEquations.lean | `e66d337fddd89bc8803f4d4ed618a775a2f72e99b5f69c164d22e00201d5cd68` |
| proof/Silver/ComposeContracts.lean | `5316016b6884d083c3c0fd93e9486ffa9775a8a3586b93aa31a69a52d3fbcaea` |
| proof/Silver/ComposeArrayNativeBounds.lean | `6245037d39c30d773125c7f95793c0401328633d0e9af16b6ed916f45066163b` |
| proof/Silver/PredicateOuterReadiness.lean | `07c59301dcadfd92374a8b107bd9fd55ce1559b7ac4e30aa3edbe6b750adb666` |
| proof/Silver/ComposeHelperEquations.lean | `d533ad30f792115ea42d42495523e080eef897533eb1e8002ef32e6c35c89f75` |
| proof/Silver/ComposeAdmission.lean | `b67f3c7567a774714ebfa638e7c6005e096f7b40a2058e67d2c6b16eb7073577` |
| proof/Silver/ComposeArrayExpressions.lean | `328e3a7355c984d9e6d438553175bcd1397679c98a8110f8aa763792d76bc5de` |
| proof/Silver/ComposeStateBounds.lean | `00eb0716e0d96f2bae4cf566672b024d9462183098839693e4ebc7bab24b8eeb` |
| proof/Silver/ComposeSourceBridge.lean | `dfe78e84d10e0972b851f05716b5f3585020ff4e31610d7164efa1c52effc181` |
| proof/Silver/PredicateSourceBridge.lean | `66cb83160567f502f7afbc5bb59aaac1f2480d575bcf04eecc6413500be8bd08` |
| proof/Silver/PredicateOuterEquations.lean | `2d1fc81be5a12c3b2d43521178f80eea229aae0f60c00fb2f9a6ac0b5456ea39` |
| src/silver_output_profile.adb | `446ac3f3e668096e5cdda361bfa21bbc7dac747ea637659de2cae951d767d794` |
