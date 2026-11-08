# Focused frame-flow module validation

Native Linux run `20261108T172824-28123f63af08` passed on integration `0333d33503`
at 2026-11-08 17:29:14 UTC; actual tool session 31693 exited 0. Its sole target
was the entire unchanged `Silver.ScalarFunctionFrameFlow` module. The build
completed 97 jobs and the freshly executed imported-closure audit checked 9,973
declarations with only `propext`, `Classical.choice` and `Quot.sound`.

Automatic defaults selected 22 workers and 22 threads. The managed duration was
49.063 seconds; original definitions, theorem statements and declared domains
were preserved. This focused result is partial validation and does not itself
establish the facade import or complete project coverage. The subsequent
[complete checkpoint](../../complete-lean/20261108T172947-84b3cd350332/README.md)
passed those requirements. Events, full log, focused evidence and actual tool
exit are retained beside this record.
