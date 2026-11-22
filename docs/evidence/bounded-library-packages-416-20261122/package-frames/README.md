# Package frame model focus

`ApplicationPackageFrames` passed its focused Lean build and fresh axiom audit
on Linux x86_64 on 2026-11-22, with 17,730 declarations and only `propext`,
`Classical.choice`, and `Quot.sound`. The retained result captures its exact
inputs. Two workers/two threads shared the host eight-CPU allocation.
Build 4.143 s; fresh audit 2.853 s; unchanged dependencies used Lake cache.

This checks the executable model for import qualification, shadow filtering,
and the complete state guard including nonempty/mutable bounds. It proves
retained-entry/span/range preservation and scalar header readiness. It does
not establish the native/source interpretation, the complete typed state-domain
bridge or the final application guarantee; those remain pending.
