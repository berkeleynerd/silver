# Scalar procedure native mechanism probes

Native Linux x86-64, 2026-11-09, for #370. The isolated installation is
`tmp/scalar-procedures-native-370`, bootstrapped with GNAT/GNATprove 16.1.0,
GPRbuild 26.0.1 and Alire 2.1.1. No other worktree's writable tool context,
proof session or cache was shared. These are producer probes, not completed
Silver compiler admission or universal assurance.

Each archive contains the exact application/runtime sources, project, retained
native log, complete report files, and managed events/native log. The
[manifest](manifest.json) records input hashes, archive hashes, source sizes,
exact entities and diagnostic counts. Proof commands use `-U --mode=all
--report=all --warnings=continue --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000
--no-loop-unrolling --no-inlining`, with all 22 available managed workers.
Source contains no author contract or proof annotation beyond SPARK_Mode.

| Probe/run | Actual outcome |
| --- | --- |
| `safe`, `20261109T230757-42be539035fc` | 75 checks proved, complete Main/runtime reports. Four procedures plus Identity and Main have `all` coverage. The unused procedure retains its guarded division check. |
| `safe` build, `20261109T231106-b3085fae798c` | GPRbuild exit 0 with the production Ada switches and `-gnatdM`. |
| `safe` execution, `20261109T231257-93c50ed12d14` | Actual exit 0, output `procedure probes ok`. One worker reserved for this serial executable. |
| `selected`, `20261109T231302-69a3623a0c2e` | 75 checks proved. This separate input adds Silver's required explicit grouping to the four arithmetic expressions. It has not been independently built/executed in this packet. |
| `narrow-copyback`, `20261109T230848-d6b6b68c9e33` | Failed as expected: the out formal is -200..200 while the caller object is -10..10. One VC_RANGE_CHECK report contains the failed copy-back bound obligations at the actual. No result contract is supplied or inferred to narrow that formal domain. |
| `unused-full-domain`, `20261109T231054-f768820edfee` | Failed as expected: an unused procedure assigns full-range Integer input plus one. VC_OVERFLOW_CHECK remains required despite the absence of any call. |

The first `safe` managed invocation explicitly declared Main and its project;
its runtime copies were checked byte-for-byte against the root runtime sources
captured by native provenance. The later probes explicitly declare every copied
source file as an input. No completed successful probe was repeated merely to
alter its evidence packaging. The two negative runs remain failed.

The selected Main report contains six `UNINITIALIZED` info records, one per out
formal, with `how_proved=flow` and exact `initialization of "Name" proved` text.
Prefix overwrites use the existing `INEFFECTIVE` unused-assignment advisory.
Only Identity emits `SUBPROGRAM_TERMINATION`; no such record is fabricated for
procedures. Their termination argument must come from the constructive semantic
model. All calls retain ordinary Effects/AoRTE dependencies. Two Main safety
records remain after producer elimination: the in-out increment's range check
and the unused procedure's nonzero-divisor check.

`producer-sources.tar.gz` retains the five previously inspected files from SPARK
revision `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Their hashes match the
scalar-function producer account. `Compute_Call_Args` transforms out actuals
without input range checks, normal in/in-out actuals with formal expected types,
and `Compute_Store` performs ordinary checked assignment on copy-back. These
source routes and the observed records inform the pending procedure capacity
and discharge argument; samples alone do not establish it.

The later [initialization producer packet](initialization-producer.json) retains
three additional CFG/type sources and the exact-one output initialization
argument. The [copy-back producer packet](copyback-producer.json) retains
`gnat2why-expr.adb`, `why-gen-expr.adb`, and the checked-conversion/assignment
route supporting at most one scalar copy-back range-check record per writable
actual. Both refer to the same pinned revision; the adjacent JSON records the
source and archive hashes.

The source-derived Python report audit passed on the selected complete five-unit
report in managed run `20261109T233222-bc34ad831870`: 75 checks, six output
initialization witnesses and one function termination witness. Its script,
actual log, managed events and auditor bytes are retained in
[python-audit.tar.gz](python-audit.tar.gz), with hashes in
[python-audit.json](python-audit.json). This is the mechanism report audit;
expanded mutation tests and final compiler assurance are separate pending work.

Native implementation/evidence work was launched as GPT-6 Astra / Max, as
confirmed by the lead. Semantic and source-contract design uses the same
selected model and effort.
Independent runtime model confirmation and token/cost totals are unavailable.
