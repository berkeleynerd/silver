# Array declaration equality diagnostic

Issue #291, 2026-10-30. Selected native worker GPT-6 Astra / Extra High;
runtime model confirmation and token/cost measurements are unavailable.

The preserved pre-xor unit run `20261030T094353-9ea6896732dc` has one completed
unresolved primitive goal in `silver_output_profile__array_declaration_at`:
`def'vc.247`, with all recorded solvers timing out, and its transformed
`def'vc.247.0`. The enclosing root is also unproved; those parent nodes are
not additional source obligations. Other unit functions are still running.

Reading the existing Why3 session preorder and its version-6 shape table maps
`.247` checksum `1d55f0dbe64d5a32bb5eb6242767c139` to shape 457: equality between
`array_declaration_at`'s result and `array_declaration_model`. After introducing
premises, shape 456 is exactly that final equality. It corresponds to the
Static postcondition at frozen source line 1557. The preceding runtime
state-validity and cursor-progress goals are proved. No solver was rerun to
obtain this mapping. A copied original gnat-json was also parsed and printed
with the existing generic Why3 executable, with no prover selected.

The first bounded repair hypothesis is to expose the existing verified
`Same_Parser_State` logical equality before the unchanged whole-record equality
in the Static postcondition. This strengthens the checked ghost contract and
adds no runtime operation. The helper includes all fixed-array extents and
Boolean metadata. It should let the splitter transport the equality through
the array initializer/model call without solving the entire record identity in
one large goal. This is a hypothesis until the focused check passes; no proof
budget, accepted input, endpoint domain or obligation is weakened.

The next experiment is one focused `Array_Declaration_At` check in the separate
one-worker native context, preserving the original two-worker unit run and its
frozen source/cache. Complete validation remains the lead's responsibility.

## First experiment and revised hypothesis

Run `20261030T105723-c229d7265935` completed in 1054.437 s on native Linux
with one worker and the original level-2, 30-second, cvc5/z3/altergo settings.
The native tool returned 0, but the managed runner correctly failed the run:
33 of 34 proof checks passed, with two additional flow/termination checks.
The unresolved check is exactly
`silver_output_profile.adb:1559:19:VC_POSTCONDITION`. Its final Why3 goal
`def'vc.262` and transformed `.262.0` time out. The preceding `.261` goal is
proved by z3. Compressed reports, original gnat-json, complete Why3 session,
and exact source hashes are retained in `native-repair/`.

A no-prover print of the generated Why3 task confirms that the added logical
record equality and original Boolean record equality remain siblings of the
final conjunction. Thus the first experiment did not establish the desired
proof cut. It is not evidence of an identified runtime-state validity failure.
The integration checkout was restored byte-for-byte from its source backup
immediately after the run; its tracked status is clean.

The next bounded hypothesis keeps the original Static equality unchanged and
places a checked `Same_Parser_State` assertion before returning the already
computed result. The native expression becomes a local constant initializer;
the expression itself is unchanged. This introduces an intermediate proof fact
without changing accepted source or equality semantics. Its possible temporary
storage effect still requires normal native validation. The source bridge
consumes this wrapper's implementation header and exact Static contract; the
model and Add_Array_Binding expression translations remain unchanged. The lead
confirmed that interface on 2026-10-30 before this second experiment.

One focused check will test the revised hypothesis with the same strict proof
settings, reusing the retained cache while keeping the first experiment's
reports and the older unit run intact. No solver or obligation budget is relaxed.

## Additional unit-run diagnostic: string reader

While the original unit run remains active on frozen `828dd16e6e`, its completed
`Read_String_In_Flow` session has one unresolved primitive goal, `def'vc.75`
(with transformed `.75.0`). All recorded solvers timed out. Its shape checksum
`ae8b0062dc9d2c657a236bdbbe755525`, shape 102, is exactly the Static equality
between the returned expression result and `Expression_At` evaluated with
`Reading_Names`, Boolean integer hiding, initializer values, and elaboration
mode. It maps to frozen source line 2184. The cursor-progress check is proved.
The native wrapper retains a local scalar environment copy `Overlay`; its
postcondition instead refers to the function result `Reading_Names` directly.
The task also expands the executable expression reader into its tail call.

This is not yet a demonstrated bug in the Boolean admission logic. The next
specific question is whether a checked logical-array identity assertion for
`Overlay.Items` and `Reading_Names(Context,Facts).Items`, plus their checked count
identity, gives the existing expression call the missing congruence fact. The
existing `Same_Parser_Scalar_Items` helper includes fixed array extents and has
its own checked Logical_Equal annotation. No string-reader repair or solver
rerun has yet been made; first finish the active array-declaration cut experiment.
The completed session, shapes, gnat-json, and frozen source hash are retained in
`native-repair/read-string-in-flow/`; they do not claim a successful unit run.

## Checked array-declaration cut result

Run `20261030T112107-09c976deac55` passed all 37 focused checks with the same
strict proof settings in 607.875 s. The intermediate
logical equality assertion and the unchanged final Static equality both proved.
The exact captured source hashes, original proof reports, complete Why3 session,
shapes, gnat-json, native log and managed events are retained in
`native-repair/array-cut/`. The shared checkout's 131 source files were then
restored byte-for-byte from the original backup. This is a focused repair result;
complete unit validation and the separate string-reader equality remain pending.
