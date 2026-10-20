# Review: model-meta dependency attachment

2026-10-20 UTC; #119 / #153. **Accepted as an attachment of the already
independently reviewed meta-preservation result**, at exact author freeze
`74160d811bbcebea43d9af9f61bae9a2e26529fb`. This is a focused integration
review, not a new review of the full transformation semantics.

The lead reviewed the [new note](../research/retained-why-model-meta-control.md),
its [input manifest and checker](../evidence/retained-why-model-meta-control-20261020/README.md),
generated attachment/results and the original
[library-origin argument](../research/retained-why-path-library-origins.md#selected-writer-closure)
and [Round 32 acceptance](review-save-capacity-round32-20261020.md).
The reviewer did not author the attachment. Live lead model/effort and
individual token/cost telemetry are unavailable; no model change is claimed.
Author-selected Astra / Extra High is separate from the lead's live settings.

The exact five native input identities, PIDs, argv, environments and temporal
cuts agree with the standard-control inputs. Both capture plans match the
accepted fourteen-driver and eleven-library closures. The resolution check
preserves identities and ordered import edges, with unique basenames before
normalization; it relocates the private overlay directory rather than silently
ignoring file or import differences. All four overlay members are checked.
The selected twenty-transform/three-printer dispatch is unchanged.

The original accepted argument already excludes the counterexample meta in
initial and reconstructed tasks. Its prior use to exclude extra library reads
does not limit the same control fact to those effects. The later standard
control packet had not imported this theorem; its null field was a missing
dependency, not evidence of a contradictory execution. No earlier packet is
rewritten to suggest that it had already supplied the join.

The new result-transport attachment was inspected in the retained source:
`call_on_buffer` passes the option to `call_on_file`, whose `save_data.get_model`
field is immutable; `handle_answer` retrieves that field for parsing.
Every selected inserted value belongs to the same None domain. A lookup
failure does not create a value, and an ID collision selecting another valid
entry cannot create Some. `record_model` dispatches `prp_model_parser` only
for Some. Under the retained selected-client/table relation, the callback
count is therefore zero even for model-looking solver output. This does not
exclude ordinary answer parsing or other diagnostics.

Ran the new checker once in comparison mode on the untouched author worktree:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-model-meta-control-20261020/check.py
```

It passed five cuts, two driver groups, fourteen drivers and eleven libraries
per group, twenty transforms and nine excerpts, in **2.345358864 seconds**
(checker timer). Git status remained clean. The clock-observed final
checker/source inspection interval was **16:35:03–16:35:15 UTC**, twelve
seconds; it excludes the earlier note/provider reading and this report.
Complete review elapsed time is unavailable. No previous checker, source
census, target, capture, debugger, disassembler, solver or proof was run.

No required repair. Meta names/maps were not decoded by the task observer;
the result correctly uses source construction/preservation and exact input
identity instead of claiming a raw observation. Standard initial state,
prospective whole-interval B/E, other diagnostic owners, complete R/U and
physical adequacy remain separate. This attachment does not complete #119
or #153, change admission/tools/Oracle, start production or authorize merging
draft PR #121.
