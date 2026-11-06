# Incremental Lean throughput evidence — 2026-11-06

The matched [four-chunk control](four-control/README.md) and
[eight-chunk candidate](eight-candidate/README.md) both passed the same complete
**4,915 line-certificate** workload for
[#327](https://github.com/berkeleynerd/silver/issues/327). The lead selected eight
chunks for the authorized next package, bounded stable identities/cache reuse
in [#328](https://github.com/berkeleynerd/silver/issues/328).

| Observed boundary | Four | Eight | Eight change |
| --- | ---: | ---: | ---: |
| External wrapper, seconds | 2001.802817 | 1341.952163 | −32.96% |
| Lake build, seconds | 1979.452 | 1318.594 | −33.39% |
| Reaped command-tree CPU, seconds | 7253.028242 | 8840.193284 | +21.88% |
| Sampled peak summed RSS, bytes | 5,588,283,392 | 8,124,977,152 | +45.39% |

[Exact comparison](comparison.json) retains the deltas, controls and disposition.
Both used the same 630 common `.olean` hashes, tool binaries, automatic 12-thread
process setting and 6144 MiB per-process allowance, with four/eight Lake workers
and equivalently forced line closures. Independent post-terminal inspection
matched captured sources and workspace modules to the frozen Git inputs; all
4,915 ordered declaration texts are byte-identical across partitions.

This is one four-then-eight ordered pair on one Linux x86-64 host. No competing
proof/native/test jobs were reported; cheap source/static work and 8.109 seconds
of idle four-control evidence retention overlapped the eight case. Host/system
load was not independently controlled. CPU includes generation/build/audit;
approximately five-second RSS samples may miss peaks and count shared pages.
Neither run paused for memory pressure.

These focused line results exclude aggregator/reconstruction and whole-project
cost. The separate [complete integrated checkpoint](integrated-complete/README.md)
passed all 638 modules with fresh auditing after the stable-content change.
[Native proof/build](native/README.md) and [90 focused test methods](tests/README.md)
also passed on matching inputs. Each packet retains its actual scope and
limitations; the comparison alone does not discharge complete assurance.
No compiled objects or cache transfers are added by evidence retention.
