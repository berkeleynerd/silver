# Frame qualification loops and state-effect trees

Focused Linux run `20261122T181527-5594c53310fa` passed a fresh audit of 21,665 declarations,
with only `propext`, `Classical.choice`, and `Quot.sound`. Two workers/two threads
shared the host eight-CPU allocation; unchanged dependencies used Lake cache.

The three complete qualification-loop equations agree with mapping the scalar,
Boolean and subtype rows, including the zero-row case and restoration of the
loop index. Their body equations and local/frame fold are kernel checked.
The three state visibility/target/read helper trees also pass structural,
precedence and scope checks using the shared declaration initialization API.
Their evaluator equations and authoritative source bindings remain outstanding.

The first whole Imported_Frame proof attempt, run
`20261122T181000-c8356152a38b`, was interrupted after its nested local/frame
normalization grew to an observed approximately 24 GiB RSS. The diagnostic and
failed run are retained in the managed ledger. Its unproved theorem was removed
from the checked module, and the next step composes the successful loop equations
through separate intermediate-state equalities. This is proof-iteration evidence,
not a complete application/source checkpoint.
