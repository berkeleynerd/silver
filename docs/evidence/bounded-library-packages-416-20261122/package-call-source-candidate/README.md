# Complete package call source tree — 2026-11-22

Focused Linux run `20261122T183015-5df9427f174a` passed the complete
Package_Call_At typed tree, native record/array declarations, complete function
header and body token proposal, and fresh axiom audit of 20,227 declarations.
Two workers and two process threads shared the eight-CPU host allocation.
Build took 79.840 seconds and audit 2.949 seconds.

The tree retains every declaration, default, grouped variable and Count
constraint; named and positional actual loops; explicit and implicit alias
checks; state reset; failure paths; and final validity guard. Structural typing
and lexical scope pass. The first source target failed on the namespace of the
array type extractor; correcting the reference resolved it. No source changed.

This is a complete source-tree proposal. Whole-tree denotation, native imported
helper closure, full-domain actual/effect semantics and authoritative complete
source equality remain required. Structural checks alone do not establish these.
