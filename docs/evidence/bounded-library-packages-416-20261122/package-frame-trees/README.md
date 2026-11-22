# Package frame trees and compaction

Focused Linux check `20261122T165935-ab890ff00d70` passed with a fresh axiom audit of 21,058 declarations, using only `propext`, `Classical.choice`, and `Quot.sound`. Two workers/two threads shared the host eight-CPU allocation; unchanged dependencies used Lake cache.

The typed imperative layer preserves bounded-loop entry limits, early returns, assignments, local scope and immutable loop parameters. Both frame trees pass recursive precedence, declaration-type, scope and writable-variable checks. The separate compaction theorem proves in-prefix writes followed by count reduction agree with shadow filtering over the full storage-size domain.

This is a focused development checkpoint. Evaluator-to-frame-model equality and authoritative source binding remain outstanding; neither the complete application proof nor complete native assurance is claimed. The compressed inputs, log and runner events preserve the actual successful run. Earlier unsuccessful attempts remain failed in the managed ledger.
