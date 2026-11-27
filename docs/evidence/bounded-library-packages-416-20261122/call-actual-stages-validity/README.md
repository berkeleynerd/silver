# Package-call actual stages and flow validity

On Linux x86-64, run `20261127T124519-7901aa307d8b` passed four focused
targets and freshly audited 28,741 declarations in 20.817 seconds. Lake used
two workers and each Lean process used two threads. The full Call candidate
object was reused from the preceding batch, where its kernel check took 80
seconds. That preceding combined run failed because the flow-domain proof
still had two unused simplifier arguments.

`ApplicationPackageCallsActualInterpretation` interprets the complete
association, payload and finishing commands on arbitrary local stores, all
input modes and every early-return path. The composed body preserves the
original failure value even after intermediate writes. The corresponding
Call candidate checks the complete typed declarations and rendered commands,
including the two actual-loop invariants and the writable-target guard. Its
1,576 proposed tokens match the contiguous fragment from `Package_Actual`
through `end Package_Call_At` in the checked `silver_output_profile.adb`
input `d3103d20a1a57388d68f4ffdf8d0a091face76de7ad586a29631f1250a91d6b2`.

`ApplicationPackageCallsValidityNative` interprets Included, every allocated
cell of Valid_Flow and the complete Valid_Body expression. The validity
candidate checks the headers and bodies. `ApplicationPackageCallsValidityMeaning`
derives the native readers’ flow domain from this executable check and the
representable path/interval field bounds. Fixed-array extent, immutable
declaration values, mutable nonemptiness and every interval containment
follow from the source test, including zero active cells.

The complete actual loop, normalized actual projection, whole call and
authoritative full-source endpoint remain separate obligations.
