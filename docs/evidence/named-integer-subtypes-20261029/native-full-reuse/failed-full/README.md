# Failed complete native attempt

Native Linux x86-64 run `20261029T165015-c6b111fb4f2a` ended with tool exit 1
at 2026-10-29 20:29:06 UTC after **13,129.891 seconds**. It used the normal
managed full command, four workers, level 2, a 30-second prover timeout and
unchanged strict warning/check options. Established sessions and solver cache
were available; this was not a cold run.

The run emitted 76 unit reports containing 15,385 proof entries and 1,432 flow
entries. **15,384 proof entries and every flow entry were proved; one static
postcondition remained unresolved**:
`silver_output_profile.adb:3414:20:VC_POSTCONDITION`,
`Body_Tail'Result = Body_Tail_Model (Text, Context, Scan, Stop)`.
The [exact session diagnosis](../body-tail-diagnostic/README.md) identifies
the timed-out subgoal and its alternatives. The native tool's final report
confirms that diagnosis. The complete coverage/provenance audit phase was not
reached, and no success manifest was produced. These reports do not establish
complete native assurance.

All 78 emitted report files match their managed retained copies; their hashes
are in `report-hashes.json`. `complete-emitted-reports.tar.gz` preserves those
files, and `unit-inventory.json` records their individual counts.
`unresolved-checks.json` retains the complete failed check and prover tree.
The input snapshot, command, tool identities, managed ledger, native log,
launcher log and tracked/generated source snapshot are retained alongside them.
At retention, all 2,561 captured native input hashes still matched the workspace,
and every captured tool executable hash was verified. All 143 tracked native
inputs match implementation `97312a790fb11a83a9607ad48ddab491711f2c3d`, as recorded
in [the input comparison](../body-tail-diagnostic/input-comparison.json).
Unrelated dirty files and original caches remain unchanged.

The separate `warn_error` report arrays contain 6,598 entries: **6,546 warnings
and 52 informational entries**. Their eight distinct messages and counts are
retained in `warning-inventory.json`. In particular, 6,236 warnings say
`function Is_Valid is assumed to return True`; the remaining warnings concern
numeric variants (170), recursive contracts (135), and imprecise array
initialization (5). These are reported separately from the one unresolved proof
entry. The output-profile unit's own `warn_error` inventory remains 50 entries.
No zero-warning claim is made.

The selected monitoring/evidence agent was GPT-6 Astra / Extra High; runtime
model confirmation and token/cost measurements are unavailable. Recovery and
read-only diagnosis took approximately eight minutes before retention. The
retention script checked the captured input/tool/report identities and archive
hashes without launching another proof. The prior interrupted run remains
interrupted; this completed attempt remains failed. The next work is a focused
repair of the exact static equality obligation in a separate worktree, followed
by the required complete validation on final inputs.
