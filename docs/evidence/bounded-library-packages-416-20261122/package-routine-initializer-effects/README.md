# Original routine initializer mask composition

Focused Linux x86-64 validation for issue #416. Managed target
`Silver.ApplicationPackageRoutineInitializerEffects` and its full imported
declaration audit passed with 84,588 declarations and only the documented Lean
foundations (`propext`, `Classical.choice`, `Quot.sound`). The runner used CPU 0–1,
two automatic Lake workers, two automatic Lean threads and 8,192 MiB per Lean
process. Every captured input was rehashed before retaining this evidence.

`initializer_effects` consumes the original `RoutineCode`, its native completion
history, the reader domain at routine entry, original state declarations and the
native state-table capacity. It derives inclusion of the definition's complete
initializer effects in the native mask entering its body. Constants contribute
no global reads; each local RHS retains its original scope before declaration;
output RHSs retain the common preappend scope. Reader domains and exact original
object executions at intermediate rows are derived from the native history.
No per-row effect, checking, or safety certificate is assumed by this consumer.

This connects the prior return/footer/output helper packet and the checked local
initializer scope transport to the complete original routine initializer list.
Body read/write inclusion and final routine/footer/library/application
composition remain separate obligations. This focused evidence does not claim
complete package or whole-language assurance. Native source and domains are
unchanged; no native run was launched or interrupted.
