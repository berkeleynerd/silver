The following constructs are imprecisely supported in flow analysis. They can be used safely but might lead to unprovable checks. Warnings can be emitted by GNATprove if the ``--info`` switch is used:

* Aliasing checks might be spurious for actual parameters that are array components,

* Global generation might wrongly classify an Output item as an In_Out for subprograms that call other subprograms with no Global contract,

* Initialization of arrays inside FOR loops is only recognized when assignments to array element are directly indexed by the loopparameter,

* Initialization of multi-dimensional array inside FOR loops is only recognized when array bounds are static,

* Assignments to record objects might cause spurious data dependencies in some components of the assigned object.

