# Report policy branch repair — bounded source review

No soundness, contract, domain or runtime-behavior blocker found in the exact
candidate recorded in `manifest.json`. Native success is still unestablished.
This is a review of the proposed delta, not a new complete report-policy review.

`Record_OK` only adds local Hide_Info for the bodies of `Termination_Policy` and
`Initialization_Policy`. Its full pre/postcondition and executable body are
unchanged. Both called executable helpers already specify exactly the policy
result on the same arguments. Their contract facts suffice for the two leading
Main_Diagnostics disjuncts without unfolding the policy definitions here. Hiding
bodies removes local proof information; it does not assert a new fact, weaken a
contract, suppress a required obligation, or hide either helper from its own
required verification. Their separate complete native discharge remains required;
the retained two-caller failure packet is not fresh evidence for those helpers.

The added raw/text termination and initialization assertions are valid
intermediate consequences of the unchanged Record_Observation_Agreement and
existing helper calls. That agreement includes entity-name equality and every
policy field/message observation. Mixed_String_Congruence supplies the fixed
strings and termination message, Mixed_Test_Congruence the numeric/classifier
facts, and Mixed_Initialization_Index the output-initialization index equality.
Missing/malformed fields are covered by Mixed_Field. No added source or metadata
validity restriction is required by these assertions.

The explicit `Kind in Main_Diagnostics` case covers exactly kinds 2..5. It is
disjoint from References=7, Main_Advisories=6, and the exact witness ranges that
start at 11. The existing initializer/output classifier equalities cover both
boolean arguments and the procedure-output message case. The candidate retains
the original unconditional whole-record postcondition for every allowed Kind,
so the branch assertion does not excuse the other cases. All added assertions
are proof obligations, not assumptions. Mixed_Record_Congruence remains Ghost
=> Static, hence the added branch/assertions have no runtime effect under the
existing SPARK interpretation.

The candidate adds exactly four annotation lines in Record_OK and three assertion
proof cuts (one conditional) in Mixed_Record_Congruence. No function body,
precondition, postcondition, domain, policy result or proof budget changes.
The local-abstraction hypothesis is reasonable given the retained limit/steps
failures, but this inspection cannot predict solver completion. Recheck the
complete affected callers and every new assertion at the production recipe;
then retain the existing complete native coverage/provenance checks. Extend only
the exact annotation allowlist sites and focused policy tests as planned.

Settings, exact input hashes, evidence limitation and unavailable measurements
are in manifest.json. No root or producer file was modified and no proof run was
started by this review. Existing certificate monitoring continues separately.
