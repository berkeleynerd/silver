# Original package and Main source assembly

Refs #416. `ApplicationPackageOriginalAssembly.accepted_assembly` starts from
accepted original Analyze and native Bundle representation. It derives native
domains, every original specification/state/routine source inventory, all phased
routine checks, the exact completion-order summary/signature table, Main's
source declaration/body inventory, local-library validity, Main checking and
header/body obligation discharge. `PackageSyntax` and `MainSyntax` contain only
original syntax/history; semantic checking, discharge, effect inclusion and
safety are separate conclusions.

`ApplicationPackageRoutineFooterEffects.function_execution_readonly` separately
proves that an original function's executable routine preserves its entire
global frame. It combines the native return's empty write mask, exact footer
storage and complete inferred-effect inclusion. This avoids treating phased
checking alone as a function-purity argument.

Both targets passed focused Linux validation with a fresh 91,679-declaration
transitive axiom audit. The managed runner used CPUs 0–1, automatic two workers
and two threads per process, and 8192 MiB per process. Every captured source
input was rehashed after the run with none missing or changed. The retained
index/evidence identify the exact run and input set.

The first assembly draft exposed one theorem namespace qualification; the next
found the exact Bool conjunction lemma name. Both were corrected without
changing source, domains or budgets. Complete routine-effect inclusion,
source-derived Main runtime stores, final assurance and full validation remain
separate requirements. No native or authoritative source build was launched.
