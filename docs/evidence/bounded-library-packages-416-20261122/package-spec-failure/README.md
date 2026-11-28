# Package specification focused native failure

Canonical complete helper run `20261122T154517-101a5dc5fa74` failed on Linux
x86_64 after 2,235.074 seconds using two workers in the shared eight-CPU
allocation. It checked `Package_Spec_At` at line 8488 with the final native
policy and retained sessions/cache. No success or complete checkpoint is claimed.

The native postcondition at line 8492 and eight preconditions at 8513, 8514,
8515, 8517, 8520, 8525, 8526 and 8537 remained unproved. The loop lacks an
explicit invariant retaining `Valid_State` and the cursor bound. The call to
`Hide_Name` also needs a valid stored signature name, which the signature
helper's successful postcondition did not expose. Repair the supporting formal
append/signature contracts and loop invariants; check each whole helper before
retrying the caller. Do not narrow the source or helper input domains.

The exact native log, managed inputs/events, unit report, summary and Output_Profile
source from `8ee9fa7a34` are retained here. Other reports remain in the managed
run. Source and failure identities are distinct from later proof repairs.
