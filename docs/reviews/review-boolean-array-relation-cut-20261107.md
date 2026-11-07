# Boolean-array Relation assertion: independent repair review — 2026-11-07

**The one-assertion repair is appropriate, and both focused checks pass.** The
new local assertion and retained merged assertion, their model-call preconditions
and range checks have applicable native evidence. Complete-helper evidence has
not been independently reviewed here. Complete native and Lean/source assurance
remain required independently.

## Exact target and review record

Reviewed the two-line assertion proposed in
`tmp/relation-diagnosis/relation-false-flow-cut.patch`, SHA-256
`6f88d7bc16fc00e846a89f04d6c10966fc1f71dffa3f0ec9a1f1a1603861b86b`.
The integration HEAD at the independent source comparison was
`67a1b36213828a38c850c0992e7ae59eeaf1f9c4`, with native implementation from
`e0d2521d5d`. The candidate is the uncommitted native body in
`tmp/image-case-repair`, based on `9d9c786dceac6160c6fff521ed273fddfdfa628b`.
Exact native body identities are:

- Current integration base, including the reviewed Primary assertion:
  `c1ce845a597605c152119bedc6b07f1aa3bccece5d2870addb86cd18077fffaa`.
- Relation candidate:
  `7d39745bd9e2d57c573a1c398f9e0f07e486a9d482b60f1cd21fc436e48543f3`.

The [input record](../evidence/boolean-arrays-20261106/final-review/relation-cut-inputs.json)
and [generation comparison](../evidence/boolean-arrays-20261106/final-review/relation-cut-generation.json)
identify reviewed source, policy, semantic and certificate inputs. Selected
reviewer: **GPT-6 Astra / Extra High**; independent runtime confirmation and
token/cost measurements are unavailable. Initial source inspection ran
**2026-11-07 04:00:44–04:03:44 UTC**, approximately 181 seconds; native evidence
review and report preparation followed, with completion time in the input record.
No governed source edit, proof/native
or test job, process-control operation, agent fan-out or GitHub action was
performed by this reviewer. Generation executed the unchanged generator purely
in memory and wrote only the assigned review evidence.

## Source meaning and complete domain

Independent byte comparison finds exactly one added assertion immediately after
the false-flow selected-cell assignment inside `if Target /= 0`:

```ada
pragma Assert (Static =>
  Result.When_False = Refined_Flow (Facts, Target, Selected, Threshold, False));
```

The false flow was initialized to `Facts`. In the nonzero branch, only its
selected value changes, using exactly the expression in `Refined_Flow`.
Count, path and all other values remain the same. `Bare_Target`'s postcondition,
`Valid_Flow`, and the procedure's count equality give `Target <= Facts.Count`.
In the zero-target branch, including an allowed zero count, the false flow
remains `Facts`, which is precisely the zero-index model branch. The added
assertion applies only to the existing nonzero branch; it does not restrict
which inputs or execution paths the procedure admits.

The original merged equality remains at candidate line **3948:18**, followed
by the existing equality bridge and later obligations. Every previous branch,
executable statement, procedure/helper contract, `Initials` domain and
termination variant is unchanged. The new ghost-model call creates a real
precondition obligation rather than supplying an assumption. No weakening,
suppression or semantic model change was found.

The pinned SPARK 16.1 LRM
[assertion-policy and dynamic-semantics rules](../../references/spark/16.1/docs/lrm/source/exceptions.rst)
make Static assertions always Ignore and never runtime checked; the
[user guide](../../references/spark/16.1/docs/ug/en/source/specification_features.rst)
confirms compiler options cannot override this. Existing `-gnata`/`-gnato`
flags therefore do not execute the assertion or its ghost call. Runtime
equivalence here follows from exact source delta and the pinned policy, not
from a newly built binary.

## Native evidence inspected

The original failure remains the completed Relation helper in full audit
`20261106T232644-673fc5a9c06b`, on old native hash `1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8`.
Its diagnosis maps unresolved `def'vc.368.0` to the merged false-flow equality,
old line 3945:18. Ordinary 30-second solver attempts timed out without a
counterexample. The reviewed candidate does not rewrite that failed history.

The focused packets are
[`20261107T040114-c0bc2424d7bc`](../evidence/boolean-arrays-20261106/native-primary-failure/relation-focused-local-assertion/record.json)
and
[`20261107T040331-451c30667872`](../evidence/boolean-arrays-20261106/native-primary-failure/relation-focused-original-assertion/record.json).
All ten artifacts in each packet and all 21 members of each packet's two
archives match their inventories. Both archived sources have the exact
candidate hash; all 2,586 captured input hashes and tool identities match
between the runs. Both managed terminal events are successful, and the archived
native logs and original `.spark` reports agree:

| Selected proof record | Actual result |
| --- | --- |
| `VC_ASSERT` at 3934:21 | One leaf with a Valid proof attempt. |
| `VC_PRECONDITION` at 3934:41 | One leaf with Valid proof attempts. |
| `VC_RANGE_CHECK` at 3934:27 | Both leaves have a Valid proof attempt. |
| Original `VC_ASSERT` at 3948:18 | One leaf with a Valid proof attempt. |
| `VC_PRECONDITION` at 3948:38 | One leaf with a Valid proof attempt. |
| `VC_RANGE_CHECK` at 3948:24 | Both leaves have a Valid proof attempt. |

Each run reports three proof records plus two successful flow records, five
checks total, in 106.762 and 115.955 seconds respectively. These overlapping
scoped counts are not a full-helper total. Both use two workers, ordinary level
2, CVC5/Z3/Alt-Ergo, configured `--timeout=30`, 1000 MiB and warnings/checks as
errors. The original assertion's successful CVC5 attempt records 32.685 seconds;
the configured timeout is not presented as a measured upper runtime bound.
`pragma_assume`, `skip_proof` and `skip_flow_proof` lists are empty. Signaled
competing attempts do not leave a required leaf unproved. The isolated
experiment cache was used with ordinary matching; no cold-cache claim is made.

Complete-helper evidence has not been independently reviewed. These
line-selected checks establish neither the procedure's full postcondition nor
complete native assurance.

## Source correspondence and regeneration

`PredicateNativeScalarHelpers.Checked` retains exact model/helper body and
header checks, including `Refined_Flow`'s `Index <= Facts.Count` precondition.
`Workers.Refinement.relation` preserves the complete legal domain, valid
initials and count equality. `Workers.Checked.relationSpec` checks the full
native contract; its `relationBody` checks the implementation **header**, not
an imperative-body translation. Complete native proof is still necessary to
establish the ordinary implementation's model equation.

The typed `Relation_Model` body/equations and source requirements are unchanged.
`PredicateCharacterSourceCandidate.relation_body`, the native-shape/source
candidate and authoritative complete-shape transport remain the source route.
The complete imperative body must remain in the full source pin and ordered
reconstruction. Independent in-memory generation confirms:

- The checked-in base pin exactly matches **53,320 tokens**; the candidate has
  **53,343**, adding only the assertion's 23 tokens.
- `OutputBodyCertificate` changes to expected generated SHA-256
  `dbf48fbbf186b92aaaed942a952faa9af24fa0f72fc625d833091b5f6fd0d8cd`.
- Only `OutputBodyLines5` changes, to expected SHA-256
  `b0c8c4371731cb3f779f8402a2e5ccc157ece1318354bcbf628a5708eca8d7b2`.
  The added equality's exact indentation creates one new unique source line;
  the other seven buckets are byte-identical.

The lead integrated the full implementation pin, reconstruction and that bucket
together while this review was in progress. At 04:07:31 UTC, independent
comparison confirmed the exact candidate body, all 53,343 pin tokens, all nine
generated module hashes and unchanged remaining reviewed inputs. This closes
the source-refresh comparison, not the kernel or complete source-assurance
obligations. The change remained uncommitted on the identified integration HEAD.

## Regression reuse and remaining work

The [Primary review](review-boolean-array-primary-cut-20261107.md)'s regression
applicability analysis extends to this additional Static assertion. Retained
behavioral passes remain applicable only after confirming unchanged final
toolchain, generated runtime, routing and other executable inputs. Old native
source/provenance or binary hashes are not final candidate identities. A final
build and complete native audit on the integrated bytes are required.

The same two existing source-policy methods need fresh passes after the final
source/certificate refresh: `test_checked_in_certificates_equal_regeneration`
and `test_output_body_split_preserves_every_line_proof_and_ordered_reconstruction`.
The separately required three final Rosetta checks and final commit/metadata
applicability review remain pending. The retained synthetic certificate fixture
does not consume this body, pin or generated reconstruction; its narrow
six-module/generator dependency argument still applies. Broad captured input-map
identity does not. No extra whole regression rerun is justified solely by this
reviewed annotation.

Required remaining evidence is complete helper or full native coverage, final
build/native provenance, complete Lean/source/module/axiom audit, affected
source-policy and Rosetta checks, and final applicability review. This report
does not approve complete feature assurance or merging PR #335.
