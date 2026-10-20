# Fixed-library registration state: exact offline suffix replay

2026-10-20, research #119 / #153. The
[retained evidence packet](../evidence/retained-why-fixed-registration-state-20261020/README.md)
checks the previously unreplayed counter, Hsdecl, representative-graph and
auxiliary snapshots from the four accepted registration-endpoint captures.
It does not repeat their native execution, session-prefix replay or binder
computation. Input_Is_Valid's prior first-inline evidence remains separate.

Sequential replay reproduces every remaining memory read through EOF, all three
snapshot JSON outputs byte for byte, and the complete representative graph
structurally. Whole-log hashes bind both the reused prefix and new suffix.
The existing typed validators establish internal graph/table consistency and
decode four auxiliary counter/backing states at each stop. The packet retains
the exact process, argv/environment, binary/input identities and capture guards.

The resulting private identifier counters are **136,844 / 121,505 / 77,806 /
59,035**, for Put_Line, Put, First_Or_Default and Is_Message respectively.
These supply missing actual-state inputs for subsequent per-process composition.
They are neither a bound on the rest of those runs nor interchangeable process
states. Hsdecl and auxiliary observations are in the packet; no continuing
capacity flag is asserted for them.

To use these observations in a capacity rule still requires a source argument
joining the selected execution family to these states, pre-endpoint history and
freshness, later allocation and identifier charges, continued native/signal
configuration, and the required storage/serialization representations. The
ordinary-ending control transfer supplies conditional save multiplicity, not
these missing state transitions. A finite snapshot cannot discharge those
universal obligations. #153 and the full #119 goal remain unfinished.

The author performed four new offline suffix checks, about three million reads
in total. No native compiler, GNATprove, solver, Lean build or full test suite
ran. Exact timings and reproduction instructions are retained in the packet.
No Oracle, toolchain, source pin, admission or production behavior changes.
Independent review is required before integration acceptance.
