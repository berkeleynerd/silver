# Named-field source-bridge repair

Focused Linux run `20261107T032925-b6d64f6ff906` passed `Silver.ComposeSourceBridge` and a fresh
318-module / 92,000-declaration audit. Build: 19.871 s; audit: 15.088 s.
Only `propext`, `Classical.choice` and `Quot.sound` were reported. Automatic
allocation granted six Lake workers and twelve threads per process, with the
24,576 MiB threshold. No clean build or independent replay ran.

The [independent review](../../../reviews/review-boolean-array-equation-fields-20261107.md)
checks the unchanged proof bodies attached directly to their named fields.
All 762 captured inputs matched at retention. The exact uncommitted repair
is identified in the input map; other inputs match `1b4ab33131`. Native source
remained at `1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8`.
This precedes the separately reviewed native Static assertion and is partial
validation, not a final source or whole-project assurance checkpoint.

The compressed manifest, log and managed events retain exact scope, tools,
configuration and the successful terminal result. `input-correspondence.json`
retains the input comparison; `SHA256SUMS` covers this packet's other files.
