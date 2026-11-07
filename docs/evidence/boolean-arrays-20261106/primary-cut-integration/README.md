# Primary branch cut: integrated source refresh

The [independent cut review](../../../reviews/review-boolean-array-primary-cut-20261107.md)
identifies the one new Static assertion, its two focused native passes and
unchanged runtime/model/domain/header meaning. Integration changes the exact
native body, the complete token pin (53,297 to 53,320 tokens) and ordered
reconstruction. The generated reconstruction matches the review's independently
derived hash; all eight line modules compare byte-identically. Exact hashes are
in `refresh.json`. This mechanical refresh is not source assurance by itself.

Managed source-policy run `20261107T033450-68e053be5f6d` passes both affected
methods: checked-in certificate regeneration, and preservation of every line
proof and ordered reconstruction. Unittest elapsed: 7.399 s; no skip or failure.
The compressed managed events/log retain actual inputs, configuration and timing.
These two methods replace earlier successful results in the final inventory;
no new full-suite success is claimed. Final native build/proof/audit, complete
Lean/source assurance and the final Rosetta three-method rerun remain required.
