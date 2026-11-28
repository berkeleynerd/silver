# Package state effects and frame loop facts

Focused Linux run `20261122T180015-6497a3de895f` passed a fresh audit of 19,824 declarations,
with only `propext`, `Classical.choice`, and `Quot.sound`. Two workers/two threads
shared the host eight-CPU allocation; unchanged dependencies used Lake cache.

The raw state visibility, assignment-target and read-set equations preserve
original declaration spans and all fixed-capacity effect bits. The guard and
target-bound theorems and the read-set length/Within theorems hold for arbitrary
imported operations and represented inputs. Their native imported-operation
domains and typed/source correspondence remain separate outstanding work.
The loop theorem derives a frame fold from a checked body equation and preserves
metadata and unrelated locals, including restoration of the native loop index.

This is partial development validation. Failed syntax/normalization attempts
remain failed in the managed ledger; no complete application/source checkpoint
is claimed.
