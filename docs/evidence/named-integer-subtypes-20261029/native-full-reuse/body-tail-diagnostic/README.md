# Body_Tail diagnostic during the complete native run

Read-only checkpoint for [#286](https://github.com/berkeleynerd/silver/issues/286),
captured on native Linux x86-64 at 2026-10-29 20:28 UTC. The selected reviewer
was GPT-6 Astra / Extra High; runtime model confirmation and token/cost
measurements are unavailable. The inputs are the exact source and translated
task snapshots identified in `summary.json`, applicable to implementation
`97312a790fb11a83a9607ad48ddab491711f2c3d`.

Run `20261029T165015-c6b111fb4f2a` was still active on `Read_Form`. Its
`Body_Tail` session had completed with 304 of 305 split goals proved. The
remaining `def'vc.304` had timeout results from Alt-Ergo, CVC5 and Z3; its only
alternative transformation, `introduce_premises`, also had a timed-out child.
Neither the subgoal nor its aggregate goal was proved. This is a confirmed
unresolved session obligation, pending the final native report and run outcome.

The Why3 shape inventory associates that goal with the static postcondition
`Body_Tail'Result = Body_Tail_Model (Text, Context, Scan, Stop)`, on source
line 3414. The generated compound postcondition label is
`GP_Check:2041:VC_POSTCONDITION:silver_output_profile.adb:3412:28`.
`summary.json` retains the exact mapping, XML fragment and artifact identities;
the complete XML, shapes, GNAT JSON and source bytes are compressed here.
`input-comparison.json` verifies all 143 tracked native inputs against the
run's captured hashes, current native workspace and implementation commit.

Earlier all-proved progress samples did not establish completion of this
session. Its current XML was written at 20:22:09 UTC; the all-proved `.bak`
belongs to 2026-10-28 and does not establish the result for these inputs.
The 75 emitted unit reports still had no unresolved proof or flow entries;
the output-profile unit report and complete audit remained outstanding.

The next hypothesis is a small explicit equality bridge for `Body_Scan`,
using the existing checked `Same_Flow` / `Lemma_Flow_Equality` helpers for
`Facts`, or a separately proved `Same_Body_Scan` logical-equality helper.
This targets array extensionality in the final return's model correspondence.
It has not been implemented or tested. Keep every existing static and runtime
obligation, preserve the active run, and inspect its terminal report before
selecting the repair. The read-only diagnosis took approximately five minutes;
it launched no proof and changed no captured input.

The [terminal failed run](../failed-full/README.md) subsequently confirmed this
exact obligation and retained all emitted reports and logs.
