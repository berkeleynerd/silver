# Boolean equality transport diagnosis

Read-only inspection on 2026-10-30, 20:20:55–20:26:55 UTC (6 minutes).
Reviewer selected GPT-6 Astra / Max for the named problem of four failed
Boolean relation equality cuts. Runtime confirmation and token/cost measurements
were unavailable. No edits, proof runs, tests or GitHub actions were performed.
The lead retained these returned conclusions; routine proof work continues at
the existing Extra High setting.

Source input SHA-256:
`c4d4dad3f868910bf1ee86168ee099406ed0c50b74cf39e26135eb662a4a7b79`,
from failed run `20261030T200101-c56457a2df8d`. The inspected generated artifacts
were under that run's installed `boolean-terminal-repair-relation/gnatprove`
directory; its report/session evidence and local task retention are linked in
the [experiment packet](../evidence/boolean-objects-20261030/terminal-native-repair/README.md).

| Artifact | SHA-256 |
| --- | --- |
| `silver_output_profile__read_boolean_relation_into.gnat-json` | `6e1511c41e753872df805b2bb6eee099aac0ac940e015e94078487af548777f0` |
| Reader `why3session.xml` | `22672a264065d0675e7568c0bf3c41f58d4ef0709ed9ee95f636467210106e16` |
| Reader `why3shapes` | `3991c26c0149203e81c7a3d882acfd9bf15a662f036cf01a5cd8a9a5b2f670a9` |

The model's branch expansion is already present. For the first failed
assertion, transformed task `def'vc.57.0` contains:

- Shape 72: the expanded `Boolean_Relation_Model` expression.
- Shape 81: `bool_eq(Result_after_factor, Boolean_Factor_Model(...))`.
- Shape 86: `bool_eq(Result_after_invalidation, Invalid_Condition(Facts))`.
- Goal 88: logical `Result_after_invalidation = to_base2(Expected)`.

`Same_Condition` translates to logical equality through its verified
`Logical_Equal` annotation. The procedure contracts supply Ada `bool_eq`.
Existing `Lemma_Condition_Equality` provides the missing implication while
retaining equal array bounds, including `Count = 0`.

The constrained `Expected` snapshot adds a representation conversion. Its
initializer establishes `Expected = of_base(model_result)`; conversion back
reconstructs nested vectors through
`of_array(to_array(v), first(v), last(v))`. Logical identity with the model
result therefore is not syntactic. The initial equality lemma already used
by `Read_Relation_Into` is justified here too. Bridging only `Expected` leaves
the separate invalidation-result equality unresolved.

The proposed first-branch discriminator uses existing helpers: bridge
`Expected` to the relation model at entry; bridge the first factor result
to its model immediately after the call; establish the selected invalid
model branch before mutation; bridge the invalidation result to
`Invalid_Condition(Facts)`; retain the final logical equality assertion.
This separates branch selection from each checked equality conversion.
Putting the entire exit equality into a lemma precondition would retain
the original difficult obligation without identifying its cause.

The native agent applied that discriminator as source SHA-256
`32b2915b2b66bc6e506549c2fb021c9e81814d413b76b4ff9f96b87918efb2c8`
and started a focused region check with unchanged proof limits. No success
result was inspected. Contracts, domains, executable behavior and helper
definitions remain unchanged. The other branches, complete native audit and
actual-source correspondence remain required.
