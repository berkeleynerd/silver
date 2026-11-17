# Procedure lexical scanner candidate, 2026-11-10

Managed Linux run `20261110T013948-d5400a83673c` passed the exact scanner
source candidate and fresh axiom audit: 111 build jobs, 14,594 declarations,
and only `propext`, `Classical.choice`, `Quot.sound`. Build took 1,523.440 s;
audit took 91.714 s. It reserved two workers and two threads per process
alongside the separately reserved native and proof streams.

The ten fragments check all scanner headers, record, recursive step/model
and loop against the refreshed whole-file reviewed pin. The complete scanner
helper block is byte-identical to successful native run
`20261110T002858-36ecd7c485a1`; its SHA-256 is
`45aaa76ca33313b45ee49ee3871a77f81e7504c736d1a4ad746f14af1ec294e9`.
The previously checked native interpretations retain the complete native domain.

The cache seeds are explicitly recorded in the adjacent JSON files. They
include successful module objects from both successful and failed earlier
runs, with complete artifact families and traces preserved. Lake invalidation
and a fresh focused audit ran after copying. No clean build or kernel replay
is claimed. The compressed files are original runner output; this README and
summary are lead-authored.

The authoritative adapter is drafted in `ProcedureNameSourceChecks.lean`,
but it was not a target of this run. Its final certificate/token equality and
the remaining declaration/call/body source correspondence remain pending.
Updating the whole-file pin alone makes no claim about those other helpers.
