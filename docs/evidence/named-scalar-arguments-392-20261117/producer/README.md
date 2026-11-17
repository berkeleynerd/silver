# Named-argument producer inspection — 2026-11-17

This packet supplements the retained scalar function/procedure producer sources.
It retains the inspected GNAT 16.1 baseline `Sem_Util` and the pinned SPARK
`SPARK_Atree` renaming, with immutable revisions and hashes in `sources.json`.
The baseline revision is the one recorded in the earlier
[frontend study](../../../research/frontend-toolchain-feasibility.md).
It preserves the existing external frontend/producer correspondence premises;
it does not prove the tool binaries from their source.

`Sem_Util.First_Actual` (`sem_util.ads:1046–1056`, body `:9648–9664`) returns
payload expressions in declaration order. `Next_Actual` (`:25685–25742`) switches
from the positional list into the named-actual chain and continues in declaration
order; the association selector node is not a payload. `Iterate_Call_Parameters`
(`:22555–22569`) visits each formal/actual pair once. `spark_atree.ads:662–663`
renames that generic.

The existing retained `gnat2why-expr.adb:4818,4871` instantiates/calls this
iterator for `Compute_Param`. The existing `flow-control_flow_graph.adb:7056–7057`
uses it for `Handle_Parameter`, including the scalar output vertices described
in the procedure capacity account. Named association syntax therefore changes
pair selection, not the per-actual conversion/copy-back route or its record
multiplicity. The unchanged-source proof/build remains the real application
path; Silver performs no positional rewrite.

The early new-feature managed run `20261117T024551-3193d455f6c3` passed two
full-route test methods on Linux aarch64 `silver-m4pro`, including reordered
function calls and selector/caller spelling collisions. That run used the fresh
native build `20261117T024053-f027e2fd5fd4` and actual application proofs/builds;
it is focused behavior evidence, not the complete compiler checkpoint.
Additional producer reports and complete suite results remain pending.
