# Focused Body_Tail equality repair

Source-only commit `d1c90fbbb68c6e85295a9c4402f3124a1b0a29d6` repairs the
unresolved static model equality from the [failed full attempt](../failed-full/README.md).
It adds eight lines to `src/silver_output_profile.adb`: six static proof-code
lines and two comments. Endpoint contracts, mathematical models, executable
statements, domains and prover settings are unchanged.

The final return block names the original model result, connects it to the
existing tail through the loop invariant, and calls the existing checked
`Lemma_Flow_Equality` on the two intermediate `Facts` pairs. This exposes
transitive interval-array equality separately from the surrounding scalar
fields. The final assertion then establishes the full scan equality. No new
helper, trusted assumption or logical-equality annotation was added.

Managed native Linux x86-64 run `20261029T203414-0517c9b1e3dd` passed at
2026-10-29 20:53:55 UTC after **1,179.240 seconds** with one worker. It selected
the complete `Body_Tail` region, lines 3406–3477, in the separate exploratory
workspace and used the existing solver cache, level 2, the same three provers
and the 30-second timeout option. **All 62 proof entries and 287 unit flow
entries were proved**, including the previously unresolved postcondition,
new assertions, both lemma preconditions and the added ghost call's variant.
The completed Why3 session has **330 goals, all marked proved**, including
the aggregate goal and its transformation descendants.

The unit's separate warning inventory contains **50 warnings**: 5 imprecise
array-initialization, 26 recursive-contract and 19 numeric-variant advisories.
There are no unresolved proof/flow entries. This is focused proof evidence;
the complete native coverage/provenance audit and complete Lean/source checks
remain required on the repaired source bytes.

`summary.json` records exact scope, duration and input identities. The source
SHA-256 is `84779089d15b9e7990fd806de3a8965edfb5bdeacac2c02544cb0c9d28ba6a8a`.
All 2,580 captured native inputs matched at retention, captured tool executable
hashes were verified, and all 143 tracked native inputs match the source-only
commit. The packet preserves the patch, source, complete focused reports,
task, session, shapes, input/tool snapshot, native log and managed ledger.
Retained report copies and archived hashes were compared directly.

Runtime erasure follows the pinned SPARK 16.1 rules. The
[assertion-policy rules](../../../../../references/spark/16.1/docs/lrm/source/exceptions.rst)
at lines 152–161 give Static-level ghost entities and assertions the Ignore
policy; lines 230–231 state that Static assertions are never checked at
runtime. The [ghost-statement rules](../../../../../references/spark/16.1/docs/lrm/source/subprograms.rst)
at lines 2207–2223 classify a call to a ghost procedure as a ghost statement
with that procedure's assertion policy. Lines 2239–2248 state that ignored
ghost declarations/statements have no runtime effect and generate no code.
`Original_Tail` explicitly has `Ghost => Static`, both new assertions specify
`Static`, and the existing `Lemma_Flow_Equality` declaration at source line 2255
has `Ghost => Static`. Thus this repair adds no runtime model evaluation,
recursive stack growth, scan copy or lemma call. Global `-gnata`/`-gnato`
checking in [silver.gpr](../../../../../silver.gpr) remains unchanged.

The selected agent was GPT-6 Astra / Extra High; runtime model confirmation and
token/cost measurements are unavailable. This was the first repair candidate,
and its focused run passed without another source iteration. Independent
source review was coordinated by the lead against the exact source hash above;
the lead retains that review separately. The failed complete run stays failed,
and its caches and reports remain preserved for the final validation checkpoint.
