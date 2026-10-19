# Selected native input materialization and parent capacity design

Research for #145 within #119. The
[source and algorithm argument](../../research/retained-literal-native-materialization.md)
supplies a bounded realizable parent for the exact accepted four-job literal
native invocation graph. Production SPARK/Bronze/Silver/Lean implementation
and correspondence remain mandatory in #89.

```sh
python3 docs/evidence/retained-literal-native-materialization-20261019/check.py \
  --output /tmp/literal-native-materialization-checks.json
python3 docs/evidence/retained-literal-native-materialization-20261019/compose.py \
  --source samples/hello_world.adb --output /tmp/literal-native-materialization-result.json
```

`evaluate(raw, Context(), invocation=None, runtime=None, path_bytes=512,
host_page_bytes=4096)` reevaluates the accepted invocation on the actual raw
bytes; an optionally supplied invocation must match it exactly. The context
checks the pinned predecessor, whose context verifies actual fixed inputs,
installed configuration and retained source correspondence. Context is
immutable while used. Alternative roots use the same accepted path widths.

The result derives all twelve input identities/extents, six directory roles,
eight child outputs, 28 parent paths, four exact argv/environment arenas and
the bounded State layout. It returns `selected_parent_design_capacity_fits`,
not a whole-native or whole-pipeline result. `production_launcher_adopted` and
`production_SPARK_GNATprove_Lean_correspondence_complete` remain false.

`start_copy`, `copy_request`, `copy_step` and `copy_invariant` expose the
partial-I/O arithmetic/prefix model. `start_route`/`route_step` expose the
four-job parent branch. These are executable research witnesses, not a
launcher and not proofs of a nonexistent SPARK implementation. The universal
argument is in the linked research document; the focused tests exercise its
transitions and byte correspondence, including errors and maximum extents.

`inputs.json` pins predecessor sources and records. `result.json` uses the
actual Hello World source. `checks.json` records the focused offline replay;
`round.json` records selected model/effort and available timing. No native
tool, build/proof execution, deployment attestation or production edit ran.
