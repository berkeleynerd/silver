# Independent certificate-core review — 2026-11-15

**Accepted for integration and complete validation; no material static finding.**
Target: `a33c7cba9da346db8be795f9dab25d44ea50bb0d`, consisting of core
`bef580d1f` and its comment-only cache clarification. The complete aggregate
was still running during this review; this acceptance does not claim that it
or complete project/source assurance has passed.

The reviewer read `CertificateJoinWitness.lean`, its actual pinned
`mkAuxLemma` implementation, the unchanged `CertificateWitness` and
`SourceLexer.string_join_ofList` / reconstruction definitions, the generator
diff, expanded native controls and retained focused evidence. This reviewer
did not author the final helper. An earlier direct-reflexivity suggestion
was rejected by the author and is not the adopted implementation.

The native metaprogram constructs only typed `List Char` constructors and an
application of the existing proved `string_join_ofList` theorem. Native
string decoding, `toExpr`, list reversal and generation are untrusted witness
construction. Incorrect characters, order, Unicode values or lengths cannot
prove a different goal: the completed witness is checked at the exact
instantiated target by `mkAuxLemma`, with async checking disabled. There is no
native-evaluation theorem, unchecked declaration insertion, bypass flag or new
axiom. Free/unresolved metavariables are not an escape: a declaration containing
them cannot be accepted by the kernel. Current generated goals are closed.

The pinned auxiliary cache is keyed by exact goal type, privacy and defeq tag,
and additionally compares universe parameter lists. A cache hit may reuse an
already checked proof of that exact goal without checking the newly supplied
candidate. The revised module comment states that distinction correctly; it
provides no way to prove a false goal. Ordinary private/transitive axiom auditing
remains required and unchanged.

Independent generation on the actual 424,747-byte source
`619f4fb8e2b0f318dac7c6278d5f644198816ce7733959ed71ca03917546b2b8`
found all eight line chunks identical between old and new generators. After
removing only old/new join-witness syntax, the complete reconstruction output
is byte-identical, including all 7,025 joins, ordered line occurrences, joined
string literals and final source/token/lexer statements. All 31 other source
certificates generate identically. `certificate-independent-parity.json`
records these checks and reviewed file hashes. This comparison uses identical
current source bytes; it does not confuse the older checked-in candidates with
the old generator's current output.

The generator still validates actual bytes, splits at LF without dropping a
final empty occurrence, preserves CR and duplicate/blank lines, and uses the
same balanced reconstruction and whole-token check. Only the output aggregate
imports the new helper. Existing source dependencies, pending publication and
fresh audit machinery are unchanged.

Retained focused controls cover Unicode and empty joins, mixed CR/LF and absent
final LF, changed/truncated source or witnesses, shifted newline boundaries and
missing flattened tokens. They compile current helpers in fresh temporary
workspaces and audit successful fixtures. The final five-method control run
passed; the earlier full-file test remains failed on pre-existing stale
OutputSpecCertificate parity and is not reclassified. The actual-size single
join passed its fresh audit under a 3,072 MiB threshold; this is distinct from
the pending complete aggregate measurement. No Lean/native proof run was
started by this review; the independent checks were generation/parity only.

Selected review setting: GPT-6 Astra / Max. Live runtime model/effort and cost
are not independently exposed. No reviewed checkout, cache, source or GitHub
state was changed by the reviewer. Complete native, source/facade/module/axiom,
provenance and applicable regression obligations remain with the lead.
