# Boolean equality-transport repair review

Read-only review on 2026-10-30, 20:43:52–20:45:48 UTC (1m56s).
Reviewer selected GPT-6 Astra / Extra High, confirmed from the lead's spawn
metadata; independent runtime confirmation and token/cost measurements were
unavailable. No edits, tests, builds, proof runs or publication were performed
by the reviewer. The lead retained the returned conclusions here.

## Inputs and verdict

Baseline implementation `b6aeb9f978597ac025de21a8574c76c42389cf82`, current
integration HEAD `2a35084ea47d094d461d1e8ca6a31bf9de887e2a` (later changes are
records), against the native worktree's `src/silver_output_profile.adb`:

| Source | SHA-256 |
| --- | --- |
| Baseline | `9542d721cb1d63f936704058e6e0705b615fdce9e86d08397a2384c7714cc4a0` |
| Candidate, unchanged at review end | `88b54a1df3e6cb1b59c482d36cd29a9f15c2506c69227fbef78c9ab93ab67ddb` |

Also inspected: the [generated-task diagnosis](review-boolean-equality-transport-diagnosis.md),
preceding reviews, relevant contracts, models and equality helper, source
bindings, Lake dependencies and regression fixtures.

**No static blocker found.** Native discharge and complete source assurance
remain separate pending requirements. The successful first-branch diagnostic
does not establish the complete candidate's proof.

## Source and proof argument

The relation repair preserves every executable call, branch, assignment and
return. Added snapshots are `Ghost => Static`; calls target the unchanged
Static equality lemma; assertions are Static. The new declarative block
contains only ghost objects. Under the established pinned-toolchain erasure
argument, executable meaning is unchanged; binary identity is not claimed.

Entry snapshots use the unchanged model domain. The right-factor snapshot
follows the nonzero comparison branch, whose cursor postcondition supplies
the position bound. Model result counts justify the constrained snapshots.
Equality-lemma preconditions follow from initializers or unchanged factor and
invalidation postconditions. The existing helper proof retains nested array
bounds, including `Count = 0`. Branch assertions add obligations rather than
assumptions. No admission restriction, contract weakening, model alteration,
suppression or unchecked proof path was added.

The remaining branches select the unchanged model: absent comparison returns
the first factor; disallowed comparison yields invalidity; the right-factor
branch snapshots invalidity or `(Facts.Count, Right_Model.After, Facts, Facts)`
before mutating the output. In the eager-chain branch, `Right_Model` selects
exactly `Relation_Model(..., Incoming, ...)`. Its substitution into the lemma
preserves the required equality and subsequent assertions.

Only `ReviewedOutputShape.outputImplementation` and the regenerated
`OutputBodyCertificate.lean` require repository proof-source updates.
`PredicateNativeWorkers.Checked` captures unchanged specifications and body
headers. Model/helper source requirements are unchanged. `OutputProfileBodySource`
already embeds the Ada file with a binary Lake dependency. The resulting
pin/certificate delta and complete transitive source checks remain required;
regeneration alone does not establish correspondence.

## Regression applicability

Static fixture/inventory inspection reconfirmed the existing refresh scope:
12 source, 16 platform, 17 output-integrity and one Silver tool/source-change
identity. Platform fixtures copy changed Ada and Lean inputs; the 18 integrity
identities compile current Ada in isolated fixtures. Conditional on successful
reruns and final-input verification, 46 refreshed plus 522 retained results
cover all 568 identities. Other runtime/sample results remain applicable through
ghost erasure; Rosetta dependencies are unchanged. Rebuild the final compiler
from matching inputs. Complete native proof/audit and Lean/source/module/axiom
validation remain mandatory.
