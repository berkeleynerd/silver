# Fixed-library registration counters and backing states

2026-10-20, #119 / #153. This packet consumes the four captures already retained
by [the session-domain packet](../retained-why-fixed-session-domain-20261020/README.md).
It supplies their previously unchecked **suffix** replay, without repeating the
accepted session-prefix replay or binder analyses and without a native run.

[check.py](check.py) hashes the pinned archives and consumed members, then skips
the exact accepted session-prefix read count while hashing those bytes. From
that boundary it executes the archived counter/table/snapshot observers and
three exact AST-selected helper bodies against a sequential read stream. Every
address, read size and payload length must agree. It requires EOF and the hash
of the complete log; a partial suffix cannot pass. It never executes the GDB
setup, breakpoints, inferior reads or continuation.

The identifier, Hsdecl and auxiliary JSON files reproduce byte for byte. The
full representative graph reproduces structurally, including root order, raw
payloads, sharing addresses and headers. Its descriptive scope string is
copied from the record; that prose is not a derived graph fact. Existing typed
graph/table validators check root coverage, table placement and dimensions;
the existing auxiliary decoder checks counters and backing-state dimensions.
The source/runtime/layout premises of those helpers remain unchanged.

| Process | Private identifier counter | Hsdecl next tag | Accepted prefix reads, not replayed | New sequential suffix reads |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 136,844 | 7,207 | 771,608 | 767,391 |
| Put | 121,505 | 7,178 | 641,314 | 767,195 |
| First_Or_Default | 77,806 | 6,967 | 226,338 | 754,018 |
| Is_Message | 59,035 | 6,796 | 40,058 | 744,865 |

All four observations are at `camlGnat_checks__iter_2373`, before scheduling and
driver preparation, in PIDs 3085/3323/3470/3568 respectively. Input_Is_Valid
PID 97103 remains a separate earlier **first-inline** observation with its own
accepted replay; neither its counter nor its phase is substituted here.

The author first checked Is_Message, then the other three serially. Exact
outputs and elapsed times are in [is-message-result.json](is-message-result.json)
and [other-cases-result.json](other-cases-result.json). Per-case times were
26.635560767, 28.989511206, 28.020941812 and 26.354881109 seconds in that execution
order. These are offline check measurements, not native capture/proof time or
total research cost. No successful suffix replay was repeated by the author.

For intentional reproduction, choose new output and scratch locations:

```sh
python3 -B docs/evidence/retained-why-fixed-registration-state-20261020/check.py \
  --output /path/to/new/result.json --scratch /path/to/owned/scratch
```

An optional repeated `--case` selects individual processes. The script streams
the read log but keeps a case's graph and auxiliary projections in memory.
Cases execute serially. It reads retained archives directly and does not depend
on historical installation or capture paths. [inputs.json](inputs.json) pins
the accepted manifest/summary and reused Python helper sources; the archive
manifest transitively binds the observer scripts, plan and captured data.

These are actual stopped-state values, not maximum counters, a history no-wrap
argument, a fresh-process equivalence theorem or later-entry invariants. They
do not bound allocations, table growth or traversal after registration. Joining
them to opening/scheduling/ordinary-ending demands, continuing native effects,
serialization capacity and assurance-essential artifact invariants remains
required. No current admission, installed tool, Oracle rule or frozen native
aggregate input changes. #153 and #119 remain incomplete.

Lead live model/effort and token/monetary measurements are unavailable. The
independent review identifies its own selected settings and exact target.
