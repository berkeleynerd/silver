# Package declaration and statement values

Focused Linux x86-64 run `20261127T122555-299f9218d337` checked
`Silver.ApplicationNativeDeclarationLaws` and
`Silver.ApplicationPackageDeclarationsStorage` with Lean 4.34.1,
two workers and two threads per process. The fresh axiom audit covered 20,745
declarations. The input digest is `98ecd429c0d50e3ed032ac6cf83e1fc19585ec400b9cfd767beb33ab8d049877`.

The declaration syntax includes typed named aggregates for the three defaulted
package records, all formal/routine/export fields used by the readers, and
typed inequalities. The aggregate guard checks every child, field uniqueness
and full component coverage where Ada has no others association. The storage
projection proves arbitrary count reassignment and the overwrite following a
one-cell increase, over arbitrary fixed backing and typed counts.

The statement reader gains projections for both discriminated condition flows,
array metadata and binding fields, the nonzero dynamic-name test, flow-vector
first index, and scalar interval aggregation. Allocation checks retain the two
condition discriminants and the flow count. The declaration evaluator
preserves arbitrary incoming values for these uninitialized records.
The packet covers this shared API and the general storage laws. The individual
reader bodies and their callee/domain proofs have separate focused targets.
